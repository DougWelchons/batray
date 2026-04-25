import React from "react";

/**
 * PageHeader — sticky top header bar (.top-header).
 *
 * title:   string — page title displayed in .page-title
 * actions: node   — right-aligned content (buttons, links, etc.)
 *
 * Example:
 *   <PageHeader
 *     title="Projects"
 *     actions={<Button as="link" to="/projects/new">New Project</Button>}
 *   />
 */
export default function PageHeader({ title, actions }) {
  return (
    <header className="top-header">
      <div className="top-header__title">
        <h1 className="page-title">{title}</h1>
      </div>
      {actions && (
        <div className="top-header__actions">{actions}</div>
      )}
    </header>
  );
}
