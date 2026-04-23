import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _accent = Color(0xFFFF5414);
const _bg = Color(0xFF0B1416);
const _card = Color(0xFF1A2A30);
const _textSub = Color(0xFF8B9DA4);

// Same Pravatar pool used across the app
// The DiceBear API works flawlessly on Flutter Web without CORS issues.
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
  // FIX: track which avatar the user selects during signup
  int _selectedAvatarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      // 👇 TEMPORARY BUTTON TO REFILL THE NEW DATABASE 👇
      // 👇 ERROR-CATCHING SEED BUTTON 👇
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            // Shows a loading indicator
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Seeding... Please wait.'),
                backgroundColor: Colors.orange,
              ),
            );

            await seedMapDatabase();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔥 New Database Seeded!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            // IF IT BREAKS, THIS PRINTS THE EXACT ERROR!
            print("🚨 SEED ERROR: $e");
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 10),
                ),
              );
            }
          }
        },
        backgroundColor: const Color(0xFFFF5414),
        icon: const Icon(Icons.upload, color: Colors.white),
        label: const Text(
          "SEED DATABASE",
          style: TextStyle(color: Colors.white),
        ),
      ),

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
                  // FIX: Avatar picker during signup so users
                  // don't get a random brown placeholder
                  _buildAvatarPicker(),
                  const SizedBox(height: 20),

                  _buildTextField(
                    "Anonymous Username (e.g., quietstriver)",
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "Age",
                          Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
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
                          onChanged: (_) {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
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
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "University / College (Optional)",
                    Icons.school_outlined,
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextField(
                  "Email",
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "Password",
                  Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RootScreen(
                          // Pass selected avatar index to RootScreen
                          selectedAvatarIndex: _selectedAvatarIndex,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isLogin ? "Log In" : "Create Account",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
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

  // FIX: Avatar picker grid — shows real Pravatar faces so the user
  // picks their look before joining (no more brown placeholder)
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

  Widget _buildTextField(
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
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

Future<void> seedMapDatabase() async {
  print("🚨 PULSE 1: Function started!");

  try {
    final CollectionReference nodes = FirebaseFirestore.instance.collection(
      'map_nodes',
    );
    print("🚨 PULSE 2: Connected to Firestore instance!");

    final dummyData = [
      {
        "name": "Kuala Lumpur",
        "desc": "Burnout + Dark Thoughts",
        "lat": 3.1390,
        "lng": 101.6869,
        "status": "critical",
      },
      {
        "name": "Subang Jaya",
        "desc": "Burnout — No 24/7 clinic",
        "lat": 3.0438,
        "lng": 101.5859,
        "status": "high",
      },
    ];

    print("🚨 PULSE 3: Starting to upload data...");
    for (var node in dummyData) {
      print("🚨 PULSE 4: Trying to upload ${node['name']}...");
      await nodes.add(node);
      print("🚨 PULSE 5: Successfully uploaded ${node['name']}!");
    }
    print("🔥 PULSE 6: Database Successfully Seeded!");
  } catch (e) {
    print("🚨 FATAL ERROR IN SEEDER: $e");
    throw e; // Forces the red snackbar to show up
  }
}
