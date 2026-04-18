import React, { useEffect } from 'react';
import { Provider, useDispatch, useSelector } from 'react-redux';
import { BrowserRouter, Routes, Route, Link, Navigate } from 'react-router-dom';
import store from './store';
import { fetchCurrentUser } from './store/slices/currentUserSlice';
import { HeaderProvider, useHeaderProps } from './HeaderContext';
import Dashboard from './pages/Dashboard';
import Projects from './pages/Projects';
import Contractors from './pages/Contractors';
import ContractorShow from './pages/ContractorShow';
import BidSubmissions from './pages/BidSubmissions';
import Sidebar from '../components/Sidebar';
import ContractorsForm from '../components/ContractorsForm';
import Header from '../components/Header';
import Flash from '../components/Flash';
import ProjectShow from './pages/ProjectShow';
import ProjectsForm from './pages/ProjectsForm';

function AppContent() {
  const dispatch = useDispatch();
  const currentUser = useSelector(state => state.currentUser.data);
  const headerProps = useHeaderProps();

  useEffect(() => {
    dispatch(fetchCurrentUser());
  }, [dispatch]);

  return (
    <BrowserRouter>
      <div className="min-h-screen bg-gray-50">
        <Sidebar currentUser={currentUser} />

        <Header {...headerProps} />

        <Flash />

        <main className="page-content">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/projects" element={<Projects />} />
            <Route path="/projects/new" element={<ProjectsForm />} />
            <Route path="/projects/:id" element={<ProjectShow />} />
            <Route path="/projects/:id/edit" element={<ProjectsForm />} />
            <Route path="/contractors" element={<Contractors />} />
            <Route path="/contractors/new" element={<ContractorsForm />} />
            <Route path="/contractors/:id" element={<ContractorShow />} />
            <Route path="/contractors/:id/edit" element={<ContractorsForm />} />
            <Route path="/bids" element={<BidSubmissions />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}

export default function App() {
  return (
    <Provider store={store}>
      <HeaderProvider>
        <AppContent />
      </HeaderProvider>
    </Provider>
  );
}
