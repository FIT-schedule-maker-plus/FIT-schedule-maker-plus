enum CourseDuty {
  compulsory, // povinny
  elective, // volitelny
  compulsoryElective, // povinne volitelny
  recommended, // doporuceny
}

extension ParseToString on CourseDuty {
  String toCzechString() {
    switch (this) {
      case CourseDuty.compulsory:
        return "Povinne predmety";
      case CourseDuty.compulsoryElective:
        return "Povinne volitelne predmety";
      case CourseDuty.elective:
        return "Volitelne predmety";
      case CourseDuty.recommended:
        return "Doporucene predmety";
      default:
        return "Unknown";
    }
  }
}

/// Represent a course in a program. This contain
class ProgramCourse {
  final int courseId;
  final CourseDuty duty;

  ProgramCourse({
    required this.courseId,
    required this.duty,
  });

  factory ProgramCourse.fromJson(Map<String, dynamic> json) => ProgramCourse(
        courseId: json["course_id"],
        duty: json["duty"],
      );

  Map<String, dynamic> toJson() => {
        "course_id": courseId,
        "duty": duty.index,
      };
}
