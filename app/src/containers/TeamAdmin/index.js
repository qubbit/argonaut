// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import TeamNavbar from '../../components/TeamNavbar';
import ApplicationForm from '../../components/ApplicationForm';
import EnvironmentForm from '../../components/EnvironmentForm';
import { updateTeam } from '../../actions/team';
import { fetchEnvironments, fetchTeamEnvironments, createTeamEnvironment } from '../../actions/environments';
import { fetchApplications, fetchTeamApplications, createTeamApplication } from '../../actions/applications';
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

  props: Props

  handleDescriptionUpdate = (data) => this.props.updateTeam(this.props.params.id, data);

  handleApplicationFormSubmit = (data) => {
    Object.assign(data, {team_id: this.props.params.id});
    this.props.createTeamApplication(this.props.params.id, data);
  }

  handleEnvironmentFormSubmit = (data) => {
    Object.assign(data, {team_id: this.props.params.id});
    this.props.createTeamEnvironment(this.props.params.id, data);
  }

  render() {
    return (
      <div style={{ display: 'flex', height: '100vh', flex: '1' }}>
        <div style={{ display: 'flex', flexDirection: 'column', flex: '1' }}>
          <TeamNavbar team={this.props.team} onDescriptionUpdate={this.handleDescriptionUpdate} />
          <ApplicationForm onSubmit={this.handleApplicationFormSubmit} />
          <EnvironmentForm onSubmit={this.handleEnvironmentFormSubmit} />
        </div>
      </div>
    );
  }
}

export default connect(
  (state) => ({
    team: state.team.currentTeam,
    applications: state.team.applications,
    environments: state.team.environments,
    currentUser: state.session.currentUser,
    pagination: state.team.pagination
  }),
  { updateTeam, fetchTeamApplications, fetchTeamEnvironments, createTeamApplication, createTeamEnvironment }
)(TeamAdmin);
