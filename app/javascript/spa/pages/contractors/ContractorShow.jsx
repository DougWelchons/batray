import React, { useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { fetchContractor } from "../../store/slices/contractorsSlice";
import { Card, StatCard, MetaList, MetaItem, Button } from "../../../components/ui";
import BidSubmissionsTable from "../../../components/shared/BidSubmissionsTable";
import ContactsTable from "./ContactsTable";
import { useHeader } from "../../HeaderContext";

export default function ContractorShow() {
  const { id } = useParams();
  const dispatch = useDispatch();
  const contractor = useSelector((state) =>
    state.contractors.items.find((c) => c.id === id)
  );
  const contacts = useSelector((state) => state.contacts.items.filter((contact) => contact.contractor_id === id));

  useHeader(contractor?.name || '', <Button as="link" to={`/contractors/${id}/edit`} variant="primary">Edit</Button>);

  useEffect(() => {
    dispatch(fetchContractor(id));
  }, [dispatch, id]);

  if (!contractor) {
    return <div>Loading...</div>;
  }

  const formatCurrency = (value) => {
    if (!value) return '-';
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(value);
  };

  const rawSubmittedValue = contractor.bid_submissions.reduce((sum, bid) => sum + (+bid.submitted_value || 0), 0);
  const rawAwardedValue = contractor.bid_submissions.reduce((sum, bid) => sum + (+bid.awarded_value || 0), 0);
  const totalSubmittedValue = formatCurrency(rawSubmittedValue);
  const totalAwardedValue = formatCurrency(rawAwardedValue);
  const dollarWinRate = rawSubmittedValue > 0 ? `${((rawAwardedValue / rawSubmittedValue) * 100).toFixed(2)}%` : '-';
  const pendingCount = contractor.bid_submissions.filter(bid => bid.status === "drafting").length;
  const wonCount = contractor.bid_submissions.filter(bid => bid.status === "awarded").length;
  const lostCount = contractor.bid_submissions.filter(bid => bid.status === "lost").length;
  const countWinRate = wonCount + lostCount > 0 ? `${((wonCount / (wonCount + lostCount)) * 100).toFixed(2)}%` : '-';

  return (<>
    <div className="stats-grid">
      <StatCard label="Total Bids" value={contractor.bid_submissions.length} />
      <StatCard label="Total Submitted Value" value={totalSubmittedValue} />
      <StatCard label="Total Awarded Value" value={totalAwardedValue} />
      <StatCard label="% By Value" value={dollarWinRate} />
    </div>
    <div className="stats-grid">
      <StatCard label="Pending" value={pendingCount} />
      <StatCard label="Won" value={wonCount} />
      <StatCard label="Lost" value={lostCount} />
      <StatCard label="% By Win/Loss" value={countWinRate} />
    </div>
    <Card title="Details" collapsible>
      <MetaList>
        {contractor.contact_name && (
          <MetaItem label="Primary Contact">{contractor.contact_name}</MetaItem>
        )}
        {contractor.phone && (
          <MetaItem label="Phone">{contractor.phone}</MetaItem>
        )}
        {(contractor.street || contractor.city || contractor.state || contractor.zip_code) && (
          <MetaItem label="Address">
            {contractor.street && <span>{contractor.street}</span>}
            {(contractor.city || contractor.state || contractor.zip_code) && (
              <span>
                {[contractor.city, contractor.state].filter(Boolean).join(', ')}
                {contractor.zip_code && ` ${contractor.zip_code}`}
              </span>
            )}
          </MetaItem>
        )}
        {contractor.notes && (
          <MetaItem label="Notes">
            <span style={{ whiteSpace: 'pre-wrap' }}>{contractor.notes}</span>
          </MetaItem>
        )}
      </MetaList>
    </Card>
    <Card title="Contacts" collapsible>
      <ContactsTable contacts={contacts} contractorId={contractor.id} />
    </Card>
    <Card title="Bid Submissions" collapsible>
      <BidSubmissionsTable bids={contractor.bid_submissions} displayContractor={false} />
    </Card>
  </>);
}
