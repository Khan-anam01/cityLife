import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteService {
  static const String _apiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImIwNGEzMTFjY2JlODQ1ZGY5NDgyNDk0MDBhODJmODk0IiwiaCI6Im11cm11cjY0In0=';
  static const String _baseUrl =
      'https://api.openrouteservice.org/v2/directions/driving-car';

  /// Fetches a route between two points and returns a list of LatLng
  static Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      '$_baseUrl?api_key=$_apiKey'
      '&start=${origin.longitude},${origin.latitude}'
      '&end=${destination.longitude},${destination.latitude}',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch route: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    // ORS returns GeoJSON — coordinates come as [lng, lat] pairs
    final List coords = data['features'][0]['geometry']['coordinates'];

    return coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
  }
}
