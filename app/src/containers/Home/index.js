// @flow
import React, { Component, PropTypes } from 'react';
import { connect } from 'react-redux';
import { css, StyleSheet } from 'aphrodite';
import { fetchTeams, createTeam, joinTeam, leaveTeam, deleteTeam } from '../../actions/teams';
import NewTeamForm from '../../components/NewTeamForm';
import Navbar from '../../components/Navbar';
import TeamListItem from '../../components/TeamListItem';
import Pager from '../../components/Pager';
import { Team, Pagination } from '../../types';
import { userSettings } from '../../actions/session';

const styles = StyleSheet.create({
  card: {
    maxWidth: '500px',
    padding: '3rem 4rem',
    margin: '2rem auto',
  },
});

type Props = {
  teams: Array<Team>,
  currentUserTeams: Array<Team>,
  fetchTeams: () => void,
  createTeam: () => void,
  joinTeam: () => void,
  leaveTeam: () => void,
  newTeamErrors: Array<string>,
  pagination: Pagination,
}

type State = {
  page: number,
  page_size: number,
}

class Home extends Component {
  static contextTypes = {
    router: PropTypes.object,
  }

  constructor(props: Props) {
    super(props);
    this.state = {
      page: 1,
      page_size: 5,
    };
  }

  state: State

  componentDidMount() {
    this.loadTeams();
  }

  props: Props

  loadTeams() {
    const { page, page_size } = this.state;
    this.props.fetchTeams({ page, page_size });
  }

  handlePagerClick = (direction) => {
    if (direction === 'next') {
      this.setState({
        page: this.state.page + 1,
      }, () => { this.loadTeams(); });
    } else if (direction === 'prev') {
      this.setState({
        page: this.state.page - 1,
      }, () => { this.loadTeams(); });
    }
  }

  handleNewTeamSubmit = (data) => this.props.createTeam(data, this.context.router);

  handleTeamJoinOrLeave = (text, teamId) => {
    if(text.trim() === 'Leave') {
      return this.props.leaveTeam(teamId);
    }
    return this.props.joinTeam(teamId, this.context.router);
  }

  handleTeamDelete = (teamId) => {
    return this.props.deleteTeam(teamId);
  }

  renderTeams() {
    const currentUserTeamIds = [];
    this.props.currentUserTeams.map((team) => currentUserTeamIds.push(team.id));

    return this.props.teams.map((team) =>
      <TeamListItem
        key={team.id}
        team={team}
        onTeamJoinOrLeave={this.handleTeamJoinOrLeave}
        onTeamDelete={this.handleTeamDelete}
        currentUserTeamIds={currentUserTeamIds}
        currentUser={userSettings()}
      />
    );
  }

  render() {
    const allowNewTeamCreation = true;
    let newTeamFormContainer;
    if(allowNewTeamCreation) {
        newTeamFormContainer = <div className={`card ${css(styles.card)}`}>
          <h3 style={{ marginBottom: '2rem', textAlign: 'center' }}>Create a new team</h3>
          <NewTeamForm onSubmit={this.handleNewTeamSubmit} errors={this.props.newTeamErrors} />
        </div>
    }
    return (
      <div style={{ flex: '1', overflowY: 'auto' }}>
        <Navbar />
        { newTeamFormContainer }
        <div className={`card ${css(styles.card)}`}>
          <h3 style={{ marginBottom: '2rem', textAlign: 'center' }}>Join a team</h3>
          <div style={{ marginBottom: '1rem' }}>
            {this.renderTeams()}
          </div>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <Pager pagination={this.props.pagination} onPagerClick={this.handlePagerClick} />
          </div>
        </div>
      </div>
    );
  }
}

export default connect(
  (state) => ({
    teams: state.teams.all,
    currentUserTeams: state.teams.currentUserTeams,
    newTeamErrors: state.teams.newTeamErrors,
    pagination: state.teams.pagination,
  }),
  { fetchTeams, createTeam, joinTeam, leaveTeam, deleteTeam }
)(Home);
