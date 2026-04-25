// backend/index.js
import express from 'express';
import cors from 'cors';
import { v4 as uuidv4 } from 'uuid';

// 1. FIREBASE IMPORTS
import { initializeApp } from 'firebase/app';
import { 
    getFirestore, 
    collection, 
    getDocs, 
    setDoc, 
    doc, 
    updateDoc, 
    increment, 
    arrayUnion 
} from 'firebase/firestore';

// 2. FIREBASE CONFIG
const firebaseConfig = {
  apiKey: "AIzaSyDfG9CeddC0Lh-PX4htiLk2u5vMvHNXYAk",
  authDomain: "healance-a47c2.firebaseapp.com",
  projectId: "healance-a47c2",
  storageBucket: "healance-a47c2.firebasestorage.app",
  messagingSenderId: "178175487563",
  appId: "1:178175487563:web:86a37df23ab60ba72127ce"
};

// Initialize Firebase
const firebaseApp = initializeApp(firebaseConfig);
const db = getFirestore(firebaseApp);

const app = express();
app.use(cors());
app.use(express.json());

// ANONYMITY LOGIC: Generates a display name so real emails stay hidden
const generateAnonName = () => {
    const prefixes = ['quiet', 'brave', 'lost', 'hoping', 'tired', 'resilient'];
    const randomPrefix = prefixes[Math.floor(Math.random() * prefixes.length)];
    const randomHex = uuidv4().split('-')[0].substring(0, 5);
    return `${randomPrefix}_striver_${randomHex}`;
};

// ==========================================
// 3. API ROUTES
// ==========================================

app.get('/', (req, res) => {
    res.json({ message: 'Héalance Backend LIVE - Firebase Integrated' });
});

/**
 * GET ALL POSTS
 * Fetches the community feed from Firestore
 */
app.get('/api/posts', async (req, res) => {
    try {
        const postsCol = collection(db, 'posts');
        const postSnapshot = await getDocs(postsCol);
        const postList = postSnapshot.docs.map(doc => ({ 
            id: doc.id, 
            ...doc.data() 
        }));
        
        // Sort newest first based on ISO string timestamp
        postList.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        res.json(postList);
    } catch (error) {
        console.error("Fetch Error:", error);
        res.status(500).json({ error: 'Database connection failed' });
    }
});

/**
 * CREATE POST
 * Saves a new anonymous post to Firestore
 */
app.post('/api/posts', async (req, res) => {
    const { category, title, body, location, authorEmail } = req.body;

    if (!title || !body) {
        return res.status(400).json({ error: 'Title and body are required' });
    }

    const newPostId = `post_${uuidv4()}`;
    const newPostData = {
        authorId: generateAnonName(), // Keep it anonymous!
        authorEmail: authorEmail || 'hidden', // Store for internal ref only
        category: category || 'General',
        title: title,
        body: body,
        location: location || 'Unknown',
        resiliencePoints: 0,
        comments: [], // Initialize empty comments array
        timestamp: new Date().toISOString()
    };

    try {
        await setDoc(doc(db, "posts", newPostId), newPostData);
        res.status(201).json({ message: 'Post published!', post: { id: newPostId, ...newPostData } });
    } catch (error) {
        console.error("Creation Error:", error);
        res.status(500).json({ error: 'Failed to save post' });
    }
});

/**
 * UPVOTE POST
 */
app.post('/api/posts/:id/upvote', async (req, res) => {
    try {
        const postRef = doc(db, "posts", req.params.id);
        await updateDoc(postRef, {
            resiliencePoints: increment(1)
        });
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: 'Upvote failed' });
    }
});

/**
 * ADD COMMENT
 * Uses arrayUnion to add a comment object into the post document
 */
app.post('/api/posts/:id/comments', async (req, res) => {
    const { text } = req.body;
    if (!text) return res.status(400).json({ error: 'Comment empty' });

    try {
        const postRef = doc(db, "posts", req.params.id);
        const commentObj = {
            id: `comment_${uuidv4()}`,
            author: generateAnonName(),
            text: text,
            timestamp: new Date().toISOString()
        };

        await updateDoc(postRef, {
            comments: arrayUnion(commentObj)
        });

        res.status(201).json({ message: 'Comment added', comment: commentObj });
    } catch (error) {
        res.status(500).json({ error: 'Failed to add comment' });
    }
});

/**
 * MAP DATA
 */
app.get('/api/map-data', (req, res) => {
    const mapNodes = [
        { id: 1, location: "Kuala Lumpur", lat: 3.1390, lng: 101.6869, status: "Critical", label: "Burnout Peak" },
        { id: 2, location: "Subang Jaya", lat: 3.0438, lng: 101.5859, status: "High Tension", label: "Resource Desert" },
        { id: 3, location: "Penang", lat: 5.4141, lng: 100.3288, status: "Stable", label: "Adequate Support" }
    ];
    res.json(mapNodes);
});

/**
 * AI CHAT (Placeholder for Role 3)
 */
app.post('/api/chat', (req, res) => {
    const { message } = req.body;
    res.json({ reply: `Héalance Sidekick: I hear you. You mentioned "${message}". How are you breathing right now?` });
});

// ==========================================
// 4. START SERVER
// ==========================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`
    ---------------------------------------------------
    🚀 Héalance Backend Running!
    🔗 URL: http://localhost:${PORT}
    📡 Firebase: ${firebaseConfig.projectId}
    ---------------------------------------------------
    `);
});