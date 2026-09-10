package de.mobile.opsx.web.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import de.mobile.opsx.web.config.ControlRoot;
import de.mobile.opsx.web.model.ChangeSummary;

class ChangeServiceTest {

    @TempDir
    Path root;

    ChangeService service;

    @BeforeEach
    void setUp() throws Exception {
        Path change = root.resolve("openspec/changes/demo");
        Files.createDirectories(change.resolve("context/evidence/sub"));
        Files.writeString(change.resolve(".openspec.yaml"), "status: proposed\n");
        Files.writeString(change.resolve("approval.yaml"),
                "# approval record — comments must survive a toggle\n"
                        + "change_id: demo\n"
                        + "status: approved\n"
                        + "jira: none\n");
        Files.createDirectories(change.resolve("context/intake"));
        Files.writeString(change.resolve("context/intake/work-item.yaml"), "title: Demo change\n");
        Files.writeString(change.resolve("workset.yaml"),
                "work_items:\n"
                        + "  - id: wi-1\n"
                        + "    status: implemented\n"
                        + "    module_id: openspec-app/desktop\n"
                        + "    branch: \"\"\n"
                        + "    commit: \"\"\n");
        Files.writeString(change.resolve("context/evidence/note.txt"), "hello evidence");
        Files.writeString(change.resolve("context/evidence/sub/deep.txt"), "deep");
        // A real file outside context/evidence (two levels up) the traversal test
        // must never reach; it exists so canonicalization resolves and the guard,
        // not a not-found error, is what rejects it.
        Files.writeString(change.resolve("secret.txt"), "TOP SECRET");

        service = new ChangeService(ControlRoot.forRoot(root));
    }

    @Test
    void listsAndParsesChange() {
        List<ChangeSummary> all = service.listChanges();
        assertThat(all).hasSize(1);
        ChangeSummary c = all.get(0);
        assertThat(c.id()).isEqualTo("demo");
        assertThat(c.status()).isEqualTo("proposed");
        assertThat(c.approval()).isEqualTo("approved");
        assertThat(c.title()).isEqualTo("Demo change");
        assertThat(c.workItems()).singleElement()
                .satisfies(w -> {
                    assertThat(w.id()).isEqualTo("wi-1");
                    assertThat(w.moduleId()).isEqualTo("openspec-app/desktop");
                });
        assertThat(c.evidence()).contains("note.txt", "sub/deep.txt");
    }

    @Test
    void readsEvidenceUnderTheChangeDir() {
        assertThat(service.readEvidence("demo", "note.txt")).isEqualTo("hello evidence");
        assertThat(service.readEvidence("demo", "sub/deep.txt")).isEqualTo("deep");
    }

    @Test
    void rejectsTraversalOutsideEvidence() {
        assertThatThrownBy(() -> service.readEvidence("demo", "../../secret.txt"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("escapes");
    }

    @Test
    void rejectsUnsafeId() {
        assertThatThrownBy(() -> service.getChange("../demo"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("invalid change id");
    }

    @Test
    void togglesApprovalPreservingCommentsAndOtherFields() throws Exception {
        ChangeSummary pending = service.setApproval("demo", false);
        assertThat(pending.approval()).isEqualTo("pending");

        String text = Files.readString(root.resolve("openspec/changes/demo/approval.yaml"));
        assertThat(text)
                .contains("# approval record — comments must survive a toggle")
                .contains("change_id: demo")
                .contains("status: pending")
                .contains("jira: none")
                .doesNotContain("status: approved");
        assertThat(text).endsWith("\n");

        ChangeSummary approved = service.setApproval("demo", true);
        assertThat(approved.approval()).isEqualTo("approved");
        assertThat(Files.readString(root.resolve("openspec/changes/demo/approval.yaml")))
                .contains("status: approved");
    }

    @Test
    void listsArchivedChanges() throws Exception {
        Path archived = root.resolve("openspec/changes/archive/old-change");
        Files.createDirectories(archived);
        Files.writeString(archived.resolve(".openspec.yaml"), "status: implemented\n");
        Files.writeString(archived.resolve("approval.yaml"), "status: approved\n");

        assertThat(service.listChanges()).extracting(ChangeSummary::id).containsExactly("demo");
        assertThat(service.listArchived())
                .singleElement()
                .satisfies(c -> {
                    assertThat(c.id()).isEqualTo("old-change");
                    assertThat(c.archived()).isTrue();
                });
        assertThat(service.getChange("old-change").archived()).isTrue();
    }

    @Test
    void refusesToApproveArchivedChange() throws Exception {
        Path archived = root.resolve("openspec/changes/archive/old-change");
        Files.createDirectories(archived);
        Files.writeString(archived.resolve(".openspec.yaml"), "status: implemented\n");
        Files.writeString(archived.resolve("approval.yaml"), "status: approved\n");

        assertThatThrownBy(() -> service.setApproval("old-change", false))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("active change not found");
    }
}
