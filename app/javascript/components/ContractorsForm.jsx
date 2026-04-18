import React, { useEffect } from 'react';
import { useNavigate, useParams } from "react-router-dom";
import FormField from './forms/FormField';
import { useHeader } from '../spa/HeaderContext';
import { createContractor, fetchContractor, updateContractor } from '../spa/store/slices/contractorsSlice';
import { useDispatch, useSelector } from 'react-redux';

export default function ContractorsForm() {
  const dispatch = useDispatch()
  const navigate = useNavigate();
  const { id } = useParams();
  const contractor = id ? useSelector((state) =>
    state.contractors.items.find((c) => c.id === id)
  ) : {};
  const defaultData = { name: "", phone: "", address: "", city: "", state: "", zip_code: "" };
  const [formData, setFormData] = React.useState({ ...defaultData, ...contractor });

  useEffect(() => {
    if (id) {
      dispatch(fetchContractor(id));
    }
  }, [dispatch, id]);

  useEffect(() => {
    if (contractor && contractor.id) {
      setFormData({ ...defaultData, ...contractor });
    }
  }, [contractor?.id]);

  useHeader(contractor?.id ? `Edit ${contractor.name}` : "Add Contractor");
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prevData => ({ ...prevData, [name]: value }));
  };

  const handlePhoneChange = (e) => {
    const { name, value } = e.target;
    // Allow only digits and limit to 10, format progressively
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
  };

  const handleSubmit = (e) => {
    const action = id
      ? dispatch(updateContractor({ id, contractorData: formData }))
      : dispatch(createContractor(formData));

    action.unwrap().then((result) => {
      navigate(`/contractors/${result.id}`);
    });
  }

  const handleCancel = () => {
    if (contractor?.id) {
      navigate(`/contractors/${contractor.id}`);
    } else {
      navigate('/contractors');
    }
  };

  return (
    <div className="card">
      <div className="form__row form__row--cols-2">
        <FormField
          label="Contractor Name"
          name="name"
          value={formData.name}
          onChange={handleChange}
          required
        />
        <FormField
          label="Phone"
          name="phone"
          value={formData.phone}
          onChange={handlePhoneChange}
        />
      </div>
      <div className="form__row form__row--cols-1">
        <FormField
          label="Address"
          name="address"
          value={formData.address}
          onChange={handleChange}
        />
      </div>
      <div className="form__row form__row--cols-3">
        <FormField
          label="City"
          name="city"
          value={formData.city}
          onChange={handleChange}
        />
        <FormField
          label="State"
          name="state"
          value={formData.state}
          onChange={handleChange}
        />
        <FormField
          label="Zip Code"
          name="zip_code"
          value={formData.zip_code}
          onChange={handleChange}
        />
      </div>
      <button type="submit" className="btn btn--primary" onClick={handleSubmit}>{contractor?.id ? "Update Contractor" : "Create Contractor"}</button>
      <button className="btn btn--secondary" onClick={handleCancel}>Cancel</button>
    </div>
  )
}