import 'dart:async';
import 'package:get_it/get_it.dart';
import '../models/story_analytics.dart';
import '../repositories/story_sentence_repository.dart';
import '../../../core/logger.dart';

/// StoryAnalyticsService - Service for generating and managing story analytics
class StoryAnalyticsService {
  final StorySentenceRepository _sentenceRepository;

  StoryAnalyticsService() : _sentenceRepository = GetIt.I<StorySentenceRepository>();

  /// Generate comprehensive analytics for a story room
  Future<StoryAnalytics> generateAnalytics(String roomId) async {
    try {
      logger.d('[AnalyticsService] Generating analytics for room: $roomId');

      // Fetch all sentences for the room
      final sentencesStream = _sentenceRepository.getSentences(roomId);
      final sentences = await sentencesStream.first; // Get current snapshot

      // Generate analytics from sentences
      final analytics = StoryAnalytics.fromSentences(roomId, sentences);

      logger.d(
        '[AnalyticsService] Generated analytics: ${analytics.totalSentences} sentences, ${analytics.participantCount} participants',
      );
      return analytics;
    } catch (e, stackTrace) {
      logger.e(
        '[AnalyticsService] Failed to generate analytics: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return StoryAnalytics.empty(roomId);
    }
  }

  /// Get basic statistics for a story room (lighter weight than full analytics)
  Future<BasicStoryStats> getBasicStats(String roomId) async {
    try {
      final sentencesStream = _sentenceRepository.getSentences(roomId);
      final sentences = await sentencesStream.first;

      if (sentences.isEmpty) {
        return BasicStoryStats.empty(roomId);
      }

      final totalSentences = sentences.length;
      final totalWords = sentences.fold(
        0,
        (acc, sentence) =>
            acc + sentence.content.split(' ').where((word) => word.isNotEmpty).length,
      );
      final participants = sentences.map((s) => s.authorNickname).toSet();
      final participantCount = participants.length;
      final firstSentence = sentences.first;
      final lastSentence = sentences.last;
      final writingDuration = lastSentence.createdAt.difference(firstSentence.createdAt);

      return BasicStoryStats(
        roomId: roomId,
        totalSentences: totalSentences,
        totalWords: totalWords,
        participantCount: participantCount,
        firstSentenceAt: firstSentence.createdAt,
        lastSentenceAt: lastSentence.createdAt,
        writingDuration: writingDuration,
        averageWordsPerSentence: totalWords / totalSentences,
      );
    } catch (e, stackTrace) {
      logger.e(
        '[AnalyticsService] Failed to get basic stats: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return BasicStoryStats.empty(roomId);
    }
  }

  /// Get participant contributions summary
  Future<List<ParticipantSummary>> getParticipantSummaries(String roomId) async {
    try {
      final sentencesStream = _sentenceRepository.getSentences(roomId);
      final sentences = await sentencesStream.first;

      final contributions = <String, ParticipantSummary>{};

      for (final sentence in sentences) {
        final nickname = sentence.authorNickname;
        if (!contributions.containsKey(nickname)) {
          final words = sentence.content.split(' ').where((word) => word.isNotEmpty).length;
          contributions[nickname] = ParticipantSummary(
            nickname: nickname,
            sentenceCount: 1,
            wordCount: words,
            firstContributionAt: sentence.createdAt,
            lastContributionAt: sentence.createdAt,
          );
        } else {
          final summary = contributions[nickname]!;
          final words = sentence.content.split(' ').where((word) => word.isNotEmpty).length;
          contributions[nickname] = summary.copyWith(
            sentenceCount: summary.sentenceCount + 1,
            wordCount: summary.wordCount + words,
            lastContributionAt: sentence.createdAt,
          );
        }
      }

      final summaries = contributions.values.toList();
      summaries.sort((a, b) => b.sentenceCount.compareTo(a.sentenceCount));

      return summaries;
    } catch (e, stackTrace) {
      logger.e(
        '[AnalyticsService] Failed to get participant summaries: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get writing timeline data
  Future<List<TimelinePoint>> getWritingTimeline(String roomId) async {
    try {
      final sentencesStream = _sentenceRepository.getSentences(roomId);
      final sentences = await sentencesStream.first;

      final dailyStats = <String, TimelinePoint>{};

      for (final sentence in sentences) {
        final dayKey =
            '${sentence.createdAt.year}-${sentence.createdAt.month.toString().padLeft(2, '0')}-${sentence.createdAt.day.toString().padLeft(2, '0')}';

        if (!dailyStats.containsKey(dayKey)) {
          dailyStats[dayKey] = TimelinePoint(
            date: DateTime(
              sentence.createdAt.year,
              sentence.createdAt.month,
              sentence.createdAt.day,
            ),
            sentenceCount: 1,
            wordCount: sentence.content.split(' ').where((word) => word.isNotEmpty).length,
            participantCount: 1,
          );
        } else {
          final point = dailyStats[dayKey]!;
          dailyStats[dayKey] = point.copyWith(
            sentenceCount: point.sentenceCount + 1,
            wordCount:
                point.wordCount +
                sentence.content.split(' ').where((word) => word.isNotEmpty).length,
          );
        }
      }

      final timeline = dailyStats.values.toList();
      timeline.sort((a, b) => a.date.compareTo(b.date));

      return timeline;
    } catch (e, stackTrace) {
      logger.e(
        '[AnalyticsService] Failed to get writing timeline: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get most active hours for writing
  Future<Map<int, int>> getActiveHours(String roomId) async {
    try {
      final sentencesStream = _sentenceRepository.getSentences(roomId);
      final sentences = await sentencesStream.first;

      final hourStats = <int, int>{};

      for (final sentence in sentences) {
        final hour = sentence.createdAt.hour;
        hourStats[hour] = (hourStats[hour] ?? 0) + 1;
      }

      return hourStats;
    } catch (e, stackTrace) {
      logger.e(
        '[AnalyticsService] Failed to get active hours: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  /// Get writing streaks and patterns
  Future<WritingStreaks> getWritingStreaks(String roomId) async {
    try {
      final sentencesStream = _sentenceRepository.getSentences(roomId);
      final sentences = await sentencesStream.first;

      if (sentences.isEmpty) {
        return WritingStreaks.empty();
      }

      sentences.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final activeDays = <String>{};
      for (final sentence in sentences) {
        final dayKey =
            '${sentence.createdAt.year}-${sentence.createdAt.month.toString().padLeft(2, '0')}-${sentence.createdAt.day.toString().padLeft(2, '0')}';
        activeDays.add(dayKey);
      }

      final sortedDays = activeDays.toList()..sort();

      // Calculate longest streak
      int longestStreak = 1;
      int currentStreak = 1;

      for (int i = 1; i < sortedDays.length; i++) {
        final prevDate = DateTime.parse(sortedDays[i - 1]);
        final currDate = DateTime.parse(sortedDays[i]);
        final daysDiff = currDate.difference(prevDate).inDays;

        if (daysDiff == 1) {
          currentStreak++;
          longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
        } else {
          currentStreak = 1;
        }
      }

      // Calculate current streak
      int currentStreakDays = 1;
      final today = DateTime.now();
      var lastActiveDate = DateTime.parse(sortedDays.last);

      if (lastActiveDate.year == today.year &&
          lastActiveDate.month == today.month &&
          lastActiveDate.day == today.day) {
        // Today is active, count backwards
        for (int i = sortedDays.length - 2; i >= 0; i--) {
          final prevDate = DateTime.parse(sortedDays[i]);
          final daysDiff = lastActiveDate.difference(prevDate).inDays;
          if (daysDiff == currentStreakDays) {
            currentStreakDays++;
            lastActiveDate = prevDate;
          } else {
            break;
          }
        }
      } else {
        currentStreakDays = 0; // No current streak
      }

      return WritingStreaks(
        longestStreak: longestStreak,
        currentStreak: currentStreakDays,
        totalActiveDays: activeDays.length,
        averageContributionsPerActiveDay: sentences.length / activeDays.length,
      );
    } catch (e, stackTrace) {
      logger.e(
        '[AnalyticsService] Failed to get writing streaks: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return WritingStreaks.empty();
    }
  }
}

/// Basic statistics for quick display
class BasicStoryStats {
  final String roomId;
  final int totalSentences;
  final int totalWords;
  final int participantCount;
  final DateTime firstSentenceAt;
  final DateTime lastSentenceAt;
  final Duration writingDuration;
  final double averageWordsPerSentence;

  BasicStoryStats({
    required this.roomId,
    required this.totalSentences,
    required this.totalWords,
    required this.participantCount,
    required this.firstSentenceAt,
    required this.lastSentenceAt,
    required this.writingDuration,
    required this.averageWordsPerSentence,
  });

  factory BasicStoryStats.empty(String roomId) {
    return BasicStoryStats(
      roomId: roomId,
      totalSentences: 0,
      totalWords: 0,
      participantCount: 0,
      firstSentenceAt: DateTime.now(),
      lastSentenceAt: DateTime.now(),
      writingDuration: Duration.zero,
      averageWordsPerSentence: 0,
    );
  }
}

/// Simplified participant summary
class ParticipantSummary {
  final String nickname;
  final int sentenceCount;
  final int wordCount;
  final DateTime firstContributionAt;
  final DateTime lastContributionAt;

  ParticipantSummary({
    required this.nickname,
    required this.sentenceCount,
    required this.wordCount,
    required this.firstContributionAt,
    required this.lastContributionAt,
  });

  double get percentageOfTotalSentences => 0; // Will be calculated when used

  ParticipantSummary copyWith({
    String? nickname,
    int? sentenceCount,
    int? wordCount,
    DateTime? firstContributionAt,
    DateTime? lastContributionAt,
  }) {
    return ParticipantSummary(
      nickname: nickname ?? this.nickname,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      wordCount: wordCount ?? this.wordCount,
      firstContributionAt: firstContributionAt ?? this.firstContributionAt,
      lastContributionAt: lastContributionAt ?? this.lastContributionAt,
    );
  }
}

/// Timeline point for daily statistics
class TimelinePoint {
  final DateTime date;
  final int sentenceCount;
  final int wordCount;
  final int participantCount;

  TimelinePoint({
    required this.date,
    required this.sentenceCount,
    required this.wordCount,
    required this.participantCount,
  });

  TimelinePoint copyWith({
    DateTime? date,
    int? sentenceCount,
    int? wordCount,
    int? participantCount,
  }) {
    return TimelinePoint(
      date: date ?? this.date,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      wordCount: wordCount ?? this.wordCount,
      participantCount: participantCount ?? this.participantCount,
    );
  }
}

/// Writing streak information
class WritingStreaks {
  final int longestStreak;
  final int currentStreak;
  final int totalActiveDays;
  final double averageContributionsPerActiveDay;

  WritingStreaks({
    required this.longestStreak,
    required this.currentStreak,
    required this.totalActiveDays,
    required this.averageContributionsPerActiveDay,
  });

  factory WritingStreaks.empty() {
    return WritingStreaks(
      longestStreak: 0,
      currentStreak: 0,
      totalActiveDays: 0,
      averageContributionsPerActiveDay: 0,
    );
  }
}
