# push_app

A new Flutter project.



### Configuraciones básicas

- Creamos las capetas `presentation` y `config`
- En la carpeta `config` creamos la capeta `theme` y `router`

- En la carpeta `theme` agregamos el archivo `app_theme.dart`
```dart
import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.red
  );
}
```

- En el archivo `main.dart` agregamos lo siguiente:

```dart
import 'package:flutter/material.dart';
import 'package:push_app/config/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,        // -> Quitamos el banner
      theme: AppTheme().getTheme(),             // -> Agregamos el theme
      home: Scaffold(
        body: Center(
          child: Text('Hello Mundo!'),
        ),
      ),
    );
  }
}
```

#### Instalamos los siguientes paquetes:

- `equatable, flutter_bloc, go_router`

- Creamos la carpeta `screens` dentro de la carpeta `presentation`
- Creamos el archivo `hom_screen.dart`

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permisos'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Solicitar permisos de notificaciones
            }, 
            icon: const Icon(Icons.settings)
          )
        ],
      ),
      body: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) {
        return const ListTile();
      },
    );
  }
}
```

- Agregamos el archivo `app_router.dart`, dentro de la carpeta `config -> router`

```dart
import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    )
  ]
);
```

- Modificamos el archivo `main.dart`, para agregar el router y quitar el home

```dart
import 'package:flutter/material.dart';
import 'package:push_app/config/router/app_router.dart';
import 'package:push_app/config/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(              // -> Se agreda el .router
    routerConfig: appRouter,                // -> Se agrega el routerConfig = appRouter
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
```


#### BLoc y FlutterFire

Documentación: https://firebase.flutter.dev/docs/messaging/notifications/

- Instalación de paquetes `flutter pub add firebase_messaging`

- Creamos la carpeta `blocs`, dentro de la carpeta `presentation`
- Click derecho a la carpeta `blocs` y seleccionamos `Bloc: New Bloc` y el bloc lo llamaremos `notifications`
- La carpeta `bloc` la renombramos por `notifications`

- Abrimos el archivo `notifications_state.dart`

```dart
part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {

  final AuthorizationStatus status;

  // TODO: Crear mi modelo de notiificaciones
  final List<dynamic> notifications;

  const NotificationsState({
    this.status = AuthorizationStatus.notDetermined, 
    this.notifications = const[],
  });

  NotificationsState copyWith({
    AuthorizationStatus? status,
    List<dynamic>? notifications,
  }) => NotificationsState(
    status: status ?? this.status,
    notifications: notifications ?? this.notifications
  );
  
  @override
  List<Object> get props => [ status, notifications ];
}
```

- Abrimos el archivo `notifications_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(NotificationsState()) {

    // on<NotificationsEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }
}
```

- Ahora necesitamos darle acceso al `NotificationsBloc` dentro de toda nuestra aplicación, abrimos el archivo `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/router/app_router.dart';

import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

void main() {

  runApp(
    MultiBlocProvider(                  // -> creamos el MultiBlocProvider en lo mas alto de la aplicación
      providers: [
        BlocProvider(
          create: (_) => NotificationsBloc()
        )
      ], 
      child: const MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
```

#### Solicitar Permisos de Notificaciones Push

- Primero agregamos el status de la notificación, abrimos el archivo `home_screen.dart` y agregamos

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.select(      // -> se agrega esto
          (NotificationsBloc bloc) => Text('${ bloc.state.status }')
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Solicitar permisos de notificaciones
            }, 
            icon: const Icon(Icons.settings)
          )
        ],
      ),
      body: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) {
        return const ListTile();
      },
    );
  }
}
```

- Vamos al archivo `notifications_bloc.dart` y creamos el metodo `requestPermission`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;     // -> Se agrego FirebaseMessaging

  NotificationsBloc() : super(NotificationsState()) {

    // on<NotificationsEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }

  //* Metodos
  void requestPermission() async {      // -> Se agrego el metodo requestPermission

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    settings.authorizationStatus;
  }
 }

```

- abrimos el archivo `home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.select(
          (NotificationsBloc bloc) => Text('${ bloc.state.status }')
        ),
        actions: [
          IconButton(
            onPressed: () {
              //* Solicitar permisos de notificaciones
              context.read<NotificationsBloc>().requestPermission();        // -> se agrego requestPermission
            }, 
            icon: const Icon(Icons.settings)
          )
        ],
      ),
      body: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) {
        return const ListTile();
      },
    );
  }
}
```

- Modificamos el archivo `android -> app -> build.gradle` y agregamos el `minSdkVersion 19`

```java
 defaultConfig {
    // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
    applicationId "com.example.push_app"
    // You can update the following values to match your application needs.
    // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
    minSdkVersion 19
    targetSdkVersion flutter.targetSdkVersion
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
}
```

#### Configurar Proyecto de Firebase

Documentación: https://firebase.google.com/docs/cli?hl=es-419#install-cli-mac-linux

- Instalamos el Referencia de Firebase CLI 
- Ejecutamos en la treminal el comando `curl -sL https://firebase.tools | bash` y cerramos la terminal

