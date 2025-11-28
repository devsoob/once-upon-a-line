import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:once_upon_a_line/core/constants/app_colors.dart';
import 'package:once_upon_a_line/core/logger.dart';
import 'package:once_upon_a_line/core/widgets/app_toast.dart';
import 'package:once_upon_a_line/core/widgets/profile_icon.dart';
import 'package:once_upon_a_line/app/data/services/story_analytics_service.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/app/data/models/story_analytics.dart';

class StoryAnalyticsPage extends StatefulWidget {
  const StoryAnalyticsPage({super.key, required this.room});

  final StoryRoom room;

  @override
  State<StoryAnalyticsPage> createState() => _StoryAnalyticsPageState();
}

class _StoryAnalyticsPageState extends State<StoryAnalyticsPage> {
  late final StoryAnalyticsService _analyticsService;
  bool _isLoading = true;
  StoryAnalytics? _analytics;
  List<ParticipantSummary>? _participantSummaries;
  List<TimelinePoint>? _timelinePoints;
  Map<int, int>? _activeHours;
  WritingStreaks? _writingStreaks;

  @override
  void initState() {
    super.initState();
    _analyticsService = GetIt.I<StoryAnalyticsService>();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      // Load all analytics data concurrently
      final results = await Future.wait([
        _analyticsService.generateAnalytics(widget.room.id),
        _analyticsService.getParticipantSummaries(widget.room.id),
        _analyticsService.getWritingTimeline(widget.room.id),
        _analyticsService.getActiveHours(widget.room.id),
        _analyticsService.getWritingStreaks(widget.room.id),
      ]);

      setState(() {
        _analytics = results[0] as StoryAnalytics;
        _participantSummaries = results[1] as List<ParticipantSummary>;
        _timelinePoints = results[2] as List<TimelinePoint>;
        _activeHours = results[3] as Map<int, int>;
        _writingStreaks = results[4] as WritingStreaks;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      logger.e('[AnalyticsPage] Failed to load analytics: $e', error: e, stackTrace: stackTrace);
      if (mounted) {
        AppToast.show(context, '분석 데이터를 불러오는 중 오류가 발생했습니다.');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '이야기 분석',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _isLoading ? null : _loadAnalytics,
            tooltip: '새로고침',
          ),
        ],
      ),
      body:
          _isLoading ? const Center(child: CircularProgressIndicator()) : _buildAnalyticsContent(),
    );
  }

  Widget _buildAnalyticsContent() {
    if (_analytics == null || _analytics!.totalSentences == 0) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 20),
          _buildStatisticsGrid(),
          const SizedBox(height: 20),
          _buildParticipantContributions(),
          const SizedBox(height: 20),
          _buildWritingPatterns(),
          const SizedBox(height: 20),
          _buildTimelineChart(),
          const SizedBox(height: 20),
          _buildActiveHoursChart(),
          const SizedBox(height: 20),
          _buildWritingStreaksCard(),
          const SizedBox(height: 20),
          _buildWordAnalysisCard(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 분석할 데이터가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이야기에 참여하면 분석을 볼 수 있어요!',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    final analytics = _analytics!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이야기 분석 결과',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '실시간 협업 통계 및 인사이트',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetricItem(
                    '총 문장',
                    '${analytics.totalSentences}개',
                    Icons.edit_note,
                    const Color(0xFF4A90E2),
                  ),
                  const SizedBox(width: 12),
                  _buildMetricItem(
                    '총 단어',
                    '${analytics.totalWords}개',
                    Icons.text_fields,
                    const Color(0xFF7ED321),
                  ),
                  const SizedBox(width: 12),
                  _buildMetricItem(
                    '참여자',
                    '${analytics.participantCount}명',
                    Icons.group,
                    const Color(0xFFF5A623),
                  ),
                  const SizedBox(width: 12),
                  _buildMetricItem(
                    '작성 기간',
                    _formatDuration(analytics.totalWritingTime),
                    Icons.access_time,
                    const Color(0xFFBD10E0),
                  ),
                  const SizedBox(width: 12),
                  _buildMetricItem(
                    '독서 시간',
                    '${analytics.readingTimeMinutes.round()}분',
                    Icons.visibility,
                    const Color(0xFF50E3C2),
                  ),
                  const SizedBox(width: 12),
                  _buildMetricItem(
                    '평균 문장 길이',
                    '${analytics.averageSentenceLength.round()}자',
                    Icons.straighten,
                    const Color(0xFFB8E986),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      width: 120, // Fixed width for horizontal scroll
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    final analytics = _analytics!;
    final numberFormat = NumberFormat();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '상세 통계',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    '총 문자 수',
                    numberFormat.format(analytics.totalCharacters),
                    Icons.text_fields,
                  ),
                  _buildStatCard(
                    '평균 문장당 단어',
                    analytics.averageWordsPerSentence.toStringAsFixed(1),
                    Icons.analytics,
                  ),
                  _buildStatCard('작성 세션', '${analytics.writingSessions.length}회', Icons.timer),
                  _buildStatCard(
                    '참여 균형도',
                    '${(analytics.contributionDistribution * 100).toStringAsFixed(0)}%',
                    Icons.balance,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 80, maxHeight: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantContributions() {
    if (_participantSummaries == null || _participantSummaries!.isEmpty) {
      return const SizedBox.shrink();
    }

    final summaries = _participantSummaries!;
    final totalSentences = summaries.fold<int>(0, (sum, s) => sum + s.sentenceCount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '참여자 기여도',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...summaries.take(5).map((summary) => _buildParticipantBar(summary, totalSentences)),
            if (summaries.length > 5) ...[
              const SizedBox(height: 8),
              Text(
                '다른 참여자 ${summaries.length - 5}명...',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantBar(ParticipantSummary summary, int totalSentences) {
    final percentage = (summary.sentenceCount / totalSentences * 100).toStringAsFixed(1);
    final barWidth = double.parse(percentage) / 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ProfileIcon(size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      summary.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${summary.sentenceCount}개 ($percentage%)',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: barWidth.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWritingPatterns() {
    final analytics = _analytics!;
    final patterns = analytics.writingPatterns;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '작성 패턴',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildPatternItem(
                    '최단 문장',
                    '${patterns.shortestSentenceLength}자',
                    Icons.short_text,
                  ),
                  _buildPatternItem(
                    '최장 문장',
                    '${patterns.longestSentenceLength}자',
                    Icons.text_fields,
                  ),
                  _buildPatternItem('최소 단어', '${patterns.shortestWordCount}개', Icons.text_fields),
                  _buildPatternItem('최대 단어', '${patterns.longestWordCount}개', Icons.text_fields),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineChart() {
    if (_timelinePoints == null || _timelinePoints!.isEmpty) {
      return const SizedBox.shrink();
    }

    final points = _timelinePoints!;
    final maxSentences = points.fold<int>(0, (max, p) => math.max(max, p.sentenceCount));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '작성 타임라인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Y-axis labels
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$maxSentences',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${(maxSentences / 2).round()}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                      Text(
                        '0',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Chart area
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:
                          points.asMap().entries.map((entry) {
                            final point = entry.value;
                            final height = (point.sentenceCount / maxSentences * 100).toDouble();
                            final isToday = _isToday(point.date);

                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                height: height.toDouble(),
                                decoration: BoxDecoration(
                                  color:
                                      isToday ? const Color(0xFF667eea) : const Color(0xFFB8E986),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Tooltip(
                                  message:
                                      '${DateFormat('M/d').format(point.date)}: ${point.sentenceCount}개',
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // X-axis labels
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 32), // Account for Y-axis label space
                  ...points.take(7).map((point) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 84) / 7, // Responsive width
                      child: Text(
                        DateFormat('M/d').format(point.date),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveHoursChart() {
    if (_activeHours == null || _activeHours!.isEmpty) {
      return const SizedBox.shrink();
    }

    final hourStats = _activeHours!;
    final maxContributions = hourStats.values.fold<int>(0, math.max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '활동 시간대',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Y-axis label
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$maxContributions',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                      Text(
                        '0',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Chart area
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:
                          List.generate(24, (hour) {
                            final count = hourStats[hour] ?? 0;
                            final height =
                                maxContributions > 0
                                    ? (count / maxContributions * 100).toDouble()
                                    : 0;
                            final isEvening = hour >= 18 || hour <= 6;

                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0.5),
                                height: height.toDouble(),
                                decoration: BoxDecoration(
                                  color:
                                      isEvening ? const Color(0xFFF5A623) : const Color(0xFF4A90E2),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                child: Tooltip(
                                  message: '${hour.toString().padLeft(2, '0')}:00 - $count개',
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // X-axis labels
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 32), // Account for Y-axis label space
                  ...['0', '6', '12', '18', '23'].map((hour) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 84) / 5, // Responsive width
                      child: Text(
                        hour,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWritingStreaksCard() {
    if (_writingStreaks == null) return const SizedBox.shrink();

    final streaks = _writingStreaks!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '연속 작성 기록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  streaks.currentStreak > 0
                      ? Icons.local_fire_department
                      : Icons.local_fire_department_outlined,
                  color: streaks.currentStreak > 0 ? Colors.red : AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStreakItem(
                    '최장 기록',
                    '${streaks.longestStreak}일',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStreakItem(
                    '현재 기록',
                    '${streaks.currentStreak}일',
                    Icons.local_fire_department,
                    streaks.currentStreak > 0 ? Colors.red : Colors.grey,
                  ),
                ),
                Expanded(
                  child: _buildStreakItem(
                    '총 활동일',
                    '${streaks.totalActiveDays}일',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildWordAnalysisCard() {
    if (_analytics == null) return const SizedBox.shrink();

    final words = _analytics!.mostCommonWords.take(8).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '자주 사용된 단어',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      words.map((word) {
                        final colors = [
                          const Color(0xFF667eea),
                          const Color(0xFF764ba2),
                          const Color(0xFFF093fb),
                          const Color(0xFFF5576C),
                          const Color(0xFF4facfe),
                          const Color(0xFF00f2fe),
                          const Color(0xFF43e97b),
                          const Color(0xFF38f9d7),
                        ];
                        final color = colors[words.indexOf(word) % colors.length];

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    } else {
      return '방금 전';
    }
  }
}
