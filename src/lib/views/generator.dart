// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:fit_schedule_maker_plus/models/course_lesson.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Generator extends StatelessWidget {
  final AnimationController animationController;
  final Animation<Offset> ofssetAnimation;

  Generator({required this.animationController, required this.ofssetAnimation, super.key});

  final TextEditingController _textEditingControllerLessons = TextEditingController(text: "0");
  final TextEditingController _textEditingControllerPractices = TextEditingController(text: "0");
  final List<DayOfWeek> selected = [];

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
              offset: Offset(10.0, 5.0), // Shadow on the left side
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
                  icon: Icon(Icons.keyboard_arrow_right),
                  color: Colors.white,
                  tooltip: "Hide",
                ),
                Expanded(
                  child: Text(
                    "Generátor rozvrhu",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.white, indent: 15),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0, left: 16, top: 20, bottom: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text("Max počet hodin na den: ", style: TextStyle(color: Colors.white, fontSize: 16))),
                          NumberPicker(_textEditingControllerLessons),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Text("Max počet cvičení na den: ", style: TextStyle(color: Colors.white, fontSize: 16))),
                          NumberPicker(_textEditingControllerPractices),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text("Vyučovací dny: ", style: TextStyle(color: Colors.white, fontSize: 16)),
                      DayPicker(selected),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                animationController.reverse();
              },
              child: Text(
                "Vygenerovat",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DayPicker extends StatefulWidget {
  final List<DayOfWeek> selected;
  const DayPicker(this.selected, {super.key});

  @override
  State<DayPicker> createState() => _DayPickerState();
}

class _DayPickerState extends State<DayPicker> {
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
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: widget.selected.contains(dayOfWeek) ? const Color.fromARGB(18, 255, 255, 255) : Color.fromARGB(6, 255, 255, 255),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          dayOfWeek.toCzechString(),
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
          buildButton(Icons.remove, () => changeText(-1), Color.fromARGB(255, 136, 82, 82)),
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: null, counterText: "", border: InputBorder.none),
              textAlign: TextAlign.center,
              maxLength: 2,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              controller: widget._textEditingController,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
              onChanged: (value) {
                int? intValue = int.tryParse(value);
                if (intValue != null) {
                  widget._textEditingController.value = widget._textEditingController.value.copyWith(
                    text: intValue.clamp(0, 15).toString(),
                    selection: TextSelection.collapsed(offset: 2),
                  );
                }
              },
            ),
          ),
          buildButton(Icons.add, () => changeText(1), Color.fromARGB(255, 88, 124, 75)),
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
          padding: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(11, 255, 255, 255),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
