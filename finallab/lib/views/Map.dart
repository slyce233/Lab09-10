import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import '../model/Loc.dart';
import 'package:geolocator/geolocator.dart';



class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();

}

class _MapState extends State <Map>{
  final centre = LatLng(43.8845, -78.8482);
  MapController _mapController;
  StatefulMapController _statefulMapController;
  var _geolocator = Geolocator();
  Loc _location;
  List <Marker> allMarkers = [];
  List <Placemark> places;
  var _path = <LatLng> [];



  @override
  void initState() {
    _mapController = MapController();
    _statefulMapController = StatefulMapController( mapController: _mapController);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    getLocation();
    return Scaffold(
      appBar: AppBar(
        title: Text("Maps"),
        actions: [
          IconButton(icon: Icon(Icons.zoom_in), onPressed: (() {
            _statefulMapController.zoomIn();
          })),
          IconButton(icon: Icon(Icons.zoom_out), onPressed: (() {
            setState(() {
              _statefulMapController.zoomOut();
            });
          }
          ))
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
          options: MapOptions(
            zoom: 12.0,
            minZoom: 10.0,
            maxZoom: 18.0,
            center: centre,
          ),
          layers: [
            TileLayerOptions(
                urlTemplate:
                'https://api.mapbox.com/styles/v1/rfortier/cjzcobx1x2csf1cmppuyzj5ys/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicmZvcnRpZXIiLCJhIjoiY2p6Y282cWV4MDg0ZDNibG9zdWZ6M3YzciJ9.p1ePjCH-zs0RdBbLx40pgQ',
                additionalOptions: {
                  'accessToken':
                  'pk.eyJ1Ijoic2x5Y2UyNCIsImEiOiJja2h6bzg4ODAwdjJ5MnhubXd1MWF3dHdqIn0.HHmb_y2me1rPV9qiJikJuw',
                  'id': 'mapbox.mapbox-streets-v8'
                }
            ),
            MarkerLayerOptions(
                markers: setMarker()),
            PolylineLayerOptions(
               polylines: [
                 Polyline(
                   points: _path,
                   strokeWidth: 2.0,
                   color: Colors.blue,
                 ),
               ],
             ),
          ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => addMarker(),
      ),
    );
  }

  setMarker(){
    Marker(
      width: 30.0,
      height: 30.0,
      point: _location.latLng,
      builder: (context) => Container(
          child: Icon(Icons.circle,
              color: Colors.blue)));
    return allMarkers;
  }

  addMarker(){
    allMarkers.add(
        Marker(
          width: 30.0,
          height: 30.0,
          point: _location.latLng,
          builder: (context) => Container(
              child: Icon(Icons.circle,
                  color: Colors.blue))));

    _path.add(_location.latLng);
    _statefulMapController.centerOnPoint(LatLng(_location.latLng.latitude, _location.latLng.longitude));
    return allMarkers;
  }
  void getLocation() async {
    updateLocation(await _geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best));
  }

  void updateLocation(Position userLocation) async {
    String addy;
    String name;
    List <Placemark> _places = await _geolocator.placemarkFromCoordinates(userLocation.latitude, userLocation.longitude);
    setState(() {
      for(Placemark place in _places) {
        places = _places;
        name = '${place.name}';
        addy = '${place.subThoroughfare},'
            '${place.thoroughfare}';
        _location = Loc(name: name,
            address: addy,
            latLng: LatLng(userLocation.latitude, userLocation.longitude));
      }
    });
  }
}