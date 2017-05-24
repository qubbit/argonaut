import { reset } from 'redux-form';
import { Socket } from 'phoenix';
import api from '../api';
import { fetchUserTeams } from './teams';

const API_URL = process.env.REACT_APP_API_URL;
const WEBSOCKET_URL = API_URL.replace(/(https|http)/, 'ws').replace('/api', '');

function connectToSocket(dispatch) {
  const token = JSON.parse(localStorage.getItem('token'));
  const socket = new Socket(`${WEBSOCKET_URL}/socket`, {
    params: { guardian_token: token },
  });
  socket.connect();
  dispatch({ type: 'SOCKET_CONNECTED', socket });
}

function setCurrentUser(dispatch, response) {
  localStorage.setItem('token', JSON.stringify(response.meta.token));
  localStorage.setItem('currentUser', JSON.stringify(response.data));
  dispatch({ type: 'AUTHENTICATION_SUCCESS', response });
  dispatch(fetchUserTeams(response.data.id));
  connectToSocket(dispatch);
}

export function userSettings() {
  return JSON.parse(localStorage.getItem('currentUser'));
}

export function login(data, router) {
  return (dispatch) => api.post('/sessions', data)
    .then((response) => {
      setCurrentUser(dispatch, response);
      dispatch(reset('login'));
      router.transitionTo('/');
    })
    .catch((e) => {
      dispatch({ type: 'SHOW_ALERT', message: 'Invalid email or password' });
      console.error(e);
    });
}

export function signup(data, router) {
  return (dispatch) => api.post('/users', data)
    .then((response) => {
      setCurrentUser(dispatch, response);
      dispatch(reset('signup'));
      router.transitionTo('/');
    })
    .catch((error) => {
      dispatch({ type: 'SIGNUP_FAILURE', error });
    });
}

export function logout(router) {
  return (dispatch) => api.delete('/sessions')
    .then(() => {
      localStorage.removeItem('token');
      localStorage.removeItem('currentUser');
      dispatch({ type: 'LOGOUT' });
      router.transitionTo('/login');
    });
}

export function authenticate() {
  return (dispatch) => {
    dispatch({ type: 'AUTHENTICATION_REQUEST' });
    return api.post('/sessions/refresh')
      .then((response) => {
        setCurrentUser(dispatch, response);
      })
      .catch(() => {
        localStorage.removeItem('token');
        localStorage.removeItem('currentUser');
        window.location = '/login';
      });
  };
}

export const unauthenticate = () => ({ type: 'AUTHENTICATION_FAILURE' });
