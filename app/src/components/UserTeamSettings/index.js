// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import TeamListItem from '../TeamListItem';
import { joinTeam, leaveTeam } from '../../actions/teams';

class UserTeamSettings extends Component {

  handleTeamJoinOrLeave = (text, teamId) => {
    if(text === 'Leave') {
      return this.props.leaveTeam(teamId);
    }
    return this.props.joinTeam(teamId, this.context.router);
  }

  noTeamsMessage = () => {
    return <div className='alert alert-info'>
      You are not a member of any team. Click on the + button to the left to join one.
    </div>
  }

  render() {
    const currentUserTeamIds = this.props.currentUserTeams.map(t => t.id);
    const teamListNode = this.props.currentUserTeams.map((team) =>
      <TeamListItem
        key={team.id}
        team={team}
        currentUserTeamIds={currentUserTeamIds}
        currentUser={this.props.user}
        onTeamJoinOrLeave={this.handleTeamJoinOrLeave}
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
  { joinTeam, leaveTeam }
)(UserTeamSettings);
