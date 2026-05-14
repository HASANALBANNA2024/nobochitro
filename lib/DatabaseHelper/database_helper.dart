import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {

  DatabaseHelper._();

  // ২. instance মেম্বারটি ডিফাইন করুন (এটি না থাকলে রেড লাইন আসবে)
  static final DatabaseHelper instance = DatabaseHelper._();

  // ৩. সুপাবেস ক্লায়েন্ট (আপনার আগের কোড অনুযায়ী)




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
  // ডাটা রিয়েল-টাইম পাওয়ার জন্য স্ট্রিম মেথড
  static Stream<List<Map<String, dynamic>>> getPhotographerStream() {
    return _client
        .from('photographers')
        .stream(primaryKey: ['photographer_id']);
  }

  // আপনার DatabaseHelper ক্লাসের ভেতরে এটি যোগ করুন
  static Future<void> insertDemoPackages() async {
    final List<Map<String, dynamic>> demoPackages = [
      {
        'package_id': 'PKG-WB-001',
        'title': 'Premium Wedding Bash',
        'category': 'Wedding',
        'photographer_id': 'N-554433', // আপনার আগের ডেমো ফটোগ্রাফার আইডি
        'base_price': 25000,
        'features': '8 Hours, 2 Photographers, Unlimited Photos, 100 Edited',
        'image_url': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc',
        'is_active': true,
        'is_customization': true,
      },
      {
        'package_id': 'PKG-EV-002',
        'title': 'Corporate Event Pro',
        'category': 'Event',
        'photographer_id': 'N-554433',
        'base_price': 15000,
        'features': '4 Hours, 1 Photographer, High Res Digital Delivery',
        'image_url': 'https://images.unsplash.com/photo-1511578314322-379afb476865',
        'is_active': true,
        'is_customization': false,
      },
      {
        'package_id': 'PKG-PT-003',
        'title': 'Outdoor Portrait Solo',
        'category': 'Portrait',
        'photographer_id': 'N-554433',
        'base_price': 5000,
        'features': '2 Hours, 20 Edited Photos, All RAW files',
        'image_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        'is_active': true,
        'is_customization': true,
      },
    ];

    try {
      // image_8488d5.png অনুযায়ী টেবিলের নাম 'packages' ধরে নিচ্ছি
      for (var package in demoPackages) {
        await _client.from('packages').upsert(package, onConflict: 'package_id');
      }
      debugPrint("প্যাকেজ ডেমো ডাটা সাকসেসফুলি ইনসার্ট হয়েছে।");
    } catch (e) {
      debugPrint("প্যাকেজ ইনসার্টে এরর: $e");
    }
  }


// database_helper.dart ফাইলের ভেতরে এটি যোগ করুন
  Future<List<Map<String, dynamic>>> getPackages() async {
    try {
      // Supabase বা SQLite থেকে packages টেবিলের সব ডাটা আনা হচ্ছে
      final response = await _client
          .from('packages') // আপনার টেবিল নাম
          .select()         // সব কলাম সিলেক্ট করা হচ্ছে
          .order('id', ascending: true); // ক্রমানুসারে সাজানোর জন্য (ঐচ্ছিক)

      // ডাটাগুলোকে লিস্ট হিসেবে রিটার্ন করা
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching packages: $e");
      return []; // কোনো এরর হলে খালি লিস্ট রিটার্ন করবে যাতে অ্যাপ ক্র্যাশ না করে
    }
  }

  Future<void> insertDummyAddons() async {
    final List<Map<String, dynamic>> dummyAddons = [
      {
        "title": "Extra 10 Retouched Photos",
        "price": 1500,
        "category": "Deliverables",
        "iamge_url": "https://images.unsplash.com/photo-1542038784456-1ea8e935640e",
        "is_active": true,
      },
      {
        "title": "4K Cinematic Video (3 min)",
        "price": 5000,
        "category": "Video",
        "iamge_url": "https://images.unsplash.com/photo-1536240478700-b869070f9279",
        "is_active": true,
      },
      {
        "title": "Aerial Drone Photography",
        "price": 3500,
        "category": "Special",
        "iamge_url": "https://images.unsplash.com/photo-1508614589041-895b88991e3e",
        "is_active": true,
      },
      {
        "title": "Premium Photo Album",
        "price": 4500,
        "category": "Print",
        "iamge_url": "https://images.unsplash.com/photo-1544377193-33dcf4d68fb5",
        "is_active": true,
      },
    ];

    try {
      // একবারে সব ডাটা ইনসার্ট করা হচ্ছে
      await _client.from('addons').insert(dummyAddons);
      print("Add-ons dummy data inserted successfully!");
    } catch (e) {
      print("Error inserting dummy addons: $e");
    }
  }




  // get photographers
  Future<List<Map<String, dynamic>>> getPhotographers() async {
    final response = await _client
        .from('photographers') // আপনার টেবিলের নাম
        .select();
    return List<Map<String, dynamic>>.from(response);
  }

  // get addons
  Future<List<Map<String, dynamic>>> getAddons() async {
    try {
      final response = await _client
          .from('addons') // আপনার সুপাবেস টেবিলের নাম
          .select()
          .eq('is_active', true); // শুধুমাত্র একটিভ আইটেমগুলো নিতে

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching addons: $e");
      return [];
    }
  }
}
