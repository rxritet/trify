import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trip_planner/features/planner/data/wikimedia_places_repository.dart';

void main() {
  test('maps Wikimedia search data into a place card', () async {
    late http.Request request;
    final repository = WikimediaPlacesRepository(
      client: MockClient((value) async {
        request = value;
        return http.Response.bytes(
          utf8.encode('''
          {"pages":[{
            "key":"Almaty",
            "title":"Алматы",
            "description":"город в Казахстане",
            "excerpt":"<span>Крупный</span> город",
            "thumbnail":{"url":"//upload.wikimedia.org/example.jpg"}
          }]}
        '''),
          200,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final places = await repository.search('Алматы');

    expect(request.url.host, 'ru.wikipedia.org');
    expect(request.url.path, '/w/rest.php/v1/search/page');
    expect(request.url.queryParameters['q'], 'Алматы');
    expect(places.single.name, 'Алматы');
    expect(places.single.description, 'Крупный город');
    expect(places.single.image, 'https://upload.wikimedia.org/example.jpg');
  });
}
