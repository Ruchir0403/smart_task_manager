import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'widgets/task_card.dart';
import 'widgets/create_task_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  String? _selectedPriority;

  final List<String> _categories = [
    'scheduling',
    'finance',
    'technical',
    'safety',
    'general',
  ];
  final List<String> _priorities = ['high', 'medium', 'low'];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshList() {
    ref
        .read(taskListProvider.notifier)
        .loadTasks(
          search: _searchController.text,
          category: _selectedCategory,
          priority: _selectedPriority,
        );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _refreshList();
    });
  }

  void _onCategorySelected(bool selected, String category) {
    setState(() {
      _selectedCategory = selected ? category : null;
    });
    _refreshList();
  }

  void _onPrioritySelected(bool selected, String priority) {
    setState(() {
      _selectedPriority = selected ? priority : null;
    });
    _refreshList();
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Task?"),
        content: Text("Are you sure you want to delete '${task.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      ref.read(taskListProvider.notifier).deleteTask(task.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Task deleted")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedPriority = null;
                _searchController.clear();
              });
              _refreshList();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                ..._priorities.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(priority.toUpperCase()),
                      selected: isSelected,
                      onSelected: (bool selected) =>
                          _onPrioritySelected(selected, priority),
                      backgroundColor: Colors.white,
                      selectedColor: Colors.red.withOpacity(0.1),
                      checkmarkColor: Colors.red,
                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.red : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                ..._categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(
                        category[0].toUpperCase() + category.substring(1),
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) =>
                          _onCategorySelected(selected, category),
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blueAccent.withOpacity(0.1),
                      checkmarkColor: Colors.blueAccent,
                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blueAccent : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: taskState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (tasks) {
                final pending = tasks
                    .where((t) => t.status == 'pending')
                    .length;
                final highPriority = tasks
                    .where((t) => t.priority == 'high')
                    .length;

                return Column(
                  children: [
                    if (tasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            _SummaryCard(
                              label: 'Pending',
                              count: pending,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            _SummaryCard(
                              label: 'High Priority',
                              count: highPriority,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),

                    Expanded(
                      child: tasks.isEmpty
                          ? Center(
                              child: Text(
                                "No tasks match filters",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                          : ListView.builder(
                              itemCount: tasks.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return GestureDetector(
                                  onLongPress: () =>
                                      _confirmDelete(context, task),
                                  child: TaskCard(task: task),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const CreateTaskSheet(),
        ),
        label: const Text('New Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
