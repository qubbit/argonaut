import api from '../api';

// fetch all applications for all teams
export function fetchApplications(params) {
  return (dispatch) => api.fetch('/applications', params)
    .then((response) => {
      dispatch({ type: 'FETCH_APPLICATIONS_SUCCESS', response });
    });
}

export function fetchTeamApplications(teamId) {
  return (dispatch) => api.fetch(`/teams/${teamId}/applications`)
    .then((response) => {
      dispatch({ type: 'FETCH_TEAM_APPLICATIONS_SUCCESS', response });
    });
}

export function createTeamApplication(teamId, data, router) {
  return (dispatch) => api.post(`/teams/${teamId}/applications`, data)
    .then((response) => {
      dispatch({ type: 'CREATE_TEAM_APPLICATION_SUCCESS', response });
      router.transitionTo(`/t/${response.data.id}`);
    })
    .catch((error) => {
      dispatch({ type: 'CREATE_TEAM_APPLICATION_FAILURE', error });
    });
}

