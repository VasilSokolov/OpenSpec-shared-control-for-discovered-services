package de.mobile.opsx.web.service;

import java.util.List;

import org.springframework.stereotype.Service;

import de.mobile.opsx.web.model.KanbanAssignee;
import de.mobile.opsx.web.model.KanbanBoard;
import de.mobile.opsx.web.model.KanbanCard;
import de.mobile.opsx.web.model.KanbanColumn;
import de.mobile.opsx.web.model.KanbanIssueType;
import de.mobile.opsx.web.model.KanbanPriority;

/**
 * Supplies the sample board that backs the Jira-style template page. Swap the
 * body of {@link #demoBoard()} (or add your own producer) to drive the same
 * fragments from real data — the template renders whatever {@link KanbanBoard}
 * it is handed.
 */
@Service
public class KanbanBoardService {

    private static final KanbanAssignee GK = new KanbanAssignee("GK", "avatar-red");
    private static final KanbanAssignee UP = new KanbanAssignee("UP", "avatar-blue");
    private static final KanbanAssignee VS = new KanbanAssignee("VS", "avatar-green");

    public KanbanBoard demoBoard() {
        var refinement = new KanbanColumn("In Refinement", List.of(
                card("QCT-5125", "Update the UI/UX to the new Design", KanbanIssueType.STORY,
                        "Update the UI/UX to th…", "chip-grey", KanbanPriority.MEDIUM, null, false, false),
                card("QCT-4674", "Contract PDF (first version)", KanbanIssueType.STORY,
                        "Contract PDF (first vers…", "chip-orange", KanbanPriority.MEDIUM, null, false, false),
                card("QCT-4659", "E-signing", KanbanIssueType.STORY,
                        "E-signing", "chip-orange", KanbanPriority.MEDIUM, null, false, false),
                card("QCT-4620", "Blocked Remove counterparty", KanbanIssueType.STORY,
                        null, null, KanbanPriority.MEDIUM, null, false, false)));

        var todo = new KanbanColumn("To Do", List.of(
                card("QCT-4243", "[Swifty] FE Change language and soft-delete contract…", KanbanIssueType.TASK,
                        "Update the UI/UX to th…", "chip-grey", KanbanPriority.HIGH, null, false, false),
                card("QCT-5112", "PDF Investigation", KanbanIssueType.STORY,
                        "PDF Investigation", "chip-blue", KanbanPriority.MEDIUM, VS, false, false),
                card("QCT-5238", "Sticky box with progress bar and buttons", KanbanIssueType.TASK,
                        "Update the UI/UX to th…", "chip-grey", KanbanPriority.MEDIUM, null, false, false)));

        var inProgress = new KanbanColumn("In Progress", true, List.of(
                card("QCT-5070", "E-signing investigation", KanbanIssueType.STORY,
                        "E-signing investigation", "chip-red", KanbanPriority.MEDIUM, GK, false, false),
                card("QCT-4690", "Update contract field section with new UI/UX", KanbanIssueType.TASK,
                        "Update the UI/UX to th…", "chip-grey", KanbanPriority.MEDIUM, UP, true, false),
                card("QCT-5162", "[BE] Deny contract details access when not authenticated …", KanbanIssueType.BUG,
                        null, null, KanbanPriority.HIGH, VS, true, false)));

        var inReview = new KanbanColumn("In Review", List.of(
                card("QCT-5164", "[FE] Hide Share CTA once contract has already been shared", KanbanIssueType.BUG,
                        null, null, KanbanPriority.MEDIUM, UP, true, false)));

        var inQa = new KanbanColumn("In QA", List.of());

        var done = new KanbanColumn("Done", List.of(
                card("QCT-4853", "Autosave changes to contract fields", KanbanIssueType.STORY,
                        "Autosave changes to c…", "chip-blue", KanbanPriority.HIGH, GK, true, false),
                card("QCT-4550", "[Swifty] Share Contract — Epic Overview", KanbanIssueType.EPIC,
                        "[Swifty] Share Contract …", "chip-purple", KanbanPriority.HIGH, VS, false, false),
                card("QCT-5055", "[BE] Enforce contract participant and initiator…", KanbanIssueType.TASK,
                        "[Swifty] Share Contract …", "chip-purple", KanbanPriority.MEDIUM, VS, true, true)));

        return new KanbanBoard("Digital Contracts",
                List.of(refinement, todo, inProgress, inReview, inQa, done));
    }

    private static KanbanCard card(String key, String title, KanbanIssueType type,
                                   String parentLabel, String parentColorClass,
                                   KanbanPriority priority, KanbanAssignee assignee,
                                   boolean hasDevelopment, boolean done) {
        return new KanbanCard(key, title, type, parentLabel, parentColorClass,
                priority, assignee, hasDevelopment, done);
    }
}
