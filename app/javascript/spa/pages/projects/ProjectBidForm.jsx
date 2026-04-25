import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { FormField, SearchableDropDown, Button, Table } from '../../../components/ui';
import { fetchContacts } from '../../store/slices/contactsSlice';

export default function ProjectBidForm({ bid = {}, contractors = [], onChange = () => {}, removeBid = () => {} }) {
  const dispatch = useDispatch();
  const allContacts = useSelector((state) => state.contacts.items);

  const selectedContractor = contractors.find((c) => c.id === bid.contractor_id) || null;
  const contractorContacts = bid.contractor_id
    ? allContacts.filter((c) => c.contractor_id === bid.contractor_id)
    : [];
  const selectedContact = contractorContacts.find((c) => c.id === bid.contact_id) || null;

  useEffect(() => {
    if (bid.contractor_id) {
      dispatch(fetchContacts(bid.contractor_id));
    }
  }, [bid.contractor_id, dispatch]);

  const handleContractorChange = (contractor) => {
    onChange({ target: { name: "contractor_id", value: contractor.id } });
    onChange({ target: { name: "contact_id", value: "" } });
  };

  const handleContactChange = (contact) => {
    onChange({ target: { name: "contact_id", value: contact.id } });
  };

  const removeThisBid = () => {
    removeBid(bid.tempId)
  }

  return (
    <Table.Row>
      <Table.Td>
        <SearchableDropDown
          label="Contractor"
          items={contractors}
          searchableColumns={["name"]}
          displayFn={(c) => c.name}
          value={selectedContractor}
          onChange={handleContractorChange}
          placeholder="Select contractor..."
          disabled={!!bid.id}
          showLabel={false}
        />
      </Table.Td>
      <Table.Td>
        <SearchableDropDown
          label="Contact"
          items={contractorContacts}
          searchableColumns={["name", "role"]}
          displayFn={(c) => c.role ? `${c.name} (${c.role})` : c.name}
          value={selectedContact}
          onChange={handleContactChange}
          placeholder={selectedContractor ? "Select contact..." : "Select contractor first"}
          disabled={!selectedContractor}
          showLabel={false}
        />
      </Table.Td>
      <Table.Td>
        <FormField label="Bid Due" name="bid_due_at" value={bid.bid_due_at} type="date" onChange={onChange} showLabel={false} />
      </Table.Td>
      <Table.Td actions>
        {!bid.id && <Button variant="danger" size="sm" onClick={removeThisBid}>×</Button>}
      </Table.Td>
    </Table.Row>
  )
}
