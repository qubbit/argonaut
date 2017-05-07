const initialState = {
  all: [],
  currentTeamEnvironments: [],
  newEnvironmentErrors: [],
  pagination: {
    total_pages: 0,
    total_entries: 0,
    page_size: 0,
    page_number: 0
  },
};

export default function (state = initialState, action) {
  switch (action.type) {
    case 'FETCH_TEAM_ENVIRONMENTS_SUCCESS':
      return {
        ...state,
        currentTeamEnvironments: action.response.data
      };
    case 'FETCH_ENVIRONMENTS_SUCCESS':
      return {
        ...state,
        all: action.response.data,
        pagination: action.response.pagination
      };
    case 'CREATE_TEAM_ENVIRONMENT_SUCCESS':
      return {
        ...state,
        all: [
          action.response.data,
          ...state.all
        ],
        currentTeamEnvironments: [
          action.response.data,
          ...state.currentTeamEnvironments
        ],
        newEnvironmentErrors: []
      };
    case 'CREATE_TEAM_ENVIRONMENT_FAILURE':
      return {
        ...state,
        newEnvironmentErrors: action.error.errors
      };
    default:
      return state;
  }
}
