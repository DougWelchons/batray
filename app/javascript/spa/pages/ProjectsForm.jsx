import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { createProject, fetchProject, updateProject } from "../store/slices/projectsSlice";
import { useHeader } from "../HeaderContext";
import FormField from "../../components/forms/FormField";
import { useParams } from "react-router-dom";
import ProjectBidForm from "../../components/ProjectBidForm";
import { fetchContractors } from "../store/slices/contractorsSlice";

export default function ProjectsForm() {
  const dispatch = useDispatch();
  const {id} = useParams();
  const project = useSelector(state => id ? state.projects.items.find(p => p.id === id) : {});
  const defaultData = { id: "", name: "", location: "", project_type: "", estimated_start_date: "" };
  const defaultBidData = { contractor_id: "", contact_id: "", bid_due_at: "", submitted_value: "", fa: "", lv: "", status: "" };
  const [formData, setFormData] = React.useState({ ...defaultData, ...project });
  const [bids, setBids] = React.useState(project?.bid_submissions ? project.bid_submissions.map(bid => ({ ...defaultBidData, ...bid })) : []);
  const contractors = useSelector(state => state.contractors.items);

  useEffect(() => {
    if (contractors.length === 0) {
      dispatch(fetchContractors());
    }
  }, [dispatch, contractors.length]);

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

  return (
    <div className="card">
      <div className="form__row form__row--cols-2">
        <FormField label="Name" name="name" value={formData.name} onChange={handleChange} />
        <FormField label="Street" name="street" value={formData.street} onChange={handleChange} />
        <FormField label="City" name="city" value={formData.city} onChange={handleChange} />
        <FormField label="State" name="state" value={formData.state} onChange={handleChange} />
        <FormField label="Zip Code" name="zip_code" value={formData.zip_code} onChange={handleChange} />
        <FormField label="Project Type" name="project_type" value={formData.project_type} onChange={handleChange} />
        <FormField label="Estimated Start Date" name="estimated_start_date" type="date" value={formData.estimated_start_date} onChange={handleChange} />
      </div>

      <div className="form__section">
        <div className="form__section-header">
          <h2 className="form__section-title">GC Bid Submissions</h2>
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
                key={bid.id || bid.tempId}
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
