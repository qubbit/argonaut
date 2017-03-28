// @flow
import React, { Component } from 'react';
import moment from 'moment';
import { css, StyleSheet } from 'aphrodite';
import debounce from 'lodash/debounce';
import Reservation from '../Reservation';
import { Reservation as ReservationType } from '../../types';

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
  var environmentNames = this.props.environments.map(env => <ReservationTableHeaderCell environment={env} />);
    return(
    <tr>
      <th>
      </th>
      {environmentNames}
    </tr>
    );
  }
}

class ReservationCell extends Component {
  // const record = getReservation(application, environment);

  render() {
    return (
     <td className={this.props.application.name + "-" + this.props.environment.name}>
      <h1>hello</h1>
     </td>
    );
  }
}

class ReservationRow extends Component {
  render() {
    var application = this.props.application;
    var environments = this.props.environments;
    var x = 0;
    var cells = this.props.environments.map(env => {
      var key = "reservation-cell-" + (++x);
      return <ReservationCell key={x} application={application} environment={env} />
    });

    return (
      <tr className={application.name} key={application.name}>
        <td>{application.name}</td>
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
      return <ReservationRow key={"reservation-row-" + (++x)} application={app} environments={this.props.environments}/>
    });
    var y = 444;
    return(
      <table>
        <thead>
          <ReservationTableHeader key={"weidbas" + (++y)} environments={this.props.environments}/>
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
