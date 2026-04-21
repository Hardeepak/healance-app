// backend/index.js
const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors()); // Allows your Flutter frontend to make requests
app.use(express.json()); // Allows the server to read JSON data

// 1. DUMMY DATABASE SCHEMA
// We are using memory arrays for the hackathon MVP.
const db = {
    users: [],
    posts: [
        {
            id: 'post_001',
            authorId: 'anon_user_8f72a',
            category: 'FutureWorries',
            title: 'I feel like I am failing my degree',
            body: 'Everyone else gets coding so easily, but I am just stuck.',
            location: 'Selangor',
            resiliencePoints: 12,
            timestamp: new Date().toISOString()
        }
    ]
};

// 2. THE ANONYMITY LOGIC
// Generates a random username if one isn't provided
const generateAnonName = () => {
    const prefixes = ['quiet', 'brave', 'lost', 'hoping', 'tired'];
    const randomPrefix = prefixes[Math.floor(Math.random() * prefixes.length)];
    const randomHex = uuidv4().split('-')[0].substring(0, 5);
    return `${randomPrefix}_striver_${randomHex}`;
};

// ==========================================
// 3. API ROUTES
// ==========================================

// Route: Health Check (Just to see if server is alive)
app.get('/', (req, res) => {
    res.json({ message: 'AuraThread/Healance Backend is running!' });
});

// Route: GET ALL POSTS (Frontend calls this to load the feed)
app.get('/api/posts', (req, res) => {
    // You can add filtering here later (e.g., req.query.category)
    res.json(db.posts);
});

// Route: CREATE A NEW POST (Frontend sends data here when user clicks "Post")
app.post('/api/posts', (req, res) => {
    const { category, title, body, location } = req.body;

    // Basic validation
    if (!title || !body) {
        return res.status(400).json({ error: 'Title and body are required' });
    }

    // Create the new post object
    const newPost = {
        id: `post_${uuidv4()}`,
        authorId: generateAnonName(), // Enforcing anonymity!
        category: category || 'General',
        title: title,
        body: body,
        location: location || 'Unknown',
        resiliencePoints: 0,
        timestamp: new Date().toISOString()
    };

    // Save to our "database"
    db.posts.unshift(newPost); // Adds to the top of the feed

    // Send success response back to frontend
    res.status(201).json({ message: 'Post created successfully', post: newPost });
});

// ==========================================
// 4. START THE SERVER
// ==========================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Backend Server running on http://localhost:${PORT}`);
    console.log(`Ready for the Frontend to hit http://localhost:${PORT}/api/posts`);
});