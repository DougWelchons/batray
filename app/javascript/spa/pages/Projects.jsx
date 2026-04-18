import React from 'react';
import { useDispatch, useSelector } from "react-redux";
import { fetchProjects } from "../../spa/store/slices/projectsSlice";
import ProjectsTable from '../../components/ProjectsTable';
import { useHeader } from '../HeaderContext';

const DUE_SOON_DAYS = 2;

export default function Projects() {
  const dispatch = useDispatch();
  const projects = useSelector(state => state.projects.items);

  useHeader('Projects');

  React.useEffect(() => {
    dispatch(fetchProjects());
  }, [dispatch]);

  const bidsDueCount = projects.filter(project => project.project_status === "drafting").length;
  const bidsDueSoonCount = projects.filter(project => project.project_due_status === "due-soon").length;
  const bidsOverdueCount = projects.filter(project => project.project_due_status === "overdue").length;

  return (
  <>
    <div className="stats-grid">
      <div className="stat-card">
        <div className="stat-card__label">Projects with Open Bids</div>
        <div className="stat-card__value">{bidsDueCount}</div>
      </div>
      <div className="stat-card">
        <div className="stat-card__label">Bids Due in Next 2 Days</div>
        <div className="stat-card__value">{bidsDueSoonCount}</div>
      </div>
      <div className="stat-card">
        <div className="stat-card__label">Projects with Overdue Bids</div>
        <div className="stat-card__value">{bidsOverdueCount}</div>
      </div>
    </div>
    <ProjectsTable />
  </>
  );
}
