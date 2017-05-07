import api from '../api';

// fetch all environments for all teams
export function fetchEnvironments(params) {
  return (dispatch) => api.fetch('/environments', params)
    .then((response) => {
      dispatch({ type: 'FETCH_ENVIRONMENTS_SUCCESS', response });
    });
}

export function fetchTeamEnvironments(teamId) {
  return (dispatch) => api.fetch(`/teams/${teamId}/environments`)
    .then((response) => {
      dispatch({ type: 'FETCH_TEAM_ENVIRONMENTS_SUCCESS', response });
    });
}

export function createTeamEnvironment(teamId, data, router) {
  return (dispatch) => api.post(`/teams/${teamId}/environments`, data)
    .then((response) => {
      dispatch({ type: 'CREATE_TEAM_ENVIRONMENT_SUCCESS', response });
      router.transitionTo(`/t/${response.data.id}`);
    })
    .catch((error) => {
      dispatch({ type: 'CREATE_TEAM_ENVIRONMENT_FAILURE', error });
    });
}

