import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_vapes/screens/home.dart';
import 'package:stock_vapes/utils/configs.dart';
import 'package:stock_vapes/utils/constants.dart';
import 'package:stock_vapes/utils/extensions.dart';
import 'package:stock_vapes/utils/native.dart';
import 'package:stock_vapes/utils/repository.dart';
import 'package:stock_vapes/utils/utils.dart';

class SalesReservations extends StatefulWidget {
  final int id;
  final String name, type;
  final Map<String, dynamic>? selectedVape;
  const SalesReservations(
      {super.key,
      required this.selectedVape,
      required this.id,
      required this.name,
      required this.type});

  @override
  State<SalesReservations> createState() => _SalesReservationsState();
}

class _SalesReservationsState extends State<SalesReservations> {
  int segmentControlValue = 1;
  var getSales = repositoryBase
      .collection("sales")
      .orderBy("dt_cri", descending: true)
      .limit(5)
      .get();
  var getReservations = repositoryBase
      .collection("reservations")
      .where("state", isNull: true)
      .orderBy("dt_cri", descending: true)
      .get();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> salesLst = [];
  var salesTotalCount = 0;

  var productFilter = "";
  var sellerFilter = "";

  @override
  void initState() {
    repositoryBase
        .collection("sales")
        .count()
        .get()
        .then((value) => salesTotalCount = value.count);
    getSales.then((value) => salesLst = value.docs);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveFlags responsiveFlag =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? ResponsiveFlags.height
            : ResponsiveFlags.width;
    return LayoutBuilder(builder: (_, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.selectedVape == null && widget.type == "admin")
            CupertinoSegmentedControl<int>(
              unselectedColor: Theme.of(context).scaffoldBackgroundColor,
              children: const {
                0: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Vendas"),
                ),
                1: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Reservas"),
                ),
              },
              onValueChanged: (val) {
                setState(() {
                  segmentControlValue = val;
                });
              },
              groupValue: segmentControlValue,
            ),
          if (widget.selectedVape == null && segmentControlValue == 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(columns: const [
                      DataColumn(label: Text("")),
                      DataColumn(label: Text("Produto")),
                      DataColumn(label: Text("Vendedor")),
                      DataColumn(label: Text("Total venda")),
                      DataColumn(label: Text("Quantidade")),
                      DataColumn(label: Text("Preço Unid.")),
                      DataColumn(label: Text("Notas")),
                      DataColumn(label: Text("Data")),
                    ], rows: [
                      for (var el in salesLst)
                        if ((productFilter.isEmpty ||
                                el.data()["vape_id"].toString() ==
                                    productFilter) &&
                            (sellerFilter.isEmpty ||
                                el.data()["user_id"].toString() ==
                                    sellerFilter))
                          DataRow(cells: [
                            DataCell(
                                Image.asset(
                                  "assets/images/${el.data()['vape_image']}",
                                  width: Util.getResponsiveValue(
                                      responsiveFlag, context, 50),
                                  height: Util.getResponsiveValue(
                                      responsiveFlag, context, 50),
                                ), onTap: () {
                              setState(() {
                                productFilter = productFilter.isEmpty
                                    ? el.data()["vape_id"].toString()
                                    : "";
                              });
                            }),
                            DataCell(Text(el.data()["vape_flavor"]), onTap: () {
                              setState(() {
                                productFilter = productFilter.isEmpty
                                    ? el.data()["vape_id"].toString()
                                    : "";
                              });
                            }),
                            DataCell(Text(el.data()["user_name"]), onTap: () {
                              setState(() {
                                sellerFilter = sellerFilter.isEmpty
                                    ? el.data()["user_id"].toString()
                                    : "";
                              });
                            }),
                            DataCell(
                              Text(
                                  "${(el.data()["quantity"] * el.data()["unit_price"]).toString()}€"),
                            ),
                            DataCell(
                              Text(
                                  "${el.data()["quantity"].toString()} (Restante: ${el.data()["vape_new_stock"].toString()})"),
                            ),
                            DataCell(
                              Text("${el.data()["unit_price"].toString()}€"),
                            ),
                            DataCell(
                              Text(el.data()["notes"] ?? " - "),
                            ),
                            DataCell(
                              Text((el.data()["dt_cri"] as Timestamp)
                                  .toDate()
                                  .format(pattern: "dd/MM/yyyy HH:mm")),
                            ),
                          ])
                    ]),
                  ),
                  salesTotalCount == salesLst.length
                      ? Container()
                      : Center(
                          child: ElevatedButton(
                              onPressed: () {
                                repositoryBase
                                    .collection("sales")
                                    .orderBy("dt_cri", descending: true)
                                    .startAfterDocument(salesLst.last)
                                    .limit(5)
                                    .get()
                                    .then((value) {
                                  setState(() {
                                    salesLst.addAll(value.docs);
                                  });
                                });
                              },
                              child: const Text("Carregar mais")),
                        ),
                ],
              ),
            ),
          if (widget.selectedVape == null && segmentControlValue == 1)
            FutureBuilder(
                future: getReservations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      !snapshot.hasData) {
                    return Container();
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Text("Sem reservas feitas!");
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(columns: const [
                      DataColumn(label: Text("")),
                      DataColumn(label: Text("Produto")),
                      DataColumn(label: Text("Vendedor")),
                      DataColumn(label: Text("Total venda")),
                      DataColumn(label: Text("Quantidade")),
                      DataColumn(label: Text("Preço Unid.")),
                      DataColumn(label: Text("Notas")),
                      DataColumn(label: Text("Data")),
                      DataColumn(label: Text("")),
                    ], rows: [
                      for (var el in snapshot.data!.docs)
                        DataRow(cells: [
                          DataCell(
                            Image.asset(
                              "assets/images/${el.data()['vape_image']}",
                              width: Util.getResponsiveValue(
                                  responsiveFlag, context, 50),
                              height: Util.getResponsiveValue(
                                  responsiveFlag, context, 50),
                            ),
                          ),
                          DataCell(
                            Text(el.data()["vape_flavor"]),
                          ),
                          DataCell(
                            Text(el.data()["user_name"]),
                          ),
                          DataCell(
                            Text(
                                "${(el.data()["quantity"] * el.data()["unit_price"]).toString()}€"),
                          ),
                          DataCell(
                            Text(
                                "${el.data()["quantity"].toString()} (Restante: ${el.data()["vape_new_stock"].toString()})"),
                          ),
                          DataCell(
                            Text("${el.data()["unit_price"].toString()}€"),
                          ),
                          DataCell(
                            Text(el.data()["notes"] ?? " - "),
                          ),
                          DataCell(
                            Text((el.data()["dt_cri"] as Timestamp)
                                .toDate()
                                .format(pattern: "dd/MM/yyyy HH:mm")),
                          ),
                          DataCell(widget.id != el.data()["user_id"]
                              ? Container()
                              : Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        HapticFeedback.heavyImpact();
                                        var data = el.data();
                                        data.addAll({
                                          "dt_reservation": data["dt_cri"],
                                          "dt_cri": DateTime.now()
                                        });
                                        data.remove("state");
                                        await repositoryBase
                                            .collection("sales")
                                            .add(data);
                                        await el.reference.set(
                                            {"state": "sold"},
                                            SetOptions(merge: true));
                                        // ignore: use_build_context_synchronously
                                        Native.goToPageReplacement(
                                            context,
                                            Home(
                                                name: widget.name,
                                                type: widget.type,
                                                id: widget.id));
                                      },
                                      child: const Icon(
                                          CupertinoIcons.money_dollar),
                                    ),
                                    const Padding(padding: EdgeInsets.all(2)),
                                    ElevatedButton(
                                      onPressed: () async {
                                        HapticFeedback.heavyImpact();
                                        await Repository.updateStock(
                                            el.data()["vape_id"],
                                            -el.data()["quantity"]);
                                        await el.reference.set(
                                            {"state": "deleted"},
                                            SetOptions(merge: true));
                                        // ignore: use_build_context_synchronously
                                        Native.goToPageReplacement(
                                            context,
                                            Home(
                                                name: widget.name,
                                                type: widget.type,
                                                id: widget.id));
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red)),
                                      child: const Icon(CupertinoIcons.xmark),
                                    )
                                  ],
                                )),
                        ])
                    ]),
                  );
                }),
        ],
      );
    });
  }
}
