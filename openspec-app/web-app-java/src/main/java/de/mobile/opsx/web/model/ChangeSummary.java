package de.mobile.opsx.web.model;

import java.util.List;

public record ChangeSummary(
        String id,
        /** {@code .openspec.yaml} status (proposed/…). */
        String status,
        /** {@code approval.yaml} status (approved/pending/unknown). */
        String approval,
        String title,
        List<WorkItem> workItems,
        /** Paths relative to {@code context/evidence/}. */
        List<String> evidence,
        /** True when the change lives under {@code changes/archive/}. */
        boolean archived) {

    public boolean approved() {
        return "approved".equals(approval);
    }
}
