package de.mobile.opsx.web.service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import de.mobile.opsx.web.config.ControlRoot;
import de.mobile.opsx.web.model.CommandResult;
import de.mobile.opsx.web.util.SafePaths;

/**
 * Runs the pinned control scripts. One method per script; there is deliberately
 * no generic "run any command" entry point, no shell string is ever interpolated
 * (we invoke {@code bash <script> <args...>} with a fixed argument list, so there
 * is no command-injection surface), and no push is ever issued — preflight is
 * fetch-only by the script's own guarantee.
 *
 * <p>Web scope is read + safe gates only: preflight and validate. Approval writes,
 * worktree/bootstrap provisioning, and the agent bridge are intentionally absent.
 */
@Service
public class GateService {

    /**
     * Hard ceiling on any gate run. {@code git-preflight.sh} does a {@code git fetch},
     * so a network stall, credential/host-key prompt, or index lock could otherwise
     * block a request thread forever and, when repeated, exhaust the servlet pool.
     */
    static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(120);

    private final Path root;
    private final Duration timeout;

    @Autowired
    public GateService(ControlRoot controlRoot) {
        this(controlRoot, DEFAULT_TIMEOUT);
    }

    GateService(ControlRoot controlRoot, Duration timeout) {
        this.root = controlRoot.path();
        this.timeout = timeout;
    }

    public CommandResult runPreflight() {
        return runScript("tools/git-preflight.sh", List.of());
    }

    public CommandResult runValidate(String id) {
        if (!SafePaths.isSafeId(id)) {
            throw new IllegalArgumentException("invalid change id: " + id);
        }
        return runScript("tools/validate-change-package.sh",
                List.of("--change", "openspec/changes/" + id));
    }

    private CommandResult runScript(String scriptRel, List<String> args) {
        Path script = root.resolve(scriptRel);
        if (!Files.isRegularFile(script)) {
            throw new IllegalStateException("pinned script not found: " + script);
        }

        List<String> command = new ArrayList<>();
        command.add("bash");
        command.add(script.toString());
        command.addAll(args);

        ProcessBuilder pb = new ProcessBuilder(command).directory(root.toFile());
        Process process = null;
        try {
            process = pb.start();
            // Drain both streams on their own threads: reading either to EOF on the
            // caller thread would block until the child exits, defeating the timeout,
            // and a full pipe buffer on one stream can deadlock the read of the other.
            StreamDrainer out = new StreamDrainer(process.getInputStream());
            StreamDrainer err = new StreamDrainer(process.getErrorStream());
            out.start();
            err.start();

            boolean finished = process.waitFor(timeout.toMillis(), TimeUnit.MILLISECONDS);
            if (!finished) {
                process.destroyForcibly();
                out.join(1000);
                err.join(1000);
                return new CommandResult(
                        scriptRel,
                        args,
                        null,
                        out.text(),
                        "gate timed out after " + timeout.toSeconds() + "s and was terminated");
            }
            out.join();
            err.join();
            return new CommandResult(
                    scriptRel,
                    args,
                    process.exitValue(),
                    out.text(),
                    err.text());
        } catch (IOException e) {
            throw new IllegalStateException("failed to run " + scriptRel + ": " + e.getMessage(), e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("interrupted running " + scriptRel, e);
        } finally {
            if (process != null && process.isAlive()) {
                process.destroyForcibly();
            }
        }
    }

    /**
     * Reads a child-process stream to EOF on its own thread. {@code Process} closes
     * the underlying descriptors when it is reaped, so we only close the stream we own.
     */
    private static final class StreamDrainer extends Thread {
        private final InputStream stream;
        private volatile byte[] bytes = new byte[0];

        StreamDrainer(InputStream stream) {
            this.stream = stream;
            setDaemon(true);
        }

        @Override
        public void run() {
            try (InputStream in = stream) {
                bytes = in.readAllBytes();
            } catch (IOException ignored) {
                // Stream closed by process teardown (e.g. destroyForcibly); keep what we have.
            }
        }

        String text() {
            return new String(bytes, StandardCharsets.UTF_8);
        }
    }
}
