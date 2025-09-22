# Upload Progress Notification System

This system provides real-time upload progress notifications across all platforms (Android, iOS, macOS, Linux, Windows) using `flutter_local_notifications`.

## Features

- **Real-time Progress**: Shows upload progress from 0% to 100%
- **Multi-file Support**: Displays current file being uploaded (e.g., "Uploading File 2 of 5")
- **Platform Support**: Works on Android, iOS, macOS, Linux, and Windows
- **Progress Bar**: Android shows native progress bar in notifications
- **Completion Notifications**: Success and error notifications with sound
- **Persistent Notifications**: Progress notifications stay visible during upload

## Implementation

### 1. Dependencies

The following dependency is already added to `pubspec.yaml`:

```yaml
dependencies:
  flutter_local_notifications: ^19.4.2
```

### 2. Notification Service

The `NotificationService` class (`lib/service/notification_service.dart`) handles all notification operations:

- **Initialization**: Sets up notification channels and permissions
- **Progress Updates**: Updates notification with current progress
- **Completion**: Shows success/error notifications
- **Platform Support**: Handles platform-specific notification settings

### 3. Integration

The notification system is integrated into the upload process in `lib/core/page/upload/upload_page.dart`:

```dart
// Show initial notification
await _notificationService.showUploadStarted(totalFiles: _selectedFiles.length);

// Update progress during upload
await _notificationService.updateUploadProgress(
  currentFile: currentFile,
  totalFiles: totalFiles,
  progress: progress,
);

// Show completion notification
await _notificationService.showUploadCompleted(totalFiles: _selectedFiles.length);
```

## Usage

### Basic Usage

```dart
final notificationService = NotificationService();

// Initialize (done automatically in main.dart)
await notificationService.initialize();

// Show upload started
await notificationService.showUploadStarted(totalFiles: 5);

// Update progress
await notificationService.updateUploadProgress(
  currentFile: 2,
  totalFiles: 5,
  progress: 60,
);

// Show completion
await notificationService.showUploadCompleted(totalFiles: 5);
```

### Error Handling

```dart
try {
  // Upload logic
} catch (e) {
  await notificationService.showUploadError(error: e.toString());
}
```

## Platform-Specific Features

### Android
- **Progress Bar**: Native progress bar in notification
- **Ongoing Notifications**: Progress notifications stay visible
- **Channel Management**: Dedicated notification channel for uploads

### iOS/macOS
- **Alert Notifications**: Shows progress in notification text
- **Badge Updates**: App badge shows upload status
- **Sound Alerts**: Completion notifications include sound

### Windows
- **Toast Notifications**: Modern Windows toast notifications
- **Progress Display**: Shows progress percentage in notification

### Linux
- **Desktop Notifications**: Uses system notification daemon
- **Action Support**: Clickable notification actions

## Testing

Use the `NotificationTestWidget` (`lib/service/notification_test.dart`) to test notification functionality:

```dart
// Add to your app for testing
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const NotificationTestWidget()),
);
```

## Notification Types

1. **Upload Started**: Shows when upload begins
2. **Progress Updates**: Real-time progress updates (0-100%)
3. **Upload Completed**: Success notification with sound
4. **Upload Error**: Error notification with details

## Configuration

### Android Channel Settings
- **Channel ID**: `upload_progress`
- **Importance**: Low (for progress), High (for completion/error)
- **Sound**: Disabled for progress, enabled for completion
- **Vibration**: Disabled for progress, enabled for completion

### iOS/macOS Settings
- **Alert**: Enabled
- **Badge**: Enabled
- **Sound**: Disabled for progress, enabled for completion

## Troubleshooting

### Common Issues

1. **Notifications not showing on Android**:
   - Check notification permissions in device settings
   - Ensure notification channel is created
   - Verify app is not in battery optimization
   - Check if notifications are enabled for the app

2. **iOS notifications not working**:
   - Check notification permissions in Settings > Notifications
   - Ensure app is not in Do Not Disturb mode
   - Verify notification style is set to "Banners" or "Alerts"

3. **Windows notifications not appearing**:
   - Check Windows notification settings
   - Ensure app has notification permissions
   - Verify Windows notification center is enabled

4. **macOS notifications not working**:
   - Check System Preferences > Notifications
   - Ensure app has notification permissions
   - Verify "Do Not Disturb" is not enabled

### Debug Mode

The system includes comprehensive debug logging. Check the console output for:

```dart
// Initialization
debugPrint('NotificationService initialized successfully');

// Upload process
debugPrint('Starting upload process for X files');
debugPrint('Upload progress: 50% (chunk 5/10)');

// Notification updates
debugPrint('NotificationService: Showing upload started notification for X files');
debugPrint('NotificationService: Updating progress - File 1/3 - 50%');
debugPrint('NotificationService: Progress notification updated successfully');
```

### Testing Notifications

Use the "Test Notifications" button on the upload page to verify the notification system works:

1. Go to the Upload page
2. Click "Test Notifications" button
3. Check if notifications appear in your system notification area
4. Check console output for debug messages

### Platform-Specific Setup

#### Android
- Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
```

#### iOS
- Add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

#### Windows
- **MSIX Packaging**: For full notification support, package your app as MSIX installer
- **Notification Settings**: Check Windows notification settings in Settings > System > Notifications
- **App Identity**: Windows requires proper app identity for notification features
- **Toast Notifications**: Uses Windows 10/11 toast notification system

### Common Fixes

1. **Restart the app** after making permission changes
2. **Clear app data** and reinstall if notifications still don't work
3. **Check device notification settings** for the specific app
4. **Verify notification permissions** are granted during app installation

## Future Enhancements

- **Pause/Resume**: Add pause/resume functionality for uploads
- **Cancel Upload**: Allow canceling uploads from notification
- **Detailed Progress**: Show file names and sizes in notifications
- **Custom Sounds**: Platform-specific notification sounds
