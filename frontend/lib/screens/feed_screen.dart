import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/services/ai_service.dart';
import 'package:share_plus/share_plus.dart';

const _accent = Color(0xFFFF5414);
const _bg = Color(0xFF0B1416);
const _card = Color(0xFF1A2A30);
const _border = Color(0xFF2B3C42);
const _textTitle = Color(0xFFD7DADC);
const _textSub = Color(0xFF8B9DA4);

final _postAvatars = [
  'https://i.pravatar.cc/100?img=1',
  'https://i.pravatar.cc/100?img=3',
  'https://i.pravatar.cc/100?img=5',
  'https://i.pravatar.cc/100?img=7',
  'https://i.pravatar.cc/100?img=9',
  'https://i.pravatar.cc/100?img=11',
  'https://i.pravatar.cc/100?img=12',
  'https://i.pravatar.cc/100?img=14',
  'https://i.pravatar.cc/100?img=15',
  'https://i.pravatar.cc/100?img=16',
  'https://i.pravatar.cc/100?img=18',
  'https://i.pravatar.cc/100?img=20',
  'https://i.pravatar.cc/100?img=22',
  'https://i.pravatar.cc/100?img=25',
  'https://i.pravatar.cc/100?img=27',
  'https://i.pravatar.cc/100?img=30',
  'https://i.pravatar.cc/100?img=32',
  'https://i.pravatar.cc/100?img=33',
  'https://i.pravatar.cc/100?img=35',
  'https://i.pravatar.cc/100?img=36',
  'https://i.pravatar.cc/100?img=38',
  'https://i.pravatar.cc/100?img=40',
  'https://i.pravatar.cc/100?img=41',
  'https://i.pravatar.cc/100?img=43',
  'https://i.pravatar.cc/100?img=45',
  'https://i.pravatar.cc/100?img=47',
  'https://i.pravatar.cc/100?img=48',
  'https://i.pravatar.cc/100?img=50',
  'https://i.pravatar.cc/100?img=52',
  'https://i.pravatar.cc/100?img=54',
  'https://i.pravatar.cc/100?img=56',
  'https://i.pravatar.cc/100?img=57',
  'https://i.pravatar.cc/100?img=59',
  'https://i.pravatar.cc/100?img=60',
  'https://i.pravatar.cc/100?img=62',
  'https://i.pravatar.cc/100?img=64',
  'https://i.pravatar.cc/100?img=65',
  'https://i.pravatar.cc/100?img=67',
  'https://i.pravatar.cc/100?img=68',
  'https://i.pravatar.cc/100?img=70',
];

String _av(int uniqueIndex) => _postAvatars[uniqueIndex % _postAvatars.length];

class Post {
  final String category, user, time, title, body, avatarUrl;
  final int points, comments;
  final bool aiSupported;
  final Color tagColor;

  const Post(
    this.category,
    this.user,
    this.time,
    this.title,
    this.body,
    this.points,
    this.comments,
    this.aiSupported,
    this.tagColor,
    this.avatarUrl,
  );
}

