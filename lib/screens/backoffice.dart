import 'package:animated_digit/animated_digit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stock_vapes/models/SaleModel.dart';
import 'package:stock_vapes/utils/configs.dart';
import 'package:stock_vapes/utils/constants.dart';
import 'package:stock_vapes/utils/utils.dart';

class BackOffice extends StatefulWidget {
  const BackOffice({super.key});

  @override
  State<BackOffice> createState() => _BackOfficeState();
}

class _BackOfficeState extends State<BackOffice> {
  double get totalSales => sales
      .map((e) => e.total)
      .fold<double>(0, (previousValue, element) => element + previousValue);
  double get totalOrders => orders
      .map((e) => e["total"])
      .fold<double>(0, (previousValue, element) => element + previousValue);

  double get totalProfit => totalSales - totalOrders;

  List<Sale> sales = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> orders = [];

  @override
  void initState() {
    repositoryBase
        .collection("sales")
        .orderBy("dt_cri", descending: true)
        .get()
        .then((value) => setState(() =>
            sales.addAll(value.docs.map((e) => Sale.fromJson(e.data())))));

    repositoryBase
        .collection("orders")
        .get()
        .then((value) => setState(() => orders = value.docs));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveFlags responsiveFlag =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? ResponsiveFlags.height
            : ResponsiveFlags.width;
    return Scaffold(
      body: sales.isEmpty || orders.isEmpty
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Util.getSidePadding(context),
                  vertical: Util.getResponsiveValue(
                      ResponsiveFlags.height, context, 100)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Flex(
                      direction: responsiveFlag == ResponsiveFlags.width
                          ? Axis.vertical
                          : Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Total"),
                            Card(
                              child: AnimatedDigitWidget(
                                textStyle: TextStyle(
                                    fontSize: Util.getSidePadding(context,
                                        val: responsiveFlag ==
                                                ResponsiveFlags.width
                                            ? 0.1
                                            : 0.04),
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.color),
                                duration: 1250.ms,
                                value: totalSales,
                                suffix: "€",
                                fractionDigits: 2,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Total Profit"),
                            Card(
                              child: AnimatedDigitWidget(
                                textStyle: TextStyle(
                                    fontSize: Util.getSidePadding(context,
                                        val: responsiveFlag ==
                                                ResponsiveFlags.width
                                            ? 0.1
                                            : 0.04),
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.color),
                                duration: 1250.ms,
                                value: totalProfit,
                                suffix: "€",
                                fractionDigits: 2,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Total Despesas"),
                            Card(
                              child: AnimatedDigitWidget(
                                textStyle: TextStyle(
                                    fontSize: Util.getSidePadding(context,
                                        val: responsiveFlag ==
                                                ResponsiveFlags.width
                                            ? 0.1
                                            : 0.04),
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.color),
                                duration: 1250.ms,
                                value: totalOrders,
                                suffix: "€",
                                fractionDigits: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(Util.getSidePadding(context)),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(columns: [
                          for (var vapeId in sales.map((e) => e.vapeId).toSet())
                            DataColumn(
                                label: Center(
                              child: Image.asset(
                                  "assets/images/${sales.firstWhere((e) => e.vapeId == vapeId).vapeImage}",
                                  width: Util.getResponsiveValue(
                                      responsiveFlag, context, 50),
                                  height: Util.getResponsiveValue(
                                      responsiveFlag, context, 50)),
                            )),
                        ], rows: [
                          DataRow(cells: [
                            for (var vapeId
                                in sales.map((e) => e.vapeId).toSet())
                              DataCell(
                                Center(
                                  child: Text(
                                      "${sales.where((element) => element.vapeId == vapeId).map((e) => e.total).fold<double>(0, (previousValue, element) => element + previousValue)}€ (${sales.where((element) => element.vapeId == vapeId).map((e) => e.quantity!).fold<double>(0, (previousValue, element) => element + previousValue)} Un.)"),
                                ),
                              )
                          ])
                        ]),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
