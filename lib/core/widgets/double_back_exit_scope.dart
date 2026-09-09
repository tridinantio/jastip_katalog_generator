import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ExitAppCallback = Future<void> Function();

class DoubleBackExitScope extends StatefulWidget {
  const DoubleBackExitScope({
    required this.child,
    this.exitInterval = const Duration(seconds: 2),
    this.onExit,
    super.key,
  });

  final Widget child;
  final Duration exitInterval;
  final ExitAppCallback? onExit;

  @override
  State<DoubleBackExitScope> createState() => _DoubleBackExitScopeState();
}

class _DoubleBackExitScopeState extends State<DoubleBackExitScope> {
  DateTime? _lastBackAttempt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackAttempt();
      },
      child: widget.child,
    );
  }

  void _handleBackAttempt() {
    final now = DateTime.now();
    final previousAttempt = _lastBackAttempt;
    if (previousAttempt != null &&
        now.difference(previousAttempt) <= widget.exitInterval) {
      _lastBackAttempt = null;
      final onExit = widget.onExit;
      unawaited(onExit == null ? SystemNavigator.pop() : onExit());
      return;
    }

    _lastBackAttempt = now;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Tekan kembali sekali lagi untuk keluar'),
          duration: widget.exitInterval,
        ),
      );
  }
}
