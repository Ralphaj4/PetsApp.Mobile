import '../../data/models/location_model.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocationUsecase {
  final LocationRepository locationRepository;

  GetCurrentLocationUsecase({required this.locationRepository});

  Future<LocationModel> call() async {
    // Check if location service is enabled
    final isEnabled = await locationRepository.isLocationServiceEnabled();
    if (!isEnabled) {
      throw Exception('Location services are disabled');
    }

    // Request permission
    final hasPermission = await locationRepository.requestLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    // Get current location
    return await locationRepository.getCurrentLocation();
  }
}
