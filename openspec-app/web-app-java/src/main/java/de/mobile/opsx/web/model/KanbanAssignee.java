package de.mobile.opsx.web.model;

/**
 * Card assignee shown as a coloured avatar. {@code colorClass} keys the avatar
 * background in the template (e.g. {@code avatar-red}). A {@code null} assignee
 * renders the unassigned placeholder.
 */
public record KanbanAssignee(String initials, String colorClass) {
}
