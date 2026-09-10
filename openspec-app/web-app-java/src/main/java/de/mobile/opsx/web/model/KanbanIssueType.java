package de.mobile.opsx.web.model;

/**
 * Jira-style issue type. {@code cssClass} keys the coloured type icon in the
 * template; {@code glyph} is the character rendered inside it.
 */
public enum KanbanIssueType {
    EPIC("Epic", "type-epic", "⚡"),
    STORY("Story", "type-story", "⚡"),
    TASK("Task", "type-task", "+"),
    SUBTASK("Sub-task", "type-subtask", "⚇"),
    BUG("Bug", "type-bug", "●");

    private final String label;
    private final String cssClass;
    private final String glyph;

    KanbanIssueType(String label, String cssClass, String glyph) {
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
