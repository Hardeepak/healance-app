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

// ── FIX 4: Static flag — mood modal shown only once per app session ──────
bool _moodModalShownThisSession = false;

// ── FIX 2: EXPANDED AVATAR PALETTE — 15 distinct colors (matches login_screen.dart) ──
// Extended so indices 0–14 are all unique, no repeats
const List<Color> _avatarPalette = [
  Color(0xFF37474F), // 0  blue-grey
  Color(0xFF4E342E), // 1  brown
  Color(0xFF283593), // 2  deep blue
  Color(0xFF1B5E20), // 3  dark green
  Color(0xFF4A148C), // 4  deep purple
  Color(0xFF880E4F), // 5  dark pink
  Color(0xFF006064), // 6  cyan teal
  Color(0xFF33691E), // 7  olive green
  Color(0xFF5D4037), // 8  warm brown
  Color(0xFF01579B), // 9  navy blue
  Color(0xFF3E2723), // 10 espresso
  Color(0xFF212121), // 11 near-black
  Color(0xFF0D47A1), // 12 royal blue  ← was repeat of 0
  Color(0xFF558B2F), // 13 medium green ← was repeat of 1
  Color(0xFF6A1B9A), // 14 violet       ← was repeat of 2
];

// ── AVATAR HELPER ─────────────────────────────────────────────────────────
Color _avatarColor(int index) {
  return _avatarPalette[index % _avatarPalette.length];
}

// ── AVATAR WIDGET ─────────────────────────────────────────────────────────
class _AvatarWidget extends StatelessWidget {
  final int index;
  final double radius;
  const _AvatarWidget({required this.index, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _avatarColor(index),
      child: Icon(Icons.person, size: radius * 1.1, color: Colors.white70),
    );
  }
}

// ── POST MODEL ────────────────────────────────────────────────────────────
class Post {
  final String category, user, time, title, body;
  final int points, comments, avatarIndex;
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
    this.avatarIndex,
  );
}

