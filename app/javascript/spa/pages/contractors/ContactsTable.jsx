import React, { useEffect, useState } from "react";
import ContactsTableRow from "./ContactsTableRow";
import { fetchContacts } from "../../store/slices/contactsSlice";
import { useDispatch, useSelector } from "react-redux";
import { Table, Button } from "../../../components/ui";

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
    <Table>
      <Table.Head>
        <Table.Row>
          <Table.Th>Name</Table.Th>
          <Table.Th>Email</Table.Th>
          <Table.Th>Phone</Table.Th>
          <Table.Th>Role</Table.Th>
          <Table.Th>
            <Button variant="ghost" size="sm" onClick={handleAddContact}>+ Add Contact</Button>
          </Table.Th>
        </Table.Row>
      </Table.Head>
      <Table.Body>
        {contacts.map((contact, index) => (
          <ContactsTableRow
            key={contact.id || contact.tempID || index}
            contact={contact}
            contractorId={contractorId}
            handleCancel={handleCancel}
            handleSave={handleSave}
          />
        ))}
      </Table.Body>
    </Table>
  )
}
