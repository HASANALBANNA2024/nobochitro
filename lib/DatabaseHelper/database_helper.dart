import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  static final _client = Supabase.instance.client;

  // ১. ডাটা ইনসার্ট করা (Create)
  static Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from(table).insert(data);
    } catch (e) {
      throw Exception("Insert Error in $table: $e");
    }
  }

  // ২. ডাটা আপডেট করা (Update)
  static Future<void> update({
    required String table,
    required String column,
    required dynamic value,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from(table).update(data).eq(column, value);
    } catch (e) {
      throw Exception("Update Error in $table: $e");
    }
  }

  // ৩. ডাটা ডিলিট করা (Delete)
  static Future<void> delete({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    try {
      await _client.from(table).delete().eq(column, value);
    } catch (e) {
      throw Exception("Delete Error in $table: $e");
    }
  }

  // ৪. এক টেবিল থেকে অন্য টেবিলে ডাটা ট্রান্সফার (Replace Logic)
  // উদাহরণ: বুকিং ক্যান্সেল হলে 'bookings' থেকে 'cancelled_bookings' এ পাঠানো
  static Future<void> moveRow({
    required String fromTable,
    required String toTable,
    required String column,
    required dynamic value,
  }) async {
    try {
      // প্রথমে ডাটাটি খুঁজে বের করা
      final data = await _client
          .from(fromTable)
          .select()
          .eq(column, value)
          .single();

      if (data != null) {
        // নতুন টেবিলে ইনসার্ট করা
        await _client.from(toTable).insert(data);
        // আগের টেবিল থেকে ডিলিট করা
        await _client.from(fromTable).delete().eq(column, value);
      }
    } catch (e) {
      throw Exception("Move Row Error: $e");
    }
  }

  // ৫. ইমেজ আপলোড সার্ভিস (Storage)
  static Future<String?> uploadImage({
    required String folder,
    required String userId,
    required dynamic file, // File type
  }) async {
    try {
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = await _client.storage
          .from('user_assets')
          .upload('$folder/$fileName', file);

      // পাবলিক ইউআরএল গেট করা
      return _client.storage
          .from('user_assets')
          .getPublicUrl('$folder/$fileName');
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  static Future<void> insertDemoPhotographers() async {
    final supabase = Supabase.instance.client;

    final List<Map<String, dynamic>> demoData = [
      {
        'photographer_id': 'N-554433',
        'name': 'Rifat Bin Azad',
        'profile_image_url': 'https://i.pravatar.cc/300?u=rifat',
        'banner_image_url':
            'https://images.unsplash.com/photo-1554048612-b6a482bc67e5?w=1200',
        'specialty': 'Wild Life & Nature',
        'technical_arsenal': 'Nikon Z9, 400mm f2.8, Benro Tripod',
        'experience_years': 8,
        'projects_completed': '300+',
        'delivery_time': '15 Days',
        'bio': 'Exploring the unseen beauty of nature through my lens.',
        'location': 'Khulna, Bangladesh',
        'per_hours_fee': 5000,
        'is_available': true,
        'avg_rating': 4.8,
      },
      {
        'photographer_id': 'N-998877',
        'name': 'Farhana Yeasmin',
        'profile_image_url': 'https://i.pravatar.cc/300?u=farhana',
        'banner_image_url':
            'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1200',
        'specialty': 'Baby & Maternity',
        'technical_arsenal': 'Canon EOS R6, 50mm f1.2, Softboxes',
        'experience_years': 3,
        'projects_completed': '50+',
        'delivery_time': '5 Days',
        'bio': 'Capturing the first precious moments of your little ones.',
        'location': 'Rajshahi, Bangladesh',
        'per_hours_fee': 1800,
        'is_available': true,
        'avg_rating': 4.6,
      },
    ];

    try {
      for (var data in demoData) {
        // upsert ব্যবহার করলে একই আইডি বারবার ইনসার্ট হবে না, ডাটা আপডেট হবে
        await supabase
            .from('photographers')
            .upsert(
              data,
              onConflict: 'photographer_id', // তোমার টেবিলের প্রাইমারি কি কলাম
            );
      }
      print("অভিনন্দন! ডেমো ডাটা সাকসেসফুলি ইনসার্ট/আপডেট হয়েছে।");
    } catch (e) {
      print("ডাটা ইনসার্টে এরর: $e");
      print(
        "টিপস: সুপাবেস SQL Editor-এ গিয়ে 'photographers' টেবিলের RLS পলিসি চেক করো।",
      );
    }
  }
}
