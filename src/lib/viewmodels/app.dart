import 'package:fit_schedule_maker_plus/models/course.dart';
import 'package:fit_schedule_maker_plus/models/course_lesson.dart';
import 'package:fit_schedule_maker_plus/models/study.dart';
import 'package:fit_schedule_maker_plus/models/program_course_group.dart';
import 'package:fit_schedule_maker_plus/models/program_course.dart';
// import 'package:fit_schedule_maker_plus/constants.dart';
import 'package:flutter/material.dart';
import 'package:chaleno/chaleno.dart';

import '../models/timetable.dart';

class AppViewModel extends ChangeNotifier {
  /// Stores all courses loaded from disk or from web.
  Map<int, Course> allCourses = {};
  Map<int, StudyProgram> allStudyPrograms = {};
  int grade = 1;
  String year = "2023/24";
  bool isWinterTerm = true;
  int currentStudyProgram = 15803;

  /// Load stored timetables from disk
  List<Timetable> getTimetables() {
    return [
      Timetable(name: "Ver. 1", selected: {}),
      Timetable(name: "Ver. 2", selected: {}),
      Timetable(name: "Ver. 3", selected: {}),
    ];
  }

  /// https://www.fit.vut.cz/study/study-plan/.en
  /// TODO Fetch from the site instead of hardcoding them
  Future<void> getAllStudyProgram() async {
    var studyPrograms = [
      StudyProgram(id: 15803, shortcut: "BIT", courseGroups: [], fullName: "Information Technology"),

      // MITAI
      StudyProgram(id: 15994, shortcut: "NADE", courseGroups: [], fullName: "Application Development"),
      StudyProgram(id: 15990, shortcut: "NBIO", courseGroups: [], fullName: "Bioinformatics and Biocomputing"),
      StudyProgram(id: 15993, shortcut: "NGRI", courseGroups: [], fullName: "Computer Graphics and Interaction"),
      StudyProgram(id: 15984, shortcut: "NNET", courseGroups: [], fullName: "Computer Networks"),
      StudyProgram(id: 15992, shortcut: "NVIZ", courseGroups: [], fullName: "Computer Vision"),
      StudyProgram(id: 15999, shortcut: "NCPS", courseGroups: [], fullName: "Cyberphysical Systems"),
      StudyProgram(id: 15997, shortcut: "NSEC", courseGroups: [], fullName: "Cybersecurity"),
      StudyProgram(id: 15988, shortcut: "NEMB", courseGroups: [], fullName: "Embedded Systems"),
      StudyProgram(id: 16000, shortcut: "NHPC", courseGroups: [], fullName: "High Performance Computing"),
      StudyProgram(id: 15995, shortcut: "NISD", courseGroups: [], fullName: "Information Systems and Databases"),
      StudyProgram(id: 15987, shortcut: "NIDE", courseGroups: [], fullName: "Intelligent Devices"),
      StudyProgram(id: 16001, shortcut: "NISY", courseGroups: [], fullName: "Intelligent Systems"),
      StudyProgram(id: 15985, shortcut: "NMAL", courseGroups: [], fullName: "Machine Learning"),
      StudyProgram(id: 15996, shortcut: "NMAT", courseGroups: [], fullName: "Mathematical Methods"),
      StudyProgram(id: 15991, shortcut: "NSEN", courseGroups: [], fullName: "Software Engineering"),
      StudyProgram(id: 15986, shortcut: "NVER", courseGroups: [], fullName: "Software Verification and Testing"),
      StudyProgram(id: 15989, shortcut: "NSPE", courseGroups: [], fullName: "Sound, Speech and Natural Language Processing"),

      // IT-MGR-2
      StudyProgram(id: 15813, shortcut: "MBI", courseGroups: [], fullName: "Bioinformatics and Biocomputing"),
      StudyProgram(id: 15808, shortcut: "MPV", courseGroups: [], fullName: "Computer and Embedded Systems"),
      StudyProgram(id: 15811, shortcut: "MGM", courseGroups: [], fullName: "Computer Graphics and Multimedia"),
      StudyProgram(id: 15814, shortcut: "MSK", courseGroups: [], fullName: "Computer Networks and Communication"),
      StudyProgram(id: 15809, shortcut: "MIS", courseGroups: [], fullName: "Information Systems"),
      StudyProgram(id: 15807, shortcut: "MBS", courseGroups: [], fullName: "Information Technology Security"),
      StudyProgram(id: 15810, shortcut: "MIN", courseGroups: [], fullName: "Intelligent Systems"),
      StudyProgram(id: 15812, shortcut: "MMI", courseGroups: [], fullName: "Management and Information Technologies"),
      StudyProgram(id: 15815, shortcut: "MMM", courseGroups: [], fullName: "Mathematical Methods in Information Technology"),
    ];

    for (final program in studyPrograms) {
      allStudyPrograms[program.id] = program;
    }
  }

