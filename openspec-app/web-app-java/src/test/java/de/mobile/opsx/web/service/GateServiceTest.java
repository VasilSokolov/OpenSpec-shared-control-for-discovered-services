package de.mobile.opsx.web.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import de.mobile.opsx.web.config.ControlRoot;
import de.mobile.opsx.web.model.CommandResult;

class GateServiceTest {

    @TempDir
    Path root;

    private void writePreflight(String body) throws Exception {
        Path script = root.resolve("tools/git-preflight.sh");
        Files.createDirectories(script.getParent());
        Files.writeString(script, "#!/usr/bin/env bash\n" + body + "\n");
    }

    @Test
    void capturesStdoutStderrAndExitCode() throws Exception {
        writePreflight("echo hello; echo oops >&2; exit 3");
        GateService gates = new GateService(ControlRoot.forRoot(root), Duration.ofSeconds(30));

        CommandResult r = gates.runPreflight();

        assertThat(r.exitCode()).isEqualTo(3);
        assertThat(r.ok()).isFalse();
        assertThat(r.stdout()).contains("hello");
        assertThat(r.stderr()).contains("oops");
    }

    @Test
    void terminatesAndReportsWhenScriptExceedsTimeout() throws Exception {
        writePreflight("sleep 30");
        GateService gates = new GateService(ControlRoot.forRoot(root), Duration.ofMillis(300));

        long start = System.nanoTime();
        CommandResult r = gates.runPreflight();
        Duration elapsed = Duration.ofNanos(System.nanoTime() - start);

        assertThat(elapsed).isLessThan(Duration.ofSeconds(10));
        assertThat(r.exitCode()).isNull();
        assertThat(r.ok()).isFalse();
        assertThat(r.stderr()).contains("timed out");
    }
}
