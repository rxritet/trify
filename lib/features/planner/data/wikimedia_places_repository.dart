import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/places_repository.dart';
import '../domain/travel_models.dart';

class PlacesApiException implements Exception {
  const PlacesApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Searches Russian Wikipedia through its public REST API.
class WikimediaPlacesRepository implements PlacesRepository {
  WikimediaPlacesRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<Place>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final uri = Uri.https('ru.wikipedia.org', '/w/rest.php/v1/search/page', {
      'q': trimmed,
      'limit': '20',
    });
    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'Trify/1.0 (educational Flutter project)',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw PlacesApiException('Сервис вернул код ${response.statusCode}.');
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final pages = payload['pages'] as List<dynamic>? ?? const [];
      return pages
          .whereType<Map<String, dynamic>>()
          .map(_placeFromJson)
          .toList(growable: false);
    } on PlacesApiException {
      rethrow;
    } catch (_) {
      throw const PlacesApiException(
        'Не удалось загрузить места. Проверьте подключение и повторите попытку.',
      );
    }
  }

  Place _placeFromJson(Map<String, dynamic> item) {
    final title = item['title'] as String? ?? 'Без названия';
    final excerpt = _plainText(item['excerpt'] as String? ?? '');
    final subtitle = item['description'] as String? ?? '';
    final thumbnail = item['thumbnail'] as Map<String, dynamic>?;
    final imageUrl = thumbnail?['url'] as String?;
    final image = imageUrl == null
        ? 'assets/images/almaty.jpg'
        : imageUrl.startsWith('//')
        ? 'https:$imageUrl'
        : imageUrl;
    return Place(
      id: 'wiki-${item['key'] ?? title}',
      name: title,
      region: subtitle.isEmpty ? 'Wikipedia' : subtitle,
      category: _categoryFor('$title $subtitle $excerpt'),
      image: image,
      description: excerpt.isEmpty
          ? 'Краткое описание пока недоступно. Откройте статью в Wikipedia для подробностей.'
          : excerpt,
      duration: 'Wikipedia',
    );
  }

  String _plainText(String value) => value
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _categoryFor(String value) {
    final text = value.toLowerCase();
    if (RegExp(r'озер|каньон|парк|гор|заповед|водопад|пещер|река')
        .hasMatch(text)) {
      return 'Природа';
    }
    if (RegExp(r'музей|театр|площад|собор|башн|дворец|памятник')
        .hasMatch(text)) {
      return 'Город';
    }
    return 'Открытие';
  }
}
