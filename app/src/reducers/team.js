const initialState = {
  channel: null,
  currentTeam: {},
  reservations: [],
  applications: [],
  environments: [],
  presentUsers: [],
  loadingReservations: false,
  pagination: {
    total_pages: 0,
    total_entries: 0,
    page_size: 0,
    page_number: 0,
  },
};

export default function (state = initialState, action) {
  switch (action.type) {
    case 'TEAM_CONNECTED_TO_CHANNEL':
      return {
        ...state,
        channel: action.channel,
        currentTeam: action.response.team,
        reservations: action.response.reservations,
        applications: action.response.applications,
        environments: action.response.environments,
        pagination: action.response.pagination,
      };
    case 'USER_LEFT_TEAM':
      return initialState;
    case 'RESERVATION_CREATED':
      return {
        ...state,
        reservations: [
          ...state.reservations,
          action.reservation,
        ],
      };
    case 'TEAM_PRESENCE_UPDATE':
      return {
        ...state,
        presentUsers: action.presentUsers,
      };
    case 'FETCH_RESERVATIONS_REQUEST':
      return {
        ...state,
        loadingReservations: true,
      };
    case 'FETCH_RESERVATIONS_SUCCESS':
      return {
        ...state,
        reservations: [
          ...action.response.data.reverse(),
          ...state.reservations,
        ],
        pagination: action.response.pagination,
        loadingReservations: false,
      };
    case 'FETCH_RESERVATIONS_FAILURE':
      return {
        ...state,
        loadingReservations: false,
      };
    case 'UPDATE_TEAM_SUCCESS':
      return {
        ...state,
        currentTeam: action.response.data,
      };
    default:
      return state;
  }
}
