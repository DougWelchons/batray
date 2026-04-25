import React from 'react';
import ContractorsTable from './ContractorsTable';
import { useHeader } from '../../HeaderContext';

export default function Contractors() {
  useHeader('Contractors');

  return <ContractorsTable />;
}
