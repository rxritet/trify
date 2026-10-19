import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/travel_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/demo_data.dart';
import '../domain/travel_models.dart';
import 'planner_state.dart';
import 'screens/explore_screen.dart';
import 'screens/trip_screen.dart';
import 'screens/create_trip_screen.dart';
import 'screens/place_screen.dart';

class PlannerShell extends StatefulWidget {
  const PlannerShell({super.key});
  @override
  State<PlannerShell> createState() => _PlannerShellState();
}

class _PlannerShellState extends State<PlannerShell> {
  int index = 0;
  bool savedOnly = false;
  static const labels = ['Главная', 'Открывать', 'Поездки', 'Профиль'];
  static const icons = [
    Icons.grid_view_rounded,
    Icons.explore_outlined,
    Icons.luggage_outlined,
    Icons.person_outline_rounded,
  ];

  void navigate(int next, {bool saved = false}) => setState(() {
    index = next;
    savedOnly = saved;
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final pages = <Widget>[
      HomeScreen(
        onExplore: () => navigate(1),
        onTrips: () => navigate(2),
        onSaved: () => navigate(1, saved: true),
      ),
      ExploreScreen(key: ValueKey(savedOnly), initialSavedOnly: savedOnly),
      const TripsScreen(),
      ProfileScreen(onSaved: () => navigate(1, saved: true)),
    ];
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              Container(
                width: 112,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: context.colors.line)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Icon(
                        Icons.explore,
                        size: 34,
                        color: context.colors.primary,
                      ),
                    ),
                    Expanded(
                      child: NavigationRail(
                        scrollable: true,
                        backgroundColor: context.colors.background,
                        selectedIndex: index,
                        onDestinationSelected: navigate,
                        labelType: NavigationRailLabelType.all,
                        groupAlignment: -.7,
                        indicatorColor: context.colors.elevated,
                        selectedIconTheme: IconThemeData(
                          color: context.colors.primary,
                        ),
                        selectedLabelTextStyle: TextStyle(
                          color: context.colors.primary,
                          fontSize: 12,
                        ),
                        destinations: [
                          for (var i = 0; i < labels.length; i++)
                            NavigationRailDestination(
                              icon: Icon(icons[i]),
                              label: Text(labels[i]),
                            ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Eyebrow('v.01'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: IndexedStack(index: index, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.colors.line)),
              ),
              child: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: navigate,
                height: 76,
                destinations: [
                  for (var i = 0; i < labels.length; i++)
                    NavigationDestination(
                      icon: Icon(icons[i], size: 23),
                      selectedIcon: Icon(
                        icons[i],
                        size: 23,
                        color: context.colors.primary,
                      ),
                      label: labels[i],
                    ),
                ],
              ),
            ),
    );
  }
}

