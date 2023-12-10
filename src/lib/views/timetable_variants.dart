import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/timetable.dart';

enum VariantMenuItem { export, delete }

class VariantWidget extends StatelessWidget {
  final Color foreground;
  final Color background;
  final Color foreground2;
  final Color colClose;
  final Color colConfirm;
  final int index;

  const VariantWidget({
    super.key,
    required this.index,
    this.background = const Color(0xff292727),
    this.foreground = const Color(0xff1BD30B),
    this.foreground2 = Colors.white,
    this.colClose = const Color(0xff770505),
    this.colConfirm = const Color(0xff00ff00),
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
                child: buildVariantOptions(context),
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

  Row buildVariantOptions(BuildContext context) {
    final vm = context.watch<TimetableViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
          ),
          child: const Text('Zvolit'),
          onPressed: () => vm.setActive(index: index),
        ),
        PopupMenuButton<VariantMenuItem>(
          onSelected: (item) {},
          itemBuilder: (context) => <PopupMenuEntry<VariantMenuItem>>[
            const PopupMenuItem<VariantMenuItem>(
              value: VariantMenuItem.export,
              child: Text('Exportovat'),
            ),
            PopupMenuItem<VariantMenuItem>(
              onTap: () => vm.removeTimetable(index: index),
              value: VariantMenuItem.delete,
              child: const Row(
                children: <Widget>[
                  Expanded(child: Text('Vymazat')),
                  Icon(Icons.delete, color: Color(0xff770505)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildVariantName() {
    return Consumer<TimetableViewModel>(
      builder: (ctx, vm, _) => Row(
        children: [
          if (vm.isEditingName(index: index))
            Expanded(
              child: TextField(
                  controller: TextEditingController()
                    ..text = vm.timetables[index].name,
                  onChanged: (newText) {
                    vm.updateEditingName(index, newText);
                  },
                  style: const TextStyle(color: Color(0xffffffff))),
            ),
          if (!vm.isEditingName(index: index))
            Text(
              vm.timetables[index].name,
              style: TextStyle(
                fontSize: 16,
                color: index == vm.active
                    ? foreground
                    : const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          if (vm.isEditingName(index: index))
            Row(
              children: [
                IconButton(
                  onPressed: () => vm.saveEditingName(index),
                  icon: const Icon(Icons.check),
                  color: colConfirm,
                ),
                IconButton(
                  onPressed: () =>
                      vm.setEditingName(index: index, value: false),
                  icon: const Icon(Icons.close),
                  color: colClose,
                ),
              ],
            ),
          if (!vm.isEditingName(index: index))
            IconButton(
              onPressed: () {
                vm.setEditingName(index: index, value: true);
              },
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
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 20.0),
          constraints: const BoxConstraints(
            minWidth: 200,
            maxWidth: 1000,
          ),
          child: Column(
            children: [
              Container(
                color: Colors.transparent,
                child: Selector<TimetableViewModel, int>(
                  selector: (ctx, vm) => vm.timetables.length,
                  builder: (ctx, length, _) => ListView.builder(
                    shrinkWrap: true,
                    itemCount: length,
                    itemBuilder: (ctx, i) => VariantWidget(index: i),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () {
                    context.read<TimetableViewModel>().createNewTimetable();
                  },
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff292727),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
