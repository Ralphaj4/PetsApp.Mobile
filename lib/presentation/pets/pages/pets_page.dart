import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/pet_model.dart';
import '../viewmodels/pet_vm.dart';
import 'pet_detail_page.dart';

class PetsPage extends ConsumerStatefulWidget {
  const PetsPage({super.key});

  @override
  ConsumerState<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends ConsumerState<PetsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petsListViewModelProvider.notifier).fetchPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final petsState = ref.watch(petsListViewModelProvider);

    ref.listen<PetsListState>(petsListViewModelProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(petsListViewModelProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        centerTitle: true,
      ),
      body: _buildBody(petsState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add pet page
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildBody(PetsListState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.pets.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(petsListViewModelProvider.notifier).fetchPets(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.pets.length,
        itemBuilder: (context, index) {
          final pet = state.pets[index];
          return _PetCard(
            pet: pet,
            onTap: () => _navigateToPetDetail(pet),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No pets yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.grey.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first pet by tapping the + button',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPetDetail(PetModel pet) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PetDetailPage(petId: pet.id),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final PetModel pet;
  final VoidCallback onTap;

  const _PetCard({
    required this.pet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: _getPetTypeIcon(pet.type),
                          label: pet.typeDisplayName,
                        ),
                        const SizedBox(width: 8),
                        if (pet.breed != null)
                          _buildInfoChip(
                            icon: Icons.category_outlined,
                            label: pet.breed!,
                          ),
                      ],
                    ),
                    if (pet.ageString != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        pet.ageString!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.grey.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: pet.profilePictureUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                pet.profilePictureUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  _getPetTypeIcon(pet.type),
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
            )
          : Icon(
              _getPetTypeIcon(pet.type),
              size: 30,
              color: AppColors.primary,
            ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPetTypeIcon(PetType type) {
    switch (type) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.pets;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.fish:
        return Icons.water;
      case PetType.rabbit:
        return Icons.cruelty_free;
      case PetType.hamster:
        return Icons.pets;
      case PetType.other:
        return Icons.pets;
    }
  }
}
