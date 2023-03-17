import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:getwidget/components/accordion/gf_accordion.dart';
import 'package:stock_vapes/screens/home.dart';
import 'package:stock_vapes/utils/configs.dart';
import 'package:stock_vapes/utils/constants.dart';
import 'package:stock_vapes/utils/extensions.dart';
import 'package:stock_vapes/utils/native.dart';
import 'package:stock_vapes/utils/utils.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  var orders = repositoryBase
      .collection("orders")
      .orderBy("dt_cri", descending: true)
      .get();
  var products = repositoryBase.collection("products").get();

  var addOrder = false;
  @override
  Widget build(BuildContext context) {
    ResponsiveFlags responsiveFlag =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? ResponsiveFlags.height
            : ResponsiveFlags.width;
    return Scaffold(
      appBar: isWeb ? null : AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Util.getSidePadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    addOrder = !addOrder;
                  });
                },
                child: Row(
                  children: [
                    Icon(addOrder
                        ? CupertinoIcons.list_bullet
                        : CupertinoIcons.add),
                    AutoSizeText(
                      addOrder
                          ? "Listagem de encomendas"
                          : "Adicionar encomenda",
                      maxFontSize: 25,
                      style: const TextStyle(fontSize: 100),
                    ),
                  ],
                ),
              ),
              addOrder
                  ? AddOrder(
                      products: products,
                    ).animate().fadeIn(duration: 550.ms)
                  : FutureBuilder(
                      future: orders,
                      builder: (_, orderSnapshot) {
                        if (!orderSnapshot.hasData) {
                          return const CircularProgressIndicator.adaptive();
                        }
                        return Column(
                          children: [
                            for (var el in orderSnapshot.data!.docs)
                              GFAccordion(
                                collapsedTitleBackgroundColor:
                                    Theme.of(context).primaryColor,
                                expandedTitleBackgroundColor:
                                    Theme.of(context).primaryColor,
                                contentBackgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                collapsedIcon:
                                    const Icon(CupertinoIcons.chevron_down),
                                expandedIcon:
                                    const Icon(CupertinoIcons.chevron_up),
                                titleChild: Row(
                                  textBaseline: TextBaseline.alphabetic,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  children: [
                                    AutoSizeText(
                                      (el.data()["dt_cri"] as Timestamp)
                                          .toDate()
                                          .format(),
                                      maxFontSize: 35,
                                      style: const TextStyle(fontSize: 100),
                                    ),
                                    const Padding(padding: EdgeInsets.all(8)),
                                    AutoSizeText(
                                      "Total: ${el.data()["total"]}€",
                                      maxFontSize: 25,
                                      style: const TextStyle(fontSize: 100),
                                    ),
                                  ],
                                ),
                                contentChild: DataTable(columns: const [
                                  DataColumn(label: Text("")),
                                  DataColumn(label: Text("Produto")),
                                  DataColumn(label: Text("Quantidade"))
                                ], rows: [
                                  for (var detail in el.data()["details"])
                                    DataRow(cells: [
                                      DataCell(
                                        Image.asset(
                                          "assets/images/${detail['image']}",
                                          width: Util.getResponsiveValue(
                                              responsiveFlag, context, 50),
                                          height: Util.getResponsiveValue(
                                              responsiveFlag, context, 50),
                                        ),
                                      ),
                                      DataCell(Text(detail["flavor"])),
                                      DataCell(
                                          Text(detail["stock"].toString())),
                                    ])
                                ]),
                              ),
                          ],
                        ).animate().fadeIn(duration: 600.ms);
                      }),
            ],
          ),
        ),
      ),
    );
  }
}

class AddOrder extends StatefulWidget {
  final Future<QuerySnapshot<Map<String, dynamic>>> products;
  const AddOrder({super.key, required this.products});

