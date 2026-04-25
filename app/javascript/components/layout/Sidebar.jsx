import React from "react";
import { Link, useLocation } from "react-router-dom";

export default function Sidebar({ currentUser }) {
  const { pathname: currentPath } = useLocation();
  const navigation = [
    {
      name: "Dashboard",
      href: "/dashboard",
      active: currentPath === "/dashboard" || currentPath === "/",
      icon: (
        <svg className="sidebar__icon" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z" />
        </svg>
      ),
    },
    {
      name: "Projects",
      href: "/projects",
      active: currentPath.startsWith("/projects"),
      icon: (
        <svg className="sidebar__icon" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" />
        </svg>
      ),
    },
    {
      name: "Contractors",
      href: "/contractors",
      active: currentPath.startsWith("/contractors"),
      icon: (
        <svg className="sidebar__icon" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z" />
        </svg>
      ),
    },
  ];

  // Add admin link if user is admin
  if (currentUser?.role === "admin") {
    navigation.push({
      name: "Users",
      href: "/users",
      active: currentPath.startsWith("/users"),
      icon: (
        <svg className="sidebar__icon" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-6-3a2 2 0 11-4 0 2 2 0 014 0zm-2 4a5 5 0 00-4.546 2.916A5.986 5.986 0 0010 16a5.986 5.986 0 004.546-2.084A5 5 0 0010 11z" clipRule="evenodd" />
        </svg>
      ),
    });
  }

  const handleSignOut = (e) => {
    e.preventDefault();
    // Rails-style form submission for sign out
    const form = document.createElement("form");
    form.method = "POST";
    form.action = "/users/sign_out";

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    if (csrfToken) {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = "authenticity_token";
      input.value = csrfToken;
      form.appendChild(input);
    }

    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = "delete";
    form.appendChild(methodInput);

    document.body.appendChild(form);
    form.submit();
  };

  return (
    <nav className="sidebar" aria-label="Main navigation">
      <div className="sidebar__brand">
        <span className="sidebar__brand-name">Batray</span>
      </div>

      <ul className="sidebar__nav" role="list">
        {navigation.map((item) => (
          <li key={item.name}>
            <Link
              to={item.href}
              className={`sidebar__nav-item ${item.active ? "sidebar__nav-item--active" : ""}`}
            >
              {item.icon}
              {item.name}
            </Link>
          </li>
        ))}
      </ul>

      <div className="sidebar__footer">
        <div className="sidebar__user-info">
          <span className="sidebar__user-name">{currentUser?.name || "User"}</span>
          <span className="sidebar__user-role">{currentUser?.role ? currentUser.role.charAt(0).toUpperCase() + currentUser.role.slice(1) : "User"}</span>
        </div>
        <button onClick={handleSignOut} className="btn btn--ghost btn--sm">
          Sign out
        </button>
      </div>
    </nav>
  );
}