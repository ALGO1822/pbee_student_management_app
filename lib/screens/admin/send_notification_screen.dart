import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/providers/notification_provider.dart';
import 'package:pbee_collate/widget/custom_button.dart';
import 'package:pbee_collate/widget/custom_input.dart';
import 'package:provider/provider.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final notifyProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    final success = await notifyProvider.sendBroadcast(
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSending = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification broadcasted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send notification. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Broadcast Message',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Use Center + ConstrainedBox for responsiveness on large screens
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipsCard(),
                const SizedBox(height: 32),
                const Text(
                  'MESSAGE DETAILS',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                CustomInput(
                  controller: _titleController,
                  hintText: 'Notification Title',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(LucideIcons.type, color: Colors.grey),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                CustomInput(
                  controller: _messageController,
                  hintText: 'Type your message here...',
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a message'
                      : null,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Send Broadcast',
                    icon: LucideIcons.send,
                    backgroundColor: Colors.purple,
                    isLoading: _isSending,
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, color: Colors.blue.shade400, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Broadcasting',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This message will be sent instantly to ALL registered users. Use this for important announcements only.',
                  style: TextStyle(color: Colors.blue.shade800, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}