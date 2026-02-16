// Simple Express server to run functions locally
const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 5000;

// Middleware - Add CORS first!
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'OPTIONS', 'PUT', 'DELETE'],
  credentials: false
}));
app.use(express.json());

// Import functions from index.js
const functions = require('./index.js');

// Create a simple request/response wrapper for the functions
// This converts Firebase Functions format to Express format

// M-Pesa Payment Endpoint
app.post('/initiateMpesaPayment', async (req, res) => {
  const mockReq = {
    method: 'POST',
    body: req.body,
    query: req.query,
    headers: req.headers
  };
  
  const mockRes = {
    status: (code) => {
      mockRes.statusCode = code;
      return mockRes;
    },
    json: (data) => {
      res.status(mockRes.statusCode || 200).json(data);
    },
    set: (header, value) => {
      res.set(header, value);
    }
  };
  
  await functions.initiateMpesaPayment(mockReq, mockRes);
});

// M-Pesa Callback Endpoint
app.post('/user/mpesa/callback', async (req, res) => {
  const mockReq = {
    method: 'POST',
    body: req.body,
    query: req.query,
    headers: req.headers
  };
  
  const mockRes = {
    status: (code) => {
      mockRes.statusCode = code;
      return mockRes;
    },
    json: (data) => {
      res.status(mockRes.statusCode || 200).json(data);
    },
    set: (header, value) => {
      res.set(header, value);
    }
  };
  
  await functions.mpesaCallback(mockReq, mockRes);
});

// Check Payment Status
app.get('/checkPaymentStatus', async (req, res) => {
  const mockReq = {
    method: 'GET',
    body: {},
    query: req.query,
    headers: req.headers
  };
  
  const mockRes = {
    status: (code) => {
      mockRes.statusCode = code;
      return mockRes;
    },
    json: (data) => {
      res.status(mockRes.statusCode || 200).json(data);
    },
    set: (header, value) => {
      res.set(header, value);
    }
  };
  
  await functions.checkPaymentStatus(mockReq, mockRes);
});

// Query STK Status
app.post('/queryStkPushStatus', async (req, res) => {
  const mockReq = {
    method: 'POST',
    body: req.body,
    query: req.query,
    headers: req.headers
  };
  
  const mockRes = {
    status: (code) => {
      mockRes.statusCode = code;
      return mockRes;
    },
    json: (data) => {
      res.status(mockRes.statusCode || 200).json(data);
    },
    set: (header, value) => {
      res.set(header, value);
    }
  };
  
  await functions.queryStkPushStatus(mockReq, mockRes);
});

// Verify Payment
app.post('/verifyPayment', async (req, res) => {
  const mockReq = {
    method: 'POST',
    body: req.body,
    query: req.query,
    headers: req.headers
  };
  
  const mockRes = {
    status: (code) => {
      mockRes.statusCode = code;
      return mockRes;
    },
    json: (data) => {
      res.status(mockRes.statusCode || 200).json(data);
    },
    set: (header, value) => {
      res.set(header, value);
    }
  };
  
  await functions.verifyPayment(mockReq, mockRes);
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'M-Pesa backend server is running' });
});

app.listen(PORT, () => {
  console.log(`✅ M-Pesa Backend Server running on http://localhost:${PORT}`);
  console.log(`📱 Use with ngrok to expose publicly`);
  console.log(`🔗 Endpoints:`);
  console.log(`   POST /initiateMpesaPayment`);
  console.log(`   POST /user/mpesa/callback`);
  console.log(`   GET  /checkPaymentStatus`);
  console.log(`   POST /queryStkPushStatus`);
  console.log(`   POST /verifyPayment`);
  console.log(`   GET  /health`);
});
