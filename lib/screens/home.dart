import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stock_vapes/screens/add_Sale.dart';
import 'package:stock_vapes/utils/configs.dart';
import 'package:stock_vapes/utils/utils.dart';
import 'package:stock_vapes/widgets/sales_reservations.dart';
import 'package:stock_vapes/widgets/vape_card.dart';

class Home extends StatefulWidget {
  final String name, type;
  final int id;
  const Home(
      {super.key, required this.name, required this.type, required this.id});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic>? selectedVape;
  var stock = repositoryBase.collection("stock").get();
  var bytes = <Uint8List>[];
  var showShareButton = false;
  var vapeCardKey = GlobalKey();

  @override
  void initState() {
    stock.then((value) => SchedulerBinding.instance.addPostFrameCallback(
        ((timeStamp) => startScreenshotWork(context, value))));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isWeb ? null : AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 20,
              horizontal: MediaQuery.of(context).size.width / 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      "Olá ${widget.name}!",
                      maxFontSize: 50,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 100),
                    ).animate().fadeIn(duration: 1500.ms),
                  ),
                  if (widget.type == "admin")
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed("/backoffice");
                      },
                      child: const Icon(
                        CupertinoIcons.money_euro,
                        size: 30,
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                  if (selectedVape == null && showShareButton)
                    FutureBuilder(
                        future: stock,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container();
                          return InkWell(
                            onTap: () async {
                              final box =
                                  // ignore: use_build_context_synchronously
                                  context.findRenderObject() as RenderBox?;

                              Share.shareXFiles(
                                bytes
                                    .map(
                                      (e) => XFile.fromData(
                                        e,
                                        name: 'produtos.png',
                                        mimeType: 'image/png',
                                      ),
                                    )
                                    .toList(),
                                sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) & box.size,
                              );

                              try {
                                Directory dir = await getTemporaryDirectory();
                                dir.deleteSync(recursive: true);
                                dir.create();
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: const Icon(
                              CupertinoIcons.share,
                              size: 30,
                            ),
                          );
                        }),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                  if (widget.type == "admin")
                    InkWell(
                      onTap: () {
                        //Native.goToPage(context, const Orders());
                        Navigator.of(context).pushNamed("/orders");
                      },
                      child: const Icon(
                        CupertinoIcons.cube_box,
                        size: 30,
                      ),
                    ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(10)),
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: stock,
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }
                  return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: buildCardWrap(snapshot));
                },
              ),
              Padding(
                  padding:
                      EdgeInsets.all(Util.getSidePadding(context, val: 0.01))),
              //if (selectedVape != null)
              AddSale(
                  id: widget.id,
                  name: widget.name,
                  type: widget.type,
                  selectedVape: selectedVape),
              SalesReservations(
                id: widget.id,
                name: widget.name,
                type: widget.type,
                selectedVape: selectedVape,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> startScreenshotWork(BuildContext context,
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final controller = ScreenshotController();
    var currentScreen = MediaQuery.of(context).size;

    var maxCardPerPage =
        (currentScreen.height / vapeCardKey.currentContext!.size!.height)
            .floor();
    var pages = (snapshot.size / maxCardPerPage).ceil();

    for (var i = 0; i < pages; i++) {
      bytes.add(await controller.captureFromWidget(
          MediaQuery(
            data: MediaQuery.of(context),
            child: Theme(
              data: Theme.of(context),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    //direction: Axis.horizontal,
                    children: [
                      for (var j = 0;
                          j < maxCardPerPage &&
                              j + maxCardPerPage * i < snapshot.size;
                          j++)
                        VapeCard(
                          data: snapshot.docs[j + maxCardPerPage * i].data(),
                          screenshot: true,
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
          pixelRatio: MediaQuery.of(context).devicePixelRatio));
    }
    setState(() {
      showShareButton = true;
    });
  }

  Widget buildCardWrap(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    List<Widget> lst = [];
    vapeCardKey = GlobalKey();
    var used = false;
    for (var el in snapshot.data!.docs) {
      if (selectedVape == null || selectedVape!["id"] == el.data()["id"]) {
        lst.add(InkWell(
          onTap: el.data()["stock"] != 0
              ? () {
                  setState(() {
                    selectedVape = selectedVape == null ? el.data() : null;
                    /*saleQuantity = 0;
                    unitPrice = MoneyMaskedTextController(
                        rightSymbol: '€', initialValue: 12);*/
                  });
                }
              : null,
          child:
              VapeCard(key: used ? GlobalKey() : vapeCardKey, data: el.data()),
        ));
        used = true;
      }
    }

    return Wrap(
      direction: Axis.horizontal,
      children: lst,
    );
  }
}
