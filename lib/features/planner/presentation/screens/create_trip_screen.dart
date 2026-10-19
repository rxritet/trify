import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/travel_widgets.dart';
import '../../domain/travel_models.dart';
import '../planner_state.dart';
import 'trip_screen.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});
  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController();
  final destination = TextEditingController();
  DateTimeRange? dates;
  bool missingDates = false;
  @override
  void dispose() {
    title.dispose();
    destination.dispose();
    super.dispose();
  }

  Future<void> chooseDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3, 12, 31),
      initialDateRange: dates,
      helpText: 'Даты поездки',
      saveText: 'Выбрать',
    );
    if (picked != null && mounted) {
      setState(() {
        dates = picked;
        missingDates = false;
      });
    }
  }

  void save() {
    final valid = form.currentState!.validate();
    setState(() => missingDates = dates == null);
    if (!valid || dates == null) return;
    final trip = PlannerScope.of(context).createTrip(
      title.text.trim(),
      destination.text.trim(),
      dates!.start,
      dates!.end,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => TripScreen(trip: trip)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Новая поездка', style: TextStyle(fontSize: 16)),
      actions: const [ThemeToggle(), SizedBox(width: 8)],
    ),
    body: PageBody(
      children: [
        Eyebrow('Большое начинается с идеи', color: context.colors.primary),
        const SizedBox(height: 16),
        Text(
          'Куда зовёт\nлюбопытство?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 14),
        Text(
          'Выбери направление и даты. Места добавим по пути.',
          style: TextStyle(color: context.colors.muted, height: 1.6),
        ),
        const SizedBox(height: 28),
        Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: title,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Название поездки',
                  hintText: 'Например, выходные в горах',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Придумай название поездки'
                    : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: destination,
                maxLength: 80,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Город или направление',
                  hintText: 'Например, Алматы',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Укажи направление'
                    : null,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: chooseDates,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    dates == null
                        ? 'Выбрать даты'
                        : '${shortDate(dates!.start)} — ${shortDate(dates!.end)} ${dates!.end.year}',
                  ),
                ),
              ),
              if (missingDates)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Выбери даты поездки',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: save,
                  icon: const Icon(Icons.north_east),
                  label: const Text('Создать поездку'),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'В демо поездка будет доступна до перезапуска приложения.',
                style: TextStyle(fontSize: 12, color: context.colors.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
