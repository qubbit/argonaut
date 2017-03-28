// @flow
import React from 'react';
import includes from 'lodash/includes';
import { Team } from '../../types';

type Props = {
  team: Team,
  currentUserTeamIds: Array<number>,
  onTeamJoin: () => void,
}

const TeamListItem = ({ team, currentUserTeamIds, onTeamJoin }: Props) => {
  const isJoined = includes(currentUserTeamIds, team.id);

  return (
    <div key={team.id} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
      <span style={{ marginRight: '8px' }}>{team.name}</span>
      <button
        onClick={() => onTeamJoin(team.id)}
        className="btn btn-sm"
        disabled={isJoined}
      >
        {isJoined ? 'Joined' : 'Join'}
      </button>
    </div>
  );
};

export default TeamListItem;
