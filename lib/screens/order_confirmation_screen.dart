import 'package:dhobi_app/global_variables.dart';
import 'package:dhobi_app/helpers/helpermethods.dart';
import 'package:dhobi_app/widgets/BrandDivider.dart';
import 'package:dhobi_app/widgets/largeButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderConfirmationScreen extends StatefulWidget {
  @override
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final DateTime selectedPickupDate = todayDate;
  final DateTime selectedDeliveryDate = todayDate;
  final int weight = 10;

  @override
  void initState() {
    super.initState();
    // totalCost =
    //     HelperMethods.calculatePrices('fullPrice', 'washAndFold', weight);
    // //TODOL: Tip, Tax, etc.
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
