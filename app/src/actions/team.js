import { reset } from 'redux-form';
import api from '../api';

export function connectToChannel(socket, teamId) {
  return (dispatch) => {
    if (!socket) { return false; }
    const channel = socket.channel(`teams:${teamId}`);

    channel.on('reservation_created', (message) => {
      dispatch({ type: 'RESERVATION_CREATED', message });
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
      .receive('ok', () => resolve(
        dispatch(reset('deletedReservation'))
      ))
      .receive('error', () => reject());
  });
}

export function createReservation(channel, data) {
  return (dispatch) => new Promise((resolve, reject) => {
    channel.push('new_reservation', data)
      .receive('ok', () => resolve(
        dispatch(reset('newReservation'))
      ))
      .receive('error', () => reject());
  });
}

export function updateTeam(teamId, data) {
  return (dispatch) => api.patch(`/teams/${teamId}`, data)
    .then((response) => {
      dispatch({ type: 'UPDATE_TEAM_SUCCESS', response });
    });
}
