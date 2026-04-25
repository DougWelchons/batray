import React from "react";

/**
 * FormField — labeled form control wrapping .form__field classes.
 *
 * type:      'text' | 'email' | 'tel' | 'number' | 'date' | 'textarea' |
 *            'select' | 'checkbox' (default: 'text')
 * label:     string — field label text
 * name:      string — input name/id (falls back to slugified label)
 * value:     string | bool — controlled value
 * onChange:  function — change handler
 * required:  bool
 * showLabel: bool (default true)
 * options:   array of { value, label } — required when type='select'
 * placeholder: string
 * rows:      number — for textarea (default 3)
 * small:     bool — renders input/select at --sm size
 * children:  node — rendered instead of a built-in input (escape hatch)
 *
 * Examples:
 *   <FormField label="Project Name" name="project_name" value={name} onChange={e => setName(e.target.value)} />
 *   <FormField type="select" label="Status" name="status" value={status} onChange={...} options={STATUS_OPTIONS} />
 *   <FormField type="checkbox" label="Include Fire Alarm" name="included_fire_alarm" value={fa} onChange={...} />
 */
export default function FormField({
  type = "text",
  label,
  name,
  value,
  onChange,
  required = false,
  showLabel = true,
  options = [],
  placeholder,
  rows = 3,
  small = false,
  className = "",
  children,
}) {
  const id = name || (label ? label.toLowerCase().replace(/\s+/g, "_") : undefined);

  if (type === "checkbox") {
    return (
      <div className={`form__field form__field--checkbox-group ${className}`}>
        <input
          type="checkbox"
          className="form__checkbox"
          id={id}
          name={name}
          checked={!!value}
          onChange={onChange}
        />
        {showLabel && (
          <label className="form__checkbox-label" htmlFor={id}>
            {label}
          </label>
        )}
      </div>
    );
  }

  return (
    <div className={`form__field ${className}`}>
      {showLabel && label && (
        <label className="form__label" htmlFor={id}>
          {label}
        </label>
      )}

      {children ? (
        children
      ) : type === "textarea" ? (
        <textarea
          className="form__textarea"
          id={id}
          name={name}
          value={value ?? ""}
          onChange={onChange}
          required={required}
          placeholder={placeholder}
          rows={rows}
        />
      ) : type === "select" ? (
        <select
          className={`form__select${small ? " form__select--sm" : ""}`}
          id={id}
          name={name}
          value={value ?? ""}
          onChange={onChange}
          required={required}
        >
          {placeholder && <option value="">{placeholder}</option>}
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
      ) : (
        <input
          className={`form__input${small ? " form__input--sm" : ""}`}
          type={type}
          id={id}
          name={name}
          value={type === "date" && value ? value.split("T")[0] : (value ?? "")}
          onChange={onChange}
          required={required}
          placeholder={placeholder}
        />
      )}
    </div>
  );
}
