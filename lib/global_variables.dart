import 'package:dhobi_app/datamodels/OurUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

User currentFirebaseUser;
OurUser currentUserInfo;

Reference profilePicRef;

TextStyle kOrderDetailsTitle =
    TextStyle(fontSize: 15.0, color: Colors.deepPurple[700]);

TextStyle kOrderDetails =
    TextStyle(fontSize: 18.0, color: Colors.grey[900], fontFamily: 'Ubuntu');

DateTime nextBusinessDay;
DateTime todayDate = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);

double laundryWashAndFoldPrice = 1.99; //Price Per Pound for wash and fold.
double deliveryFee = 3.99; // Delivery Fee
double salesTax = 10.99;

String kStripePublishableKey =
    "pk_test_51IrOrGBHuqOiCxa1nk4LRfsiRLybEDrMvlp8LetHDZX4cViXBqax0ifxYIJlkbk4UxgEd1Pvzcn11a8JFZBZk3Jg00nuVCZ0qd";
