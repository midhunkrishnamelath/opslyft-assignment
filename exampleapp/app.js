const express = require('express');
const app = express();

// Define an API endpoint
app.get('/', (req, res) => {
  res.json({ message: 'Hello from the exampleapp API!' });
});

// Start the server
const port = 3002;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
