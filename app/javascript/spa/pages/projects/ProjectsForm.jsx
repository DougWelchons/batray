import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { createProject, fetchProject, updateProject } from "../../store/slices/projectsSlice";
import { useHeader } from "../../HeaderContext";
import { FormField, MultiSelectDropDown, Card, Button, Table } from "../../../components/ui";
import { useParams } from "react-router-dom";
import ProjectBidForm from "./ProjectBidForm";
import { fetchContractors } from "../../store/slices/contractorsSlice";
import { fetchClassifications } from "../../store/slices/classificationsSlice";

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

  const removeBid = (id) => {
    setBids(bids.filter((bid) => bid.tempId !== id && bid.id !== id));
  }

  useHeader(project?.id ? `Edit ${project.name}` : "Add Project");

  const selectedClassifications = classifications.filter(c => (formData.classification_ids || []).includes(c.id));

  return (
    <Card>
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
          <Button type="button" variant="secondary" size="sm" onClick={addBid}>+ Add GC</Button>
        </div>

        <Table>
          <Table.Head>
            <Table.Row>
              <Table.Th>General Contractor</Table.Th>
              <Table.Th>Contact</Table.Th>
              <Table.Th>Bid Due Date</Table.Th>
              <Table.Th />
            </Table.Row>
          </Table.Head>
          <Table.Body>
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
                removeBid={removeBid}
              />
            )) :
            <Table.Row><Table.Td>No bids added yet</Table.Td></Table.Row>}
          </Table.Body>
        </Table>
      </div>
    </Card>
  )
}
