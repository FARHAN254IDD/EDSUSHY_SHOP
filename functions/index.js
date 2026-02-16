const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const express = require('express');

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

// ==================== M-Pesa Configuration ====================
const MPESA_CONFIG = {
  consumerKey: process.env.MPESA_CONSUMER_KEY || 'A3x09Kvm8A8xiGHha5yloAdL36U3GpZP8nySX4syRGiet4Eu',
  consumerSecret: process.env.MPESA_CONSUMER_SECRET || 'Reg1ULoAJfx88r64LiI3SGrAevNEKhqvYcdOGtCiGsyd1ECmpxrABE9lo1Ltk3uX',
  shortcode: process.env.MPESA_SHORTCODE || '174379',
  passkey: process.env.MPESA_PASSKEY || 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919',
  env: process.env.MPESA_ENV || 'sandbox',
  callbackUrl: process.env.MPESA_CALLBACK_URL || 'https://edsushy-shop-1.onrender.com/user/mpesa/callback'
};

const MPESA_API_URL = MPESA_CONFIG.env === 'sandbox' 
  ? 'https://sandbox.safaricom.co.ke'
  : 'https://api.safaricom.co.ke';

// ==================== M-Pesa STK Push Payment ====================
exports.initiateMpesaPayment = functions.https.onRequest(async (req, res) => {
  // Enable CORS for all origins
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, DELETE, PUT');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).send('CORS OK');
    return;
  }

  try {
    const { phoneNumber, amount, orderId, customerEmail, transactionDescription } = req.body;

    if (!phoneNumber || !amount || !orderId) {
      return res.status(400).json({
        success: false,
        message: 'Missing required parameters: phoneNumber, amount, orderId'
      });
    }

    // Get M-Pesa access token
    const token = await getMpesaAccessToken();
    if (!token) {
      return res.status(500).json({
        success: false,
        message: 'Failed to authenticate with M-Pesa'
      });
    }

    // Format phone number
    let formattedPhone = phoneNumber.replace(/[^\d]/g, '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '254' + formattedPhone.substring(1);
    } else if (!formattedPhone.startsWith('254')) {
      formattedPhone = '254' + formattedPhone;
    }

    // Generate timestamp and password
    const timestamp = formatTimestamp(new Date());
    const password = Buffer.from(`${MPESA_CONFIG.shortcode}${MPESA_CONFIG.passkey}${timestamp}`).toString('base64');

    // Prepare STK Push request
    const stkPushRequest = {
      BusinessShortCode: MPESA_CONFIG.shortcode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.floor(amount),
      PartyA: formattedPhone,
      PartyB: MPESA_CONFIG.shortcode,
      PhoneNumber: formattedPhone,
      CallBackURL: MPESA_CONFIG.callbackUrl,
      AccountReference: orderId,
      TransactionDesc: transactionDescription || 'Edsushy Shop Order'
    };

    // Send STK Push request
    const response = await axios.post(
      `${MPESA_API_URL}/mpesa/stkpush/v1/processrequest`,
      stkPushRequest,
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000
      }
    );

    if (response.data.ResponseCode === '0') {
      // Save transaction record
      await db.collection('transactions').doc(orderId).set({
        orderId: orderId,
        phoneNumber: formattedPhone,
        amount: amount,
        paymentMethod: 'mpesa',
        status: 'pending',
        checkoutRequestId: response.data.CheckoutRequestID,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      return res.status(200).json({
        success: true,
        message: 'STK Push sent successfully',
        checkoutRequestId: response.data.CheckoutRequestID
      });
    } else {
      return res.status(400).json({
        success: false,
        message: response.data.ResponseDescription || 'Failed to initiate STK Push',
        responseCode: response.data.ResponseCode
      });
    }
  } catch (error) {
    console.error('Error in initiateMpesaPayment:', error);
    return res.status(500).json({
      success: false,
      message: 'An error occurred: ' + error.message
    });
  }
});

