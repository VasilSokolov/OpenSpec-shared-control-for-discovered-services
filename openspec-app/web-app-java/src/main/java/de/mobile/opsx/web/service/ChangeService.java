package de.mobile.opsx.web.service;

import java.io.IOException;
import java.io.Reader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

import org.springframework.stereotype.Service;
import org.yaml.snakeyaml.Yaml;

import de.mobile.opsx.web.config.ControlRoot;
import de.mobile.opsx.web.model.ChangeSummary;
import de.mobile.opsx.web.model.WorkItem;
import de.mobile.opsx.web.util.SafePaths;

/**
 * Read model over the file-based control plane. Parses {@code openspec/changes/<id>/}
 * defensively: unknown or missing fields never crash the console. This service
 * only reads; it never reimplements a governance rule — validation and approval
 * semantics stay in the bash gates.
 */
@Service
public class ChangeService {

    private final Path root;

    public ChangeService(ControlRoot controlRoot) {
        this.root = controlRoot.path();
    }

    private Path changesDir() {
        return root.resolve("openspec/changes");
    }

    private Path archiveDir() {
        return root.resolve("openspec/changes/archive");
    }

    /** Active changes under {@code openspec/changes/} (excludes {@code archive/}). */
    public List<ChangeSummary> listChanges() {
        return listIn(changesDir(), false);
    }

    /** Archived changes under {@code openspec/changes/archive/}. */
    public List<ChangeSummary> listArchived() {
        Path dir = archiveDir();
        if (!Files.isDirectory(dir)) {
            return List.of();
        }
        return listIn(dir, true);
    }

    private List<ChangeSummary> listIn(Path dir, boolean archived) {
        if (!Files.isDirectory(dir)) {
            throw new IllegalStateException("changes directory not found: " + dir);
        }
        List<ChangeSummary> out = new ArrayList<>();
        try (Stream<Path> entries = Files.list(dir)) {
            for (Path path : (Iterable<Path>) entries::iterator) {
                if (!Files.isDirectory(path)) {
                    continue;
                }
                String name = path.getFileName().toString();
                if (!SafePaths.isSafeId(name)) {
                    continue;
                }
                // In the active dir, `archive` is the archive container, not a change.
                if (!archived && name.equals("archive")) {
                    continue;
                }
                if (!Files.isRegularFile(path.resolve(".openspec.yaml"))) {
                    continue;
                }
                out.add(loadChange(name, archived));
            }
        } catch (IOException e) {
            throw new IllegalStateException(dir + ": " + e.getMessage(), e);
        }
        out.sort(Comparator.comparing(ChangeSummary::id));
        return out;
    }

    /** Resolve a change by id, preferring the active dir, then the archive. */
    public ChangeSummary getChange(String id) {
        if (!SafePaths.isSafeId(id)) {
            throw new IllegalArgumentException("invalid change id: " + id);
        }
        if (Files.isDirectory(changesDir().resolve(id))) {
            return loadChange(id, false);
        }
        if (Files.isDirectory(archiveDir().resolve(id))) {
            return loadChange(id, true);
        }
        throw new IllegalArgumentException("change not found: " + id);
    }

    private ChangeSummary loadChange(String id, boolean archived) {
        Path base = (archived ? archiveDir() : changesDir()).resolve(id);
        if (!Files.isDirectory(base)) {
            throw new IllegalArgumentException("change not found: " + id);
        }

        String status = strField(readYaml(base.resolve(".openspec.yaml")), "status");

        String approval = strField(readYaml(base.resolve("approval.yaml")), "status");
        if (approval.isEmpty()) {
            approval = "unknown";
        }

        String title = strField(readYaml(base.resolve("context/intake/work-item.yaml")), "title");

        List<WorkItem> workItems = new ArrayList<>();
        Map<String, Object> ws = readYaml(base.resolve("workset.yaml"));
        Object items = ws.get("work_items");
        if (items instanceof List<?> list) {
            for (Object it : list) {
                if (it instanceof Map<?, ?> m) {
                    workItems.add(new WorkItem(
                            str(m, "id"),
                            str(m, "status"),
                            str(m, "module_id"),
                            str(m, "branch"),
                            str(m, "commit")));
                }
            }
        }

        return new ChangeSummary(id, status, approval, title, workItems, listEvidence(base), archived);
    }

