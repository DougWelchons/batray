import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import FormField from './forms/FormField';
import SearchableDropDown from './forms/searchableDropDown';
import { fetchContacts } from '../spa/store/slices/contactsSlice';

export default function ProjectBidForm({ bid = {}, contractors = [], onChange = () => {} }) {
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

  return (<>
    <tr>
      <td>
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
      </td>
      <td>
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
      </td>
      <td>
        <FormField label="Bid Due" name="bid_due_at" value={bid.bid_due_at} type="date" onChange={onChange} showLabel={false} />
      </td>
      {/* <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td> */}
    </tr>
  </>)
}
