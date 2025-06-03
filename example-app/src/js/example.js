import { WidgetImageStore } from 'capacitor-widget-image-store';

const base64Default = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAIAAADTED8xAAADMElEQVR4nOzVwQnAIBQFQYXff81RUkQCOyDj1YOPnbXWPmeTRef+/3O/OyBjzh3CD95BfqICMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMO0TAAD//2Anhf4QtqobAAAAAElFTkSuQmCC"; // Beispiel-Daten oder reale Daten
const filenameDefault = "example-image.png"; // Beispiel-Dateiname
const appGroup = "group.de.kisimedia.WidgetImageStore"; // dein AppGroup-Identifier

document.getElementById('base64').value = base64Default;
document.getElementById('filename').value = filenameDefault;

const resultBox = document.getElementById('result');

window.saveImage = async () => {
  const filename = document.getElementById('filename').value;
  const base64 = document.getElementById('base64').value;
  const resize = document.getElementById('resize').checked;

  try {
    const res = await WidgetImageStore.save({ base64, filename, appGroup, resize });
    resultBox.textContent = `✅ Saved to: ${res.path}`;
  } catch (err) {
    resultBox.textContent = `❌ Error: ${err.message}`;
  }
};

window.deleteImage = async () => {
  const filename = document.getElementById('filename').value;
  const appGroup = 'group.de.kisimedia.WidgetImageStore';

  try {
    await WidgetImageStore.delete({ filename, appGroup });
    resultBox.textContent = `🗑️ Deleted: ${filename}`;
  } catch (err) {
    resultBox.textContent = `❌ Error: ${err.message}`;
  }
};