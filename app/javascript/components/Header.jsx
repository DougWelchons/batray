import React from "react";

export default function Header({ title, actions }) {
  return (
    <header className="top-header">
      <div className="top-header__title">
        <h1 className="page-title">{title}</h1>
      </div>
      <div className="top-header__actions">
        {actions}
      </div>
    </header>
  )
}