import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/get_pets_usecase.dart';
import '../../../domain/usecases/get_pet_by_id_usecase.dart';
import '../../../data/models/pet_model.dart';
import '../../../core/exceptions/dio_exception_handler.dart';
import '../providers/pet_providers.dart';

// Pets List State & ViewModel
class PetsListState {
  final bool isLoading;
  final String? error;
  final List<PetModel> pets;

  PetsListState({
    this.isLoading = false,
    this.error,
    this.pets = const [],
  });

  PetsListState copyWith({
    bool? isLoading,
    String? error,
    List<PetModel>? pets,
  }) {
    return PetsListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pets: pets ?? this.pets,
    );
  }
}

final petsListViewModelProvider =
    StateNotifierProvider<PetsListViewModel, PetsListState>((ref) {
  return PetsListViewModel(ref.watch(getPetsUsecaseProvider));
});

class PetsListViewModel extends StateNotifier<PetsListState> {
  final GetPetsUsecase _getPetsUsecase;

  PetsListViewModel(this._getPetsUsecase) : super(PetsListState());

  Future<void> fetchPets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pets = await _getPetsUsecase();
      state = state.copyWith(isLoading: false, pets: pets);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Pet Detail State & ViewModel
class PetDetailState {
  final bool isLoading;
  final String? error;
  final PetModel? pet;

  PetDetailState({
    this.isLoading = false,
    this.error,
    this.pet,
  });

  PetDetailState copyWith({
    bool? isLoading,
    String? error,
    PetModel? pet,
  }) {
    return PetDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pet: pet ?? this.pet,
    );
  }
}

final petDetailViewModelProvider =
    StateNotifierProvider.family<PetDetailViewModel, PetDetailState, String>(
        (ref, petId) {
  return PetDetailViewModel(ref.watch(getPetByIdUsecaseProvider), petId);
});

class PetDetailViewModel extends StateNotifier<PetDetailState> {
  final GetPetByIdUsecase _getPetByIdUsecase;
  final String petId;

  PetDetailViewModel(this._getPetByIdUsecase, this.petId)
      : super(PetDetailState());

  Future<void> fetchPet() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pet = await _getPetByIdUsecase(petId);
      state = state.copyWith(isLoading: false, pet: pet);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
