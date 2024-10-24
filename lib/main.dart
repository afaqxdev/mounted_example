import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CounterModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/details': (context) => const DetailsScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Simulate API call or data loading
    await Future.delayed(const Duration(seconds: 2));

    // Check if widget is still mounted before updating state
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    try {
      // Simulate async operation
      await Future.delayed(const Duration(seconds: 1));

      // Only update state if widget is still mounted
      if (mounted) {
        context.read<CounterModel>().increment();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Handle error if widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error refreshing data')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<CounterModel>(
                    builder: (context, counter, child) => Text(
                      'Count: ${counter.count}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/details');
                    },
                    child: const Text('Go to Details'),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : () {
                context.read<CounterModel>().increment();
              },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// lib/screens/details_screen.dart

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Timer? _autoUpdateTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startAutoUpdate();
  }

  void _startAutoUpdate() {
    _autoUpdateTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Check if mounted before starting async operation
      if (!mounted) return;

      setState(() => _isLoading = true);

      try {
        // Simulate async operation
        await Future.delayed(const Duration(seconds: 1));

        // Check mounted again after async operation
        if (mounted) {
          context.read<CounterModel>().increment();
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _autoUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<CounterModel>(
                  builder: (context, counter, child) => Text(
                    'Count from Details: ${counter.count}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Positioned(
              top: 16,
              right: 16,
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : () {
                context.read<CounterModel>().increment();
              },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// lib/models/counter_model.dart

class CounterModel extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}
