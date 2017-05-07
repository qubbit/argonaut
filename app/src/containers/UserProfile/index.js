// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Pagination } from '../../types';
import Navbar from '../../components/Navbar';
import UserProfileForm from '../../components/UserProfileForm';
import { updateUserProfile } from '../../actions/user';
type Props = {
  params: {
    id: number
  },
  currentUser: Object,
  pagination: Pagination
}

class UserProfileContainer extends Component {

  props: Props

  handleUserProfileUpdate = (data) => {
    Object.assign(data, {id: this.props.currentUser.id});
    this.props.updateUserProfile(data);
  }

  render() {
    return (
      <div style={{ display: 'flex', height: '100vh', flex: '1' }}>
        <div style={{ display: 'flex', flexDirection: 'column', flex: '1' }}>
          <Navbar/>
          <UserProfileForm user={this.props.currentUser} onSubmit={this.handleUserProfileUpdate} />
        </div>
      </div>
    );
  }
}

export default connect( (state) => ({
    currentUser: state.session.currentUser,
    pagination: state.team.pagination
  }),
  { updateUserProfile }
)(UserProfileContainer);
