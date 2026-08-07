import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:ritu/features/home/home_screen.dart';
import 'package:ritu/theme/ritu_theme.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DeviceFrame(
        device: Devices.ios.iPhone13,
        screen: MaterialApp(
          theme: buildRituTheme(),
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
