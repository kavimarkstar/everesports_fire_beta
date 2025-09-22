import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const int _uploadNotificationId = 1001;
  static const String _uploadChannelId = 'upload_progress';
  static const String _uploadChannelName = 'Upload Progress';
  static const String _uploadChannelDescription =
      'Shows upload progress for files';

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      await _requestPermissions();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // macOS initialization settings
      const DarwinInitializationSettings macosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Linux initialization settings
      const LinuxInitializationSettings linuxSettings =
          LinuxInitializationSettings(defaultActionName: 'Open notification');

      // Windows initialization settings
      const WindowsInitializationSettings windowsSettings =
          WindowsInitializationSettings(
            appName: 'Everesports',
            appUserModelId: 'Everesports.UploadNotifications',
            guid: 'everesports-upload-notifications',
          );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macosSettings,
        linux: linuxSettings,
        windows: windowsSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isWindows) {
      // Windows notifications don't require explicit permission request
      // but we can check if notifications are supported
      debugPrint('Windows notification permissions check');
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _uploadChannelId,
      _uploadChannelName,
      description: _uploadChannelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show upload started notification
  Future<void> showUploadStarted({required int totalFiles}) async {
    if (!_isInitialized) {
      debugPrint(
        'NotificationService: Initializing before showing notification',
      );
      await initialize();
    }
    debugPrint(
      'NotificationService: Showing upload started notification for $totalFiles files',
    );
    debugPrint('Platform: ${Platform.operatingSystem}');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _uploadChannelId,
          _uploadChannelName,
          channelDescription: _uploadChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: 100,
          progress: 0,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const DarwinNotificationDetails macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      defaultActionName: 'Open notification',
    );

    const WindowsNotificationDetails windowsDetails =
        WindowsNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    try {
      await _notifications.show(
        _uploadNotificationId,
        'Upload Started',
        'Uploading $totalFiles file${totalFiles > 1 ? 's' : ''}...',
        notificationDetails,
      );
      debugPrint(
        'NotificationService: Upload started notification shown successfully',
      );
    } catch (e) {
      debugPrint(
        'NotificationService: Error showing upload started notification: $e',
      );
    }
  }

  /// Update upload progress notification
  Future<void> updateUploadProgress({
    required int currentFile,
    required int totalFiles,
    required int progress,
  }) async {
    if (!_isInitialized) return;
    debugPrint(
      'NotificationService: Updating progress - File $currentFile/$totalFiles - $progress%',
    );

    final String title = 'Uploading File $currentFile of $totalFiles';
    final String body = 'Progress: $progress%';

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _uploadChannelId,
          _uploadChannelName,
          channelDescription: _uploadChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const DarwinNotificationDetails macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      defaultActionName: 'Open notification',
    );

    const WindowsNotificationDetails windowsDetails =
        WindowsNotificationDetails();

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    try {
      await _notifications.show(
        _uploadNotificationId,
        title,
        body,
        notificationDetails,
      );
      debugPrint(
        'NotificationService: Progress notification updated successfully',
      );
    } catch (e) {
      debugPrint(
        'NotificationService: Error updating progress notification: $e',
      );
    }
  }

  /// Show upload completed notification
  Future<void> showUploadCompleted({required int totalFiles}) async {
    if (!_isInitialized) return;
    debugPrint(
      'NotificationService: Showing upload completed notification for $totalFiles files',
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _uploadChannelId,
          _uploadChannelName,
          channelDescription: _uploadChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          showProgress: false,
          ongoing: false,
          autoCancel: true,
          onlyAlertOnce: false,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const DarwinNotificationDetails macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      defaultActionName: 'Open notification',
    );

    const WindowsNotificationDetails windowsDetails =
        WindowsNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    await _notifications.show(
      _uploadNotificationId + 1, // Use different ID for completion
      'Upload Completed',
      'Successfully uploaded $totalFiles file${totalFiles > 1 ? 's' : ''}',
      notificationDetails,
    );
  }

  /// Show upload error notification
  Future<void> showUploadError({required String error}) async {
    if (!_isInitialized) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _uploadChannelId,
          _uploadChannelName,
          channelDescription: _uploadChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          showProgress: false,
          ongoing: false,
          autoCancel: true,
          onlyAlertOnce: false,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const DarwinNotificationDetails macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      defaultActionName: 'Open notification',
    );

    const WindowsNotificationDetails windowsDetails =
        WindowsNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    await _notifications.show(
      _uploadNotificationId + 2, // Use different ID for error
      'Upload Failed',
      error,
      notificationDetails,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    await _notifications.cancel(id);
  }

  /// Test Windows notifications specifically
  Future<void> testWindowsNotification() async {
    debugPrint('=== WINDOWS NOTIFICATION TEST START ===');
    debugPrint('Platform: ${Platform.operatingSystem}');
    debugPrint('Is Windows: ${Platform.isWindows}');

    if (!_isInitialized) {
      debugPrint('NotificationService: Initializing for Windows test');
      try {
        await initialize();
        debugPrint('NotificationService: Initialization completed');
      } catch (e) {
        debugPrint('NotificationService: Initialization failed: $e');
        return;
      }
    }

    debugPrint('NotificationService: Testing Windows notification');
    debugPrint('Is initialized: $_isInitialized');

    try {
      // Test 1: Simple notification with minimal details
      debugPrint('Test 1: Sending simple notification...');
      await _notifications.show(
        9999, // Use a different ID for test
        'Windows Test',
        'This is a test notification for Windows',
        const NotificationDetails(windows: WindowsNotificationDetails()),
      );
      debugPrint('Test 1: Simple notification sent successfully');

      // Test 2: Notification with more details
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Test 2: Sending detailed notification...');
      await _notifications.show(
        9998,
        'Windows Test 2',
        'This is a more detailed test notification',
        const NotificationDetails(windows: WindowsNotificationDetails()),
      );
      debugPrint('Test 2: Detailed notification sent successfully');

      debugPrint('=== WINDOWS NOTIFICATION TEST COMPLETED ===');
    } catch (e) {
      debugPrint('=== WINDOWS NOTIFICATION TEST FAILED ===');
      debugPrint('Error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  /// Simple Windows notification test without complex initialization
  Future<void> simpleWindowsTest() async {
    debugPrint('=== SIMPLE WINDOWS TEST START ===');

    try {
      // Create a new instance for testing
      final testNotifications = FlutterLocalNotificationsPlugin();

      // Initialize with minimal settings
      const initSettings = InitializationSettings(
        windows: WindowsInitializationSettings(
          appName: 'Everesports Test',
          appUserModelId: 'Everesports.Test',
          guid: 'everesports-test-123',
        ),
      );

      debugPrint('Initializing test notification plugin...');
      await testNotifications.initialize(initSettings);
      debugPrint('Test plugin initialized successfully');

      // Send simple notification
      debugPrint('Sending simple test notification...');
      await testNotifications.show(
        8888,
        'Simple Test',
        'This is a simple Windows notification test',
        const NotificationDetails(windows: WindowsNotificationDetails()),
      );
      debugPrint('Simple test notification sent successfully');

      debugPrint('=== SIMPLE WINDOWS TEST COMPLETED ===');
    } catch (e) {
      debugPrint('=== SIMPLE WINDOWS TEST FAILED ===');
      debugPrint('Error: $e');
      debugPrint('Error type: ${e.runtimeType}');
    }
  }
}
