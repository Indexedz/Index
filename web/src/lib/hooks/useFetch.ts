import isEnvBrowser from "../misc/browser";

const Mirror = import.meta.env.VITE_MIRROR_NAME;
const options = {
  method: 'post',
  headers: {
    'Content-Type': 'application/json; charset=UTF-8',
  },
};

export default async function useFetch<T = any>(header: string, props?: any, mock?: T): Promise<T> {
  if (isEnvBrowser()) {
    return mock ? mock : (Promise.resolve() as Promise<T>);
  }

  const resourceName = Mirror ? Mirror : (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'nui-frame-app';

  const response = await fetch(`https://${resourceName}/${header}`, {
    ...options,
    body: JSON.stringify(props),
  })

  const data = await response.json();
  return data;
}
