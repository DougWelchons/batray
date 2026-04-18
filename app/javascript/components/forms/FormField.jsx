import React from "react";

export default function FormField({ label, name, value, onChange, type = "text", required = false, showLabel = true }) {
  const displayValue = type === "date" && value ? value.split("T")[0] : value;

  return (
    <div className="form__field">
      {showLabel && <label className="form__label">{label}</label>}
      <input
        className="form__input"
        type={type}
        id={name || label.toLowerCase().replace(/\s+/g, "_")}
        name={name || label.toLowerCase().replace(/\s+/g, "_")}
        value={displayValue}
        onChange={onChange}
        required={required}
      />
    </div>
  );
}
