package de.mobile.opsx.web.config;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Resolves the control repository root, mirroring the Rust core: prefer
 * {@code OPSX_CONTROL_ROOT}, otherwise walk up from the working directory. A
 * directory is a control root when it carries {@code openspec/config.yaml} and
 * {@code tools/git-preflight.sh}. Never hardcoded.
 */
@Component
public class ControlRoot {

    private static final Logger log = LoggerFactory.getLogger(ControlRoot.class);

    private final Path root;

    public ControlRoot() {
        this.root = resolve();
        log.info("resolved control root: {}", root);
    }

    private ControlRoot(Path root, boolean explicit) {
        this.root = root;
    }

    /** Test seam: bind an explicit root without the filesystem probe. */
    public static ControlRoot forRoot(Path root) {
        return new ControlRoot(root, true);
    }

    public Path path() {
        return root;
    }

    private static Path resolve() {
        String env = System.getenv("OPSX_CONTROL_ROOT");
        if (env != null && !env.isBlank()) {
            Path candidate = Paths.get(env).toAbsolutePath().normalize();
            if (isControlRoot(candidate)) {
                return candidate;
            }
            throw new IllegalStateException("OPSX_CONTROL_ROOT is not a control repository: " + env);
        }
        Path dir = Paths.get("").toAbsolutePath().normalize();
        while (dir != null) {
            if (isControlRoot(dir)) {
                return dir;
            }
            dir = dir.getParent();
        }
        throw new IllegalStateException(
                "could not locate the control repository; set OPSX_CONTROL_ROOT");
    }

    private static boolean isControlRoot(Path dir) {
        return Files.isRegularFile(dir.resolve("openspec/config.yaml"))
                && Files.isRegularFile(dir.resolve("tools/git-preflight.sh"));
    }
}