// ==================== M-Pesa Callback Handler ====================
exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, DELETE, PUT');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).send('CORS OK');
    return;
  }

  try {
    console.log('M-Pesa Callback received:', JSON.stringify(req.body, null, 2));

    const body = req.body;
    
    if (!body.Body || !body.Body.stkCallback) {
      console.error('Invalid callback structure');
      return res.status(400).json({ ResultCode: '1', ResultDesc: 'Invalid callback structure' });
    }

    const stkCallback = body.Body.stkCallback;
    const resultCode = stkCallback.ResultCode;
    const resultDesc = stkCallback.ResultDesc;
    const merchantRequestId = stkCallback.MerchantRequestID;
    const checkoutRequestId = stkCallback.CheckoutRequestID;

    // Parse callback metadata
    let mpesaReceiptNumber = null;
    let transactionDate = null;
    let amount = null;
    let phoneNumber = null;

    if (stkCallback.CallbackMetadata && stkCallback.CallbackMetadata.Item) {
      const items = stkCallback.CallbackMetadata.Item;
      items.forEach(item => {
        if (item.Name === 'Amount') amount = item.Value;
        if (item.Name === 'MpesaReceiptNumber') mpesaReceiptNumber = item.Value;
        if (item.Name === 'TransactionDate') transactionDate = item.Value;
        if (item.Name === 'PhoneNumber') phoneNumber = item.Value;
      });
    }

    // Find and update order
    const ordersSnapshot = await db.collection('transactions')
      .where('checkoutRequestId', '==', checkoutRequestId)
      .limit(1)
      .get();

    if (!ordersSnapshot.empty) {
      const orderDoc = ordersSnapshot.docs[0];
      const orderId = orderDoc.id;

      if (resultCode === 0) {
        // Payment successful
        await db.collection('transactions').doc(orderId).update({
          status: 'completed',
          mpesaReceiptNumber: mpesaReceiptNumber,
          transactionDate: transactionDate,
          amount: amount,
          phoneNumber: phoneNumber,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        // Update corresponding order
        await db.collection('orders').doc(orderId).update({
          paymentStatus: 'completed',
          mpesaReceiptNumber: mpesaReceiptNumber,
          transactionId: mpesaReceiptNumber,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`Payment successful for order ${orderId}`);
      } else {
        // Payment failed or cancelled
        const failureReason = resultCode === 1 ? 'User cancelled' : resultDesc;
        await db.collection('transactions').doc(orderId).update({
          status: 'failed',
          failureReason: failureReason,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        // Update order status to failed
        await db.collection('orders').doc(orderId).update({
          paymentStatus: 'failed',
          failureReason: failureReason,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`Payment failed for order ${orderId}: ${failureReason}`);
      }
    }

    // Always return success to M-Pesa to acknowledge receipt
    return res.status(200).json({
      ResultCode: 0,
      ResultDesc: 'Accepted'
    });
  } catch (error) {
    console.error('Error processing M-Pesa callback:', error);
    return res.status(500).json({
      ResultCode: 1,
      ResultDesc: 'An error occurred: ' + error.message
    });
  }
});

// ==================== Query STK Push Status ====================
exports.queryStkPushStatus = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, DELETE, PUT');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).send('CORS OK');
    return;
  }

  try {
    const { checkoutRequestId } = req.query;

    if (!checkoutRequestId) {
      return res.status(400).json({
        success: false,
        message: 'checkoutRequestId is required'
      });
    }

    const token = await getMpesaAccessToken();
    if (!token) {
      return res.status(500).json({
        success: false,
        message: 'Failed to authenticate with M-Pesa'
      });
    }

    const timestamp = formatTimestamp(new Date());
    const password = Buffer.from(`${MPESA_CONFIG.shortcode}${MPESA_CONFIG.passkey}${timestamp}`).toString('base64');

    const queryRequest = {
      BusinessShortCode: MPESA_CONFIG.shortcode,
      Password: password,
      Timestamp: timestamp,
      CheckoutRequestID: checkoutRequestId
    };

    const response = await axios.post(
      `${MPESA_API_URL}/mpesa/stkpushquery/v1/query`,
      queryRequest,
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000
      }
    );

    return res.status(200).json(response.data);
  } catch (error) {
    console.error('Error querying STK push status:', error);
    return res.status(500).json({
      success: false,
      message: 'An error occurred: ' + error.message
    });
  }
});

// ==================== Check Payment Status ====================
exports.checkPaymentStatus = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, DELETE, PUT');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).send('CORS OK');
    return;
  }

  try {
    const { checkoutRequestId } = req.query;

    if (!checkoutRequestId) {
      return res.status(400).json({
        success: false,
        message: 'checkoutRequestId is required'
      });
    }

    // Query transaction by checkoutRequestId
    const snapshot = await db.collection('transactions')
      .where('checkoutRequestId', '==', checkoutRequestId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found'
      });
    }

    const transaction = snapshot.docs[0].data();
    return res.status(200).json({
      success: true,
      status: transaction.status,
      transaction: transaction
    });
  } catch (error) {
    console.error('Error checking payment status:', error);
    return res.status(500).json({
      success: false,
      message: 'An error occurred: ' + error.message
    });
  }
});

// ==================== Helper Functions ====================
async function getMpesaAccessToken() {
  try {
    const auth = Buffer.from(`${MPESA_CONFIG.consumerKey}:${MPESA_CONFIG.consumerSecret}`).toString('base64');
    const response = await axios.get(
      `${MPESA_API_URL}/oauth/v1/generate?grant_type=client_credentials`,
      {
        headers: {
          'Authorization': `Basic ${auth}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000
      }
    );

    return response.data.access_token;
  } catch (error) {
    console.error('Error getting M-Pesa access token:', error.message);
    return null;
  }
}

function formatTimestamp(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  const seconds = String(date.getSeconds()).padStart(2, '0');
  
  return `${year}${month}${day}${hours}${minutes}${seconds}`;
}

// ==================== Payment Verification ====================
exports.verifyPayment = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, DELETE, PUT');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).send('CORS OK');
    return;
  }

  try {
    const { orderId } = req.query;

    if (!orderId) {
      return res.status(400).json({
        success: false,
        message: 'orderId is required'
      });
    }

    const transactionDoc = await db.collection('transactions').doc(orderId).get();

    if (!transactionDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found'
      });
    }

    const transactionData = transactionDoc.data();
    return res.status(200).json({
      success: true,
      transaction: transactionData
    });
  } catch (error) {
    console.error('Error verifying payment:', error);
    return res.status(500).json({
      success: false,
      message: 'An error occurred: ' + error.message
    });
  }
});
