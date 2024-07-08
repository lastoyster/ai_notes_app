import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoader {
  static CustomLoader? _customLoader;

  CustomLoader._createObject();

  factory CustomLoader() {
    if (_customLoader != null) {
      return _customLoader!;
    } else {
      _customLoader = CustomLoader._createObject();
      return _customLoader!;
    }
  }

  OverlayEntry? _overlayEntry;

  void _buildLoader(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildLoaderWidget(context),
    );
  }

  void showLoader(BuildContext context) {
    _buildLoader(context);
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void hideLoader() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildLoaderWidget(BuildContext context) {
    final darkMode = MediaQuery.of(context).platformBrightness == Brightness.light
        ? Colors.white
        : Colors.black;

    return Stack(
      children: [
        GestureDetector(
          onTap: hideLoader,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Center(
          child: Container(
            height: 150.0,
            width: 150.0,
            color: darkMode,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.network(
                  "https://assets1.lottiefiles.com/packages/lf20_drhp9zqp.json",
                  height: 100,
                  width: 100,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: use_key_in_widget_constructors
class CustomScreenLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
