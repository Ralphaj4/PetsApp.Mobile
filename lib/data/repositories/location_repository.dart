import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/repositories/location_repository.dart';
import '../models/location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<LocationModel> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      // Get address from coordinates
      String? address;
      try {
        address = await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        // Address lookup failed, but we still have coordinates
        address = null;
      }

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      throw Exception('Failed to get current location: ${e.toString()}');
    }
  }

  @override
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return 'Unknown location';
      }

      final placemark = placemarks.first;
      final addressParts = [
        placemark.street,
        placemark.locality,
        placemark.administrativeArea,
        placemark.country,
      ].where((part) => part != null && part.isNotEmpty);

      return addressParts.join(', ');
    } catch (e) {
      throw Exception('Failed to get address: ${e.toString()}');
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
