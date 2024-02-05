/*
 * Filename: app.dart
 * Project: FIT-schedule-maker-plus
 * Author: Le Duy Nguyen (xnguye27)
 * Author: Matúš Moravčík (xmorav48)
 * Date: 15/12/2023
 * Description: This file contains the view model that serves as the central
 *    component in the application's architecture, managing data related to courses, study programs,
 *    and timetables. It facilitates the fetching of information from the web.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:chaleno/chaleno.dart';

import '../models/course.dart';
import '../models/course_lesson.dart';
import '../models/course_prerequisite.dart';
import '../models/faculty.dart';
import '../models/lesson_info.dart';
import '../models/study.dart';
import '../models/program_course_group.dart';
import '../models/program_course.dart';
import '../models/timetable.dart';
import '../viewmodels/timetable.dart';

class AppViewModel extends ChangeNotifier {
  /// Stores all courses loaded from disk or from web.
  Map<int, Course> allCourses = {};

  Map<int, StudyProgram> allStudyPrograms = {};
  Map<String, Faculty> allLocations = {};
  YearOfStudy currentGrade = YearOfStudy.second;
  Semester currentSemester = Semester.winter;
  String currentYear = "2023/24";
  int currentStudyProgram = 15803; // BIT

  /// Load stored timetables from disk
  List<Timetable> get timetables => [
        Timetable(name: "Varianta A"),
        Timetable(name: "Varianta B"),
      ];

  /// Changes the grade and notifies all listeners
  void changeGrade(YearOfStudy grade) {
    currentGrade = grade;
    notifyListeners();
  }

  /// Changes the semester to winter or summer and notifies all listeners
  void changeSemester(Semester semester) {
    currentSemester = semester;
    notifyListeners();
  }

  /// Changes the year and notifies all listeners that the year has been changed
  void changeYear(String year) {
    currentYear = year;
    notifyListeners();
  }

  /// Changes the stady and notifies all listeners
  void changeStudy(int programId) {
    currentStudyProgram = programId;
    getProgramCourses(programId);
    notifyListeners();
  }

  // FIXME: Right now it only selects the first lesson of each type from each course
  /// Generates a timetable based on user defined constraints.
  void generateTimetable(int maxLessons, int maxPractices, List<DayOfWeek> selected, TimetableViewModel tvm) {
    for (var courseId in tvm.currentTimetable.currentContent.keys) {
      final lessons = allCourses[courseId]!.lessons;

      final lessonTypes = lessons.map((lesson) => lesson.type).toSet();
      tvm.currentTimetable.currentContent[courseId]?.clear();
      for (var type in lessonTypes) {
        final index = lessons.indexWhere((element) => element.type == type && !selected.contains(element.dayOfWeek));
        if (index > -1) {
          tvm.addLesson(courseId, index);
        }
      }
    }

    notifyListeners();
  }

  /// Fetch all study program avaiable on the web
  /// https://www.fit.vut.cz/study/study-plan/.en
  /// TODO Fetch from the site instead of hardcoding them
  Future<void> getAllStudyProgram() async {
    var studyPrograms = [
      StudyProgram(id: 15803, type: StudyType.bachelor, duration: 3, shortcut: "BIT", courseGroups: [], fullName: "Information Technology"),

      // MITAI
      StudyProgram(id: 15994, type: StudyType.magister, duration: 2, shortcut: "NADE", courseGroups: [], fullName: "Application Development"),
      StudyProgram(id: 15990, type: StudyType.magister, duration: 2, shortcut: "NBIO", courseGroups: [], fullName: "Bioinformatics and Biocomputing"),
      StudyProgram(id: 15993, type: StudyType.magister, duration: 2, shortcut: "NGRI", courseGroups: [], fullName: "Computer Graphics and Interaction"),
      StudyProgram(id: 15984, type: StudyType.magister, duration: 2, shortcut: "NNET", courseGroups: [], fullName: "Computer Networks"),
      StudyProgram(id: 15992, type: StudyType.magister, duration: 2, shortcut: "NVIZ", courseGroups: [], fullName: "Computer Vision"),
      StudyProgram(id: 15999, type: StudyType.magister, duration: 2, shortcut: "NCPS", courseGroups: [], fullName: "Cyberphysical Systems"),
      StudyProgram(id: 15997, type: StudyType.magister, duration: 2, shortcut: "NSEC", courseGroups: [], fullName: "Cybersecurity"),
      StudyProgram(id: 15988, type: StudyType.magister, duration: 2, shortcut: "NEMB", courseGroups: [], fullName: "Embedded Systems"),
      StudyProgram(id: 16000, type: StudyType.magister, duration: 2, shortcut: "NHPC", courseGroups: [], fullName: "High Performance Computing"),
      StudyProgram(id: 15995, type: StudyType.magister, duration: 2, shortcut: "NISD", courseGroups: [], fullName: "Information Systems and Databases"),
      StudyProgram(id: 15987, type: StudyType.magister, duration: 2, shortcut: "NIDE", courseGroups: [], fullName: "Intelligent Devices"),
      StudyProgram(id: 16001, type: StudyType.magister, duration: 2, shortcut: "NISY", courseGroups: [], fullName: "Intelligent Systems"),
      StudyProgram(id: 15985, type: StudyType.magister, duration: 2, shortcut: "NMAL", courseGroups: [], fullName: "Machine Learning"),
      StudyProgram(id: 15996, type: StudyType.magister, duration: 2, shortcut: "NMAT", courseGroups: [], fullName: "Mathematical Methods"),
      StudyProgram(id: 15991, type: StudyType.magister, duration: 2, shortcut: "NSEN", courseGroups: [], fullName: "Software Engineering"),
      StudyProgram(id: 15986, type: StudyType.magister, duration: 2, shortcut: "NVER", courseGroups: [], fullName: "Software Verification and Testing"),
      StudyProgram(id: 15989, type: StudyType.magister, duration: 2, shortcut: "NSPE", courseGroups: [], fullName: "Sound, Speech and Natural Language Processing"),

      // IT-MGR-2
      StudyProgram(id: 15813, type: StudyType.magister, duration: 2, shortcut: "MBI", courseGroups: [], fullName: "Bioinformatics and Biocomputing"),
      StudyProgram(id: 15808, type: StudyType.magister, duration: 2, shortcut: "MPV", courseGroups: [], fullName: "Computer and Embedded Systems"),
      StudyProgram(id: 15811, type: StudyType.magister, duration: 2, shortcut: "MGM", courseGroups: [], fullName: "Computer Graphics and Multimedia"),
      StudyProgram(id: 15814, type: StudyType.magister, duration: 2, shortcut: "MSK", courseGroups: [], fullName: "Computer Networks and Communication"),
      StudyProgram(id: 15809, type: StudyType.magister, duration: 2, shortcut: "MIS", courseGroups: [], fullName: "Information Systems"),
      StudyProgram(id: 15807, type: StudyType.magister, duration: 2, shortcut: "MBS", courseGroups: [], fullName: "Information Technology Security"),
      StudyProgram(id: 15810, type: StudyType.magister, duration: 2, shortcut: "MIN", courseGroups: [], fullName: "Intelligent Systems"),
      StudyProgram(id: 15812, type: StudyType.magister, duration: 2, shortcut: "MMI", courseGroups: [], fullName: "Management and Information Technologies"),
      StudyProgram(id: 15815, type: StudyType.magister, duration: 2, shortcut: "MMM", courseGroups: [], fullName: "Mathematical Methods in Information Technology"),
    ];

    for (final program in studyPrograms) {
      allStudyPrograms[program.id] = program;
    }
  }

  /// Load from `assets/locations.json` all lecture rooms and in which faculty their are located
  Future<void> getAllLocations(BuildContext context) async {
    String data = await DefaultAssetBundle.of(context).loadString("locations.json");
    final jsonResult = jsonDecode(data) as Map<String, dynamic>;
    allLocations = jsonResult.map((key, value) {
      final faculty = switch (value) {
        "FIT" => Faculty.fit,
        "FEKT" => Faculty.fekt,
        "CESA" => Faculty.cesa,
        "CVIS" => Faculty.cvis,
        "FA" => Faculty.fa,
        "FAST" => Faculty.fast,
        "FaVU" => Faculty.favu,
        "FCH" => Faculty.fch,
        "FP" => Faculty.fp,
        "FSI" => Faculty.fsi,
        "ICV" => Faculty.icv,
        "RE" => Faculty.re,
        "USI" => Faculty.usi,
        _ => Faculty.fekt,
      };

      return MapEntry(key, faculty);
    });
  }

  /// Retrieve all courses within the specified study program asynchronously.
  /// https://www.fit.vut.cz/study/study-plan/{programId}/.en
  /// Asynchronously fetches courses for a given study program if not already loaded.
  Future<void> getProgramCourses(int programId) async {
    if (allStudyPrograms.containsKey(programId)) {
      if (allStudyPrograms[programId]!.courseGroups.isNotEmpty) {
        return;
      }
    }

    final parser = await Chaleno().load("https://www.fit.vut.cz/study/study-plan/$programId/.en");
    if (parser == null) return;

    allStudyPrograms[programId]!.courseGroups =
        parser.querySelectorAll("div.table-responsive__holder:nth-child(1) table").map(_parseCourseGroup).where((value) => value != null).map((value) => value!).toList();
  }

  /// Helper function used in `getProgramCourses` function for parsing group of courses
  ProgramCourseGroup? _parseCourseGroup(Result element) {
    var caption = element.querySelector("caption")?.text;
    if (caption == null) return null;
    caption = caption.trimLeft().toLowerCase();

    final semester = caption.contains("winter semester")
        ? Semester.winter
        : caption.contains("summer semester")
            ? Semester.summer
            : null;

    final yearOfStudy =
        switch (caption.split("year")[0].trim()) { "1st" => YearOfStudy.first, "2nd" => YearOfStudy.second, "3rd" => YearOfStudy.third, "all" => YearOfStudy.all, _ => null };

    if (yearOfStudy == null || semester == null) return null;

    var courses = element.querySelectorAll("tr")!.map((res) => _parseAndStoreCourse(res, semester)).where((value) => value != null).map((value) => value!).toList();

    return ProgramCourseGroup(courses: courses, semester: semester, yearOfStudy: yearOfStudy);
  }

  /// Helper function used in `_parseCourseGroup` to parse and store course data
  ProgramCourse? _parseAndStoreCourse(Result courseElement, Semester semester) {
    final html = courseElement.html!;
    if (!html.contains("w15p")) return null;

    final nameElement = courseElement.querySelector("a");
    if (nameElement == null) return null;

    final courseIdString = nameElement.href?.split("/")[5];
    if (courseIdString == null) return null;

    final id = int.parse(courseIdString);

    /// the library has problem with `tr` `td` elements, that why parsing them manually here
    final dutyText = html.split("class=\"w5p\">")[2].split("<")[0];
    final duty = switch (dutyText) {
      "C" => CourseDuty.compulsory,
      "E" => CourseDuty.elective,
      "R" => CourseDuty.recommended,
      _ => dutyText.startsWith("CE") ? CourseDuty.compulsoryElective : null,
    };

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
        prerequisites: [],
        semester: semester,
      );
    }

    return ProgramCourse(courseId: id, duty: duty);
  }

  /// Get all data related to the course (prerequisites and lessons)
  /// Lessons that have same lecture time will be merged into one
  /// https://www.fit.vut.cz/study/course/{course_id}/.en
  /// Asynchronously fetches and updates data for a specific course if not already loaded.
  Future<void> fetchCourseData(int courseId) async {
    if (!allCourses.containsKey(courseId)) return; // unknown course
    if (isCourseLessonFetched(courseId)) return;

    final parser = await Chaleno().load("https://www.fit.vut.cz/study/course/$courseId/.en");
    if (parser == null) return;

    final html = parser.html;
    if (html == null) return;

    allCourses[courseId]!.prerequisites = _extractPrerequisites(html);
    allCourses[courseId]!.lessons = parser.querySelectorAll("#schedule tbody tr").map(_parseLesson).fold(<CourseLesson>[], _mergeSameLessons);

    allCourses[courseId]!.loaded = true;
  }

  /// Checks if lessons for a given course have already been fetched.
  bool isCourseLessonFetched(int courseId) {
    return allCourses[courseId]!.loaded;
  }

  /// Asynchronously fetches lessons for multiple courses if not already loaded.
  Future<void> getAllCourseLessonsAsync(List<int> courseIds) async {
    await Future.wait(courseIds.map((courseId) async {
      if (!isCourseLessonFetched(courseId)) {
        await fetchCourseData(courseId);
      }
    }));
  }

  /// Retrieve the faculty in which the room is located.
  /// Use this method instead of accessing allLocations directly,
  /// as the data structure may change later.
  Faculty? getRoomLocation(String room) {
    return allLocations[room];
  }

  /// This function checks if the current study program has fetched its course group
  bool isProgramCourseGroupFetched() {
    return allStudyPrograms.containsKey(currentStudyProgram) && allStudyPrograms[currentStudyProgram]!.courseGroups.isNotEmpty;
  }

  /// Synchronously loads the current programCourseGroup based on the current study program.
  /// This function assumes that the study program and its program course groups
  /// have already been fetched. Therefore, it is recommended to check this in advance
  /// using the `isProgramCourseGroupFetched` function.
  ProgramCourseGroup getProgramCourseGroup() {
    return allStudyPrograms[currentStudyProgram]!.courseGroups.firstWhere((group) => group.semester == currentSemester && group.yearOfStudy == currentGrade);
  }

  /// This function takes a string in the format of "hh:mm" and returns the total number of minutes
  /// use for parsing the course lesson
  int parseTime(String str) {
    final chunks = str.split(":").map((v) => int.parse(v));
    return chunks.elementAt(0) * 60 + chunks.elementAt(1);
  }

  /// Helper method for extracting number of lessons required during a semester
  int? _extractNumberOfLessons(String html, String delimiter) {
    final part = html.split("Syllabus of $delimiter").elementAtOrNull(1);
    if (part == null) return null;
    final content = part.split("<div class=\"b-detail__content\">").elementAtOrNull(1);
    if (content == null) return null;

    final numberOfLessons = content.split("</div>")[0].split("</ol>")[0].split("</li>").length - 1;
    return numberOfLessons == 0 ? null : numberOfLessons;
  }

  /// Helper method for extracting prerequisites of the course
  List<CoursePrerequisite> _extractPrerequisites(String html) {
    List<CoursePrerequisite> list = [];

    var part = html.split("Time span").elementAtOrNull(1);
    if (part == null) return list;
    part = part.split("</ul>")[0];
    RegExp exp = RegExp(r"<li>(.*)</li>");

    for (final match in exp.allMatches(part)) {
      final data = match[1];
      if (data == null) continue;

      final split = data.split(" hrs ");
      final hours = int.tryParse(split[0]);
      if (hours == null) continue;

      final type = switch (split[1]) {
        "lectures" => LessonType.lecture,
        "seminar" => LessonType.seminar,
        "exercises" => LessonType.exercise,
        "laboratories" => LessonType.laboratory,
        "projects" => LessonType.project,
        "pc labs" => LessonType.computerLab,
        _ => null
      };

      if (type == null) continue;

      final numberOfLessons = switch (type) {
        LessonType.lecture => _extractNumberOfLessons(html, "lectures"),
        LessonType.seminar => _extractNumberOfLessons(html, "seminars"),
        LessonType.exercise =>
          _extractNumberOfLessons(html, "numerical exercises") ?? _extractNumberOfLessons(html, "lectures"), // the numerical execises can be the same as lectures
        LessonType.laboratory => _extractNumberOfLessons(html, "laboratory exercises"),
        LessonType.computerLab => _extractNumberOfLessons(html, "computer exercises"),
        _ => 0, // Not required
      };

      if (numberOfLessons == null) continue;

      list.add(CoursePrerequisite(type: type, requiredHours: hours, numberOfLessons: numberOfLessons));
      list.sort((a, b) => a.type.index - b.type.index);
    }

    return list;
  }

  /// Helper function that take a list of (on going) merged lesson and a lesson to be added into the list
  /// used in the `fetchCourseData` function
  List<CourseLesson> _mergeSameLessons(List<CourseLesson> list, CourseLesson? lesson) {
    if (lesson == null) {
      return list;
    }

    bool found = false;

    for (var i = 0; i < list.length; i++) {
      final value = list[i];
      if (value.dayOfWeek != lesson.dayOfWeek || value.startsFrom != lesson.startsFrom || value.endsAt != lesson.endsAt || value.type != lesson.type) {
        continue;
      }

      list[i].infos.addAll(lesson.infos);
      found = true;
      break;
    }

    if (!found) {
      list.add(lesson);
    }

    return list;
  }

  /// Helper function to parse the selected lesson element into inner data structure
  /// used in the `fetchCourseData` function
  CourseLesson? _parseLesson(element) {
    if (element.html.contains("<sup class=\"color-red\">*)</sup>")) {
      // It is not possible to register this class in Studis.
      return null;
    }

    /// match every >data</ inside a html tag
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

    final dayOfWeek = switch (matches[0]) {
      "<th>Mon" => DayOfWeek.monday,
      "<th>Tue" => DayOfWeek.tuesday,
      "<th>Wed" => DayOfWeek.wednesday,
      "<th>Thu" => DayOfWeek.thursday,
      "<th>Fri" => DayOfWeek.friday,
      _ => null
    };

    if (dayOfWeek == null) return null;

    final weeks = matches[2];
    final info = exp.firstMatch(matches.last!)![1];

    if (weeks == null || info == null) return null;

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

    return CourseLesson(
      dayOfWeek: dayOfWeek,
      type: type,
      infos: [LessonInfo(locations: locations, info: info, weeks: weeks, capacity: capacity)],
      startsFrom: startsFrom,
      endsAt: endsAt,
    );
  }
}
