import React from 'react';
import ContractorsTable from '../../components/ContractorsTable';
import { useHeader } from '../HeaderContext';
import { Link } from 'react-router-dom';

export default function Contractors() {
  useHeader('Contractors', <Link to="/contractors/new" className="btn btn--primary">Add Contractor</Link>);

  return (
    <ContractorsTable />
  );
}
