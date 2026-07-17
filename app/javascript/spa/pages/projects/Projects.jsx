import React, { useEffect } from 'react';
import { useDispatch, useSelector } from "react-redux";
import { fetchProjects } from "../../store/slices/projectsSlice";
import { fetchClassifications } from "../../store/slices/classificationsSlice";
import ProjectsTable from './ProjectsTable';
import { useHeader } from '../../HeaderContext';
import { StatCard, Button } from '../../../components/ui';

const DUE_SOON_DAYS = 2;

export default function Projects() {
  const dispatch = useDispatch();
  const projects = useSelector(state => state.projects.items);
  const classifications = useSelector(state => state.classifications.items);

  useHeader('Projects', <Button as="link" to="/projects/new" variant="primary">+ Add</Button>);

  useEffect(() => {
    dispatch(fetchProjects());
  }, [dispatch]);

  useEffect(() => {
    if (classifications.length === 0) dispatch(fetchClassifications());
  }, [dispatch, classifications.length]);

  const bidsDueCount = projects.filter(project => project.project_status === "drafting").length;
  const bidsDueSoonCount = projects.filter(project => project.project_due_status === "due-soon").length;
  const bidsOverdueCount = projects.filter(project => project.project_due_status === "overdue").length;

  return (
    <>
      <div className="stats-grid">
        <StatCard label="Projects with Open Bids" value={bidsDueCount} />
        <StatCard label="Bids Due in Next 2 Days" value={bidsDueSoonCount} />
        <StatCard label="Projects with Overdue Bids" value={bidsOverdueCount} />
      </div>
      <ProjectsTable projects={projects} />
    </>
  );
}
