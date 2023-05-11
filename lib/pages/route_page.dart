import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:halfways/language_constants.dart';
import '../helpers/google_api.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../helpers/constants.dart' as constants;
import 'main_page.dart';

class RoutePage extends StatefulWidget {
  const RoutePage(
      {super.key, required this.firstPlace, required this.secondPlace, required this.mode});

  final Place firstPlace, secondPlace;
  final String mode;

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  static const int _markerWidthNormal = 60;
  static const int _markerWidthBigger = 100;

  late GoogleMapController _mapController;
  late double _polylineLength;
  late LatLng _midpoint;
  late RouteResponse _route;
  late Future<List<Location>> futureLocations;
  int _currentPage = 0;
  final Map<String, BitmapDescriptor> _markerIcons = {};
  final Set<Polyline> _polylines = {};
  final List<Marker> _markers = [];
  final GoogleApiProvider _apiClient = GoogleApiProvider();

  @override
  void initState() {
    super.initState();
    futureLocations = _setAllAndFetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double statusHeight = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: constants.accentColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: futureLocations,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<Location> locations = snapshot.data;
                  return Stack(children: [
                    Positioned.fill(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: _midpoint),
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        polylines: _polylines,
                        markers: {..._markers},
                      ),
                    ),
                    Container(
                      color: constants.buttonBG,
                      height: statusHeight + 70,
                      child: Column(
                        children: [
                          SizedBox(
                            height: statusHeight,
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            Expanded(
                              flex: 20,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: constants.text,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 60,
                              child: Text(
                                translation(context).halfwaysBetween(
                                    widget.firstPlace.name, widget.secondPlace.name),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: constants.text),
                              ),
                            ),
                            const Spacer(flex: 20)
                          ]),
                        ],
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Container(
                        width: width,
                        height: 150,
                        margin: const EdgeInsets.only(top: 25, bottom: 25),
                        child: PageView.builder(
                          physics: const PageScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: locations.length,
                          controller: PageController(
                            viewportFraction: 0.8,
                            initialPage: 0,
                          ),
                          onPageChanged: (page) {
                            setState(() {
                              _markers[_currentPage] = Marker(
                                  markerId: _markers[_currentPage].markerId,
                                  position: _markers[_currentPage].position,
                                  icon: _markerIcons['restaurantNormal']!);
                              _markers[page] = Marker(
                                  markerId: _markers[page].markerId,
                                  position: _markers[page].position,
                                  icon: _markerIcons['restaurantBigger']!);
                              // TODO add infoWindows + onTap
                              _currentPage = page;
                            });
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: constants.fill,
                                ),
                                width: MediaQuery.of(context).size.width - 75,
                                child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(locations[index].name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 5),
                                        Row(children: [
                                          Text(
                                            locations[index].rating.toString(),
                                            style: const TextStyle(
                                                fontSize: 12, color: constants.hint),
                                          ),
                                          const SizedBox(width: 5),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(5, (star) {
                                              double rating = locations[index].rating;
                                              return Icon(
                                                  rating >= star + 0.8
                                                      ? Icons.star
                                                      : rating >= star + 0.3
                                                          ? Icons.star_half
                                                          : Icons.star_border,
                                                  size: 12,
                                                  color: constants.accentColor);
                                            }),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '(${locations[index].reviews})',
                                            style: const TextStyle(
                                                fontSize: 12, color: constants.hint),
                                          ),
                                        ]),
                                        const SizedBox(height: 5),
                                        Text(
                                            locations[index].type.replaceAll('_', ' ').capitalize(),
                                            style: const TextStyle(
                                                fontSize: 12, color: constants.hint)),
                                        const Divider(
                                          thickness: 1,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            // Column(
                                            //     crossAxisAlignment: CrossAxisAlignment.start,
                                            //     children: const [
                                            //       Text(
                                            //         'Time',
                                            //         style: TextStyle(
                                            //           color: constants.accentColor,
                                            //         ),
                                            //       ),
                                            //       SizedBox(height: 5),
                                            //       Text(
                                            //         'Distance',
                                            //         style: TextStyle(
                                            //           color: constants.mainHint,
                                            //         ),
                                            //       )
                                            //     ]),
                                            const Spacer(),
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.black,
                                              child: IconButton(
                                                onPressed: () {
                                                  Share.share(
                                                      'https://www.google.com/maps/search/?api=1&query=${locations[index].location.latitude},${locations[index].location.longitude}');
                                                },
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(
                                                  Icons.share,
                                                  color: constants.fill,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ]);
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    Future.delayed(const Duration(milliseconds: 500), () {
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: _route.swBound, northeast: _route.neBound), 40));
    });
  }

  Future<List<Location>> _setAllAndFetchLocation() async {
    return _setRoute().then((_) {
      _setPolylines();
      _setPolylineLength();
      _setMidpoint();
      return _fetchLocations().then((locations) {
        return _getMarkers().then((_) {
          _setMarkers(locations);
          return locations;
        });
      });
    });
  }

  Future<void> _setRoute() async {
    // final directory = await getApplicationDocumentsDirectory();
    // File file = File('${directory.path}/tempRoute.txt');
    // if (file.existsSync()) {
    //   debugPrint('***********************ROUTE FROM MEMORY');
    //   final contents = await file.readAsString();
    //   _route = RouteResponse.fromJson(jsonDecode(contents));
    // } else {
    //   debugPrint('***********************ROUTE API CALL');
    //   _route =
    //       await _apiClient.fetchRoute(widget.firstPlace.id, widget.secondPlace.id, widget.mode);
    //   file.writeAsString(jsonEncode(_route.toJson()));
    // }
    _route = await _apiClient.fetchRoute(widget.firstPlace.id, widget.secondPlace.id, widget.mode);
  }

  Future<List<Location>> _fetchLocations() async {
    // final directory = await getApplicationDocumentsDirectory();
    // File file = File('${directory.path}/tempLocations.txt');
    // List<Location> locations;
    // if (file.existsSync()) {
    //   debugPrint('***********************LOCATIONS FROM MEMORY');
    //   final contents = await file.readAsString();
    //   locations =
    //       (jsonDecode(contents) as List).map((location) => Location.fromJson(location)).toList();
    // } else {
    //   debugPrint('***********************LOCATIONS API CALL');
    //   locations = await _apiClient.fetchLocations(_midpoint);
    //   file.writeAsString(jsonEncode(locations.map((location) => location.toJson()).toList()));
    // }
    // return locations;
    return _apiClient.fetchLocations(_midpoint);
  }

  void _setPolylines() {
    Polyline polyline = Polyline(
        polylineId: const PolylineId("poly"),
        color: constants.analogousColor1,
        width: 3,
        points: _route.polylinePoints);

    _polylines.add(polyline);
  }

  void _setPolylineLength() {
    double totalDistance = 0;
    for (var i = 0; i < _route.polylinePoints.length - 1; i++) {
      totalDistance += _calculateDistance(_route.polylinePoints[i], _route.polylinePoints[i + 1]);
    }
    _polylineLength = totalDistance;
  }

  void _setMidpoint() {
    _midpoint = _getPointAtDistance(_polylineLength / 2) ?? const LatLng(0, 0);
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<BitmapDescriptor> _getBitmapDescriptorFromAssetBytes(String path, int width) async {
    final Uint8List imageData = await _getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(imageData);
  }

  Future<void> _getMarkers() async {
    _markerIcons['basic'] = await _getBitmapDescriptorFromAssetBytes(
        'assets/markers/MarkerBasic.png', _markerWidthNormal);
    _markerIcons['midpoint'] = await _getBitmapDescriptorFromAssetBytes(
        'assets/markers/MarkerMidpoint.png', _markerWidthNormal);

    _markerIcons['restaurantNormal'] = await _getBitmapDescriptorFromAssetBytes(
        'assets/markers/MarkerRestaurant.png', _markerWidthNormal);
    _markerIcons['restaurantBigger'] = await _getBitmapDescriptorFromAssetBytes(
        'assets/markers/MarkerRestaurant.png', _markerWidthBigger);
  }

  void _setMarkers(List<Location> locations) {
    locations.asMap().forEach((index, value) {
      _markers.add(Marker(
          markerId: MarkerId('marker$index'),
          position: value.location,
          icon:
              index != 0 ? _markerIcons['restaurantNormal']! : _markerIcons['restaurantBigger']!));
    });
    _markers.add(Marker(
      markerId: const MarkerId('markerMidpoint'),
      position: _midpoint,
      icon: _markerIcons['midpoint']!,
    ));
    _markers.add(Marker(
      markerId: const MarkerId('markerStart'),
      position: _route.startLocation,
      icon: _markerIcons['basic']!,
    ));
    _markers.add(Marker(
      markerId: const MarkerId('markerEnd'),
      position: _route.endLocation,
      icon: _markerIcons['basic']!,
    ));
    // TODO add infoWindows + onTap
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((p2.latitude - p1.latitude) * p) / 2 +
        c(p1.latitude * p) * c(p2.latitude * p) * (1 - c((p2.longitude - p1.longitude) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  LatLng? _getPointAtDistance(double meters) {
    List<LatLng> points = _route.polylinePoints;
    if (points.isEmpty || meters < 0) return null;
    if (meters == 0) return points[0];
    double dist = 0, olddist = 0;
    int curr = 1;

    while (curr < points.length && dist < meters) {
      olddist = dist;
      dist += _calculateDistance(points[curr], points[curr - 1]);
      curr++;
    }
    if (dist < meters) {
      return null;
    }
    LatLng p1 = points[curr - 2];
    LatLng p2 = points[curr - 1];
    double m = (meters - olddist) / (dist - olddist);
    return LatLng(p1.latitude + (p2.latitude - p1.latitude) * m,
        p1.longitude + (p2.longitude - p1.longitude) * m);
  }
}
