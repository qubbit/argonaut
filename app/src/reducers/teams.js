const initialState = {
  all: [],
  currentUserTeams: [],
  newTeamErrors: [],
  pagination: {
    total_pages: 0,
    total_entries: 0,
    page_size: 0,
    page_number: 0,
  },
};

export default function (state = initialState, action) {
  switch (action.type) {
    case 'FETCH_TEAMS_SUCCESS':
      return {
        ...state,
        all: action.response.data,
        pagination: action.response.pagination,
      };
    case 'FETCH_USER_TEAMS_SUCCESS':
      return {
        ...state,
        currentUserTeams: action.response.data,
      };
    case 'CREATE_TEAM_SUCCESS':
      return {
        ...state,
        all: [
          action.response.data,
          ...state.all,
        ],
        currentUserTeams: [
          ...state.currentUserTeams,
          action.response.data,
        ],
        newTeamErrors: [],
      };
    case 'CREATE_TEAM_FAILURE':
      return {
        ...state,
        newTeamErrors: action.error.errors,
      };
    case 'TEAM_JOINED':
      return {
        ...state,
        currentUserTeams: [
          ...state.currentUserTeams,
          action.response.data,
        ],
      };
    case 'TEAM_LEFT':
      const team = action.response.data;
      const filtered = state.currentUserTeams.filter(t => t.id !== team.id)

      return {
        ...state,
        currentUserTeams: [
          ...filtered
        ]
      };
    case 'TEAM_DELETED':
      const team_id = action.response.id;
      const filteredUserTeams = state.currentUserTeams.filter(t => t.id !== team_id)
      const filteredAllTeams = state.all.filter(t => t.id !== team_id)

      return {
        ...state,
        all: [
          ...filteredAllTeams
        ],
        currentUserTeams: [
          ...filteredUserTeams
        ]
      };
    default:
      return state;
  }
}
