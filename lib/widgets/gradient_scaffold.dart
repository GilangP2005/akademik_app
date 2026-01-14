import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget child;
  final Widget? title;
  final List<Widget>? actions;
  final bool safeArea;

  const GradientScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: title,
        actions: actions,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1B4B), // ungu gelap
              Color(0xFF3730A3), // ungu
              Color(0xFF2563EB), // biru
            ],
          ),
        ),
        child: safeArea
            ? SafeArea(child: child)
            : child,
      ),
    );
  }
}
