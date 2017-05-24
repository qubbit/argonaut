// @flow
import React, { Component } from 'react';
import { Field, reduxForm } from 'redux-form';
import { css, StyleSheet } from 'aphrodite';
import Input from '../Input';

const styles = StyleSheet.create({
  card: {
    maxWidth: '400px',
    padding: '20px',
    margin: '20px',
  },
});

type Props = {
  onSubmit: () => void,
  handleSubmit: () => void,
  submitting: boolean,
}

class ApplicationForm extends Component {
  props: Props

  handleSubmit = (data) => {
    this.props.onSubmit(data);
    this.props.reset();
  }

  render() {
    const { handleSubmit, submitting } = this.props;

    return (
      <form
        className={`card ${css(styles.card)}`}
        onSubmit={handleSubmit(this.handleSubmit)}
      >
        <h3 style={{ marginBottom: '2rem', textAlign: 'center' }}>Create application</h3>
        <Field name="name" type="text" component={Input} placeholder="Name" style={{ marginBottom: '1rem' }} />
        <Field name="ping" type="text" component={Input} placeholder="Ping" style={{ marginBottom: '1rem' }} />
        <Field name="repo" type="text" component={Input} placeholder="Repo" style={{ marginBottom: '1rem' }} />
        <button
          type="submit"
          disabled={submitting}
          className="btn btn-block btn-primary"
        >
          {submitting ? 'Saving...' : 'Create'}
        </button>
      </form>
    );
  }
}

const validate = (values) => {
  const errors = {};
  if (!values.name) {
    errors.name = 'Required';
  }
  return errors;
};

export default reduxForm({
  form: 'application',
  validate,
})(ApplicationForm);
