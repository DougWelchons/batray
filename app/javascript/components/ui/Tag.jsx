import React from "react";

/**
 * Tag — small inline accent pill for categorization labels.
 *
 * Uses the accent color (indigo) by default.
 * For status indicators use StatusBadge instead.
 *
 * children: string | node — tag text
 * onRemove: function — if provided, renders an × button (makes tag dismissible)
 *
 * Examples:
 *   <Tag>Fire Alarm</Tag>
 *   <Tag>Low Voltage</Tag>
 *
 *   // Dismissible
 *   <Tag onRemove={() => removeClassification(id)}>Commercial</Tag>
 *
 *   // Inline next to a heading
 *   <h2>Project Name <Tag>Rebid</Tag></h2>
 */
export default function Tag({ children, onRemove, className = "" }) {
  return (
    <span className={`tag ${className}`}>
      {children}
      {onRemove && (
        <button
          type="button"
          className="tag__remove"
          onClick={onRemove}
          aria-label="Remove"
        >
          ×
        </button>
      )}
    </span>
  );
}
