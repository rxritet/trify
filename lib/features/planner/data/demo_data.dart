import '../domain/travel_models.dart';

const demoPlaces = [
  Place(
    id: 'lake',
    name: 'Большое Алматинское озеро',
    region: 'Алматы',
    category: 'Природа',
    image: 'assets/images/almaty.jpg',
    duration: '2–3 часа',
    description: 'Бирюзовая вода, горный воздух и вершины Заилийского Алатау. Место, ради которого хочется проснуться пораньше и оставить целый день свободным.\n\nДобавьте озеро в свой план, возьмите тёплую одежду и заранее уточните условия доступа. Информация в прототипе приведена для примера.',
  ),
  Place(
    id: 'canyon',
    name: 'Чарынский каньон',
    region: 'Алматинская область',
    category: 'Приключения',
    image: 'assets/images/canyon.jpg',
    duration: '4–5 часов',
    description: 'Прогулка среди скальных башен Долины замков. Тёплые оттенки камня, извилистые тропы и пейзажи, которые хочется рассматривать без спешки.\n\nДля поездки стоит выделить отдельный день. Возьмите воду, удобную обувь и защиту от солнца. Это пример описания для дизайн-прототипа.',
  ),
  Place(
    id: 'city',
    name: 'Прогулка по Астане',
    region: 'Астана',
    category: 'Город',
    image: 'assets/images/astana.jpg',
    duration: '2 часа',
    description: 'Современная архитектура, широкие бульвары и огни вечернего города. Соберите собственный маршрут и оставьте время для остановки на кофе.\n\nСписок точек и актуальные часы работы появятся после подключения источника данных.',
  ),
];

List<Trip> createDemoTrips() => [
  Trip(
    id: 'almaty',
    title: 'Выше только горы',
    destination: 'Алматы, Казахстан',
    start: DateTime(2026, 10, 23),
    end: DateTime(2026, 10, 25),
    image: 'assets/images/almaty.jpg',
    visits: [
      Visit(place: demoPlaces[0], day: 0, time: '09:00'),
      Visit(place: demoPlaces[1], day: 1, time: '08:30'),
    ],
    notes: 'Взять термос, удобную обувь и тёплую куртку. Проверить погоду перед выездом.',
  ),
  Trip(
    id: 'astana',
    title: 'Выходные в столице',
    destination: 'Астана, Казахстан',
    start: DateTime(2026, 11, 7),
    end: DateTime(2026, 11, 8),
    image: 'assets/images/astana.jpg',
    visits: [Visit(place: demoPlaces[2], day: 0)],
  ),
];
