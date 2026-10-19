import 'package:flutter/material.dart';

import 'dart:async';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/travel_widgets.dart';
import '../planner_shell.dart';
import '../places_controller.dart';
import '../planner_state.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.initialSavedOnly = false});
  final bool initialSavedOnly;
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final searchController = TextEditingController();
  String query = '', category = 'Все';
  Timer? _debounce;
  late bool savedOnly = widget.initialSavedOnly;

  void _search(String value) {
    setState(() => query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) PlacesScope.of(context).search(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planner = PlannerScope.of(context);
    final controller = PlacesScope.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final categories = [
          'Все',
          ...{for (final place in controller.places) place.category},
        ];
        final places = controller.places
            .where(
              (place) =>
                  (category == 'Все' || place.category == category) &&
                  (!savedOnly || planner.favorites.contains(place.id)),
            )
            .toList();
        return PageBody(
          children: [
            Eyebrow('Следуй за любопытством', color: context.colors.primary),
            const SizedBox(height: 12),
            Text(
              'Места с характером',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Найди свою следующую точку на маршруте.',
              style: TextStyle(color: context.colors.muted),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: searchController,
              onChanged: _search,
              decoration: const InputDecoration(
                hintText: 'Место или город',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final item in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(item),
                        selected: category == item,
                        showCheckmark: false,
                        selectedColor: context.colors.accent,
                        labelStyle: TextStyle(
                          color: category == item
                              ? context.colors.onAccent
                              : context.colors.text,
                        ),
                        onSelected: (_) => setState(() => category = item),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    controller.status == PlacesLoadState.loading
                        ? 'Ищем места…'
                        : 'Мест: ${places.length}',
                    style: TextStyle(color: context.colors.muted, fontSize: 12),
                  ),
                ),
                FilterChip(
                  label: const Text('Избранное'),
                  labelStyle: TextStyle(
                    color: savedOnly
                        ? context.colors.onAccent
                        : context.colors.text,
                  ),
                  avatar: Icon(
                    Icons.bookmark_outline,
                    size: 17,
                    color: savedOnly
                        ? context.colors.onAccent
                        : context.colors.text,
                  ),
                  selected: savedOnly,
                  onSelected: (value) => setState(() => savedOnly = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (controller.status == PlacesLoadState.loading)
              const Padding(
                padding: EdgeInsets.only(top: 42),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.status == PlacesLoadState.failure)
              EmptyMessage(
                title: 'Не получилось загрузить места',
                message: controller.errorMessage ?? 'Повторите попытку.',
                icon: Icons.cloud_off_outlined,
                action: TextButton(
                  onPressed: () => controller.search(query),
                  child: const Text('Повторить'),
                ),
              )
            else if (places.isEmpty)
              EmptyMessage(
                title: savedOnly
                    ? 'Пока ничего не сохранено'
                    : 'Место не найдено',
                message: 'Попробуй другой запрос или сбрось фильтры.',
                icon: Icons.search_off,
                action: TextButton(
                  onPressed: () => setState(() {
                    searchController.clear();
                    query = '';
                    category = 'Все';
                    savedOnly = false;
                    controller.search('');
                  }),
                  child: const Text('Сбросить фильтры'),
                ),
              )
            else
              PlaceGrid(
                places: places,
                onTap: (place) => openPlace(context, place),
              ),
          ],
        );
      },
    );
  }
}
