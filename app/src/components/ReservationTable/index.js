// @flow
import React, { Component } from 'react';
import moment from 'moment-timezone';
import { css, StyleSheet } from 'aphrodite';
import debounce from 'lodash/debounce';
//import Reservation from '../Reservation';
import { Reservation as ReservationType } from '../../types';
import { userSettings } from '../../actions/session';

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

class ReservationTableHeaderCell extends Component {
  render() {
    return (
      <th>{this.props.environment.name}</th>
    )
  }
}

class ReservationTableHeader extends Component {
  render() {
  var environmentNames = this.props.environments.map(env => <ReservationTableHeaderCell key={`reservation-table-header-cell-${env.id}`} environment={env} />);
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
  return reservations.find(r => r.application.id === app.id && r.environment.id === env.id)
}


class ReservationCell extends Component {
  constructor(props) {
    super(props);

    this.state = { reserved: false, hover: false }
  }

  update() {

  }

  reserve() {
    console.log('reserving');
  }

  release() {
    console.log('releasing');
  }

  onMouseOverHandler(e) {
    this.setState({ hover: true });
  }

  onMouseOutHandler(e) {
    this.setState({ hover: false });
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
      releaseButton = <a href='#' className='tool-item' onClick={this.release}>
         <i className='fa fa-2x fa-unlock'></i>
         <span className='tool-label'>Release</span>
       </a>;
    }


    let reserveButton;

    var canReserve = reservation == null
    if(canReserve) {
      reserveButton = <a href='#' className='tool-item' onClick={this.reserve}>
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
        <img alt='Avatar' src={user.avatar_url} />
        <span className='reservation-info'>
          <strong>{reservationString}</strong>
        </span>
        </div>
    }

    return (
     <td onMouseOut={this.onMouseOutHandler.bind(this)} onMouseOver={this.onMouseOverHandler.bind(this)} className={'reservation-cell ' + application.name + "-" + environment.name}>
       {reservationMeta}
       <div className={'toolbar ' + visibilityClassName}>
         {reserveButton}
         {releaseButton}
         <a href={`https://${application.name}.covermymeds.com/${application.ping}`} className='tool-item'>
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
      return <ReservationCell key={key} reservation={reservation} application={application} environment={env} />
    });

    return (
      <tr className={application.name} key={application.name}>
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
  constructor(props: Props) {
    super(props);
    this.handleScroll = debounce(this.handleScroll, 200);
  }

  componentDidMount() {
    this.container.addEventListener('scroll', this.handleScroll);
  }

  componentWillReceiveProps(nextProps: Props) {
    if (nextProps.reservations.length !== this.props.reservations.length) {
      this.maybeScrollToBottom();
    }
  }

  componentWillUnmount() {
    this.container.removeEventListener('scroll', this.handleScroll);
  }

  props: Props
  container: () => void

  maybeScrollToBottom = () => {
    if (this.container.scrollHeight - this.container.scrollTop <
        this.container.clientHeight + 50) {
      this.scrollToBottom();
    }
  }

  scrollToBottom = () => {
    setTimeout(() => { this.container.scrollTop = this.container.scrollHeight; });
  }

  handleScroll = () => {
    if (this.props.moreMessages && this.container.scrollTop < 20) {
      this.props.onLoadMore();
    }
  }


  renderReservations() {
    var x = 0;

    const reservationRows = this.props.applications.map((app) => {
      return <ReservationRow key={"reservation-row-" + (++x)} reservations={this.props.reservations} application={app} environments={this.props.environments}/>
    });

    return(
      <table className='table table-bordered'>
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
    return (
      <div className={css(styles.container)} ref={(c) => { this.container = c; }}>
        {this.renderReservations()}
      </div>
    );
  }
}

export default ReservationTable;