  @override
  State<AddOrder> createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  var orderLst = [];
  var orderTotal = 0.0;
  @override
  Widget build(BuildContext context) {
    ResponsiveFlags responsiveFlag =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? ResponsiveFlags.height
            : ResponsiveFlags.width;
    return FutureBuilder(
        future: widget.products,
        builder: (_, prodSnapshot) {
          if (!prodSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          orderLst = orderLst.isEmpty
              ? prodSnapshot.data!.docs.map((e) {
                  var tmp = e.data();
                  tmp.addAll({'stock': 0, 'product': e.reference});
                  return tmp;
                }).toList()
              : orderLst;
          return LayoutBuilder(builder: (context, constraints) {
            return Wrap(
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  child: Center(
                    child: AutoSizeText(
                      "Quantidade encomenda: ${orderLst.map((e) => e["stock"] as int).toList().reduce((value, element) => value + element)}",
                      maxFontSize: 30,
                      style: const TextStyle(fontSize: double.infinity),
                    ),
                  ),
                ),
                for (var el in orderLst)
                  InkWell(
                    onTap: () async {
                      var qt = 0;
                      var res = await Native.showNativeDialog(
                          context,
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/${el['image']}",
                                width: Util.getResponsiveValue(
                                    responsiveFlag, context, 30),
                                height: Util.getResponsiveValue(
                                    responsiveFlag, context, 30),
                              ),
                              Text(el["flavor"])
                            ],
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Quantidade",
                            ),
                            autofocus: true,
                            onChanged: (value) => qt = int.parse(value),
                          ),
                          "Cancelar",
                          "Guardar");
                      if (res) {
                        setState(() {
                          el["stock"] = qt;
                        });
                      }
                    },
                    child: SizedBox(
                      width: constraints.maxWidth >
                              MediaQuery.of(context).size.height
                          ? constraints.maxWidth / 3
                          : constraints.maxWidth,
                      child: Card(
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/${el['image']}",
                              width: Util.getResponsiveValue(
                                  responsiveFlag, context, 100),
                              height: Util.getResponsiveValue(
                                  responsiveFlag, context, 100),
                            ),
                            AutoSizeText(
                              el["flavor"],
                              maxFontSize: 25,
                              style: const TextStyle(fontSize: double.infinity),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(),
                            ),
                            AutoSizeText(
                              el["stock"].toString(),
                              maxFontSize: 35,
                              style: const TextStyle(fontSize: double.infinity),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding:
                      EdgeInsets.all(Util.getSidePadding(context, val: 0.01)),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Total €",
                    ),
                    onChanged: (value) => orderTotal = double.parse(value),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: Util.getSidePadding(context, val: 0.01)),
                    child: SizedBox(
                      width: responsiveFlag == ResponsiveFlags.height
                          ? constraints.maxWidth / 4
                          : constraints.maxWidth,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (orderLst.isEmpty || orderTotal == 0) return;
                            repositoryBase.collection("orders").add({
                              'total': orderTotal,
                              'dt_cri': DateTime.now(),
                              'details': orderLst
                            });

                            for (var el in orderLst) {
                              if (el["stock"] == 0) {
                                continue;
                              }

                              var stockById = await repositoryBase
                                  .collection("stock")
                                  .where("id", isEqualTo: el["id"])
                                  .get();

                              if (stockById.docs.isNotEmpty) {
                                var currentStock = stockById.docs[0];

                                await currentStock.reference.update({
                                  "stock":
                                      currentStock.data()["stock"] + el["stock"]
                                });
                              } else {
                                await repositoryBase
                                    .collection("stock")
                                    .add(el);
                              }
                            }
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => Home(
                                          name: sharedPreferences!
                                              .getString("name")
                                              .toString(),
                                          type: sharedPreferences!
                                              .getString("type")
                                              .toString(),
                                          id: sharedPreferences!.getInt("id")!,
                                        )));
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: AutoSizeText(
                              "Guardar Encomenda",
                              maxFontSize: 20,
                              style: TextStyle(
                                  fontSize: double.infinity,
                                  color: Colors.white),
                            ),
                          )),
                    ),
                  ),
                )
              ],
            ).animate().fadeIn(duration: 600.ms);
          });
        });
  }
}
