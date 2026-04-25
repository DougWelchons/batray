import React from "react";

/**
 * Table — wraps .table with correct structure.
 *
 * Use as a compound component:
 *
 *   <Table>
 *     <Table.Head>
 *       <Table.Row>
 *         <Table.Th>Name</Table.Th>
 *         <Table.Th right>Value</Table.Th>
 *       </Table.Row>
 *     </Table.Head>
 *     <Table.Body>
 *       {items.map(item => (
 *         <Table.Row key={item.id}>
 *           <Table.Td>{item.name}</Table.Td>
 *           <Table.Td right>{item.value}</Table.Td>
 *         </Table.Row>
 *       ))}
 *     </Table.Body>
 *   </Table>
 *
 * Table.Th / Table.Td props:
 *   right:   bool — text-align right
 *   actions: bool — marks column as .table__actions (right-aligned action buttons)
 *   className: string
 */
function Table({ children, className = "" }) {
  return <table className={`table ${className}`}>{children}</table>;
}

function Head({ children }) {
  return <thead>{children}</thead>;
}

function Body({ children }) {
  return <tbody>{children}</tbody>;
}

function Row({ children, className = "", ...props }) {
  return <tr className={className} {...props}>{children}</tr>;
}

function Th({ children, right = false, className = "", ...props }) {
  const classes = [right ? "text-right" : "", className].filter(Boolean).join(" ");
  return <th className={classes || undefined} {...props}>{children}</th>;
}

function Td({ children, right = false, actions = false, className = "", ...props }) {
  const classes = [
    right ? "text-right" : "",
    actions ? "table__actions" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");
  return <td className={classes || undefined} {...props}>{children}</td>;
}

Table.Head = Head;
Table.Body = Body;
Table.Row = Row;
Table.Th = Th;
Table.Td = Td;

export default Table;
