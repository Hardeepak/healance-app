// backend/index.js
import express from 'express';
import cors from 'cors';
import { v4 as uuidv4 } from 'uuid';

// 1. FIREBASE IMPORTS
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, getDocs, setDoc, doc, updateDoc, increment } from 'firebase/firestore';

// 2. YOUR FIREBASE CONFIG (Pasted directly from your team)
const firebaseConfig = {
  apiKey: "AIzaSyDfG9CeddC0Lh-PX4htiLk2u5vMvHNXYAk",
  authDomain: "healance-a47c2.firebaseapp.com",
  projectId: "healance-a47c2",
  storageBucket: "healance-a47c2.firebasestorage.app",
  messagingSenderId: "178175487563",
  appId: "1:178175487563:web:86a37df23ab60ba72127ce"
};

// Initialize Firebase and Firestore
const firebaseApp = initializeApp(firebaseConfig);
const db = getFirestore(firebaseApp);

const app = express();
app.use(cors());
app.use(express.json());

// THE ANONYMITY LOGIC
const generateAnonName = () => {
    const prefixes = ['quiet', 'brave', 'lost', 'hoping', 'tired'];
    const randomPrefix = prefixes[Math.floor(Math.random() * prefixes.length)];
    const randomHex = uuidv4().split('-')[0].substring(0, 5);
    return `${randomPrefix}_striver_${randomHex}`;
};

// ==========================================
// 3. API ROUTES (Now wired to Firestore)
// ==========================================

app.get('/', (req, res) => {
    res.json({ message: 'Healance Backend is running LIVE with Firebase!' });
});

// Route: GET ALL POSTS (Fetches from Firestore)
app.get('/api/posts', async (req, res) => {
    try {
        const postsCol = collection(db, 'posts');
        const postSnapshot = await getDocs(postsCol);
        const postList = postSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        
        // Sort newest first
        postList.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        res.json(postList);
    } catch (error) {
        console.error("Error fetching posts: ", error);
        res.status(500).json({ error: 'Failed to fetch posts from database' });
    }
});

// Route: CREATE A NEW POST (Saves to Firestore)
app.post('/api/posts', async (req, res) => {
    const { category, title, body, location } = req.body;

    if (!title || !body) {
        return res.status(400).json({ error: 'Title and body are required' });
    }

    const newPostId = `post_${uuidv4()}`;
    const newPostData = {
        authorId: generateAnonName(),
        category: category || 'General',
        title: title,
        body: body,
        location: location || 'Unknown',
        resiliencePoints: 0,
        timestamp: new Date().toISOString()
    };

    try {
        // Save the document to the 'posts' collection using the custom ID
        await setDoc(doc(db, "posts", newPostId), newPostData);
        res.status(201).json({ message: 'Post created in Firebase successfully!', post: { id: newPostId, ...newPostData } });
    } catch (error) {
        console.error("Error creating post: ", error);
        res.status(500).json({ error: 'Failed to save post to database' });
    }
});

// Route: ADD RESILIENCE POINTS (Upvoting in Firestore)
app.post('/api/posts/:id/upvote', async (req, res) => {
    const postId = req.params.id;
    
    try {
        const postRef = doc(db, "posts", postId);
        // Firebase has a built-in "increment" function so we don't accidentally overwrite data!
        await updateDoc(postRef, {
            resiliencePoints: increment(1)
        });
        res.json({ message: 'Resilience point added in Firebase!' });
    } catch (error) {
        console.error("Error updating points: ", error);
        res.status(500).json({ error: 'Failed to update points' });
    }
});

// Route: AI SAFETY INTERCEPT (Placeholder for AI Engineer)
app.post('/api/analyze-post', (req, res) => {
    const { body } = req.body;
    const triggerWords = ['kill', 'suicide', 'die', 'hurt'];
    const containsHarm = triggerWords.some(word => body?.toLowerCase().includes(word));

    if (containsHarm) {
        return res.json({ 
            status: 'blocked', 
            message: 'We hear you, and you are not alone. Please reach out to escalation support.',
            triggerDetected: true
        });
    }
    res.json({ status: 'safe', message: 'Post is safe to publish', triggerDetected: false });
});

// ==========================================
// 4. START THE SERVER
// ==========================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Firebase Backend Server running on http://localhost:${PORT}`);
});