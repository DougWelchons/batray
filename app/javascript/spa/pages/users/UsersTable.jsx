import React from "react";
import { Button, Table, Tag } from "../../../components/ui";

export default function UsersTable({ users = [] }) {
  return (
    <Table>
      <Table.Head>
        <Table.Row>
          <Table.Th>Name</Table.Th>
          <Table.Th>Email</Table.Th>
          <Table.Th>Role</Table.Th>
          <Table.Th />
        </Table.Row>
      </Table.Head>
      <Table.Body>
        {users.map(user => (
          <Table.Row key={user.id}>
            <Table.Td>{user.name}</Table.Td>
            <Table.Td>{user.email}</Table.Td>
            <Table.Td><Tag>{user.role}</Tag></Table.Td>
            <Table.Td>
              {/* <Button variant="ghost" as="link" size="sm" to={`/users/${user.id}`}>Edit</Button> */}
            </Table.Td>
          </Table.Row>
        ))}
      </Table.Body>
    </Table>
  )
}