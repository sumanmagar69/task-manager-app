import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = context.read<AuthProvider>().user;

      if (user != null) {
        context.read<TaskProvider>().listenToTasks(user.uid);
      }
    });
  }

  void _showTaskDialog({Task? task}) {
    final titleController =
        TextEditingController(text: task?.title ?? '');

    final descriptionController =
        TextEditingController(text: task?.description ?? '');

    bool isCompleted = task?.isCompleted ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                task == null ? 'Add Task' : 'Edit Task',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (task != null)
                      CheckboxListTile(
                        title: const Text('Completed'),
                        value: isCompleted,
                        onChanged: (value) {
                          setDialogState(() {
                            isCompleted = value ?? false;
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final description =
                        descriptionController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a task title.'),
                        ),
                      );
                      return;
                    }

                    final authProvider =
                        Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );

                    final user = authProvider.user;

                    if (user == null) {
                      return;
                    }

                    final taskProvider =
                        Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    );

                    if (task == null) {
                      await taskProvider.addTask(
                        userId: user.uid,
                        title: title,
                        description: description,
                      );
                    } else {
                      await taskProvider.updateTask(
                        userId: user.uid,
                        taskId: task.id,
                        title: title,
                        description: description,
                        isCompleted: isCompleted,
                      );
                    }

                    if (!mounted) return;

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          task == null
                              ? 'Task added successfully.'
                              : 'Task updated successfully.',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    task == null ? 'Add' : 'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTask(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final user = authProvider.user;

    if (user == null) {
      return;
    }

    final taskProvider = Provider.of<TaskProvider>(
      context,
      listen: false,
    );

    await taskProvider.deleteTask(
      userId: user.uid,
      taskId: task.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted successfully.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isDark =
                  themeProvider.themeMode == ThemeMode.dark;

              return IconButton(
                tooltip: isDark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                icon: Icon(
                  isDark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  context.read<ThemeProvider>().toggleTheme();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await context.read<AuthProvider>().signOut();

              if (!mounted) return;
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text('User not logged in.'),
            )
          : taskProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : taskProvider.error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Error: ${taskProvider.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : taskProvider.tasks.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 80,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No tasks yet',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap + to add your first task.',
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: taskProvider.tasks.length,
                          itemBuilder: (context, index) {
                            final task =
                                taskProvider.tasks[index];

                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(
                                    task.isCompleted
                                        ? Icons.check
                                        : Icons.pending_actions,
                                  ),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        task.isCompleted
                                            ? TextDecoration
                                                .lineThrough
                                            : null,
                                  ),
                                ),
                                subtitle: task.description.isEmpty
                                    ? null
                                    : Text(task.description),
                                trailing:
                                    PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showTaskDialog(
                                        task: task,
                                      );
                                    }

                                    if (value == 'delete') {
                                      _deleteTask(task);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(width: 10),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete),
                                            SizedBox(width: 10),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            );
                          },
                        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}