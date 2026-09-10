package de.mobile.opsx.web.model;

/**
 * Jira-style priority. {@code cssClass} colours the chevron glyph in the template.
 */
public enum KanbanPriority {
    HIGHEST("Highest", "prio-highest", "⌃⌃"),
    HIGH("High", "prio-high", "⌃⌃"),
    MEDIUM("Medium", "prio-medium", "⌃"),
    LOW("Low", "prio-low", "⌄"),
    LOWEST("Lowest", "prio-lowest", "⌄⌄");

    private final String label;
    private final String cssClass;
    private final String glyph;

    KanbanPriority(String label, String cssClass, String glyph) {
        this.label = label;
        this.cssClass = cssClass;
        this.glyph = glyph;
    }

    public String label() {
        return label;
    }

    public String cssClass() {
        return cssClass;
    }

    public String glyph() {
        return glyph;
    }
}
