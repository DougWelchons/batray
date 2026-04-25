import React from "react";
import { Link } from "react-router-dom";
import { Table, StatusBadge } from "../ui";

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
    <Table>
      <Table.Head>
        <Table.Row>
          {displayProject && <Table.Th>Project</Table.Th>}
          {displayContractor && <Table.Th>Contractor</Table.Th>}
          <Table.Th>Contact</Table.Th>
          <Table.Th>Status</Table.Th>
          <Table.Th>Bid Date</Table.Th>
          <Table.Th right>Submitted Value</Table.Th>
          <Table.Th right>Awarded Value</Table.Th>
          {displayEstimator && <Table.Th>Estimator</Table.Th>}
          <Table.Th />
        </Table.Row>
      </Table.Head>
      <Table.Body>
        {bids.map((bid) => (
          <Table.Row key={bid.id}>
            {displayProject && (
              <Table.Td>
                <Link to={`/projects/${bid.project_id}`} className="link">{bid.project_name}</Link>
              </Table.Td>
            )}
            {displayContractor && <Table.Td>{bid.contractor_name}</Table.Td>}
            <Table.Td>{bid.contact_name}</Table.Td>
            <Table.Td><StatusBadge status={bid.status} /></Table.Td>
            <Table.Td>{new Date(bid.bid_due_at).toLocaleDateString()}</Table.Td>
            <Table.Td right>{formatCurrency(bid.submitted_value)}</Table.Td>
            <Table.Td right>{formatCurrency(bid.awarded_value)}</Table.Td>
            {displayEstimator && <Table.Td>{bid.estimators_name}</Table.Td>}
            <Table.Td />
          </Table.Row>
        ))}
      </Table.Body>
    </Table>
  );
}
