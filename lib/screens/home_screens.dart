import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination.dart';
import '../services/destination_services.dart';
import '../services/auth_services.dart';
import '../theme.dart';
import '../widgets/destination_card.dart';
import 'detail_screen.dart';
import 'search_screen.dart';
import 'seeAll_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Destination> _featured = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  bool _isCategoryLoading = true;
  String? _error;
  Map<String, dynamic>? _profile;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadCategories();
    _loadDestinations();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getProfile();
    if (mounted) setState(() => _profile = profile);
  }

  Future<void> _loadCategories() async {
    try {
      final data = await DestinationService.getCategories();
      if (mounted)
        setState(() {
          _categories = data;
          _isCategoryLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isCategoryLoading = false);
    }
  }

  Future<void> _loadDestinations({int? categoryId}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = categoryId != null
          ? await DestinationService.getByCategory(categoryId)
          : await DestinationService.getFeatured();
      if (mounted)
        setState(() {
          _featured = data;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  // mapping nama icon string dari database ke IconData Flutter
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'beach_access':
        return Icons.beach_access;
      case 'terrain':
        return Icons.terrain;
      case 'location_city':
        return Icons.location_city;
      case 'forest':
        return Icons.forest;
      case 'water':
        return Icons.water;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'masks':
        return Icons.masks;
      case 'landscape':
        return Icons.landscape;
      case 'park':
        return Icons.park;
      case 'hiking':
        return Icons.hiking;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final user = Supabase.instance.client.auth.currentUser;
    final name = _profile?['full_name'] ?? user?.email?.split('@').first ?? 'U';
    final avatarUrl = _profile?['avatar_url'];

    return Stack(
      children: [
        // ── Hero background ──
        SizedBox(
          height: screenHeight * 0.65,
          width: double.infinity,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.85),
                const Color(0xFF0D0D0D),
              ],
              stops: const [0.0, 0.4, 0.75, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.srcOver,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=800',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),

        // ── Content ──
        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        child: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'LUMINA TRAVEL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                    ),
                    // ── Avatar ──
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: avatarUrl != null
                            ? Image.network(avatarUrl, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.primary.withOpacity(0.8),
                                child: Center(
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Search bar ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.search, color: Color(0xFF888888), size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Where to next?',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.18),

              // ── Hero text ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Find Your\nNext Paradise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Categories ──
              SizedBox(
                height: 44,
                child: _isCategoryLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final cat = _categories[i];
                          final isSelected = _selectedCategoryId == cat['id'];
                          return GestureDetector(
                            onTap: () {
                              if (_selectedCategoryId == cat['id']) {
                                setState(() => _selectedCategoryId = null);
                                _loadDestinations();
                              } else {
                                setState(() => _selectedCategoryId = cat['id']);
                                _loadDestinations(categoryId: cat['id']);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getIcon(cat['icon'] ?? ''),
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat['name'] ?? '',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 28),

              // ── Popular Destinations / Category title ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategoryId != null
                          ? _categories.firstWhere(
                              (c) => c['id'] == _selectedCategoryId,
                              orElse: () => {'name': 'Destinations'},
                            )['name']
                          : 'Popular Destinations',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SeeAllScreen()),
                      ),
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Destinations list ──
              SizedBox(
                height: 200,
                child: _isLoading
                    ? _LoadingCards()
                    : _error != null
                    ? _ErrorState(onRetry: _loadDestinations)
                    : _featured.isEmpty
                    ? const Center(
                        child: Text(
                          'No destinations found',
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _featured.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, i) => DestinationCard(
                          destination: _featured[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailScreen(destination: _featured[i]),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Loading skeleton cards ──
class _LoadingCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (_, __) => Container(
        width: 155,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const _ShimmerBox(),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.04, end: 0.12).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ── Error state ──
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white38, size: 28),
          const SizedBox(height: 8),
          const Text(
            'Failed to load',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
