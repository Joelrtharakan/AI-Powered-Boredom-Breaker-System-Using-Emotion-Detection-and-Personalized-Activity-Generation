import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();

  /// Smooth page route with premium slide + fade transition
  static Route<dynamic> route() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const HistoryScreen(),
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Entry: slide up + fade in
        final enterSlide =
            Tween<Offset>(
              begin: const Offset(0.0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        final enterFade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

        // Exit: slide right + fade out
        final exitSlide =
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0.3, 0.0),
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInCubic),
            );
        final exitFade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
          ),
        );

        // Use the forward animation for both entry and exit
        // (animation goes 0→1 on push, 1→0 on pop)
        return FadeTransition(
          opacity: animation.status == AnimationStatus.reverse
              ? exitFade
              : enterFade,
          child: SlideTransition(
            position: animation.status == AnimationStatus.reverse
                ? exitSlide
                : enterSlide,
            child: child,
          ),
        );
      },
    );
  }
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _selectedFilterMood;

  @override
  void initState() {
    super.initState();
    // Fetch latest data silently immediately after frame loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // Match Dashboard Background
      body: Stack(
        children: [
          // 1. Vibrant Top Gradient Header (Dashboard Theme)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.30,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5E60CE), // Indigo
                    Color(0xFF4EA8DE), // Blue
                    Color(0xFF56CFE1), // Cyan
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Insights",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () => ref
                                .read(historyProvider.notifier)
                                .fetchHistory(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. White Content Container (The "Dashboard Slide Up" look)
          Positioned(
            top: size.height * 0.13,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 30,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                child: historyState.when(
                  data: (history) {
                    if (history.isEmpty) {
                      return _buildEmptyState();
                    }
                    final stats = _calculateStats(history);
                    return _buildContent(context, history, stats);
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      "Error loading insights",
                      style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<dynamic> history) {
    if (history.isEmpty) {
      return {};
    }

    double totalIntensity = 0;
    Map<String, int> moodCounts = {};
    String dominantMood = "None";
    int maxCount = 0;

    for (var item in history) {
      totalIntensity += (item['intensity'] as num?)?.toDouble() ?? 0.0;
      final mood = (item['mood'] as String? ?? 'unknown').toLowerCase();
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      if (moodCounts[mood]! > maxCount) {
        maxCount = moodCounts[mood]!;
        dominantMood = mood;
      }
    }

    return {
      'avg_intensity': totalIntensity / history.length,
      'total_logs': history.length,
      'dominant_mood': dominantMood,
      'mood_distribution': moodCounts,
    };
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: const Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 16),
          Text(
            "No data to analyze yet",
            style: GoogleFonts.outfit(
              color: const Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check in with your mood to see insights",
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<dynamic> history,
    Map<String, dynamic> stats,
  ) {
    final chronologicalHistory = List.from(history.reversed);
    final filteredHistory = _selectedFilterMood == null
        ? history
        : history.where((item) {
            final mood = (item['mood'] as String?)?.toLowerCase() ?? 'unknown';
            return mood == _selectedFilterMood;
          }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Key Metrics (Premium Cards)
          const _SectionTitle(title: "QUICK STATS"),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: "Avg Flow",
                    value:
                        "${(stats['avg_intensity'] * 10).toStringAsFixed(1)}",
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF6D4EFF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: "Total logs",
                    value: "${stats['total_logs']}",
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFF00C6FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: "Dominant",
                    value: stats['dominant_mood'].toString().toUpperCase(),
                    icon: Icons.psychology_rounded,
                    color: const Color(0xFFFF416C),
                    isTextSmall: true,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 40),

          // 2. Mood Distribution
          const _SectionTitle(title: "EMOTIONAL SPECTRUM"),
          const SizedBox(height: 16),
          _MoodDistributionChart(stats: stats)
              .animate()
              .fadeIn(delay: 200.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 40),

          // 3. Intensity Trend
          const _SectionTitle(title: "INTENSITY TREND"),
          const SizedBox(height: 16),
          _IntensityChart(
            history: chronologicalHistory,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 40),

          // 4. Recent History List & Filters
          const _SectionTitle(title: "RECENT LOGS"),
          const SizedBox(height: 16),
          if (stats['mood_distribution'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _selectedFilterMood,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilterMood = newValue;
                      });
                    },
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text("All Moods"),
                      ),
                      ...((stats['mood_distribution'] as Map<String, int>).keys
                              .toList()
                            ..sort())
                          .map((mood) {
                            return DropdownMenuItem<String?>(
                              value: mood,
                              child: Text(
                                mood.replaceAll('_', ' ').toUpperCase(),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ),

          filteredHistory.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "No logs found for this emotion.",
                      style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredHistory.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredHistory[index];
                    return _HistoryItemCard(item: item, index: index)
                        .animate()
                        .fadeIn(delay: (index * 50 + 500).ms)
                        .slideX(begin: 0.05);
                  },
                ),
        ],
      ),
    );
  }
}

// --- Components ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF5E60CE).withValues(alpha: 0.7),
        letterSpacing: 2.5,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTextSmall;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isTextSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: const Color(0xFF1E293B),
              fontSize: isTextSmall ? 14 : 22,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              color: const Color(0xFF94A3B8),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MoodDistributionChart extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _MoodDistributionChart({required this.stats});

  Color _getColorForMood(String mood) {
    mood = mood.toLowerCase();
    if (mood.contains('happy') || mood.contains('joy')) {
      return const Color(0xFFFFB74D);
    }
    if (mood.contains('sad') || mood.contains('depress')) {
      return const Color(0xFF4E92FF);
    }
    if (mood.contains('ang') || mood.contains('frust')) {
      return const Color(0xFFFF5252);
    }
    if (mood.contains('anx') || mood.contains('nerv')) {
      return const Color(0xFFBA68C8);
    }
    if (mood.contains('calm') || mood.contains('relax')) {
      return const Color(0xFF4DB6AC);
    }
    if (mood.contains('bored') ||
        mood.contains('low') ||
        mood.contains('tired')) {
      return const Color(0xFF7986CB);
    }
    if (mood.contains('neutral') || mood.contains('none')) {
      return const Color(0xFF81C784);
    }
    if (mood.contains('stress')) {
      return const Color(0xFFFF8A65);
    }
    return const Color(0xFF94A3B8);
  }

  @override
  Widget build(BuildContext context) {
    final distribution = stats['mood_distribution'] as Map<String, int>;
    final total = stats['total_logs'] as int;
    final sortedKeys = distribution.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 140,
            width: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 45,
                sections: sortedKeys.map((mood) {
                  final count = distribution[mood]!;
                  return PieChartSectionData(
                    color: _getColorForMood(mood),
                    value: count.toDouble(),
                    title: '',
                    radius: 12,
                    showTitle: false,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedKeys.map((mood) {
                final count = distribution[mood]!;
                final percent = ((count / total) * 100).toStringAsFixed(0);
                final color = _getColorForMood(mood);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mood.replaceAll('_', ' ').toUpperCase(),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF1E293B),
                            fontSize: 12, // Reduced slightly to fit better
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Re-added spacing
                      Text(
                        "$percent%",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntensityChart extends StatelessWidget {
  final List<dynamic> history;
  const _IntensityChart({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: history.length < 2
          ? const Center(
              child: Text(
                "Keep tracking to see your trend",
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF5E60CE), Color(0xFF4EA8DE)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "WEEKLY FLOW",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 0.25,
                        verticalInterval: 1,
                      ),
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) => const Color(0xFF1E293B),
                          getTooltipItems: (spots) => spots.map((s) {
                            return LineTooltipItem(
                              "Level: ${(s.y * 10).toStringAsFixed(1)}",
                              GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 0.5,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value > 1.0) {
                                return const SizedBox();
                              }
                              if (value == 0.5) {
                                return Text(
                                  "5",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFCBD5E1),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }
                              if (value == 1.0) {
                                return Text(
                                  "10",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFCBD5E1),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              final step = (history.length / 5).ceil().clamp(
                                1,
                                history.length,
                              );
                              final index = value.toInt();
                              if (index % step != 0) return const SizedBox();
                              if (index < 0 || index >= history.length) {
                                return const SizedBox();
                              }
                              final dateStr = history[index]['created_at'];
                              final date = DateTime.tryParse(dateStr);
                              if (date == null) return const SizedBox();
                              return Text(
                                DateFormat('dd/MM').format(date),
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: -0.1,
                      maxY: 1.1,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(history.length, (index) {
                            final intensity =
                                (history[index]['intensity'] as num?)
                                    ?.toDouble() ??
                                0.0;
                            return FlSpot(index.toDouble(), intensity);
                          }),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5E60CE), Color(0xFF4EA8DE)],
                          ),
                          barWidth: 5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show:
                                history.length <=
                                20, // Only show dots if sparse data
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 3,
                                strokeColor: const Color(0xFF5E60CE),
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF5E60CE).withValues(alpha: 0.15),
                                const Color(0xFF5E60CE).withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const _HistoryItemCard({required this.item, required this.index});

  Color _getMoodColor(String mood) {
    mood = mood.toLowerCase();
    if (mood.contains('happy') || mood.contains('joy')) {
      return const Color(0xFFFFB74D);
    }
    if (mood.contains('sad') || mood.contains('depress')) {
      return const Color(0xFF4E92FF);
    }
    if (mood.contains('ang') || mood.contains('frust')) {
      return const Color(0xFFFF5252);
    }
    if (mood.contains('anx') || mood.contains('nerv')) {
      return const Color(0xFFBA68C8);
    }
    if (mood.contains('calm') || mood.contains('relax')) {
      return const Color(0xFF4DB6AC);
    }
    if (mood.contains('bored') ||
        mood.contains('low') ||
        mood.contains('tired')) {
      return const Color(0xFF7986CB);
    }
    if (mood.contains('neutral') || mood.contains('none')) {
      return const Color(0xFF81C784);
    }
    if (mood.contains('stress')) {
      return const Color(0xFFFF8A65);
    }
    return const Color(0xFF94A3B8);
  }

  @override
  Widget build(BuildContext context) {
    final mood = (item['mood'] ?? 'Unknown').toString();
    final intensity = (item['intensity'] as num?)?.toDouble() ?? 0.0;
    final dateStr = item['created_at'] ?? '';
    final date = DateTime.tryParse(dateStr)?.toLocal();
    final color = _getMoodColor(mood);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.mood_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (date != null)
                  Text(
                    DateFormat('MMM d, h:mm a').format(date),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (intensity * 10).toStringAsFixed(1),
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "FLOW",
                style: GoogleFonts.outfit(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
