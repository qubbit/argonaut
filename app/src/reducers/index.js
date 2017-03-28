import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';
import session from './session';
import teams from './teams';
import team from './team';
import alert from './alert';

const appReducer = combineReducers({
  form,
  session,
  teams,
  team,
  alert,
});

export default function (state, action) {
  if (action.type === 'LOGOUT') {
    return appReducer(undefined, action);
  }
  return appReducer(state, action);
}
