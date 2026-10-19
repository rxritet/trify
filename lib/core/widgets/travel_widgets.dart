import 'package:flutter/material.dart';

import '../../features/planner/domain/travel_models.dart';
import '../../features/planner/presentation/planner_state.dart';
import '../theme/app_theme.dart';

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 600 ? 22 : 40,
            24,
            MediaQuery.sizeOf(context).width < 600 ? 22 : 40,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: color ?? context.colors.muted,
      fontSize: 10,
      letterSpacing: 2,
      fontWeight: FontWeight.w700,
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!, style: const TextStyle(fontSize: 12)),
          ),
      ],
    ),
  );
}

class TravelPhoto extends StatelessWidget {
  const TravelPhoto(
    this.path, {
    super.key,
    this.height,
    this.width,
    this.radius = 0,
  });
  final String path;
  final double? height, width;
  final double radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: (Uri.tryParse(path)?.hasScheme ?? false)
        ? Image.network(
            path,
            height: height,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _fallback(context),
          )
        : Image.asset(
            path,
            height: height,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _fallback(context),
          ),
  );

  Widget _fallback(BuildContext context) => Container(
    height: height,
    width: width,
    color: context.colors.elevated,
    child: Center(
      child: Icon(
        Icons.landscape_outlined,
        size: 48,
        color: context.colors.muted,
      ),
    ),
  );
}

class Tag extends StatelessWidget {
  const Tag(
    this.text, {
    super.key,
    this.icon,
    this.highlight = false,
    this.onPhoto = false,
  });
  final String text;
  final IconData? icon;
  final bool highlight;
  final bool onPhoto;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: highlight
          ? context.colors.accent
          : onPhoto
          ? context.colors.photoScrim
          : context.colors.elevated,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 14,
            color: highlight
                ? context.colors.onAccent
                : onPhoto
                ? context.colors.onPhoto
                : context.colors.text,
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: highlight
                  ? context.colors.onAccent
                  : onPhoto
                  ? context.colors.onPhoto
                  : context.colors.text,
            ),
          ),
        ),
      ],
    ),
  );
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton(this.place, {super.key, this.onPhoto = false});
  final Place place;
  final bool onPhoto;
  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final saved = state.favorites.contains(place.id);
    return IconButton.filledTonal(
      tooltip: saved ? 'Убрать из избранного' : 'В избранное',
      style: IconButton.styleFrom(
        backgroundColor: onPhoto
            ? context.colors.photoScrim
            : context.colors.elevated,
        foregroundColor: saved
            ? (onPhoto ? context.colors.accent : context.colors.primary)
            : (onPhoto ? context.colors.onPhoto : context.colors.text),
      ),
      onPressed: () => state.toggleFavorite(place.id),
      icon: Icon(
        saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        size: 21,
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(22),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              TravelPhoto(place.image, height: 166, width: double.infinity),
              Positioned(
                top: 8,
                right: 8,
                child: FavoriteButton(place, onPhoto: true),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Tag(place.category, onPhoto: true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: context.colors.muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.region,
                        style: Theme.of(context).textTheme.bodySmall,
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
  );
}

class PlaceGrid extends StatelessWidget {
  const PlaceGrid({super.key, required this.places, required this.onTap});
  final List<Place> places;
  final ValueChanged<Place> onTap;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = constraints.maxWidth >= 820
          ? 3
          : constraints.maxWidth >= 520
          ? 2
          : 1;
      final width = (constraints.maxWidth - (count - 1) * 16) / count;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final place in places)
            SizedBox(
              width: width,
              child: PlaceCard(place: place, onTap: () => onTap(place)),
            ),
        ],
      );
    },
  );
}

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.explore_outlined,
    this.action,
  });
  final String title, message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        Icon(icon, color: context.colors.primary, size: 32),
        const SizedBox(height: 14),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colors.muted, height: 1.5),
        ),
        if (action != null) ...[const SizedBox(height: 18), action!],
      ],
    ),
  );
}

void showMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
