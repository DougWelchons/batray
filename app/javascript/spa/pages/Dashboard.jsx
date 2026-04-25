import React from 'react';
import { useHeader } from '../HeaderContext';
import { StatCard } from '../../components/ui';

export default function Dashboard() {
  useHeader('Dashboard');

  return (
    <div className="stats-grid">
      <StatCard label="Total Bids YTD" value="--" />
      <StatCard label="Total Awarded YTD" value="--" />
      <StatCard label="Win Rate %" value="--" />
      <StatCard label="Dollar Win Rate %" value="--" />
    </div>
  );
}
