import React from 'react';
import { useHeader } from '../HeaderContext';

export default function Dashboard() {
  useHeader('Dashboard');

  return (
    <div className="px-4 sm:px-0">
      <p className="mt-4 text-gray-600">
        React SPA is running! This is the dashboard page.
      </p>

      <div className="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <dt className="text-sm font-medium text-gray-500 truncate">
              Total Bids YTD
            </dt>
            <dd className="mt-1 text-3xl font-semibold text-gray-900">
              --
            </dd>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <dt className="text-sm font-medium text-gray-500 truncate">
              Total Awarded YTD
            </dt>
            <dd className="mt-1 text-3xl font-semibold text-gray-900">
              --
            </dd>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <dt className="text-sm font-medium text-gray-500 truncate">
              Win Rate %
            </dt>
            <dd className="mt-1 text-3xl font-semibold text-gray-900">
              --
            </dd>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <dt className="text-sm font-medium text-gray-500 truncate">
              Dollar Win Rate %
            </dt>
            <dd className="mt-1 text-3xl font-semibold text-gray-900">
              --
            </dd>
          </div>
        </div>
      </div>
    </div>
  );
}
