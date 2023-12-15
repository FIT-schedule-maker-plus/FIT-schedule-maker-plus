/*
 * Filename: generator.dart
 * Project: FIT-schedule-maker-plus
 * Author: Matúš Moravčík (xmorav48)
 * Date: 15/12/2023
 * Description: This file defines an overlay view that contains interface for timetable generation.
 */

import 'package:fit_schedule_maker_plus/models/course_lesson.dart';
import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/viewmodels/timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Generator extends StatelessWidget {
  final AnimationController animationController;
  final Animation<Offset> ofssetAnimation;

  Generator({required this.animationController, required this.ofssetAnimation, super.key});

  // filters for timetable generation
  final TextEditingController _textEditingControllerLessons = TextEditingController(text: "0");
  final TextEditingController _textEditingControllerPractices = TextEditingController(text: "0");
  final List<DayOfWeek> freeDaysSelected = [];

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: ofssetAnimation,
      child: Container(
        width: 315,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.9),
              offset: const Offset(10.0, 5.0), // Shadow on the left side
              blurRadius: 6.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => animationController.reverse(),
                  icon: const Icon(Icons.keyboard_arrow_right),
                  color: Colors.white,
                  tooltip: "Hide",
                ),
                const Expanded(
                  child: Text(
                    "Generátor rozvrhu",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white, indent: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 16, top: 20, bottom: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text("Max počet hodin na den: ", style: TextStyle(color: Colors.white, fontSize: 16))),
                          NumberPicker(_textEditingControllerLessons),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Expanded(child: Text("Max počet cvičení na den: ", style: TextStyle(color: Colors.white, fontSize: 16))),
                          NumberPicker(_textEditingControllerPractices),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text("Dny volna: ", style: TextStyle(color: Colors.white, fontSize: 16)),
                      DaySelector(freeDaysSelected),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<AppViewModel>().generateTimetable(
                    int.parse(_textEditingControllerLessons.text), int.parse(_textEditingControllerPractices.text), freeDaysSelected, context.read<TimetableViewModel>());
                animationController.reverse();
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 30),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.white, blurRadius: 3)]),
                  child: const Text("Vygenerovat", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DaySelector extends StatefulWidget {
  final List<DayOfWeek> selected;
  const DaySelector(this.selected, {super.key});

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  int idOfHoveredDay = -1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) => buildDay(DayOfWeek.values[index])),
    );
  }

  Widget buildDay(DayOfWeek dayOfWeek) {
    return InkWell(
      onTap: () {
        if (widget.selected.contains(dayOfWeek)) {
          widget.selected.remove(dayOfWeek);
        } else {
          widget.selected.add(dayOfWeek);
        }
        setState(() {});
      },
      child: MouseRegion(
        onEnter: (value) => setState(() {
          idOfHoveredDay = dayOfWeek.index;
        }),
        onExit: (value) => setState(() {
          idOfHoveredDay = -1;
        }),
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.selected.contains(dayOfWeek)
                ? const Color.fromARGB(255, 45, 2, 2)
                : idOfHoveredDay == dayOfWeek.index
                    ? const Color.fromARGB(10, 255, 255, 255)
                    : const Color.fromARGB(0, 255, 255, 255),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            dayOfWeek.toCzechString(),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class NumberPicker extends StatefulWidget {
  final TextEditingController _textEditingController;
  const NumberPicker(this._textEditingController, {super.key});

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  void changeText(int diff) {
    int? textValue = int.tryParse(widget._textEditingController.text);
    if (textValue == null) {
      widget._textEditingController.text = "0";
    } else {
      widget._textEditingController.text = (int.parse(widget._textEditingController.text) + diff).clamp(0, 15).toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Row(
        children: [
          buildButton(Icons.remove, () => changeText(-1), const Color.fromARGB(255, 136, 82, 82)),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(hintText: null, counterText: "", border: InputBorder.none),
              textAlign: TextAlign.center,
              maxLength: 2,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              controller: widget._textEditingController,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
              onChanged: (value) {
                int? intValue = int.tryParse(value);
                if (intValue != null) {
                  widget._textEditingController.value = widget._textEditingController.value.copyWith(
                    text: intValue.clamp(0, 15).toString(),
                    selection: const TextSelection.collapsed(offset: 2),
                  );
                }
              },
            ),
          ),
          buildButton(Icons.add, () => changeText(1), const Color.fromARGB(255, 88, 124, 75)),
        ],
      ),
    );
  }

  Widget buildButton(IconData icon, void Function() onPressed, Color color) {
    return GestureDetector(
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(2.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(11, 255, 255, 255),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
