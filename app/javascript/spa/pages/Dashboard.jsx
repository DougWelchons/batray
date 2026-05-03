import React, { useEffect, useState } from 'react';
import { useHeader } from '../HeaderContext';
import { StatCard, Card, Table } from '../../components/ui';
import {
  ComposedChart, Bar, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';

function formatMonth(yearMonth) {
  const [year, month] = yearMonth.split('-');
  return new Date(year, month - 1).toLocaleDateString('en-US', { month: 'short', year: '2-digit' });
}

function formatCurrency(value) {
  if (value >= 1_000_000) return `$${(value / 1_000_000).toFixed(1)}M`;
  if (value >= 1_000) return `$${(value / 1_000).toFixed(0)}K`;
  return `$${value}`;
}

// Least-squares linear regression. Returns the trend value for each index.
function addTrend(data, valueKey) {
  const n = data.length;
  if (n < 2) return data.map(d => ({ ...d, trend: d[valueKey] }));

  const xs = data.map((_, i) => i);
  const ys = data.map(d => d[valueKey]);
  const meanX = xs.reduce((a, b) => a + b, 0) / n;
  const meanY = ys.reduce((a, b) => a + b, 0) / n;
  const slope = xs.reduce((sum, x, i) => sum + (x - meanX) * (ys[i] - meanY), 0) /
                xs.reduce((sum, x) => sum + (x - meanX) ** 2, 0);
  const intercept = meanY - slope * meanX;

  return data.map((d, i) => ({ ...d, trend: Math.max(0, slope * i + intercept) }));
}

const BidsTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  const bar = payload.find(p => p.dataKey === 'count');
  return (
    <div className="chart-tooltip">
      <div className="chart-tooltip__label">{label}</div>
      {bar && <div className="chart-tooltip__value">{bar.value} bids</div>}
    </div>
  );
};

const RevenueTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  const bar = payload.find(p => p.dataKey === 'total');
  return (
    <div className="chart-tooltip">
      <div className="chart-tooltip__label">{label}</div>
      {bar && <div className="chart-tooltip__value">{formatCurrency(bar.value)}</div>}
    </div>
  );
};

