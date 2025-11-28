import 'story_sentence.dart';

/// StoryAnalytics - Comprehensive analytics for collaborative stories
class StoryAnalytics {
  final String roomId;
  final DateTime generatedAt;

  // Basic Statistics
  final int totalSentences;
  final int totalWords;
  final int totalCharacters;
  final int participantCount;
  final Duration totalWritingTime;
  final DateTime firstSentenceAt;
  final DateTime lastSentenceAt;

  // Writing Patterns
  final List<WritingSession> writingSessions;
  final Map<String, ParticipantContribution> participantContributions;
  final List<TimelineDataPoint> timelineData;
  final WritingPatterns writingPatterns;

  // Content Analysis
  final List<String> mostCommonWords;
  final double averageSentenceLength;
  final double averageWordsPerSentence;
  final double readingTimeMinutes;

  // Engagement Metrics
  final Duration averageTimeBetweenContributions;
  final Map<int, int> sentencesByHourOfDay;
  final Map<String, int> sentencesByDayOfWeek;
  final double contributionDistribution; // How evenly distributed contributions are

  StoryAnalytics({
    required this.roomId,
    required this.generatedAt,
    required this.totalSentences,
    required this.totalWords,
    required this.totalCharacters,
    required this.participantCount,
    required this.totalWritingTime,
    required this.firstSentenceAt,
    required this.lastSentenceAt,
    required this.writingSessions,
    required this.participantContributions,
    required this.timelineData,
    required this.writingPatterns,
    required this.mostCommonWords,
    required this.averageSentenceLength,
    required this.averageWordsPerSentence,
    required this.readingTimeMinutes,
    required this.averageTimeBetweenContributions,
    required this.sentencesByHourOfDay,
    required this.sentencesByDayOfWeek,
    required this.contributionDistribution,
  });

  factory StoryAnalytics.fromSentences(String roomId, List<StorySentence> sentences) {
    if (sentences.isEmpty) {
      return StoryAnalytics.empty(roomId);
    }

    // Sort sentences by order
    sentences.sort((a, b) => a.order.compareTo(b.order));

    // Basic calculations
    final totalSentences = sentences.length;
    final totalWords = sentences.fold(
      0,
      (acc, sentence) => acc + sentence.content.split(' ').where((word) => word.isNotEmpty).length,
    );
    final totalCharacters = sentences.fold(
      0,
      (acc, sentence) => acc + sentence.content.replaceAll(' ', '').length,
    );
    final participants = sentences.map((s) => s.authorNickname).toSet();
    final participantCount = participants.length;

    final firstSentenceAt = sentences.first.createdAt;
    final lastSentenceAt = sentences.last.createdAt;
    final totalWritingTime = lastSentenceAt.difference(firstSentenceAt);

    // Calculate writing sessions (periods of active writing)
    final writingSessions = _calculateWritingSessions(sentences);

    // Participant contributions
    final participantContributions = _calculateParticipantContributions(sentences);

    // Timeline data
    final timelineData = _calculateTimelineData(sentences);

    // Writing patterns
    final writingPatterns = _calculateWritingPatterns(sentences);

    // Content analysis
    final mostCommonWords = _getMostCommonWords(sentences);
    final averageSentenceLength = totalCharacters / totalSentences;
    final averageWordsPerSentence = totalWords / totalSentences;
    final readingTimeMinutes = totalWords / 200; // Average reading speed: 200 words per minute

    // Engagement metrics
    final averageTimeBetweenContributions = _calculateAverageTimeBetweenContributions(sentences);
    final sentencesByHourOfDay = _calculateSentencesByHour(sentences);
    final sentencesByDayOfWeek = _calculateSentencesByDayOfWeek(sentences);
    final contributionDistribution = _calculateContributionDistribution(participantContributions);

    return StoryAnalytics(
      roomId: roomId,
      generatedAt: DateTime.now(),
      totalSentences: totalSentences,
      totalWords: totalWords,
      totalCharacters: totalCharacters,
      participantCount: participantCount,
      totalWritingTime: totalWritingTime,
      firstSentenceAt: firstSentenceAt,
      lastSentenceAt: lastSentenceAt,
      writingSessions: writingSessions,
      participantContributions: participantContributions,
      timelineData: timelineData,
      writingPatterns: writingPatterns,
      mostCommonWords: mostCommonWords,
      averageSentenceLength: averageSentenceLength,
      averageWordsPerSentence: averageWordsPerSentence,
      readingTimeMinutes: readingTimeMinutes,
      averageTimeBetweenContributions: averageTimeBetweenContributions,
      sentencesByHourOfDay: sentencesByHourOfDay,
      sentencesByDayOfWeek: sentencesByDayOfWeek,
      contributionDistribution: contributionDistribution,
    );
  }

