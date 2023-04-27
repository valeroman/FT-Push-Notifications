import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/config/local_notifications/local_notifications.dart';
import 'package:push_app/domain/entities/push_message.dart';

import 'package:push_app/firebase_options.dart';




part 'notifications_event.dart';
part 'notifications_state.dart';

// Cuando la notificación corre en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  // print("Handling a background message: ${message.messageId}");
}


class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  int pushNumberId = 0;

// * Nuevas propiedades
// * Creamos una funtion que retorna un Future<void>
  final Future<void> Function()? requestLocalNotificationPermission;
  final void Function({
    required int id,
    String? title,
    String? body,
    String? data,
  })? showLocalNotification;
    

  NotificationsBloc({
    this.requestLocalNotificationPermission,
    this.showLocalNotification
  }) : super(const NotificationsState()) {

    on<NotificationStatusChanged>( _notificationStatusChanged );
    on<NotificationReceived>( _onPushMessageReceived );

    // * Verificar estados de las notificaciones
    _initialStatusCheck();

    // * Listener para notificaciones en Foreground
    _onForegroundMessage();
  }

  //* Metodos
  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  }

  void _notificationStatusChanged( NotificationStatusChanged  event, Emitter<NotificationsState> emit ) {
    emit(
      state.copyWith(
        status: event.status
      )
    );

    _getFCMToken();
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
     add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _getFCMToken() async {
    if ( state.status != AuthorizationStatus.authorized ) return;

    final token = await messaging.getToken();
    print(token);
  }

  void _onPushMessageReceived( NotificationReceived event, Emitter<NotificationsState> emit ) async {
    emit(
      state.copyWith(
        notifications: [ event.pushMessage, ...state.notifications ]
      )
    );
  }

  void handleRemoteMessage( RemoteMessage message ) {
  
    if (message.notification == null) return;

    final notitication = PushMessage(
      messageId: message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '', 
      title: message.notification!.title ?? '', 
      body: message.notification!.body ?? '', 
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid 
        ? message.notification!.android?.imageUrl 
        : message.notification!.apple?.imageUrl
    );

    if ( showLocalNotification != null ) {
      showLocalNotification!(
        id:++pushNumberId,
        body: notitication.body,
        data: notitication.messageId,
        title: notitication.title
      );
    }


    add(NotificationReceived(notitication));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermission() async {

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // * Solicitar permiso a las local notifications
    if( requestLocalNotificationPermission != null ) {
      await requestLocalNotificationPermission!();
      // await LocalNotifications.requestPermissiionLocalNotifications();
    }    

    // * Agregar un nuevo emento add(NotificationStatusChanged)
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageById( String pushMessageId ) {

    final exist = state.notifications.any((element) => element.messageId == pushMessageId);
    if ( !exist ) return null;

    return state.notifications.firstWhere((element) => element.messageId == pushMessageId);
  }

 }
