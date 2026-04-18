import React, { createContext, useContext, useState, useCallback, useRef, useEffect } from 'react';

const HeaderContext = createContext(null);

export function HeaderProvider({ children }) {
  const [headerProps, setHeaderProps] = useState({ title: '', actions: null });
  const setHeader = useCallback((props) => setHeaderProps(props), []);
  return (
    <HeaderContext.Provider value={{ headerProps, setHeader }}>
      {children}
    </HeaderContext.Provider>
  );
}

export function useHeader(title, actions = null) {
  const { setHeader } = useContext(HeaderContext);
  const actionsRef = useRef(actions);
  actionsRef.current = actions;

  useEffect(() => {
    setHeader({ title, actions: actionsRef.current });
  }, [title, setHeader]);
}

export function useHeaderProps() {
  return useContext(HeaderContext).headerProps;
}
