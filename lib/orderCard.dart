import 'package:flutter/material.dart';
// import 'package:desktop_search_a_holic/newOrder.dart';

class OrderCard extends StatelessWidget {
  final String productName;
  final double productPrice;
  final double productQty;
  final String productID;

  const OrderCard({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productQty,
    required this.productID,
  });

  // buttonPress

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
        ),
        child: Card(
          shadowColor: Colors.grey[50],
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.grey[50],
          child: Row(
            children: [
              Expanded(
                  child: SizedBox(
                      height: 45, child: Align(child: Text(productName)))),
              Expanded(
                  child: SizedBox(
                      height: 45,
                      child: Align(
                          child: Text("Rs. $productPrice",
                              style: const TextStyle(color: Colors.red))))),
              Expanded(
                  child: SizedBox(
                      height: 45,
                      child: Align(
                          child: Text("Qty. $productQty",
                              style: const TextStyle(color: Colors.blue))))),
              const Expanded(
                  child: SizedBox(
                      height: 45,
                      // Delete Icon
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Align(
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ))),
            ],
          ),
        ));
  }
}
