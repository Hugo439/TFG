import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @navMenus.
  ///
  /// In es, this message translates to:
  /// **'Menús'**
  String get navMenus;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navShopping.
  ///
  /// In es, this message translates to:
  /// **'Lista de la compra'**
  String get navShopping;

  /// No description provided for @notificationDefaultTitle.
  ///
  /// In es, this message translates to:
  /// **'¡SmartMeal!'**
  String get notificationDefaultTitle;

  /// No description provided for @notificationDefaultBody.
  ///
  /// In es, this message translates to:
  /// **'Tienes una nueva notificación'**
  String get notificationDefaultBody;

  /// No description provided for @notificationActionView.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get notificationActionView;

  /// No description provided for @logoNotFound.
  ///
  /// In es, this message translates to:
  /// **'Logo no encontrado'**
  String get logoNotFound;

  /// No description provided for @errorTitle.
  ///
  /// In es, this message translates to:
  /// **'Ha ocurrido un error'**
  String get errorTitle;

  /// No description provided for @errorInitializing.
  ///
  /// In es, this message translates to:
  /// **'Error inicializando'**
  String get errorInitializing;

  /// No description provided for @errorRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get errorRetry;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get commonAccept;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get commonSend;

  /// No description provided for @commonError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get commonSuccess;

  /// No description provided for @loginWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenid@'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión en tu cuenta'**
  String get loginSubtitle;

  /// No description provided for @loginEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPasswordHint;

  /// No description provided for @loginFieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get loginFieldRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Correo no válido'**
  String get loginEmailInvalid;

  /// No description provided for @loginRememberMe.
  ///
  /// In es, this message translates to:
  /// **'Recordarme'**
  String get loginRememberMe;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get loginRegisterLink;

  /// No description provided for @loginErrorFieldsRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor completa todos los campos'**
  String get loginErrorFieldsRequired;

  /// No description provided for @loginErrorUserNotFound.
  ///
  /// In es, this message translates to:
  /// **'No existe una cuenta con este correo'**
  String get loginErrorUserNotFound;

  /// No description provided for @loginErrorWrongPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta'**
  String get loginErrorWrongPassword;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico inválido'**
  String get loginErrorInvalidEmail;

  /// No description provided for @loginErrorUserDisabled.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta ha sido deshabilitada'**
  String get loginErrorUserDisabled;

  /// No description provided for @loginErrorInvalidCredential.
  ///
  /// In es, this message translates to:
  /// **'Credenciales inválidas'**
  String get loginErrorInvalidCredential;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get loginErrorGeneric;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro'**
  String get registerTitle;

  /// No description provided for @registerHeader.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get registerHeader;

  /// No description provided for @registerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Completa tu información para mejorar tu alimentación'**
  String get registerSubtitle;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de Usuario'**
  String get registerUsernameLabel;

  /// No description provided for @registerUsernameHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre de usuario'**
  String get registerUsernameHint;

  /// No description provided for @registerEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailHint.
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get registerEmailHint;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres, mayúscula, minúscula y número'**
  String get registerPasswordHint;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Contraseña'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerHeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Altura (cm)'**
  String get registerHeightLabel;

  /// No description provided for @registerHeightHint.
  ///
  /// In es, this message translates to:
  /// **'170'**
  String get registerHeightHint;

  /// No description provided for @registerWeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get registerWeightLabel;

  /// No description provided for @registerWeightHint.
  ///
  /// In es, this message translates to:
  /// **'70'**
  String get registerWeightHint;

  /// No description provided for @registerGoalLabel.
  ///
  /// In es, this message translates to:
  /// **'Objetivo'**
  String get registerGoalLabel;

  /// No description provided for @registerGoalLoseWeight.
  ///
  /// In es, this message translates to:
  /// **'Perder peso'**
  String get registerGoalLoseWeight;

  /// No description provided for @registerGoalGainMuscle.
  ///
  /// In es, this message translates to:
  /// **'Ganar masa muscular'**
  String get registerGoalGainMuscle;

  /// No description provided for @registerGoalMaintainWeight.
  ///
  /// In es, this message translates to:
  /// **'Mantener peso'**
  String get registerGoalMaintainWeight;

  /// No description provided for @registerGoalHealthyEating.
  ///
  /// In es, this message translates to:
  /// **'Alimentación saludable'**
  String get registerGoalHealthyEating;

  /// No description provided for @registerAllergiesLabel.
  ///
  /// In es, this message translates to:
  /// **'Alergias'**
  String get registerAllergiesLabel;

  /// No description provided for @registerAllergiesHint.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo: Gluten, Lactosa'**
  String get registerAllergiesHint;

  /// No description provided for @registerButton.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registerButton;

  /// No description provided for @registerFieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get registerFieldRequired;

  /// No description provided for @registerFieldRequiredShort.
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get registerFieldRequiredShort;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Correo no válido'**
  String get registerEmailInvalid;

  /// No description provided for @registerPasswordMinLength.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get registerPasswordMinLength;

  /// No description provided for @registerPasswordUppercase.
  ///
  /// In es, this message translates to:
  /// **'Debe contener al menos una mayúscula'**
  String get registerPasswordUppercase;

  /// No description provided for @registerPasswordLowercase.
  ///
  /// In es, this message translates to:
  /// **'Debe contener al menos una minúscula'**
  String get registerPasswordLowercase;

  /// No description provided for @registerPasswordNumber.
  ///
  /// In es, this message translates to:
  /// **'Debe contener al menos un número'**
  String get registerPasswordNumber;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get registerPasswordMismatch;

  /// No description provided for @registerInvalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Número inválido'**
  String get registerInvalidNumber;

  /// No description provided for @registerHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get registerHaveAccount;

  /// No description provided for @registerLoginLink.
  ///
  /// In es, this message translates to:
  /// **'Inicia Sesión'**
  String get registerLoginLink;

  /// No description provided for @registerErrorEmailInUse.
  ///
  /// In es, this message translates to:
  /// **'Este correo ya está registrado'**
  String get registerErrorEmailInUse;

  /// No description provided for @registerErrorInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico inválido'**
  String get registerErrorInvalidEmail;

  /// No description provided for @registerErrorWeakPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es muy débil'**
  String get registerErrorWeakPassword;

  /// No description provided for @registerErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al registrarse'**
  String get registerErrorGeneric;

  /// No description provided for @registerAgeLabel.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get registerAgeLabel;

  /// No description provided for @registerAgeHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 25'**
  String get registerAgeHint;

  /// No description provided for @registerGenderLabel.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get registerGenderLabel;

  /// No description provided for @registerGenderHint.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar'**
  String get registerGenderHint;

  /// No description provided for @registerGenderMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get registerGenderMale;

  /// No description provided for @registerGenderFemale.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get registerGenderFemale;

  /// No description provided for @registerGenderOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get registerGenderOther;

  /// No description provided for @registerOptional.
  ///
  /// In es, this message translates to:
  /// **'(Opcional)'**
  String get registerOptional;

  /// No description provided for @supportTitle.
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get supportTitle;

  /// No description provided for @supportFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Enviar Mensaje'**
  String get supportFormTitle;

  /// No description provided for @supportHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Mensajes'**
  String get supportHistoryTitle;

  /// No description provided for @supportCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get supportCategoryLabel;

  /// No description provided for @supportCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una categoría'**
  String get supportCategoryHint;

  /// No description provided for @supportMessageLabel.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get supportMessageLabel;

  /// No description provided for @supportMessageHint.
  ///
  /// In es, this message translates to:
  /// **'Describe tu consulta o problema...'**
  String get supportMessageHint;

  /// No description provided for @supportMessageError.
  ///
  /// In es, this message translates to:
  /// **'El mensaje debe tener entre 10 y 500 caracteres'**
  String get supportMessageError;

  /// No description provided for @supportAttachmentButton.
  ///
  /// In es, this message translates to:
  /// **'Adjuntar Imagen'**
  String get supportAttachmentButton;

  /// No description provided for @supportRemoveAttachment.
  ///
  /// In es, this message translates to:
  /// **'Quitar imagen'**
  String get supportRemoveAttachment;

  /// No description provided for @supportSendButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar Mensaje'**
  String get supportSendButton;

  /// No description provided for @supportSendingButton.
  ///
  /// In es, this message translates to:
  /// **'Enviando...'**
  String get supportSendingButton;

  /// No description provided for @supportSendSuccess.
  ///
  /// In es, this message translates to:
  /// **'Mensaje enviado correctamente'**
  String get supportSendSuccess;

  /// No description provided for @supportSendError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar mensaje'**
  String get supportSendError;

  /// No description provided for @supportCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get supportCategory;

  /// No description provided for @supportMessage.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get supportMessage;

  /// No description provided for @supportAttach.
  ///
  /// In es, this message translates to:
  /// **'Adjuntar imagen'**
  String get supportAttach;

  /// No description provided for @supportSending.
  ///
  /// In es, this message translates to:
  /// **'Enviando...'**
  String get supportSending;

  /// No description provided for @supportSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get supportSend;

  /// No description provided for @supportSentOk.
  ///
  /// In es, this message translates to:
  /// **'Mensaje enviado correctamente'**
  String get supportSentOk;

  /// No description provided for @supportContact.
  ///
  /// In es, this message translates to:
  /// **'¿Necesitas ayuda urgente?'**
  String get supportContact;

  /// No description provided for @supportDescription.
  ///
  /// In es, this message translates to:
  /// **'Contacta directamente con nosotros'**
  String get supportDescription;

  /// No description provided for @supportHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de Mensajes'**
  String get supportHistory;

  /// No description provided for @supportFaq.
  ///
  /// In es, this message translates to:
  /// **'Preguntas Frecuentes'**
  String get supportFaq;

  /// No description provided for @supportNoMessages.
  ///
  /// In es, this message translates to:
  /// **'No tienes mensajes aún'**
  String get supportNoMessages;

  /// No description provided for @supportResponse.
  ///
  /// In es, this message translates to:
  /// **'Respuesta'**
  String get supportResponse;

  /// No description provided for @supportCategoryTechnical.
  ///
  /// In es, this message translates to:
  /// **'Problema Técnico'**
  String get supportCategoryTechnical;

  /// No description provided for @supportCategoryAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get supportCategoryAccount;

  /// No description provided for @supportCategoryBilling.
  ///
  /// In es, this message translates to:
  /// **'Facturación'**
  String get supportCategoryBilling;

  /// No description provided for @supportCategoryGeneral.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get supportCategoryGeneral;

  /// No description provided for @categoryDudas.
  ///
  /// In es, this message translates to:
  /// **'Dudas'**
  String get categoryDudas;

  /// No description provided for @categoryErrores.
  ///
  /// In es, this message translates to:
  /// **'Errores'**
  String get categoryErrores;

  /// No description provided for @categorySugerencias.
  ///
  /// In es, this message translates to:
  /// **'Sugerencias'**
  String get categorySugerencias;

  /// No description provided for @categoryCuenta.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get categoryCuenta;

  /// No description provided for @categoryMenus.
  ///
  /// In es, this message translates to:
  /// **'Menús'**
  String get categoryMenus;

  /// No description provided for @categoryOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get categoryOtro;

  /// No description provided for @supportStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get supportStatusPending;

  /// No description provided for @supportStatusAnswered.
  ///
  /// In es, this message translates to:
  /// **'Respondido'**
  String get supportStatusAnswered;

  /// No description provided for @supportStatusClosed.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get supportStatusClosed;

  /// No description provided for @statusPendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPendiente;

  /// No description provided for @statusEnProceso.
  ///
  /// In es, this message translates to:
  /// **'En Proceso'**
  String get statusEnProceso;

  /// No description provided for @statusRespondido.
  ///
  /// In es, this message translates to:
  /// **'Respondido'**
  String get statusRespondido;

  /// No description provided for @supportHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes mensajes de soporte'**
  String get supportHistoryEmpty;

  /// No description provided for @supportHistoryError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar mensajes'**
  String get supportHistoryError;

  /// No description provided for @supportHistoryLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando mensajes...'**
  String get supportHistoryLoading;

  /// No description provided for @supportResponseLabel.
  ///
  /// In es, this message translates to:
  /// **'Respuesta:'**
  String get supportResponseLabel;

  /// No description provided for @supportFaqTitle.
  ///
  /// In es, this message translates to:
  /// **'Preguntas Frecuentes'**
  String get supportFaqTitle;

  /// No description provided for @supportContactTitle.
  ///
  /// In es, this message translates to:
  /// **'Contacto Directo'**
  String get supportContactTitle;

  /// No description provided for @supportContactEmail.
  ///
  /// In es, this message translates to:
  /// **'Enviar Email'**
  String get supportContactEmail;

  /// No description provided for @supportContactWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get supportContactWhatsapp;

  /// No description provided for @contactEmail.
  ///
  /// In es, this message translates to:
  /// **'Enviar Email'**
  String get contactEmail;

  /// No description provided for @contactWhatsApp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsApp;

  /// Formato de fecha para hoy
  ///
  /// In es, this message translates to:
  /// **'Hoy a las {time}'**
  String supportDateToday(String time);

  /// Formato de fecha para ayer
  ///
  /// In es, this message translates to:
  /// **'Ayer a las {time}'**
  String supportDateYesterday(String time);

  /// Hace X días
  ///
  /// In es, this message translates to:
  /// **'Hace {days} días'**
  String supportDateDaysAgo(int days);

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @settingsProfileSection.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get settingsProfileSection;

  /// No description provided for @settingsMyProfile.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get settingsMyProfile;

  /// No description provided for @settingsMyProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ver y editar información personal'**
  String get settingsMyProfileSubtitle;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Activar/desactivar notificaciones'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Oscuro'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar tema de la aplicación'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar idioma de la aplicación'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsHelpSection.
  ///
  /// In es, this message translates to:
  /// **'Ayuda y Soporte'**
  String get settingsHelpSection;

  /// No description provided for @settingsHelpCenter.
  ///
  /// In es, this message translates to:
  /// **'Centro de Ayuda'**
  String get settingsHelpCenter;

  /// No description provided for @settingsHelpCenterSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes y tutoriales'**
  String get settingsHelpCenterSubtitle;

  /// No description provided for @settingsContactSupport.
  ///
  /// In es, this message translates to:
  /// **'Contactar Soporte'**
  String get settingsContactSupport;

  /// No description provided for @settingsContactSupportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Obtener ayuda del equipo'**
  String get settingsContactSupportSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Versión 1.0.0'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In es, this message translates to:
  /// **'SmartMeal es tu asistente personal de nutrición y planificación de comidas.'**
  String get settingsAboutDescription;

  /// No description provided for @settingsAboutCopyright.
  ///
  /// In es, this message translates to:
  /// **'© 2025 SmartMeal. Todos los derechos reservados.'**
  String get settingsAboutCopyright;

  /// No description provided for @settingsLegalSection.
  ///
  /// In es, this message translates to:
  /// **'Legal'**
  String get settingsLegalSection;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsAndConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get settingsTermsAndConditions;

  /// No description provided for @privacyHeading.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad de SmartMeal'**
  String get privacyHeading;

  /// No description provided for @privacyUpdated.
  ///
  /// In es, this message translates to:
  /// **'Última actualización: {date}'**
  String privacyUpdated(Object date);

  /// No description provided for @privacySection1Title.
  ///
  /// In es, this message translates to:
  /// **'1. Información que recopilamos'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Body.
  ///
  /// In es, this message translates to:
  /// **'Recopilamos datos básicos de cuenta (email) y datos de uso necesarios para el funcionamiento de la app (por ejemplo, menús guardados, lista de la compra y preferencias).'**
  String get privacySection1Body;

  /// No description provided for @privacySection2Title.
  ///
  /// In es, this message translates to:
  /// **'2. Uso de la información'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Body.
  ///
  /// In es, this message translates to:
  /// **'Usamos tus datos para ofrecerte la funcionalidad de SmartMeal: generar menús, calcular estadísticas y enviar notificaciones si lo autorizas.'**
  String get privacySection2Body;

  /// No description provided for @privacySection3Title.
  ///
  /// In es, this message translates to:
  /// **'3. Almacenamiento y seguridad'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Body.
  ///
  /// In es, this message translates to:
  /// **'Almacenamos la información en Firebase. Tomamos medidas razonables para proteger tus datos, pero ningún sistema es 100% seguro.'**
  String get privacySection3Body;

  /// No description provided for @privacySection4Title.
  ///
  /// In es, this message translates to:
  /// **'4. Compartición de datos'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Body.
  ///
  /// In es, this message translates to:
  /// **'No vendemos tus datos. Podemos compartir información con proveedores de servicios estrictamente necesarios para operar la app (por ejemplo, Firebase).'**
  String get privacySection4Body;

  /// No description provided for @privacySection5Title.
  ///
  /// In es, this message translates to:
  /// **'5. Tus derechos'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Body.
  ///
  /// In es, this message translates to:
  /// **'Puedes solicitar acceso, rectificación o eliminación de tu cuenta desde Ajustes. Para otras solicitudes, contacta con soporte.'**
  String get privacySection5Body;

  /// No description provided for @privacySection6Title.
  ///
  /// In es, this message translates to:
  /// **'6. Contacto'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Body.
  ///
  /// In es, this message translates to:
  /// **'Si tienes dudas sobre esta política, utiliza la sección de Soporte en la app.'**
  String get privacySection6Body;

  /// No description provided for @termsHeading.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones de SmartMeal'**
  String get termsHeading;

  /// No description provided for @termsUpdated.
  ///
  /// In es, this message translates to:
  /// **'Última actualización: {date}'**
  String termsUpdated(Object date);

  /// No description provided for @termsSection1Title.
  ///
  /// In es, this message translates to:
  /// **'1. Aceptación de los términos'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Body.
  ///
  /// In es, this message translates to:
  /// **'Al utilizar SmartMeal aceptas estos términos. Si no estás de acuerdo, no uses la app.'**
  String get termsSection1Body;

  /// No description provided for @termsSection2Title.
  ///
  /// In es, this message translates to:
  /// **'2. Uso de la aplicación'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Body.
  ///
  /// In es, this message translates to:
  /// **'SmartMeal está destinada a uso personal. No garantizamos resultados nutricionales o médicos; utiliza la app como apoyo, no como asesoramiento profesional.'**
  String get termsSection2Body;

  /// No description provided for @termsSection3Title.
  ///
  /// In es, this message translates to:
  /// **'3. Contenido generado'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Body.
  ///
  /// In es, this message translates to:
  /// **'El contenido (menús, recetas) se genera para tu uso personal. No nos hacemos responsables del uso indebido.'**
  String get termsSection3Body;

  /// No description provided for @termsSection4Title.
  ///
  /// In es, this message translates to:
  /// **'4. Limitación de responsabilidad'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Body.
  ///
  /// In es, this message translates to:
  /// **'SmartMeal se ofrece \"tal cual\". No seremos responsables por daños indirectos o consecuentes derivados del uso de la app.'**
  String get termsSection4Body;

  /// No description provided for @termsSection5Title.
  ///
  /// In es, this message translates to:
  /// **'5. Cambios en los términos'**
  String get termsSection5Title;

  /// No description provided for @termsSection5Body.
  ///
  /// In es, this message translates to:
  /// **'Podemos actualizar estos términos. Te notificaremos cambios relevantes y la fecha de actualización.'**
  String get termsSection5Body;

  /// No description provided for @statsGoalTitle.
  ///
  /// In es, this message translates to:
  /// **'Objetivo calórico'**
  String get statsGoalTitle;

  /// No description provided for @statsGoalRatio.
  ///
  /// In es, this message translates to:
  /// **'{current} kcal / {target} kcal'**
  String statsGoalRatio(Object current, Object target);

  /// No description provided for @statsGoalPercent.
  ///
  /// In es, this message translates to:
  /// **'{percent}% del objetivo'**
  String statsGoalPercent(Object percent);

  /// No description provided for @statsGoalNoData.
  ///
  /// In es, this message translates to:
  /// **'Completa tu perfil para calcular tu objetivo calórico.'**
  String get statsGoalNoData;

  /// No description provided for @settingsAccountSection.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get settingsAccountSection;

  /// No description provided for @settingsSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get settingsSignOutDialogTitle;

  /// No description provided for @settingsSignOutDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get settingsSignOutDialogMessage;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get settingsDeleteAccountDialogTitle;

  /// No description provided for @settingsDeleteAccountDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y perderás todos tus datos.'**
  String get settingsDeleteAccountDialogMessage;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get settingsComingSoon;

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'SmartMeal'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Panel Principal'**
  String get homeSubtitle;

  /// No description provided for @homeWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenid@'**
  String get homeWelcome;

  /// No description provided for @homeDescription.
  ///
  /// In es, this message translates to:
  /// **'Accede rápidamente a todas las secciones de SmartMeal'**
  String get homeDescription;

  /// No description provided for @homeCardProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get homeCardProfileTitle;

  /// No description provided for @homeCardProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get homeCardProfileSubtitle;

  /// No description provided for @homeCardMenusTitle.
  ///
  /// In es, this message translates to:
  /// **'Menús'**
  String get homeCardMenusTitle;

  /// No description provided for @homeCardMenusSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Menús semanales'**
  String get homeCardMenusSubtitle;

  /// No description provided for @homeCardShoppingTitle.
  ///
  /// In es, this message translates to:
  /// **'Lista compra'**
  String get homeCardShoppingTitle;

  /// No description provided for @homeCardShoppingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get homeCardShoppingSubtitle;

  /// No description provided for @homeCardStatsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get homeCardStatsTitle;

  /// No description provided for @homeCardStatsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis nutricional'**
  String get homeCardStatsSubtitle;

  /// No description provided for @homeCardSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get homeCardSettingsTitle;

  /// No description provided for @homeCardSettingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get homeCardSettingsSubtitle;

  /// No description provided for @homeCardSupportTitle.
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get homeCardSupportTitle;

  /// No description provided for @homeCardSupportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get homeCardSupportSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get profileTitle;

  /// No description provided for @profileEditTooltip.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get profileEditTooltip;

  /// No description provided for @profileError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get profileError;

  /// No description provided for @profileNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos'**
  String get profileNoData;

  /// No description provided for @profileChangePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get profileChangePassword;

  /// No description provided for @profileSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileSignOut;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get profileDeleteAccount;

  /// No description provided for @profileChangePasswordSoon.
  ///
  /// In es, this message translates to:
  /// **'Cambio de contraseña próximamente'**
  String get profileChangePasswordSoon;

  /// No description provided for @profileDeleteAccountDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get profileDeleteAccountDialogTitle;

  /// No description provided for @profileDeleteAccountDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.'**
  String get profileDeleteAccountDialogMessage;

  /// No description provided for @profileDeleteAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get profileDeleteAccountConfirm;

  /// No description provided for @profilePersonalInfoSection.
  ///
  /// In es, this message translates to:
  /// **'Información Personal'**
  String get profilePersonalInfoSection;

  /// No description provided for @profileEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get profileEmailLabel;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get profilePhoneLabel;

  /// No description provided for @profileHeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Altura'**
  String get profileHeightLabel;

  /// No description provided for @profileWeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso'**
  String get profileWeightLabel;

  /// No description provided for @profileBmiLabel.
  ///
  /// In es, this message translates to:
  /// **'IMC'**
  String get profileBmiLabel;

  /// No description provided for @profileGoalsSection.
  ///
  /// In es, this message translates to:
  /// **'Objetivos y Preferencias'**
  String get profileGoalsSection;

  /// No description provided for @profileMainGoalLabel.
  ///
  /// In es, this message translates to:
  /// **'Objetivo Principal'**
  String get profileMainGoalLabel;

  /// No description provided for @profileAllergiesLabel.
  ///
  /// In es, this message translates to:
  /// **'Alergias Alimentarias'**
  String get profileAllergiesLabel;

  /// No description provided for @profileNoAllergies.
  ///
  /// In es, this message translates to:
  /// **'Sin alergias registradas'**
  String get profileNoAllergies;

  /// No description provided for @profileAccountSection.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Cuenta'**
  String get profileAccountSection;

  /// No description provided for @profileChangePasswordButton.
  ///
  /// In es, this message translates to:
  /// **'Cambiar Contraseña'**
  String get profileChangePasswordButton;

  /// No description provided for @profileSignOutButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get profileSignOutButton;

  /// No description provided for @profileDeleteAccountButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get profileDeleteAccountButton;

  /// No description provided for @goalLoseWeight.
  ///
  /// In es, this message translates to:
  /// **'Perder peso'**
  String get goalLoseWeight;

  /// No description provided for @goalMaintainWeight.
  ///
  /// In es, this message translates to:
  /// **'Mantener peso'**
  String get goalMaintainWeight;

  /// No description provided for @goalGainMuscle.
  ///
  /// In es, this message translates to:
  /// **'Ganar masa muscular'**
  String get goalGainMuscle;

  /// No description provided for @goalHealthyEating.
  ///
  /// In es, this message translates to:
  /// **'Alimentación saludable'**
  String get goalHealthyEating;

  /// No description provided for @profileBmiNormal.
  ///
  /// In es, this message translates to:
  /// **'Peso normal'**
  String get profileBmiNormal;

  /// No description provided for @profileBmiUnderweight.
  ///
  /// In es, this message translates to:
  /// **'Bajo peso'**
  String get profileBmiUnderweight;

  /// No description provided for @profileBmiOverweight.
  ///
  /// In es, this message translates to:
  /// **'Sobrepeso'**
  String get profileBmiOverweight;

  /// No description provided for @profileBmiObese.
  ///
  /// In es, this message translates to:
  /// **'Obesidad'**
  String get profileBmiObese;

  /// No description provided for @profileAgeLabel.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get profileAgeLabel;

  /// No description provided for @profileYearsOld.
  ///
  /// In es, this message translates to:
  /// **'años'**
  String get profileYearsOld;

  /// No description provided for @profileGenderLabel.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get profileGenderLabel;

  /// No description provided for @profileGenderMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get profileGenderFemale;

  /// No description provided for @profileGenderOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get profileGenderOther;

  /// No description provided for @editProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get editProfileTitle;

  /// No description provided for @editProfilePersonalInfo.
  ///
  /// In es, this message translates to:
  /// **'Información Personal'**
  String get editProfilePersonalInfo;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get editProfileEmailLabel;

  /// No description provided for @editProfilePhoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get editProfilePhoneLabel;

  /// No description provided for @editProfilePhysicalData.
  ///
  /// In es, this message translates to:
  /// **'Datos Físicos'**
  String get editProfilePhysicalData;

  /// No description provided for @editProfileHeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Altura (cm)'**
  String get editProfileHeightLabel;

  /// No description provided for @editProfileWeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get editProfileWeightLabel;

  /// No description provided for @editProfileGoalsPreferences.
  ///
  /// In es, this message translates to:
  /// **'Objetivos y Preferencias'**
  String get editProfileGoalsPreferences;

  /// No description provided for @editProfileAllergiesLabel.
  ///
  /// In es, this message translates to:
  /// **'Alergias Alimentarias (opcional)'**
  String get editProfileAllergiesLabel;

  /// No description provided for @editProfileSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get editProfileSaveButton;

  /// No description provided for @editProfileSaveSuccess.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado correctamente'**
  String get editProfileSaveSuccess;

  /// No description provided for @editProfileErrorNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get editProfileErrorNameRequired;

  /// No description provided for @editProfileErrorHeightInvalid.
  ///
  /// In es, this message translates to:
  /// **'La altura debe ser un número válido'**
  String get editProfileErrorHeightInvalid;

  /// No description provided for @editProfileErrorWeightInvalid.
  ///
  /// In es, this message translates to:
  /// **'El peso debe ser un número válido'**
  String get editProfileErrorWeightInvalid;

  /// No description provided for @editProfileErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar el perfil'**
  String get editProfileErrorGeneric;

  /// No description provided for @editProfileAgeLabel.
  ///
  /// In es, this message translates to:
  /// **'Edad (años)'**
  String get editProfileAgeLabel;

  /// No description provided for @editProfileAgeOptional.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get editProfileAgeOptional;

  /// No description provided for @editProfileGenderLabel.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get editProfileGenderLabel;

  /// No description provided for @editProfileGenderMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get editProfileGenderMale;

  /// No description provided for @editProfileGenderFemale.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get editProfileGenderFemale;

  /// No description provided for @editProfileGenderOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get editProfileGenderOther;

  /// No description provided for @editProfileErrorAgeInvalid.
  ///
  /// In es, this message translates to:
  /// **'La edad debe ser un número válido'**
  String get editProfileErrorAgeInvalid;

  /// No description provided for @menuTitle.
  ///
  /// In es, this message translates to:
  /// **'Menú semanal'**
  String get menuTitle;

  /// No description provided for @menuSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu menú personalizado'**
  String get menuSubtitle;

  /// No description provided for @menuLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar menús'**
  String get menuLoadError;

  /// No description provided for @menuEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes menús generados aún.'**
  String get menuEmpty;

  /// No description provided for @menuTotalCalories.
  ///
  /// In es, this message translates to:
  /// **'Calorías totales'**
  String get menuTotalCalories;

  /// No description provided for @menuAvgDaily.
  ///
  /// In es, this message translates to:
  /// **'Promedio diario'**
  String get menuAvgDaily;

  /// No description provided for @menuGenerateTooltip.
  ///
  /// In es, this message translates to:
  /// **'Generar nuevo menú'**
  String get menuGenerateTooltip;

  /// No description provided for @menuSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar'**
  String get menuSaveError;

  /// No description provided for @menuSaveSuccess.
  ///
  /// In es, this message translates to:
  /// **'Menú guardado correctamente'**
  String get menuSaveSuccess;

  /// No description provided for @menuCardComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get menuCardComingSoon;

  /// Texto de ayuda cuando no hay menús
  ///
  /// In es, this message translates to:
  /// **'Toca el botón + para generar tu primer menú'**
  String get menuEmptyHint;

  /// Etiqueta para fecha de creación
  ///
  /// In es, this message translates to:
  /// **'Creado'**
  String get menuCreated;

  /// Etiqueta para fecha de actualización
  ///
  /// In es, this message translates to:
  /// **'Actualizado'**
  String get menuUpdated;

  /// No description provided for @generateMenuTitle.
  ///
  /// In es, this message translates to:
  /// **'Generar Menú Semanal'**
  String get generateMenuTitle;

  /// No description provided for @generateMenuMainTitle.
  ///
  /// In es, this message translates to:
  /// **'Generación Inteligente de Menús'**
  String get generateMenuMainTitle;

  /// No description provided for @generateMenuDescription.
  ///
  /// In es, this message translates to:
  /// **'Crea un menú semanal personalizado basado en tu perfil, objetivos y restricciones alimentarias'**
  String get generateMenuDescription;

  /// No description provided for @generateMenuFeature1Title.
  ///
  /// In es, this message translates to:
  /// **'28 recetas únicas'**
  String get generateMenuFeature1Title;

  /// No description provided for @generateMenuFeature1Desc.
  ///
  /// In es, this message translates to:
  /// **'Desayuno, comida, cena y snack para cada día'**
  String get generateMenuFeature1Desc;

  /// No description provided for @generateMenuFeature2Title.
  ///
  /// In es, this message translates to:
  /// **'Personalizado con IA'**
  String get generateMenuFeature2Title;

  /// No description provided for @generateMenuFeature2Desc.
  ///
  /// In es, this message translates to:
  /// **'Adaptado a tus objetivos nutricionales'**
  String get generateMenuFeature2Desc;

  /// No description provided for @generateMenuFeature3Title.
  ///
  /// In es, this message translates to:
  /// **'Respeta tus alergias'**
  String get generateMenuFeature3Title;

  /// No description provided for @generateMenuFeature3Desc.
  ///
  /// In es, this message translates to:
  /// **'Sin ingredientes que no puedas consumir'**
  String get generateMenuFeature3Desc;

  /// No description provided for @generateMenuButton.
  ///
  /// In es, this message translates to:
  /// **'Generar Mi Menú Semanal'**
  String get generateMenuButton;

  /// No description provided for @generateMenuGenerating.
  ///
  /// In es, this message translates to:
  /// **'Generando menú...'**
  String get generateMenuGenerating;

  /// No description provided for @generateMenuWaitMessage.
  ///
  /// In es, this message translates to:
  /// **'Esto puede tardar unos segundos...'**
  String get generateMenuWaitMessage;

  /// No description provided for @generateMenuAutoMessage.
  ///
  /// In es, this message translates to:
  /// **'El menú se generará automáticamente según tu perfil'**
  String get generateMenuAutoMessage;

  /// No description provided for @generateMenuSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Menú generado con éxito!'**
  String get generateMenuSuccess;

  /// No description provided for @generateMenuTotalCalories.
  ///
  /// In es, this message translates to:
  /// **'Calorías totales'**
  String get generateMenuTotalCalories;

  /// No description provided for @generateMenuAvgCalories.
  ///
  /// In es, this message translates to:
  /// **'Promedio diario'**
  String get generateMenuAvgCalories;

  /// No description provided for @generateMenuDiscard.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get generateMenuDiscard;

  /// No description provided for @generateMenuSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar Menú'**
  String get generateMenuSave;

  /// Título de la vista previa del menú generado
  ///
  /// In es, this message translates to:
  /// **'Vista previa del menú'**
  String get generateMenuPreviewTitle;

  /// Botón para generar un nuevo menú
  ///
  /// In es, this message translates to:
  /// **'Regenerar'**
  String get generateMenuRegenerate;

  /// Botón para aceptar y guardar el menú
  ///
  /// In es, this message translates to:
  /// **'Aceptar y guardar'**
  String get generateMenuAccept;

  /// No description provided for @menuWeeklyTitle.
  ///
  /// In es, this message translates to:
  /// **'Menú Semanal'**
  String get menuWeeklyTitle;

  /// No description provided for @menuWeeklySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu plan nutricional personalizado'**
  String get menuWeeklySubtitle;

  /// No description provided for @menuTotalWeek.
  ///
  /// In es, this message translates to:
  /// **'esta semana'**
  String get menuTotalWeek;

  /// No description provided for @menuAlreadyGenerated.
  ///
  /// In es, this message translates to:
  /// **'Los ingredientes de este menú ya se habían añadido a la lista de compra'**
  String get menuAlreadyGenerated;

  /// No description provided for @shoppingTitle.
  ///
  /// In es, this message translates to:
  /// **'Lista de la Compra'**
  String get shoppingTitle;

  /// No description provided for @shoppingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get shoppingSubtitle;

  /// Número de productos en la lista de la compra
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin productos} one{{count} producto} other{{count} productos}}'**
  String shoppingItemsCount(int count);

  /// No description provided for @shoppingAddButton.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get shoppingAddButton;

  /// No description provided for @shoppingGenerateButton.
  ///
  /// In es, this message translates to:
  /// **'Generar'**
  String get shoppingGenerateButton;

  /// No description provided for @shoppingGeneratedFromMenus.
  ///
  /// In es, this message translates to:
  /// **'Lista generada desde menús'**
  String get shoppingGeneratedFromMenus;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Lista vacía'**
  String get shoppingEmptyTitle;

  /// No description provided for @editProfilePhotoUpdated.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil actualizada'**
  String get editProfilePhotoUpdated;

  /// No description provided for @shoppingEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Añade productos o genera desde menús'**
  String get shoppingEmptySubtitle;

  /// No description provided for @shoppingTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total Estimado'**
  String get shoppingTotalLabel;

  /// Productos seleccionados del total
  ///
  /// In es, this message translates to:
  /// **'{checked}/{total} productos'**
  String shoppingSelectedCount(int checked, int total);

  /// No description provided for @shoppingAddTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir Producto'**
  String get shoppingAddTitle;

  /// No description provided for @shoppingEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Producto'**
  String get shoppingEditTitle;

  /// No description provided for @shoppingProductNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Producto'**
  String get shoppingProductNameLabel;

  /// No description provided for @shoppingProductNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Arroz Basmati'**
  String get shoppingProductNameHint;

  /// No description provided for @shoppingQuantityLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get shoppingQuantityLabel;

  /// No description provided for @shoppingQuantityHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 500g, 1kg, 2 unidades'**
  String get shoppingQuantityHint;

  /// No description provided for @shoppingPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio (€)'**
  String get shoppingPriceLabel;

  /// No description provided for @shoppingPriceHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 3.50'**
  String get shoppingPriceHint;

  /// No description provided for @shoppingCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get shoppingCategoryLabel;

  /// No description provided for @shoppingMenusLabel.
  ///
  /// In es, this message translates to:
  /// **'Para qué menús (opcional)'**
  String get shoppingMenusLabel;

  /// No description provided for @shoppingMenusHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Pollo al curry, Ensalada César'**
  String get shoppingMenusHint;

  /// No description provided for @shoppingFormRequiredError.
  ///
  /// In es, this message translates to:
  /// **'Por favor completa todos los campos obligatorios'**
  String get shoppingFormRequiredError;

  /// No description provided for @shoppingSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar el producto'**
  String get shoppingSaveError;

  /// No description provided for @shoppingItemAdded.
  ///
  /// In es, this message translates to:
  /// **'Producto añadido a la lista'**
  String get shoppingItemAdded;

  /// No description provided for @shoppingItemUpdated.
  ///
  /// In es, this message translates to:
  /// **'Producto actualizado'**
  String get shoppingItemUpdated;

  /// No description provided for @shoppingAddItemButton.
  ///
  /// In es, this message translates to:
  /// **'Añadir a la Lista'**
  String get shoppingAddItemButton;

  /// No description provided for @shoppingEditItemButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get shoppingEditItemButton;

  /// No description provided for @shoppingCategoryFruits.
  ///
  /// In es, this message translates to:
  /// **'Frutas y Verduras'**
  String get shoppingCategoryFruits;

  /// No description provided for @shoppingCategoryMeat.
  ///
  /// In es, this message translates to:
  /// **'Carnes y Pescados'**
  String get shoppingCategoryMeat;

  /// No description provided for @shoppingCategoryDairy.
  ///
  /// In es, this message translates to:
  /// **'Lácteos'**
  String get shoppingCategoryDairy;

  /// No description provided for @shoppingCategoryBakery.
  ///
  /// In es, this message translates to:
  /// **'Panadería'**
  String get shoppingCategoryBakery;

  /// No description provided for @shoppingCategoryBeverages.
  ///
  /// In es, this message translates to:
  /// **'Bebidas'**
  String get shoppingCategoryBeverages;

  /// No description provided for @shoppingCategorySnacks.
  ///
  /// In es, this message translates to:
  /// **'Snacks'**
  String get shoppingCategorySnacks;

  /// No description provided for @shoppingCategoryOthers.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get shoppingCategoryOthers;

  /// No description provided for @shoppingFor.
  ///
  /// In es, this message translates to:
  /// **'Para'**
  String get shoppingFor;

  /// No description provided for @shoppingCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get shoppingCategory;

  /// No description provided for @shoppingDeleteCheckedTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar productos marcados'**
  String get shoppingDeleteCheckedTitle;

  /// No description provided for @shoppingDeleteCheckedMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar todos los productos marcados como comprados?'**
  String get shoppingDeleteCheckedMessage;

  /// No description provided for @shoppingDeleteCheckedTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar marcados'**
  String get shoppingDeleteCheckedTooltip;

  /// No description provided for @shoppingCheckAllTooltip.
  ///
  /// In es, this message translates to:
  /// **'Marcar todos'**
  String get shoppingCheckAllTooltip;

  /// No description provided for @shoppingUncheckAllTooltip.
  ///
  /// In es, this message translates to:
  /// **'Desmarcar todos'**
  String get shoppingUncheckAllTooltip;

  /// No description provided for @shoppingEditPriceTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar precio'**
  String get shoppingEditPriceTitle;

  /// Muestra el precio actual del producto
  ///
  /// In es, this message translates to:
  /// **'Precio actual: {price}€'**
  String shoppingEditPriceCurrentPrice(String price);

  /// Indica la unidad de medida del precio
  ///
  /// In es, this message translates to:
  /// **'Este precio se aplica por {unit}'**
  String shoppingEditPriceUnitInfo(String unit);

  /// No description provided for @shoppingEditPriceNewPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Nuevo precio (€)'**
  String get shoppingEditPriceNewPriceLabel;

  /// No description provided for @shoppingEditPriceNewPriceHint.
  ///
  /// In es, this message translates to:
  /// **'1.50'**
  String get shoppingEditPriceNewPriceHint;

  /// No description provided for @shoppingEditPriceReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Razón (opcional)'**
  String get shoppingEditPriceReasonLabel;

  /// No description provided for @shoppingEditPriceReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Oferta en mi supermercado'**
  String get shoppingEditPriceReasonHint;

  /// No description provided for @shoppingEditPriceReasonDefault.
  ///
  /// In es, this message translates to:
  /// **'Ajuste manual'**
  String get shoppingEditPriceReasonDefault;

  /// No description provided for @shoppingEditPriceInfo.
  ///
  /// In es, this message translates to:
  /// **'Este precio solo se aplicará a tu cuenta'**
  String get shoppingEditPriceInfo;

  /// No description provided for @shoppingEditPriceErrorInvalid.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce un precio válido mayor a 0'**
  String get shoppingEditPriceErrorInvalid;

  /// Error al guardar el precio personalizado
  ///
  /// In es, this message translates to:
  /// **'Error al guardar: {error}'**
  String shoppingEditPriceErrorSaving(String error);

  /// Error inesperado al guardar
  ///
  /// In es, this message translates to:
  /// **'Error inesperado: {error}'**
  String shoppingEditPriceErrorUnexpected(String error);

  /// No description provided for @shoppingEditPriceSuccess.
  ///
  /// In es, this message translates to:
  /// **'✅ Precio personalizado guardado'**
  String get shoppingEditPriceSuccess;

  /// No description provided for @shoppingEditPriceTooltip.
  ///
  /// In es, this message translates to:
  /// **'Editar precio'**
  String get shoppingEditPriceTooltip;

  /// No description provided for @recipeDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get recipeDescription;

  /// No description provided for @recipeIngredients.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes'**
  String get recipeIngredients;

  /// No description provided for @recipeTotalCalories.
  ///
  /// In es, this message translates to:
  /// **'Calorías totales'**
  String get recipeTotalCalories;

  /// No description provided for @recipeIngredientsPrefix.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes'**
  String get recipeIngredientsPrefix;

  /// No description provided for @noDataStats.
  ///
  /// In es, this message translates to:
  /// **'No hay datos de estadísticas'**
  String get noDataStats;

  /// No description provided for @avgDaily.
  ///
  /// In es, this message translates to:
  /// **'Media diaria'**
  String get avgDaily;

  /// No description provided for @kcal.
  ///
  /// In es, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @uniqueRecipes.
  ///
  /// In es, this message translates to:
  /// **'Recetas únicas'**
  String get uniqueRecipes;

  /// No description provided for @recipesUnit.
  ///
  /// In es, this message translates to:
  /// **'recetas'**
  String get recipesUnit;

  /// No description provided for @totalWeekly.
  ///
  /// In es, this message translates to:
  /// **'Total semanal'**
  String get totalWeekly;

  /// No description provided for @estimatedCost.
  ///
  /// In es, this message translates to:
  /// **'Coste estimado'**
  String get estimatedCost;

  /// No description provided for @euro.
  ///
  /// In es, this message translates to:
  /// **'€'**
  String get euro;

  /// No description provided for @macroDistribution.
  ///
  /// In es, this message translates to:
  /// **'Distribución de macros'**
  String get macroDistribution;

  /// No description provided for @protein.
  ///
  /// In es, this message translates to:
  /// **'Proteína'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In es, this message translates to:
  /// **'Carbohidratos'**
  String get carbs;

  /// No description provided for @fats.
  ///
  /// In es, this message translates to:
  /// **'Grasas'**
  String get fats;

  /// No description provided for @favoriteRecipes.
  ///
  /// In es, this message translates to:
  /// **'Recetas favoritas'**
  String get favoriteRecipes;

  /// No description provided for @mostUsedIngredients.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes más usados'**
  String get mostUsedIngredients;

  /// No description provided for @gramsPerDay.
  ///
  /// In es, this message translates to:
  /// **'g/día'**
  String get gramsPerDay;

  /// No description provided for @times.
  ///
  /// In es, this message translates to:
  /// **'x'**
  String get times;

  /// No description provided for @caloricGoal.
  ///
  /// In es, this message translates to:
  /// **'Objetivo calórico'**
  String get caloricGoal;

  /// No description provided for @highDeficit.
  ///
  /// In es, this message translates to:
  /// **'Déficit alto'**
  String get highDeficit;

  /// No description provided for @onTarget.
  ///
  /// In es, this message translates to:
  /// **'En objetivo'**
  String get onTarget;

  /// No description provided for @surplus.
  ///
  /// In es, this message translates to:
  /// **'Superávit'**
  String get surplus;

  /// No description provided for @percentOfGoal.
  ///
  /// In es, this message translates to:
  /// **'% del objetivo'**
  String get percentOfGoal;

  /// No description provided for @completeProfileForGoal.
  ///
  /// In es, this message translates to:
  /// **'Completa tu perfil para calcular tu objetivo calórico.'**
  String get completeProfileForGoal;

  /// No description provided for @notificationsEnabled.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones activadas'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones desactivadas'**
  String get notificationsDisabled;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
