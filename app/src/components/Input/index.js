// @flow
import React from 'react';

type Props = {
  input: Object,
  label?: string,
  type?: string,
  text: string,
  meta: Object,
  placeholder?: string,
  style?: Object,
  inputStyle?: Object,
  className?: string,
}

const Input = ({ input, label, type, text, placeholder, meta, style, inputStyle, className }: Props) => {
  text = text || ''

  return <div style={{ ...style }}>
    {label && <label htmlFor={input.name}>{label}</label>}
    <input
      {...input}
      type={type}
      placeholder={placeholder}
      style={{ ...inputStyle }}
      className={className || 'form-control'}
    />
    {meta.touched && meta.error &&
      <div style={{ fontSize: '85%', color: '#cc5454' }}>{meta.error}</div>
    }
  </div>;
}

export default Input;
