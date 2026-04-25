import React from "react";

/**
 * MetaList / MetaItem — key/value detail display used on show pages.
 *
 * MetaList wraps a row of MetaItems.
 * MetaItem renders a labeled value (dt/dd pair).
 *
 * MetaItem props:
 *   label:    string — the field label (renders as <dt>)
 *   children: node   — the value(s) (renders as one or more <dd>)
 *
 * Example:
 *   <MetaList>
 *     <MetaItem label="Location">{project.city}, {project.state}</MetaItem>
 *     <MetaItem label="Project Type">{project.type}</MetaItem>
 *     <MetaItem label="Estimated Start">{formatDate(project.estimated_start_date)}</MetaItem>
 *   </MetaList>
 *
 * For multi-line values, pass an array or fragment — each child becomes its own <dd>:
 *   <MetaItem label="Address">
 *     <span>{project.street}</span>
 *     <span>{project.city} {project.state} {project.zip_code}</span>
 *   </MetaItem>
 */
export function MetaItem({ label, children }) {
  const values = Array.isArray(children) ? children : [children];

  return (
    <div className="meta-item">
      <dt>{label}</dt>
      {values.map((val, i) => (
        <dd key={i}>{val}</dd>
      ))}
    </div>
  );
}

export function MetaList({ children, className = "" }) {
  return (
    <dl className={`meta-list ${className}`}>
      {children}
    </dl>
  );
}