  factory StoryAnalytics.empty(String roomId) {
    return StoryAnalytics(
      roomId: roomId,
      generatedAt: DateTime.now(),
      totalSentences: 0,
      totalWords: 0,
      totalCharacters: 0,
      participantCount: 0,
      totalWritingTime: Duration.zero,
      firstSentenceAt: DateTime.now(),
      lastSentenceAt: DateTime.now(),
      writingSessions: [],
      participantContributions: {},
      timelineData: [],
      writingPatterns: WritingPatterns.empty(),
      mostCommonWords: [],
      averageSentenceLength: 0,
      averageWordsPerSentence: 0,
      readingTimeMinutes: 0,
      averageTimeBetweenContributions: Duration.zero,
      sentencesByHourOfDay: {},
      sentencesByDayOfWeek: {},
      contributionDistribution: 0,
    );
  }

  // Helper methods for calculations
  static List<WritingSession> _calculateWritingSessions(List<StorySentence> sentences) {
    if (sentences.isEmpty) return [];

    final sessions = <WritingSession>[];
    var currentSession = WritingSession(
      startTime: sentences.first.createdAt,
      endTime: sentences.first.createdAt,
      sentenceCount: 1,
      participantCount: 1,
    );

    final seenParticipants = <String>{sentences.first.authorNickname};

    for (int i = 1; i < sentences.length; i++) {
      final current = sentences[i];
      final previous = sentences[i - 1];
      final timeDiff = current.createdAt.difference(previous.createdAt);

      // If more than 30 minutes between sentences, start a new session
      if (timeDiff > const Duration(minutes: 30)) {
        sessions.add(currentSession);
        currentSession = WritingSession(
          startTime: current.createdAt,
          endTime: current.createdAt,
          sentenceCount: 1,
          participantCount: 1,
        );
        seenParticipants.clear();
        seenParticipants.add(current.authorNickname);
      } else {
        currentSession = currentSession.copyWith(
          endTime: current.createdAt,
          sentenceCount: currentSession.sentenceCount + 1,
        );
        seenParticipants.add(current.authorNickname);
        currentSession = currentSession.copyWith(participantCount: seenParticipants.length);
      }
    }

    sessions.add(currentSession);
    return sessions;
  }

  static Map<String, ParticipantContribution> _calculateParticipantContributions(
    List<StorySentence> sentences,
  ) {
    final contributions = <String, ParticipantContribution>{};

    for (final sentence in sentences) {
      final nickname = sentence.authorNickname;
      if (!contributions.containsKey(nickname)) {
        contributions[nickname] = ParticipantContribution(
          nickname: nickname,
          sentenceCount: 0,
          wordCount: 0,
          characterCount: 0,
          firstContributionAt: sentence.createdAt,
          lastContributionAt: sentence.createdAt,
          totalContributionTime: Duration.zero,
        );
      }

      final contribution = contributions[nickname]!;
      final words = sentence.content.split(' ').where((word) => word.isNotEmpty).length;
      final characters = sentence.content.replaceAll(' ', '').length;

      contributions[nickname] = contribution.copyWith(
        sentenceCount: contribution.sentenceCount + 1,
        wordCount: contribution.wordCount + words,
        characterCount: contribution.characterCount + characters,
        lastContributionAt: sentence.createdAt,
      );
    }

    return contributions;
  }

  static List<TimelineDataPoint> _calculateTimelineData(List<StorySentence> sentences) {
    if (sentences.isEmpty) return [];

    final timeline = <TimelineDataPoint>[];
    final sentencesByDay = <String, int>{};

    for (final sentence in sentences) {
      final dayKey =
          '${sentence.createdAt.year}-${sentence.createdAt.month.toString().padLeft(2, '0')}-${sentence.createdAt.day.toString().padLeft(2, '0')}';
      sentencesByDay[dayKey] = (sentencesByDay[dayKey] ?? 0) + 1;
    }

    final sortedDays = sentencesByDay.keys.toList()..sort();

    for (final day in sortedDays) {
      final parts = day.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      timeline.add(
        TimelineDataPoint(
          date: date,
          sentenceCount: sentencesByDay[day]!,
          cumulativeSentenceCount:
              timeline.isEmpty
                  ? sentencesByDay[day]!
                  : timeline.last.cumulativeSentenceCount + sentencesByDay[day]!,
        ),
      );
    }

    return timeline;
  }

  static WritingPatterns _calculateWritingPatterns(List<StorySentence> sentences) {
    if (sentences.isEmpty) return WritingPatterns.empty();

    final sentenceLengths = sentences.map((s) => s.content.length).toList();
    final wordCounts =
        sentences.map((s) => s.content.split(' ').where((word) => word.isNotEmpty).length).toList();

    sentenceLengths.sort();
    wordCounts.sort();

    return WritingPatterns(
      shortestSentenceLength: sentenceLengths.first,
      longestSentenceLength: sentenceLengths.last,
      medianSentenceLength: sentenceLengths[sentenceLengths.length ~/ 2],
      shortestWordCount: wordCounts.first,
      longestWordCount: wordCounts.last,
      medianWordCount: wordCounts[wordCounts.length ~/ 2],
    );
  }

