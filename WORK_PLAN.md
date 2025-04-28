# Squeak Project Work Plan

## Intended Real Features

### 1. Open and Parse Files
- Allow users to select PDF, EPUB, HTML, or plain text files from their device.
- Use `ParsingService` to extract and display the file contents in the app.

### 2. Read Aloud Any Parsed Content
- Enable text-to-speech (TTS) for all parsed content (not just shared text).
- Add controls for play, pause, and stop TTS playback.

### 3. Share/Receive Content
- Continue supporting sharing from other apps (Android/iOS share intent).
- Display shared content and allow it to be read aloud.

### 4. Error Handling
- Notify users if a file cannot be parsed or if an unsupported format is selected.
- Provide clear feedback for parsing failures or TTS errors.

### 5. UI Improvements
- Add buttons for file selection and TTS controls.
- (Optional) Add features like history, favorites, or settings for TTS preferences.

---

## Implementation Steps
1. Integrate a file picker into the Home Screen UI.
2. Connect file selection to `ParsingService` for content extraction.
3. Display parsed content in the main view.
4. Enable TTS for all displayed content.
5. Improve error handling and user feedback.
6. Polish UI and add extra features as needed.

---

_Last updated: 2025-04-26_
