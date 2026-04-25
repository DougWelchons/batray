import React from 'react';
import ContractorsTable from './ContractorsTable';
import { useHeader } from '../../HeaderContext';
import { Button } from '../../../components/ui';

export default function Contractors() {
  useHeader('Contractors', <Button as="link" to="/contractors/new" variant="primary">+ Add</Button>);

  return <ContractorsTable />;
}
