import React from "react";
import ReactDOM from "react-dom";
import { Link, useLocation } from "react-router-dom";

export default function Sidebar({ currentUser }) {
  const { pathname: currentPath } = useLocation();
  const [open, setOpen] = React.useState(true);
  const [userMenuOpen, setUserMenuOpen] = React.useState(false);
  const [userMenuPos, setUserMenuPos] = React.useState({ top: 0, left: 0 });
  const userMenuButtonRef = React.useRef(null);
  const userMenuPanelRef = React.useRef(null);

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

  const signOut = () => {
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

  const userRole = currentUser?.role
    ? currentUser.role.charAt(0).toUpperCase() + currentUser.role.slice(1)
    : "User";

  const openUserMenu = () => {
    if (userMenuButtonRef.current) {
      const rect = userMenuButtonRef.current.getBoundingClientRect();
      setUserMenuPos({
        bottom: window.innerHeight - rect.bottom,
        left: rect.right + 8,
      });
    }
    setUserMenuOpen((o) => !o);
  };

  // Close user menu on outside click
  React.useEffect(() => {
    if (!userMenuOpen) return;
    const handler = (e) => {
      if (
        !userMenuButtonRef.current?.contains(e.target) &&
        !userMenuPanelRef.current?.contains(e.target)
      ) {
        setUserMenuOpen(false);
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [userMenuOpen]);

  // Close user menu when sidebar expands
  React.useEffect(() => {
    if (open) setUserMenuOpen(false);
  }, [open]);

  // Keep app-main margin in sync with sidebar state
  React.useEffect(() => {
    const main = document.querySelector(".app-main");
    if (main) main.classList.toggle("app-main--sidebar-closed", !open);
  }, [open]);

  return (
    <nav className={`sidebar ${open ? "" : "sidebar--closed"}`} aria-label="Main navigation">
      <div className="sidebar__brand">
        {open && <span className="sidebar__brand-name">Batray</span>}
        <button
          className="sidebar__toggle"
          onClick={() => setOpen(!open)}
          aria-label={open ? "Collapse sidebar" : "Expand sidebar"}
          type="button"
        >
          <svg viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
            <path fillRule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clipRule="evenodd" />
          </svg>
        </button>
      </div>

      <ul className="sidebar__nav" role="list">
        {navigation.map((item) => (
          <li key={item.name}>
            <Link
              to={item.href}
              className={`sidebar__nav-item ${item.active ? "sidebar__nav-item--active" : ""}`}
            >
              {item.icon}
              {open && item.name}
            </Link>
          </li>
        ))}
      </ul>

      {open ? (
        <div className="sidebar__footer">
          <div className="sidebar__user-info">
            <span className="sidebar__user-name">{currentUser?.name || "User"}</span>
            <span className="sidebar__user-role">{userRole}</span>
          </div>
          <button onClick={signOut} className="btn btn--ghost btn--sm">
            Sign out
          </button>
        </div>
      ) : (
        <div className="sidebar__footer">
          <button
            ref={userMenuButtonRef}
            className="sidebar__user-button"
            onClick={openUserMenu}
            type="button"
            aria-label="User menu"
            aria-expanded={userMenuOpen}
          >
            <svg className="sidebar__icon" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
            </svg>
          </button>

          {userMenuOpen && ReactDOM.createPortal(
            <div
              ref={userMenuPanelRef}
              className="sidebar-user-popup"
              style={{ bottom: userMenuPos.bottom, left: userMenuPos.left }}
            >
              <div className="dropdown-menu__header dropdown-menu__header--name">
                {currentUser?.name || "User"}
              </div>
              <div className="dropdown-menu__header dropdown-menu__header--role">
                {userRole}
              </div>
              <div className="dropdown-menu__divider" role="separator" />
              <button
                type="button"
                className="dropdown-menu__item"
                onMouseDown={() => { setUserMenuOpen(false); signOut(); }}
              >
                Sign out
              </button>
            </div>,
            document.body
          )}
        </div>
      )}
    </nav>
  );
}
