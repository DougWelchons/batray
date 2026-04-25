import React, { useEffect } from 'react';
import { useDispatch, useSelector } from "react-redux";
import { fetchProjects } from "../../store/slices/projectsSlice";
import { fetchClassifications } from "../../store/slices/classificationsSlice";
import ProjectsTable from './ProjectsTable';
import { useHeader } from '../../HeaderContext';

const DUE_SOON_DAYS = 2;

export default function Projects() {
  const dispatch = useDispatch();
  const projects = useSelector(state => state.projects.items);
  const classifications = useSelector(state => state.classifications.items);

  useHeader('Projects');

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
