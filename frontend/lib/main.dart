import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/feed_screen.dart';
import 'package:frontend/screens/tools_screen.dart';
import 'package:frontend/screens/map_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const _bg = Color(0xFF0B1416);
const _card = Color(0xFF1A2A30);
const _accent = Color(0xFFFF5414);
const _textTitle = Color(0xFFD7DADC);
const _textSub = Color(0xFF8B9DA4);
const _border = Color(0xFF2B3C42);

void main() async {
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  print("🚨 VAULT CHECK: API KEY IS -> ${dotenv.env['FIREBASE_API_KEY']}");

  // Connect to our live Helance Database
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '', // <-- COPY YOUR FULL API KEY HERE
      authDomain: "healance-9e647.firebaseapp.com",
      projectId: "healance-9e647",
      storageBucket:
          "healance-9e647.firebasestorage.app", // <-- Double check this one from your screen
      messagingSenderId: "599899764817",
      appId:
          dotenv.env['FIREBASE_APP_ID'] ?? '',
    ),
  );

  runApp(const HealanceApp());
}

class HealanceApp extends StatelessWidget {
  const HealanceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Héalance',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      colorSchemeSeed: _accent,
      useMaterial3: true,
      fontFamily: 'Segoe UI',
    ),
    home: const LoginScreen(),
  );
}

class RootScreen extends StatefulWidget {
  final int selectedAvatarIndex; // 1. Declare the variable

  // 2. Add it to the constructor (default to 0 just in case)
  const RootScreen({super.key, this.selectedAvatarIndex = 0});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  // This drives the feed filter from sidebar tap
  int _feedCategoryIndex = 0;

  // Maps sidebar community label → feed category string
  static const _communityToCategory = {
    '#CareerAnxiety': 'Career Anxiety',
    '#DarkThoughts': 'Dark Thoughts',
    '#SleepStruggles': 'Sleep Struggles',
    '#Overthinking': 'Overthinking',
    '#BodyInsecurity': 'Body Insecurity',
    '#AcademicBurnout': 'Academic Burnout',
    '#Loneliness': 'Loneliness',
    '#FamilyIssues': 'Family Issues',
    '#Trauma': 'Trauma',
    '#SocialMediaTrap': 'Social Media Trap',
    '#FutureDreams': 'Future Doubts',
    '#PhoneAddiction': 'Phone Addiction',
    '#Procrastination': 'Procrastination',
    '#Relationships': 'Relationships',
    '#IdentityWorth': 'Identity & Self-Worth',
    '#FeelingUnattractive': 'Feeling Unattractive',
    '#NoOneToTalkTo': 'No One To Talk To',
    '#FriendshipDrama': 'Friendship Drama',
    '#FinancialAnxiety': 'Financial Anxiety',
  };

  static const _allCategories = [
    'All',
    'Academic Burnout',
    'Loneliness',
    'Overthinking',
    'Bullying',
    'Friendship Drama',
    'Financial Anxiety',
    'Career Anxiety',
    'Dark Thoughts',
    'Body Insecurity',
    'Family Issues',
    'Social Media Trap',
    'Future Doubts',
    'Trauma',
    'Phone Addiction',
    'Procrastination',
    'Feeling Unattractive',
    'No One To Talk To',
    'Identity & Self-Worth',
    'Sleep Struggles',
    'Relationships',
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    final screens = [
      FeedScreen(initialCategoryIndex: _feedCategoryIndex),
      const ToolsScreen(),
      const MapScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 1,
        shadowColor: Colors.black,
        titleSpacing: 24,
        title: Row(
          children: [
            const Icon(Icons.spa_rounded, color: _accent, size: 28),
            const SizedBox(width: 8),
            const Text(
              'héalance',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _textTitle,
                letterSpacing: -1,
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 40),
              Container(
                width: 300,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      'Search héalance',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                const Text(
                  '1.2k',
                  style: TextStyle(
                    color: _textTitle,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage(
                    'https://api.dicebear.com/8.x/adventurer/png?seed=YouMain&backgroundColor=b6e3f4',
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'anon_user',
                  style: TextStyle(color: _textTitle, fontSize: 13),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 250,
              color: _card,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _navItem(Icons.home_filled, 'Home', 0),
                  _navItem(Icons.psychology, 'AI Sidekick', 1),
                  _navItem(Icons.map, 'Resource Map', 2),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Divider(color: Colors.white10),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'SPACES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ..._communityToCategory.keys.map(
                    (c) => _communityItem(context, c),
                  ),
                ],
              ),
            ),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              backgroundColor: _card,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Feed'),
                NavigationDestination(
                  icon: Icon(Icons.psychology),
                  label: 'Sidekick',
                ),
                NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
              ],
            ),
    );
  }

  Widget _navItem(IconData icon, String title, int index) {
    bool isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? _textTitle : Colors.grey.shade500,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? _textTitle : Colors.grey.shade500,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.05),
      onTap: () => setState(() => _currentIndex = index),
    );
  }

  // ── COMMUNITIES: tap → navigate to feed AND filter by category ─────────
  Widget _communityItem(BuildContext context, String label) {
    final categoryName = _communityToCategory[label] ?? 'All';
    final catIdx = _allCategories.indexOf(categoryName);
    final isActive =
        _currentIndex == 0 && _feedCategoryIndex == (catIdx < 0 ? 0 : catIdx);

    return Container(
      color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? _accent.withOpacity(0.2) : Colors.white10,
          child: Icon(
            Icons.tag,
            size: 12,
            color: isActive ? _accent : Colors.white54,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? _accent : Colors.white70,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          setState(() {
            _currentIndex = 0; // go to feed tab
            _feedCategoryIndex = catIdx < 0 ? 0 : catIdx;
          });
        },
      ),
    );
  }
}
