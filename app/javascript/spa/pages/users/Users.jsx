import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import UsersTable from "./UsersTable";
import { Button, Card } from "../../../components/ui";
import { useHeader } from '../../HeaderContext';
import { fetchUsers } from "../../store/slices/usersSlice";

export default function Users() {
  const dispatch = useDispatch()
  const users = useSelector(state => state.users.items);

  useHeader('Users', <Button as="link" to="/users/new" variant="primary">+ Add</Button>);

  useEffect(() => {
    dispatch(fetchUsers());
  }, [dispatch]);

  return (
    <Card>
      <UsersTable users={users} />
    </Card>
  )
}