void openTrip(BuildContext context, Trip trip) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => TripScreen(trip: trip)));
void openPlace(BuildContext context, Place place) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => PlaceScreen(place: place)));
void createTrip(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => const CreateTripScreen()));

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onExplore,
    required this.onTrips,
    required this.onSaved,
  });
  final VoidCallback onExplore, onTrips, onSaved;
  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final trip = state.trips.first;
    return PageBody(
      children: [
        Row(
          children: [
            Icon(Icons.explore, color: context.colors.primary, size: 28),
            const SizedBox(width: 8),
            const Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'trify',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.4,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.line),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Eyebrow('Демо'),
            ),
            const SizedBox(width: 10),
            const ThemeToggle(),
            IconButton(
              onPressed: onSaved,
              tooltip: 'Сохранённые места',
              icon: const Icon(Icons.bookmark_border_rounded),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Eyebrow(
          'Меньше суеты. Больше открытий.',
          color: context.colors.primary,
        ),
        const SizedBox(height: 12),
        Text(
          'Твой следующий\nхороший маршрут.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Собери места, в которых хочется побывать.',
          style: TextStyle(color: context.colors.muted, height: 1.5),
        ),
        const SizedBox(height: 22),
        Semantics(
          button: true,
          label: 'Найти место или направление',
          child: Material(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onExplore,
              child: Padding(
                padding: EdgeInsets.all(17),
                child: Row(
                  children: [
                    Icon(Icons.search, color: context.colors.muted),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Куда отправимся?',
                        style: TextStyle(color: context.colors.muted),
                      ),
                    ),
                    Icon(
                      Icons.north_east,
                      size: 18,
                      color: context.colors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SectionHeading(
          'Ближайшая поездка',
          action: 'Все поездки',
          onAction: onTrips,
        ),
        TripHero(trip: trip, onTap: () => openTrip(context, trip)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => createTrip(context),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Запланировать поездку'),
          ),
        ),
        SectionHeading(
          'Вдохновение рядом',
          action: 'Смотреть все',
          onAction: onExplore,
        ),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth < 520
              ? SizedBox(
                  height: 200 + MediaQuery.textScalerOf(context).scale(110),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: demoPlaces.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (_, i) => SizedBox(
                      width: 246,
                      child: PlaceCard(
                        place: demoPlaces[i],
                        onTap: () => openPlace(context, demoPlaces[i]),
                      ),
                    ),
                  ),
                )
              : PlaceGrid(
                  places: demoPlaces,
                  onTap: (place) => openPlace(context, place),
                ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route_outlined, size: 15, color: context.colors.muted),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Путешествуй в своём ритме',
                style: TextStyle(color: context.colors.muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TripHero extends StatelessWidget {
  const TripHero({
    super.key,
    required this.trip,
    required this.onTap,
    this.compact = false,
  });
  final Trip trip;
  final VoidCallback onTap;
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Открыть поездку ${trip.title}',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: context.colors.surface,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: compact ? 250 : 308,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TravelPhoto(trip.image),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x18000000),
                        Color(0x30000000),
                        Color(0xEF0B120E),
                      ],
                      stops: [0, .3, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 20,
                  child: Tag(
                    '${trip.days} дн. · ${trip.visits.length} места',
                    highlight: true,
                    icon: Icons.route_outlined,
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 20,
                  bottom: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.destination,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        trip.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white70,
                            size: 15,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              tripDates(trip),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 21,
                            backgroundColor: context.colors.accent,
                            child: Icon(
                              Icons.north_east,
                              color: context.colors.onAccent,
                              size: 21,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final trips = PlannerScope.of(context).trips;
    return PageBody(
      children: [
        Eyebrow('Твоя коллекция впечатлений', color: context.colors.primary),
        const SizedBox(height: 12),
        Text('Мои поездки', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Text(
          'От первой идеи до последней остановки.',
          style: TextStyle(color: context.colors.muted),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => createTrip(context),
          icon: const Icon(Icons.add),
          label: const Text('Новая поездка'),
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 680
                ? (constraints.maxWidth - 20) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (final trip in trips)
                  SizedBox(
                    width: width,
                    child: TripHero(
                      trip: trip,
                      compact: true,
                      onTap: () => openTrip(context, trip),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onSaved});
  final VoidCallback onSaved;
  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final user = AuthScope.maybeOf(context)?.user;
    return PageBody(
      children: [
        Eyebrow('Твоё пространство', color: context.colors.primary),
        const SizedBox(height: 12),
        Text('Профиль', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 28),
        CircleAvatar(
          radius: 40,
          backgroundColor: context.colors.elevated,
          backgroundImage: const AssetImage(
            'assets/branding/trify-avatar-concept-04.png',
          ),
        ),
        const SizedBox(height: 18),
        Text(
          user == null ? 'Привет, путешественник' : 'Привет, ${user.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Здесь начинается твоя история путешествий.',
          style: TextStyle(color: context.colors.muted),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: _Stat(value: '${state.trips.length}', label: 'поездки'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(
                value: '${state.favorites.length}',
                label: 'в избранном',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          margin: EdgeInsets.zero,
          color: context.colors.surface,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                leading: Icon(
                  Icons.bookmark_outline,
                  color: context.colors.primary,
                ),
                title: const Text('Сохранённые места'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onSaved,
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                secondary: const Icon(Icons.light_mode_outlined),
                title: const Text('Светлая тема'),
                value: ThemeScope.of(context).value == ThemeMode.light,
                onChanged: (light) => ThemeScope.of(context).value = light
                    ? ThemeMode.light
                    : ThemeMode.dark,
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                leading: Icon(Icons.language),
                title: Text('Язык'),
                trailing: Text(
                  'Русский',
                  style: TextStyle(color: context.colors.muted),
                ),
              ),
              if (user != null) ...[
                const Divider(height: 1, indent: 20, endIndent: 20),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  leading: const Icon(Icons.logout_outlined),
                  title: const Text('Выйти из аккаунта'),
                  onTap: () => AuthScope.of(context).signOut(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 26),
        EmptyMessage(
          title: user?.firebaseUid == null
              ? 'Твои данные — на этом устройстве'
              : 'Твои данные синхронизируются',
          message: user?.firebaseUid == null
              ? 'Данные планировщика привязаны к этому аккаунту на устройстве. Поиск мест использует открытые данные Wikipedia.'
              : 'Поездки, заметки и избранное привязаны к твоему Google-аккаунту и синхронизируются с Firestore.',
          icon: Icons.auto_awesome_outlined,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(color: context.colors.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: context.colors.muted)),
      ],
    ),
  );
}
