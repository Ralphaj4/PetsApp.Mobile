import '../repositories/pet_repository.dart';
import '../../data/models/pet_model.dart';

class GetPetByIdUsecase {
  final PetRepository _petRepository;

  GetPetByIdUsecase({required PetRepository petRepository})
      : _petRepository = petRepository;

  Future<PetModel> call(String id) async {
    return await _petRepository.getPetById(id);
  }
}
