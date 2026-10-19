import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/travel_widgets.dart';
import '../../domain/travel_models.dart';
import '../planner_state.dart';

class PlaceScreen extends StatelessWidget {
  const PlaceScreen({super.key, required this.place});
  final Place place;

  Future<void> addToTrip(BuildContext context) async {
    final state = PlannerScope.of(context);
    Trip selected = state.trips.first;
    var day = 0;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Добавить в поездку',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.name,
                    style: TextStyle(color: context.colors.muted),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<Trip>(
                    initialValue: selected,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Поездка'),
                    items: [
                      for (final trip in state.trips)
                        DropdownMenuItem(
                          value: trip,
                          child: Text(
                            trip.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() {
                          selected = value;
                          day = 0;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<int>(
                    key: ValueKey(selected.id),
                    initialValue: day,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'День поездки',
                    ),
                    items: [
                      for (var i = 0; i < selected.days; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(
                            'День ${i + 1} · ${shortDate(selected.start.add(Duration(days: i)))}',
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setSheetState(() => day = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Добавить в план'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final added = state.addPlace(selected, place, day);
    showMessage(
      context,
      added
          ? 'Добавлено: ${selected.title}, день ${day + 1}'
          : 'Это место уже есть в выбранном дне',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Место', style: TextStyle(fontSize: 16)),
      actions: [
        const ThemeToggle(),
        FavoriteButton(place),
        const SizedBox(width: 16),
      ],
    ),
    body: PageBody(
      children: [
        TravelPhoto(
          place.image,
          height: 310,
          width: double.infinity,
          radius: 24,
        ),
        const SizedBox(height: 26),
        Eyebrow(place.category, color: context.colors.primary),
        const SizedBox(height: 12),
        Text(place.name, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Tag(place.region, icon: Icons.location_on_outlined),
            Tag(
              place.duration,
              icon: place.duration == 'Wikipedia'
                  ? Icons.menu_book_outlined
                  : Icons.schedule,
            ),
          ],
        ),
        const SectionHeading('Ради таких моментов'),
        Text(
          place.description,
          style: TextStyle(
            color: context.colors.muted,
            fontSize: 15,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => addToTrip(context),
            icon: const Icon(Icons.add),
            label: const Text('Добавить в поездку'),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'Твой маршрут. Твой темп.',
            style: TextStyle(color: context.colors.muted, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
