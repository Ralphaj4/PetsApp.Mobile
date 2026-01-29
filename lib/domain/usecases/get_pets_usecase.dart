import '../repositories/pet_repository.dart';
import '../../data/models/pet_model.dart';

class GetPetsUsecase {
  final PetRepository _petRepository;

  GetPetsUsecase({required PetRepository petRepository})
      : _petRepository = petRepository;

  Future<List<PetModel>> call() async {
    return await _petRepository.getPets();
  }
}
