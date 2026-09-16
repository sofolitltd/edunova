import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'EduNova'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToContinue;

  /// No description provided for @joinEduNova.
  ///
  /// In en, this message translates to:
  /// **'Join EduNova'**
  String get joinEduNova;

  /// No description provided for @createAccountToStart.
  ///
  /// In en, this message translates to:
  /// **'Create your account to start learning'**
  String get createAccountToStart;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @byCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our '**
  String get byCreatingAccount;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @enterMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number'**
  String get enterMobile;

  /// No description provided for @validMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number'**
  String get validMobile;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get enterFullName;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameMinLength;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPasswordMsg.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordMsg;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @mobilePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile and password are required'**
  String get mobilePasswordRequired;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to receive a verification code'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to'**
  String get otpSentTo;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get enterOtp;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid code'**
  String get invalidOtp;

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'Code has expired, please request a new one'**
  String get otpExpired;

  /// No description provided for @otpVerified.
  ///
  /// In en, this message translates to:
  /// **'Code verified successfully'**
  String get otpVerified;

  /// No description provided for @otpFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get otpFailed;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendOtp;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendOtpIn;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get seconds;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful!'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Password reset failed'**
  String get resetPasswordFailed;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get passwordResetTitle;

  /// No description provided for @passwordResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from previously used passwords'**
  String get passwordResetSubtitle;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save Password'**
  String get savePassword;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verifyAccount;

  /// No description provided for @verifyAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your mobile'**
  String get verifyAccountSubtitle;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account verified successfully!'**
  String get accountVerified;

  /// No description provided for @accountVerifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can now login to your account'**
  String get accountVerifiedSubtitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @exam.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get exam;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start learning today'**
  String get homeSubtitle;

  /// No description provided for @searchCourses.
  ///
  /// In en, this message translates to:
  /// **'Search courses...'**
  String get searchCourses;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @examsTaken.
  ///
  /// In en, this message translates to:
  /// **'Exams Taken'**
  String get examsTaken;

  /// No description provided for @avgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg Score'**
  String get avgScore;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @mathCourse.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get mathCourse;

  /// No description provided for @mathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Algebra, Geometry, Calculus'**
  String get mathSubtitle;

  /// No description provided for @scienceCourse.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get scienceCourse;

  /// No description provided for @scienceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Physics, Chemistry, Biology'**
  String get scienceSubtitle;

  /// No description provided for @englishCourse.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishCourse;

  /// No description provided for @englishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar, Literature, Writing'**
  String get englishSubtitle;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'lessons'**
  String get lessons;

  /// No description provided for @upcomingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Schedule'**
  String get upcomingSchedule;

  /// No description provided for @mathClass.
  ///
  /// In en, this message translates to:
  /// **'Mathematics Class'**
  String get mathClass;

  /// No description provided for @scienceClass.
  ///
  /// In en, this message translates to:
  /// **'Science Class'**
  String get scienceClass;

  /// No description provided for @examSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and take your exams'**
  String get examSubtitle;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @upcomingExams.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Exams'**
  String get upcomingExams;

  /// No description provided for @mathMidterm.
  ///
  /// In en, this message translates to:
  /// **'Mathematics Midterm'**
  String get mathMidterm;

  /// No description provided for @scienceQuiz.
  ///
  /// In en, this message translates to:
  /// **'Science Quiz'**
  String get scienceQuiz;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @recentResults.
  ///
  /// In en, this message translates to:
  /// **'Recent Results'**
  String get recentResults;

  /// No description provided for @mathQuiz.
  ///
  /// In en, this message translates to:
  /// **'Math Quiz'**
  String get mathQuiz;

  /// No description provided for @englishTest.
  ///
  /// In en, this message translates to:
  /// **'English Test'**
  String get englishTest;

  /// No description provided for @historyMidterm.
  ///
  /// In en, this message translates to:
  /// **'History Midterm'**
  String get historyMidterm;

  /// No description provided for @classSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your enrolled classes and materials'**
  String get classSubtitle;

  /// No description provided for @enrolledClasses.
  ///
  /// In en, this message translates to:
  /// **'Enrolled Classes'**
  String get enrolledClasses;

  /// No description provided for @mathematics.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get mathematics;

  /// No description provided for @physics.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get physics;

  /// No description provided for @englishLit.
  ///
  /// In en, this message translates to:
  /// **'English Literature'**
  String get englishLit;

  /// No description provided for @chemistry.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get chemistry;

  /// No description provided for @nextClassToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get nextClassToday;

  /// No description provided for @nextClassTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get nextClassTomorrow;

  /// No description provided for @nextClassIn2Days.
  ///
  /// In en, this message translates to:
  /// **'In 2 days'**
  String get nextClassIn2Days;

  /// No description provided for @classMaterials.
  ///
  /// In en, this message translates to:
  /// **'Class Materials'**
  String get classMaterials;

  /// No description provided for @mathNotesWeek1.
  ///
  /// In en, this message translates to:
  /// **'Math Notes - Week 1'**
  String get mathNotesWeek1;

  /// No description provided for @physicsLabRecord.
  ///
  /// In en, this message translates to:
  /// **'Physics Lab Record'**
  String get physicsLabRecord;

  /// No description provided for @englishEssay.
  ///
  /// In en, this message translates to:
  /// **'English Essay Guidelines'**
  String get englishEssay;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'Bangla'**
  String get bangla;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and set a new one'**
  String get changePasswordSubtitle;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChanged;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSaved;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @academic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academic;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religion;

  /// No description provided for @islam.
  ///
  /// In en, this message translates to:
  /// **'Islam'**
  String get islam;

  /// No description provided for @hinduism.
  ///
  /// In en, this message translates to:
  /// **'Hinduism'**
  String get hinduism;

  /// No description provided for @christianity.
  ///
  /// In en, this message translates to:
  /// **'Christianity'**
  String get christianity;

  /// No description provided for @buddhism.
  ///
  /// In en, this message translates to:
  /// **'Buddhism'**
  String get buddhism;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @classLevel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classLevel;

  /// No description provided for @classOne.
  ///
  /// In en, this message translates to:
  /// **'Class 1'**
  String get classOne;

  /// No description provided for @classTwo.
  ///
  /// In en, this message translates to:
  /// **'Class 2'**
  String get classTwo;

  /// No description provided for @classThree.
  ///
  /// In en, this message translates to:
  /// **'Class 3'**
  String get classThree;

  /// No description provided for @classFour.
  ///
  /// In en, this message translates to:
  /// **'Class 4'**
  String get classFour;

  /// No description provided for @classFive.
  ///
  /// In en, this message translates to:
  /// **'Class 5'**
  String get classFive;

  /// No description provided for @classSix.
  ///
  /// In en, this message translates to:
  /// **'Class 6'**
  String get classSix;

  /// No description provided for @classSeven.
  ///
  /// In en, this message translates to:
  /// **'Class 7'**
  String get classSeven;

  /// No description provided for @classEight.
  ///
  /// In en, this message translates to:
  /// **'Class 8'**
  String get classEight;

  /// No description provided for @classNine.
  ///
  /// In en, this message translates to:
  /// **'Class 9'**
  String get classNine;

  /// No description provided for @classTen.
  ///
  /// In en, this message translates to:
  /// **'Class 10'**
  String get classTen;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get fatherName;

  /// No description provided for @fatherMobile.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Mobile'**
  String get fatherMobile;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @motherName.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get motherName;

  /// No description provided for @motherMobile.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Mobile'**
  String get motherMobile;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @notificationMobile.
  ///
  /// In en, this message translates to:
  /// **'Notification Mobile'**
  String get notificationMobile;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddress;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// No description provided for @unanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get unanswered;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @submitExam.
  ///
  /// In en, this message translates to:
  /// **'Submit Exam'**
  String get submitExam;

  /// No description provided for @confirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Submit'**
  String get confirmSubmit;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @aboutClass.
  ///
  /// In en, this message translates to:
  /// **'About Class'**
  String get aboutClass;

  /// No description provided for @classAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'This class covers advanced topics with interactive sessions and practical assignments. Regular attendance and participation is expected.'**
  String get classAboutDescription;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklySchedule;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @visitUs.
  ///
  /// In en, this message translates to:
  /// **'Visit Us'**
  String get visitUs;

  /// No description provided for @frequentlyAsked.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAsked;

  /// No description provided for @faq1Question.
  ///
  /// In en, this message translates to:
  /// **'How do I reset my password?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Change Password. Enter your current password and set a new one.'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In en, this message translates to:
  /// **'How do I change the language?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Language. Tap to toggle between Bangla and English.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In en, this message translates to:
  /// **'How do I take an exam?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In en, this message translates to:
  /// **'Go to the Exams tab, find an upcoming exam and tap Start. You\'ll have a timer and multiple choice questions.'**
  String get faq3Answer;

  /// No description provided for @faq4Question.
  ///
  /// In en, this message translates to:
  /// **'How do I contact my teacher?'**
  String get faq4Question;

  /// No description provided for @faq4Answer.
  ///
  /// In en, this message translates to:
  /// **'Go to Classes, select your class, and you\'ll find the teacher\'s contact information.'**
  String get faq4Answer;

  /// No description provided for @faq5Question.
  ///
  /// In en, this message translates to:
  /// **'Is my data secure?'**
  String get faq5Question;

  /// No description provided for @faq5Answer.
  ///
  /// In en, this message translates to:
  /// **'Yes. We use industry-standard encryption and secure storage for all your data.'**
  String get faq5Answer;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Online & Offline Education Centre'**
  String get aboutSubtitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'EduNova is a comprehensive education platform designed for students in Bangladesh. Access courses, take exams, track progress, and connect with teachers — all in one place.'**
  String get aboutDescription;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// No description provided for @feature1Title.
  ///
  /// In en, this message translates to:
  /// **'Interactive Courses'**
  String get feature1Title;

  /// No description provided for @feature1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn with structured lessons and notes'**
  String get feature1Subtitle;

  /// No description provided for @feature2Title.
  ///
  /// In en, this message translates to:
  /// **'Video Lessons'**
  String get feature2Title;

  /// No description provided for @feature2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch recorded classes anytime'**
  String get feature2Subtitle;

  /// No description provided for @feature3Title.
  ///
  /// In en, this message translates to:
  /// **'Online Exams'**
  String get feature3Title;

  /// No description provided for @feature3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take tests with instant results'**
  String get feature3Subtitle;

  /// No description provided for @feature4Title.
  ///
  /// In en, this message translates to:
  /// **'Progress Tracking'**
  String get feature4Title;

  /// No description provided for @feature4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor your academic performance'**
  String get feature4Subtitle;

  /// No description provided for @builtWith.
  ///
  /// In en, this message translates to:
  /// **'Built With'**
  String get builtWith;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved.'**
  String get allRightsReserved;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logoutConfirm;

  /// No description provided for @logoutConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get logoutConfirmSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: September 2026'**
  String get lastUpdated;

  /// No description provided for @termsS1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get termsS1Title;

  /// No description provided for @termsS1Content.
  ///
  /// In en, this message translates to:
  /// **'By accessing and using EduNova, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you may not use our services.'**
  String get termsS1Content;

  /// No description provided for @termsS2Title.
  ///
  /// In en, this message translates to:
  /// **'2. User Accounts'**
  String get termsS2Title;

  /// No description provided for @termsS2Content.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account credentials. You agree to provide accurate and complete information during registration and to update it as necessary.'**
  String get termsS2Content;

  /// No description provided for @termsS3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Academic Integrity'**
  String get termsS3Title;

  /// No description provided for @termsS3Content.
  ///
  /// In en, this message translates to:
  /// **'All exams and assessments must be completed honestly. Any form of cheating, plagiarism, or academic dishonesty may result in account suspension or termination.'**
  String get termsS3Content;

  /// No description provided for @termsS4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Content Usage'**
  String get termsS4Title;

  /// No description provided for @termsS4Content.
  ///
  /// In en, this message translates to:
  /// **'All course materials, videos, notes, and other content provided through EduNova are for personal educational use only. Redistribution or commercial use is strictly prohibited.'**
  String get termsS4Content;

  /// No description provided for @termsS5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Payments & Refunds'**
  String get termsS5Title;

  /// No description provided for @termsS5Content.
  ///
  /// In en, this message translates to:
  /// **'Payment terms and refund policies are subject to the specific course or subscription plan you choose. Please review the refund policy before making any purchase.'**
  String get termsS5Content;

  /// No description provided for @termsS6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Limitation of Liability'**
  String get termsS6Title;

  /// No description provided for @termsS6Content.
  ///
  /// In en, this message translates to:
  /// **'EduNova shall not be liable for any indirect, incidental, or consequential damages arising from your use of our services. We strive to ensure accuracy but do not guarantee uninterrupted service.'**
  String get termsS6Content;

  /// No description provided for @termsS7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Changes to Terms'**
  String get termsS7Title;

  /// No description provided for @termsS7Content.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify these terms at any time. Continued use of EduNova after changes constitutes acceptance of the new terms. Users will be notified of significant changes.'**
  String get termsS7Content;

  /// No description provided for @privacyS1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacyS1Title;

  /// No description provided for @privacyS1Content.
  ///
  /// In en, this message translates to:
  /// **'We collect personal information you provide directly, including your name, mobile number, email address, and academic information. We also collect usage data such as exam scores and course progress.'**
  String get privacyS1Content;

  /// No description provided for @privacyS2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacyS2Title;

  /// No description provided for @privacyS2Content.
  ///
  /// In en, this message translates to:
  /// **'Your information is used to provide and improve our educational services, personalize your learning experience, send important notifications, and communicate with you about your account.'**
  String get privacyS2Content;

  /// No description provided for @privacyS3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Security'**
  String get privacyS3Title;

  /// No description provided for @privacyS3Content.
  ///
  /// In en, this message translates to:
  /// **'We implement industry-standard security measures including encryption and secure storage to protect your personal information. However, no method of transmission over the internet is 100% secure.'**
  String get privacyS3Content;

  /// No description provided for @privacyS4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data Sharing'**
  String get privacyS4Title;

  /// No description provided for @privacyS4Content.
  ///
  /// In en, this message translates to:
  /// **'We do not sell or rent your personal information to third parties. We may share anonymized, aggregated data for research or analytics purposes. Your identity will never be disclosed.'**
  String get privacyS4Content;

  /// No description provided for @privacyS5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get privacyS5Title;

  /// No description provided for @privacyS5Content.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, correct, or delete your personal data. You may also request a copy of all data we hold about you by contacting our support team.'**
  String get privacyS5Content;

  /// No description provided for @privacyS6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Cookies & Tracking'**
  String get privacyS6Title;

  /// No description provided for @privacyS6Content.
  ///
  /// In en, this message translates to:
  /// **'EduNova uses essential cookies to maintain your session and preferences. We do not use third-party tracking or advertising cookies without your explicit consent.'**
  String get privacyS6Content;

  /// No description provided for @privacyS7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Contact Us'**
  String get privacyS7Title;

  /// No description provided for @privacyS7Content.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, please contact us at support@edunova.com or visit our Help & Support page.'**
  String get privacyS7Content;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
