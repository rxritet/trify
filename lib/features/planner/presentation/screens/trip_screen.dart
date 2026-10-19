import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/travel_widgets.dart';
import '../../data/demo_data.dart';
import '../../domain/travel_models.dart';
import '../planner_shell.dart';
import '../planner_state.dart';
import 'notes_editor.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key, required this.trip});
  final Trip trip;
  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  int day = 0;
  bool notesTab = false;

  Future<void> addPlace() async {
    final place = await showModalBottomSheet<Place>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Добавить в день ${day + 1}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                for (final place in demoPlaces)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    leading: TravelPhoto(
                      place.image,
                      width: 56,
                      height: 56,
                      radius: 12,
                    ),
                    title: Text(place.name),
                    subtitle: Text(place.region),
                    trailing: Icon(
                      Icons.add_circle_outline,
                      color: context.colors.primary,
                    ),
                    onTap: () => Navigator.pop(context, place),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || place == null) return;
    final added = PlannerScope.of(context).addPlace(widget.trip, place, day);
    showMessage(
      context,
      added ? 'Место добавлено в план' : 'Это место уже есть в выбранном дне',
    );
  }

  Future<void> editNotes() async {
    final notes = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => NotesEditor(initialNotes: widget.trip.notes),
    );
    if (mounted && notes != null) {
      PlannerScope.of(context).saveNotes(widget.trip, notes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final trip = widget.trip;
    final visits = trip.visits.where((visit) => visit.day == day).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя поездка', style: TextStyle(fontSize: 16)),
        actions: const [ThemeToggle(), SizedBox(width: 8)],
      ),
      body: PageBody(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 230,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TravelPhoto(trip.image),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xC0111413)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Tag(
                      trip.destination,
                      icon: Icons.location_on_outlined,
                      onPhoto: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(trip.title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Tag(tripDates(trip), icon: Icons.calendar_today_outlined),
              Tag('${trip.days} дн.', icon: Icons.schedule),
              Tag('${trip.visits.length} места', icon: Icons.route),
            ],
          ),
          const SizedBox(height: 28),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.route_outlined),
                label: Text('План по дням'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.notes_rounded),
                label: Text('Заметки'),
              ),
            ],
            selected: {notesTab},
            onSelectionChanged: (value) =>
                setState(() => notesTab = value.first),
          ),
          const SizedBox(height: 24),
          if (notesTab) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trip.notes.isEmpty
                    ? 'Пока без заметок. Запиши всё важное перед поездкой.'
                    : trip.notes,
                style: const TextStyle(height: 1.8),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: editNotes,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Редактировать заметки'),
            ),
          ] else ...[
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: trip.days,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) => Semantics(
                  selected: i == day,
                  child: Material(
                    color: i == day
                        ? context.colors.accent
                        : context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => day = i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'День ${i + 1}',
                              style: TextStyle(
                                color: i == day
                                    ? context.colors.onAccent
                                    : context.colors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              shortDate(trip.start.add(Duration(days: i))),
                              style: TextStyle(
                                color: i == day
                                    ? context.colors.onAccent
                                    : context.colors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SectionHeading(
              'В своём ритме',
              action: '+ Добавить',
              onAction: addPlace,
            ),
            if (visits.isEmpty)
              EmptyMessage(
                title: 'День для новых открытий',
                message: 'Добавь первое место и начни собирать маршрут.',
                action: FilledButton.icon(
                  onPressed: addPlace,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить место'),
                ),
              ),
            for (final visit in visits)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 49,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            visit.time,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 95,
                            color: context.colors.line,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => openPlace(context, visit.place),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TravelPhoto(
                                visit.place.image,
                                height: 128,
                                width: double.infinity,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  8,
                                  14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            visit.place.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            visit.place.duration,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Удалить из плана',
                                      onPressed: () =>
                                          state.removeVisit(trip, visit),
                                      icon: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: context.colors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Оставь немного времени для незапланированного.',
              style: TextStyle(color: context.colors.muted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
