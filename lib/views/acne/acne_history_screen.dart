import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/acne_storage_service.dart';
import 'widgets/history/acne_history_app_bar.dart';
import 'widgets/history/acne_empty_state.dart';
import 'widgets/history/acne_result_card.dart';
import 'handlers/acne_history_handlers.dart';

class AcneHistoryScreen extends StatefulWidget {
  const AcneHistoryScreen({super.key});

  @override
  State<AcneHistoryScreen> createState() => _AcneHistoryScreenState();
}

class _AcneHistoryScreenState extends State<AcneHistoryScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  late final AcneHistoryHandlers _handlers;

  @override
  void initState() {
    super.initState();
    _handlers = AcneHistoryHandlers(
      context: context,
      onRefresh: _loadResults,
    );
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);

    try {
      final results = await AcneStorageService.getAllResults();
      final stats = await AcneStorageService.getStorageStats();

      setState(() {
        _results = results;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AcneHistoryAppBar(
        onRefresh: _loadResults,
        onClearOld: () => _handlers.handleClearOld(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('acne'),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Phân tích mới'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: _results.isEmpty
                ? AcneEmptyState(
              onAnalyze: () => context.pushNamed('acne'),
            )
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return AcneResultCard(
          result: result,
          onView: () => _handlers.handleViewDetail(context, result),
          onDelete: () => _handlers.handleDelete(
            context,
            result,
            index,
                () {
              setState(() => _results.removeAt(index));
              _loadResults();
            },
          ),
        );
      },
    );
  }
}