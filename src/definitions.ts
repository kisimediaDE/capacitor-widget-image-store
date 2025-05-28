export interface WidgetImageStorePlugin {
  save(options: { base64: string; filename: string; appGroup: string }): Promise<{ path: string }>;
}
