import React, { useEffect } from "react";
import { useParams } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import BidSubmissionsTable from "../../components/BidSubmissionsTable";
import { fetchProject } from "../../spa/store/slices/projectsSlice";
import CollapsibleCard from "../../components/CollapsibleCard";
import { useHeader } from "../HeaderContext";

export default function ProjectShow() {
  const dispatch  = useDispatch()
  const { id } = useParams();
  const project = useSelector(state => state.projects.items.find(p => p.id === id));

  useEffect(() => {
    dispatch(fetchProject(id));
  }, [dispatch, id]);

  useHeader(project?.name || '');

  const longDateFormat = (date) => {
    if (!date) return '-';
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }

  return (<>
  <div className="card">
    <div className="meta-list">
      <div className="meta-item">
        <dt>Location</dt>
        <dd>{project?.location}</dd>
      </div>
      <div className="meta-item">
        <dt>Project Type</dt>
        <dd>{project?.project_type}</dd>
      </div>
      <div className="meta-item">
        <dt>Estimated Start Date</dt>
        <dd>{longDateFormat(project?.estimated_start_date)}</dd>
      </div>
      <div className="meta-item">
        <dt>Bid Due Date</dt>
        <dd>{longDateFormat(project?.earliest_bid_due_at)}</dd>
      </div>
      <div className="meta-item">
        <dt>Status</dt>
        <dd>{project?.project_status}</dd>
      </div>
    </div>
  </div>
    <CollapsibleCard title="Bid Submissions">
      <BidSubmissionsTable bids={project?.bid_submissions} displayProject={false} />
    </CollapsibleCard>
  </>)
}