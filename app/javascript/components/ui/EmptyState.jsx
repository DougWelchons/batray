import React from "react";

/**
 * EmptyState — centered empty-state block inside a card or table.
 *
 * message: string — primary message text
 * action:  node   — optional call-to-action (Button or Link)
 *
 * Example:
 *   <EmptyState
 *     message="No contractors yet."
 *     action={<Button as="link" to="/contractors/new">Add Contractor</Button>}
 *   />
 */
export default function EmptyState({ message, action }) {
  return (
    <div className="empty-state">
      <p>{message}</p>
      {action}
    </div>
  );
}
