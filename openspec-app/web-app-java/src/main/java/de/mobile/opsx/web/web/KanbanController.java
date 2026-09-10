package de.mobile.opsx.web.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import de.mobile.opsx.web.service.KanbanBoardService;

/**
 * Serves the Jira-style Kanban board template at {@code /kanban}. It is a
 * read-only, client-side demo: SortableJS lets you drag cards between columns in
 * the browser, but nothing is persisted. Use it as a starting template — hand the
 * {@code board} fragment any {@link de.mobile.opsx.web.model.KanbanBoard}.
 */
@Controller
public class KanbanController {

    private final KanbanBoardService boards;

    public KanbanController(KanbanBoardService boards) {
        this.boards = boards;
    }

    @GetMapping("/kanban")
    public String kanban(Model model) {
        model.addAttribute("board", boards.demoBoard());
        return "kanban";
    }
}
