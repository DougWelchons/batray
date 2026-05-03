import React, { useState } from 'react';

/**
 * InfoTooltip — an (i) icon that reveals a short explanation on hover.
 *
 * text: string — the explanation to display
 *
 * Usage: <InfoTooltip text="Win rate = awarded projects / qualifying projects" />
 */
export default function InfoTooltip({ text }) {
  const [visible, setVisible] = useState(false);

  return (
    <span className="info-tooltip">
      <span
        className="info-tooltip__icon"
        onMouseEnter={() => setVisible(true)}
        onMouseLeave={() => setVisible(false)}
        aria-label={text}
      >
        i
      </span>
      {visible && (
        <span className="info-tooltip__popup" role="tooltip">
          {text}
        </span>
      )}
    </span>
  );
}
