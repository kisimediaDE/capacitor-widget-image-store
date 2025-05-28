export interface WidgetImageStorePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
