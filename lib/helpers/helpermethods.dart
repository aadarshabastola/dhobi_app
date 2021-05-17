import 'package:dhobi_app/datamodels/OurUser.dart';
import 'package:dhobi_app/global_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HelperMethods {
  static void getCurrentUserInfo() async {
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    String userId = currentFirebaseUser.uid;

    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users/$userId');
    userRef.once().then((DataSnapshot snapshot) {
      currentUserInfo =
          snapshot.value != null ? OurUser.fromSnapshot(snapshot) : null;
      profilePicRef = FirebaseStorage.instance
          .ref()
          .child('${currentUserInfo.id}/ProfilePic');
    });
  }

  static void getNextDay() {
    DateTime todayDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    nextBusinessDay = todayDate.add(
        (DateTime.now().weekday != 5) ? Duration(days: 1) : Duration(days: 2));
  }

  static double calculatePrices(
      String returnType, String washType, int weight) {
    double fullPrice = 0.0;
    double price = 0.0;
    double tax = 0.0;
    double delivery = deliveryFee;
    double data;
    if (washType == 'washAndFold') {
      price = laundryWashAndFoldPrice * weight;
    }
    tax = salesTax * price / 100;

    fullPrice = price + tax + deliveryFee;
    if (returnType == 'fullPrice') {
      data = fullPrice;
    }
    if (returnType == 'price') {
      data = price;
    }
    if (returnType == 'tax') {
      data = tax;
    }
    if (returnType == 'delivery') {
      data = delivery;
    }
    return double.parse((data).toStringAsFixed(2));
  }
}
