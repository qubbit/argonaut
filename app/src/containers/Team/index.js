// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import ReservationTable from '../../components/ReservationTable';
import TeamNavbar from '../../components/TeamNavbar';
import Loading from '../../components/Loading';
import {
  fetchTeamTable,
  connectToChannel,
  leaveChannel,
  createReservation,
  deleteReservation,
  updateTeam,
} from '../../actions/team';
import { Application, Environment, Reservation } from '../../types';

type Props = {
  socket: any,
  channel: any,
  team: Object,
  params: {
    id: number,
  },
  connectToChannel: () => void,
  leaveChannel: () => void,
  createReservation: () => void,
  deleteReservation: () => void,
  reservations: Array<Reservation>,
  applications: Array<Application>,
  environments: Array<Environment>,
  currentUser: Object,
  updateTeam: () => void,
}

class Team extends Component {
  componentWillMount() {
    this.props.fetchTeamTable(this.props.params.id);
  }
  componentDidMount() {
    this.props.connectToChannel(this.props.socket, this.props.params.id);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.id !== this.props.params.id) {
      this.props.leaveChannel(this.props.channel);
      this.props.connectToChannel(nextProps.socket, nextProps.params.id);
      this.props.fetchTeamTable(nextProps.params.id);
    }
    if (!this.props.socket && nextProps.socket) {
      this.props.connectToChannel(nextProps.socket, nextProps.params.id);
      this.props.fetchTeamTable(nextProps.params.id);
    }
  }

  componentWillUnmount() {
    this.props.leaveChannel(this.props.channel);
  }

  props: Props
  reservationList: () => void

  handleReservation = (data) => {
    console.log('handleReservation');
    this.props.createReservation(this.props.channel, data);
  }

  handleRelease = (data) => {
    console.log('handleRelease');
    this.props.deleteReservation(this.props.channel, data);
  }

  handleDescriptionUpdate = (data) => this.props.updateTeam(this.props.params.id, data);

  render() {
    const eventHandlers = { onReserveClick: this.handleReservation, onReleaseClick: this.handleRelease }
    return (
      <div style={{ display: 'flex', flex: '1' }}>
        <div style={{ display: 'flex', flexDirection: 'column', flex: '1' }}>
          <TeamNavbar team={this.props.team} onDescriptionUpdate={this.handleDescriptionUpdate} />
          { this.props.loadingReservations ? <Loading/> : <ReservationTable
            reservations={this.props.reservations}
            applications={this.props.applications}
            environments={this.props.environments}
            team={this.props.team}
            eventHandlers={eventHandlers}
            ref={(c) => { this.reservationList = c; }}
          /> }
        </div>
      </div>
    );
  }
}

export default connect(
  (state) => ({
    team: state.team.currentTeam,
    socket: state.session.socket,
    channel: state.team.channel,
    reservations: state.team.reservations,
    applications: state.team.applications,
    environments: state.team.environments,
    presentUsers: state.team.presentUsers,
    currentUser: state.session.currentUser,
    loadingReservations: state.team.loadingReservations,
  }),
  { fetchTeamTable, connectToChannel, leaveChannel, createReservation, deleteReservation, updateTeam }
)(Team);
