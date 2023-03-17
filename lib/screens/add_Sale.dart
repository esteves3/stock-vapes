import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stock_vapes/screens/home.dart';
import 'package:stock_vapes/utils/configs.dart';
import 'package:stock_vapes/utils/native.dart';
import 'package:stock_vapes/utils/repository.dart';
import 'package:stock_vapes/utils/utils.dart';

class AddSale extends StatefulWidget {
  final int id;
  final String name, type;
  final Map<String, dynamic>? selectedVape;
  const AddSale(
      {super.key,
      required this.id,
      required this.name,
      required this.type,
      this.selectedVape});

  @override
  State<AddSale> createState() => _AddSaleState();
}

class _AddSaleState extends State<AddSale> {
  var saleQuantity = 1;
  var unitPrice = MoneyMaskedTextController(rightSymbol: '€', initialValue: 12);
  var saleNotes = "";
  bool isLoadingSaleSave = false;
  @override
  Widget build(BuildContext context) {
    return widget.selectedVape == null
        ? Container()
        : LayoutBuilder(builder: (_, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const AutoSizeText(
                      "Marcar venda",
                      maxFontSize: 35,
                      maxLines: 1,
                      style: TextStyle(fontSize: 100),
                    ),
                    Padding(
                        padding: EdgeInsets.all(
                            Util.getSidePadding(context, val: 0.01))),
                    AutoSizeText(
                      "Total: ${(unitPrice.numberValue * saleQuantity).toString()}€",
                      maxFontSize: 15,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 100),
                    )
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth >
                              MediaQuery.of(context).size.height
                          ? constraints.maxWidth / 8
                          : constraints.maxWidth,
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            saleQuantity = value != '' ? int.parse(value) : 0;
                          });
                        },
                        initialValue: saleQuantity.toString(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(
                              '[0-${(widget.selectedVape!["stock"] > 9 ? 9 : widget.selectedVape!["stock"])}]')),
                          FilteringTextInputFormatter.digitsOnly,
                          LimitRangeTextInputFormatter(
                              1, widget.selectedVape!["stock"])
                        ],
                        decoration:
                            const InputDecoration(labelText: "Quantidade"),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth >
                              MediaQuery.of(context).size.height
                          ? constraints.maxWidth / 6
                          : constraints.maxWidth,
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {});
                        },
                        controller: unitPrice,
                        decoration:
                            const InputDecoration(labelText: "Preço Unid."),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth >
                              MediaQuery.of(context).size.height
                          ? constraints.maxWidth / 4
                          : constraints.maxWidth,
                      child: TextFormField(
                        onChanged: (value) {
                          saleNotes = value;
                        },
                        decoration: const InputDecoration(labelText: "Notas"),
                      ),
                    ),
                    if (constraints.maxWidth >
                        MediaQuery.of(context).size.height)
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10)),
                    SizedBox(
                      width: constraints.maxWidth >
                              MediaQuery.of(context).size.height
                          ? constraints.maxWidth / 6
                          : constraints.maxWidth,
                      child: ElevatedButton(
                        onPressed: () {
                          addSale(false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: isLoadingSaleSave
                              ? const CircularProgressIndicator.adaptive()
                              : const Icon(CupertinoIcons.arrow_right),
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    SizedBox(
                      width: constraints.maxWidth >
                              MediaQuery.of(context).size.height
                          ? constraints.maxWidth / 8
                          : constraints.maxWidth,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 255, 114, 79))),
                        onPressed: () {
                          addSale(true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: isLoadingSaleSave
                              ? const CircularProgressIndicator.adaptive()
                              : const Icon(FontAwesomeIcons.box),
                        ),
                      ),
                    )
                  ],
                ).animate().moveY(begin: 16),
              ],
            ).animate().fadeIn(duration: 600.ms).moveY();
          });
  }

  void addSale(bool isReservation) async {
    if (isLoadingSaleSave) return;
    if (saleQuantity == 0 &&
        widget.selectedVape!["stock"] - saleQuantity >= 0) {
      return;
    }
    setState(() {
      isLoadingSaleSave = true;
    });
    var data = {
      "vape_id": widget.selectedVape!["id"],
      "vape_flavor": widget.selectedVape!["flavor"],
      "vape_image": widget.selectedVape!["image"],
      "vape_new_stock": widget.selectedVape!["stock"] - saleQuantity,
      "user_id": widget.id,
      "user_name": widget.name,
      "quantity": saleQuantity,
      "unit_price": unitPrice.numberValue,
      "notes": saleNotes,
      "dt_cri": DateTime.now(),
    };
    if (isReservation) {
      data.addAll({"state": null});
    }
    await repositoryBase
        .collection(isReservation ? "reservations" : "sales")
        .add(data);

    await Repository.updateStock(widget.selectedVape!["id"], saleQuantity);

    // ignore: use_build_context_synchronously
    Native.goToPageReplacement(
        context, Home(name: widget.name, type: widget.type, id: widget.id));
  }
}
