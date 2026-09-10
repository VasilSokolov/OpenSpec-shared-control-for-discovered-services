package de.mobile.opsx.web.model;

import java.util.List;

/**
 * Structured output of one pinned gate-script run. Mirrors the Rust core's
 * {@code CommandOutput}: a non-zero (or null) exit code is a normal result,
 * not an error.
 */
public record CommandResult(
        String script,
        List<String> args,
        Integer exitCode,
        String stdout,
        String stderr) {

    public boolean ok() {
        return exitCode != null && exitCode == 0;
    }

    public String command() {
        return args.isEmpty() ? script : script + " " + String.join(" ", args);
    }
}
