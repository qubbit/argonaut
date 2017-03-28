// @flow
import React from 'react';
import moment from 'moment';
import Avatar from '../Avatar';
import { Reservation as ReservationType } from '../../types';

type Props = {
  reservation: ReservationType,
}

const Reservation = ({ reservation: { text, reserved_at, user } }: Props) =>
  <div style={{ display: 'flex', marginBottom: '10px' }}>
    <Avatar email={user.email} style={{ marginRight: '10px' }} />
    <div>
      <div style={{ lineHeight: '1.2' }}>
        <b style={{ marginRight: '8px', fontSize: '14px' }}>{user.username}</b>
        <time style={{ fontSize: '12px', color: 'rgb(192,192,192)' }}>{moment(reserved_at).format('h:mm A')}</time>
      </div>
      <div>{text}</div>
    </div>
  </div>;

export default Reservation;
