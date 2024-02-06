/*
 * Filename: utils.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub (xkloub03)
 * Date: 15/12/2023
 * Description: This file contains utility functions for saving data to files and images.
 */

import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';

import 'package:fit_schedule_maker_plus/models/study.dart';
import 'package:flutter/material.dart';

import 'models/lesson.dart';

void saveFile(
  dynamic data,
  String filename, {
  String mimetype = "text/plain",
}) {
  final bytes = utf8.encode(data);
  // NOTE: This requires the custom <script> element inside web/index.html.
  js.context.callMethod("saveAs", <Object>[
    html.Blob(<Object>[bytes]),
    filename,
    "$mimetype;charset=utf-8",
  ]);
}

void saveImage(
  Uint8List bytes,
  String filename, {
  String mimetype = "text/plain",
}) {
  // NOTE: This requires the custom <script> element inside web/index.html.
  js.context.callMethod("saveAs", <Object>[
    html.Blob(<Object>[bytes]),
    filename,
    "$mimetype;charset=utf-8",
  ]);
}

Color getLessonColor(LessonType type, {bool active = false}) {
  Color color = switch (type) {
    LessonType.lecture => const Color.fromARGB(255, 22, 106, 30),
    LessonType.seminar => const Color.fromARGB(255, 38, 161, 161),
    LessonType.exercise => const Color.fromARGB(255, 21, 69, 88),
    LessonType.computerLab => const Color.fromARGB(255, 89, 3, 3),
    LessonType.laboratory => const Color.fromARGB(255, 111, 92, 24),
    LessonType.project => const Color.fromARGB(255, 177, 97, 17),
  };

  color = color
      .withRed(max(0, color.red - (0x60 * 299 / 1000).round()))
      .withGreen(max(0, color.green - (0x60 * 587 / 1000).round()))
      .withBlue(max(0, color.blue - (0x60 * 114 / 1000).round()));

  if (!active) {
    color = color.withAlpha(60);
  }
  return color;
}

List<StudyProgram> getAllStudies() {
  return [
    StudyProgram(
        id: 15803,
        type: StudyType.bachelor,
        duration: 3,
        shortcut: "BIT",
        courseGroups: [],
        fullName: "Information Technology"),

    // MITAI
    StudyProgram(
        id: 15994,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NADE",
        courseGroups: [],
        fullName: "Application Development"),
    StudyProgram(
        id: 15990,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NBIO",
        courseGroups: [],
        fullName: "Bioinformatics and Biocomputing"),
    StudyProgram(
        id: 15993,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NGRI",
        courseGroups: [],
        fullName: "Computer Graphics and Interaction"),
    StudyProgram(
        id: 15984,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NNET",
        courseGroups: [],
        fullName: "Computer Networks"),
    StudyProgram(
        id: 15992,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NVIZ",
        courseGroups: [],
        fullName: "Computer Vision"),
    StudyProgram(
        id: 15999,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NCPS",
        courseGroups: [],
        fullName: "Cyberphysical Systems"),
    StudyProgram(
        id: 15997,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NSEC",
        courseGroups: [],
        fullName: "Cybersecurity"),
    StudyProgram(
        id: 15988,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NEMB",
        courseGroups: [],
        fullName: "Embedded Systems"),
    StudyProgram(
        id: 16000,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NHPC",
        courseGroups: [],
        fullName: "High Performance Computing"),
    StudyProgram(
        id: 15995,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NISD",
        courseGroups: [],
        fullName: "Information Systems and Databases"),
    StudyProgram(
        id: 15987,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NIDE",
        courseGroups: [],
        fullName: "Intelligent Devices"),
    StudyProgram(
        id: 16001,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NISY",
        courseGroups: [],
        fullName: "Intelligent Systems"),
    StudyProgram(
        id: 15985,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NMAL",
        courseGroups: [],
        fullName: "Machine Learning"),
    StudyProgram(
        id: 15996,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NMAT",
        courseGroups: [],
        fullName: "Mathematical Methods"),
    StudyProgram(
        id: 15991,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NSEN",
        courseGroups: [],
        fullName: "Software Engineering"),
    StudyProgram(
        id: 15986,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NVER",
        courseGroups: [],
        fullName: "Software Verification and Testing"),
    StudyProgram(
        id: 15989,
        type: StudyType.magister,
        duration: 2,
        shortcut: "NSPE",
        courseGroups: [],
        fullName: "Sound, Speech and Natural Language Processing"),

    // IT-MGR-2
    StudyProgram(
        id: 15813,
        type: StudyType.magister,
        duration: 2,
        shortcut: "MBI",
        courseGroups: [],
        fullName: "Bioinformatics and Biocomputing"),
    StudyProgram(
        id: 15808,
        type: StudyType.magister,
        duration: 2,
        shortcut: "MPV",
        courseGroups: [],
        fullName: "Computer and Embedded Systems"),
    StudyProgram(
        id: 15811,
        type: StudyType.magister,
        duration: 2,
        shortcut: "MGM",
        courseGroups: [],
        fullName: "Computer Graphics and Multimedia"),
    StudyProgram(
        id: 15814,
        type: StudyType.magister,
        duration: 2,
        shortcut: "MSK",
        courseGroups: [],
        fullName: "Computer Networks and Communication"),
    StudyProgram(
        id: 15809,
        type: StudyType.magister,
        duration: 2,
        shortcut: "MIS",
        courseGroups: [],
        fullName: "Information Systems"),
    StudyProgram(
        id: 15807,
        type: StudyType.magister,
        duration: 2,
        shortcut: "MBS",
        courseGroups: [],
        fullName: "Information Technology Security"),
    StudyProgram(
        id: 15810,
        type: StudyType.magister,
        duration: 2,
        shortcut: "MIN",
        courseGroups: [],
        fullName: "Intelligent Systems"),
    StudyProgram(
        id: 15812,
        type: StudyType.magister,
        duration: 2,
        shortcut: "MMI",
        courseGroups: [],
        fullName: "Management and Information Technologies"),
    StudyProgram(
        id: 15815,
        type: StudyType.magister,
        duration: 2,
        shortcut: "MMM",
        courseGroups: [],
        fullName: "Mathematical Methods in Information Technology"),
  ];
}
