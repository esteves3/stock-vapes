import 'package:flutter/widgets.dart';

class LayoutScrollView extends StatelessWidget {
  final Axis scrollDirection;
  final Widget child;
  const LayoutScrollView(
      {Key? key, required this.child, this.scrollDirection = Axis.vertical})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: scrollDirection,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraint.maxHeight),
          child: IntrinsicHeight(
            child: child,
          ),
        ),
      );
    });
  }
}