    private Path changeDir(String id) {
        Path active = changesDir().resolve(id);
        if (Files.isDirectory(active)) {
            return active;
        }
        Path archived = archiveDir().resolve(id);
        if (Files.isDirectory(archived)) {
            return archived;
        }
        throw new IllegalArgumentException("change not found: " + id);
    }

    private List<String> listEvidence(Path base) {
        Path evidenceRoot = base.resolve("context/evidence");
        if (!Files.isDirectory(evidenceRoot)) {
            return List.of();
        }
        List<String> files = new ArrayList<>();
        try (Stream<Path> walk = Files.walk(evidenceRoot)) {
            walk.filter(Files::isRegularFile)
                    .forEach(p -> files.add(evidenceRoot.relativize(p).toString()));
        } catch (IOException e) {
            return List.of();
        }
        files.sort(Comparator.naturalOrder());
        return files;
    }

    /**
     * Read one evidence file. Path-traversal guard: the resolved target must stay
     * under {@code context/evidence/} after canonicalization.
     */
    public String readEvidence(String id, String rel) {
        if (!SafePaths.isSafeId(id)) {
            throw new IllegalArgumentException("invalid change id: " + id);
        }
        Path evidenceRoot = changeDir(id).resolve("context/evidence");
        try {
            Path canonRoot = evidenceRoot.toRealPath();
            Path canonTarget = evidenceRoot.resolve(rel).toRealPath();
            if (!canonTarget.startsWith(canonRoot)) {
                throw new IllegalArgumentException("evidence path escapes the change directory");
            }
            return Files.readString(canonTarget);
        } catch (IOException e) {
            throw new IllegalArgumentException(e.getMessage(), e);
        }
    }

    /**
     * Toggle the top-level {@code status:} of {@code approval.yaml} with a single-line,
     * comment-preserving edit (ported from the Rust core's {@code set_approval}). It
     * never rewrites the whole document — which would drop comments and reorder keys —
     * and never touches any other field. Archived changes are immutable here.
     */
    public ChangeSummary setApproval(String id, boolean approved) {
        if (!SafePaths.isSafeId(id)) {
            throw new IllegalArgumentException("invalid change id: " + id);
        }
        Path base = changesDir().resolve(id);
        if (!Files.isDirectory(base)) {
            throw new IllegalArgumentException("active change not found: " + id);
        }
        Path path = base.resolve("approval.yaml");
        String newStatus = approved ? "approved" : "pending";
        try {
            String text = Files.readString(path);
            boolean endsWithNewline = text.endsWith("\n");
            List<String> lines = new ArrayList<>(Arrays.asList(text.split("\n", -1)));
            // Mirror Rust's str::lines(): a newline-terminated file has no trailing
            // empty element.
            if (endsWithNewline && !lines.isEmpty() && lines.get(lines.size() - 1).isEmpty()) {
                lines.remove(lines.size() - 1);
            }
            boolean replaced = false;
            for (int i = 0; i < lines.size(); i++) {
                if (!replaced && lines.get(i).startsWith("status:")) {
                    lines.set(i, "status: " + newStatus);
                    replaced = true;
                }
            }
            if (!replaced) {
                throw new IllegalArgumentException("no top-level `status:` line in approval.yaml");
            }
            String result = String.join("\n", lines);
            if (endsWithNewline) {
                result += "\n";
            }
            Files.writeString(path, result);
        } catch (IOException e) {
            throw new IllegalArgumentException(e.getMessage(), e);
        }
        return loadChange(id, false);
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Object> readYaml(Path path) {
        if (!Files.isRegularFile(path)) {
            return Map.of();
        }
        try (Reader reader = Files.newBufferedReader(path)) {
            Object parsed = new Yaml().load(reader);
            if (parsed instanceof Map<?, ?> m) {
                return (Map<String, Object>) m;
            }
        } catch (Exception e) {
            // Defensive: malformed/optional file never crashes the console.
        }
        return Map.of();
    }

    private static String strField(Map<String, Object> map, String key) {
        return str(map, key);
    }

    private static String str(Map<?, ?> map, String key) {
        Object v = map.get(key);
        return (v instanceof String s) ? s : (v == null ? "" : String.valueOf(v));
    }
}
