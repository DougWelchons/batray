import React, { useState, useRef, useEffect } from "react";

/**
 * MultiSelectDropDown — multi-select dropdown with live search and chip display.
 *
 * items:             array of objects (or primitives)
 * searchableColumns: array of string keys to search/display (e.g. ["name"])
 * displayFn:         optional (item) => string — overrides searchableColumns for display
 * value:             array of currently selected items (default [])
 * onChange:          (items[]) => void — called with full updated selection array
 * label:             string
 * placeholder:       string (default "Select...")
 * required:          bool
 * disabled:          bool
 * showLabel:         bool (default true)
 *
 * Example:
 *   <MultiSelectDropDown
 *     label="Classifications"
 *     items={classifications}
 *     searchableColumns={["name"]}
 *     value={selectedClassifications}
 *     onChange={vals => setSelectedClassifications(vals)}
 *   />
 */
export default function MultiSelectDropDown({
  items = [],
  onChange,
  value = [],
  label,
  placeholder = "Select...",
  displayFn,
  searchableColumns = [],
  required = false,
  disabled = false,
  showLabel = true,
}) {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [highlighted, setHighlighted] = useState(0);
  const containerRef = useRef(null);
  const searchRef = useRef(null);
  const listRef = useRef(null);

  const selected = Array.isArray(value) ? value : [];

  const getLabel = (item) => {
    if (displayFn) return displayFn(item);
    if (searchableColumns.length > 0)
      return searchableColumns.map((col) => item[col]).filter(Boolean).join(" ");
    return String(item);
  };

  const getId = (item) => (item && typeof item === "object" ? item.id : item);

  const isSelected = (item) => selected.some((s) => getId(s) === getId(item));

  const filtered =
    query.trim() === ""
      ? items
      : items.filter((item) => getLabel(item).toLowerCase().includes(query.toLowerCase()));

  useEffect(() => {
    const handler = (e) => {
      if (containerRef.current && !containerRef.current.contains(e.target)) {
        setOpen(false);
        setQuery("");
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  useEffect(() => {
    if (open) {
      searchRef.current?.focus();
      setHighlighted(0);
    }
  }, [open]);

  useEffect(() => {
    if (!listRef.current) return;
    listRef.current.children[highlighted]?.scrollIntoView({ block: "nearest" });
  }, [highlighted]);

  const toggle = (item) => {
    const next = isSelected(item)
      ? selected.filter((s) => getId(s) !== getId(item))
      : [...selected, item];
    onChange?.(next);
  };

  const remove = (item, e) => {
    e.stopPropagation();
    onChange?.(selected.filter((s) => getId(s) !== getId(item)));
  };

  const handleTriggerKeyDown = (e) => {
    if (e.key === "Enter" || e.key === " " || e.key === "ArrowDown") {
      e.preventDefault();
      setOpen(true);
    }
  };

  const handleSearchKeyDown = (e) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setHighlighted((h) => Math.min(h + 1, filtered.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setHighlighted((h) => Math.max(h - 1, 0));
    } else if (e.key === "Enter") {
      e.preventDefault();
      if (filtered[highlighted]) toggle(filtered[highlighted]);
    } else if (e.key === "Escape") {
      setOpen(false);
      setQuery("");
    }
  };

  return (
    <div className="form__field" ref={containerRef}>
      {showLabel && label && (
        <label className="form__label">
          {label}
          {required && <span style={{ color: "var(--status-lost)", marginLeft: 2 }}>*</span>}
        </label>
      )}

      <div className="searchable-dropdown">
        <button
          type="button"
          className="searchable-dropdown__trigger multiselect-trigger"
          onClick={() => !disabled && setOpen((o) => !o)}
          onKeyDown={disabled ? undefined : handleTriggerKeyDown}
          aria-haspopup="listbox"
          aria-expanded={open}
          disabled={disabled}
        >
          {selected.length === 0 ? (
            <span className="searchable-dropdown__placeholder">{placeholder}</span>
          ) : (
            <span className="multiselect-chips">
              {selected.map((item) => (
                <span key={getId(item)} className="multiselect-chip">
                  {getLabel(item)}
                  <span
                    role="button"
                    aria-label={`Remove ${getLabel(item)}`}
                    className="multiselect-chip__remove"
                    onMouseDown={(e) => remove(item, e)}
                  >
                    ×
                  </span>
                </span>
              ))}
            </span>
          )}
          <svg
            className="searchable-dropdown__chevron"
            style={{ transform: open ? "rotate(180deg)" : "rotate(0deg)", flexShrink: 0 }}
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
            width="16"
            height="16"
            aria-hidden="true"
          >
            <path fillRule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
          </svg>
        </button>

        {open && (
          <div className="searchable-dropdown__panel" role="listbox" aria-multiselectable="true">
            <div className="searchable-dropdown__search-wrap">
              <input
                ref={searchRef}
                className="searchable-dropdown__search"
                type="text"
                placeholder="Search..."
                value={query}
                onChange={(e) => { setQuery(e.target.value); setHighlighted(0); }}
                onKeyDown={handleSearchKeyDown}
                autoComplete="off"
              />
            </div>
            <ul className="searchable-dropdown__list" ref={listRef} role="listbox">
              {filtered.length === 0 ? (
                <li className="searchable-dropdown__empty">No results</li>
              ) : (
                filtered.map((item, i) => {
                  const sel = isSelected(item);
                  return (
                    <li
                      key={getId(item) ?? i}
                      className={[
                        "searchable-dropdown__item",
                        i === highlighted ? "searchable-dropdown__item--highlighted" : "",
                        sel ? "searchable-dropdown__item--selected" : "",
                      ].filter(Boolean).join(" ")}
                      onMouseEnter={() => setHighlighted(i)}
                      onMouseDown={(e) => { e.preventDefault(); toggle(item); }}
                      role="option"
                      aria-selected={sel}
                    >
                      <span>{getLabel(item)}</span>
                      {sel && (
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" width="14" height="14" aria-hidden="true">
                          <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                        </svg>
                      )}
                    </li>
                  );
                })
              )}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
}
