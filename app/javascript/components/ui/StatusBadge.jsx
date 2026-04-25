import React from "react";

const STATUS_CLASS = {
  drafting:  "status-drafting",
  submitted: "status-submitted",
  awarded:   "status-awarded",
  lost:      "status-lost",
  withdrawn: "status-archived",
  declined:  "status-archived",
};

const STATUS_LABEL = {
  drafting:  "Drafting",
  submitted: "Submitted",
  awarded:   "Awarded",
  lost:      "Lost",
  withdrawn: "Withdrawn",
  declined:  "Declined",
};

/**
 * StatusBadge — renders a pill badge for BidSubmission status.
 *
 * status: 'drafting' | 'submitted' | 'awarded' | 'lost' | 'withdrawn' | 'declined'
 * label:  optional override for display text
 */
export default function StatusBadge({ status, label }) {
  const statusClass = STATUS_CLASS[status] ?? "status-archived";
  const displayLabel = label ?? STATUS_LABEL[status] ?? status;

  return (
    <span className={`status-badge ${statusClass}`}>
      {displayLabel}
    </span>
  );
}
