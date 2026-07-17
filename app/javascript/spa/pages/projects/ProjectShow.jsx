import React, { useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { fetchProject } from "../../store/slices/projectsSlice";
import { fetchClassifications } from "../../store/slices/classificationsSlice";
import { Card, MetaList, MetaItem, Button } from "../../../components/ui";
import BidSubmissionsTable from "../../../components/shared/BidSubmissionsTable";
import { useHeader } from "../../HeaderContext";

export default function ProjectShow() {
  const dispatch  = useDispatch()
  const { id } = useParams();
  const project = useSelector(state => state.projects.items.find(p => p.id === id));
  const classifications = useSelector(state => state.classifications.items);

  useEffect(() => {
    dispatch(fetchProject(id));
  }, [dispatch, id]);

  useEffect(() => {
    if (classifications.length === 0) dispatch(fetchClassifications());
  }, [dispatch, classifications.length]);

  useHeader(project?.name || '', <Button as="link" to={`/projects/${id}/edit`} variant="primary">Edit</Button>);

  const longDateFormat = (date) => {
    if (!date) return '-';
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      timeZone: 'UTC'
    });
  }

  return (<>
    <Card>
      <MetaList>
        <MetaItem label="Location">
          {project && <>
            <span>{project.street}</span>
            <span>{project.city} {project.state} {project.zip_code}</span>
          </>}
        </MetaItem>
        <MetaItem label="Project Type">
          {(project?.classification_ids?.length > 0)
            ? classifications
                .filter(c => project.classification_ids.includes(c.id))
                .map(c => c.name)
                .join(", ")
            : "-"}
        </MetaItem>
        <MetaItem label="Estimated Start Date">{longDateFormat(project?.estimated_start_date)}</MetaItem>
        <MetaItem label="Bid Due Date">{longDateFormat(project?.earliest_bid_due_at)}</MetaItem>
        <MetaItem label="Status">{project?.project_status}</MetaItem>
      </MetaList>
      <div className="form__section-header">
        <h2 className="form__section-title">Notes</h2>
      </div>
      {project?.notes ? <div>{project.notes}</div> : <div>No notes to display</div>}
    </Card>
    <Card title="Bid Submissions" collapsible>
      <BidSubmissionsTable bids={project?.bid_submissions} displayProject={false} />
    </Card>
  </>)
}
