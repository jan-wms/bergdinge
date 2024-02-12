import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final VoidCallback onInit;
  const LoadingPage({super.key, required this.onInit});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          Text('App wird eingerichtet...'),
        ],
      ),
    );
  }
}
