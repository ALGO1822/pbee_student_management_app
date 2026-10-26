import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/models/courses.dart';
import 'package:pbee_collate/providers/course_provider.dart';
import 'package:pbee_collate/widget/custom_button.dart';
import 'package:pbee_collate/widget/custom_input.dart';
import 'package:provider/provider.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  // Method to show the Add/Edit dialog
  void _showCourseDialog({Course? course}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, // Ensure modal background is set
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Provide CourseProvider to the modal form
        return ChangeNotifierProvider.value(
          value: Provider.of<CourseProvider>(context, listen: false),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _AddEditCourseForm(course: course),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Manage Courses',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        // --- FIX: Moved FAB to AppBar ---
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: Colors.purple),
            tooltip: 'Add Course',
            onPressed: () => _showCourseDialog(),
          ),
          const SizedBox(width: 8),
        ],
        // ---------------------------------
      ),
      body: Builder(
        builder: (context) {
          if (courseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (courseProvider.error != null) {
            return Center(child: Text('Error: ${courseProvider.error}'));
          }

          if (courseProvider.courses.isEmpty) {
            return const Center(
              child: Text('No courses found. Add one to get started!'),
            );
          }

          // Use ListView.builder for better performance with long lists
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // Add padding for last item
            itemCount: courseProvider.courses.length,
            itemBuilder: (context, index) {
              final course = courseProvider.courses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0), // Use padding instead of Separated
                child: _buildCourseTile(context, course),
              );
            },
          );
        },
      ),
      // --- REMOVED FloatingActionButton ---
    );
  }

  Widget _buildCourseTile(BuildContext context, Course course) {
    // No need to get provider here if it's only used for delete
    final formattedPrice = NumberFormat.currency(symbol: '₦', decimalDigits: 2)
        .format(course.price);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(course.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(formattedPrice,
            style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(LucideIcons.edit, color: Colors.blueAccent.shade200, size: 20),
              tooltip: 'Edit Course',
              onPressed: () => _showCourseDialog(course: course),
            ),
            IconButton(
              icon: Icon(LucideIcons.trash2, color: Colors.red.shade300, size: 20),
              tooltip: 'Delete Course',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Course?'),
                    content: Text(
                        'Are you sure you want to delete "${course.title}"? This will also notify all enrolled users.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  // Call provider using 'listen: false' inside a function
                  await Provider.of<CourseProvider>(context, listen: false)
                      .deleteCourse(course.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Form for Adding/Editing a Course
class _AddEditCourseForm extends StatefulWidget {
  final Course? course;
  const _AddEditCourseForm({this.course});

  @override
  State<_AddEditCourseForm> createState() => _AddEditCourseFormState();
}

class _AddEditCourseFormState extends State<_AddEditCourseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _priceController = TextEditingController(
        text: widget.course != null ? widget.course!.price.toStringAsFixed(0) : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final title = _titleController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    bool success;
    if (widget.course == null) {
      // Add new course
      success = await courseProvider.addCourse(title, price);
    } else {
      // Update existing course
      success = await courseProvider.updateCourse(widget.course!.id, title, price);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context); // Close the bottom sheet
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(courseProvider.error ?? 'An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    // We might still be mounted if save failed
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.course == null ? 'Add New Course' : 'Edit Course',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            CustomInput(
              controller: _titleController,
              hintText: 'Course Title',
              keyboardType: TextInputType.text,
              prefixIcon: const Icon(LucideIcons.bookOpen, color: Colors.grey),
              validator: (value) =>
                  value!.isEmpty ? 'Title cannot be empty' : null,
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: _priceController,
              hintText: 'Price (e.g., 50000)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(LucideIcons.badgeDollarSign, color: Colors.grey),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Price cannot be empty';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Save Course',
              isLoading: _isSaving,
              onPressed: _saveForm,
              backgroundColor: Colors.purple,
              icon: LucideIcons.check,
            )
          ],
        ),
      ),
    );
  }
}