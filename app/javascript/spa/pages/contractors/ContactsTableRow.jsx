import React, { useState } from "react";
import { useDispatch } from "react-redux";
import { createContact, updateContact, deleteContact } from "../../store/slices/contactsSlice";
import { FormField } from "../../../components/ui";

export default function ContactsTableRow({ contact = {}, contractorId, onChange = () => {}, autoSave = true, handleCancel = () => {}, handleSave = () => {} }) {
  const dispatch = useDispatch();
  const defaultData = { name: "", email: "", phone: "", role: "", contractor_id: contractorId };
  const [isEditing, setIsEditing] = useState(!contact.id);
  const [formData, setFormData] = useState({ ...defaultData, ...contact, contractor_id: contractorId });
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState(null);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prevData => ({ ...prevData, [name]: value }));
    onChange({ ...formData, [name]: value });
  };

  const handlePhoneChange = (e) => {
    const { name, value } = e.target;
    const digits = value.replace(/[^0-9]/g, '').slice(0, 10);

    let formattedValue = '';
    if (digits.length === 0) {
      formattedValue = '';
    } else if (digits.length <= 3) {
      formattedValue = `${digits}`;
    } else if (digits.length <= 6) {
      formattedValue = `${digits.slice(0, 3)}-${digits.slice(3)}`;
    } else {
      formattedValue = `${digits.slice(0, 3)}-${digits.slice(3, 6)}-${digits.slice(6)}`;
    }

    setFormData(prevData => ({ ...prevData, [name]: formattedValue }));
    onChange({ ...formData, [name]: formattedValue });
  };

  const saveContact = async () => {
    if (!autoSave) {
      setIsEditing(false);
      onChange(formData);
      return;
    }

    setSaving(true);
    setSaveError(null);

    const action = contact.id
      ? updateContact({ id: contact.id, contactData: { name: formData.name, email: formData.email, phone: formData.phone, role: formData.role } })
      : createContact({ ...formData, contractor_id: contractorId });

    try {
      await dispatch(action).unwrap();
      setSaving(false);
      setIsEditing(false);
      onChange(formData);
    } catch (err) {
      setSaving(false);
      setSaveError(err || 'Failed to save contact');
    }

    if (!contact.id) {
      handleSave(formData.tempID);
    }
  };

  const handleDelete = () => {
    if (contact.id && window.confirm('Are you sure you want to remove this contact?')) {
      dispatch(deleteContact(contact.id));
    }
  };

  return (<>
    {!isEditing ?
      <tr >
        <td>{contact.name}</td>
        <td>{contact.email}</td>
        <td>{contact.phone}</td>
        <td>{contact.role}</td>
        <td className="table__actions">
          <button className="btn btn--ghost btn--sm" onClick={() => setIsEditing(true)}>Edit</button>
          <button className="btn btn--danger btn--sm" onClick={handleDelete}>Remove</button>
        </td>
      </tr> : <tr>
      <td><FormField
        label="name"
        name="name"
        value={formData.name}
        onChange={handleChange}
        required
      /></td>
      <td><FormField
        label="email"
        name="email"
        value={formData.email}
        onChange={handleChange}
        required
      /></td>
      <td><FormField
        label="phone"
        name="phone"
        value={formData.phone}
        onChange={handlePhoneChange}
        required
      /></td>
      <td><FormField
        label="role"
        name="role"
        value={formData.role}
        onChange={handleChange}
        required
      /></td>
      <td className="table__actions">
        {saveError && <span className="form__error">{saveError}</span>}
        <button className="btn btn--primary btn--sm" onClick={saveContact} disabled={saving}>
          {saving ? 'Saving...' : 'Save'}
        </button>
        <button className="btn btn--ghost btn--sm" disabled={saving} onClick={() => {
          if (!contact.id) {
            handleCancel(contact.tempID);
          }
          setIsEditing(false);
        }}>Cancel</button>
      </td>
    </tr>}
  </>)
}
