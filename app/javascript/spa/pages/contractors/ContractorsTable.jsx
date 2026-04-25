import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { fetchContractors } from "../../store/slices/contractorsSlice";
import { Link } from "react-router-dom";

export default function ContractorsTable() {
  const dispatch = useDispatch();
  const contractors = useSelector(state => state.contractors.items);

  useEffect(() => {
    dispatch(fetchContractors());
  }, [dispatch]);

  return (
    <div className="card">
      {contractors.length > 0 ? (
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Phone</th>
              <th className="text-right">Bids</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {contractors.map(contractor => (
              <tr key={contractor.id}>
                <td><Link to={`/contractors/${contractor.id}`} className="link">{contractor.name}</Link></td>
                <td>{contractor.phone || "—"}</td>
                <td className="text-right">{contractor.total_bid_submissions}</td>
                <td className="table__actions">
                  <Link to={`/contractors/${contractor.id}/edit`} className="btn btn--ghost btn--sm">Edit</Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>):(
        <div className="empty-state">
          <p>No contractors yet.</p>
          <Link to="/contractors/new" className="btn btn--primary">Add your first contractor</Link>
        </div>
      )}
    </div>
  )
}
