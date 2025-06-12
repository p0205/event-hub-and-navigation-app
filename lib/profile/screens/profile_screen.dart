import 'package:event_hub_and_navigation_app/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:event_hub_and_navigation_app/auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/models/user.dart';
import '../../widgets/login_reminder_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditingPhone = false;
  bool _isChangingPassword = false;

  User? _user;

  @override
  void initState() {
    super.initState();
    // Initialize with user data
    final state = context.read<AuthBloc>().state;
    if (state is AuthenticatedState) {
      _user = state.user;
      _phoneController.text = state.user.phoneNo ?? '';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
      return 'Please enter a valid phone number (10-11 digits)';
    }
    return null;
  }

  void _togglePhoneEditing() {
    setState(() {
      _isEditingPhone = !_isEditingPhone;
      if (!_isEditingPhone) {
        // Reset to original value if cancelled
        final state = context.read<AuthBloc>().state;
        if (state is AuthenticatedState) {
          _phoneController.text = state.user.phoneNo ?? '';
        }
      }
    });
  }

  void _savePhoneNumber() {
    final validationError = _validatePhone(_phoneController.text);
    if (validationError == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Update'),
          content: Text(
              'Are you sure you want to update your phone number to ${_phoneController.text}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<ProfileBloc>().add(
                      UpdatePhoneNoEvent(
                        userId: _user!.id,
                        phoneNo: _phoneController.text,
                      ),
                    );
                setState(() {
                  _isEditingPhone = false;
                });
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
    }
  }

  void _changeProfileImage() {
    // TODO: Implement profile image change logic
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Password Change'),
          content: const Text('Are you sure you want to change your password?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isChangingPassword = true;
                });
                context.read<ProfileBloc>().add(
                      UpdatePasswordEvent(
                        userId: _user!.id,
                        currentPassword: _currentPasswordController.text,
                        newPassword: _newPasswordController.text,
                      ),
                    );
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  if (!value.contains(RegExp(r'[A-Z]'))) {
                    return 'Password must contain at least one uppercase letter';
                  }
                  if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Password must contain at least one number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isChangingPassword ? null : _changePassword,
            child: _isChangingPassword
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is UnAuthenticatedState) {
            return const LoginReminderWidget();
          }
          
          return BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileSuccess) {
                context.read<AuthBloc>().add(UpdateUserEvent(user: state.user));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                if (_isEditingPhone) {
                  setState(() {
                    _isEditingPhone = false;
                  });
                }
              } else if (state is PasswordUpdatedSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password updated successfully")),
                );
                Navigator.pop(context);
                if (_isChangingPassword) {
                  setState(() {
                    _isChangingPassword = false;
                  });
                }
              } else if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.person,
                              size: 60, color: Colors.grey),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon:
                                  const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _changeProfileImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // User Information Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Name (Non-editable)
                            _buildInfoRow(
                              'Name',
                              _user?.name ?? 'Not set',
                              isEditable: false,
                            ),
                            const Divider(),

                            // Email (Non-editable)
                            _buildInfoRow(
                              'Email',
                              _user?.email ?? 'Not set',
                              isEditable: false,
                            ),
                            const Divider(),

                            // Phone Number (Editable)
                            _buildInfoRow(
                              'Phone',
                              _phoneController.text,
                              isEditable: true,
                              onEdit: _togglePhoneEditing,
                              onSave: _savePhoneNumber,
                              isEditing: _isEditingPhone,
                              controller: _phoneController,
                              validator: _validatePhone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Change Password Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showChangePasswordDialog,
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Change Password'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Logout'),
                              content:
                                  const Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context
                                        .read<AuthBloc>()
                                        .add(SignOutRequested());
                                    // Reset the entire app navigation state
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      '/',
                                      (route) => false,
                                    )
                                        .then((_) {
                                      // Force rebuild the entire app
                                      (context as Element).markNeedsBuild();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Logout',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text('Logout',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isEditable = false,
    VoidCallback? onEdit,
    VoidCallback? onSave,
    bool isEditing = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      errorStyle: TextStyle(height: 0.5),
                    ),
                    validator: validator,
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          if (isEditable)
            IconButton(
              icon: Icon(
                isEditing ? Icons.save : Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: isEditing ? onSave : onEdit,
            ),
        ],
      ),
    );
  }
}