final List<Post> _posts = [
  Post(
    'Loneliness',
    'empty_room',
    '1d',
    "I haven't spoken out loud to anyone in 3 days.",
    "Online classes make it so easy to disappear. Nobody checks in. Not even once.",
    750,
    180,
    true,
    Colors.blueGrey,
    _av(0),
  ),
  Post(
    'Loneliness',
    'crowded_room',
    '5h',
    "I have 5 roommates and still feel completely alone.",
    "We live together but don't really know each other. We just coexist.",
    410,
    62,
    false,
    Colors.blueGrey,
    _av(1),
  ),
  Post(
    'Loneliness',
    'solo_eater',
    '12h',
    "Eating lunch in the library bathroom again.",
    "Too scared to sit in the cafeteria alone.",
    890,
    210,
    true,
    Colors.blueGrey,
    _av(2),
  ),
  Post(
    'Overthinking',
    'brain_buzz',
    '5h',
    "Replaying a conversation from 3 years ago.",
    "Why did I say that? They definitely still think about it.",
    544,
    212,
    true,
    Colors.tealAccent,
    _av(9),
  ),
  Post(
    'Overthinking',
    'what_if_guy',
    '1h',
    "If I don't get an A I won't graduate.",
    "The spiral happens so fast. One bad mark and I've catastrophised my entire future.",
    900,
    150,
    true,
    Colors.tealAccent,
    _av(10),
  ),
  Post(
    'Bullying',
    'silent_cry',
    '12h',
    "Someone made a meme about me in the uni WhatsApp group.",
    "200 people laughing. I don't want to go to class tomorrow.",
    1200,
    400,
    true,
    Colors.red,
    _av(16),
  ),
  Post(
    'Academic Burnout',
    'tired_scholar',
    '1h',
    "I stared at a blank Word doc for 4 hours straight.",
    "Thesis due in a week. Brain completely fried.",
    512,
    89,
    true,
    Colors.redAccent,
    _av(22),
  ),
  Post(
    'Academic Burnout',
    'drop_out_thought',
    '8h',
    "I've thought about dropping out every single day this semester.",
    "I won't. I can't. But the thought keeps coming back.",
    1100,
    310,
    true,
    Colors.redAccent,
    _av(28),
  ),
  Post(
    'Friendship Drama',
    'ghosted_again',
    '2h',
    "My friend group made a separate chat without me.",
    "I saw the notifications on my roommate's phone.",
    890,
    150,
    true,
    Colors.purpleAccent,
    _av(29),
  ),
  Post(
    'Career Anxiety',
    'quietstriver',
    '4h',
    "Can't stop comparing myself to peers who got FAANG offers.",
    "Everyone from my cohort seems to have figured it out.",
    312,
    47,
    true,
    Colors.indigoAccent,
    _av(35),
  ),
  Post(
    'Family Issues',
    'high_expectations',
    '1h',
    "My parents sacrificed so much. I can't afford to fail them.",
    "Every B+ feels like I've betrayed years of their hard work.",
    920,
    240,
    true,
    Colors.deepOrange,
    _av(2),
  ),
  Post(
    'Dark Thoughts',
    'shadow_walker',
    '1h',
    "I just want everything to stop.",
    "So tired of waking up and feeling this heavy weight every single morning.",
    911,
    103,
    true,
    Colors.red,
    _av(6),
  ),
  Post(
    'Financial Anxiety',
    'broke_student',
    '5h',
    "How do people afford to live right now?",
    "Rent up, groceries insane.",
    1200,
    310,
    false,
    Colors.green,
    _av(9),
  ),
  Post(
    'Social Media Trap',
    'highlight_reel',
    '30m',
    "Everyone on Instagram looks like they have life figured out at 22.",
    "Perfect holidays. Perfect bodies. Perfect careers.",
    1340,
    420,
    true,
    Colors.cyan,
    _av(19),
  ),
  Post(
    'Future Doubts',
    '25_and_lost',
    '1h',
    "Graduating in 3 months and I've never been more terrified.",
    "Everyone asks 'what's next?' I genuinely don't know.",
    1050,
    310,
    true,
    Colors.amber,
    _av(25),
  ),
  Post(
    'Phone Addiction',
    'screen_zombie',
    '4h',
    "I pick up my phone before I even open my eyes in the morning.",
    "First and last thing I see every day.",
    760,
    175,
    true,
    Colors.lightGreen,
    _av(37),
  ),
  Post(
    'Procrastination',
    'paralysed_14',
    '3h',
    "My to-do list has 14 items. Been staring at it since 9am.",
    "I kept reorganising the list instead of doing anything on it.",
    870,
    220,
    true,
    Colors.orange,
    _av(1),
  ),
  Post(
    'Sleep Struggles',
    'nocturnalfix',
    '1d',
    "3am again. Anyone else's anxiety peak at night?",
    "Daytime I'm okay-ish. The moment I lie down my brain writes horror scripts.",
    544,
    88,
    true,
    Colors.indigoAccent,
    _av(19),
  ),
  Post(
    'Relationships',
    'attachment_anxiety',
    '3h',
    "I love him but the moment he's quiet I spiral into 'he hates me.'",
    "I know it's my anxiety not reality. How do I fix this?",
    870,
    215,
    true,
    const Color(0xFFFF4D7D),
    _av(22),
  ),
];

