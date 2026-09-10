package de.mobile.opsx.web.util;

/**
 * Argument-validation guards, ported verbatim from the Rust core so the Java
 * server keeps the same command-injection / path-traversal posture.
 */
public final class SafePaths {

    private SafePaths() {
    }

    /**
     * A change id must be a single safe path segment: non-empty, ≤128 chars,
     * not "." or "..", and only [A-Za-z0-9-_.].
     */
    public static boolean isSafeId(String id) {
        if (id == null || id.isEmpty() || id.length() > 128) {
            return false;
        }
        if (id.equals(".") || id.equals("..")) {
            return false;
        }
        for (int i = 0; i < id.length(); i++) {
            char c = id.charAt(i);
            boolean ok = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
                    || (c >= '0' && c <= '9') || c == '-' || c == '_' || c == '.';
            if (!ok) {
                return false;
            }
        }
        return true;
    }
}
