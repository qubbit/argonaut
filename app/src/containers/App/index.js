// @flow
import React, { Component } from 'react';
import { BrowserRouter, Miss } from 'react-router';
import { connect } from 'react-redux';
import { authenticate, unauthenticate, logout } from '../../actions/session';
import Home from '../Home';
import NotFound from '../../components/NotFound';
import Login from '../Login';
import Signup from '../Signup';
import MatchAuthenticated from '../../components/MatchAuthenticated';
import RedirectAuthenticated from '../../components/RedirectAuthenticated';
import Sidebar from '../../components/Sidebar';
import Team from '../Team';
import TeamAdmin from '../TeamAdmin';
import UserSettingsContainer from '../UserSettings';
import Alert from '../Alert';
import { Team as TeamType } from '../../types';

type Props = {
  authenticate: () => void,
  unauthenticate: () => void,
  isAuthenticated: boolean,
  willAuthenticate: boolean,
  logout: () => void,
  currentUserTeams: Array<TeamType>,
}

class App extends Component {
  componentDidMount() {
    const token = localStorage.getItem('token');

    if (token) {
      this.props.authenticate();
    } else {
      this.props.unauthenticate();
    }
  }

  props: Props

  handleLogout = (router) => this.props.logout(router);

  render() {
    const { isAuthenticated, willAuthenticate, currentUserTeams } = this.props;
    const authProps = { isAuthenticated, willAuthenticate };

    return (
      <BrowserRouter>
        {({ router, location }) => (
          <div style={{ display: 'flex', flex: '1' }}>
            <Alert pathname={location.pathname} />
            {isAuthenticated &&
              <Sidebar
                router={router}
                teams={currentUserTeams}
                onLogoutClick={this.handleLogout}
              />
            }
            <MatchAuthenticated exactly pattern="/" component={Home} {...authProps} />
            <RedirectAuthenticated exactly pattern="/login" component={Login} {...authProps} />
            <RedirectAuthenticated exactly pattern="/signup" component={Signup} {...authProps} />
            <MatchAuthenticated exactly pattern="/t/:id" component={Team} {...authProps} />
            <MatchAuthenticated exactly pattern="/t/:id/admin" component={TeamAdmin} {...authProps} />
            <MatchAuthenticated exactly pattern="/settings" component={UserSettingsContainer} {...authProps} />
            <Miss component={NotFound} />
          </div>
        )}
      </BrowserRouter>
    );
  }
}

export default connect(
  (state) => ({
    isAuthenticated: state.session.isAuthenticated,
    willAuthenticate: state.session.willAuthenticate,
    currentUserTeams: state.teams.currentUserTeams,
  }),
  { authenticate, unauthenticate, logout }
)(App);
