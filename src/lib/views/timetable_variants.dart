import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/timetable_variant.dart';
import '../viewmodels/variants.dart';

enum VariantMenuItem { export, delete }

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
        child: ExpansionTile(
          title: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: buildVariantName(),
              ),
              Expanded(
                flex: 1,
                child: buildVariantOptions(),
              ),
            ],
          ),
          children: <Widget>[
            Container(
              height: 200,
              color: Colors.blue,
            )
          ],
        ),
      ),
    );
  }

  Row buildVariantOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<VariantMenuItem>(
          onSelected: (item) {},
          itemBuilder: (context) => <PopupMenuEntry<VariantMenuItem>>[
            const PopupMenuItem<VariantMenuItem>(
              value: VariantMenuItem.export,
              child: Text('Export'),
            ),
            PopupMenuItem<VariantMenuItem>(
              onTap: () {
                viewmodel.deleteVariant(name: variant.name);
              },
              value: VariantMenuItem.delete,
              child: const Row(
                children: <Widget>[
                  Expanded(child: Text('Delete')),
                  Icon(Icons.delete, color: Color(0xff770505)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row buildVariantName() {
    return Row(
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
    );
  }

  Flex buildVariantButtonContents() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        buildLeftContents(),
        buildRightContents(),
      ],
    );
  }

  Expanded buildRightContents() {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PopupMenuButton<VariantMenuItem>(
            onSelected: (item) {},
            itemBuilder: (context) => <PopupMenuEntry<VariantMenuItem>>[
              const PopupMenuItem<VariantMenuItem>(
                value: VariantMenuItem.export,
                child: Text('Export'),
              ),
              PopupMenuItem<VariantMenuItem>(
                onTap: () {
                  viewmodel.deleteVariant(name: variant.name);
                },
                value: VariantMenuItem.delete,
                child: const Row(
                  children: <Widget>[
                    Expanded(child: Text('Delete')),
                    Icon(Icons.delete, color: Color(0xff770505)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Expanded buildLeftContents() {
    return Expanded(
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 200,
              maxWidth: 1000,
            ),
            child: Expanded(
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
          ),
        ),
      ),
    );
  }
}