- Accede a Firebase con tu Cuenta de Google ejecutando el siguiente comando:
- `firebase login`


#### Cambar ID de la aplicación

- Abrimos el archivo `AndroidManifest.xml`  uw se encuentra en la ruta `android -> app -> src -> main`

```java
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.push_app">     // -> ID de la aplicación
</manifest>
```

- Cambiamos el ID de la aplicacion por:

Android

```java
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.valeroman.push_app">     // -> ID de la aplicación
</manifest>
```
- Buscamos en todo el proyecto la palabra `com.example.push_app` y lo reemplazamos en:

- En `android -> app` buscar el archivo `build.gradle`
- Abrimos el archivo `AndroidManifest.xml`  que se encuentra en la ruta `android -> app -> src -> debug`
- En `android -> app -> src -> main -> kotlin -> com -> example -> push_app`  buscar el archivo `MainActivity.kt`
- En `build -> app -> generated -> source -> buildConfig -> debug -> com -> example -> push_app`  buscar el archivo `BuildConfig.java`
- En 

- Cambiamos el nombre de la carpeta `example` por `valeroman`, que se encuentra en la ruta `android -> app -> src -> main -> kotlin -> com`

IOS

- Abrir el archivo `Runner.xcworkspace` se abre en el xcode, seleccionamos `Runner` Target `Runner` y `Signing & Capabilities` y cambiamos el Bundle Identifier `com.example.push_app` por `com.valeroman.push_app`


#### Configurar Flutter con el proyecto de firebase

Instalación de ```flutter pub add firebase_core```

- Install the CLI if not already done so
```dart pub global activate flutterfire_cli```

- Run the `configure` command, select a Firebase project and platforms
flutterfire configure

#### Asi si me funciono:

Open Terminal and run:

```dart
pub global activate flutterfire_cli
```
`export PATH="$PATH":"$HOME/.pub-cache/bin"`

Run: `flutterfire --version`

If you get a version number, flutterfire has been installed successfully.


#### Inicializar la aplicación de Firebase en Flutter

- Abrimos el archivo `main.dart` y agregamos `WidgetsFlutterBinding.ensureInitialized();`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/router/app_router.dart';

import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

void main() async {                                 // -> Se agrego el async

  WidgetsFlutterBinding.ensureInitialized();        // -> Se agrego esto
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => NotificationsBloc()
        )
      ], 
      child: const MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}

```

- Abrimos el archivo `notifications_bloc.dart` y agregamos un nuevo metodo `initializeFCM`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:push_app/firebase_options.dart';


part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(NotificationsState()) {

    // on<NotificationsEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }

  //* Metodos
  static Future<void> initializeFCM() async {       // -> Se agrego nuevo metodo initializeFCM
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
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

    settings.authorizationStatus;
  }
 }
```

- Ahora agregamos en el archivo `main.dart` el `await NotificationsBloc.initializeFCM();`


