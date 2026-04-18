import { createSlice } from '@reduxjs/toolkit';

const flashSlice = createSlice({
  name: 'flash',
  initialState: { messages: [] },
  reducers: {
    addFlash(state, action) {
      // payload: { notice?: string, alert?: string }
      Object.entries(action.payload).forEach(([type, message]) => {
        if (message) {
          state.messages.push({ id: Date.now() + Math.random(), type, message });
        }
      });
    },
    dismissFlash(state, action) {
      state.messages = state.messages.filter(m => m.id !== action.payload);
    },
  },
});

export const { addFlash, dismissFlash } = flashSlice.actions;
export default flashSlice.reducer;