  static List<String> _getMostCommonWords(List<StorySentence> sentences, {int count = 10}) {
    final wordCount = <String, int>{};

    for (final sentence in sentences) {
      final words =
          sentence.content
              .toLowerCase()
              .replaceAll(RegExp(r'[^\w\s]'), ' ')
              .split(RegExp(r'\s+'))
              .where((word) => word.isNotEmpty && word.length > 2)
              .toList();

      for (final word in words) {
        wordCount[word] = (wordCount[word] ?? 0) + 1;
      }
    }

    final sortedWords = wordCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedWords.take(count).map((entry) => entry.key).toList();
  }

  static Duration _calculateAverageTimeBetweenContributions(List<StorySentence> sentences) {
    if (sentences.length < 2) return Duration.zero;

    final intervals = <Duration>[];
    for (int i = 1; i < sentences.length; i++) {
      final interval = sentences[i].createdAt.difference(sentences[i - 1].createdAt);
      intervals.add(interval);
    }

    final totalDuration = intervals.fold(Duration.zero, (acc, interval) => acc + interval);
    return Duration(milliseconds: totalDuration.inMilliseconds ~/ intervals.length);
  }

  static Map<int, int> _calculateSentencesByHour(List<StorySentence> sentences) {
    final byHour = <int, int>{};
    for (final sentence in sentences) {
      final hour = sentence.createdAt.hour;
      byHour[hour] = (byHour[hour] ?? 0) + 1;
    }
    return byHour;
  }

  static Map<String, int> _calculateSentencesByDayOfWeek(List<StorySentence> sentences) {
    final byDay = <String, int>{};
    const days = ['월', '화', '水', '목', '금', '토', '일'];

    for (final sentence in sentences) {
      final dayIndex = sentence.createdAt.weekday - 1; // Monday = 0
      final dayName = days[dayIndex];
      byDay[dayName] = (byDay[dayName] ?? 0) + 1;
    }
    return byDay;
  }

  static double _calculateContributionDistribution(
    Map<String, ParticipantContribution> contributions,
  ) {
    if (contributions.isEmpty) return 0;

    final sentenceCounts = contributions.values.map((c) => c.sentenceCount).toList();
    final mean = sentenceCounts.reduce((a, b) => a + b) / sentenceCounts.length;
    final variance =
        sentenceCounts.fold(0.0, (acc, cnt) => acc + (cnt - mean) * (cnt - mean)) /
        sentenceCounts.length;

    // Return coefficient of variation (lower = more evenly distributed)
    return variance / (mean * mean);
  }
}

class WritingSession {
  final DateTime startTime;
  final DateTime endTime;
  final int sentenceCount;
  final int participantCount;

  WritingSession({
    required this.startTime,
    required this.endTime,
    required this.sentenceCount,
    required this.participantCount,
  });

  Duration get duration => endTime.difference(startTime);

  WritingSession copyWith({
    DateTime? startTime,
    DateTime? endTime,
    int? sentenceCount,
    int? participantCount,
  }) {
    return WritingSession(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      participantCount: participantCount ?? this.participantCount,
    );
  }
}

class ParticipantContribution {
  final String nickname;
  final int sentenceCount;
  final int wordCount;
  final int characterCount;
  final DateTime firstContributionAt;
  final DateTime lastContributionAt;
  final Duration totalContributionTime;

  ParticipantContribution({
    required this.nickname,
    required this.sentenceCount,
    required this.wordCount,
    required this.characterCount,
    required this.firstContributionAt,
    required this.lastContributionAt,
    required this.totalContributionTime,
  });

  double get percentageOfTotalContributions => 0; // Will be calculated when analytics are generated

  ParticipantContribution copyWith({
    String? nickname,
    int? sentenceCount,
    int? wordCount,
    int? characterCount,
    DateTime? firstContributionAt,
    DateTime? lastContributionAt,
    Duration? totalContributionTime,
  }) {
    return ParticipantContribution(
      nickname: nickname ?? this.nickname,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      wordCount: wordCount ?? this.wordCount,
      characterCount: characterCount ?? this.characterCount,
      firstContributionAt: firstContributionAt ?? this.firstContributionAt,
      lastContributionAt: lastContributionAt ?? this.lastContributionAt,
      totalContributionTime: totalContributionTime ?? this.totalContributionTime,
    );
  }
}

class TimelineDataPoint {
  final DateTime date;
  final int sentenceCount;
  final int cumulativeSentenceCount;

  TimelineDataPoint({
    required this.date,
    required this.sentenceCount,
    required this.cumulativeSentenceCount,
  });
}

class WritingPatterns {
  final int shortestSentenceLength;
  final int longestSentenceLength;
  final int medianSentenceLength;
  final int shortestWordCount;
  final int longestWordCount;
  final int medianWordCount;

  WritingPatterns({
    required this.shortestSentenceLength,
    required this.longestSentenceLength,
    required this.medianSentenceLength,
    required this.shortestWordCount,
    required this.longestWordCount,
    required this.medianWordCount,
  });

  factory WritingPatterns.empty() {
    return WritingPatterns(
      shortestSentenceLength: 0,
      longestSentenceLength: 0,
      medianSentenceLength: 0,
      shortestWordCount: 0,
      longestWordCount: 0,
      medianWordCount: 0,
    );
  }
}
