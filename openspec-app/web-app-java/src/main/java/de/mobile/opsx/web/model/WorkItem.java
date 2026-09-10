package de.mobile.opsx.web.model;

public record WorkItem(
        String id,
        String status,
        String moduleId,
        String branch,
        String commit) {
}
