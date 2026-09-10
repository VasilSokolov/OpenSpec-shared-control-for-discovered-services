package de.mobile.opsx.web.model;

import java.util.List;

/**
 * A board column. {@code accent} highlights the header (e.g. the active
 * In Progress lane). {@code cards} is mutable-free; the template reads
 * {@code cards().size()} for the count badge.
 */
public record KanbanColumn(String name, boolean accent, List<KanbanCard> cards) {

    public KanbanColumn(String name, List<KanbanCard> cards) {
        this(name, false, cards);
    }
}
