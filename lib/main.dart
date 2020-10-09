import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mappy/utils/config.helper.dart';
import 'package:mappy/utils/location.helper.dart';

void main() {
  runApp(App());
}

const Color COLOR_PRIMARY = const Color(0xFFFBFAF8);
const Color COLOR_SECONDARY = const Color(0xFFF4F4F8);
const Color COLOR_ACCENT = const Color(0xFF006992);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: COLOR_SECONDARY,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: COLOR_PRIMARY,
        accentColor: COLOR_ACCENT,
        scaffoldBackgroundColor: COLOR_SECONDARY,
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          color: COLOR_SECONDARY,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: FutureBuilder(
        future: loadConfigFile(),
        builder: (
          BuildContext cntx,
          AsyncSnapshot<Map<String, dynamic>> snapshot,
        ) {
          if (snapshot.hasData) {
            return MapboxMap(
              accessToken: snapshot.data['mapbox_api_token'] as String ?? '',
              minMaxZoomPreference: MinMaxZoomPreference(6.0, 20.0),
              initialCameraPosition: CameraPosition(
                zoom: 15.0,
                target: LatLng(14.508, 46.048),
              ),
              onMapCreated: (MapboxMapController controller) async {
                final result = await acquireCurrentLocation();
                final animateCameraResult = await controller.animateCamera(
                  CameraUpdate.newLatLng(result),
                );

                print('Animate camera result successful: $animateCameraResult');
                if (animateCameraResult) {
                  final circle = await controller.addCircle(
                    CircleOptions(
                      circleRadius: 8.0,
                      circleColor: '#006992',
                      circleOpacity: 0.8,
                      geometry: result,
                      draggable: false,
                    ),
                  );
                  print('Added circle ${circle.id}');
                }
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text('Error has occurred: ${snapshot.error.toString()}')
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_on_sharp),
        onPressed: () {},
      ),
    );
  }
}
