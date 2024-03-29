/*
 * Filename: timetable_variants.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub (xkloub03)
 * Date: 15/12/2023
 * Description: This file represents the content of the 'Verze rozvrhu' tab. It outlines the
 *    view for different timetable versions, providing users with the capability to create,
 *    delete, and modify timetable versions. Additionally, users can export these versions
 *    to JSON or PNG formats.
 */
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../disp_timetable_gen.dart';
import '../models/program_course_group.dart';
import '../models/timetable.dart';
import '../viewmodels/app.dart';
import '../viewmodels/timetable.dart';
import '../views/timetable_container.dart' as view;
import 'homepage.dart' as view;

enum ExportMenuItem { exportPNG, exportJSON }

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
          borderRadius: BorderRadius.circular(13),
          color: background,
        ),
        child: ExpansionTile(
          shape: const OutlineInputBorder(borderSide: BorderSide.none),
          title: Row(
            children: <Widget>[
              Expanded(child: buildVariantName()),
              Expanded(child: buildVariantOptions(context)),
            ],
          ),
          children: <Widget>[
            SizedBox(
              height: 600,
              child: Selector<TimetableViewModel, Timetable>(
                selector: (ctx, vm) => vm.timetables[index],
                builder: (ctx, tim, _) {
                  return view.Timetable(
                    filter: Filter.all(),
                    timetable: tim,
                    readOnly: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row buildVariantOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Selector<TimetableViewModel, Semester>(
          selector: (context, vm) => vm.timetables[index].semester,
          builder: (context, sem, _) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Switch(
                activeThumbImage: const AssetImage("images/snowflake.png"),
                activeTrackColor: const Color.fromARGB(255, 91, 221, 252),
                inactiveTrackColor: const Color.fromARGB(255, 249, 249, 107),
                inactiveThumbColor: Colors.white,
                inactiveThumbImage: const AssetImage("images/sun.png"),
                value: sem == Semester.winter,
                onChanged: (value) {
                  Semester semester = value ? Semester.winter : Semester.summer;
                  final tvm = context.read<TimetableViewModel>();
                  tvm.changeSemester(semester, index: index);
                  if (index == tvm.active) {
                    context.read<AppViewModel>().changeSemester(semester);
                  }
                },
              ),
            );
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
          ),
          child: const Text('Zvolit'),
          onPressed: () => context.read<TimetableViewModel>().setActive(index: index),
        ),
        PopupMenuButton<ExportMenuItem>(
          onSelected: (item) {},
          icon: Icon(Icons.download, color: foreground2),
          color: background,
          itemBuilder: (context) => <PopupMenuEntry<ExportMenuItem>>[
            PopupMenuItem<ExportMenuItem>(
              value: ExportMenuItem.exportPNG,
              child: Text("PNG", style: TextStyle(color: foreground2)),
              onTap: () {
                context.read<TimetableViewModel>().saveAsPng(index: index);
              },
            ),
            PopupMenuItem<ExportMenuItem>(
              value: ExportMenuItem.exportJSON,
              child: Text("JSON", style: TextStyle(color: foreground2)),
              onTap: () {
                context.read<TimetableViewModel>().saveAsJson(
                      index: index,
                      avm: context.read<AppViewModel>(),
                    );
              },
            ),
          ],
        ),
        ConfirmDeleteButton(variantIndex: index),
      ],
    );
  }

  Widget buildVariantName() {
    bool isHovered = false;
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Consumer<TimetableViewModel>(
        builder: (ctx, vm, _) => Row(
          children: [
            if (vm.isEditingName(index: index))
              Expanded(
                child: TextField(
                    controller: TextEditingController()..text = vm.timetables[index].name,
                    onChanged: (newText) => vm.updateEditingName(index, newText),
                    focusNode: FocusNode()..requestFocus(),
                    style: const TextStyle(color: Color(0xffffffff))),
              ),
            if (!vm.isEditingName(index: index))
              Text(
                vm.timetables[index].name,
                style: TextStyle(
                  fontSize: 16,
                  color: index == vm.active ? foreground : const Color.fromARGB(255, 255, 255, 255),
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
                    onPressed: () => vm.setEditingName(index: index, value: false),
                    icon: const Icon(Icons.close),
                    color: colClose,
                  ),
                ],
              ),
            if (!vm.isEditingName(index: index))
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: StatefulBuilder(builder: (_, setState) {
                  return InkWell(
                    onHover: (val) => setState(() => isHovered = val),
                    onTap: () => vm.setEditingName(index: index, value: true),
                    child: Icon(
                      Icons.edit,
                      color: isHovered ? Colors.blue : foreground2,
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}

class TimetableVariants extends StatelessWidget {
  const TimetableVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xff171616),
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 20.0),
              constraints: BoxConstraints(
                minWidth: 0,
                maxWidth: max(700, MediaQuery.of(context).size.width * 0.7),
              ),
              child: Column(
                children: [
                  Container(
                    color: Colors.transparent,
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 150),
                    child: Selector<TimetableViewModel, int>(
                      selector: (ctx, vm) => vm.timetables.length,
                      builder: (ctx, length, _) => SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: length,
                          itemBuilder: (ctx, i) => VariantWidget(index: i),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 20),
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
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: view.BlackButton(
            onTap: () {
              context.read<TimetableViewModel>().loadFromJson(context.read<AppViewModel>());
            },
            child: const Text(
              "Import",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class ConfirmDeleteButton extends StatefulWidget {
  final int variantIndex;
  const ConfirmDeleteButton({
    super.key,
    required this.variantIndex,
  });

  @override
  State<ConfirmDeleteButton> createState() => _ConfirmDeleteButtonState();
}

class _ConfirmDeleteButtonState extends State<ConfirmDeleteButton> {
  bool isEnabled = false;

  @override
  void initState() {
    super.initState();
    isEnabled = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return IconButton(
        icon: const Icon(Icons.delete_sharp),
        color: const Color(0xff770505 + 0x00222222),
        onPressed: () {
          setState(() {
            isEnabled = !isEnabled;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                isEnabled = false;
              });
            }
          });
        },
      );
    } else {
      return IconButton(
          icon: const Icon(Icons.check),
          color: const Color(0xff00ff00),
          onPressed: () {
            context.read<TimetableViewModel>().removeTimetable(index: widget.variantIndex);
            isEnabled = false;
          });
    }
  }
}
