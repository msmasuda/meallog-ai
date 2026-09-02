// lib/features/meal_record/data/food_label_mapper.dart

class FoodLabelMapping {
  const FoodLabelMapping({
    required this.primaryDishName,
    this.candidates = const [],
    this.ingredients = const [],
  });

  final String primaryDishName;
  final List<String> candidates;
  final List<String> ingredients;
}

class FoodLabelMapper {
  static const Map<String, FoodLabelMapping> _dictionary = {
    'curry': FoodLabelMapping(
      primaryDishName: 'カレーライス',
      candidates: ['カレーライス', 'キーマカレー', 'カツカレー'],
      ingredients: ['玉ねぎ', '人参', 'じゃがいも', '肉', 'カレールー'],
    ),
    'ramen': FoodLabelMapping(
      primaryDishName: 'ラーメン',
      candidates: ['醤油ラーメン', '味噌ラーメン', '豚骨ラーメン'],
      ingredients: ['中華麺', 'チャーシュー', 'ネギ', 'メンマ', '卵'],
    ),
    'noodle': FoodLabelMapping(
      primaryDishName: 'うどん・そば',
      candidates: ['うどん', 'そば', 'ラーメン', 'パスタ'],
      ingredients: ['麺', 'つゆ', 'ネギ'],
    ),
    'noodles': FoodLabelMapping(
      primaryDishName: '麺類',
      candidates: ['ラーメン', 'うどん', '焼きそば', 'パスタ'],
      ingredients: ['麺', 'ネギ', '具材'],
    ),
    'pasta': FoodLabelMapping(
      primaryDishName: 'パスタ',
      candidates: ['トマトパスタ', 'カルボナーラ', 'ペペロンチーノ', '和風パスタ'],
      ingredients: ['パスタ', 'オリーブオイル', 'トマト', 'ニンニク'],
    ),
    'spaghetti': FoodLabelMapping(
      primaryDishName: 'スパゲッティ',
      candidates: ['ミートソーススパゲッティ', 'ナポリタン', 'カルボナーラ'],
      ingredients: ['スパゲッティ', '玉ねぎ', 'トマトソース'],
    ),
    'pizza': FoodLabelMapping(
      primaryDishName: 'ピザ',
      candidates: ['マルゲリータピザ', 'ミックスピザ', 'チーズピザ'],
      ingredients: ['ピザ生地', 'チーズ', 'トマトソース', 'バジル'],
    ),
    'salad': FoodLabelMapping(
      primaryDishName: 'サラダ',
      candidates: ['グリーンサラダ', 'シーザーサラダ', 'ポテトサラダ'],
      ingredients: ['レタス', 'トマト', 'きゅうり', 'ドレッシング'],
    ),
    'sushi': FoodLabelMapping(
      primaryDishName: '寿司',
      candidates: ['にぎり寿司', '海鮮丼', '巻き寿司'],
      ingredients: ['酢飯', '魚介類', '海苔', '醤油'],
    ),
    'sashimi': FoodLabelMapping(
      primaryDishName: '刺身',
      candidates: ['刺身盛り合わせ', '海鮮丼'],
      ingredients: ['鮮魚', '大根のツマ', 'わさび', '醤油'],
    ),
    'hamburger': FoodLabelMapping(
      primaryDishName: 'ハンバーガー',
      candidates: ['ハンバーガー', 'チーズバーガー', 'テリヤキバーガー'],
      ingredients: ['バンズ', 'パティ', 'レタス', 'トマト', 'チーズ'],
    ),
    'burger': FoodLabelMapping(
      primaryDishName: 'ハンバーグ',
      candidates: ['デミグラスハンバーグ', '和風ハンバーグ', 'チーズハンバーグ'],
      ingredients: ['合い挽き肉', '玉ねぎ', 'パン粉', '卵'],
    ),
    'patty': FoodLabelMapping(
      primaryDishName: 'ハンバーグ',
      candidates: ['ハンバーグ', 'つくね'],
      ingredients: ['ひき肉', '玉ねぎ', '卵'],
    ),
    'steak': FoodLabelMapping(
      primaryDishName: 'ステーキ',
      candidates: ['ビーフステーキ', 'チキンステーキ', 'ポークソテー'],
      ingredients: ['肉', '塩コショウ', 'ステーキソース'],
    ),
    'sandwich': FoodLabelMapping(
      primaryDishName: 'サンドイッチ',
      candidates: ['たまごサンド', 'ハムレタスサンド', 'カツサンド'],
      ingredients: ['食パン', '卵', 'ハム', 'レタス', 'マヨネーズ'],
    ),
    'soup': FoodLabelMapping(
      primaryDishName: 'スープ・味噌汁',
      candidates: ['味噌汁', 'コーンスープ', 'コンソメスープ', '豚汁'],
      ingredients: ['豆腐', 'わかめ', 'ネギ', '出汁'],
    ),
    'rice': FoodLabelMapping(
      primaryDishName: 'ご飯もの',
      candidates: ['白ご飯', 'チャーハン', 'オムライス', '炊き込みご飯'],
      ingredients: ['お米', '卵', 'ネギ'],
    ),
    'fried rice': FoodLabelMapping(
      primaryDishName: 'チャーハン',
      candidates: ['炒飯', '五目チャーハン', 'キムチチャーハン'],
      ingredients: ['ご飯', '卵', 'ネギ', '焼豚', 'ごま油'],
    ),
    'dumpling': FoodLabelMapping(
      primaryDishName: '餃子',
      candidates: ['焼き餃子', '水餃子', '小籠包'],
      ingredients: ['餃子の皮', '豚ひき肉', 'キャベツ', 'ニラ', 'ニンニク'],
    ),
    'fried chicken': FoodLabelMapping(
      primaryDishName: '唐揚げ',
      candidates: ['鶏の唐揚げ', '竜田揚げ', 'チキン南蛮'],
      ingredients: ['鶏もも肉', '醤油', '生姜', '片栗粉'],
    ),
    'fish': FoodLabelMapping(
      primaryDishName: '焼き魚・煮魚',
      candidates: ['鮭の塩焼き', '鯖の味噌煮', 'アジの開き'],
      ingredients: ['魚', '醤油', 'みりん', '生姜'],
    ),
    'tofu': FoodLabelMapping(
      primaryDishName: '豆腐料理',
      candidates: ['冷奴', '麻婆豆腐', '湯豆腐', '揚げ出し豆腐'],
      ingredients: ['豆腐', 'ネギ', '生姜', '醤油'],
    ),
    'egg': FoodLabelMapping(
      primaryDishName: '卵料理',
      candidates: ['目玉焼き', '卵焼き', 'オムレツ', 'ゆで卵'],
      ingredients: ['卵', '油', '調味料'],
    ),
    'bread': FoodLabelMapping(
      primaryDishName: 'パン',
      candidates: ['トースト', 'クロワッサン', '総菜パン'],
      ingredients: ['パン', 'バター'],
    ),
    'dessert': FoodLabelMapping(
      primaryDishName: 'デザート・スイーツ',
      candidates: ['ケーキ', 'プリン', 'パフェ', 'アイスクリーム'],
      ingredients: ['砂糖', '生クリーム', 'フルーツ'],
    ),
    'cake': FoodLabelMapping(
      primaryDishName: 'ケーキ',
      candidates: ['ショートケーキ', 'チーズケーキ', 'チョコレートケーキ'],
      ingredients: ['小麦粉', '砂糖', '卵', '生クリーム'],
    ),
  };

  /// 検出されたラベル群から最適な料理名・候補・食材をマッピング
  static FoodLabelMapping? mapLabels(List<String> rawLabels) {
    for (final raw in rawLabels) {
      final normalized = raw.trim().toLowerCase();
      for (final entry in _dictionary.entries) {
        if (normalized == entry.key || normalized.contains(entry.key)) {
          return entry.value;
        }
      }
    }
    return null;
  }

  /// 複数の検出ラベルをまとめて総合的な候補リストを生成
  static List<String> extractAllCandidates(List<String> rawLabels) {
    final candidates = <String>{};
    for (final raw in rawLabels) {
      final normalized = raw.trim().toLowerCase();
      for (final entry in _dictionary.entries) {
        if (normalized == entry.key || normalized.contains(entry.key)) {
          candidates.add(entry.value.primaryDishName);
          candidates.addAll(entry.value.candidates);
        }
      }
    }
    return candidates.toList();
  }
}
