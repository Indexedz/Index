import React from 'react';
import useEvent from './useEvent';

function useEState<T>(defaultValue: T, event: string): [
  state: T,
  setState: React.Dispatch<React.SetStateAction<T>>,
  isLoading: boolean
] {
  const [state, setState] = React.useState<T>(defaultValue);
  const [isLoading, setLoading] = React.useState<boolean>(true);

  useEvent(event, (data: T) => {
    setState(data);
    setLoading(false);
  });

  return [state, setState, isLoading]
}

export default useEState;
