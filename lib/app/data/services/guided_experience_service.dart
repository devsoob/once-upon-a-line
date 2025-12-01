import 'package:flutter/material.dart';

class GuidedExperienceService {
  static final GuidedExperienceService _instance = GuidedExperienceService._internal();
  factory GuidedExperienceService() => _instance;
  GuidedExperienceService._internal();

  /// Writing prompts organized by difficulty and theme
  final Map<String, List<WritingPrompt>> _writingPrompts = {
    '시작하기': [
      WritingPrompt(
        id: 'beginner1',
        title: '나의 하루',
        description: '오늘 경험한 가장 인상적인 순간을 써보세요',
        difficulty: 'beginner',
        example: '아침에 기상했을 때의 기분부터 하루 종일의 생각을 정리해보세요.',
        tips: '구체적인 상황과 감정을 자세히 묘사하면 좋을 것 같아요.',
      ),
      WritingPrompt(
        id: 'beginner2',
        title: '마음에 드는 장소',
        description: '내가 가장 좋아하는 곳을 자세히 묘사해보세요',
        difficulty: 'beginner',
        example: '카페, 도서관, 공원 등에서 편안함을 느끼는 이유를 설명해보세요.',
        tips: '다섯 감각(시각, 청각, 후각, 촉각, 미각)을 활용해 보면 좋아요.',
      ),
      WritingPrompt(
        id: 'beginner3',
        title: '좋은 추억',
        description: '언제든지 떠올릴 수 있는 행복한 기억을 써보세요',
        difficulty: 'beginner',
        example: '가족과 함께한 여행이나 친구와의 특별한 순간을 생각해보세요.',
        tips: '그때의 기분과 함께 주변 사람들도 함께 묘사해보세요.',
      ),
    ],
    '상상력': [
      WritingPrompt(
        id: 'imagination1',
        title: '시간여행',
        description: '과거나 미래로 시간여행을 할 수 있다면 어디로 가고 싶나요?',
        difficulty: 'intermediate',
        example: '진시황 무덤을 방문하거나 2050년의 서울을 구경해보세요.',
        tips: '구체적인 상황과 인물을 묘사하면 더 생동감 있을 거예요.',
      ),
      WritingPrompt(
        id: 'imagination2',
        title: '마법 능력',
        description: '마법 능력을 하나 갖게 된다면 어떤 능력을 가져야 할까요?',
        difficulty: 'intermediate',
        example: '시간을 멈추거나 타인의 마음을 알 수 있는 능력 등을 상상해보세요.',
        tips: '그 능력으로 무엇을 할지, 그리고 어떤后果가 있을지 생각해보세요.',
      ),
      WritingPrompt(
        id: 'imagination3',
        title: '평행 세계',
        description: '다른 평행 세계의 나는 어떤 삶을 살고 있을까?',
        difficulty: 'advanced',
        example: '의사가 된 나, 예술가가 된 나, 여행가인 나 등을 상상해보세요.',
        tips: '그 세계의 환경을 함께 묘사하면更有趣할 거예요.',
      ),
    ],
    '도전 과제': [
      WritingPrompt(
        id: 'challenge1',
        title: '도전과제',
        description: '지금까지 해본 적 없는 새로운 활동을 시도해본다면?',
        difficulty: 'intermediate',
        example: '취미 삼아 그림이나 악기 연주, 요리 등을 시작하는 이야기.',
        tips: '처음의 부담감과 극복 과정을重点으로 묘사해보세요.',
      ),
      WritingPrompt(
        id: 'challenge2',
        title: '첫 직장',
        description: '첫 취직에서의 첫날 경험을 묘사해보세요',
        difficulty: 'intermediate',
        example: '새로운 동료들과의 만남, 업무 파악, 첫 실수 등 다양한 상황.',
        tips: '두려움과 기대감이 섞인복잡한 감정을 묘사해보세요.',
      ),
      WritingPrompt(
        id: 'challenge3',
        title: '혼자 여행',
        description: '첫 혼자 여행에서의 경험과 감정을 묘사해보세요',
        difficulty: 'advanced',
        example: '낯선 곳에서의 긴장감, 새로운 경험,자아발견의 과정.',
        tips: '환경 묘사와내심변화를 동시에 보여주면 좋아요.',
      ),
    ],
  };