  /// https://www.fit.vut.cz/study/study-plan/{programId}/.en
  Future<void> getProgramCourses(int programId) async {
    if (allStudyPrograms.containsKey(programId)) {
      return;
    }

    final parser = await Chaleno().load("https://www.fit.vut.cz/study/study-plan/$programId/.en");
    if (parser == null) return;

    allStudyPrograms[programId]?.courseGroups = parser
        .querySelectorAll("div.table-responsive__holder:nth-child(1) table")
        .map(_parseCourseGroup)
        .where((value) => value != null)
        .map((value) => value!)
        .toList();
  }

  ProgramCourseGroup? _parseCourseGroup(element) {
    var caption = element.querySelector("caption")?.text;
    if (caption == null) return null;
    caption = caption.trimLeft();

    final semester = caption.contains("winter semester") ? Semester.winter : Semester.summer;
    final yearOfStudy = caption.startsWith("1st year") ? YearOfStudy.first
        : caption.startsWith("2nd year") ? YearOfStudy.second
        : caption.startsWith("3rd year") ? YearOfStudy.third
        : caption.startsWith("Any") ? YearOfStudy.any
        : null;

    if (yearOfStudy == null) return null;

    var courses = element
        .querySelectorAll("tr")!
        .map(_parseAndStoreCourse)
        .where((value) => value != null)
        .map((value) => value!)
        .toList();

    return ProgramCourseGroup(courses: courses, semester: semester, yearOfStudy: yearOfStudy);
  }

  ProgramCourse? _parseAndStoreCourse(courseElement) {
    final html = courseElement.html!;
    if (!html.contains("w15p")) return null;

    final nameElement = courseElement.querySelector("a");
    if (nameElement == null) return null;
    final courseIdString = nameElement.href?.split("/")[5];
    if (courseIdString == null) return null;
    final id = int.parse(courseIdString);

    final dutyText = html.split("class=\"w5p\">")[2].split("<")[0];
    final duty = dutyText.startsWith("CE") ? CourseDuty.compulsoryElective
        : dutyText == "C" ? CourseDuty.compulsory
        : dutyText == "E" ? CourseDuty.elective
        : dutyText == "R" ? CourseDuty.recommended
        : null;

    if (duty == null) return null;

    if (!allCourses.containsKey(id)) {
      final courseName = nameElement.text;
      final shortcut = html.split("class=\"w15p\">")[1].split("<")[0];

      if (courseName == null) return null;

      allCourses[id] = Course(
        id: id,
        shortcut: shortcut,
        fullName: courseName,
        lessons: [],
        loadedLessons: false
      );
    }

    return ProgramCourse(courseId: id, duty: duty);
  }


  /// https://www.fit.vut.cz/study/course/{course_id}/.en
  Future<void> getCourseLessions(int courseId) async {
    if (!allCourses.containsKey(courseId)) {
      // Unknown course
      return;
    }

    if (allCourses[courseId]!.loadedLessons) {
      // No need to do anything
      return;
    }

    final parser = await Chaleno().load("https://www.fit.vut.cz/study/course/$courseId/.en");
    if (parser == null) return;

    allCourses[courseId]!.lessons = parser
        .querySelectorAll("#schedule tbody tr")
        .map(_parseLesson)
        .where((value) => value != null)
        .map((value) => value!)
        .toList();

    allCourses[courseId]!.loadedLessons = true;
  }

