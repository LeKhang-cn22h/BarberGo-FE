import 'package:barbergofe/services/hair_storage_service..dart';
import 'package:barbergofe/views/hair/%20widgets/history/hair_empty_state.dart';
import 'package:barbergofe/views/hair/%20widgets/history/hair_history_app_bar.dart';
import 'package:barbergofe/views/hair/%20widgets/history/hair_result_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'handlers/hair_history_handlers.dart';

class HairHistoryScreen extends StatefulWidget {
  const HairHistoryScreen({super.key});

  @override
  State<HairHistoryScreen> createState() => _HairHistoryScreenState();
}

class _HairHistoryScreenState extends State<HairHistoryScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  late final HairHistoryHandlers _handlers;

  @override
  void initState() {
    super.initState();
    _handlers = HairHistoryHandlers(
      context: context,
      onRefresh: _loadResults,
    );
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);

    try {
      final results = await HairStorageService.getAllResults();
      final stats = await HairStorageService.getStorageStats();

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
      appBar: HairHistoryAppBar(
        onRefresh: _loadResults,
        onClearOld: () => _handlers.handleClearOld(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('hair'),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Tạo mới'),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? HairEmptyState(onAnalyze: () => context.pushNamed('hair'))
          : _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return HairResultCard(
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