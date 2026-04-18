import React, { useState } from 'react';

export default function CollapsibleCard({ title, children, defaultOpen = true }) {
  const [isOpen, setIsOpen] = useState(defaultOpen);

  return (
    <div className="card">
      <div
        className="card-header clickable"
        onClick={() => setIsOpen(!isOpen)}
        style={{ cursor: 'pointer', userSelect: 'none' }}
      >
        <div className="card__title">
          <span style={{
            transition: 'transform 0.2s',
            transform: isOpen ? 'rotate(90deg)' : 'rotate(0deg)',
            display: 'inline-block',
            marginRight: '8px',
          }}>
            ▶
          </span>
          {title}
        </div>
      </div>
      {isOpen && (
        <div className="card-content">
          {children}
        </div>
      )}
    </div>
  );
}
