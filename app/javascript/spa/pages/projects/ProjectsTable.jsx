import React, { useState, useMemo } from "react";
import { useSelector } from "react-redux";
import { Link } from "react-router-dom";
import { Card, Table, Tag, Button, EmptyState } from "../../../components/ui";

export default function ProjectsTable({ projects }) {
  // const projects = useSelector(state => state.projects.items);
  const classifications = useSelector(state => state.classifications.items);
  const [sortColumn, setSortColumn] = useState("bid_due_at");
  const [sortDirection, setSortDirection] = useState("desc");

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

  const sortedProjects = useMemo(() => {
    if (!projects) return [];

    return [...projects].sort((a, b) => {
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
  }, [projects, sortColumn, sortDirection]);

  const SortableHeader = ({ column, label, right = false }) => {
    const isActive = sortColumn === column;
    const icon = isActive ? (sortDirection === "asc" ? " ↑" : " ↓") : "";

    return (
      <th>
        <button
          onClick={() => handleSort(column)}
          className={`sort-link ${isActive ? "sort-link--active" : ""} ${right ? "sort-link--right" : ""}`}
        >
          {label}
          <span className="sort-indicator">{icon}</span>
        </button>
      </th>
    );
  }

  return (
    <Card noPadding>
      {projects?.length > 0 ? (
        <Table>
          <Table.Head>
            <Table.Row>
              <SortableHeader column="name" label="Project Name" />
              <SortableHeader column="location" label="Location" />
              <SortableHeader column="bid_due_at" label="Bid Due" />
              <SortableHeader column="project_type" label="Type" />
              <SortableHeader column="estimated_start_date" label="Start Date" />
              <SortableHeader column="bid_count" label="Bids" right />
              <th />
            </Table.Row>
          </Table.Head>
          <Table.Body>
            {sortedProjects.map(project => (
              <Table.Row key={project.id} className={projectStatusClass(project)}>
                <Table.Td>
                  <Link to={`/projects/${project.id}`} className="link">{project.name}</Link>
                  {project.rebid_of_id && <Tag>Rebid</Tag>}
                </Table.Td>
                <Table.Td>{project.city || "—"}</Table.Td>
                <Table.Td className={projectDueDateClass(project)}>
                  {formatDate(project.earliest_bid_due_at) || "—"}
                </Table.Td>
                <Table.Td>
                  {(() => {
                    const ids = project.classification_ids || [];
                    if (ids.length === 0) return "—";
                    if (ids.length === 1) {
                      const name = classifications.find(c => c.id === ids[0])?.name;
                      return <Tag>{name || "—"}</Tag>;
                    }
                    return <Tag>{ids.length} types</Tag>;
                  })()}
                </Table.Td>
                <Table.Td>{formatDate(project.estimated_start_date) || "—"}</Table.Td>
                <Table.Td right>{project.bid_count}</Table.Td>
                <Table.Td actions>
                  <Button as="link" to={`/projects/${project.id}/edit`} variant="ghost" size="sm">Edit</Button>
                </Table.Td>
              </Table.Row>
            ))}
          </Table.Body>
        </Table>
      ) : (
        <EmptyState
          message="No projects yet."
          action={<Button as="link" to="/projects/new">Create your first project</Button>}
        />
      )}
    </Card>
  );
}
