// @flow
import React, { Component } from 'react';

type Props = {
  onSubmit: () => void,
  submitting: boolean
}

class UserPreferences extends Component {
  props: Props

  render() {
    const { submitting } = this.props;

    return (<div style={{width: '640px' }}>
      <div className='alert alert-warning'>
        Use vacation mode to release all your reservations across all the teams.
      </div>
      <button className='btn'>Vacation Mode</button>
    </div>);
  }
}

export default UserPreferences;
