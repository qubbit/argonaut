// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import TeamListItem from '../TeamListItem';
import { joinTeam, leaveTeam, deleteTeam } from '../../actions/teams';

class UserTeamSettings extends Component {

  handleTeamJoinOrLeave = (text, teamId) => {
    if(text === 'Leave') {
      return this.props.leaveTeam(teamId);
    }
    return this.props.joinTeam(teamId, this.context.router);
  }

  handleTeamDelete = (teamId) => {
    return this.props.deleteTeam(teamId);
  }

  noTeamsMessage = () => {
    return <div className='alert alert-info'>
      You are not a member of any team. Click on the + button on the sidebar to join one.
    </div>
  }

  render() {
    const currentUserTeamIds = this.props.currentUserTeams.map(t => t.id);
    const teamListNode = this.props.currentUserTeams.map((team) =>
      <TeamListItem
        key={team.id}
        team={team}
        onTeamJoinOrLeave={this.handleTeamJoinOrLeave}
        onTeamDelete={this.handleTeamDelete}
        currentUserTeamIds={currentUserTeamIds}
        currentUser={this.props.user}
      />
    );
    return <div style={{ width: '640px' }}>
      <div className='alert alert-warning'>
        The act of leaving a team is a destructive operation. When you leave a team, all your app:env reservations in the team will be cleared.
      </div>
        <div>
        {teamListNode.length > 0 ? teamListNode : this.noTeamsMessage()}
        </div>
      </div>;
  }
}

export default connect(
  (state) => ({
    teams: state.teams.all,
    currentUserTeams: state.teams.currentUserTeams,
  }),
  { joinTeam, leaveTeam, deleteTeam }
)(UserTeamSettings);
