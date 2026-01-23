import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/location_model.dart';
import '../../../domain/usecases/get_current_location_usecase.dart';
import '../providers/map_providers.dart';

final mapViewModelProvider =
    StateNotifierProvider<MapViewModel, MapState>((ref) {
  return MapViewModel(ref.watch(getCurrentLocationUsecaseProvider));
});

class MapState {
  final bool isLoading;
  final String? error;
  final LocationModel? currentLocation;
  final Set<Marker> markers;
  final GoogleMapController? mapController;

  MapState({
    this.isLoading = false,
    this.error,
    this.currentLocation,
    this.markers = const {},
    this.mapController,
  });

  MapState copyWith({
    bool? isLoading,
    String? error,
    LocationModel? currentLocation,
    Set<Marker>? markers,
    GoogleMapController? mapController,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentLocation: currentLocation ?? this.currentLocation,
      markers: markers ?? this.markers,
      mapController: mapController ?? this.mapController,
    );
  }

  LatLng? get currentLatLng => currentLocation != null
      ? LatLng(currentLocation!.latitude, currentLocation!.longitude)
      : null;
}

class MapViewModel extends StateNotifier<MapState> {
  final GetCurrentLocationUsecase _getCurrentLocationUsecase;

  MapViewModel(this._getCurrentLocationUsecase) : super(MapState());

  void onMapCreated(GoogleMapController controller) {
    state = state.copyWith(mapController: controller);
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final location = await _getCurrentLocationUsecase();
      state = state.copyWith(
        isLoading: false,
        currentLocation: location,
      );

      // Add marker for current location
      addMarker(
        id: 'current_location',
        position: LatLng(location.latitude, location.longitude),
        title: 'Current Location',
        snippet: location.address ?? 'Your location',
      );

      // Move camera to current location
      if (state.mapController != null) {
        state.mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude),
            15.0,
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void addMarker({
    required String id,
    required LatLng position,
    String? title,
    String? snippet,
  }) {
    final marker = Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
    );

    final updatedMarkers = Set<Marker>.from(state.markers);
    updatedMarkers.removeWhere((m) => m.markerId.value == id);
    updatedMarkers.add(marker);

    state = state.copyWith(markers: updatedMarkers);
  }

  void removeMarker(String id) {
    final updatedMarkers = Set<Marker>.from(state.markers);
    updatedMarkers.removeWhere((m) => m.markerId.value == id);
    state = state.copyWith(markers: updatedMarkers);
  }

  void clearMarkers() {
    state = state.copyWith(markers: {});
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
