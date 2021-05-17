import 'dart:convert';

import 'package:dhobi_app/global_variables.dart';
import 'package:dhobi_app/helpers/helpermethods.dart';
import 'package:dhobi_app/widgets/BrandDivider.dart';
import 'package:dhobi_app/widgets/ErrorDialog.dart';
import 'package:dhobi_app/widgets/largeButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;

class OrderConfirmationScreen extends StatefulWidget {
  @override
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final DateTime selectedPickupDate = todayDate;
  final DateTime selectedDeliveryDate = todayDate;
  final int weight = 10;

  String text = 'Click the button to start the payment';
  double totalCost = 10.0;
  double tip = 1.0;
  double tax = 0.0;
  double taxPercent = 0.2;
  int amount = 0;
  bool showSpinner = false;
  String url =
      'https://us-central1-demostripe-b9557.cloudfunctions.net/StripePI';
  Uri zxc;

  @override
  void initState() {
    super.initState();
    StripePayment.setOptions(
      StripeOptions(publishableKey: kStripePublishableKey),
    );
    totalCost =
        HelperMethods.calculatePrices('fullPrice', 'washAndFold', weight);
    //TODOL: Tip, Tax, etc.
  }

  void checkIfNativePayReady() async {
    print('started to check if native pay ready');
    bool deviceSupportNativePay = await StripePayment.deviceSupportsNativePay();
    bool isNativeReady = await StripePayment.canMakeNativePayPayments(
        ['american_express', 'visa', 'maestro', 'master_card']);
    deviceSupportNativePay && isNativeReady
        ? createPaymentMethodNative()
        : createPaymentMethod();
  }

  Future<void> createPaymentMethodNative() async {
    print('started NATIVE payment...');
    StripePayment.setStripeAccount(null);
    List<ApplePayItem> items = [];
    items.add(ApplePayItem(
      label: 'Demo Order',
      amount: totalCost.toString(),
    ));
    if (tip != 0.0)
      items.add(ApplePayItem(
        label: 'Tip',
        amount: tip.toString(),
      ));
    if (taxPercent != 0.0) {
      tax = ((totalCost * taxPercent) * 100).ceil() / 100;
      items.add(ApplePayItem(
        label: 'Tax',
        amount: tax.toString(),
      ));
    }
    items.add(ApplePayItem(
      label: 'Vendor A',
      amount: (totalCost + tip + tax).toString(),
    ));
    amount = ((totalCost + tip + tax) * 100).toInt();
    print('amount in pence/cent which will be charged = $amount');
    //step 1: add card
    PaymentMethod paymentMethod = PaymentMethod();
    Token token = await StripePayment.paymentRequestWithNativePay(
      androidPayOptions: AndroidPayPaymentRequest(
        totalPrice: (totalCost + tax + tip).toStringAsFixed(2),
        currencyCode: 'USD',
      ),
      applePayOptions: ApplePayPaymentOptions(
        countryCode: 'US',
        currencyCode: 'USD',
        items: items,
      ),
    );
    paymentMethod = await StripePayment.createPaymentMethod(
      PaymentMethodRequest(
        card: CreditCard(
          token: token.tokenId,
        ),
      ),
    );
    paymentMethod != null
        ? processPaymentAsDirectCharge(paymentMethod)
        : showDialog(
            context: context,
            builder: (BuildContext context) => ShowDialogToDismiss(
                title: 'Error',
                content:
                    'It is not possible to pay with this card. Please try again with a different card',
                buttonText: 'CLOSE'));
  }

  Future<void> processPaymentAsDirectCharge(PaymentMethod paymentMethod) async {
    setState(() {
      showSpinner = true;
    });
    //step 2: request to create PaymentIntent, attempt to confirm the payment & return PaymentIntent
    final http.Response response = await http
        // .post('$url?amount=$amount&currency=USD&paym=${paymentMethod.id}'.pars);
        .post(zxc);
    print('Now i decode');
    if (response.body != null && response.body != 'error') {
      final paymentIntentX = jsonDecode(response.body);
      final status = paymentIntentX['paymentIntent']['status'];
      final strAccount = paymentIntentX['stripeAccount'];
      //step 3: check if payment was succesfully confirmed
      if (status == 'succeeded') {
        //payment was confirmed by the server without need for futher authentification
        StripePayment.completeNativePayRequest();
        setState(() {
          text =
              'Payment completed. ${paymentIntentX['paymentIntent']['amount'].toString()}p succesfully charged';
          showSpinner = false;
        });
      } else {
        //step 4: there is a need to authenticate
        StripePayment.setStripeAccount(strAccount);
        await StripePayment.confirmPaymentIntent(PaymentIntent(
                paymentMethodId: paymentIntentX['paymentIntent']
                    ['payment_method'],
                clientSecret: paymentIntentX['paymentIntent']['client_secret']))
            .then(
          (PaymentIntentResult paymentIntentResult) async {
            //This code will be executed if the authentication is successful
            //step 5: request the server to confirm the payment with
            final statusFinal = paymentIntentResult.status;
            if (statusFinal == 'succeeded') {
              StripePayment.completeNativePayRequest();
              setState(() {
                showSpinner = false;
              });
            } else if (statusFinal == 'processing') {
              StripePayment.cancelNativePayRequest();
              setState(() {
                showSpinner = false;
              });
              showDialog(
                  context: context,
                  builder: (BuildContext context) => ShowDialogToDismiss(
                      title: 'Warning',
                      content:
                          'The payment is still in \'processing\' state. This is unusual. Please contact us',
                      buttonText: 'CLOSE'));
            } else {
              StripePayment.cancelNativePayRequest();
              setState(() {
                showSpinner = false;
              });
              showDialog(
                  context: context,
                  builder: (BuildContext context) => ShowDialogToDismiss(
                      title: 'Error',
                      content:
                          'There was an error to confirm the payment. Details: $statusFinal',
                      buttonText: 'CLOSE'));
            }
          },
          //If Authentication fails, a PlatformException will be raised which can be handled here
        ).catchError((e) {
          //case B1
          StripePayment.cancelNativePayRequest();
          setState(() {
            showSpinner = false;
          });
          showDialog(
              context: context,
              builder: (BuildContext context) => ShowDialogToDismiss(
                  title: 'Error',
                  content:
                      'There was an error to confirm the payment. Please try again with another card',
                  buttonText: 'CLOSE'));
        });
      }
    } else {
      //case A
      StripePayment.cancelNativePayRequest();
      setState(() {
        showSpinner = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) => ShowDialogToDismiss(
              title: 'Error',
              content:
                  'There was an error in creating the payment. Please try again with another card',
              buttonText: 'CLOSE'));
    }
  }

