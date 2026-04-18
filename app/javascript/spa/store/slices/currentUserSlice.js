import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

export const fetchCurrentUser = createAsyncThunk(
  'currentUser/fetch',
  async (_, { rejectWithValue }) => {
    try {
      const response = await fetch('/api/v1/current_user', {
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to fetch current user');
      }

      return await response.json();
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

const currentUserSlice = createSlice({
  name: 'currentUser',
  initialState: {
    data: null,
    loading: false,
    error: null,
  },
  reducers: {
    clearCurrentUser: (state) => {
      state.data = null;
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchCurrentUser.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchCurrentUser.fulfilled, (state, action) => {
        state.loading = false;
        state.data = action.payload;
      })
      .addCase(fetchCurrentUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export const { clearCurrentUser } = currentUserSlice.actions;
export default currentUserSlice.reducer;
