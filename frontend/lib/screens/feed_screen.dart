import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

// Global list so it can be mutated by the Create Post form
final List<Post> _posts = [
  Post(
    'Loneliness',
    'empty_room',
    '1d',
    "I haven't spoken out loud to anyone in 3 days.",
    "Online classes make it so easy to disappear. Nobody checks in. Not even once. I turned my camera off in week two and have basically been invisible since. Part of me wonders if anyone would even notice if I stopped showing up entirely.",
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
    "Too scared to sit in the cafeteria alone. People look at you like something's wrong with you.",
    890,
    210,
    true,
    Colors.blueGrey,
    _av(2),
  ),
  Post(
    'Loneliness',
    'ghosted_guy',
    '2d',
    "Does anyone actually maintain friendships after high school?",
    "Everyone moved on. I'm still calling people who never pick up.",
    320,
    45,
    false,
    Colors.blueGrey,
    _av(3),
  ),
  Post(
    'Loneliness',
    'invisible_kid',
    '3h',
    "I said bye to my classmates and none of them heard me.",
    "I just stood there, waited, then walked away. I don't think I exist to them.",
    1100,
    290,
    true,
    Colors.blueGrey,
    _av(4),
  ),
  Post(
    'Loneliness',
    'midnight_scroller',
    '1h',
    "It's 2am and I have nobody to text.",
    "So here I am posting this instead.",
    670,
    134,
    false,
    Colors.blueGrey,
    _av(5),
  ),
  Post(
    'Overthinking',
    'brain_buzz',
    '5h',
    "Replaying a conversation from 3 years ago.",
    "Why did I say that? They definitely still think about it. My brain won't let it go. I was 17.",
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
    "If I don't get an A I won't graduate, won't get hired, will be homeless.",
    "The spiral happens so fast. One bad mark and I've catastrophised my entire future.",
    900,
    150,
    true,
    Colors.tealAccent,
    _av(10),
  ),
  Post(
    'Overthinking',
    'decision_loop',
    '6h',
    "I can't choose a lunch option without a 20-minute internal debate.",
    "Every small decision feels enormous. I'm completely drained by 9am from just existing.",
    388,
    91,
    true,
    Colors.tealAccent,
    _av(12),
  ),
  Post(
    'Bullying',
    'silent_cry',
    '12h',
    "Someone made a meme about me in the uni WhatsApp group.",
    "200 people laughing. I don't want to go to class tomorrow. Or ever. I screenshotted it and I keep opening it.",
    1200,
    400,
    true,
    Colors.red,
    _av(16),
  ),
  Post(
    'Bullying',
    'fake_friends',
    '2h',
    "I caught them making fun of my presentation in the back row.",
    "They thought I couldn't see them texting and laughing. It destroyed something in me.",
    650,
    120,
    true,
    Colors.red,
    _av(17),
  ),
  Post(
    'Bullying',
    'anon_hate',
    '1d',
    "Getting horrible DMs from an anonymous account.",
    "They know specific things only people in my course would know. I feel unsafe on campus now.",
    880,
    250,
    true,
    Colors.red,
    _av(18),
  ),
  Post(
    'Academic Burnout',
    'tired_scholar',
    '1h',
    "I stared at a blank Word doc for 4 hours straight.",
    "Thesis due in a week. Brain completely fried. I used to love this subject.",
    512,
    89,
    true,
    Colors.redAccent,
    _av(22),
  ),
  Post(
    'Academic Burnout',
    'caffeine_veins',
    '3h',
    "Is it normal to cry over a 2.8 GPA?",
    "I studied so hard this semester. I feel like a massive disappointment to everyone.",
    820,
    140,
    true,
    Colors.redAccent,
    _av(23),
  ),
  Post(
    'Academic Burnout',
    'drop_out_thought',
    '8h',
    "I've thought about dropping out every single day this semester.",
    "I won't. I can't. But the thought keeps coming back like it's offering something.",
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
    "I saw the notifications on my roommate's phone. I pretended I didn't notice.",
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
    "Everyone from my cohort seems to have figured it out. I freeze in every interview.",
    312,
    47,
    true,
    Colors.indigoAccent,
    _av(35),
  ),
  Post(
    'Career Anxiety',
    'linkedin_dread',
    '2h',
    "Opening LinkedIn has become a form of self-harm.",
    "Another classmate. Another dream job. I close the app and stare at the ceiling.",
    880,
    201,
    true,
    Colors.indigoAccent,
    _av(36),
  ),
  Post(
    'Family Issues',
    'black_sheep',
    '12h',
    "My parents refuse to acknowledge my mental health.",
    "They tell me to 'pray more' or 'stop being lazy.' It makes everything worse.",
    840,
    210,
    true,
    Colors.deepOrange,
    _av(1),
  ),
  Post(
    'Family Issues',
    'high_expectations',
    '1h',
    "My parents sacrificed so much. I can't afford to fail them.",
    "Every B+ feels like I've betrayed years of their hard work. The weight is crushing.",
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
    'Dark Thoughts',
    'invisible_pain',
    '3h',
    "I fantasise about disappearing and nobody noticing for days.",
    "Not dying. Just ceasing. A pause button on existing. The thought is loud lately.",
    800,
    187,
    true,
    Colors.red,
    _av(7),
  ),
  Post(
    'Financial Anxiety',
    'broke_student',
    '5h',
    "How do people afford to live right now?",
    "Rent up, groceries insane. My PTPTN runs out by the 2nd week of every month.",
    1200,
    310,
    false,
    Colors.green,
    _av(9),
  ),
  Post(
    'Financial Anxiety',
    'skip_meals',
    '3h',
    "Skipped lunch again to make it to Friday.",
    "It's Thursday. I have RM4.50. I tell people I'm just 'not hungry.'",
    980,
    280,
    true,
    Colors.green,
    _av(10),
  ),
  Post(
    'Body Insecurity',
    'mirror_hate',
    '8h',
    "Gained 10kg this semester. I dread every photo.",
    "How do people stay fit studying 12 hours a day and stress-eating at midnight?",
    422,
    88,
    false,
    Colors.pinkAccent,
    _av(14),
  ),
  Post(
    'Social Media Trap',
    'highlight_reel',
    '30m',
    "Everyone on Instagram looks like they have life figured out at 22.",
    "Perfect holidays. Perfect bodies. Perfect careers. I know it's curated. Still destroys me.",
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
    "Everyone asks 'what's next?' I genuinely don't know. That feels shameful at 22.",
    1050,
    310,
    true,
    Colors.amber,
    _av(25),
  ),
  Post(
    'Trauma',
    'not_over_it',
    '6h',
    "People say 'that was years ago.' My body didn't get the memo.",
    "Smells. Sounds. Certain phrases. I'm back there instantly. Exhausted by my own triggers.",
    870,
    220,
    true,
    Colors.deepPurple,
    _av(32),
  ),
  Post(
    'Phone Addiction',
    'screen_zombie',
    '4h',
    "I pick up my phone before I even open my eyes in the morning.",
    "First and last thing I see every day. My attention span is functionally gone.",
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
    "My to-do list has 14 items. Been staring at it since 9am. It's 4pm.",
    "I kept reorganising the list instead of doing anything on it. Classic.",
    870,
    220,
    true,
    Colors.orange,
    _av(1),
  ),
  Post(
    'Feeling Unattractive',
    'rejected_again',
    '6h',
    "Left on read after the first date. I know why.",
    "I'm not conventionally attractive. I've accepted that. Doesn't hurt less.",
    590,
    135,
    false,
    Colors.pink,
    _av(6),
  ),
  Post(
    'No One To Talk To',
    'burden_fear',
    '1h',
    "I need to talk to someone but I don't want to be a burden.",
    "Everyone has their own problems. Why would I pile mine on top? So I don't.",
    1050,
    290,
    true,
    Colors.teal,
    _av(10),
  ),
  Post(
    'Identity & Self-Worth',
    'who_am_i',
    '4h',
    "I perform different versions of myself for different people. Who is the original?",
    "Home version. Friend version. Work version. I've lost track of the real one.",
    720,
    168,
    true,
    Colors.limeAccent,
    _av(15),
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
    "I know it's my anxiety not reality. The fear is so loud. How do I fix this?",
    870,
    215,
    true,
    Color(0xFFFF4D7D),
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

Map<String, List<Resource>> _sidebarResources = {
  // Add specific resources here if needed in the future
};

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

  // THIS IS THE FIX FOR THE SIDEBAR:
  // Listens for changes from main.dart's sidebar and updates the local category filter
  @override
  void didUpdateWidget(covariant FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategoryIndex != widget.initialCategoryIndex) {
      setState(() {
        _catIdx = widget.initialCategoryIndex;
      });
    }
  }

  // ALL FILTERING HAPPENS HERE
  List<Post> get _filtered {
    var list = _posts;

    // Filter by Category Space
    if (_catIdx != 0) {
      list = list.where((p) => p.category == _categories[_catIdx]).toList();
    }

    // Filter by Search Text Bar
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
                  if (newIdx != -1) {
                    setState(() => _catIdx = newIdx);
                  }
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
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  'https://api.dicebear.com/8.x/notionists/png?seed=You',
                ),
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

  // FULLY IMPLEMENTED CREATE POST FORM
  void _showCreatePostForm(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String selectedCategory = 'Loneliness'; // Default starting category

    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  "This is a safe space. Your identity is hidden.",
                  style: TextStyle(color: _textSub, fontSize: 13),
                ),
                const Divider(color: _border, height: 30),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: _bg,
                  icon: const Icon(Icons.arrow_drop_down, color: _textSub),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _bg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _categories
                      .where((c) => c != 'All')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedCategory = val;
                  },
                ),
                const SizedBox(height: 16),

                // Title Input
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

                // Body Input
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

                // Submit Button
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
                    ),
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          bodyController.text.isNotEmpty) {
                        setState(() {
                          // Insert the new post at the very top of the global list
                          _posts.insert(
                            0,
                            Post(
                              selectedCategory,
                              'anon_striver_${DateTime.now().millisecondsSinceEpoch % 1000}', // Random anon name
                              'Just now',
                              titleController.text,
                              bodyController.text,
                              1, // Start with 1 upvote
                              0, // 0 comments
                              false,
                              _getColorForCategory(selectedCategory),
                              _av(
                                DateTime.now().millisecondsSinceEpoch,
                              ), // Assign random avatar
                            ),
                          );
                          // Reset the category view to 'All' so the user sees their post immediately
                          _catIdx = 0;
                        });

                        Navigator.pop(context); // Close the bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post published anonymously!'),
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
                    child: const Text(
                      "Post Anonymously",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
          const Resource(
            'Anytime Fitness',
            'Physical health drives mental health. 3-Day Free Trial.',
            'Claim Free Trial',
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500',
            Colors.purpleAccent,
            'https://www.anytimefitness.my/try-us-free/',
          ),
        ];

    final widgets = <Widget>[];
    for (int i = 0; i < resources.length; i++) {
      widgets.add(_buildActionCard(resources[i]));
      if (i < resources.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
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
                Icon(
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
