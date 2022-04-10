import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/blocs/blocs.dart';

class MapView extends StatelessWidget {
  final LatLng initialLocation;
  final Set<Polyline> polylines;
  final Set<Marker> markers;
  const MapView({Key? key, required this.initialLocation, required this.polylines, required this.markers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final mapBloc = BlocProvider.of<MapBloc>(context);

    final CameraPosition initialCameraPosition =
        CameraPosition(target: initialLocation, zoom: 15);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Listener(
        //se acciona cuando movemos el mapa 
        onPointerMove: ((event) => mapBloc.add(OnStopFollowingUserEvent())),
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition,
          compassEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          polylines: polylines,
          onMapCreated: (controller) => mapBloc.add(OnMapInitializedEvent(controller)),
          markers: markers,
          //guarda las cordenadas del centro del mapa
          onCameraMove: (position) => mapBloc.mapCenter = position.target
        ),
      ),
    );
  }
}
