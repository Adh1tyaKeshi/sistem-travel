import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/destination_services.dart';
import '../theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/destination_card.dart';
import 'detail_screen.dart';
import 'search_screen.dart';
import 'seeAll_screen.dart';
import 'extra_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Destination> _featured = [];
  bool _isLoading = true;
  String? _error;

  static const _categories = [
    (icon: Icons.beach_access, label: 'Beaches'),
    (icon: Icons.terrain, label: 'Mountains'),
    (icon: Icons.location_city, label: 'Cities'),
    (icon: Icons.forest, label: 'Forests'),
  ];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = await DestinationService.getFeatured();
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
          bottom: false, // ← biarkan MainScaffold yang handle bottom padding
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
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 2,
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                          ),
                          fit: BoxFit.cover,
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

              // ── Hero text — pakai SizedBox sebagai spacer fixed ──
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
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => CategoryChip(
                    icon: _categories[i].icon,
                    label: _categories[i].label,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Popular Destinations ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Destinations',
                      style: TextStyle(
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

        // ── FAB — posisi dari bawah layar ──
        Positioned(
          bottom: 80, // di atas bottom nav (60) + sedikit margin
          right: 24,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTripScreen()),
            ),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.primaryShadow,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
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
