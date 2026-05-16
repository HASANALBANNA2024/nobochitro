import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  DatabaseHelper._();

  // ২. instance মেম্বারটি ডিফাইন করুন (এটি না থাকলে রেড লাইন আসবে)
  static final DatabaseHelper instance = DatabaseHelper._();

  // getcategoris of under of banner
  // database_helper.dart
  Future<List<String>> getUniqueCategories() async {
    try {
      final response = await _client.from('packages').select('category');

      final List<dynamic> data = response as List;
      // Set ব্যবহার করে ডুপ্লিকেট নাম বাদ দেওয়া হয়েছে
      final categories = data
          .map((item) => item['category'].toString())
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      debugPrint("Error fetching unique categories: $e");
      return [];
    }
  }

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
      // --- আপনার আগের ডাটা ---
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

      // --- নতুন ইউনিক ফটোগ্রাফার ডাটা ---
      {
        'photographer_id': 'N-223344',
        'name': 'Tanvir Ahmed',
        'profile_image_url': 'https://i.pravatar.cc/300?u=tanvir',
        'banner_image_url':
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200',
        'specialty': 'Commercial & Product',
        'technical_arsenal': 'Sony A7R V, 90mm Macro, Godox Lighting',
        'experience_years': 6,
        'projects_completed': '150+',
        'delivery_time': '3 Days',
        'bio': 'Making products look premium and ready for the global market.',
        'location': 'Dhaka, Bangladesh',
        'per_hours_fee': 4000,
        'is_available': true,
        'avg_rating': 4.9,
      },
      {
        'photographer_id': 'N-112233',
        'name': 'Sajid Al-Hossain',
        'profile_image_url': 'https://i.pravatar.cc/300?u=sajid',
        'banner_image_url':
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1200',
        'specialty': 'Architecture & Interior',
        'technical_arsenal': 'Canon EOS R5, 17mm Tilt-Shift, DJI Mavic 3 Pro',
        'experience_years': 5,
        'projects_completed': '80+',
        'delivery_time': '10 Days',
        'bio': 'Capturing structures and spaces with precision and HDR depth.',
        'location': 'Sylhet, Bangladesh',
        'per_hours_fee': 6000,
        'is_available': true,
        'avg_rating': 4.7,
      },
      {
        'photographer_id': 'N-776655',
        'name': 'Maliha Zaman',
        'profile_image_url': 'https://i.pravatar.cc/300?u=maliha',
        'banner_image_url':
            'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200',
        'specialty': 'Fashion & Lifestyle',
        'technical_arsenal': 'Fujifilm GFX 100S, 85mm f1.4, Profoto B10',
        'experience_years': 4,
        'projects_completed': '120+',
        'delivery_time': '7 Days',
        'bio':
            'Combining style and storytelling through high-end fashion photography.',
        'location': 'Dhaka, Bangladesh',
        'per_hours_fee': 3500,
        'is_available': true,
        'avg_rating': 4.8,
      },
      {
        'photographer_id': 'N-334455',
        'name': 'Ariful Islam',
        'profile_image_url': 'https://i.pravatar.cc/300?u=ariful',
        'banner_image_url':
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200',
        'specialty': 'Food & Culinary',
        'technical_arsenal': 'Sony A7 IV, 50mm Macro, Scrims & Reflectors',
        'experience_years': 3,
        'projects_completed': '60+',
        'delivery_time': '4 Days',
        'bio':
            'Turning flavors into visuals. Specialist in restaurant menu shoots.',
        'location': 'Chittagong, Bangladesh',
        'per_hours_fee': 2500,
        'is_available': true,
        'avg_rating': 4.5,
      },
    ];

    try {
      for (var data in demoData) {
        await supabase
            .from('photographers')
            .upsert(data, onConflict: 'photographer_id');
      }
      print(
        "অভিনন্দন! সব স্পেশালিস্ট ফটোগ্রাফারদের ডাটা সাকসেসফুলি আপডেট হয়েছে।",
      );
    } catch (e) {
      print("ডাটা ইনসার্টে এরর: $e");
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
    final List<Map<String, dynamic>> expandedPackages = [
      // --- Commercial (Ecommerce & Branding) ---
      {
        'package_id': 'PKG-COM-101',
        'title': 'Starter Product Shoot',
        'category': 'Commercial',
        'base_price': 5000,
        'features': '5 Products, White Background, Basic Editing, 48h Delivery',
        'image_url':
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
        'is_active': true,
        'is_customization': false,
      },
      {
        'package_id': 'PKG-COM-102',
        'title': 'Lifestyle Product Branding',
        'category': 'Commercial',
        'base_price': 15000,
        'features':
            '10 Products, Real-life Context, Professional Props, Social Media Ready',
        'image_url':
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
        'is_active': true,
        'is_customization': true,
      },

      // --- Graduation (Academic) ---
      {
        'package_id': 'PKG-GRAD-201',
        'title': 'Single Graduation Portrait',
        'category': 'Graduation',
        'base_price': 2000,
        'features': '30 Mins, Campus Spot, 5 Retouched Photos, Gown Provided',
        'image_url':
            'https://images.unsplash.com/photo-1523050854058-8df90110c9f1',
        'is_active': true,
        'is_customization': false,
      },
      {
        'package_id': 'PKG-GRAD-202',
        'title': 'Squad Graduation Party',
        'category': 'Graduation',
        'base_price': 8000,
        'features':
            'Max 10 People, Group Fun Shots, Celebration Clips, All RAW images',
        'image_url':
            'https://images.unsplash.com/photo-1541339907198-e08756ebafe3',
        'is_active': true,
        'is_customization': true,
      },

      // --- Food (Restaurant & Blogs) ---
      {
        'package_id': 'PKG-FOOD-301',
        'title': 'Cafe Menu Teaser',
        'category': 'Food',
        'base_price': 4000,
        'features':
            '5 Signature Dishes, Natural Lighting, Ideal for Instagram Stories',
        'image_url':
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
        'is_active': true,
        'is_customization': false,
      },
      {
        'package_id': 'PKG-FOOD-302',
        'title': 'Fine Dining Commercial',
        'category': 'Food',
        'base_price': 20000,
        'features':
            'Full Menu, Chef Portraits, Kitchen Action Shots, 4K Food B-Roll Video',
        'image_url':
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
        'is_active': true,
        'is_customization': true,
      },

      // --- Architecture & Interior ---
      {
        'package_id': 'PKG-ARCH-401',
        'title': 'Airbnb/Rental Basic',
        'category': 'Architecture',
        'base_price': 6000,
        'features':
            'Living Room & Bedroom, Optimized for Booking Sites, Basic HDR',
        'image_url':
            'https://images.unsplash.com/photo-1484154218962-a197022b5858',
        'is_active': true,
        'is_customization': false,
      },
      {
        'package_id': 'PKG-ARCH-402',
        'title': 'Corporate Office Showcase',
        'category': 'Architecture',
        'base_price': 25000,
        'features':
            'Full Building Exterior, Interior Hubs, Employee in Action, Drone Exterior',
        'image_url':
            'https://images.unsplash.com/photo-1497366216548-37526070297c',
        'is_active': true,
        'is_customization': true,
      },

      // --- Fashion ---
      {
        'package_id': 'PKG-FASH-501',
        'title': 'Street Style Lookbook',
        'category': 'Fashion',
        'base_price': 10000,
        'features': 'Outdoor Session, 2 Outfits, Trendy Edits, Lifestyle Feel',
        'image_url':
            'https://images.unsplash.com/photo-1496747611176-843222e1e57c',
        'is_active': true,
        'is_customization': true,
      },
      {
        'package_id': 'PKG-FASH-502',
        'title': 'Editorial Studio Session',
        'category': 'Fashion',
        'base_price': 35000,
        'features':
            'Cyclorama Wall, Pro Lighting Setup, Makeup Artist, Vogue Style Retouching',
        'image_url':
            'https://images.unsplash.com/photo-1509631179647-0177331693ae',
        'is_active': true,
        'is_customization': true,
      },

      // --- Nature & Travel ---
      {
        'package_id': 'PKG-NAT-601',
        'title': 'Traveler Solo Portrait',
        'category': 'Nature',
        'base_price': 3000,
        'features':
            '1 Scenic Location, Adventure Theme, 10 High-Res Digital Files',
        'image_url':
            'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
        'is_active': true,
        'is_customization': false,
      },

      // --- Lifestyle (Pets/Family) ---
      {
        'package_id': 'PKG-LIFE-701',
        'title': 'Home Family Session',
        'category': 'Lifestyle',
        'base_price': 7000,
        'features':
            'In-home Shoot, Candid Interactions, 2 Hours, All Digital Images',
        'image_url':
            'https://images.unsplash.com/photo-1511895426328-dc8714191300',
        'is_active': true,
        'is_customization': true,
      },
    ];

    try {
      for (var package in expandedPackages) {
        await _client
            .from('packages')
            .upsert(package, onConflict: 'package_id');
      }
      debugPrint("বর্ধিত ডেমো প্যাকেজগুলো সফলভাবে ইনসার্ট হয়েছে।");
    } catch (e) {
      debugPrint("ইনসার্টে এরর: $e");
    }
  }

  // database_helper.dart ফাইলের ভেতরে এটি যোগ করুন
  Future<List<Map<String, dynamic>>> getPackages() async {
    try {
      // Supabase বা SQLite থেকে packages টেবিলের সব ডাটা আনা হচ্ছে
      final response = await _client
          .from('packages') // আপনার টেবিল নাম
          .select() // সব কলাম সিলেক্ট করা হচ্ছে
          .order('id', ascending: true); // ক্রমানুসারে সাজানোর জন্য (ঐচ্ছিক)

      // ডাটাগুলোকে লিস্ট হিসেবে রিটার্ন করা
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching packages: $e");
      return []; // কোনো এরর হলে খালি লিস্ট রিটার্ন করবে যাতে অ্যাপ ক্র্যাশ না করে
    }
  }

  Future<void> insertAddons() async {
    final List<Map<String, dynamic>> dummyAddons = [
      // --- WEDDING CATEGORY ADD-ONS ---
      {
        "title": "Wedding Luxury Album",
        "price": 8000,
        "category": "Wedding",
        "iamge_url":
            "https://images.unsplash.com/photo-1544333346-713fe99179b3",
        "is_active": true,
      },
      {
        "title": "Cinematic Wedding Teaser",
        "price": 5000,
        "category": "Wedding",
        "iamge_url":
            "https://images.unsplash.com/photo-1535016120720-40c646bebbfc",
        "is_active": true,
      },
      {
        "title": "Full Day Drone Coverage",
        "price": 7000,
        "category": "Wedding",
        "iamge_url":
            "https://images.unsplash.com/photo-1508614589041-895b88991e3e",
        "is_active": true,
      },
      {
        "title": "Bride & Groom Portrait Set",
        "price": 3000,
        "category": "Wedding",
        "iamge_url":
            "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
        "is_active": true,
      },

      // --- EVENT CATEGORY ADD-ONS ---
      {
        "title": "Express Event Delivery (24h)",
        "price": 2500,
        "category": "Event",
        "iamge_url":
            "https://images.unsplash.com/photo-1566576721346-d4a3b4eaad55",
        "is_active": true,
      },
      {
        "title": "Event Highlight Reels",
        "price": 2000,
        "category": "Event",
        "iamge_url":
            "https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7",
        "is_active": true,
      },
      {
        "title": "Instant Photo Print (50 copies)",
        "price": 4500,
        "category": "Event",
        "iamge_url":
            "https://images.unsplash.com/photo-1542038784456-1ea8e935640e",
        "is_active": true,
      },
      {
        "title": "Extra Event Photographer",
        "price": 4000,
        "category": "Event",
        "iamge_url":
            "https://images.unsplash.com/photo-1509048191080-d2984bad6ae5",
        "is_active": true,
      },

      // --- COMMON / BOTH (আপনি চাইলে এগুলোকে 'Common' রাখতে পারেন অথবা দুবার দিতে পারেন) ---
      {
        "title": "Luxury Photo Box",
        "price": 3500,
        "category": "Wedding", // ওয়েডিং এর জন্য
        "iamge_url":
            "https://images.unsplash.com/photo-1531346878377-a5be20888e57",
        "is_active": true,
      },
      {
        "title": "Canvas Frame (20x30)",
        "price": 3000,
        "category": "Event", // ইভেন্টের জন্য
        "iamge_url":
            "https://images.unsplash.com/photo-1583847268964-b28dc2f51ac9",
        "is_active": true,
      },
    ];

    try {
      await _client.from('addons').insert(dummyAddons);
      print("${dummyAddons.length} টি অ্যাড-অন সফলভাবে ইনসার্ট করা হয়েছে!");
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

  // result screen for cateogry by use packages
  Future<List<Map<String, dynamic>>> getPackagesByCategory(
    String categoryName,
  ) async {
    final response = await _client
        .from('packages')
        .select()
        .eq('category', categoryName);
    return List<Map<String, dynamic>>.from(response);
  }


  /// payment transaction / verifications table insert data from bookings summary and payment sheet

  // ------------------------------------------------------------------------------------
  // 🔴 নতুন সংযোজন: পেমেন্ট স্ক্রিনশট ফোল্ডারে আপলোড এবং বুকিং ডাটা টেবিলে সেভ করার কমপ্লিট ফাংশন
  // ------------------------------------------------------------------------------------
  Future<void> insertBookingWithTransactionImage(Map<String, dynamic> bookingData) async {
    try {
      String? imageUrl;
      String? imageName = bookingData['transaction_image_name'];

      // 🔴 এখানে 'nobochitro' কেটে 'user_assets' করে দিন (হুবহু নিচের মতো)
      const String bucketName = 'user_assets';

      // ১. ইমেজ ফাইল বা বাইটস চেক করে বাকেটের ভেতর payment_transaction ফোল্ডারে আপলোড করা
      if (kIsWeb) {
        // ওয়েবের জন্য (Uint8List Bytes)
        final bytes = bookingData['transaction_image_file'];
        if (bytes != null && imageName != null) {
          // পাথের শুরুতে ফোল্ডারের নাম জুড়ে দেওয়া হলো
          final String path = 'payment_transaction/web_${DateTime.now().millisecondsSinceEpoch}_$imageName';

          await _client.storage
              .from(bucketName)
              .uploadBinary(path, bytes);

          imageUrl = _client.storage.from(bucketName).getPublicUrl(path);
        }
      } else {
        // অ্যান্ডরয়েড/আইওএস এর জন্য (File Object)
        final file = bookingData['transaction_image_file'] as File?;
        if (file != null && imageName != null) {
          // পাথের শুরুতে ফোল্ডারের নাম জুড়ে দেওয়া হলো
          final String path = 'payment_transaction/mobile_${DateTime.now().millisecondsSinceEpoch}_$imageName';

          await _client.storage
              .from(bucketName)
              .upload(path, file);

          imageUrl = _client.storage.from(bucketName).getPublicUrl(path);
        }
      }

      // ২. ডাটাবেস টেবিল ফরমেট অনুযায়ী ম্যাপ ক্লিনিং ও প্রিপারেশন
      final Map<String, dynamic> dbData = Map<String, dynamic>.from(bookingData);
      dbData.remove('transaction_image_file');

      // টেবিলের কলামে ইমেজের পাবলিক URL সেট করা
      dbData['transaction_image_url'] = imageUrl;

      // 🔴 এখানে নিশ্চিত হয়ে নিন আপনার টেবিলের নাম 'payment_verifications' নাকি 'bookings'
      await _client.from('payment_verifications').insert(dbData);

      debugPrint("✅ Booking and Payment Data Successfully Saved!");
    } catch (e) {
      debugPrint("❌ Error in insertBookingWithTransactionImage: $e");
      rethrow;
    }
  }
}
