import api from '../api';

export function fetchUserProfile(params) {
  return (dispatch) => api.fetch('/profile', params)
    .then((response) => {
      dispatch({ type: 'FETCH_USER_PROFILE_SUCCESS', response });
    });
}

export function updateUserProfile(data, router) {
  return (dispatch) => api.patch(`/profile`, data)
    .then((response) => {
      dispatch({ type: 'UPDATE_USER_PROFILE_SUCCESS', response });
    })
    .catch((error) => {
      dispatch({ type: 'UPDATE_USER_PROFILE_FAILURE', error });
    });
}

export function vacationMode(userId) {
  return (dispatch) => api.post(`/users/${userId}/vacation`, {})
    .then((response) => {
      dispatch({ type: 'USER_VACATION_MODE_SUCCESS', response });
    });
}

