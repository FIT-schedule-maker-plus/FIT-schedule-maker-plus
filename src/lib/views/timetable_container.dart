/*
 * Filename: timetable_container.dart
 * Project: FIT-schedule-maker-plus
 * Author: Matúš Moravčík (xmorav48)
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file defines the view of timetable, its lessons and overlay for that shows lesson infos. Its a content of the 'Pracovní rozvrh' tab.
 */

import 'dart:async';
import 'dart:math';
import 'package:fit_schedule_maker_plus/models/faculty.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../disp_timetable_gen.dart';
import '../models/course.dart';
import '../models/course_lesson.dart';
import '../models/timetable.dart' as model;
import '../viewmodels/timetable.dart';
import '../viewmodels/app.dart';

const appBarCol = Color.fromARGB(255, 52, 52, 52);
const timetableVerticalLinesColor = Color.fromARGB(255, 83, 83, 83);
const lessonHeight = 100;
const overlayColor = Color.fromARGB(255, 220, 220, 220);
const double overlayWidth = 220;
const double overlayHeight = 250;
double daysBarWidth = 35;

class TimetableContainer extends StatelessWidget {
  const TimetableContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appBarCol,
      child: Column(
        children: [
          const Courses(),
          const SizedBox(height: 40),
          Selector<TimetableViewModel, Filter>(
              selector: (_, vm) => Filter.courses(vm.filter.courses),
              builder: (context, filter, _) {
                return Expanded(
                  child: Timetable(filter: filter),
                );
              })
        ],
      ),
    );
  }
}

