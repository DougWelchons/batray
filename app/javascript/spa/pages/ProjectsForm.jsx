import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { createProject, fetchProject, updateProject } from "../store/slices/projectsSlice";
import { useHeader } from "../HeaderContext";
import FormField from "../../components/forms/FormField";
import MultiSelectDropDown from "../../components/forms/MultiSelectDropDown";
import { useParams } from "react-router-dom";
import ProjectBidForm from "../../components/ProjectBidForm";
import { fetchContractors } from "../store/slices/contractorsSlice";
import { fetchClassifications } from "../store/slices/classificationsSlice";

export default function ProjectsForm() {
  const dispatch = useDispatch();
  const {id} = useParams();
  const project = useSelector(state => id ? state.projects.items.find(p => p.id === id) : {});
  const defaultData = { id: "", name: "", street: "", city: "", state: "", zip_code: "", classification_ids: [], estimated_start_date: "" };
  const defaultBidData = { contractor_id: "", contact_id: "", bid_due_at: "", submitted_value: "", fa: "", lv: "", status: "" };
  const [formData, setFormData] = useState({ ...defaultData, ...project });
  const [bids, setBids] = useState(project?.bid_submissions ? project.bid_submissions.map(bid => ({ ...defaultBidData, ...bid })) : [{ ...defaultBidData, tempId: Date.now() }]);
  const contractors = useSelector(state => state.contractors.items);
  const classifications = useSelector(state => state.classifications.items);

  useEffect(() => {
    if (contractors.length === 0) {
      dispatch(fetchContractors());
    }
  }, [dispatch, contractors.length]);

  useEffect(() => {
    if (classifications.length === 0) {
      dispatch(fetchClassifications());
    }
  }, [dispatch, classifications.length]);

  useEffect(() => {
    if (id)
      dispatch(fetchProject(id));
  }, [dispatch, id]);

  useEffect(() => {
    if (project && project.id) {
      setFormData({ ...defaultData, ...project });
      setBids(project.bid_submissions ? project.bid_submissions.map(bid => ({ ...defaultBidData, ...bid })) : []);
    }
  }, [project?.id]);

  const addBid = () => {
    setBids(prevBids => [...prevBids, { ...defaultBidData, tempId: Date.now() }]);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prevData => ({ ...prevData, [name]: value }));
  };

  const handleSubmit = (e) => {
    dispatch(project?.id ? updateProject({ id: project.id, projectData: formData }) : createProject(formData));
  }

  useHeader(project?.id ? `Edit ${project.name}` : "Add Project");

  const selectedClassifications = classifications.filter(c => (formData.classification_ids || []).includes(c.id));

  return (
    <div className="card">
      <div className="form__row form__row--cols-1">
        <FormField label="Name" name="name" value={formData.name} onChange={handleChange} />
        <FormField label="Street" name="street" value={formData.street} onChange={handleChange} />
      </div>
      <div className="form__row form__row--cols-3">
        <FormField label="City" name="city" value={formData.city} onChange={handleChange} />
        <FormField label="State" name="state" value={formData.state} onChange={handleChange} />
        <FormField label="Zip Code" name="zip_code" value={formData.zip_code} onChange={handleChange} />
      </div>
      <div className="form__row form__row--cols-2">
        <MultiSelectDropDown
          label="Project Type"
          items={classifications}
          value={selectedClassifications}
          displayFn={(c) => c.name}
          searchableColumns={["name"]}
          onChange={(selected) => setFormData(prev => ({ ...prev, classification_ids: selected.map(c => c.id) }))}
        />
        <FormField label="Estimated Start Date" name="estimated_start_date" type="date" value={formData.estimated_start_date} onChange={handleChange} />
      </div>

      <div className="form__section">
        <div className="form__section-header">
          <h2 className="form__section-title">General Contractors</h2>
          <button type="button" className="btn btn--secondary btn--sm" onClick={addBid}>
            + Add GC
          </button>
        </div>

        <table className="table">
          <thead>
            <tr>
              <th>General Contractor</th>
              <th>Contact</th>
              <th>Bid Due Date</th>
              {/* <th>Submitted Value</th>
              <th>FA</th>
              <th>LV</th>
              <th>Status</th>
              <th></th> */}
            </tr>
          </thead>
          <tbody>
            {bids.length > 0 ? bids.map((bid, index) => (
              <ProjectBidForm
                key={bid.id || bid.tempId || index}
                bid={bid}
                contractors={contractors}
                onChange={(e) => {
                  const { name, value } = e.target;
                  setBids(prevBids => {
                    const newBids = [...prevBids];
                    newBids[index] = { ...newBids[index], [name]: value };
                    return newBids;
                  });
                }}
              />
            )) :
            <tr><td colSpan="8">No bids added yet</td></tr>}
          </tbody>
        </table>
      </div>
    </div>
  )
}
