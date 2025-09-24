const mongoose = require('mongoose');

module.exports = async function connectDB() {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true, 
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000, // Timeout after 5s instead of 30s
    });
    console.log('MongoDB connected successfully');
  } catch (err) {
    console.error('MongoDB connection error:', err.message);
    console.warn('⚠️  MongoDB is not running. Please:');
    console.warn('   1. Install MongoDB: brew install mongodb-community');
    console.warn('   2. Start MongoDB: brew services start mongodb-community');
    console.warn('   3. Or use Docker: docker run -d -p 27017:27017 mongo');
    console.warn('   For now, the server will continue without database...');
    
    // Don't exit the process, just log the warning
    // You could also implement an in-memory alternative here
  }
};
