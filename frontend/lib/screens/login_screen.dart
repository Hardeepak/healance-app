import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🚨 NEW IMPORT

const _accent = Color(0xFFFF5414);
const _bg = Color(0xFF0B1416);
const _card = Color(0xFF1A2A30);
const _textSub = Color(0xFF8B9DA4);

const _avatarPool = [
  'https://api.dicebear.com/8.x/notionists/png?seed=Felix',
  'https://api.dicebear.com/8.x/notionists/png?seed=Aneka',
  'https://api.dicebear.com/8.x/notionists/png?seed=Jack',
  'https://api.dicebear.com/8.x/notionists/png?seed=Sam',
  'https://api.dicebear.com/8.x/notionists/png?seed=Nala',
  'https://api.dicebear.com/8.x/notionists/png?seed=Leo',
  'https://api.dicebear.com/8.x/notionists/png?seed=Zoe',
  'https://api.dicebear.com/8.x/notionists/png?seed=Max',
  'https://api.dicebear.com/8.x/notionists/png?seed=Mia',
  'https://api.dicebear.com/8.x/notionists/png?seed=Eli',
  'https://api.dicebear.com/8.x/notionists/png?seed=Lola',
  'https://api.dicebear.com/8.x/notionists/png?seed=Finn',
  'https://api.dicebear.com/8.x/notionists/png?seed=Oliver',
  'https://api.dicebear.com/8.x/notionists/png?seed=Chloe',
  'https://api.dicebear.com/8.x/notionists/png?seed=Jasper',
  'https://api.dicebear.com/8.x/notionists/png?seed=Ruby',
  'https://api.dicebear.com/8.x/notionists/png?seed=Oscar',
  'https://api.dicebear.com/8.x/notionists/png?seed=Lily',
  'https://api.dicebear.com/8.x/notionists/png?seed=Milo',
  'https://api.dicebear.com/8.x/notionists/png?seed=Jade',
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  int _selectedAvatarIndex = 0;
  bool _isLoading = false; // Tracks auth state

  // 🚨 CONTROLLERS TO CAPTURE USER INPUT
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _uniController = TextEditingController();

  String? _selectedGender;
  String? _selectedState;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _uniController.dispose();
    super.dispose();
  }

  // 🚨 THE AUTHENTICATION ENGINE
  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        // --- LOGIN LOGIC ---
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // --- SIGN UP LOGIC ---
        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Save the extra anonymous profile data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set({
              'username': _usernameController.text.trim().isEmpty
                  ? 'anonymous_user'
                  : _usernameController.text.trim(),
              'avatarUrl': _avatarPool[_selectedAvatarIndex],
              'age': int.tryParse(_ageController.text.trim()) ?? 0,
              'gender': _selectedGender ?? 'Not Specified',
              'state': _selectedState ?? 'Unknown',
              'university': _uniController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      // If successful, navigate to RootScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RootScreen(selectedAvatarIndex: _selectedAvatarIndex),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Errors (e.g., wrong password, email in use)
      String message = e.message ?? 'An error occurred';
      if (e.code == 'user-not-found') message = 'No user found for that email.';
      if (e.code == 'wrong-password') message = 'Wrong password provided.';
      if (e.code == 'email-already-in-use')
        message = 'An account already exists for that email.';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.spa_rounded, size: 48, color: _accent),
                const SizedBox(height: 16),
                const Text(
                  'héalance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  isLogin
                      ? "Welcome back to your safe space."
                      : "Join the community anonymously.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textSub, fontSize: 14),
                ),
                const SizedBox(height: 32),

                if (!isLogin) ...[
                  _buildAvatarPicker(),
                  const SizedBox(height: 20),

                  _buildTextField(
                    "Anonymous Username (e.g., quietstriver)",
                    Icons.person_outline,
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "Age",
                          Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          controller: _ageController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          dropdownColor: _card,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.people_outline,
                              color: _textSub,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: _bg,
                          ),
                          hint: const Text(
                            "Gender",
                            style: TextStyle(color: _textSub),
                          ),
                          items: ["Male", "Female", "Non-binary", "Other"]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedGender = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    isExpanded: true,
                    dropdownColor: _card,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.map_outlined,
                        color: _textSub,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _bg,
                    ),
                    hint: const Text(
                      "State / Region",
                      style: TextStyle(color: _textSub),
                    ),
                    items:
                        [
                              "Johor",
                              "Kedah",
                              "Kelantan",
                              "Kuala Lumpur",
                              "Labuan",
                              "Melaka",
                              "Negeri Sembilan",
                              "Pahang",
                              "Penang",
                              "Perak",
                              "Perlis",
                              "Putrajaya",
                              "Sabah",
                              "Sarawak",
                              "Selangor",
                              "Terengganu",
                              "Outside Malaysia",
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedState = val),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "University / College (Optional)",
                    Icons.school_outlined,
                    controller: _uniController,
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextField(
                  "Email",
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "Password",
                  Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                ),
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Forgot Password? Link sent to your email"),
                            backgroundColor: _accent,
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: _textSub, fontSize: 12),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _submitAuth, // 🚨 Call Auth logic here
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Prevent button color from completely greying out when loading
                    disabledBackgroundColor: _accent.withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isLogin ? "Log In" : "Create Account",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Toggle state and clear fields when switching modes
                    setState(() {
                      isLogin = !isLogin;
                      _passwordController.clear();
                    });
                  },
                  child: Text(
                    isLogin
                        ? "New here? Sign Up"
                        : "Already have an account? Log In",
                    style: const TextStyle(color: _textSub),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose your anonymous avatar",
          style: TextStyle(
            color: _textSub,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(_avatarPool.length, (i) {
            final isSelected = _selectedAvatarIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatarIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _accent : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _accent.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(_avatarPool[i]),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 🚨 Pass the controller down to the actual TextField widget
  Widget _buildTextField(
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textSub, fontSize: 13),
        prefixIcon: Icon(icon, color: _textSub),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: _bg,
      ),
    );
  }
}
