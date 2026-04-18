import React, { useEffect } from 'react';
import { createPortal } from 'react-dom';
import { useSelector, useDispatch } from 'react-redux';
import { dismissFlash } from '../spa/store/slices/flashSlice';

function FlashMessage({ id, type, message }) {
  const dispatch = useDispatch();

  useEffect(() => {
    const timer = setTimeout(() => dispatch(dismissFlash(id)), 4000);
    return () => clearTimeout(timer);
  }, [id, dispatch]);

  return (
    <div
      className={`flash flash--${type === 'alert' ? 'alert' : 'notice'}`}
      role="alert"
    >
      {message}
    </div>
  );
}

export default function Flash() {
  const messages = useSelector(state => state.flash.messages);
  if (messages.length === 0) return null;

  return (
    <div className="flash-container">
      {messages.map(msg => (
        <FlashMessage key={msg.id} {...msg} />
      ))}
    </div>
  );
}
