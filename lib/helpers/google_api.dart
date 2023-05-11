import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

// For storing our result
class Suggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;

  Suggestion(this.placeId, this.mainText, this.secondaryText);
}

class Location {
  String name, type;
  LatLng location;
  double rating;
  int reviews;

  Location(this.name, this.location, this.rating, this.reviews, this.type);

  Location.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        location = LatLng.fromJson(json['location'])!,
        rating = json['rating'],
        reviews = json['reviews'],
        type = json['type'];

  Map<String, dynamic> toJson() =>
      {'name': name, 'location': location, 'rating': rating, 'reviews': reviews, 'type': type};
}

class RouteResponse {
  List<LatLng> polylinePoints;
  LatLng neBound;
  LatLng swBound;
  int distanceValue;
  String distanceText;
  int durationValue;
  String durationText;
  LatLng startLocation;
  LatLng endLocation;

  RouteResponse(
      this.polylinePoints,
      this.neBound,
      this.swBound,
      this.distanceValue,
      this.distanceText,
      this.durationValue,
      this.durationText,
      this.startLocation,
      this.endLocation);

  RouteResponse.empty()
      : polylinePoints = [],
        neBound = const LatLng(0, 0),
        swBound = const LatLng(0, 0),
        distanceValue = 0,
        distanceText = '',
        durationValue = 0,
        durationText = '',
        startLocation = const LatLng(0, 0),
        endLocation = const LatLng(0, 0);

  RouteResponse.fromJson(Map<String, dynamic> json)
      : polylinePoints = (json['polylinePoints'] as List).map((i) => LatLng.fromJson(i)!).toList(),
        neBound = LatLng.fromJson(json['neBound'])!,
        swBound = LatLng.fromJson(json['swBound'])!,
        distanceValue = json['distanceValue'] as int,
        distanceText = json['distanceText'] as String,
        durationValue = json['durationValue'] as int,
        durationText = json['durationText'] as String,
        startLocation = LatLng.fromJson(json['startLocation'])!,
        endLocation = LatLng.fromJson(json['endLocation'])!;

  Map<String, dynamic> toJson() => {
        'polylinePoints': polylinePoints.map((point) => point.toJson()).toList(),
        'neBound': neBound,
        'swBound': swBound,
        'distanceValue': distanceValue,
        'distanceText': distanceText,
        'durationValue': durationValue,
        'durationText': durationText,
        'startLocation': startLocation,
        'endLocation': endLocation
      };
}

class GoogleApiProvider {
  final _client = Client();
  final String _sessionToken;
  static const _apiKey = String.fromEnvironment("GOOGLE_KEY");

  GoogleApiProvider([this._sessionToken = '']);

  List<LatLng> _decodePolyline(String input) {
    var list = input.codeUnits;
    List lList = [];
    int index = 0;
    int len = input.length;
    int c = 0;
    List<LatLng> positions = [];
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (int i = 2; i < lList.length; i++) {
      lList[i] += lList[i - 2];
    }

    for (int i = 0; i < lList.length; i += 2) {
      positions.add(LatLng(lList[i], lList[i + 1]));
    }

    return positions;
  }

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    debugPrint('*****SUGGESTION CALL');
    final uri = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: 'maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          // 'types': 'address',
          // 'language': lang, Unconcoment once app allows for different languages
          'key': _apiKey,
          'sessiontoken': _sessionToken
        });
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return (result['predictions'] as List)
            .map<Suggestion>((p) => Suggestion(
                p['place_id'],
                p['structured_formatting']['main_text'],
                p['structured_formatting']['secondary_text'] ?? ''))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<List<Location>> fetchLocations(LatLng location) async {
    debugPrint('*****LOCATION CALL');
    final uri = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: 'maps/api/place/nearbysearch/json',
        queryParameters: {
          'location': '${location.latitude},${location.longitude}',
          // 'types': 'address',
          // 'language': lang, Unconcoment once app allows for different languages
          'keyword': 'restaurant', // allow different keywords later
          'radius': '5000',
          'key': _apiKey,
        });
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      if (result['status'] == 'OK') {
        // compose locations in a list
        return (result['results'] as List)
            .map<Location>((p) => Location(
                p['name'],
                LatLng(p['geometry']['location']['lat'], p['geometry']['location']['lng']),
                p['rating'].toDouble(),
                p['user_ratings_total'],
                p['types'][0]))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<RouteResponse> fetchRoute(String originId, String destinationId, String mode) async {
    debugPrint('*****ROUTE CALL');
    final uri = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: 'maps/api/directions/json',
        queryParameters: {
          'origin': originId,
          'destination': destinationId,
          // 'language': lang, Unconcoment once app allows for different languages
          'key': _apiKey,
          'mode': mode,
        });
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        dynamic route = result['routes'][0];
        dynamic leg = route['legs'][0];
        return RouteResponse(
          _decodePolyline(route['overview_polyline']['points']),
          LatLng(route['bounds']['northeast']['lat'], route['bounds']['northeast']['lng']),
          LatLng(route['bounds']['southwest']['lat'], route['bounds']['southwest']['lng']),
          leg['distance']['value'],
          leg['distance']['text'],
          leg['duration']['value'],
          leg['duration']['text'],
          LatLng(leg['start_location']['lat'], leg['start_location']['lng']),
          LatLng(leg['end_location']['lat'], leg['end_location']['lng']),
        );
      }
      if (result['status'] == 'NOT_FOUND') {
        // at least one address could not be found
        return RouteResponse.empty();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        // no route could be found
        return RouteResponse.empty();
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