// ── SEED POSTS ────────────────────────────────────────────────────────────
final List<Post> _posts = [
  Post(
    'Loneliness',
    'empty_room',
    '1d',
    "I haven't spoken out loud to anyone in 3 days.",
    "Online classes make it so easy to disappear. Nobody checks in. Not even once. I turned my camera off in week two and have basically been invisible since. Part of me wonders if anyone would notice if I stopped showing up.",
    750,
    180,
    true,
    Colors.blueGrey,
    0,
  ),
  Post(
    'Loneliness',
    'crowded_room',
    '5h',
    "I have 5 roommates and still feel completely alone.",
    "We live together but don't really know each other. We just coexist. I eat at a different time so I don't have to make small talk. I've started to wonder if I'm the problem.",
    410,
    62,
    false,
    Colors.blueGrey,
    1,
  ),
  Post(
    'Loneliness',
    'solo_eater',
    '12h',
    "Eating lunch in the library bathroom again.",
    "Too scared to sit in the cafeteria alone. I've been doing this for three weeks. I bring a packed lunch and eat it on the toilet. I know how that sounds.",
    890,
    210,
    true,
    Colors.blueGrey,
    2,
  ),
  Post(
    'Loneliness',
    'strong_friend',
    '6h',
    "I'm the 'strong friend' and I'm completely exhausted.",
    "Everyone calls me when they're struggling. Nobody asks how I'm doing. I'm not okay.",
    980,
    265,
    true,
    Colors.blueGrey,
    3,
  ),
  Post(
    'Loneliness',
    'invisible_girl',
    '3h',
    "I sat next to the same person for a whole semester and they don't know my name.",
    "We've had full conversations. I've helped them with assignments. They introduced me to someone last week as 'this girl'. I cried in the bathroom after.",
    670,
    145,
    true,
    Colors.blueGrey,
    4,
  ),
  Post(
    'Overthinking',
    'brain_buzz',
    '5h',
    "Replaying a conversation from 3 years ago.",
    "Why did I say that? They definitely still think about it. I was 17. It was a throwaway comment at a party. I'm 20 now and it still hits me at 2am.",
    544,
    212,
    true,
    Colors.tealAccent,
    5,
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
    6,
  ),
  Post(
    'Overthinking',
    'text_analyzer',
    '3h',
    'They replied with "ok." instead of "ok!" and I\'ve been analysing it for 4 hours.',
    "The full stop. THE FULL STOP. I've drafted 11 replies and sent none of them.",
    210,
    80,
    false,
    Colors.tealAccent,
    7,
  ),
  Post(
    'Bullying',
    'silent_cry',
    '12h',
    "Someone made a meme about me in the uni WhatsApp group.",
    "200 people laughing. I don't want to go to class tomorrow. Or ever. I screenshotted it and I keep opening it, which I know is the worst thing to do.",
    1200,
    400,
    true,
    Colors.red,
    8,
  ),
  Post(
    'Bullying',
    'anon_hate',
    '1d',
    "Getting horrible DMs from an anonymous account.",
    "They know specific things only people in my course would know. I feel unsafe on campus now. I've reported it but they said they can't do anything without knowing who it is.",
    880,
    250,
    true,
    Colors.red,
    9,
  ),
  Post(
    'Bullying',
    'body_comment',
    '6h',
    'A classmate called me "the fat one" in front of everyone as a casual descriptor.',
    "Said it like it was fine. Room went silent. I haven't gone back to that class since.",
    990,
    310,
    true,
    Colors.red,
    10,
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
    11,
  ),
  Post(
    'Academic Burnout',
    'drop_out_thought',
    '8h',
    "I've thought about dropping out every single day this semester.",
    "I won't. I can't. But the thought keeps coming back like it's offering something. It feels like a door I know I can't open. But I keep looking at it.",
    1100,
    310,
    true,
    Colors.redAccent,
    12,
  ),
  Post(
    'Academic Burnout',
    'library_tears',
    '6h',
    "Cried in the library stairwell between classes today.",
    "Not sure exactly why. It just all hit me at once between the 2nd and 3rd floor.",
    750,
    168,
    false,
    Colors.redAccent,
    13,
  ),
  Post(
    'Academic Burnout',
    'grade_spiral',
    '11h',
    "My grades are dropping and I don't even care anymore.",
    "That's the scariest part. I used to care SO much. Now it's just static. All of it.",
    830,
    190,
    true,
    Colors.redAccent,
    14,
  ),
  Post(
    'Academic Burnout',
    'perfectionist_breaks',
    '2h',
    "I got a B+ and I genuinely wanted to disappear.",
    "I know that's irrational. I know it's still good. My brain doesn't care. My parents paid so much for this degree. A B+ feels like a betrayal.",
    920,
    200,
    true,
    Colors.redAccent,
    0,
  ),
  Post(
    'Friendship Drama',
    'ghosted_again',
    '2h',
    "My friend group made a separate chat without me.",
    "I saw the notifications on my roommate's phone. I've been going over every interaction trying to figure out what I did.",
    890,
    150,
    true,
    Colors.purpleAccent,
    1,
  ),
  Post(
    'Friendship Drama',
    'two_faced',
    '14h',
    "My 'best friend' told everyone something I said in confidence.",
    "It was personal and raw. Now it's a talking point in our entire course group.",
    940,
    270,
    true,
    Colors.purpleAccent,
    2,
  ),
  Post(
    'Friendship Drama',
    'slow_fade',
    '4h',
    "My closest friend just... slowly stopped replying. No fight. No reason.",
    "It's been two months. The slow fade is so much worse than a proper falling out. At least then I'd know what happened. Now I just replay everything wondering what I did wrong.",
    760,
    180,
    true,
    Colors.purpleAccent,
    3,
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
    4,
  ),
  Post(
    'Career Anxiety',
    'rejection_pile',
    '7h',
    "Applied to 40 places. 2 rejections. 38 silences.",
    "The silence is somehow worse. Like I don't even deserve an actual no.",
    630,
    140,
    false,
    Colors.indigoAccent,
    5,
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
    6,
  ),
  Post(
    'Dark Thoughts',
    'shadow_walker',
    '1h',
    "I just want everything to stop.",
    "So tired of waking up and feeling this heavy weight every single morning. I don't want to hurt myself. I just want to not feel this anymore.",
    911,
    103,
    true,
    Colors.red,
    7,
  ),
  Post(
    'Dark Thoughts',
    'numb_life',
    '8h',
    "I don't feel sad anymore. I just feel nothing. Is that worse?",
    "At least sadness means something is there. This emptiness genuinely terrifies me.",
    750,
    175,
    true,
    Colors.red,
    8,
  ),
  Post(
    'Dark Thoughts',
    'pretending_fine',
    '3h',
    "I've been performing 'okay' for so long I've forgotten what real okay feels like.",
    "I smile in class. I answer when people ask. I laugh at the right times. Then I go home and stare at the ceiling for two hours before I can even start my assignments.",
    1050,
    290,
    true,
    Colors.red,
    9,
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
    10,
  ),
  Post(
    'Financial Anxiety',
    'family_provider',
    '2h',
    "I send money home every month. I'm a student eating plain rice.",
    "I don't regret helping them. But I'm scared how long I can keep this up.",
    890,
    210,
    true,
    Colors.green,
    11,
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
    12,
  ),
  Post(
    'Financial Anxiety',
    'hidden_broke',
    '1h',
    "I pretend to be busy when friends want to eat out because I can't afford it.",
    "I've said 'oh I have an assignment' so many times. The truth is I have RM8 until Thursday and I'd rather be alone than explain that.",
    840,
    195,
    true,
    Colors.green,
    13,
  ),
  Post(
    'Family Issues',
    'high_expectations',
    '1h',
    "My parents sacrificed so much. I can't afford to fail them.",
    "Every B+ feels like I've betrayed years of their hard work. My dad drove Grab for two years to pay for my first semester.",
    920,
    240,
    true,
    Colors.deepOrange,
    14,
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
    0,
  ),
  Post(
    'Family Issues',
    'long_distance_guilt',
    '5h',
    "Called home and lied about how I'm doing for the 6th week in a row.",
    "Mum would worry. Dad would drive 4 hours here. So I say 'alright la, just busy.' I hang up and cry into my pillow.",
    910,
    235,
    true,
    Colors.deepOrange,
    1,
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
    2,
  ),
  Post(
    'Social Media Trap',
    'comparison_hourly',
    '9h',
    "I know comparison kills me. I do it every hour anyway.",
    "Deleted the apps. Reinstalled within 3 days. Why is this impossible to stop?",
    680,
    158,
    true,
    Colors.cyan,
    3,
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
    4,
  ),
  Post(
    'Future Doubts',
    'climate_dread',
    '6h',
    "I don't plan for the future because I'm not sure my generation has one.",
    "Climate, economy, AI replacing jobs. Why study for a world that might not exist? I know that's nihilistic. But sometimes late at night it genuinely feels rational.",
    1100,
    300,
    true,
    Colors.amber,
    5,
  ),
  Post(
    'Future Doubts',
    'degree_doubt',
    '2h',
    "I'm finishing a degree I hate for a job I don't want.",
    "Three years in. RM40k of debt. And I sit in lectures wondering why I'm here. I chose this because it seemed 'safe'. Now I just feel trapped.",
    980,
    275,
    true,
    Colors.amber,
    6,
  ),
  Post(
    'Trauma',
    'healing_backward',
    '8h',
    "I thought I was getting better. One bad week undid months of progress.",
    "Nobody tells you healing goes backwards. I felt so ashamed. Like I failed at recovering.",
    790,
    195,
    true,
    Colors.deepPurple,
    7,
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
    8,
  ),
  Post(
    'Procrastination',
    'lazy_or_depressed',
    '1h',
    "Am I lazy or is this depression? I genuinely can't tell anymore.",
    "I WANT to do things. My body won't cooperate. My brain calls me worthless for it.",
    1100,
    310,
    true,
    Colors.orange,
    9,
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
    10,
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
    11,
  ),
  Post(
    'Sleep Struggles',
    'sleep_impossible',
    '6h',
    "It's 4am. I have a 9am class. I've been trying to sleep since midnight.",
    "Took melatonin. Tried box breathing. Phone off. Eyes closed. Nothing. My brain just keeps going and going and I don't even know what about.",
    720,
    160,
    true,
    Colors.indigoAccent,
    12,
  ),
  Post(
    'Relationships',
    'attachment_anxiety',
    '3h',
    "I love him but the moment he's quiet I spiral into 'he hates me.'",
    "I know it's my anxiety not reality. The fear is so loud. We've been together 8 months. He's patient. But I can feel him getting tired.",
    870,
    215,
    true,
    const Color(0xFFFF4D7D),
    13,
  ),
  Post(
    'Relationships',
    'afraid_to_love',
    '7h',
    "I push everyone away the moment they get close. I don't know how to stop.",
    "There's someone who genuinely likes me. And I've been slowly making myself unbearable because I'm terrified of being left. I know I'm doing it. I can't stop.",
    950,
    240,
    true,
    const Color(0xFFFF4D7D),
    14,
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
    0,
  ),
  Post(
    'No One To Talk To',
    'midnight_alone',
    '2h',
    "It's 2am and I just need someone to tell me it's going to be okay.",
    "Not advice. Not a solution. Just someone to say it. My phone is full of contacts and I don't feel like I can call any of them.",
    1120,
    330,
    true,
    Colors.teal,
    1,
  ),
  Post(
    'Body Insecurity',
    'shrinking_self',
    '2h',
    "I barely eat and I'm starting to think that's fine.",
    "People compliment my body more now. That's messed up right? I know it is.",
    730,
    160,
    true,
    Colors.pinkAccent,
    2,
  ),
  Post(
    'Identity & Self-Worth',
    'never_enough',
    '6h',
    "No matter what I achieve it never feels like enough.",
    "Got first class. Cried. Then immediately moved the goalposts. What is wrong with me?",
    940,
    255,
    true,
    Colors.limeAccent,
    3,
  ),
  Post(
    'Identity & Self-Worth',
    'who_am_i',
    '4h',
    "I've spent so long being what everyone needs that I don't know who I actually am.",
    "The good student. The responsible one. The reliable friend. The good child. Who am I when nobody's watching? I genuinely don't know.",
    1030,
    280,
    true,
    Colors.limeAccent,
    4,
  ),
  Post(
    'Academic Burnout',
    'assignment_paralysis',
    '30m',
    "Extension approved. Didn't start it. Extension expired. Still didn't start it.",
    "I don't know what's wrong with me. I used to be the one who submitted early. Now I watch deadlines pass like I'm watching a train from the platform.",
    880,
    210,
    true,
    Colors.redAccent,
    5,
  ),
  Post(
    'Dark Thoughts',
    'exhausted_existing',
    '45m',
    "I'm not suicidal. I just don't understand why I'm supposed to want to be here.",
    "Like, what's the point? I do the things. Go to class, eat, sleep, repeat. For what? Nobody told me adulthood would feel this hollow.",
    1180,
    380,
    true,
    Colors.red,
    6,
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

// ── RESOURCE TYPE ENUM ────────────────────────────────────────────────────
enum ResourceType { link, book, video, test, paid, app }

// ── RESOURCE MODEL ────────────────────────────────────────────────────────
class Resource {
  final String title, desc, btnText, url, coverImageUrl;
  final Color color;
  final ResourceType type;

  const Resource({
    required this.title,
    required this.desc,
    required this.btnText,
    required this.color,
    required this.url,
    required this.type,
    required this.coverImageUrl,
  });
}

// ── TYPE LABEL & BADGE COLOR ──────────────────────────────────────────────
String _typeLabel(ResourceType t) {
  switch (t) {
    case ResourceType.book:
      return '📚 Book';
    case ResourceType.video:
      return '▶️ Video';
    case ResourceType.test:
      return '🧪 Quiz / Test';
    case ResourceType.paid:
      return '💼 Paid Service';
    case ResourceType.app:
      return '📱 App';
    case ResourceType.link:
      return '🔗 Website';
  }
}

Color _typeBadgeColor(ResourceType t) {
  switch (t) {
    case ResourceType.book:
      return const Color(0xFF8D6E63);
    case ResourceType.video:
      return Colors.red;
    case ResourceType.test:
      return Colors.teal;
    case ResourceType.paid:
      return const Color(0xFF5C6BC0);
    case ResourceType.app:
      return Colors.green;
    case ResourceType.link:
      return Colors.blueGrey;
  }
}

// ── FIX 1: RELIABLE FALLBACK IMAGE URLS ──────────────────────────────────
// All resource images now use Unsplash with stable topic-matched queries.
// The old png/logo URLs (Pomofocus, Notion, etc.) were fragile — replaced
// with curated Unsplash photos that match each resource's theme.

final Map<String, List<Resource>> _sidebarResources = {
  'Academic Burnout': [
    Resource(
      title: 'Atomic Habits',
      desc:
          "James Clear's groundbreaking guide to building tiny habits that compound into massive academic results. The book that changed how millions study.",
      btnText: 'View on Goodreads',
      color: const Color(0xFFFF6B35),
      url: 'https://www.goodreads.com/book/show/40121378-atomic-habits',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80',
    ),
    Resource(
      title: 'Pomofocus',
      desc:
          'The cleanest Pomodoro timer on the web. 25 min focus, 5 min break. Break your paralysis one sprint at a time.',
      btnText: 'Start Timer',
      color: Colors.redAccent,
      url: 'https://pomofocus.io/',
      type: ResourceType.app,
      // FIX 1: was pomofocus.io/icons/... (broken) → stable Unsplash
      coverImageUrl:
          'https://images.unsplash.com/photo-1495364141860-b0d03eccd065?w=400&q=80',
    ),
    Resource(
      title: 'Notion Student Planner',
      desc:
          'Free, beautiful student planner template used by thousands. Track assignments, deadlines, and goals — all in one place.',
      btnText: 'Get Template',
      color: Colors.white,
      url: 'https://www.notion.so/templates/student-planner',
      type: ResourceType.link,
      // FIX 1: was Unsplash photo already, keeping same style
      coverImageUrl:
          'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&q=80',
    ),
  ],

  'Loneliness': [
    Resource(
      title: 'The Art of Being Alone',
      desc:
          "Vironika Tugaleva's beautiful meditation on solitude — learning to enjoy your own company and stop waiting for others to fill the void.",
      btnText: 'View on Goodreads',
      color: const Color(0xFF5C6BC0),
      url:
          'https://www.goodreads.com/book/show/18245091-the-art-of-being-alone',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1507692049790-de0a70b4d17c?w=400&q=80',
    ),
    Resource(
      title: 'Bumble BFF',
      desc:
          'Swipe to find real friends — not dates — in your city. Low pressure, no awkwardness. Thousands of students use it to find their people.',
      btnText: 'Try Bumble BFF',
      color: const Color(0xFFFFD000),
      url: 'https://bumble.com/bff',
      type: ResourceType.app,
      coverImageUrl:
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400&q=80',
    ),
    Resource(
      title: '7 Cups',
      desc:
          'Free chat with trained listeners right now. Anonymous. No waitlist. Real humans who actually get it.',
      btnText: 'Talk Now',
      color: const Color(0xFF00C8A0),
      url: 'https://www.7cups.com/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400&q=80',
    ),
  ],

  'Overthinking': [
    Resource(
      title: 'The Worry Trick',
      desc:
          "Dr David Carbonell explains why anxiety tricks your brain and gives you the exact tools to stop the mental loops. Game-changer for overthinkers.",
      btnText: 'View on Goodreads',
      color: Colors.teal,
      url: 'https://www.goodreads.com/book/show/29771006-the-worry-trick',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=400&q=80',
    ),
    Resource(
      title: 'Calm',
      desc:
          'Science-backed breathing exercises and guided meditations specifically designed to quiet the overthinking spiral.',
      btnText: 'Download Calm',
      color: const Color(0xFF0077B6),
      url: 'https://www.calm.com/',
      type: ResourceType.app,
      coverImageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
    ),
    Resource(
      title: 'Anxiety & Overthinking Test',
      desc:
          'Free GAD-7 generalised anxiety screener. Takes 2 minutes, gives you a real sense of where you are and what kind of help to look for.',
      btnText: 'Take the Test',
      color: Colors.tealAccent,
      url: 'https://www.mdcalc.com/calc/1727/gad-7-general-anxiety-disorder-7',
      type: ResourceType.test,
      coverImageUrl:
          'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400&q=80',
    ),
  ],

  'Bullying': [
    Resource(
      title: 'Cyber999 Malaysia (MCMC)',
      desc:
          'Official Malaysian government channel to report cyberbullying. Your report can get content taken down and action taken.',
      btnText: 'Report Now',
      color: Colors.red,
      url: 'https://www.mcmc.gov.my/en/consumer/complaints/cyber999',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&q=80',
    ),
    Resource(
      title: 'Befrienders Malaysia',
      desc:
          'Free. Confidential. 24/7. Talk it through with someone trained to listen without judgment.',
      btnText: 'Call Now',
      color: Colors.redAccent,
      url: 'https://www.befrienders.org.my/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400&q=80',
    ),
    Resource(
      title: 'BetterHelp',
      desc:
          'Match with a licensed online therapist in 48 hours. Proper professional support for when things get serious.',
      btnText: 'Get Matched',
      color: const Color(0xFF214F6E),
      url: 'https://www.betterhelp.com/',
      type: ResourceType.paid,
      coverImageUrl:
          'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?w=400&q=80',
    ),
  ],

  'Career Anxiety': [
    Resource(
      title: '16Personalities Career Test',
      desc:
          'The most popular free personality + career test online. Millions have used it to find what actually fits them — not what looks safe.',
      btnText: 'Take Career Quiz',
      color: const Color(0xFF4E4187),
      url: 'https://www.16personalities.com/',
      type: ResourceType.test,
      coverImageUrl:
          'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400&q=80',
    ),
    Resource(
      title: '80,000 Hours',
      desc:
          'Research-backed guide to finding a career that actually matters. Built for confused graduates who want more than a job.',
      btnText: 'Explore Careers',
      color: const Color(0xFF1A1A2E),
      url: 'https://80000hours.org/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
    ),
    Resource(
      title: "So Good They Can't Ignore You",
      desc:
          "Cal Newport's antidote to the 'follow your passion' trap. Required reading if you have no idea what career actually suits you.",
      btnText: 'View on Goodreads',
      color: Colors.orange,
      url:
          'https://www.goodreads.com/book/show/13525945-so-good-they-can-t-ignore-you',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1521791136064-7986c2920216?w=400&q=80',
    ),
  ],

  'Dark Thoughts': [
    Resource(
      title: 'Befrienders Malaysia',
      desc:
          'Free, confidential 24/7 emotional support. You are not alone. Trained listeners ready right now.',
      btnText: 'Contact Now',
      color: Colors.redAccent,
      url: 'https://www.befrienders.org.my/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400&q=80',
    ),
    Resource(
      title: 'Mind Kami',
      desc:
          'Malaysian youth mental health platform built for students. Local resources, local context.',
      btnText: 'Find Resources',
      color: const Color(0xFF5B5BD6),
      url: 'https://www.mindkami.com/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=400&q=80',
    ),
    Resource(
      title: 'BetterHelp',
      desc:
          'Match with a licensed therapist online in 48 hours. Proper professional support when you need more than a hotline.',
      btnText: 'Get Matched',
      color: const Color(0xFF214F6E),
      url: 'https://www.betterhelp.com/',
      type: ResourceType.paid,
      coverImageUrl:
          'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?w=400&q=80',
    ),
  ],

  'Financial Anxiety': [
    Resource(
      title: 'I Will Teach You To Be Rich',
      desc:
          "Ramit Sethi's no-BS personal finance book for young people. Practical, funny, Malaysian-applicable. Gets you from broke to intentional.",
      btnText: 'View on Goodreads',
      color: Colors.green,
      url:
          'https://www.goodreads.com/book/show/40591670-i-will-teach-you-to-be-rich',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=400&q=80',
    ),
    Resource(
      title: 'Budget Tracker Template',
      desc:
          'Free pre-made Google Sheets budget for Malaysian students. Track ringgit in and out, see exactly where it goes.',
      btnText: 'Get Template',
      color: Colors.teal,
      url:
          'https://docs.google.com/spreadsheets/d/1pCg1amE8tvTTl9WKBS8RDYXBP1y7MPCqvQPNE5XxrJM/copy',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&q=80',
    ),
    Resource(
      title: 'GXBank Malaysia',
      desc:
          'Digital bank with no minimum balance, no fees, and high savings interest. Open in minutes from your phone.',
      btnText: 'Open Account',
      color: Colors.lightGreen,
      url: 'https://www.gxbank.com.my/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400&q=80',
    ),
  ],

  'Friendship Drama': [
    Resource(
      title: 'Platonic',
      desc:
          "Marisa G. Franco's science-backed guide to making and keeping real adult friendships. The book nobody told you existed.",
      btnText: 'View on Goodreads',
      color: Colors.purpleAccent,
      url: 'https://www.goodreads.com/book/show/58782741-platonic',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400&q=80',
    ),
    Resource(
      title: 'Bumble BFF',
      desc:
          "If your friend group isn't working, build a new one. Meet real friends in your city — zero pressure.",
      btnText: 'Try Bumble BFF',
      color: const Color(0xFFFFD000),
      url: 'https://bumble.com/bff',
      type: ResourceType.app,
      coverImageUrl:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=400&q=80',
    ),
    Resource(
      title: 'BetterHelp',
      desc:
          'Talking to a therapist about relationship patterns is one of the most underrated things you can do. Available online, your schedule.',
      btnText: 'Try BetterHelp',
      color: const Color(0xFF214F6E),
      url: 'https://www.betterhelp.com/',
      type: ResourceType.paid,
      coverImageUrl:
          'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?w=400&q=80',
    ),
  ],

  'Family Issues': [
    Resource(
      title: 'Adult Children of Emotionally Immature Parents',
      desc:
          "Lindsay Gibson's transformative book on healing from parents who couldn't meet your emotional needs. For anyone who grew up feeling invisible at home.",
      btnText: 'View on Goodreads',
      color: Colors.deepOrange,
      url:
          'https://www.goodreads.com/book/show/23129659-adult-children-of-emotionally-immature-parents',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1536640712-4d4c36ff0e4e?w=400&q=80',
    ),
    Resource(
      title: 'MIASA Malaysia',
      desc:
          'Local Malaysian counseling and mental health awareness support. People who understand our cultural context.',
      btnText: 'Get Local Help',
      color: Colors.teal,
      url: 'https://miasa.org.my/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1527137342181-19aab11a8ee8?w=400&q=80',
    ),
    Resource(
      title: 'BetterHelp',
      desc:
          'Family issues are some of the hardest to unpack alone. Match with a licensed therapist online in 48 hours.',
      btnText: 'Get Matched',
      color: const Color(0xFF214F6E),
      url: 'https://www.betterhelp.com/',
      type: ResourceType.paid,
      coverImageUrl:
          'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?w=400&q=80',
    ),
  ],

  'Social Media Trap': [
    Resource(
      title: 'Digital Minimalism',
      desc:
          "Cal Newport explains why social media is designed to hijack your attention — and how to reclaim your life without quitting entirely.",
      btnText: 'View on Goodreads',
      color: Colors.blueGrey,
      url: 'https://www.goodreads.com/book/show/40672036-digital-minimalism',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=400&q=80',
    ),
    Resource(
      title: 'One Sec App',
      desc:
          'Forces a 1-second pause before you open Instagram or TikTok. That one second breaks the reflex. Used by 400k+ people.',
      btnText: 'Get the App',
      color: Colors.indigoAccent,
      url: 'https://one-sec.app/',
      type: ResourceType.app,
      coverImageUrl:
          'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&q=80',
    ),
    Resource(
      title: 'The Social Dilemma (Netflix)',
      desc:
          "The documentary that made Silicon Valley insiders speak out. Watch it and you'll never look at your feed the same way.",
      btnText: 'Watch on Netflix',
      color: Colors.red,
      url: 'https://www.netflix.com/title/81254224',
      type: ResourceType.video,
      coverImageUrl:
          'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=400&q=80',
    ),
  ],

  'Phone Addiction': [
    Resource(
      title: 'Forest App',
      desc:
          'Plant a virtual tree. Every time you pick up your phone it dies. 1M+ people have grown a forest by staying focused.',
      btnText: 'Plant a Tree',
      color: Colors.green,
      url: 'https://www.forestapp.cc/',
      type: ResourceType.app,
      coverImageUrl:
          'https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&q=80',
    ),
    Resource(
      title: 'How to Break Up with Your Phone',
      desc:
          "Catherine Price's practical 30-day plan to stop compulsive scrolling. Not about quitting — about using your phone on your terms.",
      btnText: 'View on Goodreads',
      color: const Color(0xFF8D6E63),
      url:
          'https://www.goodreads.com/book/show/35289387-how-to-break-up-with-your-phone',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=400&q=80',
    ),
    Resource(
      title: 'Primitive Technology (YouTube)',
      desc:
          'The most calming, screen-free hobby content on the internet. Replace doom-scrolling with something that actually fascinates you.',
      btnText: 'Watch Channel',
      color: Colors.lightGreen,
      url: 'https://www.youtube.com/@primitivetechnology9550',
      type: ResourceType.video,
      coverImageUrl:
          'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=400&q=80',
    ),
  ],

  'Procrastination': [
    Resource(
      title: 'Focusmate',
      desc:
          'Book a 50-min session with a real human and work side by side over video. Body-doubling is the most underrated procrastination hack.',
      btnText: 'Book Session',
      color: Colors.orange,
      url: 'https://www.focusmate.com/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&q=80',
    ),
    Resource(
      title: 'Goblin Tools',
      desc:
          'AI that breaks down your overwhelming tasks into tiny, specific, non-scary steps. Free. Life-changing for ADHD brains.',
      btnText: 'Try It Free',
      color: Colors.green,
      url: 'https://goblin.tools/',
      type: ResourceType.app,
      coverImageUrl:
          'https://images.unsplash.com/photo-1512758017271-d7b84c2113f1?w=400&q=80',
    ),
    Resource(
      title: 'Eat That Frog',
      desc:
          "Brian Tracy's classic 21 productivity principles. The frog is your worst task — and you learn to eat it first. Short, actionable, and actually works.",
      btnText: 'View on Goodreads',
      color: Colors.deepOrange,
      url: 'https://www.goodreads.com/book/show/95887.Eat_That_Frog_',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400&q=80',
    ),
  ],

  'Sleep Struggles': [
    Resource(
      title: 'Rain & Thunder ASMR (YouTube)',
      desc:
          '8 hours of heavy rain sounds — the most streamed sleep aid on YouTube. No commentary, no ads mid-sleep, just rain.',
      btnText: 'Listen Now',
      color: Colors.indigo,
      url: 'https://www.youtube.com/watch?v=q76bMs-NwRk',
      type: ResourceType.video,
      coverImageUrl:
          'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=400&q=80',
    ),
    Resource(
      title: 'Why We Sleep',
      desc:
          "Matthew Walker's paradigm-shifting science of sleep. After this book you will actually want to sleep 8 hours.",
      btnText: 'View on Goodreads',
      color: Colors.deepPurple,
      url: 'https://www.goodreads.com/book/show/34466963-why-we-sleep',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=400&q=80',
    ),
    Resource(
      title: 'Sleep Cycle App',
      desc:
          'Tracks your sleep phases using your phone mic and wakes you at the lightest moment so you feel human, not destroyed.',
      btnText: 'Get the App',
      color: Colors.purpleAccent,
      url: 'https://www.sleepcycle.com/',
      type: ResourceType.app,
      coverImageUrl:
          'https://images.unsplash.com/photo-1506792006437-256b665541e2?w=400&q=80',
    ),
  ],

  'Body Insecurity': [
    Resource(
      title: 'Anytime Fitness — Free 3-Day Pass',
      desc:
          'Try any Anytime Fitness gym in Malaysia free for 3 days. Movement changes how you feel about your body faster than anything else.',
      btnText: 'Claim Free Trial',
      color: Colors.purpleAccent,
      url: 'https://www.anytimefitness.my/try-us-free/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&q=80',
    ),
    Resource(
      title: 'More Than a Body',
      desc:
          "Lindsay and Lexie Kite's groundbreaking book on body image resilience. Changes how you see yourself from the inside out.",
      btnText: 'View on Goodreads',
      color: Colors.pink,
      url: 'https://www.goodreads.com/book/show/51858258-more-than-a-body',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80',
    ),
    Resource(
      title: 'Blogilates (YouTube)',
      desc:
          "Cassey Ho's body-positive Pilates workouts. Free forever, all levels, no shame. Millions of students use this to feel better.",
      btnText: 'Watch Channel',
      color: Colors.pinkAccent,
      url: 'https://www.youtube.com/@blogilates',
      type: ResourceType.video,
      coverImageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&q=80',
    ),
  ],

  'Future Doubts': [
    Resource(
      title: 'Ikigai Career Test',
      desc:
          'Find where passion, skill, and purpose overlap. The Japanese concept that helps you figure out what you should actually be doing.',
      btnText: 'Take the Test',
      color: Colors.amber,
      url: 'https://ikigaitest.com/',
      type: ResourceType.test,
      coverImageUrl:
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400&q=80',
    ),
    Resource(
      title: 'Designing Your Life',
      desc:
          "Stanford professors Bill Burnett and Dave Evans teach you to prototype your life like a designer. The bestselling antidote to 'what do I do with my life.'",
      btnText: 'View on Goodreads',
      color: Colors.orange,
      url: 'https://www.goodreads.com/book/show/26046333-designing-your-life',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1501290741922-b56c0d0884af?w=400&q=80',
    ),
    Resource(
      title: 'Woebot',
      desc:
          'CBT-based AI emotional support chatbot. Free. No waitlist. Helps you reframe the catastrophising about your future.',
      btnText: 'Try Woebot',
      color: const Color(0xFF00AAFF),
      url: 'https://woebothealth.com/',
      type: ResourceType.app,
      coverImageUrl:
          'https://images.unsplash.com/photo-1531746790731-6c087fecd65a?w=400&q=80',
    ),
  ],

  'Trauma': [
    Resource(
      title: 'The Body Keeps the Score',
      desc:
          "Bessel van der Kolk's landmark book on how trauma lives in your body — and the therapies that actually free you from it.",
      btnText: 'View on Goodreads',
      color: Colors.deepPurple,
      url:
          'https://www.goodreads.com/book/show/18693771-the-body-keeps-the-score',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1474631245212-32dc3c8310c6?w=400&q=80',
    ),
    Resource(
      title: '7 Cups',
      desc:
          'Free online chat with trained volunteer listeners. Anonymous. No appointment needed. Available right now.',
      btnText: 'Talk Now',
      color: const Color(0xFF00C8A0),
      url: 'https://www.7cups.com/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400&q=80',
    ),
    Resource(
      title: 'BetterHelp',
      desc:
          'Trauma requires a professional. Match with a licensed therapist who specialises in trauma, online, in 48 hours.',
      btnText: 'Get Matched',
      color: const Color(0xFF214F6E),
      url: 'https://www.betterhelp.com/',
      type: ResourceType.paid,
      coverImageUrl:
          'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?w=400&q=80',
    ),
  ],

  'No One To Talk To': [
    Resource(
      title: '7 Cups',
      desc:
          'Free chat with trained listeners. Anonymous. Available right now. No sign-up required.',
      btnText: 'Talk Now',
      color: const Color(0xFF00C8A0),
      url: 'https://www.7cups.com/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400&q=80',
    ),
    Resource(
      title: 'Befrienders Malaysia',
      desc:
          "Free 24/7 hotline. Just to be heard. You don't need a reason. You don't need to be 'bad enough.'",
      btnText: 'Call Now',
      color: Colors.red,
      url: 'https://www.befrienders.org.my/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1516387938699-a93567ec168e?w=400&q=80',
    ),
    Resource(
      title: 'Woebot',
      desc:
          "AI-powered emotional support, CBT-based, free. It's not a replacement for humans but it's there at 2am when humans aren't.",
      btnText: 'Try Woebot',
      color: const Color(0xFF00AAFF),
      url: 'https://woebothealth.com/',
      type: ResourceType.app,
      coverImageUrl:
          'https://images.unsplash.com/photo-1531746790731-6c087fecd65a?w=400&q=80',
    ),
  ],

  'Identity & Self-Worth': [
    Resource(
      title: 'The Gifts of Imperfection',
      desc:
          "Brene Brown's guide to letting go of who you think you should be and embracing who you actually are.",
      btnText: 'View on Goodreads',
      color: Colors.limeAccent,
      url:
          'https://www.goodreads.com/book/show/6616214-the-gifts-of-imperfection',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=400&q=80',
    ),
    Resource(
      title: 'Values in Action (VIA) Test',
      desc:
          'Free psychology-backed test from the University of Pennsylvania. Discover your core character strengths — what makes you, you.',
      btnText: 'Take Free Test',
      color: Colors.amber,
      url: 'https://www.viacharacter.org/survey/account/register',
      type: ResourceType.test,
      coverImageUrl:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400&q=80',
    ),
    Resource(
      title: 'BetterHelp',
      desc:
          'Identity and self-worth questions are deep. A therapist can help you work through them safely.',
      btnText: 'Get Matched',
      color: const Color(0xFF214F6E),
      url: 'https://www.betterhelp.com/',
      type: ResourceType.paid,
      coverImageUrl:
          'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?w=400&q=80',
    ),
  ],

  'Relationships': [
    Resource(
      title: 'Attachment Style Quiz',
      desc:
          "Free quiz: discover if you're anxious, avoidant, or secure — and finally understand why you act the way you do in relationships.",
      btnText: 'Take Quiz',
      color: const Color(0xFFFF4D7D),
      url: 'https://www.attachmentproject.com/attachment-style-quiz/',
      type: ResourceType.test,
      coverImageUrl:
          'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=400&q=80',
    ),
    Resource(
      title: 'Attached',
      desc:
          'Amir Levine and Rachel Heller explain the science of adult attachment. The book that explains why love is so hard.',
      btnText: 'View on Goodreads',
      color: Colors.pink,
      url: 'https://www.goodreads.com/book/show/9547888-attached',
      type: ResourceType.book,
      coverImageUrl:
          'https://images.unsplash.com/photo-1474552226712-ac0f0961a954?w=400&q=80',
    ),
    Resource(
      title: 'BetterHelp',
      desc:
          'Work through your relationship patterns with a licensed therapist. Available online, matched in 48 hours.',
      btnText: 'Get Matched',
      color: const Color(0xFF214F6E),
      url: 'https://www.betterhelp.com/',
      type: ResourceType.paid,
      coverImageUrl:
          'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?w=400&q=80',
    ),
  ],

  'Feeling Unattractive': [
    Resource(
      title: 'Anytime Fitness — Free 3-Day Pass',
      desc:
          'Movement changes how you feel about yourself faster than anything else. Try any Malaysian branch free for 3 days.',
      btnText: 'Claim Free Trial',
      color: Colors.purpleAccent,
      url: 'https://www.anytimefitness.my/try-us-free/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&q=80',
    ),
    Resource(
      title: 'Glow Up (Netflix)',
      desc:
          'Make-up artists compete to transform themselves. Genuinely uplifting — a reminder that style is an art form, not a standard.',
      btnText: 'Watch on Netflix',
      color: Colors.pinkAccent,
      url: 'https://www.netflix.com/title/80217499',
      type: ResourceType.video,
      coverImageUrl:
          'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400&q=80',
    ),
    Resource(
      title: '7 Cups',
      desc:
          'Talk through confidence and self-image struggles with a trained listener. Anonymous, free, and judgment-free.',
      btnText: 'Talk Now',
      color: const Color(0xFF00C8A0),
      url: 'https://www.7cups.com/',
      type: ResourceType.link,
      coverImageUrl:
          'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400&q=80',
    ),
  ],
};

List<Resource> get _defaultResources => [
  Resource(
    title: 'Headspace',
    desc:
        'Learn to meditate and live more mindfully. Guided sessions for any mood.',
    btnText: 'Try Headspace',
    color: const Color(0xFFF47D31),
    url: 'https://www.headspace.com/',
    type: ResourceType.app,
    coverImageUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
  ),
  Resource(
    title: '7 Cups',
    desc: 'Free chat with trained listeners. Anonymous. Available now.',
    btnText: 'Talk Now',
    color: const Color(0xFF00C8A0),
    url: 'https://www.7cups.com/',
    type: ResourceType.link,
    coverImageUrl:
        'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400&q=80',
  ),
  Resource(
    title: 'BetterHelp',
    desc: 'Connect with a licensed therapist online, on your schedule.',
    btnText: 'Try BetterHelp',
    color: const Color(0xFF214F6E),
    url: 'https://www.betterhelp.com/',
    type: ResourceType.paid,
    coverImageUrl:
        'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?w=400&q=80',
  ),
];

// ── FEED SCREEN ───────────────────────────────────────────────────────────
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
  String _searchQuery = '';

  // FIX 4: Store the real avatarIndex loaded from Firestore
  int _myAvatarIndex = 0;

  @override
  void initState() {
    super.initState();
    _catIdx = widget.initialCategoryIndex;
    _loadMyAvatarIndex(); // FIX 4: load from Firestore instead of deriving from UID hash
    if (!_moodModalShownThisSession) {
      _moodModalShownThisSession = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showMoodModal(context),
      );
    }
  }

  // FIX 4: Fetch the real avatarIndex the user chose at registration
  Future<void> _loadMyAvatarIndex() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final idx = data['avatarIndex'];
        if (idx != null && mounted) {
          setState(() => _myAvatarIndex = (idx as int).clamp(0, 14));
        }
      }
    } catch (e) {
      debugPrint('Avatar index fetch failed: $e');
    }
  }

  @override
  void didUpdateWidget(covariant FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategoryIndex != widget.initialCategoryIndex) {
      setState(() => _catIdx = widget.initialCategoryIndex);
    }
  }

  void _showMoodModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "How is your mood today?",
              style: TextStyle(
                color: _textTitle,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodOption(context, "😢", "Terrible"),
                _buildMoodOption(context, "😟", "Bad"),
                _buildMoodOption(context, "😐", "Neutral"),
                _buildMoodOption(context, "🙂", "Good"),
                _buildMoodOption(context, "😄", "Great"),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // FIX 3: Mood snackbar — white text on a solid dark background for visibility
  Widget _buildMoodOption(BuildContext context, String emoji, String label) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  "Mood logged: $label",
                  // FIX 3: explicit white so it's readable on the dark card bg
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            // FIX 3: use a slightly lighter shade than _card so the snackbar
            // has clear contrast against both the bar background and text
            backgroundColor: const Color(0xFF243640),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _accent.withOpacity(0.5), width: 1),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: _textSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Post> get _filtered {
    var list = _posts;
    if (_catIdx != 0)
      list = list.where((p) => p.category == _categories[_catIdx]).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (p) =>
                p.title.toLowerCase().contains(q) ||
                p.body.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  List<Post> get _relatedPosts {
    if (_catIdx == 0) return [];
    final currentCat = _categories[_catIdx];
    final others = _posts.where((p) => p.category != currentCat).toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    return others.take(3).toList();
  }

  Color _colorForCategory(String cat) {
    switch (cat) {
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

  Future<void> _launch(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint('Could not launch $url');
    }
  }

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
                                  setModalState(() => isClassifying = true);
                                  String detectedCategory = 'Loneliness';
                                  bool isSafePost = true;
                                  try {
                                    final combinedText =
                                        "TITLE: ${titleController.text}\nBODY: ${bodyController.text}";
                                    final aiResult =
                                        await HelanceAIService.analyzePost(
                                          combinedText,
                                        );
                                    if (aiResult['isSafe'] == false) {
                                      isSafePost = false;
                                    } else {
                                      detectedCategory =
                                          aiResult['category'] as String;
                                      if (!_categories.contains(
                                        detectedCategory,
                                      ))
                                        detectedCategory = 'Overthinking';
                                      UserActivityTracker.addPost(combinedText);
                                    }
                                  } catch (e) {
                                    debugPrint("AI Classification failed: $e");
                                  }

                                  if (!isSafePost) {
                                    setModalState(() => isClassifying = false);
                                    Navigator.pop(context);
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: _card,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          title: const Row(
                                            children: [
                                              Icon(
                                                Icons.shield_rounded,
                                                color: Colors.redAccent,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Safety Alert',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: const Text(
                                            "We hear you, and you are not alone. Your safety is incredibly important. Please reach out to someone who can help right now.",
                                            style: TextStyle(
                                              color: _textTitle,
                                              height: 1.5,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text(
                                                "Go Back",
                                                style: TextStyle(
                                                  color: _textSub,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () async {
                                                const url =
                                                    'https://www.befrienders.org.my/';
                                                if (!await launchUrl(
                                                  Uri.parse(url),
                                                ))
                                                  debugPrint(
                                                    'Could not launch $url',
                                                  );
                                              },
                                              icon: const Icon(
                                                Icons.phone,
                                                size: 16,
                                              ),
                                              label: const Text(
                                                "Talk to Befrienders",
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  String anonName =
                                      'anon_striver_${DateTime.now().millisecondsSinceEpoch % 1000}';
                                  int anonAvatarIdx =
                                      _myAvatarIndex; // FIX 4: use real avatar
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
                                          // FIX 4: read stored avatarIndex, fall back to _myAvatarIndex
                                          anonAvatarIdx =
                                              (data['avatarIndex'] as int?) ??
                                              _myAvatarIndex;
                                        }
                                      }
                                    } catch (e) {
                                      debugPrint("Profile fetch error: $e");
                                    }
                                  }

                                  if (!context.mounted) return;
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
                                        _colorForCategory(detectedCategory),
                                        anonAvatarIdx,
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Colors.green.shade700,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill out both the title and body.',
                                        style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
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
                            hintText: "Search Héalance...",
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
                      const SizedBox(height: 8),
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
                        return Column(
                          children: [
                            RichPostCard(
                              post: post,
                              upvoted: _upvoted.contains(globalIdx),
                              downvoted: _downvoted.contains(globalIdx),
                              onUpvote: () => setState(() {
                                _upvoted.contains(globalIdx)
                                    ? _upvoted.remove(globalIdx)
                                    : {
                                        _upvoted.add(globalIdx),
                                        _downvoted.remove(globalIdx),
                                      };
                              }),
                              onDownvote: () => setState(() {
                                _downvoted.contains(globalIdx)
                                    ? _downvoted.remove(globalIdx)
                                    : {
                                        _downvoted.add(globalIdx),
                                        _upvoted.remove(globalIdx),
                                      };
                              }),
                            ),
                            if (i == 2 && _relatedPosts.isNotEmpty)
                              _buildRelatedSection(),
                          ],
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
            itemBuilder: (_, i) => _TrendingCard(
              post: trendingList[i],
              rank: i + 1,
              onTap: () {
                final newIdx = _categories.indexOf(trendingList[i].category);
                if (newIdx != -1) setState(() => _catIdx = newIdx);
              },
            ),
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
              // FIX 4: uses _myAvatarIndex loaded from Firestore
              _AvatarWidget(index: _myAvatarIndex, radius: 16),
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

  Widget _buildRelatedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.hub_rounded,
                  color: Colors.tealAccent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  'You might also relate to',
                  style: TextStyle(
                    color: _textTitle,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  'from other spaces',
                  style: TextStyle(color: _textSub, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.tealAccent.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.tealAccent.withOpacity(0.03),
            ),
            child: Column(
              children: _relatedPosts.asMap().entries.map((e) {
                final post = e.value;
                final isLast = e.key == _relatedPosts.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _AvatarWidget(index: post.avatarIndex, radius: 14),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _textTitle,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: post.tagColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    post.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: post.tagColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_upward_rounded,
                                size: 12,
                                color: _textSub,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${post.points}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _textSub,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) Divider(height: 1, color: _border),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _buildSidePanel() {
    final cat = _categories[_catIdx];
    final resources = _sidebarResources[cat] ?? _defaultResources;
    final catColor = _colorForCategory(cat == 'All' ? 'Loneliness' : cat);

    final widgets = <Widget>[
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: catColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: catColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.recommend_rounded, size: 14, color: _textSub),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                cat == 'All' ? 'Resources for You' : 'Resources for $cat',
                style: const TextStyle(
                  color: _textSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ];

    for (int i = 0; i < resources.length; i++) {
      widgets.add(_buildRichResourceCard(resources[i]));
      if (i < resources.length - 1) widgets.add(const SizedBox(height: 16));
    }
    return widgets;
  }

  Widget _buildRichResourceCard(Resource r) {
    return Card(
      elevation: 0,
      color: _card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 110,
                width: double.infinity,
                child: Image.network(
                  r.coverImageUrl,
                  fit: BoxFit.cover,
                  // FIX 1: richer fallback — colored gradient + icon so it
                  // never looks broken/empty even if the URL fails
                  errorBuilder: (_, __, ___) => Container(
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          r.color.withOpacity(0.25),
                          r.color.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _iconForType(r.type),
                            color: r.color.withOpacity(0.7),
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            r.title,
                            style: TextStyle(
                              color: r.color.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _typeBadgeColor(r.type).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _typeLabel(r.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: r.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  r.desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textTitle,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _launch(r.url),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: r.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      r.btnText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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

  // FIX 1: returns a meaningful icon per resource type for the fallback UI
  IconData _iconForType(ResourceType t) {
    switch (t) {
      case ResourceType.book:
        return Icons.menu_book_rounded;
      case ResourceType.video:
        return Icons.play_circle_fill_rounded;
      case ResourceType.test:
        return Icons.quiz_rounded;
      case ResourceType.paid:
        return Icons.support_agent_rounded;
      case ResourceType.app:
        return Icons.phone_android_rounded;
      case ResourceType.link:
        return Icons.language_rounded;
    }
  }
}

// ── TRENDING CARD ─────────────────────────────────────────────────────────
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
                : rank == 2
                ? Colors.grey.withOpacity(0.4)
                : Colors.brown.withOpacity(0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  rank == 1
                      ? '🥇'
                      : rank == 2
                      ? '🥈'
                      : '🥉',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: post.tagColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.category,
                      style: TextStyle(
                        fontSize: 9,
                        color: post.tagColor,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward_rounded,
                      size: 11,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${post.points}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textTitle,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                _AvatarWidget(index: post.avatarIndex, radius: 8),
                const SizedBox(width: 6),
                Text(
                  'u/${post.user}',
                  style: const TextStyle(fontSize: 10, color: _textSub),
                ),
                const Spacer(),
                Text(
                  post.time,
                  style: const TextStyle(fontSize: 10, color: _textSub),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── CATEGORY BAR ──────────────────────────────────────────────────────────
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
        itemBuilder: (_, i) {
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

// ── POST CARD ─────────────────────────────────────────────────────────────
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
                        const SnackBar(
                          content: Text(
                            'Comment posted!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color(0xFF243640),
                        ),
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
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF37474F),
            child: Icon(Icons.person, size: 14, color: Colors.white70),
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
    final displayPoints = post.points + (upvoted ? 1 : 0) - (downvoted ? 1 : 0);
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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
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
                  Row(
                    children: [
                      _AvatarWidget(index: post.avatarIndex, radius: 10),
                      const SizedBox(width: 8),
                      Text(
                        'u/${post.user} • ${post.time}',
                        style: const TextStyle(fontSize: 12, color: _textSub),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: post.tagColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          post.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: post.tagColor,
                          ),
                        ),
                      ),
                      if (post.aiSupported) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
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
                          padding: const EdgeInsets.all(4),
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
                          padding: EdgeInsets.all(4),
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
