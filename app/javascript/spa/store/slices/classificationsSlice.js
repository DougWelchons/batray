import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

export const fetchClassifications = createAsyncThunk(
  'classifications/fetchAll',
  async (_, { rejectWithValue }) => {
    try {
      const response = await fetch('/api/v1/classifications', {
        headers: { 'Content-Type': 'application/json' },
      });

      if (!response.ok) throw new Error('Failed to fetch classifications');

      return await response.json();
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

const classificationsSlice = createSlice({
  name: 'classifications',
  initialState: {
    items: [],
    loading: false,
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchClassifications.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchClassifications.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload;
      })
      .addCase(fetchClassifications.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export default classificationsSlice.reducer;
