import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/index_page.dart';
import 'pages/upload_page.dart';
import 'pages/results_page.dart';
import 'pages/not_found_page.dart';
import 'pages/coach_builder_page.dart';
import 'pages/camera_page.dart';

void main() {
  runApp(StrideApp());
}

class StrideApp extends StatelessWidget {
  StrideApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const IndexPage(),
      ),
      GoRoute(
        path: '/upload',
        builder: (context, state) => const UploadPage(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => const ResultsPage(),
      ),
      GoRoute(
        path: '/coach-builder',
        builder: (context, state) => const CoachBuilderPage(),
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraPage(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Stride',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Inter',
      ),
      routerConfig: _router,
    );
  }
}
