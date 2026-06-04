import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();
  }

  Future<void> programarNotificacionToma({
    required int id,
    required String medicamento,
    required String dosis,
    required DateTime horaProgramada,
  }) async {
    final ahora = DateTime.now();
    if (horaProgramada.isBefore(ahora)) return;

    const androidDetails = AndroidNotificationDetails(
      'tomas_channel',
      'Recordatorios de tomas',
      channelDescription: 'Notificaciones para recordar tomar medicamentos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      id,
      '💊 Hora de tomar tu medicamento',
      '$medicamento — $dosis',
      tz.TZDateTime.from(horaProgramada, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> programarTodasLasTomas({
    required int tratamientoId,
    required String medicamento,
    required String dosis,
    required List<DateTime> horasProgramadas,
  }) async {
    for (int i = 0; i < horasProgramadas.length; i++) {
      await programarNotificacionToma(
        id: tratamientoId * 1000 + i,
        medicamento: medicamento,
        dosis: dosis,
        horaProgramada: horasProgramadas[i],
      );
    }
  }

  Future<void> cancelarNotificacionesTratamiento(int tratamientoId) async {
    for (int i = 0; i < 1000; i++) {
      await _plugin.cancel(tratamientoId * 1000 + i);
    }
  }

  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }
}
