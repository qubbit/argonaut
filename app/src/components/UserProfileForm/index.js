// @flow
import React, { Component } from 'react';
import { Field, reduxForm } from 'redux-form';
import { css, StyleSheet } from 'aphrodite';
import Input from '../Input';
import Select from '../Select';
import Errors from '../Errors';

const styles = StyleSheet.create({
  card: {
    width: '720px',
    padding: '3rem 4rem',
    margin: '2rem auto',
  },
});

type Props = {
  onSubmit: () => void,
  submitting: boolean,
  handleSubmit: () => void,
  errors: any,
}

class UserProfileForm extends Component {
  props: Props

  constructor(props) {
    super(props)

    this.state = { timeZones: [
      {value: 'America/Anchorage', text: 'Anchorage'},
      {value: 'America/Chicago', text: 'Chicago'},
      {value: 'America/Denver', text: 'Denver'},
      {value: 'America/Indianapolis', text: 'Indianapolis'},
      {value: 'America/Los_Angeles', text: 'Los Angeles'},
      {value: 'America/New_York', text: 'New York'},
      {value: 'America/Phoenix', text: 'Phoenix'},
      {value: 'America/Puerto_Rico', text: 'Puerto Rico'}
    ], user: this.props.user };
  }

  handleSubmit = (data) => this.props.onSubmit(data);

  render() {
    const { errors, handleSubmit, submitting } = this.props;

    return (
      <form
        className={`card ${css(styles.card)}`}
        onSubmit={handleSubmit(this.handleSubmit)}
      >
        <h3 style={{ marginBottom: '2rem', textAlign: 'center' }}>Profile</h3>

        <div style={{ marginBottom: '1rem' }}>
          <Field
            name="username"
            type="text"
            component={Input}
            placeholder="Username"
            text={this.state.user.username}
          />
          <Errors name="username" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <Field
            name="password"
            type="password"
            component={Input}
            placeholder="Password"
          />
          <Errors name="password" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <Field
            name="password_confirmation"
            type="password"
            component={Input}
            placeholder="Password Confirmation"
          />
          <Errors name="password_confirmation" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <Field
            name="email"
            type="email"
            component={Input}
            placeholder="Email"
            text={this.state.user.email}
          />
          <Errors name="email" errors={errors} />
        </div>

        <hr style={{ margin: '2rem 0' }} />

        <div style={{ marginBottom: '1rem' }}>
          <Field
            name="avatar_url"
            type="text"
            component={Input}
            placeholder="Avatar URL"
            text={this.state.user.avatar_url}
          />
          <Errors name="avatar_url" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <Field
            name="first_name"
            type="text"
            component={Input}
            placeholder="First name"
            text={this.state.user.first_name}
          />
          <Errors name="first_name" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <Field
            name="last_name"
            type="text"
            component={Input}
            placeholder="Last name"
            text={this.state.user.last_name}
          />
          <Errors name="last_name" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <Field
            name="time_zone"
            type="select"
            component={Select}
            options={this.state.timeZones}
            text={this.state.user.avatar_url}
          />
          <Errors name="last_name" errors={errors} />
        </div>

        <button
          type="submit"
          disabled={submitting}
          className="btn btn-primary"
        >
          {submitting ? 'Saving...' : 'Update'}
        </button>

      </form>
    );
  }
}

const validate = (values) => {
  const errors = {};

  if (!values.username) {
    errors.username = 'Required';
  }

  if (!values.email) {
    errors.email = 'Required';
  }

  if (values.password !== values.password_confirmation) {
    errors.password_confirmation = 'Password confirmation does not match';
  }

  return errors;
};

export default reduxForm({
  form: 'userProfile',
  validate,
})(UserProfileForm);