// Le Duy Nguyen
class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  bool isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    final allCourses = context.select((AppViewModel vm) => vm.allCourses);
    final courseIDs = context.select((TimetableViewModel tvm) => tvm.currentTimetable.currentContent.keys.toList());
    isCollapsed = courseIDs.isEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isCollapsed
          ? Container(key: const ValueKey(1))
          : Container(
              key: const ValueKey(2),
              width: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [appBarCol, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0.0, 10.0),
                      blurRadius: 15.0,
                      spreadRadius: 10.0,
                    )
                  ]),
              child: isCollapsed
                  ? null
                  : Column(
                      children: [
                        const SizedBox(height: 17),
                        const Center(
                          child: Text(
                            'Vybrané predmety',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          alignment: Alignment.center,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 60, // to apply margin in the main axis of the wrap
                            runSpacing: 10, // to apply margin in the cross axis of the wrap
                            children: courseIDs.map((courseId) => buildCourseWidget(allCourses[courseId]!, context)).toList(),
                          ),
                        ),
                        const SizedBox(height: 17),
                      ],
                    ),
            ),
    );
  }

  Widget buildCourseWidget(Course course, BuildContext context) {
    bool isHiden = false;

    return Container(
      width: 180,
      height: 30,
      decoration: ShapeDecoration(
        color: const Color(0xFF1BD30B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          StatefulBuilder(builder: (ctx, setState) {
            return Tooltip(
              waitDuration: const Duration(milliseconds: 500),
              message: "Skrýt",
              child: IconButton(
                onPressed: () {
                  final tvm = ctx.read<TimetableViewModel>();
                  if (isHiden) {
                    tvm.removeCourseFromFilter(course.id);
                  } else {
                    tvm.addCourseToFilter(course.id);
                  }
                  setState(() => isHiden = !isHiden);
                },
                padding: EdgeInsets.zero,
                color: Colors.white,
                icon: Icon(isHiden ? Icons.visibility_off : Icons.visibility),
              ),
            );
          }),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                course.shortcut,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Tooltip(
            waitDuration: const Duration(milliseconds: 500),
            message: "Vymazat",
            child: IconButton(
              onPressed: () => context.read<TimetableViewModel>().removeCourse(course.id),
              padding: EdgeInsets.zero,
              color: Colors.white,
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}

// Matúš Moravčík
class Timetable extends StatelessWidget {
  /// Timetable to display explicitly. This is useful when we want to display a timetable
  /// from some variant. When this is null, then we display current timetable.
  final model.Timetable? timetable;
  final Filter filter;
  final bool readOnly;
  const Timetable({super.key, this.timetable, required this.filter, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    AppViewModel appViewModel = context.read<AppViewModel>();
    final courseIds = context.select((TimetableViewModel tvm) => tvm.currentTimetable.currentContent.keys.toList());
    bool areAllLessonsFetched = courseIds.every((courseId) => appViewModel.isCourseLessonFetched(courseId));

    return areAllLessonsFetched
        ? buildTimetable(context)
        : FutureBuilder(
            future: appViewModel.getAllCourseLessonsAsync(courseIds),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return buildTimetable(context);
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            });
  }

  Widget buildTimetable(BuildContext context) {
    AppViewModel appViewModel = context.read<AppViewModel>();
    TimetableViewModel timetableViewModel = context.read<TimetableViewModel>();
    final generatedData = timetable == null ? genDispTimetable(appViewModel, timetableViewModel, filter) : genDispTimetableSpecific(appViewModel, timetable!, filter);

    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
      width: double.infinity,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double oneLessonWidth = constraints.maxWidth / 15;
          daysBarWidth = oneLessonWidth / 2;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTimeBar(),
              const Divider(thickness: 2, height: 2, color: Colors.black),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Stack(
                        children: [
                          Column(
                            children: [
                              buildWeekDay(DayOfWeek.values[index], oneLessonWidth - 1, generatedData[DayOfWeek.values[index]]!.first),
                              const Divider(thickness: 2, height: 2, color: Colors.black),
                            ],
                          ),
                          ...generatedData[DayOfWeek.values[index]]!
                              .second
                              .map((specLes) => Lesson(readOnly, appViewModel.allCourses[specLes.courseID]!, specLes, oneLessonWidth, generatedData))
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTimeBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: List.generate(
          15,
          (index) => Expanded(
            child: Text(
              '${index + 7}:00',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildWeekDay(DayOfWeek dayOfWeek, double lessonWidth, int maxHeight) {
    return SizedBox(
      height: lessonHeight * (maxHeight + 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: daysBarWidth - 0.5, // There was always overflow by 0.5 pixels due to floating point arithmetic
            child: Text(dayOfWeek.toCzechString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
          ),
          Padding(
            padding: EdgeInsets.only(right: lessonWidth / 2),
            child: const VerticalDivider(thickness: 1, width: 1, color: timetableVerticalLinesColor),
          ),
          ...List.generate(
            14,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: lessonWidth / 2),
              child: const VerticalDivider(thickness: 1, width: 1, color: timetableVerticalLinesColor),
            ),
          ),
        ],
      ),
    );
  }
}

// Le Duy Nguyen
class Lesson extends StatefulWidget {
  final bool readOnly;
  final Course course;
  final SpecificLesson specLes;
  final double oneLessonWidth;
  final Map<DayOfWeek, Pair<int, List<SpecificLesson>>> genData;

  const Lesson(this.readOnly, this.course, this.specLes, this.oneLessonWidth, this.genData, {super.key});

  @override
  State<Lesson> createState() => _LessonState();
}

class _LessonState extends State<Lesson> {
  Timer? _timer;
  bool entryHasFocus = false;
  OverlayEntry? entry;
  Offset? overlayTriggerPosition;
  Offset? overlayPosition;

  String? locations;
  String? profesors;

  @override
  void dispose() {
    entry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonId = widget.specLes.lessonID;
    final lessonLevel = widget.specLes.height;
    const int leftOffset = 5;
    CourseLesson lesson = widget.course.lessons[lessonId];
    TimetableViewModel timetableViewModel = context.watch<TimetableViewModel>();
    Size screenSize = MediaQuery.of(context).size;

    Color color = switch (lesson.type) {
      LessonType.lecture => const Color.fromARGB(255, 22, 106, 30),
      LessonType.seminar => const Color(0xFF21A2A2),
      LessonType.exercise => const Color.fromARGB(255, 21, 69, 88),
      LessonType.computerLab => const Color.fromARGB(255, 89, 3, 3),
      LessonType.laboratory => const Color.fromARGB(255, 111, 92, 24),
    };

    locations = lesson.infos.map((info) => info.locations).expand((loc) => loc).toSet().join(', ');
    profesors = lesson.infos.map((info) => info.info).toSet().join(", ");

    color = color
        .withRed(max(0, color.red - (0x60 * 299 / 1000).round()))
        .withGreen(max(0, color.green - (0x60 * 587 / 1000).round()))
        .withBlue(max(0, color.blue - (0x60 * 114 / 1000).round()));

    if (!widget.specLes.selected) {
      color = color.withAlpha(50);
    }

    final hourIndex = (lesson.startsFrom / 60) - 7; // Timetable starts from 7:00
    return Positioned(
      left: leftOffset + daysBarWidth + hourIndex * widget.oneLessonWidth,
      top: lessonHeight * lessonLevel + 5,
      child: InkWell(
        onTap: () {
          if (widget.readOnly) return;
          if (widget.specLes.selected) {
            deselectLesson(timetableViewModel, widget.specLes);
          } else {
            final lessons = context.read<AppViewModel>().allCourses[widget.course.id]!.lessons;
            final selectedLessons = timetableViewModel.currentTimetable.currentContent[widget.course.id];

            if (selectedLessons == null || selectedLessons.isNotEmpty) {
              int id = selectedLessons!.firstWhere((id) => lessons[id].type == lesson.type, orElse: () => -1);
              if (id != -1) {
                var x = widget.genData.values
                    .expand((element) => element.second)
                    .where((element) => element.courseID == widget.course.id)
                    .firstWhere((element) => element.lessonID == id);
                x.selected = false;
                timetableViewModel.currentTimetable.removeLesson(widget.course.id, id);
              }
            }

            selectLesson(timetableViewModel, widget.specLes);
          }
        },
        child: widget.readOnly
            ? buildLesson(lesson, color)
            : MouseRegion(
                onExit: (details) async {
                  _timer?.cancel();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (!entryHasFocus) {
                      hideOverlay();
                    }
                  });
                },
                onHover: (details) {
                  if (entry != null) {
                    Timer(const Duration(milliseconds: 100), () {
                      if (!entryHasFocus) {
                        hideOverlay();
                      }
                    });
                  } else {
                    _timer?.cancel();
                    _timer = Timer(const Duration(milliseconds: 600), () {
                      overlayPosition = details.position;
                      overlayTriggerPosition = details.position;
                      if (details.position.dx + overlayWidth > screenSize.width) {
                        overlayPosition = overlayPosition!.translate(-overlayWidth, 0);
                      }
                      if (details.position.dy + overlayHeight > screenSize.height) {
                        overlayPosition = overlayPosition!.translate(0, -overlayHeight);
                      }
                      if (mounted) {
                        showOverlay(widget.course, lesson);
                        entry!.markNeedsBuild();
                      }
                    });
                  }
                },
                child: buildLesson(lesson, color),
              ),
      ),
    );
  }

  Container buildLesson(CourseLesson lesson, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      width: (lesson.endsAt - lesson.startsFrom) / 60 * widget.oneLessonWidth,
      decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1),
            borderRadius: BorderRadius.circular(10.0),
          )),
      height: 90,
      alignment: Alignment.center,
      child: Column(children: [
        Text(
          widget.course.shortcut,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          profesors!,
          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, fontWeight: FontWeight.w100, color: Color(0xFFC6C4C4)),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        buildRooms(context, lesson.infos.map((v) => v.locations).expand((v) => v).toSet()),
        // Text(
        //   locations!,
        //   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
        //   overflow: TextOverflow.ellipsis,
        // )
      ]),
    );
  }

  void hideOverlay() {
    if (entry != null) {
      entry!.remove();
      entry = null;
    }
  }

  void showOverlay(Course course, CourseLesson lesson) {
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: overlayPosition!.dy,
        left: overlayPosition!.dx,
        child: MouseRegion(
          onEnter: (event) => entryHasFocus = true,
          onExit: (event) {
            hideOverlay();
            entryHasFocus = false;
          },
          child: buildOverlay(course, lesson),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  Widget buildOverlay(Course course, CourseLesson lesson) {
    const overlayBorderRadius = Radius.circular(10);
    const overlayZeroRadius = Radius.zero;
    BorderRadiusGeometry? borders;

    // the border where the mouse is pointing should be sharp, the other are rounded
    if (overlayPosition == overlayTriggerPosition) {
      borders = const BorderRadius.only(topRight: overlayBorderRadius, bottomLeft: overlayBorderRadius, bottomRight: overlayBorderRadius, topLeft: overlayZeroRadius);
    } else if (overlayPosition!.translate(overlayWidth, 0) == overlayTriggerPosition) {
      borders = const BorderRadius.only(topRight: overlayZeroRadius, bottomLeft: overlayBorderRadius, bottomRight: overlayBorderRadius, topLeft: overlayBorderRadius);
    } else if (overlayPosition!.translate(0, overlayHeight) == overlayTriggerPosition) {
      borders = const BorderRadius.only(topRight: overlayBorderRadius, bottomLeft: overlayZeroRadius, bottomRight: overlayBorderRadius, topLeft: overlayBorderRadius);
    } else {
      borders = const BorderRadius.only(topRight: overlayBorderRadius, bottomLeft: overlayBorderRadius, bottomRight: overlayZeroRadius, topLeft: overlayBorderRadius);
    }

    List<Widget> infos = lesson.infos
        .map((info) {
          return <Widget>[
            buildInfo("Vyučujíci: ", info.info),
            const SizedBox(height: 15),
            buildInfo("Místnosti: ", info.locations.join(", ")),
            const SizedBox(height: 15),
            const Text(
              "Vyučující týdny: ",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w200,
                color: Color.fromARGB(255, 100, 100, 100),
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                info.weeks,
                softWrap: true,
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const Divider(color: Colors.black)
          ];
        })
        .expand((i) => i)
        .toList();

    /// Remove last `Divider`
    infos.removeLast();

    return Container(
        width: overlayWidth,
        height: overlayHeight,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: overlayColor,
          borderRadius: borders,
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: overlayColor,
            )
          ],
        ),
        child: Column(children: [
          Center(
            child: Text(
              course.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black, decoration: TextDecoration.none),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
              child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: infos),
          ))
        ]));
  }

  Widget buildRooms(BuildContext ctx, Set<String> rooms) {
    List<Widget> widgets = [];
    Map<Faculty, List<String>> locations = {};
    List<String> unknownLocations = [];

    AppViewModel appViewModel = context.read<AppViewModel>();

    for (final room in rooms) {
      final faculty = appViewModel.getRoomLocation(room);
      if (faculty == null) {
        unknownLocations.add(room);
        continue;
      }

      locations.putIfAbsent(faculty, () => []);
      locations[faculty]!.add(room);
    }

    for (final entry in locations.entries) {
      final facultyName = switch (entry.key) {
        Faculty.fit => "FIT",
        Faculty.fekt => "FEKT",
        Faculty.cesa => "CESA",
        Faculty.cvis => "CVIS",
        Faculty.fa => "FA",
        Faculty.fast => "FAST",
        Faculty.favu => "FaVU",
        Faculty.fch => "FCH",
        Faculty.fp => "FP",
        Faculty.fsi => "FSI",
        Faculty.icv => "ICV",
        Faculty.re => "RE",
        Faculty.usi => "ÚSI",
      };

      final facultyColor = switch (entry.key) {
        Faculty.fit => Color(0xFF00a9e0),
        Faculty.fekt => Color(0xFF003da5),
        Faculty.cesa => Color(0xFF009db1),
        Faculty.cvis => Color(0xFF898d8d),
        Faculty.fa => Color(0xFF7a99ac),
        Faculty.fast => Color(0xFF658d1b),
        Faculty.favu => Color(0xFFe782a9),
        Faculty.fch => Color(0xFF00ab8e),
        Faculty.fp => Color(0xFF8246af),
        Faculty.fsi => Color(0xFF004f71),
        Faculty.usi => Color(0xFF211447),
        Faculty.icv || Faculty.re => Color(0xFFe4002b), // Don't know... Use the VUT one
      };

      widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: facultyColor,
            ),
            height: 19,
            child: Text(facultyName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ))),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              entry.value.join(", "),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
              // overflow: TextOverflow.ellipsis,
            ))
      ]));
    }
    widgets.add(Text(
      unknownLocations.join(", "),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
    ));

    return Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: widgets)));
  }

  Row buildInfo(String infoType, String infoValue) {
    return Row(
      children: [
        Text(infoType, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w200, color: Color.fromARGB(255, 100, 100, 100), decoration: TextDecoration.none)),
        Expanded(
          child: Text(
            infoValue,
            softWrap: true,
            overflow: TextOverflow.clip,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black, decoration: TextDecoration.none),
          ),
        ),
      ],
    );
  }
}
