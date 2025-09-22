import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si')
  ];

  /// No description provided for @everesports.
  ///
  /// In en, this message translates to:
  /// **'Everesports'**
  String get everesports;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @contentDisplay.
  ///
  /// In en, this message translates to:
  /// **'Content & Display'**
  String get contentDisplay;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @addSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Add Social Media'**
  String get addSocialMedia;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get cover;

  /// No description provided for @crop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get crop;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @usernamecopiedt.
  ///
  /// In en, this message translates to:
  /// **'Username copied'**
  String get usernamecopiedt;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @userID.
  ///
  /// In en, this message translates to:
  /// **'User ID: '**
  String get userID;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectedimagenotfound.
  ///
  /// In en, this message translates to:
  /// **'Selected image not found'**
  String get selectedimagenotfound;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile:'**
  String get errorUpdatingProfile;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @profileupdatedsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileupdatedsuccessfully;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordCannotBeEmpty;

  /// No description provided for @usernameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameCannotBeEmpty;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @userIdIsMissing.
  ///
  /// In en, this message translates to:
  /// **'User ID is missing'**
  String get userIdIsMissing;

  /// No description provided for @failedToFetchUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch user:'**
  String get failedToFetchUser;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFound;

  /// No description provided for @profileImageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Profile image uploaded'**
  String get profileImageUploaded;

  /// No description provided for @coverPhotoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Cover photo uploaded'**
  String get coverPhotoUploaded;

  /// No description provided for @profileImageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Profile image deleted'**
  String get profileImageDeleted;

  /// No description provided for @coverPhotoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cover photo deleted'**
  String get coverPhotoDeleted;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @errorDeletingImage.
  ///
  /// In en, this message translates to:
  /// **'Error deleting image:'**
  String get errorDeletingImage;

  /// No description provided for @errorCroppingImage.
  ///
  /// In en, this message translates to:
  /// **'Error cropping image:'**
  String get errorCroppingImage;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get failedToUploadImage;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image:'**
  String get errorUploadingImage;

  /// No description provided for @addGames.
  ///
  /// In en, this message translates to:
  /// **'Add Games'**
  String get addGames;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields.'**
  String get pleaseFillAllFields;

  /// No description provided for @gameUIDMismatch.
  ///
  /// In en, this message translates to:
  /// **'Game UID and Confirm Game UID do not match.'**
  String get gameUIDMismatch;

  /// No description provided for @gameUIDAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This Game UID is already used for this game. Please use a different UID.'**
  String get gameUIDAlreadyUsed;

  /// No description provided for @maxTwoEntries.
  ///
  /// In en, this message translates to:
  /// **'You can only add up to 2 entries for this game.'**
  String get maxTwoEntries;

  /// No description provided for @gameAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Game added successfully!'**
  String get gameAddedSuccessfully;

  /// No description provided for @noGamesAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No games added yet.'**
  String get noGamesAddedYet;

  /// No description provided for @pleaseLoginToComment.
  ///
  /// In en, this message translates to:
  /// **'Please log in to comment.'**
  String get pleaseLoginToComment;

  /// No description provided for @errorAddingComment.
  ///
  /// In en, this message translates to:
  /// **'Error adding comment: {error}'**
  String errorAddingComment(Object error);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get minutesAgo;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @hideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get hideReplies;

  /// No description provided for @showReplies.
  ///
  /// In en, this message translates to:
  /// **'Show {count} replies'**
  String showReplies(Object count);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get deleteCommentConfirm;

  /// No description provided for @reportedComment.
  ///
  /// In en, this message translates to:
  /// **'Comment reported.'**
  String get reportedComment;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get noCommentsYet;

  /// No description provided for @beFirstToComment.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment!'**
  String get beFirstToComment;

  /// No description provided for @writeAComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeAComment;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get error;

  /// No description provided for @sharePost.
  ///
  /// In en, this message translates to:
  /// **'Share Post'**
  String get sharePost;

  /// No description provided for @editYourComment.
  ///
  /// In en, this message translates to:
  /// **'Edit your comment'**
  String get editYourComment;

  /// No description provided for @noAlbumsFound.
  ///
  /// In en, this message translates to:
  /// **'No albums found. Create one below.'**
  String get noAlbumsFound;

  /// No description provided for @pleaseLoginToLikePosts.
  ///
  /// In en, this message translates to:
  /// **'Please log in to like posts.'**
  String get pleaseLoginToLikePosts;

  /// No description provided for @errorLikingPost.
  ///
  /// In en, this message translates to:
  /// **'Error liking post.'**
  String get errorLikingPost;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet.'**
  String get noPostsYet;

  /// No description provided for @beFirstToShare.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share!'**
  String get beFirstToShare;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @uploadComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Upload coming soon!'**
  String get uploadComingSoon;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @unfollowFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unfollow: {error}'**
  String unfollowFailed(Object error);

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @followFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to follow: {error}'**
  String followFailed(Object error);

  /// No description provided for @pleaseLoginToSharePosts.
  ///
  /// In en, this message translates to:
  /// **'Please log in to share posts.'**
  String get pleaseLoginToSharePosts;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied!'**
  String get linkCopied;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @noImageToDownload.
  ///
  /// In en, this message translates to:
  /// **'No image to download.'**
  String get noImageToDownload;

  /// No description provided for @failedToDecodeImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to decode image.'**
  String get failedToDecodeImage;

  /// No description provided for @downloadNotSupportedOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Download not supported on web.'**
  String get downloadNotSupportedOnWeb;

  /// No description provided for @saveImage.
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get saveImage;

  /// No description provided for @savedToDownloads.
  ///
  /// In en, this message translates to:
  /// **'Saved to Downloads.'**
  String get savedToDownloads;

  /// No description provided for @pleaseLoginToBookmarkPosts.
  ///
  /// In en, this message translates to:
  /// **'Please log in to bookmark posts.'**
  String get pleaseLoginToBookmarkPosts;

  /// No description provided for @selectAlbums.
  ///
  /// In en, this message translates to:
  /// **'Select Albums'**
  String get selectAlbums;

  /// No description provided for @newAlbumName.
  ///
  /// In en, this message translates to:
  /// **'New Album Name'**
  String get newAlbumName;

  /// No description provided for @createAlbum.
  ///
  /// In en, this message translates to:
  /// **'Create Album'**
  String get createAlbum;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'si': return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
