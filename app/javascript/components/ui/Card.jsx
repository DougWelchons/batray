import React, { useState } from "react";

/**
 * Card — wraps .card with optional title and header actions.
 *
 * title:       string — renders .card__title
 * actions:     node  — renders right-aligned in the card header (buttons, links)
 * collapsible: bool  — makes the card collapsible, default open
 * defaultOpen: bool  — initial open state when collapsible (default true)
 * noPadding:   bool  — removes card padding (for cards that contain a full-bleed table)
 */
export default function Card({
  title,
  actions,
  collapsible = false,
  defaultOpen = true,
  noPadding = false,
  className = "",
  children,
}) {
  const [isOpen, setIsOpen] = useState(defaultOpen);

  const hasHeader = title || actions;

  return (
    <div className={`card ${noPadding ? "card--no-padding" : ""} ${className}`}>
      {hasHeader && (
        <div className="card__header">
          {title && (
            <h2
              className="card__title"
              onClick={collapsible ? () => setIsOpen((o) => !o) : undefined}
              style={collapsible ? { cursor: "pointer", userSelect: "none" } : undefined}
            >
              {collapsible && (
                <span
                  style={{
                    display: "inline-block",
                    marginRight: "8px",
                    transition: "transform 0.15s",
                    transform: isOpen ? "rotate(90deg)" : "rotate(0deg)",
                  }}
                >
                  ▶
                </span>
              )}
              {title}
            </h2>
          )}
          {actions && <div className="card__actions">{actions}</div>}
        </div>
      )}
      {(!collapsible || isOpen) && children}
    </div>
  );
}
