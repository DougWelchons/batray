import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './spa/App';
import { store } from './spa/store';
import { addFlash } from './spa/store/slices/flashSlice';

// Seed any flash messages that Rails embedded on page load
const container = document.getElementById('root');
try {
  const initialFlash = JSON.parse(container.dataset.flash || '{}');
  if (Object.keys(initialFlash).length > 0) {
    store.dispatch(addFlash(initialFlash));
  }
} catch (_) {}

// Intercept all fetch calls to pick up X-Flash-* headers from API responses
const originalFetch = window.fetch;
window.fetch = async (...args) => {
  const response = await originalFetch(...args);
  const notice = response.headers.get('X-Flash-Notice');
  const alert = response.headers.get('X-Flash-Alert');
  if (notice || alert) {
    const flash = {};
    if (notice) flash.notice = notice;
    if (alert) flash.alert = alert;
    store.dispatch(addFlash(flash));
  }
  return response;
};

const root = createRoot(container);
root.render(<App />);
