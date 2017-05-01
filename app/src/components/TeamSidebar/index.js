// @flow
import React from 'react';
import { css, StyleSheet } from 'aphrodite';
import { Team, User } from '../../types';

const styles = StyleSheet.create({
  teamSidebar: {
    color: '#ab9ba9',
    background: '#4d394b',
  },

  header: {
    padding: '20px 15px',
    marginBottom: '10px',
    width: '220px',
  },

  teamName: {
    marginBottom: '0',
    fontSize: '22px',
    lineHeight: '1',
    color: '#fff',
  },

  userList: {
    paddingLeft: '15px',
    listStyle: 'none',
  },

  username: {
    position: 'relative',
    paddingLeft: '20px',
    fontSize: '14px',
    fontWeight: '300',
    ':after': {
      position: 'absolute',
      top: '7px',
      left: '0',
      width: '8px',
      height: '8px',
      borderRadius: '50%',
      background: 'rgb(64,151,141)',
      content: '""',
    },
  },

  listHeading: {
    marginLeft: '15px',
    marginBottom: '5px',
    fontSize: '13px',
    textTransform: 'uppercase',
  },
});

type Props = {
  team: Team,
  currentUser: User,
  presentUsers: Array<User>,
}

const TeamSidebar = ({ team, currentUser, presentUsers }: Props) =>
  <div className={css(styles.teamSidebar)}>
    <div className={css(styles.header)}>
      <h2 className={css(styles.teamName)}>{team.name}</h2>
      <div style={{ fontSize: '13px' }}>{currentUser.username}</div>
    </div>
    <div className={css(styles.listHeading)}>Active Users</div>
    <ul className={css(styles.userList)}>
      {presentUsers.map((user) =>
        <li key={user.id} className={css(styles.username)}>{user.username}</li>
      )}
    </ul>
  </div>;

export default TeamSidebar;