  Future<void> createPaymentMethod() async {
    StripePayment.setStripeAccount(null);
    tax = ((totalCost * taxPercent) * 100).ceil() / 100;
    amount = ((totalCost + tip + tax) * 100).toInt();
    print('amount in pence/cent which will be charged = $amount');
    //step 1: add card
    PaymentMethod paymentMethod = PaymentMethod();
    paymentMethod = await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) {
      return paymentMethod;
    }).catchError((e) {
      print('Errore Card: ${e.toString()}');
    });
    paymentMethod != null
        ? processPaymentAsDirectCharge(paymentMethod)
        : showDialog(
            context: context,
            builder: (BuildContext context) => ShowDialogToDismiss(
                title: 'Error',
                content:
                    'It is not possible to pay with this card. Please try again with a different card',
                buttonText: 'CLOSE'));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          shadowColor: Colors.black45,
          backgroundColor: Colors.white,
          title: Text(
            'Confirm Your Order',
            style: TextStyle(fontSize: 20, color: Colors.purple[900]),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Your Laundry Will Be Picked Up On:',
                style: TextStyle(
                  color: Colors.purple[900],
                  fontSize: 15,
                  fontFamily: 'Ubuntu',
                ),
              ),
              SizedBox(height: 5),
              Text(
                "${DateFormat('EEEE, MMMM d').format(selectedPickupDate)}",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                  color: Colors.purple[900],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'And Delivered On:',
                style: TextStyle(
                    color: Colors.purple[900],
                    fontSize: 15,
                    fontFamily: 'Ubuntu'),
              ),
              SizedBox(height: 5),
              Text(
                '${DateFormat('EEEE, MMMM d').format(selectedDeliveryDate)}',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                  color: Colors.purple[900],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              ExpansionTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'And This Will Cost You:',
                      style: TextStyle(
                          color: Colors.purple[900],
                          fontSize: 15,
                          fontFamily: 'Ubuntu'),
                    ),
                    Expanded(child: Container()),
                    Text(
                      '\$ ${HelperMethods.calculatePrices('fullPrice', 'washAndFold', weight)}',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ubuntu',
                        color: Colors.purple[900],
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Charge:',
                          style: TextStyle(
                              color: Colors.purple[900],
                              fontSize: 15,
                              fontFamily: 'Ubuntu'),
                        ),
                        Expanded(child: Container()),
                        Text(
                          '\$ ${HelperMethods.calculatePrices('price', 'washAndFold', weight)}',
                          style: TextStyle(
                              color: Colors.purple[900],
                              fontSize: 15,
                              fontFamily: 'Ubuntu-Bold'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Tax:',
                          style: TextStyle(
                              color: Colors.purple[900],
                              fontSize: 15,
                              fontFamily: 'Ubuntu'),
                        ),
                        Expanded(child: Container()),
                        Text(
                          '\$ ${HelperMethods.calculatePrices('tax', 'washAndFold', weight)}',
                          style: TextStyle(
                              color: Colors.purple[900],
                              fontSize: 15,
                              fontFamily: 'Ubuntu-Bold'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Delivery:',
                          style: TextStyle(
                              color: Colors.purple[900],
                              fontSize: 15,
                              fontFamily: 'Ubuntu'),
                        ),
                        Expanded(child: Container()),
                        Text(
                          '\$ ${HelperMethods.calculatePrices('delivery', 'washAndFold', weight)}',
                          style: TextStyle(
                              color: Colors.purple[900],
                              fontSize: 15,
                              fontFamily: 'Ubuntu-Bold'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: BrandDivider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                              color: Colors.purple[900],
                              fontSize: 15,
                              fontFamily: 'Ubuntu'),
                        ),
                        Expanded(child: Container()),
                        Text(
                          '\$ ${HelperMethods.calculatePrices('fullPrice', 'washAndFold', weight)}',
                          style: TextStyle(
                              color: Colors.purple[900],
                              fontSize: 15,
                              fontFamily: 'Ubuntu-Bold'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
              SizedBox(height: 10),
              LargeButton(
                title: 'BACK',
                color: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              LargeButton(
                title: 'PAY',
                color: Colors.black,
                onPressed: () {
//
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
