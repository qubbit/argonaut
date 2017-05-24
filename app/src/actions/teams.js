import api from '../api';

export function fetchTeams(params) {
  return (dispatch) => api.fetch('/teams', params)
    .then((response) => {
      dispatch({ type: 'FETCH_TEAMS_SUCCESS', response });
    });
}

export function fetchUserTeams(userId) {
  return (dispatch) => api.fetch(`/users/${userId}/teams`)
    .then((response) => {
      dispatch({ type: 'FETCH_USER_TEAMS_SUCCESS', response });
    });
}

export function createTeam(data, router) {
  return (dispatch) => api.post('/teams', data)
    .then((response) => {
      dispatch({ type: 'CREATE_TEAM_SUCCESS', response });
      router.transitionTo(`/t/${response.data.id}`);
    })
    .catch((error) => {
      dispatch({ type: 'CREATE_TEAM_FAILURE', error });
    });
}

export function joinTeam(teamId, router) {
  return (dispatch) => api.post(`/teams/${teamId}/join`)
    .then((response) => {
      dispatch({ type: 'TEAM_JOINED', response });
      router.transitionTo(`/t/${response.data.id}`);
    });
}

export function leaveTeam(teamId) {
  return (dispatch) => api.delete(`/teams/${teamId}/leave`)
    .then((response) => {
      dispatch({ type: 'TEAM_LEFT', response });
    });
}

export function deleteTeam(teamId) {
  return (dispatch) => api.delete(`/teams/${teamId}`)
    .then((response) => {
      dispatch({ type: 'TEAM_DELETED', response });
    });
}
