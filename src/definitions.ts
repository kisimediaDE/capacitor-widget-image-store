export interface WidgetImageStorePlugin {
  save(options: { base64: string; filename: string; appGroup: string; resize?: boolean }): Promise<{ path: string }>;
  delete(options: { filename: string; appGroup: string }): Promise<void>;
}
