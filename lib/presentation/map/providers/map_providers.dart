import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/repositories/location_repository.dart';
import '../../../data/repositories/location_repository.dart' as impl;
import '../../../domain/usecases/get_current_location_usecase.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return impl.LocationRepositoryImpl();
});

final getCurrentLocationUsecaseProvider =
    Provider<GetCurrentLocationUsecase>((ref) {
  return GetCurrentLocationUsecase(
    locationRepository: ref.watch(locationRepositoryProvider),
  );
});
