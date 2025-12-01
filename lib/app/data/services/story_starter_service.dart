import 'dart:math';
import '../models/story_starter.dart';

class StoryStarterService {
  static final StoryStarterService _instance = StoryStarterService._internal();
  factory StoryStarterService() => _instance;
  StoryStarterService._internal();

  final Random _random = Random();

  // 다양한 카테고리의 시작점 데이터베이스
  final List<StoryStarter> _storyStarters = [
    // 모험/판타지 카테고리
    _starter('모험', '오래된 지도의 따라 만나는 숨겨진 보물', 'sf1'),
    _starter('모험', '마법사가 된 평범한 학생', 'sf2'),
    _starter('모험', '타임머신을 발견한 고등학생', 'sf3'),
    _starter('판타지', '용의 알을 구원하는 평민 소년', 'fs1'),
    _starter('판타지', '세계수 깊은 곳에서 깨어난 자', 'fs2'),
    _starter('판타지', '마법서의 마지막 페이지에 숨겨진 비밀', 'fs3'),
    _starter('모험', '버려진 요령에서 발견한 시간여행 기계', 'sf4'),
    _starter('모험', '도시의 숨겨진 지하도시 탐험', 'sf5'),

    // 로맨스 카테고리
    _starter('로맨스', '비 오는 날 카페에서 만난 타인의 추억', 'ro1'),
    _starter('로맨스', '이사를 온 집의 이웃과 처음 보는 눈빛', 'ro2'),
    _starter('로맨스', '혼자 남은 도서관의 야간 경비원', 'ro3'),
    _starter('로맨스', '헤어진 지 10년 후의 첫 이메일', 'ro4'),
    _starter('로맨스', '버스 정류장에서 우연히 만난 옛 연인', 'ro5'),
    _starter('로맨스', '고향으로 돌아온 선배의 커피 전문점', 'ro6'),

    // 미스터리/스릴러 카테고리
    _starter('미스터리', '자택에서 발견한 낯선 사람의 사진', 'mi1'),
    _starter('미스터리', '밤마다 같은 꿈을 꾸는 소녀', 'mi2'),
    _starter('미스터리', '사라진 친구에게서 온 마지막 문자', 'mi3'),
    _starter('스릴러', '혼자 남은 연구실에서 들려오는 목소리', 'th1'),
    _starter('스릴러', '정상에선 절벽 아래가 더 안전해 보였지만...', 'th2'),
    _starter('미스터리', '모든 시계가 동시에 멈춘 날의 비밀', 'mi4'),
    _starter('스릴러', '완전히 동일한 두 개의 집', 'th3'),

    // 일상/드라마 카테고리
    _starter('드라마', '마지막 열차를 놓친 기숙사생', 'dr1'),
    _starter('드라마', '할머니가 남긴 상자 속의 젊음', 'dr2'),
    _starter('일상', '내일은 내일의 자신이 할 일', 'dl1'),
    _starter('일상', '카페에서 마주한 나이든 나', 'dl2'),
    _starter('드라마', '첫 직장에서 만난 특별한 동료', 'dr3'),
    _starter('드라마', '아버지의 재킷口袋에서 발견한 과거', 'dr4'),

    // 공포 카테고리
    _starter('공포', '새로 이사온 집의 13호는 비어있지만...', 'ho1'),
    _starter('공포', '사진 속 아이가 우리집 아이와 너무 닮았지만...', 'ho2'),
    _starter('공포', '자정이 지나면 작동하지 않는 엘리베이터', 'ho3'),
    _starter('공포', '거울 속에서는 내가 아닌 다른 누군가가 있다', 'ho4'),

    // SF 카테고리
    _starter('SF', '첫 인공지능이 사랑한다고 말한 날', 'sc1'),
    _starter('SF', '2030년, 인간과 기계의 경계가 모호해지는 순간', 'sc2'),
    _starter('SF', '우주선이 고장나 떠다니는 무인도에서', 'sc3'),
    _starter('SF', '미래에서 온 편지를 받은 오늘', 'sc4'),
    _starter('SF', '기억을 판매하는 가게에서', 'sc5'),

    // 판타지 카테고리 (추가)
    _starter('판타지', '마법사가 아닌 평범한 내가 갑자기 강력한 주문学会了', 'fs4'),
    _starter('판타지', '게임 속 캐릭터가 현실로 뛰어나와 나를 만나러 왔다', 'fs5'),
    _starter('판타지', '아버지가 남긴 유품에서 발견한 신비한 문장', 'fs6'),
    _starter('판타지', '꿈 속에서만 만날 수 있는 마법사', 'fs7'),
    _starter('판타지', '날마다 다른 능력을 갖는 하루', 'fs8'),
  ];

  static StoryStarter _starter(String genre, String content, String id) {
    return StoryStarter(id: id, genre: genre, content: content);
  }

  /// 랜덤 스토리 시작점을 반환합니다.
  StoryStarter getRandomStarter() {
    if (_storyStarters.isEmpty) {
      return StoryStarter(id: 'default', genre: '모험', content: '어느 날, 평범했던 일상이 완전히 뒤집어졌습니다.');
    }
    return _storyStarters[_random.nextInt(_storyStarters.length)];
  }

  /// 특정 장르의 랜덤 시작점을 반환합니다.
  StoryStarter getRandomStarterByGenre(String genre) {
    final List<StoryStarter> genreStarters =
        _storyStarters.where((starter) => starter.genre == genre).toList();

    if (genreStarters.isEmpty) {
      return getRandomStarter(); // 해당 장르가 없으면 전체에서 선택
    }

    return genreStarters[_random.nextInt(genreStarters.length)];
  }

  /// 사용 가능한 모든 장르 목록을 반환합니다.
  List<String> getAvailableGenres() {
    return _storyStarters.map((starter) => starter.genre).toSet().toList();
  }

  /// 장르별 시작점 개수를 반환합니다.
  Map<String, int> getGenreCount() {
    final Map<String, int> count = {};
    for (final starter in _storyStarters) {
      count[starter.genre] = (count[starter.genre] ?? 0) + 1;
    }
    return count;
  }

  /// 모든 시작점을 장르별로 그룹화하여 반환합니다.
  Map<String, List<StoryStarter>> getStartersByGenre() {
    final Map<String, List<StoryStarter>> grouped = {};
    for (final starter in _storyStarters) {
      if (!grouped.containsKey(starter.genre)) {
        grouped[starter.genre] = [];
      }
      grouped[starter.genre]!.add(starter);
    }
    return grouped;
  }
}
