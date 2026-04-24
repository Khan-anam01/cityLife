import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global key accessible from anywhere in the widget tree
final scaffoldKey = GlobalKey<ScaffoldState>();

// Provider so any widget can access it via Riverpod
final scaffoldKeyProvider = Provider<GlobalKey<ScaffoldState>>(
  (ref) => scaffoldKey,
);
