// @flow
import React, { Component } from 'react';
import { css, StyleSheet } from 'aphrodite';

const styles = StyleSheet.create({
  alert: {
    padding: '10% 20px',
    textAlign: 'center',
    fontSize: '3em'
  }
});

type Props = {
  timeout?: number,
  onClose: () => void,
};

class Loading extends Component {
  componentDidMount() {
    if (this.props.timeout) {
      setTimeout(this.props.onClose, this.props.timeout);
    }
  }

  props: Props

  render() {
    return (
      <div className={`fa-spin ${css(styles.alert)}`}>
        &#9096;
      </div>
    );
  }
}

export default Loading;
