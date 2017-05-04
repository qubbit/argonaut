// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import ReservationTable from '../../components/ReservationTable';
import TeamNavbar from '../../components/TeamNavbar';
import {
  connectToChannel,
  leaveChannel,
  createReservation,
  updateTeam,
} from '../../actions/team';
import { Application, Environment, Reservation, Pagination } from '../../types';

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
  reservations: Array<Reservation>,
  applications: Array<Application>,
  environments: Array<Environment>,
  currentUser: Object,
  pagination: Pagination,
  updateTeam: () => void,
}

class Team extends Component {
  componentDidMount() {
    this.props.connectToChannel(this.props.socket, this.props.params.id);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.id !== this.props.params.id) {
      this.props.leaveChannel(this.props.channel);
      this.props.connectToChannel(nextProps.socket, nextProps.params.id);
    }
    if (!this.props.socket && nextProps.socket) {
      this.props.connectToChannel(nextProps.socket, nextProps.params.id);
    }
  }

  componentWillUnmount() {
    this.props.leaveChannel(this.props.channel);
  }

  props: Props
  messageList: () => void

  handleMessageCreate = (data) => {
    this.props.createMessage(this.props.channel, data);
    this.messageList.scrollToBottom();
  }

  handleDescriptionUpdate = (data) => this.props.updateTeam(this.props.params.id, data);

  render() {
    return (
      <div style={{ display: 'flex', height: '100vh', flex: '1' }}>
        <div style={{ display: 'flex', flexDirection: 'column', flex: '1' }}>
          <TeamNavbar team={this.props.team} onDescriptionUpdate={this.handleDescriptionUpdate} />
          <ReservationTable
            reservations={this.props.reservations}
            applications={this.props.applications}
            environments={this.props.environments}
            ref={(c) => { this.messageList = c; }}
          />
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
    pagination: state.team.pagination,
    loadingReservations: state.team.loadingReservations,
  }),
  { connectToChannel, leaveChannel, createReservation, updateTeam }
)(Team);