const _categories = [
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

List<Post> get _trending {
  final sorted = [..._posts]..sort((a, b) => b.points.compareTo(a.points));
  return sorted.take(3).toList();
}

class Resource {
  final String title, desc, btnText, imageUrl, url;
  final Color color;

  const Resource(
    this.title,
    this.desc,
    this.btnText,
    this.imageUrl,
    this.color,
    this.url,
  );
}

Map<String, List<Resource>> _sidebarResources = {};

class FeedScreen extends StatefulWidget {
  final int initialCategoryIndex;

  const FeedScreen({super.key, this.initialCategoryIndex = 0});

  @override
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> {
  late int _catIdx;
  final Set<int> _upvoted = {};
  final Set<int> _downvoted = {};

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _catIdx = widget.initialCategoryIndex;
  }

  @override
  void didUpdateWidget(covariant FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategoryIndex != widget.initialCategoryIndex) {
      setState(() {
        _catIdx = widget.initialCategoryIndex;
      });
    }
  }

  List<Post> get _filtered {
    var list = _posts;
    if (_catIdx != 0) {
      list = list.where((p) => p.category == _categories[_catIdx]).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list
          .where(
            (p) =>
                p.title.toLowerCase().contains(query) ||
                p.body.toLowerCase().contains(query),
          )
          .toList();
    }
    return list;
  }

  Future<void> _launch(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint('Could not launch $url');
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Academic Burnout':
        return Colors.redAccent;
      case 'Loneliness':
        return Colors.blueGrey;
      case 'Overthinking':
        return Colors.tealAccent;
      case 'Bullying':
        return Colors.red;
      case 'Friendship Drama':
        return Colors.purpleAccent;
      case 'Financial Anxiety':
        return Colors.green;
      case 'Career Anxiety':
        return Colors.indigoAccent;
      case 'Dark Thoughts':
        return Colors.red;
      case 'Body Insecurity':
        return Colors.pinkAccent;
      case 'Family Issues':
        return Colors.deepOrange;
      case 'Social Media Trap':
        return Colors.cyan;
      case 'Future Doubts':
        return Colors.amber;
      case 'Trauma':
        return Colors.deepPurple;
      case 'Phone Addiction':
        return Colors.lightGreen;
      case 'Procrastination':
        return Colors.orange;
      case 'Feeling Unattractive':
        return Colors.pink;
      case 'No One To Talk To':
        return Colors.teal;
      case 'Identity & Self-Worth':
        return Colors.limeAccent;
      case 'Sleep Struggles':
        return Colors.indigoAccent;
      case 'Relationships':
        return const Color(0xFFFF4D7D);
      default:
        return Colors.tealAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: _textSub,
                            ),
                            hintText: "Search Healance...",
                            hintStyle: const TextStyle(color: _textSub),
                            filled: true,
                            fillColor: _card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildPostInputFake(),

                      const SizedBox(height: 16),
                      _buildTrendingStrip(),
                      const SizedBox(height: 16),
                      CategoryBar(
                        selected: _catIdx,
                        onTap: (i) => setState(() => _catIdx = i),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_filtered.length, (i) {
                        final post = _filtered[i];
                        final globalIdx = _posts.indexOf(post);

                        return RichPostCard(
                          post: post,
                          upvoted: _upvoted.contains(globalIdx),
                          downvoted: _downvoted.contains(globalIdx),
                          onUpvote: () => setState(() {
                            if (_upvoted.contains(globalIdx)) {
                              _upvoted.remove(globalIdx);
                            } else {
                              _upvoted.add(globalIdx);
                              _downvoted.remove(globalIdx);
                            }
                          }),
                          onDownvote: () => setState(() {
                            if (_downvoted.contains(globalIdx)) {
                              _downvoted.remove(globalIdx);
                            } else {
                              _downvoted.add(globalIdx);
                              _upvoted.remove(globalIdx);
                            }
                          }),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isWide)
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
                child: Column(children: _buildSidePanel()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingStrip() {
    final trendingList = _trending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: _accent,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                'Trending Today',
                style: TextStyle(
                  color: _textTitle,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trendingList.length,
            itemBuilder: (context, i) {
              return _TrendingCard(
                post: trendingList[i],
                rank: i + 1,
                onTap: () {
                  final newIdx = _categories.indexOf(trendingList[i].category);
                  if (newIdx != -1) setState(() => _catIdx = newIdx);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostInputFake() {
    return GestureDetector(
      onTap: () => _showCreatePostForm(context),
      child: Card(
        elevation: 0,
        color: _card,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: _border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid ?? 'guest')
                    .snapshots(),
                builder: (context, snapshot) {
                  String avatarUrl =
                      'https://api.dicebear.com/8.x/notionists/png?seed=fallback';

                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data != null && data.containsKey('avatarUrl')) {
                      avatarUrl = data['avatarUrl']?.toString() ?? avatarUrl;
                    }
                  }

                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white10,
                    backgroundImage: NetworkImage(avatarUrl),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _border),
                  ),
                  child: const Text(
                    "Create Post anonymously...",
                    style: TextStyle(color: _textSub, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🚨 AI-POWERED CREATE POST FORM
  void _showCreatePostForm(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    bool isClassifying = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Create an Anonymous Post",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "This is a safe space. Your identity is hidden. AI will automatically sort your post.",
                      style: TextStyle(color: _textSub, fontSize: 13),
                    ),
                    const Divider(color: _border, height: 30),

                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Title",
                        hintStyle: const TextStyle(color: _textSub),
                        filled: true,
                        fillColor: _bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: bodyController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Share what's on your mind...",
                        hintStyle: const TextStyle(color: _textSub),
                        filled: true,
                        fillColor: _bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: _accent.withOpacity(0.6),
                        ),
                        onPressed: isClassifying
                            ? null
                            : () async {
                                if (titleController.text.isNotEmpty &&
                                    bodyController.text.isNotEmpty) {
                                  // 1. Turn on loading spinner
                                  setModalState(() => isClassifying = true);

                                  // 2. AI Categorization
                                  String detectedCategory =
                                      'Loneliness'; // Fallback
                                  try {
                                    final combinedText =
                                        "TITLE: ${titleController.text}\nBODY: ${bodyController.text}";

                                    final aiResult =
                                        await HelanceAIService.analyzePost(
                                          combinedText,
                                        );
                                    detectedCategory =
                                        aiResult['category'] as String;

                                    if (!_categories.contains(
                                      detectedCategory,
                                    )) {
                                      detectedCategory = 'Overthinking';
                                    }

                                    UserActivityTracker.addPost(combinedText);
                                  } catch (e) {
                                    debugPrint("AI Classification failed: $e");
                                  }

                                  // 3. Profile Fetch
                                  String anonName =
                                      'anon_striver_${DateTime.now().millisecondsSinceEpoch % 1000}';
                                  String anonAvatar = _av(
                                    DateTime.now().millisecondsSinceEpoch,
                                  );

                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    try {
                                      final doc = await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .get();
                                      if (doc.exists && doc.data() != null) {
                                        final data =
                                            doc.data() as Map<String, dynamic>?;
                                        if (data != null) {
                                          anonName =
                                              data['username']?.toString() ??
                                              anonName;
                                          anonAvatar =
                                              data['avatarUrl']?.toString() ??
                                              anonAvatar;
                                        }
                                      }
                                    } catch (e) {
                                      debugPrint("Profile fetch error: $e");
                                    }
                                  }

                                  if (!context.mounted) return;

                                  // 4. Save and Update UI
                                  setState(() {
                                    _posts.insert(
                                      0,
                                      Post(
                                        detectedCategory,
                                        anonName,
                                        'Just now',
                                        titleController.text,
                                        bodyController.text,
                                        1,
                                        0,
                                        true,
                                        _getColorForCategory(detectedCategory),
                                        anonAvatar,
                                      ),
                                    );
                                    _catIdx = 0;
                                  });

                                  setModalState(() => isClassifying = false);
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Post sorted into #$detectedCategory!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill out both the title and body.',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                        child: isClassifying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "Post Anonymously",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildSidePanel() {
    final cat = _categories[_catIdx];
    final resources =
        _sidebarResources[cat] ??
        [
          const Resource(
            'Headspace',
            'Learn to meditate and live mindfully.',
            'Try Headspace',
            'https://images.unsplash.com/photo-1528319725582-ddc096101511?w=500',
            Colors.orangeAccent,
            'https://www.headspace.com/',
          ),
          const Resource(
            'Meetup Malaysia',
            'Find low-pressure local groups for hobbies you love.',
            'Explore Meetup',
            'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?w=500',
            Colors.pinkAccent,
            'https://www.meetup.com/cities/my/',
          ),
        ];

    final widgets = <Widget>[];
    for (int i = 0; i < resources.length; i++) {
      widgets.add(_buildActionCard(resources[i]));
      if (i < resources.length - 1) widgets.add(const SizedBox(height: 16));
    }
    return widgets;
  }

  Widget _buildActionCard(Resource r) {
    return Card(
      elevation: 0,
      color: _card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage(r.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: r.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  r.desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textTitle,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _launch(r.url),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: r.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      r.btnText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final Post post;
  final int rank;
  final VoidCallback onTap;

  const _TrendingCard({
    required this.post,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: rank == 1
                ? Colors.amber.withOpacity(0.5)
                : Colors.grey.withOpacity(0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textTitle,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(
                  Icons.arrow_upward_rounded,
                  size: 14,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.points}',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: post.tagColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#${post.category.replaceAll(' ', '')}',
                    style: TextStyle(
                      color: post.tagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;

  const CategoryBar({super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final sel = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? _textTitle : _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? _textTitle : _border),
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  color: sel ? _bg : _textSub,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RichPostCard extends StatelessWidget {
  final Post post;
  final bool upvoted, downvoted;
  final VoidCallback onUpvote, onDownvote;

  const RichPostCard({
    super.key,
    required this.post,
    required this.upvoted,
    required this.downvoted,
    required this.onUpvote,
    required this.onDownvote,
  });

  void _showCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Comments on '${post.title}'",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: _border, height: 30),
              Expanded(
                child: ListView(
                  children: [
                    _buildDummyComment(
                      "I completely relate to this. You are not alone.",
                      "anon_butterfly",
                      "2h ago",
                    ),
                    _buildDummyComment(
                      "Hang in there! Things will get better.",
                      "brave_striver",
                      "5h ago",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Add an anonymous comment...",
                  hintStyle: const TextStyle(color: _textSub),
                  filled: true,
                  fillColor: _bg,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: _accent),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comment posted!')),
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDummyComment(String text, String user, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey.shade800,
            child: const Icon(Icons.person, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user,
                    style: const TextStyle(
                      color: _textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(color: _textTitle, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int displayPoints = post.points + (upvoted ? 1 : 0) - (downvoted ? 1 : 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: _card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _bg.withOpacity(0.5),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(8),
              ),
              border: const Border(right: BorderSide(color: _border)),
            ),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                    color: upvoted ? Colors.blueAccent : _textSub,
                    size: 20,
                  ),
                  onPressed: onUpvote,
                ),
                Text(
                  '$displayPoints',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: upvoted
                        ? Colors.blueAccent
                        : (downvoted ? Colors.redAccent : _textTitle),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_downward_rounded,
                    color: downvoted ? Colors.redAccent : _textSub,
                    size: 20,
                  ),
                  onPressed: onDownvote,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🚨 UI RESTORED HERE: The Category and AI Verified badges are back!
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white10,
                        backgroundImage: NetworkImage(post.avatarUrl),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.user,
                        style: const TextStyle(
                          color: _textSub,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.time,
                        style: const TextStyle(color: _textSub, fontSize: 12),
                      ),

                      const Spacer(), // Pushes the badges to the right side
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: post.tagColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${post.category.replaceAll(' ', '')}',
                          style: TextStyle(
                            color: post.tagColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // AI Verified Badge
                      if (post.aiSupported) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.blueAccent,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI Verified',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textTitle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textTitle,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _showCommentsSheet(context),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: _textSub,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${post.comments} Comments',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textSub,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () async {
                          await Share.share(
                            "Check out this post on Héalance:\n\n${post.title}\n${post.body}",
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.share_outlined,
                                size: 16,
                                color: _textSub,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Share',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textSub,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
