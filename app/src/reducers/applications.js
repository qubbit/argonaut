const initialState = {
  all: [],
  currentTeamApplications: [],
  newApplicationErrors: [],
  pagination: {
    total_pages: 0,
    total_entries: 0,
    page_size: 0,
    page_number: 0
  },
};

export default function (state = initialState, action) {
  switch (action.type) {
    case 'FETCH_TEAM_APPLICATIONS_SUCCESS':
      return {
        ...state,
        currentTeamApplications: action.response.data
      };
    case 'FETCH_APPLICATIONS_SUCCESS':
      return {
        ...state,
        all: action.response.data,
        pagination: action.response.pagination
      };
    case 'CREATE_TEAM_APPLICATION_SUCCESS':
      debugger;
      return {
        ...state,
        all: [
          action.response,
          ...state.all
        ],
        currentTeamApplications: [
          action.response,
          ...state.currentTeamApplications
        ],
        newApplicationErrors: []
      };
    case 'CREATE_TEAM_APPLICATION_FAILURE':
      return {
        ...state,
        newApplicationErrors: action.error.errors
      };
    default:
      return state;
  }
}
