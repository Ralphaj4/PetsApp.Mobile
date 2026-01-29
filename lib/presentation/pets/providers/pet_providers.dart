import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../data/repositories/pet_repository.dart' as impl;
import '../../../domain/usecases/get_pets_usecase.dart';
import '../../../domain/usecases/get_pet_by_id_usecase.dart';
import '../../../core/providers/http_providers.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  return impl.PetRepositoryImpl(dio: ref.watch(dioProvider));
});

final getPetsUsecaseProvider = Provider<GetPetsUsecase>((ref) {
  return GetPetsUsecase(petRepository: ref.watch(petRepositoryProvider));
});

final getPetByIdUsecaseProvider = Provider<GetPetByIdUsecase>((ref) {
  return GetPetByIdUsecase(petRepository: ref.watch(petRepositoryProvider));
});
