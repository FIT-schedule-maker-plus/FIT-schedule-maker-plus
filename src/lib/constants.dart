enum Category {
  compulsory,
  compulsoryOptional,
  optional,
}

extension ParseToString on Category {
  String toCzechString() {
    switch (this) {
      case Category.compulsory:
        return "Povinne predmety";
      case Category.compulsoryOptional:
        return "Povinne volitelne predmety";
      case Category.optional:
        return "Volitelne predmety";
      default:
        return "Unknown";
    }
  }
}
