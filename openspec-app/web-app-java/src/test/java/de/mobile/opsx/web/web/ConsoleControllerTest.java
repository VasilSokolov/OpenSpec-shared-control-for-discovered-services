package de.mobile.opsx.web.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.nio.file.Path;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.ui.ConcurrentModel;
import org.springframework.ui.Model;

import de.mobile.opsx.web.config.ControlRoot;
import de.mobile.opsx.web.model.ChangeSummary;
import de.mobile.opsx.web.service.ChangeService;
import de.mobile.opsx.web.service.GateService;

class ConsoleControllerTest {

    private ChangeService changes;
    private ConsoleController controller;

    @BeforeEach
    void setUp() {
        changes = mock(ChangeService.class);
        GateService gates = mock(GateService.class);
        ControlRoot controlRoot = ControlRoot.forRoot(Path.of("/tmp"));
        controller = new ConsoleController(changes, gates, controlRoot);
        when(changes.listChanges()).thenReturn(List.of());
        when(changes.listArchived()).thenReturn(List.of());
    }

    private static ChangeSummary summary(String id, boolean approved) {
        return new ChangeSummary(id, "proposed", approved ? "approved" : "pending",
                "", List.of(), List.of(), false);
    }

    @Test
    void moveToApprovedApprovesAndReturnsBoard() {
        when(changes.setApproval("demo", true)).thenReturn(summary("demo", true));
        Model model = new ConcurrentModel();

        String view = controller.move("demo", "approved", model);

        verify(changes).setApproval("demo", true);
        assertThat(view).isEqualTo("fragments :: board");
        assertThat(model.getAttribute("proposed")).isNotNull();
        assertThat(model.getAttribute("approved")).isNotNull();
        assertThat(model.getAttribute("archived")).isNotNull();
    }

    @Test
    void moveToProposedUnapproves() {
        when(changes.setApproval("demo", false)).thenReturn(summary("demo", false));
        Model model = new ConcurrentModel();

        String view = controller.move("demo", "proposed", model);

        verify(changes).setApproval("demo", false);
        assertThat(view).isEqualTo("fragments :: board");
    }

    @Test
    void boardRendersLanesWithoutMutating() {
        Model model = new ConcurrentModel();

        String view = controller.board(model);

        assertThat(view).isEqualTo("fragments :: board");
        assertThat(model.getAttribute("proposed")).isNotNull();
        assertThat(model.getAttribute("approved")).isNotNull();
        assertThat(model.getAttribute("archived")).isNotNull();
        verify(changes, never()).setApproval(org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyBoolean());
    }

    @Test
    void moveToUnsupportedLaneReturnsErrorAndDoesNotWrite() {
        Model model = new ConcurrentModel();

        String view = controller.move("demo", "archived", model);

        assertThat(view).isEqualTo("fragments :: error");
        assertThat(model.getAttribute("error")).asString().contains("unsupported lane");
        verify(changes, never()).setApproval(org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyBoolean());
    }
}
