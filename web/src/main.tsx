import React from 'react'
import ReactDOM from 'react-dom/client'
import NavigationProvider from './lib/navigation/provider'
import Route from './lib/navigation/route'
import './global.css'

/* PAGES */
import Primary from './pages/primary'
import SpawnLocation from './pages/spawn'
import LoadingPage from './pages/loading'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <NavigationProvider default="primary">
      <Route name="primary" element={<Primary />} />
      <Route name="spawnLocation" element={<SpawnLocation />} />
      <Route name="loading" element={<LoadingPage />} />
    </NavigationProvider>
  </React.StrictMode>,
)
