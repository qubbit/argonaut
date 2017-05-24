import api from '../api';

export function fetchTeamTable(teamId) {
  return (dispatch) => {
    dispatch({type: 'FETCH_TEAM_RESERVATIONS_REQUEST' });
    return api.fetch(`/teams/${teamId}/table`, {})
    .then((response) => {
      dispatch({ type: 'FETCH_TEAM_RESERVATIONS_SUCCESS', response });
    })
    .catch(() => {
      dispatch({ type: 'FETCH_TEAM_RESERVATIONS_FAILURE' });
    });
  }
}

export function connectToChannel(socket, teamId) {
  return (dispatch) => {
    if (!socket) { return false; }
    const channel = socket.channel(`teams:${teamId}`);

    channel.on('reservation_created', (message) => {
      dispatch({ type: 'RESERVATION_CREATED', message });
    });

    channel.on('reservation_deleted', (message) => {
      dispatch({ type: 'RESERVATION_DELETED', message });
    });

    channel.join().receive('ok', (response) => {
      dispatch({ type: 'TEAM_CONNECTED_TO_CHANNEL', response, channel });
    });

    return false;
  };
}

export function leaveChannel(channel) {
  return (dispatch) => {
    if (channel) {
      channel.leave();
    }
    dispatch({ type: 'USER_LEFT_TEAM' });
  };
}

export function deleteReservation(channel, data) {
  return (dispatch) => new Promise((resolve, reject) => {
    channel.push('delete_reservation', data)
      .receive('error', () => reject());
  });
}

export function createReservation(channel, data) {
  return (dispatch) => new Promise((resolve, reject) => {
    channel.push('new_reservation', data)
      .receive('error', () => reject());
  });
}

export function updateTeam(teamId, data) {
  return (dispatch) => api.patch(`/teams/${teamId}`, data)
    .then((response) => {
      dispatch({ type: 'UPDATE_TEAM_SUCCESS', response });
    });
}

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

export function createTeamApplication(teamId, data) {
  return (dispatch) => api.post(`/teams/${teamId}/applications`, data)
    .then((response) => {
      dispatch({ type: 'CREATE_TEAM_APPLICATION_SUCCESS', response });
    })
    .catch((error) => {
      dispatch({ type: 'CREATE_TEAM_APPLICATION_FAILURE', error });
    });
}

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

export function createTeamEnvironment(teamId, data) {
  return (dispatch) => api.post(`/teams/${teamId}/environments`, data)
    .then((response) => {
      dispatch({ type: 'CREATE_TEAM_ENVIRONMENT_SUCCESS', response });
    })
    .catch((error) => {
      dispatch({ type: 'CREATE_TEAM_ENVIRONMENT_FAILURE', error });
    });
}

export function deleteTeamApplication(teamId, applicationId) {
  return (dispatch) => api.delete(`/teams/${teamId}/applications/${applicationId}`)
    .then((response) => {
      if(response.success) dispatch({ type: 'DELETE_TEAM_APPLICATION_SUCCESS', response });
    });
}

export function deleteTeamEnvironment(teamId, environmentId) {
  return (dispatch) => api.delete(`/teams/${teamId}/environments/${environmentId}`)
    .then((response) => {
      if(response.success) dispatch({ type: 'DELETE_TEAM_ENVIRONMENT_SUCCESS', response });
    });
}

