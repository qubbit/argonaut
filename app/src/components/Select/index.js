// @flow
import React from 'react';

type Props = {
  input: Object,
  label?: string,
  options: Array<Object>,
  meta: Object,
  style?: Object,
  inputStyle?: Object,
  className?: string,
}

const Select = ({ input, label, options, meta, style, inputStyle, className }: Props) => {
  options = options || []

  const optionTags = options.map(o => <option key={o.value} value={o.value}>{o.text}</option>);

  return <div style={{ ...style }}>
    {label && <label htmlFor={input.name}>{label}</label>}
    <select
      {...input}
      style={{ ...inputStyle }}
      className={className || 'form-control'}
    >
    { optionTags }
    </select>
    {meta.touched && meta.error &&
      <div style={{ fontSize: '85%', color: '#cc5454' }}>{meta.error}</div>
    }
  </div>
}

export default Select;
