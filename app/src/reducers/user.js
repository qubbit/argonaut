const initialState = {
  currentUser: {},
  updateProfileErrors: []
};

export default function (state = initialState, action) {
  switch (action.type) {
    case 'FETCH_USER_PROFILE_SUCCESS':
      return {
        ...state,
        currentUser: action.response.data
      };
    case 'UPDATE_USER_PROFILE_SUCCESS':
      return {
        ...state,
        currentUser: action.response.data,
      };
    case 'UPDATE_USER_PROFILE_FAILURE':
      return {
        ...state,
        updateProfileErrors: action.error.errors
      };
    default:
      return state;
  }
}
