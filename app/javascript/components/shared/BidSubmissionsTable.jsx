import React from "react";
import { Link } from "react-router-dom";

  const STATUS_BADGE_CLASSES = {
    "drafting"  : "status-badge status-drafting",
    "submitted" : "status-badge status-submitted",
    "awarded"   : "status-badge status-awarded",
    "lost"      : "status-badge status-lost",
    "withdrawn" : "status-badge status-archived",
    "declined"  : "status-badge status-archived"
  };

export default function BidSubmissionsTable({
  bids = [],
  displayProject = true,
  displayContractor = true,
  displayEstimator = true,
}) {

  const formatCurrency = (value) => {
    if (!value) return '-';
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(value);
  };

  return (
    <table className="table">
      <thead>
        <tr>
          {displayProject && <th>Project</th>}
          {displayContractor && <th>Contractor</th>}
          <th>Contact</th>
          <th>Status</th>
          <th>Bid Date</th>
          <th>Submitted Value</th>
          <th>Awarded Value</th>
          {displayEstimator && <th>Estimator</th>}
          <th></th>
        </tr>
        </thead>
        <tbody>
        {bids.map((bid) => (
          <tr key={bid.id}>
            {displayProject && <td>
              <Link to={`/projects/${bid.project_id}`} className="link">{bid.project_name}</Link>
            </td>}
            {displayContractor && <td>{bid.contractor_name}</td>}
            <td>{bid.contact_name}</td>
            <td><span className={STATUS_BADGE_CLASSES[bid.status]}>{bid.status}</span></td>
            <td>{new Date(bid.bid_due_at).toLocaleDateString()}</td>
            <td className="text-right">{formatCurrency(bid.submitted_value)}</td>
            <td className="text-right">{formatCurrency(bid.awarded_value)}</td>
            {displayEstimator && <td>{bid.estimators_name}</td>}
          </tr>
        ))}
        </tbody>
    </table>
  )
}
