import 'package:ble_test/bloc/device_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanDevices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = DeviceBlocProvider.of(context);
    return Scaffold(
      body: Container(
        child: StreamBuilder<List<BluetoothDevice>>(
          stream: bloc.devices,
          initialData: bloc.devices.value,
          builder: (context, snap) => Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 200,
                      child: FlatButton(
                        onPressed: () => bloc.scan.add(null),
                        child: Text('scan'),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: snap.data.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(snap.data[index].name),
                              leading: Text(snap.data[index].id.id),
                            );
                          }),
                    )
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
