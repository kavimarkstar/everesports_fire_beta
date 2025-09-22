# Windows Notification Troubleshooting Guide

## 🔧 **Quick Fix Steps**

### **Step 1: Check Windows Notification Settings**

1. **Open Windows Settings**:
   - Press `Windows + I`
   - Go to **System** → **Notifications & actions**

2. **Enable Notifications**:
   - Make sure **"Get notifications from apps and other senders"** is **ON**
   - Scroll down to find your app (Everesports)
   - Make sure it's **enabled**

3. **Check Focus Assist**:
   - Press `Windows + I`
   - Go to **System** → **Focus assist**
   - Make sure it's set to **"Off"** or **"Priority only"**

### **Step 2: Test the Notification System**

1. **Run the app**:
   ```bash
   flutter run -d windows
   ```

2. **Go to Upload page**

3. **Click "Test Windows Notification Only"** (blue button)
   - This tests basic Windows notification functionality
   - Check console for debug messages

4. **Click "Test Notifications"** (regular button)
   - This tests the full upload notification flow

### **Step 3: Check Console Output**

Look for these debug messages in the console:

```
✅ Good messages:
- "NotificationService initialized successfully"
- "Platform: windows"
- "Windows test notification sent successfully"
- "NotificationService: Upload started notification shown successfully"

❌ Error messages:
- "Failed to initialize NotificationService: [error]"
- "Windows test notification failed: [error]"
- "Error showing upload started notification: [error]"
```

### **Step 4: Common Windows Issues & Solutions**

#### **Issue 1: No Notifications Appear**
**Solution:**
- Check Windows notification settings (Step 1)
- Restart the app
- Check if Windows is in "Do Not Disturb" mode

#### **Issue 2: "Failed to initialize" Error**
**Solution:**
- Make sure you're running on Windows 10/11
- Check if the app has proper permissions
- Try running as administrator

#### **Issue 3: Notifications Appear but Don't Show Progress**
**Solution:**
- This is normal - Windows doesn't support progress bars in notifications
- Progress is shown in the notification text instead

#### **Issue 4: Build Errors**
**Solution:**
- Use debug mode: `flutter run -d windows`
- Don't worry about release build errors for testing

### **Step 5: Advanced Troubleshooting**

#### **Check Windows Version**
- Windows 10 version 1903 or later required
- Windows 11 (any version) supported

#### **Check App Identity**
- The app needs proper identity for notifications
- This is handled automatically in debug mode

#### **Check Notification History**
1. Press `Windows + A` (Action Center)
2. Look for notification history
3. Check if notifications are being sent but not displayed

### **Step 6: Test Commands**

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run in debug mode
flutter run -d windows

# Check Flutter doctor
flutter doctor -v
```

### **Expected Behavior on Windows**

✅ **What Should Work:**
- Toast notifications in Windows notification center
- Notification text updates (progress shown as text)
- Sound notifications for completion/error
- Clickable notifications

❌ **What Won't Work:**
- Progress bars (Windows limitation)
- Custom notification icons (limited support)
- Rich notifications (basic text only)

### **Debug Information**

When testing, you should see:

1. **Console Output:**
   ```
   Platform: windows
   NotificationService: Testing Windows notification
   NotificationService: Windows test notification sent successfully
   ```

2. **Windows Notification Center:**
   - Toast notification appears
   - Shows "Windows Test" or "Upload Started"
   - Clickable notification

3. **No Errors:**
   - No "Failed to initialize" messages
   - No "Windows test notification failed" messages

### **If Still Not Working**

1. **Check Windows Event Viewer**:
   - Press `Windows + R`
   - Type `eventvwr.msc`
   - Look for application errors

2. **Try Different Notification Types**:
   - Use the "Test Windows Notification Only" button
   - Check if basic notifications work

3. **Check Flutter Version**:
   ```bash
   flutter --version
   ```
   - Should be Flutter 3.0+ for Windows support

4. **Reinstall Dependencies**:
   ```bash
   flutter clean
   flutter pub get
   flutter pub deps
   ```

### **Success Indicators**

✅ **Notifications Working:**
- Toast notifications appear in Windows notification center
- Console shows success messages
- No error messages in console
- Notifications are clickable

The notification system should work on Windows with these troubleshooting steps!
