import 'active_service.dart'; // নতুন ফাইলের নাম অনুযায়ী ইম্পোর্ট

class PaymentController {
  Future<List<Map<String, dynamic>>> fetchActivePayments() async {
    return await ActiveService.getActivePayments();
  }

  Future<void> updateStatus(String id, String status, Function onDone) async {
    await ActiveService.updatePaymentStatus(id, status);
    onDone();
  }
}