  CourseLesson? _parseLesson(element) {
    RegExp exp = RegExp(r">(.*)</");
    final matches = exp.allMatches(element.html).map((e) => e[1]).toList();

    final type = switch (matches[1]) {
      "exercise" => LessonType.exercise,
      "lecture" => LessonType.lecture,
      "laboratory" => LessonType.laboratory,
      "seminar" => LessonType.seminar,
      "comp.lab" => LessonType.computerLab,
      _ => null
    };

    if (type == null) return null;

    final dayOfWeek = switch(matches[0]) {
      "<th>Mon" => DayOfWeek.monday,
      "<th>Tue" => DayOfWeek.tueday,
      "<th>Wed" => DayOfWeek.wednesday,
      "<th>Thu" => DayOfWeek.thursday,
      "<th>Fri" => DayOfWeek.friday,
      _ => null
    };

    if (dayOfWeek == null) return null;

    List<String> locations = [];
    int? startsFrom;
    int? endsAt;
    int? capacity;

    for (var i = 3; i < matches.length; i++) {
      final s = matches[i]!;
      if (s.startsWith("<td>")) {
        final chunks = s.split(">").map((v) => v.split("<")[0]).where((v) => v.isNotEmpty);
        startsFrom = parseTime(chunks.elementAt(0));
        endsAt = parseTime(chunks.elementAt(1));
        capacity = int.parse(chunks.elementAt(2));

        break;
      }

      locations.add(s);
    }

    if (startsFrom == null || endsAt == null || capacity == null) return null;

    final note = matches[2];
    final info = exp.firstMatch(matches.last!)![1];

    if (note == null || info == null) return null;

    return CourseLesson(
      dayOfWeek: dayOfWeek,
      type: type,
      locations: locations,
      note: note,
      info: info,
      startsFrom: startsFrom,
      endsAt: endsAt,
      capacity: capacity
    );
  }


  /// Changes the grade and notifies all listeners
  void changeGrade(int grade) {
    this.grade = grade;
    notifyListeners();
  }

  /// Changes the term to winter or summer and notifies all listeners
  void changeTerm(bool isWinterTerm) {
    this.isWinterTerm = isWinterTerm;
    notifyListeners();
  }

  /// Changes the year and notifies all listeners that the year has been changed
  void changeYear(String year) {
    this.year = year;
    notifyListeners();
  }

  /// Changes the stady and notifies all listeners
  void changeStudy(int programId) {
    currentStudyProgram = programId;
    getProgramCourses(programId);
    notifyListeners();
  }

  List<ProgramCourseGroup> getProgramCourseGroup() {
    if (!allStudyPrograms.containsKey(currentStudyProgram)) {
      getProgramCourses(currentStudyProgram);
    }

    final semester = isWinterTerm ? Semester.winter : Semester.summer;
    return allStudyPrograms[currentStudyProgram]!
        .courseGroups
        .where((group) => group.semester == semester)
        .toList();
  }

  /// Return indices of all courses that satisfy the following filters: year, term, study and [category]
  // List<int> filterCourses(Category category) {
  //   if (study != "BIT") return [];
  //   if (!isWinterTerm) return [30, 31, 32];

  //   switch (category) {
  //     case Category.compulsory:
  //       return List.generate(6, (index) => index + (grade + 1) * 6,
  //           growable: false);
  //     case Category.compulsoryOptional:
  //       return List.generate(4, (index) => index + ((grade + 1) * 2),
  //           growable: false);
  //     case Category.optional:
  //       return List.generate(5, (index) => 2 * index + (grade + 4),
  //           growable: false);
  //     default:
  //       return [];
  //   }
  // }
}

int parseTime(String str) {
  final chunks = str.split(":").map((v) => int.parse(v));
  return chunks.elementAt(0) * 60 + chunks.elementAt(1);
}

