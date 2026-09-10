package de.mobile.opsx.web.web;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import de.mobile.opsx.web.config.ControlRoot;
import de.mobile.opsx.web.model.ChangeSummary;
import de.mobile.opsx.web.service.ChangeService;
import de.mobile.opsx.web.service.GateService;

/**
 * Server-side rendered console. The landing page is a Jira-style table of active
 * and archived changes; gate actions, approval toggles, and the evidence viewer
 * return HTML fragments swapped in by HTMX.
 */
@Controller
public class ConsoleController {

    private final ChangeService changes;
    private final GateService gates;
    private final ControlRoot controlRoot;

    public ConsoleController(ChangeService changes, GateService gates, ControlRoot controlRoot) {
        this.changes = changes;
        this.gates = gates;
        this.controlRoot = controlRoot;
    }

    @GetMapping("/")
    public String index(Model model) {
        addBoardModel(model);
        model.addAttribute("controlRootPath", controlRoot.path().toString());
        return "index";
    }

    /**
     * Drag a card between the Proposed and Approved lanes. The only state this
     * mutates is {@code approval.yaml}'s top-level status (the same safe write as
     * the approve/unapprove buttons); it never applies a change or runs an agent.
     * Returns the whole board fragment so the server re-render is the source of
     * truth for which lane a card lands in and which actions it exposes.
     */
    @PostMapping("/changes/{id}/move")
    public String move(@PathVariable String id, @RequestParam String to, Model model) {
        try {
            boolean approved = switch (to) {
                case "approved" -> true;
                case "proposed" -> false;
                default -> throw new IllegalArgumentException("unsupported lane: " + to);
            };
            changes.setApproval(id, approved);
        } catch (RuntimeException e) {
            model.addAttribute("error", e.getMessage());
            return "fragments :: error";
        }
        addBoardModel(model);
        return "fragments :: board";
    }

    /**
     * Read-only board re-render. The Apply and Archived lanes are copy-only: a
     * drop there mutates no state, so the client copies the command and calls this
     * to snap the card back to the server's true lane.
     */
    @GetMapping("/board")
    public String board(Model model) {
        addBoardModel(model);
        return "fragments :: board";
    }

    private void addBoardModel(Model model) {
        List<ChangeSummary> active = changes.listChanges();
        model.addAttribute("proposed", active.stream().filter(c -> !c.approved()).toList());
        model.addAttribute("approved", active.stream().filter(ChangeSummary::approved).toList());
        model.addAttribute("archived", changes.listArchived());
    }

    @GetMapping("/changes/{id}")
    public String detail(@PathVariable String id, Model model) {
        model.addAttribute("controlRootPath", controlRoot.path().toString());
        try {
            model.addAttribute("change", changes.getChange(id));
        } catch (RuntimeException e) {
            model.addAttribute("detailError", e.getMessage());
        }
        return "detail";
    }

    @GetMapping("/changes/{id}/evidence")
    public String evidence(@PathVariable String id, @RequestParam String path, Model model) {
        try {
            model.addAttribute("evidencePath", path);
            model.addAttribute("evidenceContent", changes.readEvidence(id, path));
            return "fragments :: evidenceView";
        } catch (RuntimeException e) {
            model.addAttribute("error", e.getMessage());
            return "fragments :: error";
        }
    }

    @PostMapping("/changes/{id}/approve")
    public String approve(@PathVariable String id, Model model) {
        return applyApproval(id, true, model);
    }

    @PostMapping("/changes/{id}/unapprove")
    public String unapprove(@PathVariable String id, Model model) {
        return applyApproval(id, false, model);
    }

    private String applyApproval(String id, boolean approved, Model model) {
        try {
            model.addAttribute("change", changes.setApproval(id, approved));
            return "fragments :: approvalControl";
        } catch (RuntimeException e) {
            model.addAttribute("error", e.getMessage());
            return "fragments :: error";
        }
    }

    @PostMapping("/preflight")
    public String preflight(Model model) {
        return gateResult(model, gates::runPreflight);
    }

    @PostMapping("/changes/{id}/validate")
    public String validate(@PathVariable String id, Model model) {
        return gateResult(model, () -> gates.runValidate(id));
    }

    private String gateResult(Model model, GateCall call) {
        try {
            model.addAttribute("result", call.run());
            return "fragments :: commandResult";
        } catch (RuntimeException e) {
            model.addAttribute("error", e.getMessage());
            return "fragments :: error";
        }
    }

    @FunctionalInterface
    private interface GateCall {
        de.mobile.opsx.web.model.CommandResult run();
    }
}
