import React from "react";
import InfoTooltip from "./InfoTooltip";

/**
 * StatCard — dashboard summary metric card.
 *
 * label: string — short uppercase label (e.g. "Win Rate")
 * value: string | number — the displayed metric
 * sub:   string — optional small line below value (e.g. "vs 62% last year")
 * info:  string — optional explanation shown via (i) hover tooltip
 *
 * Use inside a .stats-grid container.
 */
export default function StatCard({ label, value, sub, info }) {
  return (
    <div className="stat-card">
      <div className="stat-card__header">
        <div className="stat-card__label">{label}</div>
        {info && <InfoTooltip text={info} />}
      </div>
      <div className="stat-card__value">{value}</div>
      {sub && <div className="stat-card__sub">{sub}</div>}
    </div>
  );
}
