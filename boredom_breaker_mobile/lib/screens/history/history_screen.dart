import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // OLED Black
      appBar: AppBar(
        title: Text(
          "Mental Insights",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
            onPressed: () => ref.read(historyProvider.notifier).fetchHistory(),
          ),
        ],
      ),
      body: historyState.when(
        data: (history) {
          if (history.isEmpty) {
            return _buildEmptyState();
          }
          // Calculate stats
          final stats = _calculateStats(history);
          return _buildContent(context, history, stats);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            "Error loading insights",
            style: GoogleFonts.inter(color: Colors.white54),
          ),
        ),
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
      // Intensity
      totalIntensity += (item['intensity'] as num?)?.toDouble() ?? 0.0;

      // Mood Count
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
          Icon(Icons.analytics_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            "No data to analyze yet",
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            "Check in with your mood to see insights",
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<dynamic> history,
    Map<String, dynamic> stats,
  ) {
    // Reverse for lists (newest first), but chart usually needs chronological
    final chronologicalHistory = List.from(history.reversed);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Key Metrics Row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MetricCard(
                    label: "Avg Intensity",
                    value:
                        "${(stats['avg_intensity'] * 100).toStringAsFixed(0)}%",
                    icon: Icons.ssid_chart_rounded,
                    color: const Color(0xFF6D4EFF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: "Check-ins",
                    value: "${stats['total_logs']}",
                    icon: Icons.check_circle_outline_rounded,
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
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

          const SizedBox(height: 24),

          // 2. Mood Distribution (Pie Chart)
          Text(
            "Emotional Spectrum",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _MoodDistributionChart(
            stats: stats,
          ).animate().fadeIn(delay: 200.ms).scale(),

          const SizedBox(height: 32),

          // 3. Intensity Trend (Line Chart)
          Text(
            "Intensity Trend",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your emotional intensity over the last 20 sessions",
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _IntensityChart(
            history: chronologicalHistory,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 32),

          // 4. Recent History List
          Text(
            "Recent Logs",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = history[index];
              return _HistoryItemCard(item: item, index: index)
                  .animate()
                  .fadeIn(delay: (index * 50 + 500).ms)
                  .slideX(begin: 0.1);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// --- Componets ---

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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: isTextSmall ? 14 : 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
        mood.contains('tired') ||
        mood.contains('fatigue')) {
      return const Color(0xFF7986CB);
    }
    if (mood.contains('neutral') || mood.contains('none')) {
      return const Color(0xFF81C784);
    }
    if (mood.contains('stress')) {
      return const Color(0xFFFF8A65);
    }
    return const Color(0xFFB0BEC5); // Blue Grey default
  }

  @override
  Widget build(BuildContext context) {
    final distribution = stats['mood_distribution'] as Map<String, int>;
    final total = stats['total_logs'] as int;

    // Sort to keep consistent colors/positions
    final sortedKeys = distribution.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Pie Chart
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
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
          const SizedBox(width: 24),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedKeys.map((mood) {
                final count = distribution[mood]!;
                final percent = ((count / total) * 100).toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getColorForMood(mood),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mood.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        "$percent%",
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 12,
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
    if (history.length < 2) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Center(
          child: Text(
            "Check in more times to see your trend",
            style: TextStyle(color: Colors.white38),
          ),
        ),
      );
    }

    // Smart Axis Logic
    final first = DateTime.parse(history.first['created_at']).toLocal();
    final last = DateTime.parse(history.last['created_at']).toLocal();
    final isSameDay =
        first.year == last.year &&
        first.month == last.month &&
        first.day == last.day;

    return Container(
      height: 250, // Increased height for better proportions
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 40,
        bottom: 20,
      ), // Equal padding for aesthetics
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchSpotThreshold:
                50, // Massive touch area to make dragging/scrubbing act like hovering
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => const Color(0xFF242424),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                    touchedSpot.y.toStringAsFixed(2),
                    GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 0),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 0),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36, // Allocate proper space for bottom text
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < history.length &&
                      value == value.toInt()) {
                    int idx = value.toInt();
                    int lastIdx = history.length - 1;

                    bool isFirst = idx == 0;
                    bool isLast = idx == lastIdx;

                    if (history.length > 4) {
                      int step = (history.length / 4).round();
                      if (step < 1) step = 1;

                      bool isMultiple = idx % step == 0;

                      if (!isFirst && !isLast && !isMultiple) {
                        return const SizedBox.shrink();
                      }

                      // Stop internal points from rendering if they are way too close to the end tags
                      if (isMultiple && !isFirst && !isLast) {
                        if ((lastIdx - idx) <= (step * 0.9) ||
                            idx <= (step * 0.9)) {
                          return const SizedBox.shrink();
                        }
                      }
                    }
                    final date = DateTime.parse(
                      history[value.toInt()]['created_at'],
                    ).toLocal();

                    final label = isSameDay
                        ? DateFormat('h:mm a').format(date)
                        : DateFormat('MM/dd').format(date);

                    return Container(
                      padding: const EdgeInsets.only(top: 10.0),
                      alignment: Alignment.center,
                      width: 50, // Limit width of text chunk slightly more
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                interval: 1,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 0),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: -0.5, // Prevents left label clipping
          maxX: (history.length - 1) + 0.5, // Prevents right label clipping
          minY: 0,
          maxY: 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(history.length, (index) {
                final intensity =
                    (history[index]['intensity'] as num?)?.toDouble() ?? 0.0;
                return FlSpot(index.toDouble(), intensity);
              }),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF00C6FF)],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const _HistoryItemCard({required this.item, required this.index});

  Color _getMoodColor(String mood) {
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
        mood.contains('tired') ||
        mood.contains('fatigue')) {
      return const Color(0xFF7986CB);
    }
    if (mood.contains('neutral') || mood.contains('none')) {
      return const Color(0xFF81C784);
    }
    if (mood.contains('stress')) {
      return const Color(0xFFFF8A65);
    }
    return const Color(0xFFB0BEC5); // Blue Grey default
  }

  @override
  Widget build(BuildContext context) {
    final mood = (item['mood'] ?? 'Unknown').toString().toLowerCase();
    final emotion = item['emotion'] ?? '';
    final intensity = (item['intensity'] as num?)?.toDouble() ?? 0.0;
    final dateStr = item['created_at'] ?? '';
    final date = DateTime.tryParse(dateStr)?.toLocal();
    final color = _getMoodColor(mood);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.circle, color: color, size: 12),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mood.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    if (date != null)
                      Text(
                        DateFormat('MMM d, h:mm a').format(date),
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                if (emotion.isNotEmpty && emotion.toLowerCase() != mood) ...[
                  const SizedBox(height: 4),
                  Text(
                    emotion,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Mini intensity indicator
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                (intensity * 10).toStringAsFixed(1),
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 30,
                width: 4,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      heightFactor: intensity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
