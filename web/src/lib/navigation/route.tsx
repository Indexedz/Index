import React, { useMemo } from 'react'
import { useNavigation } from './provider'

interface RouteProps {
  name: string,
  element: React.ReactNode,

  nostatic?: boolean
}

function Route(route: RouteProps): React.ReactNode | null {
  const { currentPage } = useNavigation();
  const isVisible = useMemo(() => currentPage === route.name, [currentPage]);

  if (route?.nostatic) {
    return isVisible ? route.element : null
  }

  return (
    <div style={{
      display: isVisible ? 'block' : 'none'
    }}>
      {route.element}
    </div>
  )
}

export default React.memo(Route);
