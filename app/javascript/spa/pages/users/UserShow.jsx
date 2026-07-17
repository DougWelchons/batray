import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useHeader } from '../../HeaderContext';
import { Card } from '../../../components/ui';
import { useParams } from 'react-router-dom';
import { fetchUser } from '../../store/slices/usersSlice';
import ProjectsTable from '../projects/ProjectsTable';
import { fetchProjects } from '../../store/slices/projectsSlice';

export default function UserShow() {
  const dispatch = useDispatch()
  const { id } = useParams();
  const projects = useSelector(state => state.projects.items.filter(p => p.user_id === id));
  const user = useSelector(state => state.users.items.find(u => u.id === id));

  useHeader(user ? user.name : 'User');

  useEffect(() => {
    dispatch(fetchUser(id));
  }, [dispatch, id]);

  useEffect(() => {
    dispatch(fetchProjects());
  }, [dispatch]);

  return (
    <>
      <Card>
        <h2>{user?.name}</h2>
        <p>Email: {user?.email}</p>
        {/* Add more user details as needed */}
      </Card>
      <ProjectsTable />
    </>
  );
}