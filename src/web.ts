import { WebPlugin } from '@capacitor/core';

import type { WidgetImageStorePlugin, WidgetImageStoreSaveOptions } from './definitions';

export class WidgetImageStoreWeb extends WebPlugin implements WidgetImageStorePlugin {
  async save(_options: WidgetImageStoreSaveOptions): Promise<{ path: string }> {
    void _options;
    throw this.unimplemented('save is not implemented on web.');
  }

  async delete(_options: { filename: string; appGroup: string }): Promise<void> {
    void _options;
    throw this.unimplemented('delete is not implemented on web.');
  }

  async list(_options: { appGroup: string }): Promise<{ files: string[] }> {
    void _options;
    throw this.unimplemented('list is not implemented on web.');
  }

  async deleteExcept(_options: { keep: string[]; appGroup: string }): Promise<void> {
    void _options;
    throw this.unimplemented('deleteExcept is not implemented on web.');
  }

  async exists(_options: { filename: string; appGroup: string }): Promise<{ exists: boolean }> {
    void _options;
    throw this.unimplemented('exists is not implemented on web.');
  }

  async getPath(_options: { filename: string; appGroup: string }): Promise<{ path: string }> {
    void _options;
    throw this.unimplemented('getPath is not implemented on web.');
  }
}
