import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const getStats = () => api.get('/stats');
export const getSessions = () => api.get('/sessions');
export const getRooms = () => api.get('/rooms');
export const endSession = (id) => api.put(`/sessions/${id}/end`);
export const blockRoom = (id, message) => api.put(`/rooms/${id}/block`, { message });

export default api;