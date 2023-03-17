import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stock_vapes/utils/constants.dart';
import 'package:stock_vapes/utils/utils.dart';

class VapeCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool screenshot;
  const VapeCard({
    super.key,
    required this.data,
    this.screenshot = false,
  });

  @override
  State<VapeCard> createState() => _VapeCardState();
}

class _VapeCardState extends State<VapeCard> {
  Future<DocumentSnapshot<Map<String, dynamic>>>? product;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveFlags responsiveFlag =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? ResponsiveFlags.height
            : ResponsiveFlags.width;

    return Opacity(
      opacity: widget.data["stock"] == 0 ? 0.3 : 1,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth > MediaQuery.of(context).size.height
              ? constraints.maxWidth / 3
              : constraints.maxWidth,
          child: Card(
            child: Row(
              children: [
                Image.asset(
                  "assets/images/${widget.data['image']}",
                  width: Util.getResponsiveValue(responsiveFlag, context, 100),
                  height: Util.getResponsiveValue(responsiveFlag, context, 100),
                ).animate().fadeIn(duration: 1000.ms).moveX(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      widget.data['flavor'],
                      maxLines: 1,
                      maxFontSize: 20,
                      style: const TextStyle(fontSize: 100),
                    ).animate().fadeIn(duration: 800.ms),
                    if (!widget.screenshot)
                      AutoSizeText(
                        "Stock Atual: ${widget.data['stock']}",
                        maxLines: 2,
                        maxFontSize: 16,
                        style: const TextStyle(fontSize: 100),
                      ).animate().fadeIn(duration: 1200.ms),
                  ],
                )
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).moveX(duration: 550.ms);
      }),
    );
  }
}
