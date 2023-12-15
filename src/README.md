# FIT schedule maker plus
## Build prerequisites
- [flutter](https://docs.flutter.dev/get-started/install) (cli app)
- Internet connection
- Chrome or chromium-based browser (for dev version)
## Build and run
(git) Clone the project

    git clone https://github.com/FIT-schedule-maker-plus/FIT-schedule-maker-plus scheduler
    cd scheduler/src

(submitted archive) Make sure you are in the `src` directory. It should contain:
- `lib/`
- `web/`
- ...
    
Build and run with

    flutter run -d chrome --web-browser-flag "--disable-web-security" --release
    
For other chrome binaries:

    CHROME_EXECUTABLE="google-chrome-stable" flutter run -d chrome --web-browser-flag "--disable-web-security" --release

### Why the `"--disable-web-security"` flag?
Without this flag, the web scraping won't work because of CORS problems. We would have to solve this with help from our faculty first.

## Used Libraries
- [provider](https://pub.dev/packages/provider): ^6.0.5 
- [convert](https://pub.dev/packages/convert): ^3.1.1 
- [chaleno](https://pub.dev/packages/chaleno): ^0.0.6 
- [screenshot](https://pub.dev/packages/screenshot): ^2.1.0 
- [file_picker](https://pub.dev/packages/file_picker): ^6.1.1 


