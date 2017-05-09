// @flow
import React, { Component } from 'react';
import TeamListItem from '../TeamListItem';

class UserTeamSettings extends Component {

  render() {
    const teamListNode = this.props.teams.map((team) =>
      <TeamListItem
        key={team.id}
        team={team}
        onTeamJoin={this.handleTeamJoin}
        onTeamLeave={this.handleTeamLeave}
        currentUser={{}}
      />
    );
    return <div>{teamListNode}</div>;
  }
}

export default UserTeamSettings;
