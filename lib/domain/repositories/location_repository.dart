import '../../data/models/location_model.dart';

abstract class LocationRepository {
  Future<LocationModel> getCurrentLocation();
  Future<String> getAddressFromCoordinates(double latitude, double longitude);
  Future<bool> requestLocationPermission();
  Future<bool> isLocationServiceEnabled();
}
