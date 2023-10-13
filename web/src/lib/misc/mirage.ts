import { Event } from "../hooks/useEvent";
import isEnvBrowser from "./browser";

export default class Mirage {
  private events: Event[] = [];
  private delay: boolean = true;

  constructor(events: Event | Event[]) {
    if (!isEnvBrowser()) return;

    this.events = Array.isArray(events) ? events : [events];
    setTimeout(() => this.delay = false, 1000);
  }

  /**
   * mirage
  */
  public async mirage() {
    if (!isEnvBrowser()) return;
    if (this.delay) await new Promise(resolve => setTimeout(resolve, 1000));

    this.events.map((event) => {
      const payload = { data: event }
      const message = new MessageEvent('message', payload)

      window.dispatchEvent(message)
    })
  }
}