export default function Dashboard() {
  useHeader('Dashboard');

  const [analytics, setAnalytics] = useState(null);

  useEffect(() => {
    fetch('/api/v1/analytics/dashboard', { headers: { Accept: 'application/json' } })
      .then(r => r.json())
      .then(data => setAnalytics(data))
      .catch(() => {});
  }, []);

  const bidsData = addTrend(
    (analytics?.bids_per_month ?? []).map(d => ({ ...d, label: formatMonth(d.month) })),
    'count'
  );

  const revenueData = addTrend(
    (analytics?.awarded_revenue_by_month ?? []).map(d => ({ ...d, label: formatMonth(d.month) })),
    'total'
  );

  const formatDate = (dateString) => {
    if (!dateString) return null;
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return new Date(dateString).toLocaleDateString(undefined, options);
  }

  console.log('analytics.contractor_data', analytics?.contractor_data);

  return (
    <div className="dashboard">
      <div className="stats-grid">
        <StatCard
          label="Total Bids YTD"
          value={analytics ? (analytics.stats?.total_bids_ytd ?? 0) : '--'}
          info="Count of distinct projects with at least one submitted, awarded, or lost bid this calendar year. A project with multiple GC bids counts as one."
        />
        <StatCard
          label="Total Awarded YTD"
          value={analytics ? formatCurrency(analytics.stats?.total_awarded_ytd ?? 0) : '--'}
          info="Sum of awarded_value for all bids with an award decision date in the current calendar year."
        />
        <StatCard
          label="Win Rate"
          value={analytics ? (analytics.stats?.win_rate != null ? `${analytics.stats.win_rate}%` : '—') : '--'}
          info="Project-level win rate: awarded projects ÷ qualifying projects. Qualifying = submitted, awarded, or lost. Excludes drafting, withdrawn, and declined."
        />
        <StatCard
          label="Dollar Win Rate"
          value={analytics ? (analytics.stats?.dollar_win_rate != null ? `${analytics.stats.dollar_win_rate}%` : '—') : '--'}
          info="Total awarded value ÷ total representative value. For won projects, representative value = awarded value. For others, it = average submitted value across GC bids."
        />
      </div>

      <div className="charts-grid">
        <Card>
          <div className="chart-header">
            <h3 className="chart-title">Bids per Month</h3>
          </div>
          <ResponsiveContainer width="100%" height={260}>
            <ComposedChart data={bidsData} margin={{ top: 4, right: 16, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border)" vertical={false} />
              <XAxis
                dataKey="label"
                tick={{ fill: 'var(--color-text-secondary)', fontSize: 12 }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                allowDecimals={false}
                tick={{ fill: 'var(--color-text-secondary)', fontSize: 12 }}
                axisLine={false}
                tickLine={false}
                width={30}
              />
              <Tooltip content={<BidsTooltip />} cursor={{ fill: 'var(--color-accent-subtle)' }} />
              <Bar dataKey="count" fill="var(--color-accent)" radius={[3, 3, 0, 0]} />
              <Line
                dataKey="trend"
                stroke="var(--color-text-muted)"
                strokeWidth={2}
                strokeDasharray="4 3"
                dot={false}
                activeDot={false}
              />
            </ComposedChart>
          </ResponsiveContainer>
        </Card>

        <Card>
          <div className="chart-header">
            <h3 className="chart-title">Awarded Revenue by Month</h3>
          </div>
          <ResponsiveContainer width="100%" height={260}>
            <ComposedChart data={revenueData} margin={{ top: 4, right: 16, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border)" vertical={false} />
              <XAxis
                dataKey="label"
                tick={{ fill: 'var(--color-text-secondary)', fontSize: 12 }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                tickFormatter={formatCurrency}
                tick={{ fill: 'var(--color-text-secondary)', fontSize: 12 }}
                axisLine={false}
                tickLine={false}
                width={54}
              />
              <Tooltip content={<RevenueTooltip />} cursor={{ fill: 'var(--color-accent-subtle)' }} />
              <Bar dataKey="total" fill="var(--color-status-awarded, #95a89e)" radius={[3, 3, 0, 0]} />
              <Line
                dataKey="trend"
                stroke="var(--color-text-muted)"
                strokeWidth={2}
                strokeDasharray="4 3"
                dot={false}
                activeDot={false}
              />
            </ComposedChart>
          </ResponsiveContainer>
        </Card>
      </div>
      <Card>
        <Table>
          <Table.Head>
            <Table.Row>
              <Table.Th>Contractor</Table.Th>
              <Table.Th>Total Bids</Table.Th>
              <Table.Th>Awarded</Table.Th>
              <Table.Th>Win Rate</Table.Th>
              <Table.Th>Submitted Value</Table.Th>
              <Table.Th>Awarded Value</Table.Th>
              <Table.Th>Awarded Rate</Table.Th>
            </Table.Row>
            </Table.Head>
            <Table.Body>
              {(analytics?.contractor_data ?? []).map((contractor) => (
                <Table.Row key={contractor.id}>
                  <Table.Td>{contractor.name}</Table.Td>
                  <Table.Td>{contractor.total_bids}</Table.Td>
                  <Table.Td>{contractor.total_wins}</Table.Td>
                  <Table.Td>{contractor.win_pct}%</Table.Td>
                  <Table.Td>{formatCurrency(contractor.bid_value)}</Table.Td>
                  <Table.Td>{formatCurrency(contractor.win_value)}</Table.Td>
                  <Table.Td>{contractor.value_pct}%</Table.Td>
                </Table.Row>
              ))}
            </Table.Body>
        </Table>
      </Card>
    </div>
  );
}
