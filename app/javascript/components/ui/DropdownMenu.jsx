import React, { useState, useRef, useEffect } from "react";
import { Link } from "react-router-dom";
import Button from "./Button";

/**
 * DropdownMenu — action/context menu triggered by a button.
 *
 * trigger:        string | ReactNode — button label (default "Options")
 * triggerVariant: Button variant ('primary' | 'secondary' | 'ghost' | 'danger') — default 'secondary'
 * triggerSize:    Button size ('sm' | 'md') — default undefined
 * align:          'left' | 'right' — panel alignment relative to trigger — default 'left'
 * direction:      'down' | 'right' — which direction the panel opens — default 'down'
 * items:          array of item objects:
 *   { label, onClick, to, href, variant, disabled, divider, header }
 *   - divider: true      → renders a separator line (ignores other props)
 *   - header: true       → renders a non-interactive label (use `variant: 'name'|'role'` for styling)
 *   - to: string         → react-router Link
 *   - href: string       → plain <a>
 *   - onClick: fn        → button action
 *   - variant: 'danger'  → red label color
 *   - disabled: bool
 *
 * Example:
 *   <DropdownMenu
 *     trigger="Actions"
 *     align="right"
 *     direction="down"
 *     items={[
 *       { label: "Edit", to: `/projects/${id}/edit` },
 *       { label: "Duplicate", onClick: handleDuplicate },
 *       { divider: true },
 *       { label: "Delete", onClick: handleDelete, variant: "danger" },
 *     ]}
 *   />
 */
export default function DropdownMenu({
  trigger = "Options",
  triggerVariant = "secondary",
  triggerSize,
  align = "left",
  direction = "down",
  items = [],
}) {
  const [open, setOpen] = useState(false);
  const [highlighted, setHighlighted] = useState(-1);
  const containerRef = useRef(null);
  const panelRef = useRef(null);

  // All interactive items — used for keyboard nav index alignment with actionIndex counter
  const actionItems = items.filter((item) => !item.divider && !item.header);

  // Close on outside click
  useEffect(() => {
    const handler = (e) => {
      if (containerRef.current && !containerRef.current.contains(e.target)) {
        setOpen(false);
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  // Focus first item on open
  useEffect(() => {
    if (open) {
      setHighlighted(-1);
    }
  }, [open]);

  const close = () => setOpen(false);

  const handleTriggerKeyDown = (e) => {
    if (e.key === "Enter" || e.key === " " || e.key === "ArrowDown") {
      e.preventDefault();
      setOpen(true);
      setHighlighted(0);
    } else if (e.key === "Escape") {
      close();
    }
  };

  const handlePanelKeyDown = (e) => {
    if (e.key === "Escape") {
      close();
      containerRef.current?.querySelector("button")?.focus();
      return;
    }
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setHighlighted((h) => Math.min(h + 1, actionItems.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setHighlighted((h) => Math.max(h - 1, 0));
    } else if (e.key === "Enter") {
      e.preventDefault();
      const item = actionItems[highlighted];
      if (item && !item.disabled) {
        item.onClick?.();
        close();
      }
    }
  };

  const handleItemClick = (item) => {
    if (item.disabled) return;
    item.onClick?.();
    close();
  };

  let actionIndex = -1;

  return (
    <div className="dropdown-menu" ref={containerRef}>
      <Button
        variant={triggerVariant}
        size={triggerSize}
        onClick={() => setOpen((o) => !o)}
        onKeyDown={handleTriggerKeyDown}
        aria-haspopup="menu"
        aria-expanded={open}
        type="button"
      >
        {trigger}
      </Button>

      {open && (
        <div
          className={[
            "dropdown-menu__panel",
            direction === "right" ? "dropdown-menu__panel--direction-right" : `dropdown-menu__panel--${align}`,
          ].join(" ")}
          role="menu"
          ref={panelRef}
          onKeyDown={handlePanelKeyDown}
        >
          {items.map((item, i) => {
            if (item.divider) {
              return <div key={i} className="dropdown-menu__divider" role="separator" />;
            }

            if (item.header) {
              return (
                <div
                  key={i}
                  className={`dropdown-menu__header${item.variant ? ` dropdown-menu__header--${item.variant}` : ""}`}
                  role="presentation"
                >
                  {item.label}
                </div>
              );
            }

            actionIndex += 1;
            const thisIndex = actionIndex;
            const isHighlighted = highlighted === thisIndex;
            const itemClass = [
              "dropdown-menu__item",
              item.variant === "danger" ? "dropdown-menu__item--danger" : "",
              item.disabled ? "dropdown-menu__item--disabled" : "",
              isHighlighted ? "dropdown-menu__item--highlighted" : "",
            ]
              .filter(Boolean)
              .join(" ");

            if (item.to) {
              return (
                <Link
                  key={i}
                  to={item.to}
                  className={itemClass}
                  role="menuitem"
                  onClick={close}
                  tabIndex={-1}
                >
                  {item.label}
                </Link>
              );
            }

            if (item.href) {
              return (
                <a
                  key={i}
                  href={item.href}
                  className={itemClass}
                  role="menuitem"
                  onClick={close}
                  tabIndex={-1}
                >
                  {item.label}
                </a>
              );
            }

            return (
              <button
                key={i}
                type="button"
                className={itemClass}
                role="menuitem"
                disabled={item.disabled}
                onMouseDown={(e) => { e.preventDefault(); handleItemClick(item); }}
                onMouseEnter={() => setHighlighted(thisIndex)}
                tabIndex={-1}
              >
                {item.label}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
