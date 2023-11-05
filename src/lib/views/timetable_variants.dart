import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/timetable_variant.dart';
import '../viewmodels/variants.dart';

class VariantWidget extends StatelessWidget {
  final TimetableVariant variant;
  final Color foreground;
  final Color background;
  final Color foreground2;
  final VariantsViewModel viewmodel;

  const VariantWidget({
    super.key,
    required this.variant,
    required this.viewmodel,
    this.background = const Color(0xff292727),
    this.foreground = const Color(0xff1BD30B),
    this.foreground2 = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: background,
        ),
        child: MaterialButton(
          onPressed: () {},
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      variant.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: foreground,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      color: foreground2,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_horiz, color: foreground2),
                    ),
                    IconButton(
                      onPressed: () =>
                          viewmodel.deleteVariant(name: variant.name),
                      icon: const Icon(Icons.delete, color: Color(0xff770505)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimetableVariants extends StatelessWidget {
  const TimetableVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff171616),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(color: const Color.fromARGB(50, 0, 100, 100)),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.transparent,
                child: Consumer<VariantsViewModel>(
                  builder: (ctx, vm, _) => ListView.builder(
                    itemCount: vm.variants.length,
                    itemBuilder: (ctx, index) => VariantWidget(
                      variant: vm.variants[index],
                      viewmodel: vm,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(color: const Color.fromARGB(50, 0, 100, 100)),
            ),
          ],
        ),
      ),
    );
  }
}
