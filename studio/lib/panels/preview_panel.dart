import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:ritu/features/home/home_screen.dart';
import 'package:ritu/theme/ritu_theme.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final device = Devices.ios.iPhone13;

    return LayoutBuilder(
      builder: (context, constraints) {
        final frame = DeviceFrame(
          device: device,
          screen: MaterialApp(
            theme: buildRituTheme(),
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
          ),
        );

        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: device.screenSize.width,
              height: device.screenSize.height,
              child: frame,
            ),
          ),
        );
      },
    );
  }
}
