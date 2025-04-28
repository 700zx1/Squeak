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
#1. Integrate a file picker into the Home Screen UI.
#2. Connect file selection to `ParsingService` for content extraction.
#3. Display parsed content in the main view.
#4. Enable TTS for all displayed content.
#5. Improve error handling and user feedback.
#6. Polish UI and add extra features as needed.

## Implemenation Steps continued.
1. previous steps 1-6 complete.  Now, build out settings page with needed settings including: TTS voices, quality, speed, other useful options.  Light dark mode toggle.
2. add TTS text highlighting to the main screen as text is read aloud.
3. change all references in code of "squeak_new" to "squeak" and adapt as needed to output a working code state.  Please consider the app to be named, "Squeak" officially.
4. update readme.md to current state.  Create new logo.  Build out how to install apk from releases page on GitHub.  Update features and usage section.  Be sure to note what languages and file types are supported.
---

_Last updated: 2025-04-27