```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/router/app_router.dart';

import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsBloc.initializeFCM();      // -> Se agrego esto
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => NotificationsBloc()
        )
      ], 
      child: const MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}

```


#### Actualizar el estado acorde a los permisos

- Agregamos un evento en el archivo `notifications_event.dart` llamado `NotificationStatusChange`

```dart
part of 'notifications_bloc.dart';

abstract class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;

  NotificationStatusChanged(this.status);
}
```

- Agregamos el nuevo metodo en el archivo `notifications_bloc.dart`, llamado `_notificationStatusChanged`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:push_app/firebase_options.dart';


part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(NotificationsState()) {

    on<NotificationStatusChanged>( _notificationStatusChanged );
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

    // * Agregar un nuevo emento add(NotificationStatusChanged)
    add(NotificationStatusChanged(settings.authorizationStatus));
  }
 }
```

#### Token del dispositivo y determinar permiso actual

- Abrimos el archivo `notifications_bloc.dart` y agregamos lo metodos: `_initialStatusCheck` y `_getFCMToken`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:push_app/firebase_options.dart';


part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(NotificationsState()) {

    on<NotificationStatusChanged>( _notificationStatusChanged );

    _initialStatusCheck();      // -> Se llama el motodo _initialStatusCheck
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

    _getFCMToken();     // -> Se llama el metodo _getFCMToken
  }

  void _initialStatusCheck() async {        // -> Se agrego el metodo
    final settings = await messaging.getNotificationSettings();
     add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _getFCMToken() async {               // -> Se agrego el metodo
    if ( state.status != AuthorizationStatus.authorized ) return;

    final token = await messaging.getToken();
    print(token);
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

    // * Agregar un nuevo emento add(NotificationStatusChanged)
    add(NotificationStatusChanged(settings.authorizationStatus));
  }
 }

```


#### Escuchar mensaje push

- Abrimos el archivo `notifications_bloc.dat` y agregamos los metodos `_handleRemoteMessage` y `_onForegroundMessage`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:push_app/firebase_options.dart';


part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(NotificationsState()) {

    on<NotificationStatusChanged>( _notificationStatusChanged );

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

  void _handleRemoteMessage( RemoteMessage message ) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification == null) return;

    print('Message also contained a notification: ${message.notification}');
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
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

    // * Agregar un nuevo emento add(NotificationStatusChanged)
    add(NotificationStatusChanged(settings.authorizationStatus));
  }
 }

```

#### Recibir Nuestra Primera Notificación Push

Configuración en Firebase video `Recibir nuestra primera notificación Push`


#### Notificaciones cuando la app está terminada

- Abrimos el archivo `notifications_bloc.dart` y colocamos en lo mas arriba la function `firebaseMessagingBackgroundHandler`

```dart
// Cuando la notificación corre en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}
```

- Ahora llamamos la función el el archivo `main.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/router/app_router.dart';

import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);        // -> Se agrego esto
  
  await NotificationsBloc.initializeFCM();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => NotificationsBloc()
        )
      ], 
      child: const MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}

```

#### Entidad para el manejo de notificaciones

- Creamos la entidad `push_message.dart` en la carpeta `domain -> entities`

```dart

class PushMessage {

  final String messageId;
  final String title;
  final String body;
  final DateTime sentDate;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  PushMessage({
    required this.messageId, 
    required this.title, 
    required this.body, 
    required this.sentDate, 
    this.data, 
    this.imageUrl
  });

  // Para imprimir en consola
  @override
  String toString() {
    return '''
PushMessage -
id:     $messageId
title:  $title
body:   $body
data:   $data
sentDate: $sentDate
imageUrl: $imageUrl
''';
  }
}
```

- Ahora agregamos el `PushMessage` en el archivo `notifications_state.dart`

```dart
part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {

  final AuthorizationStatus status;

  final List<PushMessage> notifications;        // -> Agregamos el tupo de dato PushMessage

  const NotificationsState({
    this.status = AuthorizationStatus.notDetermined, 
    this.notifications = const[],
  });

  NotificationsState copyWith({
    AuthorizationStatus? status,
    List<PushMessage>? notifications,            // -> Agregamos el tupo de dato PushMessage
  }) => NotificationsState(
    status: status ?? this.status,
    notifications: notifications ?? this.notifications
  );
  
  @override
  List<Object> get props => [ status, notifications ];
}


