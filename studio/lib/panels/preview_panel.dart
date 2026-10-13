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
          child: _TiltingPhone(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: device.screenSize.width,
                height: device.screenSize.height,
                child: frame,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Turns the phone a few degrees toward the pointer, with a shadow that
/// slides the other way so the frame reads as an object on the page.
class _TiltingPhone extends StatefulWidget {
  const _TiltingPhone({required this.child});

  final Widget child;

  @override
  State<_TiltingPhone> createState() => _TiltingPhoneState();
}

class _TiltingPhoneState extends State<_TiltingPhone>
    with SingleTickerProviderStateMixin {
  /// About 7 degrees. Enough to read as depth, still easy to tap.
  static const _maxTilt = 0.12;

  final _tilt = ValueNotifier<Offset>(Offset.zero);
  Offset _target = Offset.zero;
  late final AnimationController _follow;

  @override
  void initState() {
    super.initState();
    _follow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addListener(_tick);
  }

  @override
  void dispose() {
    _follow.removeListener(_tick);
    _follow.dispose();
    _tilt.dispose();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final next = Offset.lerp(_tilt.value, _target, 0.18)!;
    if ((next - _target).distance < 0.004) {
      _tilt.value = _target;
      _follow.stop();
      return;
    }
    _tilt.value = next;
  }

  void _aim(Offset target) {
    _target = target;
    if (!_follow.isAnimating) {
      _follow.repeat();
    }
  }

  void _onHover(PointerEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final size = box.size;
    if (size.width == 0 || size.height == 0) return;
    final local = box.globalToLocal(event.position);
    final nx = ((local.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
    final ny = ((local.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    _aim(Offset(nx, ny));
  }

  void _onExit(PointerEvent event) {
    _aim(Offset.zero);
  }

  Matrix4 _transformFor(Offset tilt) {
    return Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(tilt.dy * _maxTilt)
      ..rotateY(-tilt.dx * _maxTilt);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: ValueListenableBuilder<Offset>(
        valueListenable: _tilt,
        child: widget.child,
        builder: (context, tilt, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: _GroundShadow(tilt: tilt)),
              Transform(
                alignment: Alignment.center,
                transform: _transformFor(tilt),
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroundShadow extends StatelessWidget {
  const _GroundShadow({required this.tilt});

  final Offset tilt;

  @override
  Widget build(BuildContext context) {
    final lean = tilt.distance.clamp(0.0, 1.0);
    return Align(
      alignment: Alignment(-tilt.dx * 0.45, 1.04 + tilt.dy * 0.08),
      child: FractionallySizedBox(
        widthFactor: 0.52 + lean * 0.06,
        heightFactor: 0.028,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(76, 71, 68, 0.16 + lean * 0.08),
                blurRadius: 28 + lean * 10,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
