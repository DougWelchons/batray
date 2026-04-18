import { configureStore } from '@reduxjs/toolkit';
import currentUserReducer from './slices/currentUserSlice';
import usersReducer from './slices/usersSlice';
import projectsReducer from './slices/projectsSlice';
import contractorsReducer from './slices/contractorsSlice';
import contactsReducer from './slices/contactsSlice';
import flashReducer from './slices/flashSlice';

export const store = configureStore({
  reducer: {
    currentUser: currentUserReducer,
    users: usersReducer,
    projects: projectsReducer,
    contractors: contractorsReducer,
    contacts: contactsReducer,
    flash: flashReducer,
  },
});

export default store;
