// @flow
import React, { Component } from 'react';

type Props = {
  onSubmit: () => void,
  submitting: boolean,
  onVacationMode: () => void
}

class UserPreferences extends Component {
  props: Props

  render() {
    const { submitting, onVacationMode } = this.props;

    return (<div style={{width: '640px' }}>
      <div className='alert alert-warning'>
        Use vacation mode to release all your reservations across all the teams.
      </div>
      <button className='btn' disabled={submitting} onClick={onVacationMode}>Vacation Mode</button>
    </div>);
  }
}

export default UserPreferences;
