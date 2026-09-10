package de.mobile.opsx.web.model;

import java.util.List;

/**
 * A Jira-style board: a named group of columns. {@code workItemCount} is the
 * total shown next to the board name; it defaults to the sum of all card counts.
 */
public record KanbanBoard(String name, int workItemCount, List<KanbanColumn> columns) {

    public KanbanBoard(String name, List<KanbanColumn> columns) {
        this(name, columns.stream().mapToInt(c -> c.cards().size()).sum(), columns);
    }
}
