// @flow
import React from 'react';
import { Application } from '../../types';

type Props = {
  application: Application,
  onApplicationDelete: () => void
}

const ApplicationListItem = ({ application, onApplicationDelete }: Props) => {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
      <span style={{ marginRight: '8px' }}>{application.name}</span>
      <span className='applicationControls'>
        <button onClick={() => onApplicationDelete(application.id)} className="btn btn-sm btn-danger">
          <i className='fa fa-trash'></i> Delete
        </button>
      </span>
    </div>
  );
};

export default ApplicationListItem;
