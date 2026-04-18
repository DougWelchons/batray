import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { fetchContacts } from './contactsSlice';

export const fetchContractors = createAsyncThunk(
  'contractors/fetchAll',
  async (_, { rejectWithValue }) => {
    try {
      const response = await fetch('/api/v1/contractors', {
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to fetch contractors');
      }

      return await response.json();
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const fetchContractor = createAsyncThunk(
  'contractors/fetchOne',
  async (id, { rejectWithValue, dispatch }) => {
    try {
      const response = await fetch(`/api/v1/contractors/${id}`, {
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to fetch contractor');
      }

      const contractor = await response.json();
      dispatch(fetchContacts(id));
      return contractor;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const createContractor = createAsyncThunk(
  'contractors/create',
  async (contractorData, { rejectWithValue }) => {
    try {
      const response = await fetch('/api/v1/contractors', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ contractor: contractorData }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.errors?.join(', ') || 'Failed to create contractor');
      }

      return await response.json();
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const updateContractor = createAsyncThunk(
  'contractors/update',
  async ({ id, contractorData }, { rejectWithValue }) => {
    try {
      const response = await fetch(`/api/v1/contractors/${id}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ contractor: contractorData }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.errors?.join(', ') || 'Failed to update contractor');
      }

      return await response.json();
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const deleteContractor = createAsyncThunk(
  'contractors/delete',
  async (id, { rejectWithValue }) => {
    try {
      const response = await fetch(`/api/v1/contractors/${id}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to delete contractor');
      }

      return id;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

const contractorsSlice = createSlice({
  name: 'contractors',
  initialState: {
    items: [],
    loading: false,
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      // Fetch all contractors
      .addCase(fetchContractors.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchContractors.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload;
      })
      .addCase(fetchContractors.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      // Fetch single contractor
      .addCase(fetchContractor.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchContractor.fulfilled, (state, action) => {
        state.loading = false;
        const index = state.items.findIndex((contractor) => contractor.id === action.payload.id);
        if (index !== -1) {
          state.items[index] = action.payload;
        } else {
          state.items.push(action.payload);
        }
      })
      .addCase(fetchContractor.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      // Create contractor
      .addCase(createContractor.fulfilled, (state, action) => {
        state.items.push(action.payload);
      })
      // Update contractor
      .addCase(updateContractor.fulfilled, (state, action) => {
        const index = state.items.findIndex((contractor) => contractor.id === action.payload.id);
        if (index !== -1) {
          state.items[index] = action.payload;
        }
      })
      // Delete contractor
      .addCase(deleteContractor.fulfilled, (state, action) => {
        state.items = state.items.filter((contractor) => contractor.id !== action.payload);
      });
  },
});

export default contractorsSlice.reducer;
