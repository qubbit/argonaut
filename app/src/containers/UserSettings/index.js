// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Pagination } from '../../types';
import Navbar from '../../components/Navbar';
import UserProfileForm from '../../components/UserProfileForm';
import UserTeamSettings from '../../components/UserTeamSettings';
import UserPreferences from '../../components/UserPreferences';
import { updateUserProfile, vacationMode } from '../../actions/user';
import { css, StyleSheet } from 'aphrodite';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';

const styles = StyleSheet.create({
  card: {
    width: '720px',
    margin: '2rem auto'
  }
});

type Props = {
  params: {
    id: number
  },
  currentUser: Object,
  pagination: Pagination
}

class UserSettingsContainer extends Component {

  props: Props

  handleUserProfileUpdate = (data) => {
    Object.assign(data, {id: this.props.currentUser.id});
    this.props.updateUserProfile(data);
  }

  handleVacationMode = (user) => {
    this.props.vacationMode(this.props.currentUser.id);
  }

  render() {
    return (
      <div style={{ display: 'flex', flex: '1' }}>
        <div style={{ display: 'flex', flexDirection: 'column', flex: '1' }}>
          <Navbar/>
          <div className={`card ${css(styles.card)}`} style={{ display: 'flex', margin: '2em auto' }}>
            <div style={{ padding: '32px' }}>
              <Tabs>
                <TabList style={{ marginBottom: '32px' }}>
                  <Tab>
                    <i className="fa fa-user-circle-o" /> Profile
                  </Tab>
                  <Tab>
                    <i className="fa fa-adjust" /> Preferences
                  </Tab>
                  <Tab>
                    <i className="fa fa-users" /> Teams
                  </Tab>
                  <Tab>
                    <i className="fa fa-info-circle" /> About
                  </Tab>
                </TabList>

                <TabPanel>
                  <UserProfileForm user={this.props.currentUser} onSubmit={this.handleUserProfileUpdate} />
                </TabPanel>
                <TabPanel>
                  <UserPreferences user={this.props.currentUser} onVacationMode={this.handleVacationMode} />
                </TabPanel>
                <TabPanel>
                  <UserTeamSettings user={this.props.currentUser} teamEventHandlers={this.handleUserProfileUpdate} />
                </TabPanel>
                <TabPanel>
                  <div className='alert alert-info'>
                    <p>Shipping of Argonaut was made possible by <strong>Gopal Adhikari</strong>, and the following contributors.</p>
                    <ul>
                      <li>Matt Bramson </li>
                    </ul>
                    <ul>
                      <li>Your name here </li>
                    </ul>
                    <ul>
                      <li>Your name here</li>
                    </ul>
                    <ul>
                      <li>Your name here</li>
                    </ul>
                  </div>
                </TabPanel>
              </Tabs>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default connect( (state) => ({
    currentUser: state.session.currentUser,
    pagination: state.team.pagination,
    teams: state.teams
  }),
  { updateUserProfile, vacationMode }
)(UserSettingsContainer);
