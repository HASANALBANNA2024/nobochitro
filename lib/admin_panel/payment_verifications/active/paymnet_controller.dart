import 'active_service.dart';

class PaymentController {
  Future<List<Map<String, dynamic>>> fetchActivePayments() async {
    return await ActiveService.getActivePayments();
  }

  // এটি Approve/Suspend এর জন্য (payment & booking দুটোই আপডেট করবে)
  Future<void> updateStatus(String id, String status, Function onDone) async {
    await ActiveService.updatePaymentStatus(id, status);
    onDone();
  }

  // এটি চেইনিংয়ের জন্য (শুধু booking_status আপডেট করবে)
  Future<void> updateBookingStatusOnly(String id, String status, Function onDone) async {
    await ActiveService.updateBookingStatusOnly(id, status);
    onDone();
  }

  Future<void> suspendPayment(String id, String note, Function onDone) async {
    await ActiveService.suspendPayment(id, note);
    onDone();
  }

  Future<void> updateHandover(String id, String link, Function onDone) async {
    await ActiveService.updateHandover(id, link);
    onDone();
  }
}