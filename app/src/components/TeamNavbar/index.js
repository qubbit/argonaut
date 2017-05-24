// @flow
import React, { Component } from 'react';
import { css, StyleSheet } from 'aphrodite';
import DescriptionForm from '../DescriptionForm';
import { Team } from '../../types';

const styles = StyleSheet.create({
  navbar: {
    padding: '15px',
    background: '#fff',
    borderBottom: '1px solid rgb(240,240,240)',
  },

  teamMeta: {
    display: 'flex',
    alignItems: 'center',
    fontSize: '12px',
    height: '24px',
  },

  descriptionButton: {
    padding: '2px 4px',
    color: 'rgb(120,120,120)',
    background: 'transparent',
    border: '0',
    borderRadius: '4px',
    cursor: 'pointer',
    ':hover': {
      boxShadow: '0 0 2px rgba(0,0,0,.25)',
    },
  },
});

type State = {
  editingDescription: boolean,
}

type Props = {
  team: Team,
  onDescriptionUpdate: () => void,
}

class TeamNavbar extends Component {
  constructor(props: Props) {
    super(props);
    this.state = {
      editingDescription: false,
    };
  }

  state: State

  componentWillReceiveProps(nextProps: Props) {
    if (nextProps.team.id !== this.props.team.id ||
        nextProps.team.description !== this.props.team.description) {
      this.setState({ editingDescription: false });
    }
  }

  props: Props

  handleDescriptionUpdate = (data: { description: string }) => this.props.onDescriptionUpdate(data);

  render() {
    const { team } = this.props;
    const { editingDescription } = this.state;

    return (
      <nav className={css(styles.navbar)}>
        <div><h4>{team.name}</h4></div>
        <div className={css(styles.teamMeta)}>
          {editingDescription
            ?
              <DescriptionForm
                onSubmit={this.handleDescriptionUpdate}
                initialValues={{ description: team.description }}
                onCancel={() => this.setState({ editingDescription: false })}
              />
            :
              <button
                className={css(styles.descriptionButton)}
                onClick={() => this.setState({ editingDescription: true })}
              >
                {team.description ? team.description : 'Click here to edit description'}
              </button>
          }
        </div>
      </nav>
    );
  }
}

export default TeamNavbar;
