import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';

class DeviceBloc {
  final _flutterBlue = FlutterBlue.instance;
  final _devicesController =
      BehaviorSubject<List<BluetoothDevice>>(seedValue: []);
  final _scanStartController = PublishSubject<void>();

  DeviceBloc() {
    _flutterBlue.setLogLevel(LogLevel.emergency);
    _scanStartController.listen((_) async {
      _devicesController.add([]);
      final available = await _flutterBlue.isAvailable;
      if (available) {
        _flutterBlue
            .scan(timeout: Duration(seconds: 30))
            .listen((scanResult) async {
          final isNew = _devicesController.value
                  .map((device) => device.id.id)
                  .where((id) => scanResult.device.id.id == id)
                  .length ==
              0;
          if (isNew) {
            final newDevices = _devicesController.value;
            newDevices.add(scanResult.device);
            _devicesController.add(newDevices);
            if (scanResult.device.id.id == 'F4:0F:24:26:75:22') {
              final device = scanResult.device;
              final state = await device.state;
              if (state == BluetoothDeviceState.connected) {
                List<BluetoothService> services =
                    await scanResult.device.discoverServices();
                if (services.length > 0) {
                  device.writeCharacteristic(
                      services[0].characteristics[0], [0, 0]);
                  device.readCharacteristic(characteristic)
                }
              } else {
                _flutterBlue.connect(device).listen((state) async {
                  if (state == BluetoothDeviceState.connected) {
                    final services = await scanResult.device.discoverServices();
                    services.forEach((service) {
                      print(service);
                    });
                  }
                });
              }
            }
          }
        });
      } else {
        print('not available');
      }
    });
  }

  ValueObservable<List<BluetoothDevice>> get devices => _devicesController;

  Sink<void> get scan => _scanStartController.sink;

  void dispose() async {
    await _scanStartController.close();
    await _devicesController.close();
  }
}

class DeviceBlocProvider extends InheritedWidget {
  final DeviceBloc bloc;

  DeviceBlocProvider({
    Key key,
    @required Widget child,
    @required this.bloc,
  }) : super(key: key, child: child);

  static DeviceBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(DeviceBlocProvider)
            as DeviceBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(DeviceBlocProvider oldWidget) =>
      bloc != oldWidget.bloc;
}
