import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  // ⚠️ IMPORTANT: Replace these with your actual Supabase credentials
  static const String supabaseUrl = 'https://vmnszznfdnhpianpukdd.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtbnN6em5mZG5ocGlhbnB1a2RkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4ODYxMjgsImV4cCI6MjA4NjQ2MjEyOH0.EG16y9VMykZX1DNbU-TJx6uurbKm_3NeF3yiUQ7kyD0';

  // Storage bucket name for products
  static const String productBucket = 'Products';

  // Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Supabase initialization failed: $e');
      rethrow;
    }
  }

  // Get Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  // Get authenticated user
  static User? get currentUser => client.auth.currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
