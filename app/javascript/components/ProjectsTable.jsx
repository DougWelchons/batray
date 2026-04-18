import React from "react";
import { useSelector } from "react-redux";
import { Link } from "react-router-dom";

export default function ProjectsTable() {
  const projects = useSelector(state => state.projects.items);
  const classifications = useSelector(state => state.classifications.items);
  const [sortColumn, setSortColumn] = React.useState("bid_due_at");
  const [sortDirection, setSortDirection] = React.useState("desc");

  const formatDate = (dateString) => {
    if (!dateString) return null;
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return new Date(dateString).toLocaleDateString(undefined, options);
  }

  const projectDueDateClass = (project) => {
    if (project.project_due_status === "due-soon") return "bid-due--warning";
    if (project.project_due_status === "overdue") return "bid-due--overdue";
    return "";
  }

  const projectStatusClass = (project) => {
    if (project.project_status === "drafting") return "project-row--drafting";
    if (project.project_status === "submitted") return "project-row--submitted";
    if (project.project_status === "awarded") return "project-row--awarded";
    if (project.project_status === "lost") return "project-row--lost";
    return "project-row--inactive";
  }

  const handleSort = (column) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortColumn(column);
      setSortDirection("asc");
    }
  }

  const sortedProjects = React.useMemo(() => {
    if (!projects) return [];

    const sorted = [...projects].sort((a, b) => {
      let aVal, bVal;

      switch (sortColumn) {
        case "name":
          aVal = a.name?.toLowerCase() || "";
          bVal = b.name?.toLowerCase() || "";
          break;
        case "location":
          aVal = a.location?.toLowerCase() || "";
          bVal = b.location?.toLowerCase() || "";
          break;
        case "bid_due_at":
          // Projects with no bid due date should appear at the top (largest sort value when desc)
          aVal = a.earliest_bid_due_at ? new Date(a.earliest_bid_due_at).getTime() : Infinity;
          bVal = b.earliest_bid_due_at ? new Date(b.earliest_bid_due_at).getTime() : Infinity;
          break;
        case "project_type":
          aVal = a.classification_ids?.length || 0;
          bVal = b.classification_ids?.length || 0;
          break;
        case "estimated_start_date":
          aVal = a.estimated_start_date ? new Date(a.estimated_start_date).getTime() : 0;
          bVal = b.estimated_start_date ? new Date(b.estimated_start_date).getTime() : 0;
          break;
        case "bid_count":
          aVal = a.bid_count || 0;
          bVal = b.bid_count || 0;
          break;
        default:
          return 0;
      }

      if (aVal < bVal) return sortDirection === "asc" ? -1 : 1;
      if (aVal > bVal) return sortDirection === "asc" ? 1 : -1;
      return 0;
    });

    return sorted;
  }, [projects, sortColumn, sortDirection]);

  const SortableHeader = ({ column, label, className = "" }) => {
    const isActive = sortColumn === column;
    const icon = isActive ? (sortDirection === "asc" ? " ↑" : " ↓") : "";

    return (
      <th>
        <button
          onClick={() => handleSort(column)}
          className={`sort-link ${isActive ? "sort-link--active" : ""} ${className}`}
        >
          {label}
          <span className="sort-indicator">{icon}</span>
        </button>
      </th>
    );
  }

  return (
    <div className="card">
      {projects?.length > 0 ?
        <table className="table">
          <thead>
            <tr>
              <SortableHeader column="name" label="Project Name" />
              <SortableHeader column="location" label="Location" />
              <SortableHeader column="bid_due_at" label="Bid Due" />
              <SortableHeader column="project_type" label="Type" />
              <SortableHeader column="estimated_start_date" label="Start Date" />
              <SortableHeader column="bid_count" label="Bids" className="sort-link--right" />
              <th></th>
            </tr>
          </thead>
          <tbody>
            {sortedProjects.map(project => (
              <tr key={project.id} className={projectStatusClass(project)}>
                <td>
                  <Link to={`/projects/${project.id}`} className="link">{project.name}</Link>
                  {project.rebid_of_id && (
                    <span className="tag">Rebid</span>
                  )}
                </td>
                <td>{project.location || "—"}</td>
                <td className={projectDueDateClass(project)}>{formatDate(project.earliest_bid_due_at) || "—"}</td>
                <td>
                  {(() => {
                    const ids = project.classification_ids || [];
                    if (ids.length === 0) return "—";
                    if (ids.length === 1) {
                      const name = classifications.find(c => c.id === ids[0])?.name;
                      return <span className="tag">{name || "—"}</span>;
                    }
                    return <span className="tag">{ids.length} types</span>;
                  })()}
                </td>
                <td>{formatDate(project.estimated_start_date) || "—"}</td>
                <td className="text-right">{project.bid_count}</td>
                <td className="table__actions">
                  <Link to={`/projects/${project.id}/edit`} className="btn btn--ghost btn--sm">Edit</Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table> :
        <div className="empty-state">
          <p>No projects yet.</p>
          <Link to="/projects/new" className="btn btn--primary">Create your first project</Link>
        </div>
      }
    </div>
  );
}
