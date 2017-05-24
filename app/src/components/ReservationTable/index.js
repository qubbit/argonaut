// @flow
import React, { Component } from 'react';
import moment from 'moment-timezone';
import { css, StyleSheet } from 'aphrodite';
import { Reservation as ReservationType } from '../../types';
import { userSettings } from '../../actions/session';
import { Link } from 'react-router';

const styles = StyleSheet.create({
  container: {
    flex: '1',
    padding: '10px 10px 0 10px',
    background: '#fff',
    overflowY: 'auto',
  }
});

type Props = {
  reservations: Array<ReservationType>
}

class ReservationTableHeader extends Component {
  render() {
  var environmentNames = this.props.environments.map(env => <th key={`environment-${env.name}-${env.id}`}>{env.name}</th>);
    return(
    <tr>
      <th>
      </th>
      {environmentNames}
    </tr>
    );
  }
}

function getReservation(app, env, reservations) {
  return reservations.find(r => r.application.id == app.id && r.environment.id == env.id)
}


class ReservationCell extends Component {
  constructor(props) {
    super(props);

    this.state = { reserved: false, hover: false }
  }

  update() {

  }

  onMouseOverHandler(e) {
    this.setState({ hover: true });
  }

  onMouseOutHandler(e) {
    this.setState({ hover: false });
  }

  doReserve = (e) => {
    const d = e.currentTarget.dataset;
    const data = {application_id: d.applicationId, environment_id: d.environmentId};
    this.props.eventHandlers.onReserveClick(data);
  }

  doRelease = (e) => {
    const d = e.currentTarget.dataset;
    const data = {reservation_id: d.reservationId};
    this.props.eventHandlers.onReleaseClick(data);
  }

  render() {
    const reservation = this.props.reservation;
    const application = this.props.application;
    const environment = this.props.environment;

    var user = { username: '', avatar_url: '' };
    var time = '';
    var reservationString = '';


    let releaseButton;

    var canRelease = reservation && (userSettings().is_admin || reservation.user.id === userSettings().id);

    if (canRelease) {
      releaseButton = <a href='#' className='tool-item'
                      data-application-id={application.id}
                      data-environment-id={environment.id}
                      data-reservation-id={reservation.id}
                      onClick={this.doRelease.bind(this)}>
                       <i className='fa fa-2x fa-unlock'></i>
                       <span className='tool-label'>Release</span>
                      </a>;
    }


    let reserveButton;

    var canReserve = reservation == null
    if(canReserve) {
      reserveButton = <a href='#' className='tool-item' data-application-id={application.id} data-environment-id={environment.id} onClick={this.doReserve.bind(this)}>
         <i className='fa fa-2x fa-lock'></i>
         <span className='tool-label'>Reserve</span>
       </a>;
    }

    if(reservation){
      user = reservation.user;

      time = moment(reservation.reserved_at).tz(userSettings.time_zone || 'America/New_York').format('MMMM D, h:mm a');
      reservationString = `${user.username} since ${time}`;
    }

    let visibilityClassName = 'hidden';

    if(this.state.hover) {
      visibilityClassName = 'not-hidden';
    }


    let reservationMeta;

    if(reservation) {
      reservationMeta = <div className='reservation-meta'>
        <img alt='Avatar' src={user.avatar_url} height="64"/>
        <span className='reservation-info'>
          {reservationString}
        </span>
        </div>
    }

    return (
     <td onMouseOut={this.onMouseOutHandler.bind(this)} onMouseOver={this.onMouseOverHandler.bind(this)} className={'reservation-cell ' + application.name + "-" + environment.name}>
       {reservationMeta}
       <div className={'toolbar ' + visibilityClassName}>
         {reserveButton}
         {releaseButton}
         <a href={`https://${environment.name}-${application.name}.testing.covermymeds.com/${application.ping}`} className='tool-item'>
           <i className='fa fa-2x fa-info'></i>
           <span className='tool-label'> Info</span>
         </a>
       </div>
     </td>
    );
  }
}

class ReservationRow extends Component {
  render() {
    const application = this.props.application;
    const environments = this.props.environments;
    const reservations = this.props.reservations;

    var x = 0;
    var cells = environments.map(env => {
      var key = "reservation-cell-" + (++x);
      const reservation = getReservation(application, env, reservations);
      return <ReservationCell key={key} reservation={reservation} application={application} environment={env} eventHandlers={this.props.eventHandlers}/>
    });

    return (
      <tr className={'application-row ' + application.name} key={application.name}>
        <td className='application-name'>
          <strong>{application.name}</strong>
          <div className='toolbar'>
            <span className='tool-item'>
              <a href={`https://git.innova-partners.com/${application.repo}`}>
                <i className='fa fa-github fa-2x'></i>
              </a>
            </span>
          </div>
        </td>
        {cells}
      </tr>
    );
  }
}

class ReservationTable extends Component {
  props: Props
  container: () => void

  constructor(props) {
    super(props)
    this.state = { user: userSettings() }
  }

  renderReservations() {
    var x = 0;

    const reservationRows = this.props.applications.map((app) => {
      return <ReservationRow key={"reservation-row-" + (++x)} reservations={this.props.reservations} application={app} environments={this.props.environments} eventHandlers={this.props.eventHandlers}/>
    });

    return(
      <table key='table' className='table table-bordered'>
        <thead>
          <ReservationTableHeader key={"reservation-table-header-0"} environments={this.props.environments}/>
        </thead>
        <tbody>
          {reservationRows}
        </tbody>
      </table>
    )
  }

  render() {
    let nodes = [];
    let hasApplications = true;
    let hasEnvironments = true;

    if(this.props.applications.length === 0) {
      hasApplications = false;
      nodes.push(<div key="noApplicationsMessage" className='disappointed'><h3>No applications to show 😞</h3></div>);
    }

    if(this.props.environments.length === 0) {
      hasEnvironments = false;
      nodes.push(<div key="noEnvironmentsMessage" className='disappointed'><h3>No environments to show 😢</h3></div>);
    }

    if(hasApplications && hasEnvironments) {
      nodes.push(this.renderReservations());
    } else if(this.props.team.owner_id === this.state.user.id) {
      nodes.push(<div key="add-stuff-link-container" className='disappointed'>
        <Link to={`/t/${this.props.team.id}/admin`} className="btn btn-sm">
          <h3>
            <i className='fa fa-wrench'></i> Go on and add them!
          </h3>
        </Link>
      </div>);
    }

    return <div className={css(styles.container)} ref={(c) => { this.container = c; }}>{nodes}</div>;
  }
}

export default ReservationTable;