```

- Abrimos el archivo `notifications_bloc.dart` y actualizamos el metodo `_handleRemoteMessage`

```dart
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/domain/entities/push_message.dart';

import 'package:push_app/firebase_options.dart';




part 'notifications_event.dart';
part 'notifications_state.dart';

// Cuando la notificación corre en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}


class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {

    on<NotificationStatusChanged>( _notificationStatusChanged );

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

  void _handleRemoteMessage( RemoteMessage message ) {
  
    if (message.notification == null) return;

    final notitication = PushMessage(       // -> Se agrego el PushMessage
      messageId: message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '', 
      title: message.notification!.title ?? '', 
      body: message.notification!.body ?? '', 
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid 
        ? message.notification!.android?.imageUrl 
        : message.notification!.apple?.imageUrl
    );

    print(notitication);
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
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

    // * Agregar un nuevo emento add(NotificationStatusChanged)
    add(NotificationStatusChanged(settings.authorizationStatus));
  }
 }

```


#### Actualizar el estado con la nueva Notificación

- Creamos un nuevo evento `NotificationReceived`, en el archivo `notifications_event.dart`

```dart
part of 'notifications_bloc.dart';

abstract class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;

  NotificationStatusChanged(this.status);
}

 class NotificationReceived extends NotificationsEvent {        // -> Nuevo evento
  final PushMessage pushMessage;
  NotificationReceived(this.pushMessage);

 }

```

- Agregamos un nuevo metodo `_onPushMessageReceived`, en el archivo `notificactions_bloc.dart`

```dart
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/domain/entities/push_message.dart';

import 'package:push_app/firebase_options.dart';




part 'notifications_event.dart';
part 'notifications_state.dart';

// Cuando la notificación corre en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}


class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {

    on<NotificationStatusChanged>( _notificationStatusChanged );
    on<NotificationReceived>( _onPushMessageReceived );             // -> Se agrego el llamado

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


  void _onPushMessageReceived( NotificationReceived event, Emitter<NotificationsState> emit ) async {       // -> Nuevo metodo _onPushMessageReceived
    emit(
      state.copyWith(
        notifications: [ event.pushMessage, ...state.notifications ]
      )
    );
  }

  void _handleRemoteMessage( RemoteMessage message ) {
  
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

    add(NotificationReceived(notitication));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
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

    // * Agregar un nuevo emento add(NotificationStatusChanged)
    add(NotificationStatusChanged(settings.authorizationStatus));
  }
 }

```

- Actualozamos el archivo `home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.select(
          (NotificationsBloc bloc) => Text('${ bloc.state.status }')
        ),
        actions: [
          IconButton(
            onPressed: () {
              //* Solicitar permisos de notificaciones
              context.read<NotificationsBloc>().requestPermission();
            }, 
            icon: const Icon(Icons.settings)
          )
        ],
      ),
      body: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {

    final notifications = context.watch<NotificationsBloc>().state.notifications;       // -> Se agrego nuevo

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.body),
          leading: notification.imageUrl != null
            ? Image.network(notification.imageUrl!)
            : null
        );
      },
    );
  }
}
```


#### Segunda pantalla - Información de la notificación

- Creamos un nuevo metodo `getMessageById`, en el archivo `notifications_bloc.dart`


```dart
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/domain/entities/push_message.dart';

import 'package:push_app/firebase_options.dart';




part 'notifications_event.dart';
part 'notifications_state.dart';

// Cuando la notificación corre en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}


class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {

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

