import React from "react";
import { Link } from "react-router-dom";

/**
 * Button — wraps .btn CSS classes.
 *
 * variant: 'primary' | 'secondary' | 'ghost' | 'danger'
 * size:    'sm' | 'md' (default)
 * as:      'button' (default) | 'a' | 'link' (react-router Link)
 *
 * All other props (onClick, href, to, type, disabled, etc.) pass through.
 */
export default function Button({
  variant = "primary",
  size,
  as = "button",
  className = "",
  children,
  ...props
}) {
  const classes = [
    "btn",
    `btn--${variant}`,
    size === "sm" ? "btn--sm" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");

  if (as === "link") {
    return (
      <Link className={classes} {...props}>
        {children}
      </Link>
    );
  }

  if (as === "a") {
    return (
      <a className={classes} {...props}>
        {children}
      </a>
    );
  }

  return (
    <button className={classes} {...props}>
      {children}
    </button>
  );
}
