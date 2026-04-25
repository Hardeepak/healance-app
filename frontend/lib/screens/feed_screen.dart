import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/ai_service.dart';

const _accent = Color(0xFFFF5414);
const _bg = Color(0xFF0B1416);
const _card = Color(0xFF1A2A30);
const _border = Color(0xFF2B3C42);
const _textTitle = Color(0xFFD7DADC);
const _textSub = Color(0xFF8B9DA4);

// Each post has its own unique Pravatar seed so no two look the same.
// Seeds chosen to get a diverse mix of real-looking faces.
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

// Each post gets a UNIQUE avatar index — never repeated consecutively.
// We deliberately skip even/odd patterns so it looks organic.
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

// Post bodies are now varied in length — some are one-liners, some are
// multi-sentence. This mirrors how real forums look: different people,
// different writing styles, different amounts of detail they feel comfortable sharing.
final List<Post> _posts = [
  // ── LONELINESS ──────────────────────────────────────────────────────────
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
    "Too scared to sit in the cafeteria alone. People look at you like something's wrong with you. I've been doing this for three weeks. I bring a packed lunch and eat it on the toilet. I know how that sounds.",
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
    "I just stood there, waited, then walked away. I don't think I exist to them. This has happened more than once — I'll say something in a group conversation and it just gets completely ignored. Like the words evaporated. I've started wondering if I'm fundamentally forgettable.",
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
    'Loneliness',
    'new_city_blue',
    '4h',
    "Moved to KL for uni. 6 months in. Zero real friends.",
    "I smile at people in tutorials. They smile back. We have never spoken again. I've tried joining clubs, sitting near different people, even saying yes to study groups. Nothing sticks. I go home every weekend and pretend I'm having the time of my life.",
    540,
    98,
    true,
    Colors.blueGrey,
    _av(6),
  ),
  Post(
    'Loneliness',
    'wallflower99',
    '8h',
    "Being the quiet one means people forget you're even there.",
    "They make plans around me, in front of me. I'm never included. I've stopped expecting to be.",
    430,
    87,
    false,
    Colors.blueGrey,
    _av(7),
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
    _av(8),
  ),

  // ── OVERTHINKING ──────────────────────────────────────────────────────
  Post(
    'Overthinking',
    'brain_buzz',
    '5h',
    "Replaying a conversation from 3 years ago.",
    "Why did I say that? They definitely still think about it. My brain won't let it go. I was 17. It was a throwaway comment at a party. I'm 20 now and it still hits me at 2am.",
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
    'text_analyzer',
    '3h',
    'They replied with "ok." instead of "ok!" and I\'ve been analysing it for 4 hours.',
    "The full stop. THE FULL STOP.",
    210,
    80,
    false,
    Colors.tealAccent,
    _av(11),
  ),
  Post(
    'Overthinking',
    'decision_loop',
    '6h',
    "I can't choose a lunch option without a 20-minute internal debate.",
    "Every small decision feels enormous. I'm completely drained by 9am from just existing. I don't know when this started. I used to be decisive. Now choosing between the nasi lemak stall and the economy rice counter feels like a crisis.",
    388,
    91,
    true,
    Colors.tealAccent,
    _av(12),
  ),
  Post(
    'Overthinking',
    'email_regret',
    '2h',
    "Sent an email to my lecturer and I've regretted every word since.",
    "Was the tone too casual? Too formal? Did I sign off correctly?",
    460,
    103,
    false,
    Colors.tealAccent,
    _av(13),
  ),
  Post(
    'Overthinking',
    'future_fear',
    '7h',
    "My brain runs worst-case scenarios 24/7 like it's a full-time job.",
    "I know logically none of it is likely. I cannot stop the mental projections.",
    710,
    180,
    true,
    Colors.tealAccent,
    _av(14),
  ),
  Post(
    'Overthinking',
    'apology_spiral',
    '4h',
    "I apologised so many times they got annoyed at me for over-apologising.",
    "And then I spent the rest of the day apologising in my head for over-apologising. Send help.",
    830,
    200,
    true,
    Colors.tealAccent,
    _av(15),
  ),

  // ── BULLYING ──────────────────────────────────────────────────────────
  Post(
    'Bullying',
    'silent_cry',
    '12h',
    "Someone made a meme about me in the uni WhatsApp group.",
    "200 people laughing. I don't want to go to class tomorrow. Or ever. I screenshotted it and I keep opening it, which I know is the worst thing to do. But I can't stop. Like I'm trying to understand what I did wrong.",
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
    "They know specific things only people in my course would know. I feel unsafe on campus now. I've reported it to the faculty but they said they can't do anything without knowing who it is. I haven't slept properly in a week.",
    880,
    250,
    true,
    Colors.red,
    _av(18),
  ),
  Post(
    'Bullying',
    'class_sport',
    '9h',
    "They treat humiliating me as a group sport every session.",
    "Someone always has a new joke at my expense. I laugh along but I am dying inside.",
    730,
    167,
    true,
    Colors.red,
    _av(19),
  ),
  Post(
    'Bullying',
    'excluded_setup',
    '4h',
    "They exclude me from group projects then complain I do nothing.",
    "They set me up to fail and use it as ammunition.",
    520,
    142,
    false,
    Colors.red,
    _av(20),
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
    _av(21),
  ),

  // ── ACADEMIC BURNOUT ──────────────────────────────────────────────────
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
    "I studied so hard this semester. I feel like a massive disappointment to everyone, including myself. My parents don't know yet. I've been pretending everything is fine on our weekly calls.",
    820,
    140,
    true,
    Colors.redAccent,
    _av(23),
  ),
  Post(
    'Academic Burnout',
    'dead_inside_42',
    '5h',
    "Finished my assignment and felt absolutely nothing.",
    "No relief. No pride. Just empty.",
    670,
    122,
    true,
    Colors.redAccent,
    _av(24),
  ),
  Post(
    'Academic Burnout',
    'slept_through',
    '2d',
    "I slept through my alarm during finals week.",
    "Not because I didn't try. I just had nothing left. My body gave out on me.",
    440,
    95,
    false,
    Colors.redAccent,
    _av(25),
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
    _av(26),
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
    _av(27),
  ),
  Post(
    'Academic Burnout',
    'drop_out_thought',
    '8h',
    "I've thought about dropping out every single day this semester.",
    "I won't. I can't. But the thought keeps coming back like it's offering something. It feels like a door I know I can't open. But I keep looking at it. Every morning before I've even checked my phone — it's there.",
    1100,
    310,
    true,
    Colors.redAccent,
    _av(28),
  ),

  // ── FRIENDSHIP DRAMA ──────────────────────────────────────────────────
  Post(
    'Friendship Drama',
    'ghosted_again',
    '2h',
    "My friend group made a separate chat without me.",
    "I saw the notifications on my roommate's phone. I pretended I didn't notice. I've been going over every interaction this semester trying to figure out what I did.",
    890,
    150,
    true,
    Colors.purpleAccent,
    _av(29),
  ),
  Post(
    'Friendship Drama',
    'one_sided_always',
    '8h',
    "I am always the one who initiates. Never them.",
    "What happens if I just stop? Day 4 of the experiment. Nobody has texted.",
    600,
    130,
    false,
    Colors.purpleAccent,
    _av(30),
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
    _av(31),
  ),
  Post(
    'Friendship Drama',
    'outgrown_fear',
    '3d',
    "I think I've outgrown my friend group and it terrifies me.",
    "We have nothing to talk about anymore. But I'm scared of the silence if I walk away.",
    380,
    88,
    false,
    Colors.purpleAccent,
    _av(32),
  ),
  Post(
    'Friendship Drama',
    'jealous_friend',
    '5h',
    "My friend gets competitive every time something good happens to me.",
    "I got an internship offer. Instead of congratulating me she listed why she deserved it more. I didn't even respond. I just stared at the message. We've been friends since Form 1.",
    710,
    155,
    true,
    Colors.purpleAccent,
    _av(33),
  ),
  Post(
    'Friendship Drama',
    'used_not_seen',
    '3h',
    "They only message me when they need something.",
    "Notes before exams. Lifts. Comfort at 1am. Silence every other day of the year.",
    830,
    195,
    true,
    Colors.purpleAccent,
    _av(34),
  ),

  // ── CAREER ANXIETY ────────────────────────────────────────────────────
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
    "Another classmate. Another dream job. I close the app and stare at the ceiling. I've muted 12 people now. But they keep appearing in 'People You May Know' and I click on them anyway. I don't know why I do it.",
    880,
    201,
    true,
    Colors.indigoAccent,
    _av(36),
  ),
  Post(
    'Career Anxiety',
    'degree_doubt',
    '1d',
    "Did I pick the wrong degree? I'm 3 years in and terrified.",
    "I don't enjoy any of this. But I can't start over.",
    750,
    180,
    true,
    Colors.indigoAccent,
    _av(37),
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
    _av(38),
  ),
  Post(
    'Career Anxiety',
    'imposter_hired',
    '3h',
    "I got hired but spend every day waiting to be found out.",
    "I smile and nod in meetings. Half the time I have absolutely no idea what's happening. I've been googling the most basic things on the toilet just to keep up. Three months in and I still feel like I'm pretending.",
    540,
    118,
    true,
    Colors.indigoAccent,
    _av(39),
  ),
  Post(
    'Career Anxiety',
    'passion_missing',
    '9h',
    "Everyone says follow your passion. I genuinely don't have one.",
    "I've tried everything. Nothing feels like a calling. I just feel lost.",
    810,
    195,
    true,
    Colors.indigoAccent,
    _av(0),
  ),

  // ── FAMILY ISSUES ─────────────────────────────────────────────────────
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
    "Every B+ feels like I've betrayed years of their hard work. The weight is crushing. My dad drove Grab for two years to pay for my first semester. I think about that every time I want to give up.",
    920,
    240,
    true,
    Colors.deepOrange,
    _av(2),
  ),
  Post(
    'Family Issues',
    'middle_child_void',
    '6h',
    "I'm the middle child. I'm basically furniture.",
    "Older sibling is the success. Younger is the baby. I'm just there.",
    430,
    90,
    false,
    Colors.deepOrange,
    _av(3),
  ),
  Post(
    'Family Issues',
    'divorce_therapist',
    '2d',
    "My parents divorced last year. I became both their therapists.",
    "They each call me to vent about the other. I'm 20. I'm not equipped for this.",
    660,
    155,
    true,
    Colors.deepOrange,
    _av(4),
  ),
  Post(
    'Family Issues',
    'career_dictated',
    '4h',
    "My parents chose my degree. I hate every single day of it.",
    "Engineering was their dream, not mine. I don't know how to tell them I'm miserable.",
    580,
    130,
    true,
    Colors.deepOrange,
    _av(5),
  ),

  // ── DARK THOUGHTS ─────────────────────────────────────────────────────
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
    'Dark Thoughts',
    'numb_life',
    '8h',
    "I don't feel sad anymore. I just feel nothing. Is that worse?",
    "At least sadness means something is there. This emptiness genuinely terrifies me.",
    750,
    175,
    true,
    Colors.red,
    _av(8),
  ),

  // ── FINANCIAL ANXIETY ─────────────────────────────────────────────────
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
    'Financial Anxiety',
    'debt_spiral',
    '1d',
    "My credit card debt is keeping me up every night.",
    "Took it for textbooks. Snowballed fast. I'm scared to check the balance. I've been paying minimum for 5 months and it barely moves because of the interest. I'm trapped in a cycle I didn't understand when I signed up for it at 18.",
    770,
    165,
    true,
    Colors.green,
    _av(11),
  ),
  Post(
    'Financial Anxiety',
    'rich_friends_excuses',
    '6h',
    "All my friends eat out every weekend. I make excuses.",
    "Can't keep up financially. Too embarrassed to say that.",
    660,
    140,
    false,
    Colors.green,
    _av(12),
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
    _av(13),
  ),

  // ── BODY INSECURITY ───────────────────────────────────────────────────
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
    'Body Insecurity',
    'shrinking_self',
    '2h',
    "I barely eat and I'm starting to think that's fine.",
    "People compliment my body more now. That's messed up right? I know it is.",
    730,
    160,
    true,
    Colors.pinkAccent,
    _av(15),
  ),
  Post(
    'Body Insecurity',
    'acne_shame',
    '4h',
    "My skin makes me not want to leave my room on bad days.",
    "'Just drink water.' I've been drowning in it. It doesn't help.",
    510,
    112,
    false,
    Colors.pinkAccent,
    _av(16),
  ),
  Post(
    'Body Insecurity',
    'height_complex',
    '7h',
    "I'm 20 and 165cm. It affects everything and nobody talks about it.",
    "Dating, interviews, group photos. I feel at a constant disadvantage.",
    480,
    105,
    false,
    Colors.pinkAccent,
    _av(17),
  ),
  Post(
    'Body Insecurity',
    'clothes_wrong',
    '1d',
    "I stand in front of my wardrobe for 40 minutes and nothing feels right.",
    "I watch people throw on an outfit and look effortlessly fine. I don't get it.",
    360,
    82,
    true,
    Colors.pinkAccent,
    _av(18),
  ),

  // ── SOCIAL MEDIA TRAP ─────────────────────────────────────────────────
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
    'Social Media Trap',
    'tiktok_3am',
    '2h',
    "Said '5 more minutes' at 10pm. It's now 3am.",
    "I didn't even enjoy most of it. I just couldn't stop. Another night gone.",
    890,
    230,
    true,
    Colors.cyan,
    _av(20),
  ),
  Post(
    'Social Media Trap',
    'follower_pain',
    '6h',
    "My post got 3 likes. My classmate's got 847.",
    "It's just a number. I know that. I deleted the photo anyway.",
    570,
    127,
    false,
    Colors.cyan,
    _av(21),
  ),
  Post(
    'Social Media Trap',
    'fomo_glass',
    '1d',
    "I see everyone's trips and feel like I'm watching life through glass.",
    "FOMO now means feeling like my entire life is behind. Not just missing parties.",
    620,
    140,
    true,
    Colors.cyan,
    _av(22),
  ),
  Post(
    'Social Media Trap',
    'editing_face',
    '4h',
    "Spent 2 hours editing my face then deleted the post anyway.",
    "Who am I even trying to look like? That version of me doesn't exist.",
    800,
    195,
    true,
    Colors.cyan,
    _av(23),
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
    _av(24),
  ),

  // ── FUTURE DOUBTS ─────────────────────────────────────────────────────
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
    'Future Doubts',
    'no_roadmap',
    '5h',
    "Nobody handed me a life plan. I'm supposed to just figure it out?",
    "First gen student. No family templates. No guidance. Just anxiety and Google.",
    880,
    240,
    true,
    Colors.amber,
    _av(26),
  ),
  Post(
    'Future Doubts',
    'quarter_life',
    '3h',
    "I thought I'd feel like an adult by now.",
    "People at work talk about mortgages. I barely know how to properly cook rice.",
    740,
    170,
    false,
    Colors.amber,
    _av(27),
  ),
  Post(
    'Future Doubts',
    'purpose_empty',
    '7h',
    "What's the point of all this if I don't know what I want?",
    "Study, work, retire, die. There has to be more. I just can't see it from here.",
    810,
    200,
    true,
    Colors.amber,
    _av(28),
  ),
  Post(
    'Future Doubts',
    'dream_shifted',
    '2d',
    "I wanted to be an artist. I studied accounting instead.",
    "'Practical.' I know. But I grieve the version of me that chose differently.",
    630,
    145,
    true,
    Colors.amber,
    _av(29),
  ),
  Post(
    'Future Doubts',
    'adulthood_crash',
    '4h',
    "Adulting is suffering through systems nobody explained to you.",
    "Tax forms. Lease agreements. EPF contributions. Where was the class for this?",
    920,
    260,
    false,
    Colors.amber,
    _av(30),
  ),
  Post(
    'Future Doubts',
    'climate_dread',
    '6h',
    "I don't plan for the future because I'm not sure my generation has one.",
    "Climate, economy, AI replacing jobs. Why study for a world that might not exist? I know that's nihilistic. I know. But sometimes late at night it genuinely feels rational and that scares me more than anything.",
    1100,
    300,
    true,
    Colors.amber,
    _av(31),
  ),

  // ── TRAUMA ────────────────────────────────────────────────────────────
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
    'Trauma',
    'childhood_weight',
    '1d',
    "Things I witnessed as a child are rewiring how I act as an adult.",
    "I didn't know it was abuse until therapy. Now I'm unlearning everything.",
    940,
    255,
    true,
    Colors.deepPurple,
    _av(33),
  ),
  Post(
    'Trauma',
    'trust_broken',
    '3h',
    "I don't know how to trust people. Too many times burned.",
    "New friendships terrify me. I'm always waiting for them to show their real face.",
    560,
    124,
    false,
    Colors.deepPurple,
    _av(34),
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
    _av(35),
  ),
  Post(
    'Trauma',
    'flinch_response',
    '2h',
    "I flinch when people raise their voices. Even in normal conversations.",
    "I know they're not angry at me. My body doesn't know that. It never learned.",
    680,
    160,
    true,
    Colors.deepPurple,
    _av(36),
  ),

  // ── PHONE ADDICTION ───────────────────────────────────────────────────
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
    'Phone Addiction',
    'silence_panic',
    '2h',
    "I can't sit in silence anymore. It makes me panic.",
    "No music, no podcast, no scroll. Just quiet. It feels wrong. That scares me.",
    640,
    148,
    true,
    Colors.lightGreen,
    _av(38),
  ),
  Post(
    'Phone Addiction',
    'check_200',
    '7h',
    "I check my phone 200+ times a day. I actually timed it. 200.",
    "Nothing is ever there. But I keep checking. Like a reflex I cannot override.",
    830,
    200,
    false,
    Colors.lightGreen,
    _av(39),
  ),
  Post(
    'Phone Addiction',
    'scroll_not_sleep',
    '3h',
    "I tell myself I'll sleep at 11. I start scrolling. It's 3am again.",
    "I'm not even enjoying it. Just scrolling. Like I'm running from something.",
    720,
    163,
    true,
    Colors.lightGreen,
    _av(0),
  ),

  // ── PROCRASTINATION ───────────────────────────────────────────────────
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
    'Procrastination',
    'deadline_only',
    '5h',
    "I only function under extreme deadline pressure. That can't be healthy.",
    "All-nighters. Panic. Cortisol spike. Then it's over and I crash for a week. I've been doing this since secondary school and it's only getting worse. The stakes are higher now and the recovery takes longer.",
    750,
    180,
    false,
    Colors.orange,
    _av(2),
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
    _av(3),
  ),
  Post(
    'Procrastination',
    'shame_loop',
    '8h',
    "Procrastinate → guilt → too guilty to start → procrastinate more.",
    "I know the loop. I'm in it right now. Writing this instead of my assignment.",
    920,
    245,
    true,
    Colors.orange,
    _av(4),
  ),
  Post(
    'Procrastination',
    'executive_wall',
    '2d',
    "I've wanted to shower for 3 days. I cannot make myself do it.",
    "There's a wall between wanting to do something and doing it. Exhausting.",
    680,
    160,
    true,
    Colors.orange,
    _av(5),
  ),

  // ── FEELING UNATTRACTIVE ──────────────────────────────────────────────
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
    'Feeling Unattractive',
    'never_asked_out',
    '2h',
    "I genuinely believe nobody will ever find me attractive.",
    "Never been asked out. I'm in my 20s. I feel like I'm missing a fundamental experience that everyone else just gets to have automatically.",
    840,
    210,
    true,
    Colors.pink,
    _av(7),
  ),
  Post(
    'Feeling Unattractive',
    'camera_off',
    '4h',
    "I turn off my camera in every video call. I can't look at myself on screen.",
    "Other people look fine. I look wrong.",
    470,
    106,
    false,
    Colors.pink,
    _av(8),
  ),
  Post(
    'Feeling Unattractive',
    'wardrobe_dread',
    '1d',
    "Nothing feels right on my body. Every morning the same 40-minute battle.",
    "I watch people throw on an outfit and look effortlessly fine. I don't understand it.",
    360,
    82,
    true,
    Colors.pink,
    _av(9),
  ),

  // ── NO ONE TO TALK TO ─────────────────────────────────────────────────
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
    'No One To Talk To',
    'therapy_broke',
    '5h',
    "I can't afford therapy and free resources feel useless.",
    "RM200 a session. My entire week's food budget. I just need someone to actually listen.",
    900,
    240,
    true,
    Colors.teal,
    _av(11),
  ),
  Post(
    'No One To Talk To',
    'ceiling_talks',
    '3h',
    "I talk to the ceiling at 1am because there's literally nobody else.",
    "I've started narrating my feelings out loud just to make them feel real.",
    640,
    150,
    false,
    Colors.teal,
    _av(12),
  ),
  Post(
    'No One To Talk To',
    'listener_only',
    '7h',
    "I listen to everyone's problems. Nobody asks about mine.",
    "I'm the 'strong' one. People come to me. I am so tired of being strong.",
    870,
    220,
    true,
    Colors.teal,
    _av(13),
  ),
  Post(
    'No One To Talk To',
    'stranger_comfort',
    '2h',
    "I find it easier to talk to strangers online than people I know.",
    "No judgment. No history. No consequences. Is that sad? It genuinely helps.",
    560,
    130,
    false,
    Colors.teal,
    _av(14),
  ),

  // ── IDENTITY & SELF-WORTH ─────────────────────────────────────────────
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
    'Identity & Self-Worth',
    'people_pleaser',
    '2h',
    "I say yes to everything. I'm exhausted, resentful, and it's my own fault.",
    "I physically cannot say no. I smile, agree, then cry about it alone.",
    810,
    190,
    true,
    Colors.limeAccent,
    _av(16),
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
    _av(17),
  ),
  Post(
    'Identity & Self-Worth',
    'culture_clash',
    '1d',
    "Too Western for my family. Too Asian for friends abroad. I belong nowhere.",
    "Neither world fully accepts me. I float between them, never landing anywhere.",
    660,
    150,
    true,
    Colors.limeAccent,
    _av(18),
  ),

  // ── SLEEP STRUGGLES ───────────────────────────────────────────────────
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
    'Sleep Struggles',
    'cant_switch_off',
    '2h',
    "Body exhausted. Brain refuses to sleep. Every. Single. Night.",
    "Melatonin. White noise. No screens. Cold room. Nothing works.",
    780,
    188,
    true,
    Colors.indigoAccent,
    _av(20),
  ),
  Post(
    'Sleep Struggles',
    'oversleep_escape',
    '5h',
    "I sleep 12 hours and wake up more exhausted.",
    "People say sleep heals. Mine feels like hiding. Is that a different thing?",
    620,
    145,
    true,
    Colors.indigoAccent,
    _av(21),
  ),

  // ── RELATIONSHIPS ─────────────────────────────────────────────────────
  Post(
    'Relationships',
    'attachment_anxiety',
    '3h',
    "I love him but the moment he's quiet I spiral into 'he hates me.'",
    "I know it's my anxiety not reality. The fear is so loud. How do I fix this? We've been together 8 months. He's patient. But I can feel him getting tired and that makes the spiral worse.",
    870,
    215,
    true,
    const Color(0xFFFF4D7D),
    _av(22),
  ),
  Post(
    'Relationships',
    'push_pull',
    '7h',
    "I push people away the moment they get too close. I watch myself do it.",
    "The pattern is obvious. The breaking is compulsive. I don don't want to be alone forever.",
    690,
    163,
    true,
    const Color(0xFFFF4D7D),
    _av(23),
  ),
  Post(
    'Relationships',
    'not_over_it_1yr',
    '1d',
    "It's been a year. I'm still not over it. Am I broken?",
    "Everyone else moves on. I'm still replaying our last conversation.",
    750,
    178,
    false,
    const Color(0xFFFF4D7D),
    _av(24),
  ),
  Post(
    'Relationships',
    'settling_fear',
    '4h',
    "I'm scared I'll settle because I'm scared of being alone.",
    "I see couples around me and can't tell if they chose love or just settled for comfort.",
    520,
    120,
    true,
    const Color(0xFFFF4D7D),
    _av(25),
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

// ── SIDEBAR RESOURCE DATA ─────────────────────────────────────────────────
class _Resource {
  final String title, desc, btnText, imageUrl, url;
  final Color color;
  const _Resource(
    this.title,
    this.desc,
    this.btnText,
    this.imageUrl,
    this.color,
    this.url,
  );
}

Map<String, List<_Resource>> _sidebarResources = {
  'Academic Burnout': [
    _Resource(
      'StudyStream',
      'Join live virtual study rooms with thousands of students.',
      'Join Virtual Room',
      'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=500',
      Colors.blueAccent,
      'https://www.studystream.live/',
    ),
    _Resource(
      'Pomofocus',
      'Pomodoro timer to break tasks into 25-min sprints.',
      'Start Timer',
      'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500',
      Colors.redAccent,
      'https://pomofocus.io/',
    ),
    _Resource(
      'Sleep Cycle',
      'Burnout starts with bad sleep. Track and improve yours.',
      'Get the App',
      'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=500',
      Colors.purpleAccent,
      'https://www.sleepcycle.com/',
    ),
  ],
  'Family Issues': [
    _Resource(
      'MIASA Malaysia',
      'Local counseling and mental health awareness support.',
      'Get Local Help',
      'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=500',
      Colors.teal,
      'https://miasa.org.my/',
    ),
    _Resource(
      'Talian Kasih 15999',
      'Malaysian government hotline for domestic pressure or crisis.',
      'Learn More',
      'https://images.unsplash.com/photo-1583508915901-b5f84c1dcde1?w=500',
      Colors.red,
      'https://www.kpwkm.gov.my/',
    ),
    _Resource(
      'BetterHelp',
      'Connect with licensed therapists online, internationally.',
      'Visit BetterHelp',
      'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=500',
      Colors.green,
      'https://www.betterhelp.com/',
    ),
  ],
  'Dark Thoughts': [
    _Resource(
      'Befrienders Malaysia',
      'Free, confidential 24/7 emotional support. You are not alone.',
      'Contact Now',
      'https://images.unsplash.com/photo-1527525443983-6e60c75fff46?w=500',
      Colors.redAccent,
      'https://www.befrienders.org.my/',
    ),
    _Resource(
      'Mind Kami',
      'Malaysian youth mental health resources. Built for you.',
      'Find Resources',
      'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=500',
      Colors.indigo,
      'https://www.mindkami.com/',
    ),
    _Resource(
      'Crisis Text Line',
      'Text HOME to 741741. Crisis counselor. 24/7.',
      'Text Now',
      'https://images.unsplash.com/photo-1516383740770-fbcc5ccbece0?w=500',
      Colors.orangeAccent,
      'https://www.crisistextline.org/',
    ),
  ],
  'Career Anxiety': [
    _Resource(
      'JobStreet Malaysia',
      'Browse entry-level roles for fresh grads. Updated daily.',
      'Open JobStreet',
      'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=500',
      Colors.blueAccent,
      'https://www.jobstreet.com.my/',
    ),
    _Resource(
      'LinkedIn Learning',
      'Beat imposter syndrome with free skills courses.',
      'Start Learning',
      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500',
      Colors.lightBlue,
      'https://learning.linkedin.com/',
    ),
    _Resource(
      '16Personalities',
      'Free aptitude test to discover careers that actually fit.',
      'Take Career Quiz',
      'https://images.unsplash.com/photo-1507679622767-ace22ea65a12?w=500',
      Colors.deepPurple,
      'https://www.16personalities.com/',
    ),
  ],
  'Financial Anxiety': [
    _Resource(
      'GXBank Malaysia',
      'Digital savings account — open in minutes, no min balance.',
      'Open GXBank',
      'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=500',
      Colors.green,
      'https://www.gxbank.com.my/',
    ),
    _Resource(
      'Public Gold',
      'Start investing in gold from RM1. Safe, stable, Shariah-compliant.',
      'Invest Now',
      'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=500',
      Colors.amber,
      'https://www.publicgold.com.my/',
    ),
    _Resource(
      'Budget Google Sheet',
      'Free pre-made personal budget tracker — just copy and use.',
      'Get Template',
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=500',
      Colors.teal,
      'https://docs.google.com/spreadsheets/d/1pCg1amE8tvTTl9WKBS8RDYXBP1y7MPCqvQPNE5XxrJM/copy',
    ),
  ],
  'Loneliness': [
    _Resource(
      'Meetup Malaysia',
      'Low-pressure local hobby groups. Find your people.',
      'Explore Groups',
      'https://images.unsplash.com/photo-1529156069898-49953eb1b5ea?w=500',
      Colors.pinkAccent,
      'https://www.meetup.com/cities/my/',
    ),
    _Resource(
      'Bumble BFF',
      'Find friends (not dates) in your area. Zero pressure.',
      'Try Bumble BFF',
      'https://images.unsplash.com/photo-1516534775068-ba3e7458af70?w=500',
      Colors.amber,
      'https://bumble.com/bff',
    ),
    _Resource(
      'The Art of Being Alone',
      'Book by Renuka Singh. Embrace solitude without loneliness.',
      'Buy on Shopee',
      'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500',
      Colors.blueGrey,
      'https://shopee.com.my/search?keyword=art+of+being+alone+book',
    ),
  ],
  'Friendship Drama': [
    _Resource(
      'Bumble BFF',
      'Meet new friends in your city. No awkwardness, just vibes.',
      'Try Bumble BFF',
      'https://images.unsplash.com/photo-1529156069898-49953eb1b5ea?w=500',
      Colors.amber,
      'https://bumble.com/bff',
    ),
    _Resource(
      'Meetup Hobby Groups',
      'Find people who share your interests. Hiking, gaming, art.',
      'Find Your Tribe',
      'https://images.unsplash.com/photo-1528605248644-14dd04022da1?w=500',
      Colors.pinkAccent,
      'https://www.meetup.com/cities/my/',
    ),
    _Resource(
      'Attachment Theory (YouTube)',
      'Why we behave in friendships — eye-opening 10-min video.',
      'Watch Video',
      'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=500',
      Colors.purpleAccent,
      'https://www.youtube.com/watch?v=WjOowWxOXCg',
    ),
  ],
  'Feeling Unattractive': [
    _Resource(
      'Sephora Malaysia',
      'Skincare, makeup, self-care tools. Treat yourself well.',
      'Shop Sephora',
      'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500',
      Colors.pinkAccent,
      'https://www.sephora.my/',
    ),
    _Resource(
      'Anytime Fitness',
      '3-day free trial. Movement changes how you feel about yourself.',
      'Claim Free Trial',
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500',
      Colors.purpleAccent,
      'https://www.anytimefitness.my/try-us-free/',
    ),
    _Resource(
      'Glow Up TikTok Tips',
      'Real glow-up tips — skincare, confidence, style. Actually useful.',
      'Watch on TikTok',
      'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=500',
      Colors.cyan,
      'https://www.tiktok.com/search?q=glow+up+tips',
    ),
  ],
  'Body Insecurity': [
    _Resource(
      'Sephora Malaysia',
      'Skincare routines that actually work. Start somewhere.',
      'Shop Now',
      'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500',
      Colors.pinkAccent,
      'https://www.sephora.my/',
    ),
    _Resource(
      'Nike Training Club',
      'Free guided workouts. Start slow, feel better about your body.',
      'Try Free',
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500',
      Colors.redAccent,
      'https://www.nike.com/ntc-app',
    ),
    _Resource(
      'Blogilates (YouTube)',
      'Fun, body-positive pilates workouts for all fitness levels.',
      'Watch Now',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=500',
      Colors.pink,
      'https://www.youtube.com/@blogilates',
    ),
  ],
  'Identity & Self-Worth': [
    _Resource(
      'Atomic Habits',
      "James Clear's bestseller on building identity through small actions.",
      'Buy on Shopee',
      'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500',
      Colors.orange,
      'https://shopee.com.my/search?keyword=atomic+habits',
    ),
    _Resource(
      'The Mountain Is You',
      'Brianna Wiest — why we self-sabotage and how to stop.',
      'Buy on Shopee',
      'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500',
      Colors.deepPurple,
      'https://shopee.com.my/search?keyword=the+mountain+is+you',
    ),
    _Resource(
      'Mark Manson (YouTube)',
      'Blunt, honest takes on self-worth, purpose and modern life.',
      'Watch Channel',
      'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=500',
      Colors.blueGrey,
      'https://www.youtube.com/@IAmMarkManson',
    ),
  ],
  'Social Media Trap': [
    _Resource(
      'One Sec App',
      'Adds a 1-second pause before opening social apps. Breaks the reflex.',
      'Download Now',
      'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=500',
      Colors.blueGrey,
      'https://one-sec.app/',
    ),
    _Resource(
      'Digital Detox Challenge',
      '7-day challenge with a global community. Reset your habits.',
      'Join Challenge',
      'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=500',
      Colors.teal,
      'https://digitaldetox.org/',
    ),
    _Resource(
      'Headspace',
      'Mindfulness fills the void social media pretends to fill.',
      'Try Free',
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500',
      Colors.orangeAccent,
      'https://www.headspace.com/',
    ),
  ],
  'Phone Addiction': [
    _Resource(
      'One Sec App',
      'Forces a mindful pause before you open any app. Actually works.',
      'Download Now',
      'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=500',
      Colors.lightGreen,
      'https://one-sec.app/',
    ),
    _Resource(
      'Forest App',
      'Plant virtual trees. Your phone stays down. Trees stay alive.',
      'Get Forest',
      'https://images.unsplash.com/photo-1448375240586-882707db888b?w=500',
      Colors.green,
      'https://www.forestapp.cc/',
    ),
    _Resource(
      'Digital Wellbeing (Android)',
      'Built into your phone. Set app limits and wind-down mode now.',
      'Set It Up',
      'https://images.unsplash.com/photo-1555774698-0b77e0d5fac6?w=500',
      Colors.blueAccent,
      'https://wellbeing.google/',
    ),
  ],
  'Future Doubts': [
    _Resource(
      '80,000 Hours',
      'Research-backed career advice for people who want to do good.',
      'Explore Now',
      'https://images.unsplash.com/photo-1507679622767-ace22ea65a12?w=500',
      Colors.blueAccent,
      'https://80000hours.org/',
    ),
    _Resource(
      'Ikigai Test',
      'Find where passion, skill, and purpose overlap. Free online.',
      'Take the Test',
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500',
      Colors.amber,
      'https://ikigaitest.com/',
    ),
    _Resource(
      'Atomic Habits',
      'Build your future identity one tiny habit at a time.',
      'Buy on Shopee',
      'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500',
      Colors.orange,
      'https://shopee.com.my/search?keyword=atomic+habits',
    ),
  ],
  'Trauma': [
    _Resource(
      'Befrienders Malaysia',
      'Free, confidential listening. Available 24/7. No judgment.',
      'Call Now',
      'https://images.unsplash.com/photo-1527525443983-6e60c75fff46?w=500',
      Colors.red,
      'https://www.befrienders.org.my/',
    ),
    _Resource(
      '7 Cups',
      'Free online chat with trained volunteer listeners.',
      'Talk Now',
      'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=500',
      Colors.deepPurple,
      'https://www.7cups.com/',
    ),
    _Resource(
      'The Body Keeps the Score',
      'Bessel van der Kolk — the definitive book on trauma and healing.',
      'Buy on Shopee',
      'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500',
      Colors.indigo,
      'https://shopee.com.my/search?keyword=body+keeps+the+score',
    ),
  ],
  'Procrastination': [
    _Resource(
      'Focusmate',
      'Virtual body-doubling. Work alongside a real human. Free.',
      'Book Session',
      'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500',
      Colors.orange,
      'https://www.focusmate.com/',
    ),
    _Resource(
      'Goblin Tools',
      'AI breaks scary tasks into tiny steps. Built for executive dysfunction.',
      'Try It Free',
      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500',
      Colors.green,
      'https://goblin.tools/',
    ),
    _Resource(
      'Atomic Habits',
      'James Clear — how tiny systems beat motivation every time.',
      'Buy on Shopee',
      'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500',
      Colors.orange,
      'https://shopee.com.my/search?keyword=atomic+habits',
    ),
  ],
  'Sleep Struggles': [
    _Resource(
      'Sleep Cycle',
      'Tracks your sleep phases and wakes you at the right moment.',
      'Get the App',
      'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=500',
      Colors.purpleAccent,
      'https://www.sleepcycle.com/',
    ),
    _Resource(
      'Headspace Sleep',
      'Sleepcasts and meditations designed to quiet a busy mind.',
      'Try Free',
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500',
      Colors.indigoAccent,
      'https://www.headspace.com/sleep',
    ),
    _Resource(
      'Matthew Walker (YouTube)',
      "World's leading sleep scientist. 10-min talks that change everything.",
      'Watch Now',
      'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=500',
      Colors.blueGrey,
      'https://www.youtube.com/results?search_query=matthew+walker+sleep',
    ),
  ],
  'No One To Talk To': [
    _Resource(
      '7 Cups',
      'Free chat with trained listeners. Anonymous. No waitlist.',
      'Talk Now',
      'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=500',
      Colors.teal,
      'https://www.7cups.com/',
    ),
    _Resource(
      'Befrienders Malaysia',
      'Free 24/7 hotline. Just to be heard. That\'s enough.',
      'Call Now',
      'https://images.unsplash.com/photo-1527525443983-6e60c75fff46?w=500',
      Colors.red,
      'https://www.befrienders.org.my/',
    ),
    _Resource(
      'Woebot (AI Chat)',
      'AI-powered emotional support chatbot. CBT-based. Free.',
      'Try Woebot',
      'https://images.unsplash.com/photo-1516383740770-fbcc5ccbece0?w=500',
      Colors.lightBlue,
      'https://woebothealth.com/',
    ),
  ],
  'Overthinking': [
    _Resource(
      'Headspace',
      'Guided meditation specifically for anxious, busy minds.',
      'Try Free',
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500',
      Colors.teal,
      'https://www.headspace.com/',
    ),
    _Resource(
      'Calm',
      'Sleep stories and breathing exercises to slow the spiral.',
      'Download Calm',
      'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=500',
      Colors.blueAccent,
      'https://www.calm.com/',
    ),
    _Resource(
      'Feeling Good: The New Mood Therapy',
      'David Burns — CBT workbook that clinically reduces overthinking.',
      'Buy on Shopee',
      'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500',
      Colors.orange,
      'https://shopee.com.my/search?keyword=feeling+good+burns',
    ),
  ],
  'Bullying': [
    _Resource(
      'Cyber999 (MCMC)',
      'Report cyberbullying and online harassment in Malaysia.',
      'Report Now',
      'https://images.unsplash.com/photo-1516383740770-fbcc5ccbece0?w=500',
      Colors.red,
      'https://www.mcmc.gov.my/en/consumer/complaints/cyber999',
    ),
    _Resource(
      'Befrienders Malaysia',
      'Talk it through. 24/7. Free. Confidential.',
      'Call Now',
      'https://images.unsplash.com/photo-1527525443983-6e60c75fff46?w=500',
      Colors.redAccent,
      'https://www.befrienders.org.my/',
    ),
    _Resource(
      '7 Cups',
      'Chat anonymously with a trained listener who gets it.',
      'Talk Now',
      'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=500',
      Colors.deepPurple,
      'https://www.7cups.com/',
    ),
  ],
  'Relationships': [
    _Resource(
      'Attachment Project',
      'Free quiz: discover your attachment style and why you act this way.',
      'Take Quiz',
      'https://images.unsplash.com/photo-1516534775068-ba3e7458af70?w=500',
      Colors.pink,
      'https://www.attachmentproject.com/attachment-style-quiz/',
    ),
    _Resource(
      'School of Life (YouTube)',
      'Clear, compassionate videos on love, breakups and connection.',
      'Watch Channel',
      'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=500',
      Colors.deepOrange,
      'https://www.youtube.com/@theschooloflifetv',
    ),
    _Resource(
      'Hold Me Tight (Book)',
      'Sue Johnson — the science of emotional connection. Life-changing.',
      'Buy on Shopee',
      'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500',
      const Color(0xFFFF4D7D),
      'https://shopee.com.my/search?keyword=hold+me+tight+sue+johnson',
    ),
  ],
};

class FeedScreen extends StatefulWidget {
  final int initialCategoryIndex;
  const FeedScreen({super.key, this.initialCategoryIndex = 0});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late int _catIdx;
  final Set<int> _upvoted = {};
  final Set<int> _downvoted = {};

  @override
  void initState() {
    super.initState();
    _catIdx = widget.initialCategoryIndex;
  }

  @override
  void didUpdateWidget(FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategoryIndex != widget.initialCategoryIndex) {
      setState(() => _catIdx = widget.initialCategoryIndex);
    }
  }

  List<Post> get _filtered => _catIdx == 0
      ? _posts
      : _posts.where((p) => p.category == _categories[_catIdx]).toList();

  List<Post> get _relatedPosts {
    if (_catIdx == 0) return [];
    final currentCat = _categories[_catIdx];
    final others = _posts.where((p) => p.category != currentCat).toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    return others.take(3).toList();
  }

  Future<void> _launch(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint('Could not launch $url');
    }
  }

  // ── THE BRIDGE TO FIREBASE (WRITE) ──
  Future<void> submitPost(String title, String body, String category) async {
    if (title.trim().isEmpty || body.trim().isEmpty) return;

    try {
      final CollectionReference cloudPosts = FirebaseFirestore.instance
          .collection('posts');

      // 1. Save it to the live database!
      await cloudPosts.add({
        'title': title,
        'content': body,
        'category': category,
        'author': 'anon_user',
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 1,
      });

      // 2. Add it to the top of the screen instantly so the user sees it
      setState(() {
        _posts.insert(
          0,
          Post(
            category,
            'anon_user',
            'Just now',
            title,
            body,
            1,
            0,
            true,
            Colors.tealAccent, // Default color for new posts
            'https://api.dicebear.com/8.x/notionists/png?seed=You',
          ),
        );
      });

      print("✅ Post successfully saved to the cloud!");
    } catch (e) {
      print("🚨 Error saving post: $e");
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
                      _buildPostInputFake(),
                      const SizedBox(height: 16),
                      _buildTrendingStrip(),
                      const SizedBox(height: 16),
                      _CategoryBar(
                        selected: _catIdx,
                        onTap: (i) => setState(() => _catIdx = i),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_filtered.length, (i) {
                        final post = _filtered[i];
                        final globalIdx = _posts.indexOf(post);
                        return Column(
                          children: [
                            _RichPostCard(
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
    final trending = _trending;
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
            itemCount: trending.length,
            itemBuilder: (_, i) =>
                _TrendingCard(post: trending[i], rank: i + 1),
          ),
        ),
      ],
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
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(post.avatarUrl),
                          ),
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

  Widget _buildPostInputFake() {
    return GestureDetector(
      onTap: () => _showCreatePostForm(context), // THIS NOW OPENS THE FORM
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

  // --- ROLE 1 TASK 2: POST CREATION FORM UI ---
  void _showCreatePostForm(BuildContext context) {
    // We need TWO controllers: one for Title, one for Body
    final TextEditingController titleController = TextEditingController();
    final TextEditingController postController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _border),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Anonymous Post",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // TITLE INPUT
                TextField(
                  controller: titleController, // <-- Hooked up!
                  style: const TextStyle(color: Colors.white),
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
                const SizedBox(height: 12),

                // BODY INPUT
                TextField(
                  controller: postController, // <-- Hooked up!
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "What's on your mind? (AI Moderation is active)",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: _textSub),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        String title = titleController.text;
                        String body = postController.text;
                        String lowerBody = body.toLowerCase();

                        Navigator.pop(context); // Close the popup

                        // 3. THE AI SAFETY TRIGGER
                        if (lowerBody.contains('die') ||
                            lowerBody.contains('suicide') ||
                            lowerBody.contains('kill') ||
                            lowerBody.contains('murder')) {
                          _showSafetyInterceptUI(
                            context,
                          ); // Blocked! Show Warning.
                        } else {
                          // Safe! Figure out the category and save it.
                          String currentCat = _catIdx == 0
                              ? 'Overthinking'
                              : _categories[_catIdx];

                          // Call the Firebase function!
                          await submitPost(title, body, currentCat);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "✅ Post published securely to the cloud!",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Post to Community"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- ROLE 1 TASK 3: SAFETY INTERCEPT UI ---
  void _showSafetyInterceptUI(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: _bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  "AI Safety Intercept",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Our AI detected language indicating severe distress or self-harm in your draft. You are not alone, and we want to help.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textTitle,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.phone),
                    label: const Text("Connect to 24/7 Crisis Support"),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "I'm okay, discard post",
                    style: TextStyle(color: _textSub),
                  ),
                ),
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
          const _Resource(
            'Headspace',
            'Learn to meditate and live mindfully. Student discounts available.',
            'Try Headspace',
            'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500',
            Colors.orangeAccent,
            'https://www.headspace.com/',
          ),
          const _Resource(
            'Meetup Malaysia',
            'Find low-pressure local groups for hobbies you love.',
            'Explore Meetup',
            'https://images.unsplash.com/photo-1529156069898-49953eb1b5ea?w=500',
            Colors.pinkAccent,
            'https://www.meetup.com/cities/my/',
          ),
          const _Resource(
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
      if (i < resources.length - 1) widgets.add(const SizedBox(height: 16));
    }
    return widgets;
  }

  Widget _buildActionCard(_Resource r) {
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
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

// ── TRENDING CARD ──────────────────────────────────────────────────────────
class _TrendingCard extends StatelessWidget {
  final Post post;
  final int rank;
  const _TrendingCard({required this.post, required this.rank});
  @override
  Widget build(BuildContext context) {
    return Container(
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
              CircleAvatar(
                radius: 8,
                backgroundImage: NetworkImage(post.avatarUrl),
              ),
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
    );
  }
}

// ── CATEGORY BAR ──────────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _CategoryBar({required this.selected, required this.onTap});
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

// ── POST CARD ──────────────────────────────────────────────────────────────
class _RichPostCard extends StatelessWidget {
  final Post post;
  final bool upvoted, downvoted;
  final VoidCallback onUpvote, onDownvote;
  const _RichPostCard({
    required this.post,
    required this.upvoted,
    required this.downvoted,
    required this.onUpvote,
    required this.onDownvote,
  });
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
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(post.avatarUrl),
                      ),
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
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.share_outlined,
                        size: 16,
                        color: _textSub,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSub,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (post.aiSupported)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.amber.withOpacity(0.1),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.amber,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
