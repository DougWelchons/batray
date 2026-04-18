import React, { useState, useRef, useEffect } from "react";

export default function SearchableDropDown({
  items = [],
  searchableColumns = [],
  onChange,
  value,
  label,
  placeholder = "Select...",
  displayFn,
  required = false,
  disabled = false,
  showLabel = true
}) {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [highlighted, setHighlighted] = useState(0);
  const containerRef = useRef(null);
  const searchRef = useRef(null);
  const listRef = useRef(null);

  const getDisplayLabel = (item) => {
    if (!item) return "";
    if (displayFn) return displayFn(item);
    return searchableColumns
      .map((col) => item[col])
      .filter(Boolean)
      .join(" ");
  };

  const filtered =
    query.trim() === ""
      ? items
      : items.filter((item) =>
          searchableColumns.some((col) => {
            const val = item[col];
            return val && String(val).toLowerCase().includes(query.toLowerCase());
          })
        );

  // Close on outside click
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

  // Focus search input when panel opens
  useEffect(() => {
    if (open) {
      searchRef.current?.focus();
      setHighlighted(0);
    }
  }, [open]);

  // Scroll highlighted item into view
  useEffect(() => {
    if (!listRef.current) return;
    const item = listRef.current.children[highlighted];
    item?.scrollIntoView({ block: "nearest" });
  }, [highlighted]);

  const handleSelect = (item) => {
    onChange?.(item);
    setOpen(false);
    setQuery("");
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
      if (filtered[highlighted]) handleSelect(filtered[highlighted]);
    } else if (e.key === "Escape") {
      setOpen(false);
      setQuery("");
    }
  };

  const selectedLabel = getDisplayLabel(value);

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
          className="searchable-dropdown__trigger"
          onClick={() => !disabled && setOpen((o) => !o)}
          onKeyDown={disabled ? undefined : handleTriggerKeyDown}
          aria-haspopup="listbox"
          aria-expanded={open}
          disabled={disabled}
        >
          <span
            className={
              selectedLabel
                ? "searchable-dropdown__selected-label"
                : "searchable-dropdown__placeholder"
            }
          >
            {selectedLabel || placeholder}
          </span>
          <svg
            className="searchable-dropdown__chevron"
            style={{ transform: open ? "rotate(180deg)" : "rotate(0deg)" }}
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
            width="16"
            height="16"
            aria-hidden="true"
          >
            <path
              fillRule="evenodd"
              d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
              clipRule="evenodd"
            />
          </svg>
        </button>

        {open && (
          <div className="searchable-dropdown__panel" role="listbox">
            <div className="searchable-dropdown__search-wrap">
              <input
                ref={searchRef}
                className="searchable-dropdown__search"
                type="text"
                placeholder="Search..."
                value={query}
                onChange={(e) => {
                  setQuery(e.target.value);
                  setHighlighted(0);
                }}
                onKeyDown={handleSearchKeyDown}
                autoComplete="off"
              />
            </div>

            <ul className="searchable-dropdown__list" ref={listRef} role="listbox">
              {filtered.length === 0 ? (
                <li className="searchable-dropdown__empty">No results</li>
              ) : (
                filtered.map((item, i) => (
                  <li
                    key={i}
                    className={[
                      "searchable-dropdown__item",
                      i === highlighted ? "searchable-dropdown__item--highlighted" : "",
                      value === item ? "searchable-dropdown__item--selected" : "",
                    ]
                      .filter(Boolean)
                      .join(" ")}
                    onMouseEnter={() => setHighlighted(i)}
                    onMouseDown={(e) => {
                      e.preventDefault();
                      handleSelect(item);
                    }}
                    role="option"
                    aria-selected={value === item}
                  >
                    {getDisplayLabel(item)}
                  </li>
                ))
              )}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
}
