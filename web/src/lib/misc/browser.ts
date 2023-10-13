export default function isEnvBrowser(): boolean {
  return !(window as any).invokeNative;
}