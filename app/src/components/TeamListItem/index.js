// @flow
import React from 'react';
import includes from 'lodash/includes';
import { Team } from '../../types';
import { Link } from 'react-router';

type Props = {
  team: Team,
  currentUserTeamIds: Array<number>,
  currentUser: User,
  onTeamJoin: () => void
}

const TeamListItem = ({ team, currentUserTeamIds, currentUser, onTeamJoin }: Props) => {
  const isJoined = includes(currentUserTeamIds, team.id);

  let adminButton;

  if(team.owner_id === currentUser.id) {
      adminButton = <Link to={`/t/${team.id}/admin`} className="btn btn-sm">
        <i className='fa fa-wrench'></i> Admin
      </Link>
  }

  return (
    <div key={team.id} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
      <span style={{ marginRight: '8px' }}>{team.name}</span>
      <span className='roomControls'>
        {adminButton}
        <button
          onClick={() => onTeamJoin(team.id)}
          className="btn btn-sm"
          disabled={isJoined}
        >
          {isJoined ? 'Joined' : 'Join'}
        </button>
      </span>
    </div>
  );
};

export default TeamListItem;
