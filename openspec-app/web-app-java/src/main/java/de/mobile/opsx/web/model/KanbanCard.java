package de.mobile.opsx.web.model;

/**
 * One board card. {@code parentLabel}/{@code parentColorClass} render the Jira
 * parent-link chip (nullable). {@code assignee} is nullable (unassigned).
 * {@code hasDevelopment} shows the branch/PR indicator; {@code done} strikes the
 * key through as in a completed Done-column card.
 */
public record KanbanCard(
        String key,
        String title,
        KanbanIssueType type,
        String parentLabel,
        String parentColorClass,
        KanbanPriority priority,
        KanbanAssignee assignee,
        boolean hasDevelopment,
        boolean done) {

    /** Convenience builder for the common case (no parent chip, no dev flag). */
    public static KanbanCard of(String key, String title, KanbanIssueType type,
                                KanbanPriority priority, KanbanAssignee assignee) {
        return new KanbanCard(key, title, type, null, null, priority, assignee, false, false);
    }
}