  void _handleRemoteMessage( RemoteMessage message ) {
  
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

    add(NotificationReceived(notitication));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
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

    // * Agregar un nuevo emento add(NotificationStatusChanged)
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageById( String pushMessageId ) {     // => NUevo metodo

    final exist = state.notifications.any((element) => element.messageId == pushMessageId);
    if ( !exist ) return null;

    return state.notifications.firstWhere((element) => element.messageId == pushMessageId);
  }

 }

```

- Creamos el archivo `details_scree.dart` 

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class DetailsScreen extends StatelessWidget {

  final String pushMessageId;

  const DetailsScreen({super.key, required this.pushMessageId});

  @override
  Widget build(BuildContext context) {

    final PushMessage? message = context.watch<NotificationsBloc>().getMessageById(pushMessageId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles Puah'),
      ),
      body: (message != null)
        ? _DetailsView(message: message)
        : const Center( child: Text('Notificación no existe'))
    );
  }
}

class _DetailsView extends StatelessWidget {

  final PushMessage message;

  const _DetailsView({required this.message});

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric( horizontal: 10, vertical: 20 ),
      child: Column(
        children: [

          if ( message.imageUrl != null )
            Image.network(message.imageUrl!),

          const SizedBox( height: 30 ),

          Text(message.title, style: textStyles.titleMedium),
          Text(message.body),

          const Divider(),
          Text(message.data.toString())

        ],
      ),
    );
  }
}
```

#### Navegar a la segunda pantalla

- Abrimos el archivo `app_router.dart` y configuramos la nueva ruta

```dart
import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/screens/details_screen.dart';
import 'package:push_app/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/push-details/:messageId',
      builder: (context, state) => DetailsScreen( pushMessageId: state.params['messageId'] ?? ''),
    )
  ]
);
```

- Agregamos el onTag en el archivo `home_screen.dart`, para navegar a la pagina de detalles

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.select(
          (NotificationsBloc bloc) => Text('${ bloc.state.status }')
        ),
        actions: [
          IconButton(
            onPressed: () {
              //* Solicitar permisos de notificaciones
              context.read<NotificationsBloc>().requestPermission();
            }, 
            icon: const Icon(Icons.settings)
          )
        ],
      ),
      body: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {

    final notifications = context.watch<NotificationsBloc>().state.notifications;

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.body),
          leading: notification.imageUrl != null
            ? Image.network(notification.imageUrl!)
            : null,
          onTap: () {
            context.push('/push-details/${ notification.messageId }');
          },
        );
      },
    );
  }
}
```

#### Manejar interacciones con las notificaciones

- Abrimos el archivo `main.dart` y creamos un nuevo widget `StatefulWidget` llamado `HandleNotificationInteraccions`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/router/app_router.dart';

import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  await NotificationsBloc.initializeFCM();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => NotificationsBloc()
        )
      ], 
      child: const MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      builder: (context, child) => HandleNotificationInteraccions(child: child!),
    );
  }
}

class HandleNotificationInteraccions extends StatefulWidget {

  final Widget child;

  const HandleNotificationInteraccions({
    super.key, 
    required this.child
  });

  @override
  State<HandleNotificationInteraccions> createState() => _HandleNotificationInteraccionsState();
}

class _HandleNotificationInteraccionsState extends State<HandleNotificationInteraccions> {

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }
  
  void _handleMessage(RemoteMessage message) {

    context.read<NotificationsBloc>().handleRemoteMessage(message);

    final messageId = message.messageId?.replaceAll(':', '').replaceAll('%', '');
    appRouter.push('/push-details/$messageId');
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

```

- Abrimos el archivo `notifications_bloc.dart` y cambiamos el metodo privado `_handleRemoteMessage` a publico `handleRemoteMessage`

```dart
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  NotificationsBloc() : super(const NotificationsState()) {

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

    // * Agregar un nuevo emento add(NotificationStatusChanged)
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageById( String pushMessageId ) {

    final exist = state.notifications.any((element) => element.messageId == pushMessageId);
    if ( !exist ) return null;

    return state.notifications.firstWhere((element) => element.messageId == pushMessageId);
  }

 }

```