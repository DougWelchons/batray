import React, { useEffect } from "react";
import { Link, useParams } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { fetchContractor } from "../../spa/store/slices/contractorsSlice";
import BidSubmissionsTable from "../../components/BidSubmissionsTable";
import ContactsTable from "../../components/ContactsTable";
import CollapsibleCard from "../../components/CollapsibleCard";
import { useHeader } from "../HeaderContext";

export default function ContractorsTable() {
  const { id } = useParams();
  const dispatch = useDispatch();
  const contractor = useSelector((state) =>
    state.contractors.items.find((c) => c.id === id)
  );
  const contacts = useSelector((state) => state.contacts.items.filter((contact) => contact.contractor_id === id));
  // const bids = useSelector((state) => state.bidSubmissions.items.filter((bid) => bid.contractor_id === parseInt(id)));

  useHeader(contractor?.name || '', <Link to={`/contractors/${id}/edit`} className="btn btn--ghost">Edit</Link>);

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
    <div>
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-card__label">Total Bids</div>
          <div className="stat-card__value">{contractor.bid_submissions.length}</div>
        </div>
        <div className="stat-card">
          <div className="stat-card__label">Total Submitted Value</div>
          <div className="stat-card__value">{totalSubmittedValue}</div>
        </div>
        <div className="stat-card">
          <div className="stat-card__label">Total Awarded Value</div>
          <div className="stat-card__value">{totalAwardedValue}</div>
        </div>
        <div className="stat-card">
          <div className="stat-card__label">% By Value</div>
          <div className="stat-card__value">{dollarWinRate}</div>
        </div>
      </div>
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-card__label">Pending</div>
          <div className="stat-card__value">{pendingCount}</div>
        </div>
        <div className="stat-card">
          <div className="stat-card__label">Won</div>
          <div className="stat-card__value">{wonCount}</div>
        </div>
        <div className="stat-card">
          <div className="stat-card__label">Lost</div>
          <div className="stat-card__value">{lostCount}</div>
        </div>
        <div className="stat-card">
          <div className="stat-card__label">% By Win/Loss</div>
          <div className="stat-card__value">{countWinRate}</div>
        </div>
      </div>
      <CollapsibleCard title="Details">
        <dl className="meta-list">
          {contractor.contact_name && (
            <div className="meta-item">
              <dt>Primary Contact</dt>
              <dd>{contractor.contact_name}</dd>
            </div>
          )}
          {contractor.phone && (
            <div className="meta-item">
              <dt>Phone</dt>
              <dd>{contractor.phone}</dd>
            </div>
          )}
          {(contractor.street || contractor.city || contractor.state || contractor.zip_code) && (
            <div className="meta-item">
              <dt>Address</dt>
              <dd>
                {contractor.street && <span>{contractor.street}<br /></span>}
                {(contractor.city || contractor.state || contractor.zip_code) && (
                  <span>
                    {[contractor.city, contractor.state].filter(Boolean).join(', ')}
                    {contractor.zip_code && ` ${contractor.zip_code}`}
                  </span>
                )}
              </dd>
            </div>
          )}
          {contractor.notes && (
            <div className="meta-item" style={{ flexBasis: '100%' }}>
              <dt>Notes</dt>
              <dd style={{ whiteSpace: 'pre-wrap' }}>{contractor.notes}</dd>
            </div>
          )}
        </dl>
      </CollapsibleCard>
      <CollapsibleCard title="Contacts">
        <ContactsTable contacts={contacts} contractorId={contractor.id} />
      </CollapsibleCard>
      <CollapsibleCard title="Bid Submissions">
        <BidSubmissionsTable bids={contractor.bid_submissions} displayContractor={false} />
      </CollapsibleCard>
    </div>
  </>);
}
