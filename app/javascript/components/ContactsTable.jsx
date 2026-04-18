import React, { useEffect, useState } from "react";
import ContactsTableRow from "./ContactsTableRow";
import { fetchContacts } from "../spa/store/slices/contactsSlice";
import { useDispatch, useSelector } from "react-redux";

export default function ContactsTable({ contractorId }) {
  const dispatch = useDispatch();
  const existingContacts = useSelector(state => state.contacts.items);
  const [newContacts, setNewContacts] = useState([]);
  const [contacts, setContacts] = useState([...existingContacts, ...newContacts]);

  useEffect(() => {
    dispatch(fetchContacts(contractorId));
  }, [dispatch, contractorId]);

  useEffect(() => {
    setContacts([...existingContacts, ...newContacts]);
  }, [existingContacts, newContacts]);

  const handleAddContact = () => {
    const contact = { tempID: Date.now(), id: "", name: "", email: "", phone: "", role: "", contractor_id: contractorId };
    setNewContacts(prev => [...prev, contact]);
    setContacts([...contacts, contact]);
  };

  const handleCancel = identifier => {
    setContacts(prev => prev.filter(c => c.tempID !== identifier));
    setNewContacts(prev => prev.filter(c => c.tempID !== identifier));
  }

  const handleSave = identifier => {
    setNewContacts(prev => prev.filter(c => c.tempID !== identifier));
  }

  return (
    <table className="table">
      <thead>
        <tr>
          <th>Name</th>
          <th>Email</th>
          <th>Phone</th>
          <th>Role</th>
          <th>
            <button className="btn btn--ghost btn--sm" onClick={handleAddContact}>+ Add Contact</button>
          </th>
        </tr>
      </thead>
      <tbody>
        {contacts.map((contact, index) => (
          <ContactsTableRow
            key={contact.id || contact.tempID || index}
            contact={contact}
            contractorId={contractorId}
            handleCancel={handleCancel}
            handleSave={handleSave}
          />
        ))}
      </tbody>
    </table>
  )
}
