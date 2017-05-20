// @flow
import React from 'react';
import { Environment } from '../../types';

type Props = {
  environment: Environment,
  onEnvironmentDelete: () => void
}

const EnvironmentListItem = ({ environment, onEnvironmentDelete }: Props) => {

  return (
    <div key={environment.id} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
      <span style={{ marginRight: '8px' }}>{environment.name}</span>
      <span className='environmentControls'>
        <button onClick={() => onEnvironmentDelete(environment.id)} className="btn btn-sm">
          <i className='fa fa-trash'></i> Delete
        </button>
      </span>
    </div>
  );
};

export default EnvironmentListItem;
