import 'package:flutter/material.dart';
import 'package:place_prep/models/application_model.dart';
import 'package:place_prep/services/application_service.dart';

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';
  List<ApplicationItem> _applications = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _applications = await ApplicationService.fetchApplications();
    } catch (error) {
      _errorMessage = 'Unable to load applications. Make sure backend is running.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addApplication(bool applied) async {
    final name = _nameController.text.trim();
    final status = _statusController.text.trim().isEmpty ? 'pending' : _statusController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Company name is required.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final application = await ApplicationService.createApplication(name, applied, status);
      _applications.insert(0, application);
      _nameController.clear();
      _statusController.clear();
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _deleteApplication(int id) async {
    try {
      await ApplicationService.deleteApplication(id);
      _applications.removeWhere((item) => item.id == id);
      if (mounted) setState(() {});
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to delete application.';
      });
    }
  }

  Future<void> _toggleApplied(ApplicationItem item) async {
    final index = _applications.indexWhere((entry) => entry.id == item.id);
    if (index == -1) return;

    final updatedItem = ApplicationItem(
      id: item.id,
      name: item.name,
      applied: !item.applied,
      status: item.status,
    );

    setState(() {
      _applications[index] = updatedItem;
      _errorMessage = '';
    });

    try {
      await ApplicationService.updateApplication(item.id, applied: updatedItem.applied);
    } catch (error) {
      setState(() {
        _applications[index] = item;
        _errorMessage = 'Failed to update application status.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApplications,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company applications', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                ),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_applications.isEmpty)
                const Expanded(child: Center(child: Text('No applications found. Add one to get started.')))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _applications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _applications[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text('Status: ${item.status}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(item.applied ? Icons.check_box : Icons.check_box_outline_blank),
                                onPressed: () => _toggleApplied(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteApplication(item.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    bool dialogApplied = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add application'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Company name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _statusController,
                    decoration: const InputDecoration(labelText: 'Status (pending / accepted / rejected)'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    value: dialogApplied,
                    onChanged: (value) {
                      setDialogState(() {
                        dialogApplied = value;
                      });
                    },
                    title: const Text('Applied'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await _addApplication(dialogApplied);
                        },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
