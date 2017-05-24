// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import TeamNavbar from '../../components/TeamNavbar';
import ApplicationListItem from '../../components/ApplicationListItem';
import EnvironmentListItem from '../../components/EnvironmentListItem';
import ApplicationForm from '../../components/ApplicationForm';
import EnvironmentForm from '../../components/EnvironmentForm';
import {
  fetchTeamTable,
  connectToChannel,
  leaveChannel,
  createReservation,
  deleteReservation,
  updateTeam,
  fetchTeamEnvironments,
  createTeamEnvironment,
  deleteTeamEnvironment,
  fetchTeamApplications,
  createTeamApplication,
  deleteTeamApplication
} from '../../actions/team';
import { Application, Environment, Pagination } from '../../types';

type Props = {
  team: Object,
  params: {
    id: number
  },
  applications: Array<Application>,
  environments: Array<Environment>,
  currentUser: Object,
  pagination: Pagination,
  updateTeam: () => void
}

class TeamAdmin extends Component {
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

  handleDescriptionUpdate = (data) => {
    this.props.updateTeam(this.props.params.id, data);
  }

  handleApplicationFormSubmit = (data) => {
    Object.assign(data, {team_id: this.props.params.id});
    this.props.createTeamApplication(this.props.params.id, data);
  }

  handleEnvironmentFormSubmit = (data) => {
    Object.assign(data, {team_id: this.props.params.id});
    this.props.createTeamEnvironment(this.props.params.id, data);
  }

  handleApplicationDelete = (applicationId) => {
    this.props.deleteTeamApplication(this.props.params.id, applicationId);
  }

  handleEnvironmentDelete = (environmentId) => {
    this.props.deleteTeamEnvironment(this.props.params.id, environmentId);
  }

  applicationList = () => {
    return this.props.applications.map(a => <ApplicationListItem key={`application-${a.id}`} application={a} onApplicationDelete={this.handleApplicationDelete}/>);
  }

  environmentList = () => {
    return this.props.environments.map(e => <EnvironmentListItem key={`environment-${e.id}`} environment={e} onEnvironmentDelete={this.handleEnvironmentDelete}/>);
  }

  render() {
    return (
      <div style={{ display: 'flex', flex: '1' }}>
        <div style={{ display: 'flex', flexDirection: 'column', flex: '1' }}>
          <TeamNavbar team={this.props.team} onDescriptionUpdate={this.handleDescriptionUpdate} />
          <div className='teamAdminSection' style={{ display: 'flex', justifyContent: 'space-around' }}>
            <section className='newAppEnvForms'>
              <ApplicationForm onSubmit={this.handleApplicationFormSubmit} />
              <EnvironmentForm onSubmit={this.handleEnvironmentFormSubmit} />
            </section>
            <section className='adminApplicationList'>
              <h3 className='adminSectionHeader'>Applications</h3>
              {this.applicationList()}
            </section>
            <section className='adminEnvironmentList'>
              <h3 className='adminSectionHeader'>Environments</h3>
              {this.environmentList()}
            </section>
          </div>
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
    pagination: state.team.pagination
  }),
  { fetchTeamTable, connectToChannel, leaveChannel, createReservation, deleteReservation, updateTeam, fetchTeamApplications, fetchTeamEnvironments, createTeamApplication, deleteTeamApplication, createTeamEnvironment, deleteTeamEnvironment }
)(TeamAdmin);
