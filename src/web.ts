import { WebPlugin } from '@capacitor/core';

import type { WidgetImageStorePlugin } from './definitions';

export class WidgetImageStoreWeb extends WebPlugin implements WidgetImageStorePlugin {
  async save(_options: { base64: string; filename: string; appGroup: string }): Promise<{ path: string }> {
    throw this.unimplemented('Not implemented on web.');
  }
  async delete(_options: { filename: string; appGroup: string }): Promise<void> {
    throw this.unimplemented('Not implemented on web.');
  }
}
