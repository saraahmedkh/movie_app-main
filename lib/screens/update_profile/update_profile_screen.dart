import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/services/user_storage.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  int _selectedAvatarId = 1;
  bool _isLoading = false;
  bool _showAvatarPicker = false;

  final List<int> _avatars = List.generate(6, (i) => i + 1);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final local = await UserStorage.getUser();

      setState(() {
        _nameController.text = user?.displayName ?? local['name'] ?? '';
        _emailController.text = user?.email ?? local['email'] ?? '';
        _phoneController.text = local['phone'] ?? '';
        _selectedAvatarId = int.tryParse(local['avatar'] ?? '1') ?? 1;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // تحديث الاسم في Firebase
      await user?.updateDisplayName(_nameController.text.trim());

      // حفظ البيانات في SharedPreferences
      await UserStorage.saveUser(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatar: _selectedAvatarId.toString(),
        email: _emailController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFB800)),
        ),
        title: const Text("Update Profile",
            style: TextStyle(color: Color(0xFFFFB800))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildAvatarSection(),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                icon: Icons.person,
                hint: "Name",
                validator: (v) =>
                v == null || v.isEmpty ? "Please enter your name" : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                hint: "Email",
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                v == null || v.isEmpty ? "Please enter your email" : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                icon: Icons.phone,
                hint: "Phone Number",
                keyboardType: TextInputType.phone,
                validator: (v) =>
                v == null || v.isEmpty ? "Please enter your phone" : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB800),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Update Profile",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showAvatarPicker = !_showAvatarPicker),
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getAvatarColor(_selectedAvatarId).withOpacity(0.3),
                  border: Border.all(color: const Color(0xFFFFB800), width: 2),
                ),
                child: ClipOval(
                  child: Center(
                    child: _buildAvatarImage(_selectedAvatarId, size: 90),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFB800), shape: BoxShape.circle),
                  child: const Icon(Icons.edit, size: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showAvatarPicker ? 200 : 0,
          child: _showAvatarPicker
              ? Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: GridView.builder(
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: _avatars.length,
              itemBuilder: (_, index) {
                final id = _avatars[index];
                final isSelected = _selectedAvatarId == id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedAvatarId = id;
                    _showAvatarPicker = false;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFB800)
                              : Colors.transparent,
                          width: 2),
                      color: _getAvatarColor(id).withOpacity(0.2),
                    ),
                    child: Center(child: _buildAvatarImage(id, size: 50)),
                  ),
                );
              },
            ),
          )
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildAvatarImage(int id, {double size = 50}) {
    return Image.asset(
      'assets/images/ava$id.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.person, size: size * 0.6, color: Colors.white),
    );
  }

  Color _getAvatarColor(int id) {
    final colors = [
      const Color(0xFF5DADE2),
      const Color(0xFF48C9B0),
      const Color(0xFFF39C12),
    ];
    return colors[(id - 1) % colors.length];
  }
}