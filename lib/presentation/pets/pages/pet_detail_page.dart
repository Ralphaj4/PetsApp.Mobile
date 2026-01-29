import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/pet_model.dart';
import '../viewmodels/pet_vm.dart';

class PetDetailPage extends ConsumerStatefulWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  ConsumerState<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends ConsumerState<PetDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petDetailViewModelProvider(widget.petId).notifier).fetchPet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petDetailViewModelProvider(widget.petId));

    ref.listen<PetDetailState>(petDetailViewModelProvider(widget.petId),
        (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref
            .read(petDetailViewModelProvider(widget.petId).notifier)
            .clearError();
      }
    });

    return Scaffold(
      body: _buildBody(petState),
    );
  }

  Widget _buildBody(PetDetailState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pet Details')),
        body: const Center(child: Text('Pet not found')),
      );
    }

    final pet = state.pet!;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(pet),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(pet),
                const SizedBox(height: 24),
                _buildDetailsSection(pet),
                const SizedBox(height: 24),
                _buildHealthSection(pet),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(PetModel pet) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          pet.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        background: pet.profilePictureUrl != null
            ? Image.network(
                pet.profilePictureUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderImage(pet),
              )
            : _buildPlaceholderImage(pet),
      ),
    );
  }

  Widget _buildPlaceholderImage(PetModel pet) {
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      child: Center(
        child: Icon(
          _getPetTypeIcon(pet.type),
          size: 100,
          color: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildInfoSection(PetModel pet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              icon: _getPetTypeIcon(pet.type),
              label: 'Type',
              value: pet.typeDisplayName,
            ),
            _buildDivider(),
            _buildInfoItem(
              icon: pet.gender == Gender.male ? Icons.male : Icons.female,
              label: 'Gender',
              value: pet.genderDisplayName,
            ),
            _buildDivider(),
            _buildInfoItem(
              icon: Icons.cake_outlined,
              label: 'Age',
              value: pet.ageString ?? 'Unknown',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.grey.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: AppColors.grey.withOpacity(0.3),
    );
  }

  Widget _buildDetailsSection(PetModel pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (pet.breed != null)
                  _buildDetailRow(Icons.category_outlined, 'Breed', pet.breed!),
                if (pet.origin != null)
                  _buildDetailRow(
                      Icons.location_on_outlined, 'Origin', pet.origin!),
                if (pet.weight != null)
                  _buildDetailRow(Icons.monitor_weight_outlined, 'Weight',
                      '${pet.weight} kg'),
                if (pet.dateOfBirth != null)
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Date of Birth',
                    _formatDate(pet.dateOfBirth!),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSection(PetModel pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.medical_services_outlined,
                  'Sterilization',
                  pet.sterilizationDisplayName,
                ),
                if (pet.microchipNumber != null)
                  _buildDetailRow(
                    Icons.memory_outlined,
                    'Microchip',
                    pet.microchipNumber!,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
