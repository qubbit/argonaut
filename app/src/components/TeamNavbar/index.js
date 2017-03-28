// @flow
import React, { Component } from 'react';
import { css, StyleSheet } from 'aphrodite';
import TopicForm from '../TopicForm';
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

  topicButton: {
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
  editingTopic: boolean,
}

type Props = {
  team: Team,
  onTopicUpdate: () => void,
}

class TeamNavbar extends Component {
  constructor(props: Props) {
    super(props);
    this.state = {
      editingTopic: false,
    };
  }

  state: State

  componentWillReceiveProps(nextProps: Props) {
    if (nextProps.team.id !== this.props.team.id ||
        nextProps.team.topic !== this.props.team.topic) {
      this.setState({ editingTopic: false });
    }
  }

  props: Props

  handleTopicUpdate = (data: { topic: string }) => this.props.onTopicUpdate(data);

  render() {
    const { team } = this.props;
    const { editingTopic } = this.state;

    return (
      <nav className={css(styles.navbar)}>
        <div>#{team.name}</div>
        <div className={css(styles.teamMeta)}>
          {editingTopic
            ?
              <TopicForm
                onSubmit={this.handleTopicUpdate}
                initialValues={{ topic: team.name }}
                onCancel={() => this.setState({ editingTopic: false })}
              />
            :
              <button
                className={css(styles.topicButton)}
                onClick={() => this.setState({ editingTopic: true })}
              >
                {team.name ? team.name : 'General chat and discussion'}
              </button>
          }
        </div>
      </nav>
    );
  }
}

export default TeamNavbar;
