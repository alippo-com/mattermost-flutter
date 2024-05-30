import 'package:permission_handler/permission_handler.dart';

Future<bool> hasBluetoothPermission() async {
  Permission bluetooth = Permission.bluetooth;

  PermissionStatus status = await bluetooth.status;

  switch (status) {
    case PermissionStatus.denied:
    case PermissionStatus.restricted:
      PermissionStatus requestStatus = await bluetooth.request();
      return requestStatus == PermissionStatus.granted;
    case PermissionStatus.permanentlyDenied:
      return false;
    default:
      return true;
  }
}

Future<bool> hasMicrophonePermission() async {
  Permission microphone = Permission.microphone;

  PermissionStatus status = await microphone.status;

  switch (status) {
    case PermissionStatus.denied:
    case PermissionStatus.restricted:
      PermissionStatus requestStatus = await microphone.request();
      return requestStatus == PermissionStatus.granted;
    case PermissionStatus.permanentlyDenied:
      return false;
    default:
      return true;
  }
}
