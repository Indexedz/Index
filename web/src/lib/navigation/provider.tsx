import React, { createContext, useContext } from 'react';

interface NavigationContextType {
  currentPage: string;
  useNavigate: (page: string) => void;
}

interface NavigationProviderProps{
  children: React.ReactNode,
  default: string
}

const NavigationContext = createContext<NavigationContextType | undefined>(undefined);

export const useNavigation = () => {
  const context = useContext(NavigationContext);
  if (!context) {
    throw new Error('useNavigation must be used within a NavigationProvider');
  }
  return context;
}

export default function NavigationProvider(props: NavigationProviderProps) {
  const [currentPage, useNavigate] = React.useState<string>(props.default);

  const contextValue: NavigationContextType = {
    currentPage,
    useNavigate,
  };

  return (
    <NavigationContext.Provider value={contextValue}>
      {props.children}
    </NavigationContext.Provider>
  );
}
