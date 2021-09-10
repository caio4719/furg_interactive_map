import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furg_interactive_map/app/app_store.dart';
import 'package:furg_interactive_map/models/coordinates/polygon_coordinates.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:furg_interactive_map/models/coordinates/coordinates_model.dart';
import 'package:flutter/services.dart' show rootBundle;
part 'fmap_store.g.dart';

class FmapStore = _FmapStoreBase with _$FmapStore;

abstract class _FmapStoreBase with Store {
  // * Create store to access my appStore
  final AppStore _appStore;

  // * Run function when render widget
  _FmapStoreBase(this._appStore) {
    loadCustomMarker();
    loadMapStyles();
    if (isPolygon == true) {
      loadPolygonBuildings();
    } else {
      loadBuildings();
    }
  }

  // * Get all markers to fill campus
  @observable
  List<Marker> allBuildings = [];

  @observable
  String? allBuildingsJson;

  @observable
  bool isAllMarkersFetched = false;

  @observable
  BitmapDescriptor? customIcon;

  @observable
  String? allPolygonBuildingsJson;

  @observable
  List<Polygon> allPolygonBuildings = [];

  @observable
  Set<Polygon> polygons = HashSet<Polygon>();

  @observable
  bool isPolygon = true;

  // * Load custom markers for each type of building
  @action
  Future loadCustomMarker() async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(3, 3)), 'assets/markers/marker.png')
        .then((d) {
      customIcon = d;
    });
  }

  @action
  Future loadBuildings() async {
    // * Load json file
    allBuildingsJson = await rootBundle
        .loadString('assets/coordinates/furg_map_just_points.json');

    // * Decode json file
    final jsonMarkers = jsonDecode(allBuildingsJson!);
    var jsonDecodedMarkers = CampusMarkers.fromJson(jsonMarkers);

    // * Create a marker for each building in json file
    for (var i = 0; i < jsonDecodedMarkers.features!.length; i++) {
      allBuildings.add(
        Marker(
          markerId:
              MarkerId("${jsonDecodedMarkers.features![i].properties!.name}"),
          draggable: false,
          onTap: () => {
            // showModalBottomSheet(
            //   jsonDecodedMarkers.features![i].properties!.name,
            //   context: context,
            //   builder: (context) => ,
            // ),
          },
          position: LatLng(
              jsonDecodedMarkers.features![i].geometry!.coordinates!.last,
              jsonDecodedMarkers.features![i].geometry!.coordinates!.first),
          // icon: customIcon!,
        ),
      );
    }
    // * Make the map widget visiable
    return isAllMarkersFetched = !isAllMarkersFetched;
  }

  // ! Create a polygon for each building
  Future loadPolygonBuildings() async {
    // * Load json file
    allPolygonBuildingsJson = await rootBundle
        .loadString('assets/coordinates/polygon_coordinates.json');

    // * Decode json file
    final jsonPolygons = jsonDecode(allPolygonBuildingsJson!);
    var jsonDecodedPolygons = PolygonCoordinates.fromJson(jsonPolygons);

    // * Create a marker for each building in json file
    for (var i = 0; i < jsonDecodedPolygons.features!.length; i++) {
      List<LatLng> tempPolygonList = [];
      for (var j = 0;
          j < jsonDecodedPolygons.features![i].geometry!.coordinates!.length;
          j++) {
        print(i);
        tempPolygonList.add(LatLng(
            jsonDecodedPolygons.features![i].geometry!.coordinates![j].first,
            jsonDecodedPolygons.features![i].geometry!.coordinates![j].last));
        polygons.add(
          Polygon(
            polygonId: PolygonId(
                "jsonDecodedPolygons.features![i].geometry!.coordinates!.length"),
            points: tempPolygonList,
            fillColor: Colors.pink,
            strokeWidth: 2,
          ),
        );
      }
    }
    // * Make the map widget visiable
    return isAllMarkersFetched = !isAllMarkersFetched;
  }

  // * Map styles loading part

  @observable
  String? darkMapStyle;

  @observable
  String? lightMapStyle;

  @observable
  String? coordinates;

  // * Define google map controller
  @observable
  Completer<GoogleMapController>? googleMapController = Completer();

  // * Definition of my initial location for map controller
  @observable
  CameraPosition initialCameraPositionSmallHill = CameraPosition(
    target: LatLng(
      -32.075526,
      -52.163279,
    ),
    zoom: 14.4746,
  );

  // * Load each map style
  @action
  Future loadMapStyles() async {
    darkMapStyle =
        await rootBundle.loadString('assets/map_styles/dark_map.json');
    lightMapStyle =
        await rootBundle.loadString('assets/map_styles/light_map.json');
  }

  // * Set map style based at the app style
  @action
  Future setMapStyle() async {
    final controller = await googleMapController!.future;
    if (_appStore.isDark)
      controller.setMapStyle(darkMapStyle);
    else
      controller.setMapStyle(lightMapStyle);
  }
}
