import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pbee_collate/providers/user_entry_provider.dart';
import 'package:pbee_collate/screens/admin/admin_entry.dart';
import 'package:pbee_collate/screens/user/user_login.dart';
import 'package:pbee_collate/screens/auth_gate.dart';
import 'package:pbee_collate/providers/course_provider.dart';
import 'package:pbee_collate/util/validator.dart';
import 'package:pbee_collate/widget/custom_button.dart';
import 'package:pbee_collate/widget/custom_dropdown.dart';
import 'package:pbee_collate/widget/custom_input.dart';

class UserEntry extends StatefulWidget {
  const UserEntry({super.key});

  @override
  State<UserEntry> createState() => _UserEntryState();
}

class _UserEntryState extends State<UserEntry> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  String? selectedCourse;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // --- UPDATED DIALOG METHOD ---
  void _showTermsDialog(
    BuildContext context,
    UserEntryProvider signUpProvider,
  ) {
    bool isAgreed = false;
    final mainScreenContext = context;

    showDialog(
      context: mainScreenContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: const Row(
                children: [
                  Icon(LucideIcons.fileText, color: Colors.purple),
                  SizedBox(width: 12),
                  Text('Terms & Conditions'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 200,
                      child: const SingleChildScrollView(
                        child: Text(
                          'Please read and agree to the following terms:\n\n'
                          '1. Data Collection: You agree to provide accurate and complete information during registration. This information will be stored securely.\n\n'
                          '2. User Conduct: You agree not to misuse the app, harass other users, or attempt unauthorized access.\n\n'
                          '3. Course Enrollment: Enrolling in a course constitutes an agreement to pay the specified fees. All fees are non-refundable.\n\n'
                          '4. Termination: We reserve the right to terminate or suspend your account for any violation of these terms without notice.\n\n'
                          '5. Disclaimers: The service is provided "as is". We make no warranties regarding the availability or accuracy of the content.\n\n'
                          'By clicking "I agree," you confirm that you have read, understood, and accepted these terms.',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        setDialogState(() {
                          isAgreed = !isAgreed;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isAgreed,
                              activeColor: Colors.purple,
                              onChanged: (value) {
                                setDialogState(() {
                                  isAgreed = value ?? false;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'I agree to the Terms and Conditions',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isAgreed
                      ? () async {
                          Navigator.pop(dialogContext);

                          final String? errorMessage = await signUpProvider
                              .handleSignUp(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                address: addressController.text.trim(),
                                phone: phoneNumberController.text.trim(),
                                course: selectedCourse ?? '',
                                notes: notesController.text.trim(),
                                formValid: true,
                              );

                          if (errorMessage != null) {
                            if (mainScreenContext.mounted) {
                              ScaffoldMessenger.of(
                                mainScreenContext,
                              ).showSnackBar(
                                SnackBar(content: Text(errorMessage)),
                              );
                            }
                          } else {
                            if (mainScreenContext.mounted) {
                              Navigator.pushAndRemoveUntil(
                                mainScreenContext,
                                MaterialPageRoute(
                                  builder: (context) => const AuthGate(),
                                ),
                                (route) => false,
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text('Agree & Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    final signUpProvider = Provider.of<UserEntryProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    // 1. Prepare the list of course titles once to ensure consistency
    final List<String> courseTitles = courseProvider.courses
        .map((c) => c.title)
        .toSet()
        .toList();

    // 2. SAFETY CHECK: Check if the currently selected course actually exists in the generated list
    final bool isCourseInList =
        selectedCourse != null && courseTitles.contains(selectedCourse);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Account'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: signUpProvider.pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.purple.shade50,
                            backgroundImage:
                                signUpProvider.selectedImage != null
                                ? FileImage(signUpProvider.selectedImage!)
                                : null,
                            child: signUpProvider.selectedImage == null
                                ? Icon(
                                    LucideIcons.camera,
                                    size: 40,
                                    color: Colors.purple.shade200,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.purple,
                              child: const Icon(
                                LucideIcons.plus,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            bottomRight: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                            controller: firstNameController,
                            hintText: 'First Name',
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                Validator.name(value, fieldName: 'First Name'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomInput(
                            bottomLeft: Radius.circular(0.0),
                            topLeft: Radius.circular(0.0),
                            controller: lastNameController,
                            hintText: 'Last Name',
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                Validator.name(value, fieldName: 'Last Name'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      controller: addressController,
                      hintText: 'Address',
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validator.address(value),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      controller: emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validator.email(value),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      controller: passwordController,
                      hintText: 'Password',
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validator.password(value),
                      obscureText: !_isPasswordVisible,
                      suffixIcon: GestureDetector(
                        child: Icon(
                          _isPasswordVisible
                              ? LucideIcons.eye
                              : LucideIcons.eyeOff,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      controller: phoneNumberController,
                      hintText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validator.phone(value),
                    ),
                    const SizedBox(height: 16),

                    // --- UPDATED DROPDOWN ---
                    CustomDropdownInput(
                      hintText: 'Select your course',

                      // FIX: Ensure value is actually in the list we are passing
                      value: isCourseInList ? selectedCourse : null,

                      items: courseTitles,

                      onChanged: (newValue) {
                        setState(() {
                          selectedCourse = newValue;
                        });
                      },
                      validator: (value) {
                        // Custom validation to block submit if the selected course was deleted
                        if (selectedCourse != null && !isCourseInList) {
                          return 'Selected course is no longer available';
                        }
                        return Validator.dropdown(value, fieldName: 'course');
                      },
                    ),

                    // --- PRICE / ERROR DISPLAY ---
                    if (selectedCourse != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          isCourseInList
                              ? 'Price: ${NumberFormat.currency(symbol: '₦', decimalDigits: 2).format(courseProvider.getPriceForTitle(selectedCourse))}'
                              : 'Course Unavailable (Deleted by Admin)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            // Show RED text if the course is invalid
                            color: isCourseInList
                                ? Colors.purple.shade700
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    CustomInput(
                      controller: notesController,
                      hintText: 'Reference No',
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Submit Application',
                        isLoading: signUpProvider.isLoading,
                        onPressed: () {
                          // The validate() call will now fail if the course is deleted
                          // because of the logic we added to the dropdown validator above.
                          if (_formKey.currentState!.validate()) {
                            _showTermsDialog(context, signUpProvider);
                          }
                        },
                        backgroundColor: Colors.purple,
                        icon: LucideIcons.send,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const UserLogin(),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Admin Login',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminEntry(),
                            ),
                          );
                        },
                        textColor: Colors.purple,
                        backgroundColor: Colors.purple.shade50,
                        borderColor: Colors.purple.shade100,
                        icon: LucideIcons.shield,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
