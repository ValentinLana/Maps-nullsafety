import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/blocs/blocs.dart';
import 'package:maps/helpers/custom_image_markers.dart';
import 'package:maps/helpers/widgets_to_marker.dart';
import 'package:maps/models/models.dart';
import 'package:maps/themes/uber.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationBloc locationBloc;

  StreamSubscription<LocationState>? locationStateSubscription;

  GoogleMapController? _mapController;

  LatLng? mapCenter;

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    on<OnMapInitializedEvent>(_onInitMap);
    on<OnStartFollowingUserEvent>(_onStartFollowingUser);
    on<OnStopFollowingUserEvent>(
        ((event, emit) => emit(state.copyWith(isFollowingUser: false))));
    on<UpdateUserPolylineEvent>(_onPolylineNewPoint);
    on<OnToggleUserRoute>(((event, emit) =>
        emit(state.copyWith(showMyRoute: !state.showMyRoute))));
    on<DisplayPolylineEvent>(((event, emit) => emit(
        state.copyWith(polylines: event.polylines, markers: event.markers))));

    //escuchamos los cambios en el state del locationbloc
    locationStateSubscription = locationBloc.stream.listen((locationState) {
      if (locationState.lastKnownLocation != null) {
        add(UpdateUserPolylineEvent(locationState.myLocationHistory));
      }
      if (!state.isFollowingUser) return;
      if (locationState.lastKnownLocation == null) return;

      moveCamera(locationState.lastKnownLocation!);
    });
  }

  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    _mapController = event.controller;

    _mapController!.setMapStyle(jsonEncode(uberMapTheme));

    emit(state.copyWith(isMapInitialized: true));
  }

  void _onStartFollowingUser(
      OnStartFollowingUserEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: true));
    if (locationBloc.state.lastKnownLocation == null) return;
    moveCamera(locationBloc.state.lastKnownLocation!);
  }

  void _onPolylineNewPoint(
      UpdateUserPolylineEvent event, Emitter<MapState> emit) {
    final myRoute = Polyline(
      polylineId: const PolylineId('myRoute'),
      color: Colors.black,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      points: event.userLocations,
    );

    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['myRoute'] = myRoute;

    emit(state.copyWith(polylines: currentPolylines));
  }

  Future drawRoutePolyline(RouteDestination destination) async {
    final myRoute = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.black,
      width: 5,
      points: destination.points,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    //pasamos la distancia a kms
    double kms = destination.distance / 1000;
    //redondeamos
    kms = (kms * 100).floorToDouble();
    kms /= 100;

    //pasamos a minutos y redondeamos
    int tripDuration = (destination.duration / 60).floorToDouble().toInt();

    // Custom markers
   /*  final startAssetImageMarker = await getAssetImageMarker();
    final endAssetImageMarker = await getNetweokImageMarker(); */

    final startAssetImageMarker = await getStartCustomMarker(tripDuration, 'Mi ubicación');
    final endAssetImageMarker = await getEndCustomMarker(kms.toInt(), destination.endPlace.text);

    final startMarker = Marker(
      markerId: const MarkerId('start'),
      //este es el primer punto de la polyline
      anchor: const Offset(0.1, 1),
      position: destination.points.first,
      icon: startAssetImageMarker,/* 
      infoWindow: InfoWindow(
          title: 'Inicio', snippet: 'Kms: $kms, duration: $tripDuration'), */
    );

    final finalMarker = Marker(
      markerId: const MarkerId('final'),
      //este es el ultimo punto de la polyline
      position: destination.points.last,
      icon: endAssetImageMarker,
      //anchor: const Offset(0,0), 
      /* infoWindow: InfoWindow(
          title: destination.endPlace.text,
          snippet: destination.endPlace.placeName), */
    );

    final currentMarkers = Map<String, Marker>.from(state.markers);
    //sobrescribe el marker con el id start, osea el primer markador
    currentMarkers['start'] = startMarker;
    currentMarkers['final'] = finalMarker;

    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    //sobrescribe el polyline con el id route, osea el primer polyline
    currentPolylines['route'] = myRoute;

    add(DisplayPolylineEvent(currentPolylines, currentMarkers));
/* 
    await Future.delayed(const Duration(milliseconds: 300));
    _mapController?.showMarkerInfoWindow(const MarkerId('start')); */
  }

  void moveCamera(LatLng newLocation) {
    final cameraUpdate = CameraUpdate.newLatLng(newLocation);
    _mapController?.animateCamera(cameraUpdate);
  }

  @override
  Future<void> close() {
    locationStateSubscription?.cancel();
    return super.close();
  }
}
