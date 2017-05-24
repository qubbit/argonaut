// @flow
import React, { Component } from 'react';
import { Field, reduxForm } from 'redux-form';
import Input from '../Input';
import Select from '../Select';
import Errors from '../Errors';

type Props = {
  onSubmit: () => void,
  submitting: boolean,
  handleSubmit: () => void,
  errors: any,
}

class UserProfileForm extends Component {
  props: Props

  componentWillMount() {
    if (this.props.pristine) this.props.initialize(this.props.user);
  }

  componentWillUnmount() {
    if (this.props.pristine) this.props.destroy();
  }
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
      <form style={{ width: '640px' }} onSubmit={handleSubmit(this.handleSubmit)} >
        <div style={{ marginBottom: '1rem' }}>
          <label>Username</label>
          <Field
            name="username"
            type="text"
            component={Input}
          />
          <Errors name="username" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label>Password</label>
          <Field
            name="password"
            type="password"
            component={Input}
          />
          <Errors name="password" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label>Password confirmation</label>
          <Field
            name="password_confirmation"
            type="password"
            component={Input}
          />
          <Errors name="password_confirmation" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label>Email</label>
          <Field
            name="email"
            type="email"
            component={Input}
            text={this.state.user.email}
          />
          <Errors name="email" errors={errors} />
        </div>

        <hr style={{ margin: '2rem 0' }} />

        <div style={{ marginBottom: '1rem' }}>
          <label>Avatar URL</label>
          <Field
            name="avatar_url"
            type="text"
            component={Input}
            text={this.state.user.avatar_url}
          />
          <Errors name="avatar_url" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label>First name</label>
          <Field
            name="first_name"
            type="text"
            component={Input}
            text={this.state.user.first_name}
          />
          <Errors name="first_name" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label>Last name</label>
          <Field
            name="last_name"
            type="text"
            component={Input}
            text={this.state.user.last_name}
          />
          <Errors name="last_name" errors={errors} />
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label>Time zone</label>
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

let userProfileForm = reduxForm({
  form: 'userProfile',
  validate,
})(UserProfileForm);

export default userProfileForm;
