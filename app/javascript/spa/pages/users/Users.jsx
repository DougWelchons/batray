import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import UsersTable from "./UsersTable";
import { Card } from "../../../components/ui";
import { fetchUsers } from "../../store/slices/usersSlice";

export default function Users() {
  const dispatch = useDispatch()
  const users = useSelector(state => state.users.items);

  useEffect(() => {
    dispatch(fetchUsers());
  }, [dispatch]);

  return (
    <Card>
      <UsersTable users={users} />
    </Card>
  )
}