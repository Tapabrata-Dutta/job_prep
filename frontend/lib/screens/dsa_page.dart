import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:place_prep/services/auth_service.dart';
import 'package:http/http.dart' as http;

class DsaPage extends StatefulWidget {
  const DsaPage({super.key});

  @override
  State<DsaPage> createState() => _DsaPageState();
}

class _DsaPageState extends State<DsaPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _editQuestionController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<_DsaItem> _items = [];
  String _errorMessage = '';
  bool _editSolved = false;
  int? _updatingItemId;

  String get _baseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000/api/dsa';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000/api/dsa';
  }
  return 'http://127.0.0.1:8000/api/dsa';
  }

  String get _baseUrlWithSlash {
    return '$_baseUrl/';
  }

  Map<String, String> get _defaultHeaders {
    return {
      'Content-Type': 'application/json',
      if (AuthService.token != null) 'Authorization': 'Bearer ${AuthService.token}',
    };
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _editQuestionController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      setState(() {
        _isLoading = false;
        _items = const [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _isSubmitting = false;
    });

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 8));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        setState(() {
          _items = data.map((item) => _DsaItem.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Unable to load DSA questions.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not reach backend. Start the backend server first.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _defaultHeaders,
        body: jsonEncode({'question': question, 'isSolve': false}),
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;
      if (response.statusCode == 201 || response.statusCode == 200) {
        _questionController.clear();
        await _loadQuestions();
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _errorMessage = body['message'] ?? 'Failed to add question';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not add question.';
        _isSubmitting = false;
      });
    }
  }

  Future<void> _updateQuestion(_DsaItem item, String question, bool isSolved) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrlWithSlash${item.id}'),
        headers: _defaultHeaders,
        body: jsonEncode({'question': question, 'isSolve': isSolved}),
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;
      if (response.statusCode == 200) {
        await _loadQuestions();
      } else {
        setState(() {
          _errorMessage = 'Could not update question.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not update question.';
      });
    }
  }

  Future<void> _toggleStatus(_DsaItem item) async {
    final nextValue = !item.isSolved;

    setState(() {
      _updatingItemId = item.id;
      _items = _items.map((entry) {
        if (entry.id == item.id) {
          return _DsaItem(id: entry.id, question: entry.question, isSolved: nextValue);
        }
        return entry;
      }).toList();
    });

    try {
      final response = await http.put(
        Uri.parse('$_baseUrlWithSlash${item.id}'),
        headers: _defaultHeaders,
        body: jsonEncode({'isSolve': nextValue}),
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;
      if (response.statusCode == 200) {
        await _loadQuestions();
      } else {
        setState(() {
          _errorMessage = 'Could not update status.';
        });
        await _loadQuestions();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not update status.';
      });
      await _loadQuestions();
    } finally {
      if (mounted) {
        setState(() {
          _updatingItemId = null;
        });
      }
    }
  }

  Future<void> _deleteQuestion(_DsaItem item) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrlWithSlash${item.id}'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 8));
      if (!mounted) return;
      if (response.statusCode == 200) {
        await _loadQuestions();
      } else {
        setState(() {
          _errorMessage = 'Could not delete question.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not delete question.';
      });
    }
  }

  void _showAddDialog() {
    _questionController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create DSA question'),
          content: TextField(
            controller: _questionController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Question'),
            onSubmitted: (_) async {
              Navigator.pop(context);
              await _addQuestion();
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: () async {
              Navigator.pop(context);
              await _addQuestion();
            }, child: const Text('Create')),
          ],
        );
      },
    );
  }

  void _showEditDialog(_DsaItem item) {
    _editQuestionController.text = item.question;
    _editSolved = item.isSolved;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update DSA question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editQuestionController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              SwitchListTile.adaptive(
                value: _editSolved,
                onChanged: (value) {
                  setState(() {
                    _editSolved = value;
                  });
                },
                title: const Text('Mark as solved'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: () async {
              Navigator.pop(context);
              if (_editQuestionController.text.trim().isNotEmpty) {
                await _updateQuestion(item, _editQuestionController.text.trim(), _editSolved);
              }
            }, child: const Text('Save')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final solvedCount = _items.where((item) => item.isSolved).length;
    final totalCount = _items.length;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to home',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('DSA Tracker'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DSA progress',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your daily DSA practice and sync it with the backend.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 110,
                    child: Row(
                      children: [
                        Expanded(child: _ProgressCard(title: 'Solved', value: '$solvedCount', color: Colors.green.shade600)),
                        const SizedBox(width: 10),
                        Expanded(child: _ProgressCard(title: 'Pending', value: '${totalCount - solvedCount}', color: Colors.orange.shade700)),
                        const SizedBox(width: 10),
                        Expanded(child: _ProgressCard(title: 'Total', value: '$totalCount', color: Colors.indigo.shade600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _questionController,
                            decoration: const InputDecoration(
                              labelText: 'Add a DSA question',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addQuestion(),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isSubmitting ? null : _addQuestion,
                              icon: _isSubmitting
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.add),
                              label: const Text('Add question'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_errorMessage, style: TextStyle(color: Colors.red.shade700)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    : _items.isEmpty
                        ? const Center(child: Text('No DSA questions yet.'))
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                child: ListTile(
                                  leading: _updatingItemId == item.id
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(
                                          item.isSolved ? Icons.check_circle : Icons.radio_button_unchecked,
                                          color: item.isSolved ? Colors.green : Colors.orange,
                                        ),
                                  title: Text(item.question, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  subtitle: Text(item.isSolved ? 'Solved' : 'Pending'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Switch.adaptive(
                                        value: item.isSolved,
                                        onChanged: (value) async {
                                          await _toggleStatus(item);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Update',
                                        onPressed: () => _showEditDialog(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: 'Delete',
                                        onPressed: () => _deleteQuestion(item),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DsaItem {
  _DsaItem({required this.id, required this.question, required this.isSolved});

  factory _DsaItem.fromJson(Map<String, dynamic> json) {
    final value = json['isSolve'];
    bool isSolved = false;

    if (value is bool) {
      isSolved = value;
    } else if (value is num) {
      isSolved = value != 0;
    } else if (value is String) {
      final normalized = value.trim().toLowerCase();
      isSolved = ['true', '1', 'yes', 'y', 'done', 'solved'].contains(normalized);
    }

    return _DsaItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      question: json['question']?.toString() ?? '',
      isSolved: isSolved,
    );
  }

  final int id;
  final String question;
  final bool isSolved;
}
