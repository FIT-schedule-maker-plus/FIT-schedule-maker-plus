// ignore_for_file: prefer_const_constructors

/*
 * Filename: timetable_container.dart
 * Project: FIT-schedule-maker-plus
 * Author: Matúš Moravčík (xmorav48)
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file provides the implementation of the timetable view, including lessons and an overlay
 *              displaying lesson information. It serves as the content for the 'Pracovní rozvrh' tab.
 */
import 'dart:developer' as dev;
import 'dart:async';
import 'dart:math';
import 'package:fit_schedule_maker_plus/models/faculty.dart';
import 'package:fit_schedule_maker_plus/models/lesson.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../disp_timetable_gen.dart';
import '../models/course.dart';
import '../models/timetable.dart' as model;
import '../utils.dart';
import '../viewmodels/timetable.dart';
import '../viewmodels/app.dart';

const appBarCol = Color.fromARGB(255, 52, 52, 52);
const timetableVerticalLinesColor = Color.fromARGB(255, 83, 83, 83);
const lessonHeight = 100;
const overlayColor = Color.fromARGB(255, 220, 220, 220);
const double overlayWidth = 220;
const double overlayHeight = 250;
const double colorHorizontalPadding = 0.3;
const double gradientWidth = 0.02;
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
          Selector<TimetableViewModel, List<Course>>(
              selector: (_, vm) => vm.filter.courses.toList(),
              builder: (context, filteredCourses, _) {
                return Expanded(
                  child: Timetable(filter: Filter.courses(filteredCourses.toSet())),
                );
              })
        ],
      ),
    );
  }
}

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  bool isCollapsed = true;
  bool hideCourses = true;

  @override
  Widget build(BuildContext context) {
    final courses = context
        .select((TimetableViewModel tvm) => tvm.currentTimetable.currentContent.keys.toList());
    isCollapsed = courses.isEmpty;
    bool areAllLessonsFetched =
        courses.every((course) => context.read<AppViewModel>().isCourseLessonFetched(course.id));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isCollapsed
          ? Container(key: const ValueKey(1))
          : areAllLessonsFetched
              ? buildCourses(courses)
              : FutureBuilder(
                  future: context
                      .read<AppViewModel>()
                      .getAllCourseLessonsAsync(courses.map((course) => course.id).toList()),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        return buildCourses(courses);
                      default:
                        return buildCourses(courses);
                    }
                  },
                ),
    );
  }

  Widget buildCourses(List<Course> courses) {
    return Container(
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
      child: Column(
        children: [
          const SizedBox(height: 17),
          ExpansionTile(
            title: Text(
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
            childrenPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            shape: const OutlineInputBorder(borderSide: BorderSide.none),
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            initiallyExpanded: true,
            controlAffinity: ListTileControlAffinity.leading,
            maintainState: true,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                alignment: Alignment.center,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 60, // to apply margin in the main axis of the wrap
                  runSpacing: 10, // to apply margin in the cross axis of the wrap
                  children: courses.map((course) => buildCourseWidget(course, context)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCourseWidget(Course course, BuildContext context) {
    bool isHidden = context.read<TimetableViewModel>().filter.courses.contains(course);

    return Selector<TimetableViewModel, List<Lesson>>(
      selector: (context, vm) => vm.currentTimetable.currentContent[course]?.toList() ?? [],
      builder: (context, selectedLessons, _) {
        List<Color> lessonColors = [];

        Set<LessonType> lessonTypes = course.prerequisites
            .map((prerequisite) => prerequisite.type)
            .toSet()
            .difference(
                selectedLessons.map((lesson) => lesson.type).toSet()..add(LessonType.project));

        for (var type in lessonTypes) {
          lessonColors.add(getLessonColor(type));
          lessonColors.add(getLessonColor(type));
        }

        double step = (1 - colorHorizontalPadding) / lessonTypes.length;

        List<double> stops = List.generate(
          lessonTypes.length,
          (index) => [
            colorHorizontalPadding / 2 + index * step + gradientWidth,
            colorHorizontalPadding / 2 + (index + 1) * step - gradientWidth
          ],
        ).expand((element) => element).toList();

        return Container(
          width: 180,
          height: 30,
          decoration: BoxDecoration(
            color: lessonColors.isEmpty ? Colors.transparent : null,
            gradient: lessonColors.isNotEmpty
                ? LinearGradient(
                    colors: lessonColors,
                    stops: stops,
                    transform: GradientRotation(pi / 4),
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
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
                      if (isHidden) {
                        tvm.removeCourseFromFilter(course);
                      } else {
                        tvm.addCourseToFilter(course);
                      }
                      setState(() => isHidden = !isHidden);
                    },
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                    icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
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
                  onPressed: () => context.read<TimetableViewModel>().removeCourse(course),
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
    final courses = context
        .select((TimetableViewModel tvm) => tvm.currentTimetable.currentContent.keys.toList());
    bool areAllLessonsFetched =
        courses.every((course) => appViewModel.isCourseLessonFetched(course.id));
    return areAllLessonsFetched
        ? buildTimetable(context)
        : FutureBuilder(
            future:
                appViewModel.getAllCourseLessonsAsync(courses.map((course) => course.id).toList()),
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
    final generatedData = timetable == null
        ? genDispTimetable(appViewModel, timetableViewModel, filter)
        : genDispTimetableSpecific(appViewModel, timetable!, filter);

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
                  restorationId: "timetableScrollPostition",
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      dev.log(generatedData[DayOfWeek.values[index]].toString());
                      return Stack(
                        children: [
                          Column(
                            children: [
                              buildWeekDay(DayOfWeek.values[index], oneLessonWidth - 1,
                                  generatedData[DayOfWeek.values[index]]!.first),
                              const Divider(thickness: 2, height: 2, color: Colors.black),
                            ],
                          ),
                          ...generatedData[DayOfWeek.values[index]]!.second.map((specLes) =>
                              LessonView(
                                  readOnly,
                                  appViewModel.allCourses[specLes.lesson.course.id]!,
                                  specLes,
                                  oneLessonWidth,
                                  generatedData))
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
            width: daysBarWidth -
                0.5, // There was always overflow by 0.5 pixels due to floating point arithmetic
            child: Text(dayOfWeek.toCzechString(),
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
          ),
          Padding(
            padding: EdgeInsets.only(right: lessonWidth / 2),
            child:
                const VerticalDivider(thickness: 1, width: 1, color: timetableVerticalLinesColor),
          ),
          ...List.generate(
            14,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: lessonWidth / 2),
              child:
                  const VerticalDivider(thickness: 1, width: 1, color: timetableVerticalLinesColor),
            ),
          ),
        ],
      ),
    );
  }
}

class LessonView extends StatefulWidget {
  final bool readOnly;
  final Course course;
  final SpecificLesson specLes;
  final double oneLessonWidth;
  final Map<DayOfWeek, Pair<int, List<SpecificLesson>>> genData;

  const LessonView(this.readOnly, this.course, this.specLes, this.oneLessonWidth, this.genData,
      {super.key});

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
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
    Lesson lesson = widget.specLes.lesson;
    final lessonLevel = widget.specLes.height;
    const int leftOffset = 5;
    TimetableViewModel timetableViewModel = context.watch<TimetableViewModel>();
    Size screenSize = MediaQuery.of(context).size;

    Color color = getLessonColor(lesson.type);

    locations = lesson.infos.map((info) => info.locations).expand((loc) => loc).toSet().join(', ');
    profesors = lesson.infos.map((info) => info.info).toSet().join(", ");

    color = color
        .withRed(max(0, color.red - (0x60 * 299 / 1000).round()))
        .withGreen(max(0, color.green - (0x60 * 587 / 1000).round()))
        .withBlue(max(0, color.blue - (0x60 * 114 / 1000).round()));

    if (!widget.specLes.selected) {
      color = color.withAlpha(60);
    }

    final hourIndex = (lesson.startsFrom / 60) - 7; // Timetable starts from 7:00
    return Positioned(
      left: leftOffset + daysBarWidth + hourIndex * widget.oneLessonWidth,
      top: lessonHeight * lessonLevel + 5,
      child: InkWell(
        onTap: () {
          if (widget.readOnly) return;
          _timer?.cancel();
          hideOverlay();
          if (widget.specLes.selected) {
            deselectLesson(timetableViewModel, widget.specLes);
          } else {
            final selectedLessons =
                timetableViewModel.currentTimetable.currentContent[widget.course.id];

            if (selectedLessons == null || selectedLessons.isNotEmpty) {
              Lesson? less = selectedLessons
                  ?.firstWhere((selectedLesson) => selectedLesson.type == lesson.type);

              if (less != null) {
                SpecificLesson specLess = widget.genData.values
                    .expand((element) => element.second)
                    .where((element) => element.lesson.course == widget.course)
                    .firstWhere((element) => element.lesson == less);

                specLess.selected = false;
                timetableViewModel.currentTimetable.removeLesson(less);
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

  Container buildLesson(Lesson lesson, Color color) {
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
          style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w100,
              color: Color(0xFFC6C4C4)),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        buildRooms(context, lesson.infos.map((v) => v.locations).expand((v) => v).toSet()),
      ]),
    );
  }

  void hideOverlay() {
    if (entry != null) {
      entry!.remove();
      entry = null;
    }
  }

  void showOverlay(Course course, Lesson lesson) {
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: overlayPosition!.dy + 1,
        left: overlayPosition!.dx + 1,
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

  Widget buildOverlay(Course course, Lesson lesson) {
    const overlayBorderRadius = Radius.circular(10);
    const overlayZeroRadius = Radius.zero;
    BorderRadiusGeometry? borders;

    // the border where the mouse is pointing should be sharp, the other are rounded
    if (overlayPosition == overlayTriggerPosition) {
      borders = const BorderRadius.only(
          topRight: overlayBorderRadius,
          bottomLeft: overlayBorderRadius,
          bottomRight: overlayBorderRadius,
          topLeft: overlayZeroRadius);
    } else if (overlayPosition!.translate(overlayWidth, 0) == overlayTriggerPosition) {
      borders = const BorderRadius.only(
          topRight: overlayZeroRadius,
          bottomLeft: overlayBorderRadius,
          bottomRight: overlayBorderRadius,
          topLeft: overlayBorderRadius);
    } else if (overlayPosition!.translate(0, overlayHeight) == overlayTriggerPosition) {
      borders = const BorderRadius.only(
          topRight: overlayBorderRadius,
          bottomLeft: overlayZeroRadius,
          bottomRight: overlayBorderRadius,
          topLeft: overlayBorderRadius);
    } else {
      borders = const BorderRadius.only(
          topRight: overlayBorderRadius,
          bottomLeft: overlayBorderRadius,
          bottomRight: overlayZeroRadius,
          topLeft: overlayBorderRadius);
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
      child: Column(
        children: [
          Center(
            child: Text(
              course.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.none),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfo("Typ vyučování: ", lesson.type.toCzechString()),
                  const SizedBox(height: 15),
                  ...infos,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildRooms(BuildContext ctx, Set<String> rooms) {
    Map<Faculty, List<String>> locations = {};
    List<String> unknownLocations = [];

    for (final room in rooms) {
      final faculty = context.read<AppViewModel>().getRoomLocation(room);
      if (faculty == null) {
        unknownLocations.add(room);
        continue;
      }

      locations.putIfAbsent(faculty, () => []);
      locations[faculty]!.add(room);
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: locations.entries
              .expand<Widget>(
                (entry) => [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Color(entry.key.getColorThemeInHex()),
                    ),
                    height: 19,
                    child: Text(
                      entry.key.getAcronym(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      entry.value.join(", "),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
                    ),
                  )
                ],
              )
              .toList()
            ..add(
              Text(
                unknownLocations.join(", "),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
              ),
            ),
        ),
      ),
    );
  }

  Row buildInfo(String infoType, String infoValue) {
    return Row(
      children: [
        Text(infoType,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w200,
                color: Color.fromARGB(255, 100, 100, 100),
                decoration: TextDecoration.none)),
        Expanded(
          child: Text(
            infoValue,
            softWrap: true,
            overflow: TextOverflow.clip,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                decoration: TextDecoration.none),
          ),
        ),
      ],
    );
  }
}
