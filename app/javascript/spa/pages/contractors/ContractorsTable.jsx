import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { fetchContractors } from "../../store/slices/contractorsSlice";
import { Link } from "react-router-dom";
import { Card, Table, Button, EmptyState } from "../../../components/ui";

export default function ContractorsTable() {
  const dispatch = useDispatch();
  const contractors = useSelector(state => state.contractors.items);

  useEffect(() => {
    dispatch(fetchContractors());
  }, [dispatch]);

  return (
    <Card noPadding>
      {contractors.length > 0 ? (
        <Table>
          <Table.Head>
            <Table.Row>
              <Table.Th>Name</Table.Th>
              <Table.Th>Phone</Table.Th>
              <Table.Th right>Bids</Table.Th>
              <Table.Th />
            </Table.Row>
          </Table.Head>
          <Table.Body>
            {contractors.map(contractor => (
              <Table.Row key={contractor.id}>
                <Table.Td>
                  <Link to={`/contractors/${contractor.id}`} className="link">{contractor.name}</Link>
                </Table.Td>
                <Table.Td>{contractor.phone || "—"}</Table.Td>
                <Table.Td right>{contractor.total_bid_submissions}</Table.Td>
                <Table.Td actions>
                  <Button as="link" to={`/contractors/${contractor.id}/edit`} variant="ghost" size="sm">Edit</Button>
                </Table.Td>
              </Table.Row>
            ))}
          </Table.Body>
        </Table>
      ) : (
        <EmptyState
          message="No contractors yet."
          action={<Button as="link" to="/contractors/new">Add your first contractor</Button>}
        />
      )}
    </Card>
  );
}