  /// Beginner tutorials and guides
  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      id: 'step1',
      title: '이야기란 무엇인가?',
      content: '이야기는 우리가日常에서 경험하지 못하는 세계를 만들어가는 매력적인 예술입니다. 함께 이야기의 첫걸음을 뗘러봅시다!',
      icon: Icons.lightbulb_outline,
      tips: ['이야기는 사실이 아니어도 괜찮아요', '상상력을 충분히 발휘해보세요', '첫 이야기에는 특별한 테마가 없어도 좋아요'],
    ),
    TutorialStep(
      id: 'step2',
      title: '이야기 시작하기',
      content: '이야기를 시작하는 방법은 여러가지가 있습니다. 가장 자신 있는 방법으로 시작해보세요!',
      icon: Icons.play_circle_outline,
      tips: ['「그때는 아직 모를 있었습니다...」로 시작해보기', '특정 상황에서 시작하기 (도서관, 카페, 공원 등)', '인물 소개로 시작하기'],
    ),
    TutorialStep(
      id: 'step3',
      title: '이야기 전개하기',
      content: '이야기를 이어갈 때는 논리적이고 흥미진진하게 전개하는 것이 중요합니다.',
      icon: Icons.timeline,
      tips: ['이전 문장과 연결되는 자연스러운 흐름', '인물의 행동과 대화를 활용하기', '상황의 긴장감을 차근차근 높이기'],
    ),
    TutorialStep(
      id: 'step4',
      title: '완성하기',
      content: '이야기의 마무리도 중요합니다. 독자에게 만족스러운 느낌을 주는结尾을 만들어보세요!',
      icon: Icons.flag_outlined,
      tips: ['해결 가능한 문제로 마무리하기', '인물의 성장이나 변화 보여주기', '미래에 대한 상상으로 마무리하기'],
    ),
  ];

  /// Writing techniques and tips
  final List<WritingTip> _writingTips = [
    WritingTip(
      id: 'tip1',
      title: '다섯 감각 활용하기',
      description: '이야기에 생동감을 주기 위해 五感(시각, 청각, 후각, 촉각, 미각)을 활용해보세요.',
      example: '「해가 질 때 카페에서는 커피의 고소한 향과 경쾌한 재즈 선율이 어우러졌습니다.」',
      category: '描寫技巧',
    ),
    WritingTip(
      id: 'tip2',
      title: '인물의 마음描写하기',
      description: '인물의内心世界를描寫하면 독자가 더 깊게 몰입할 수 있습니다.',
      example: '「마음은 두근거렸지만 얼굴은 평온을 유지하려 애썼다.」',
      category: '인물描写',
    ),
    WritingTip(
      id: 'tip3',
      title: '대화를 활용하기',
      description: '인물 간의 대화를 통해 이야기를 진행하고 성격을描寫해보세요.',
      example: '「"정말 좋은 하루야." 영수는 웃으며 말했다. "당신도 그런 기분이 들었으면 좋겠어."」',
      category: '대화 활용',
    ),
    WritingTip(
      id: 'tip4',
      title: '상황 제시하기',
      description: '이야기가 일어나는 장소와 상황을 명확히 제시하면 독자가 더 잘 이해할 수 있습니다.',
      example: '「비 오는 날, 사람은 적어 보이는 도서관 한켠에서 소율은 펜을 잡고 있었습니다.」',
      category: '상황設定',
    ),
  ];

  /// Sample story templates
  final List<StoryTemplate> _storyTemplates = [
    StoryTemplate(
      id: 'template1',
      title: '완성도 높은 단편 소설',
      description: '인물의 성장과 변화를 담은 단편 소설 템플릿',
      structure: '도입 → 전개 → 위기 → 해결 → 결말',
      example: '「처음 도서관에 들어선 날, 나는 평소보다 조용함을 느꼈다. 그러나 그 조용함 속에서 무엇인가 다른 소리가 들렸다...」',
      estimatedLength: '300-500문장',
    ),
    StoryTemplate(
      id: 'template2',
      title: '모험 이야기',
      description: '주인공이 새로운 세계를 탐험하는 이야기',
      structure: '평상시 일상 → 특별한 사건 → 모험 시작 →試練 → 성장 → 귀환',
      example: '「평범한 고등학생이던 민수가 우연히 발견한 오래된 지도는 그를 전혀 다른 세계로 이끈 있었다...」',
      estimatedLength: '500-1000문장',
    ),
    StoryTemplate(
      id: 'template3',
      title: '일상생활의 기적',
      description: '일상생활에서 발견하는 작은 기적과 성장의 이야기',
      structure: '평범한 일상 → 작은 발견 →内心的 변화 →다른 시선 →새로운 시작',
      example: '「카페에서 매일 만나는 그 노인은 왜 그렇게 밝게 웃을 수 있을까요? 오늘은勇氣를 내어 물어보기로 했습니다.」',
      estimatedLength: '200-400문장',
    ),
  ];

  /// Get writing prompts by category
  List<WritingPrompt> getPromptsByCategory(String category) {
    return _writingPrompts[category] ?? [];
  }

  /// Get all available categories
  List<String> getPromptCategories() {
    return _writingPrompts.keys.toList();
  }

  /// Get prompts by difficulty level
  List<WritingPrompt> getPromptsByDifficulty(String difficulty) {
    return _writingPrompts.values
        .expand((prompts) => prompts)
        .where((prompt) => prompt.difficulty == difficulty)
        .toList();
  }

  /// Get all tutorial steps
  List<TutorialStep> getTutorialSteps() {
    return _tutorialSteps;
  }

  /// Get tutorial step by ID
  TutorialStep? getTutorialStep(String id) {
    try {
      return _tutorialSteps.firstWhere((step) => step.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all writing tips
  List<WritingTip> getWritingTips() {
    return _writingTips;
  }

  /// Get tips by category
  List<WritingTip> getTipsByCategory(String category) {
    return _writingTips.where((tip) => tip.category == category).toList();
  }

  /// Get all story templates
  List<StoryTemplate> getStoryTemplates() {
    return _storyTemplates;
  }

  /// Get template by ID
  StoryTemplate? getStoryTemplate(String id) {
    try {
      return _storyTemplates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is first-time (can be enhanced with user preferences)
  Future<bool> isFirstTimeUser() async {
    // TODO: Implement user preference checking
    // For now, return true to always show onboarding
    return true;
  }

  /// Mark user as experienced
  Future<void> markUserAsExperienced() async {
    // TODO: Save user preference to indicate they've seen onboarding
  }
}

// Data classes for guided experience
class WritingPrompt {
  final String id;
  final String title;
  final String description;
  final String difficulty; // beginner, intermediate, advanced
  final String example;
  final String tips;

  WritingPrompt({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.example,
    required this.tips,
  });
}

class TutorialStep {
  final String id;
  final String title;
  final String content;
  final IconData icon;
  final List<String> tips;

  TutorialStep({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.tips,
  });
}

class WritingTip {
  final String id;
  final String title;
  final String description;
  final String example;
  final String category;

  WritingTip({
    required this.id,
    required this.title,
    required this.description,
    required this.example,
    required this.category,
  });
}

class StoryTemplate {
  final String id;
  final String title;
  final String description;
  final String structure;
  final String example;
  final String estimatedLength;

  StoryTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.structure,
    required this.example,
    required this.estimatedLength,
  });
}
