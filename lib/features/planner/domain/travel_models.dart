class Place {
  const Place({
    required this.id,
    required this.name,
    required this.region,
    required this.category,
    required this.image,
    required this.description,
    required this.duration,
  });
  final String id, name, region, category, image, description, duration;
}

class Visit {
  const Visit({required this.place, required this.day, this.time = '10:00'});
  final Place place;
  final int day;
  final String time;
}

class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.start,
    required this.end,
    required this.image,
    List<Visit>? visits,
    this.notes = '',
  }) : visits = visits ?? [];
  final String id, title, destination, image;
  final DateTime start, end;
  final List<Visit> visits;
  String notes;
  int get days =>
      DateTime.utc(
        end.year,
        end.month,
        end.day,
      ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
      1;
}

String shortDate(DateTime date) {
  const months = [
    'янв',
    'фев',
    'мар',
    'апр',
    'мая',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

String tripDates(Trip trip) =>
    '${shortDate(trip.start)} — ${shortDate(trip.end)} ${trip.end.year}';
