import { WebPlugin } from '@capacitor/core';
import type { WidgetImageStorePlugin } from './definitions';

export class WidgetImageStoreWeb extends WebPlugin implements WidgetImageStorePlugin {
  async save(_options: { base64: string; filename: string; appGroup: string }): Promise<{ path: string }> {
    throw this.unimplemented('save is not implemented on web.');
  }

  async delete(_options: { filename: string; appGroup: string }): Promise<void> {
    throw this.unimplemented('delete is not implemented on web.');
  }

  async list(_options: { appGroup: string }): Promise<{ files: string[] }> {
    throw this.unimplemented('list is not implemented on web.');
  }

  async deleteExcept(_options: { keep: string[]; appGroup: string }): Promise<void> {
    throw this.unimplemented('deleteExcept is not implemented on web.');
  }

  async exists(_options: { filename: string; appGroup: string }): Promise<{ exists: boolean }> {
    throw this.unimplemented('exists is not implemented on web.');
  }

  async getPath(_options: { filename: string; appGroup: string }): Promise<{ path: string }> {
    throw this.unimplemented('getPath is not implemented on web.');
  }
}
