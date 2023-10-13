import React from "react"

export interface Event<T = unknown> {
  header: string,
  props: T
}

export default function useEvent<T = any>(header: string, cb: (props : T) => void) {
  const callback: React.MutableRefObject<(props: T) => void> = React.useRef(() => { })

  React.useEffect(() => {
    callback.current = cb
  }, [cb])

  React.useEffect(() => {
    const event = (event: MessageEvent<Event<T>>) => {
      const payload = event.data

      return (header == payload.header) ? (
        callback.current(payload.props)
      ) : null
    }

    window.addEventListener("message", event)
    return () => window.removeEventListener("message", event)
  }, [header])
}