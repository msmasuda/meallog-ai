// lib/features/meal_record/data/food_label_mapper.dart

enum FoodCategory {
  food,
  drink,
  nonFood,
}

class FoodLabelMapping {
  const FoodLabelMapping({
    required this.primaryDishName,
    this.candidates = const [],
    this.ingredients = const [],
    this.category = FoodCategory.food,
  });

  final String primaryDishName;
  final List<String> candidates;
  final List<String> ingredients;
  final FoodCategory category;
}

class FoodLabelMapper {
  /// 汎用判定時に提示する定番の日常料理候補リスト
  static const List<String> defaultMealCandidates = [
    '焼きそば',
    'カレーライス',
    'ラーメン',
    'パスタ',
    'ハンバーグ',
    '野菜炒め',
    '唐揚げ',
    '生姜焼き',
    'チャーハン',
    'うどん',
    '餃子',
    '定食',
  ];

  /// 汎用判定時に提示する定番のドリンク候補リスト
  static const List<String> defaultDrinkCandidates = [
    'コーヒー',
    'カフェラテ',
    '緑茶・お茶',
    '紅茶',
    'フルーツジュース',
    'スムージー',
    'ビール',
    '水・ミネラルウォーター',
  ];

  /// 汎用的な食事・料理関連ラベル
  static const Set<String> _genericFoodLabels = {
    'food',
    'dish',
    'cuisine',
    'meal',
    'recipe',
    'fast food',
    'comfort food',
    'junk food',
    'asian food',
    'japanese cuisine',
    'chinese food',
    'western food',
    'delicacy',
    'lunch',
    'dinner',
    'breakfast',
    'supper',
    'brunch',
    'snack',
    'side dish',
    'tableware',
    'plate',
    'platter',
    'bowl',
    'produce',
    'ingredient',
    'finger food',
  };

  /// 汎用的な飲み物・ドリンク関連ラベル
  static const Set<String> _genericDrinkLabels = {
    'drink',
    'beverage',
    'drinkware',
    'cup',
    'mug',
    'coffee cup',
    'glass',
    'stemware',
    'liquid',
    'fluid',
    'cocktail glass',
    'beer glass',
    'wine glass',
    'barware',
    'teapot',
  };

  /// 非食品ラベルの日本語翻訳辞書
  static const Map<String, String> _nonFoodTranslations = {
    'cat': '猫',
    'small to medium-sized cats': '猫',
    'kitten': '子猫',
    'dog': '犬',
    'puppy': '子犬',
    'pet': 'ペット',
    'animal': '動物',
    'bird': '鳥',
    'mammal': '動物',
    'carnivore': '動物',
    'felidae': '猫科動物',
    'canidae': '犬科動物',
    'person': '人物',
    'human': '人物',
    'face': '人物の顔',
    'people': '人物',
    'smile': '人物',
    'clothing': '衣服',
    'room': '部屋',
    'furniture': '家具',
    'table': 'テーブル',
    'chair': 'イス',
    'couch': 'ソファ',
    'bed': 'ベッド',
    'car': '車',
    'vehicle': '乗り物',
    'motor vehicle': '自動車',
    'building': '建物',
    'house': '家',
    'plant': '植物',
    'flower': '花',
    'tree': '木',
    'houseplant': '観葉植物',
    'electronic': '電子機器',
    'gadget': '電子機器',
    'computer': 'パソコン',
    'laptop': 'ノートパソコン',
    'screen': '画面・モニター',
    'television': 'テレビ',
    'display device': 'ディスプレイ',
    'phone': 'スマートフォン',
    'mobile phone': 'スマートフォン',
    'document': '書類',
    'book': '本',
    'paper': '紙・書類',
    'art': 'イラスト・アート',
    'sky': '空',
    'nature': '自然風景',
    'outdoor': '屋外風景',
    'indoor': '屋内',
    'shoes': '靴',
    'footwear': '靴',
    'bag': 'かばん',
    'luggage and bags': 'バッグ',
    'toy': 'おもちゃ',
    'selfie': '自撮り写真',
    'eyewear': 'メガネ',
    'glasses': 'メガネ',
    'watch': '腕時計',
    '__background__': '背景・その他',
  };

  /// 具体的な料理・ドリンク・食材の辞書（英語ラベル -> 日本語マッピング）
  static const Map<String, FoodLabelMapping> _dictionary = {
    // === 麺類 ===
    'yakisoba': FoodLabelMapping(
      primaryDishName: '焼きそば',
      candidates: ['ソース焼きそば', '塩焼きそば', 'あんかけ焼きそば', 'かた焼きそば'],
      ingredients: ['中華麺', '豚肉', 'キャベツ', '玉ねぎ', 'もやし', '人参', '紅生姜'],
    ),
    'yaki udon': FoodLabelMapping(
      primaryDishName: '焼きうどん',
      candidates: ['醤油焼きうどん', 'ソース焼きうどん', '豚肉とキャベツの焼きうどん'],
      ingredients: ['うどん', '豚肉', 'キャベツ', '玉ねぎ', 'かつお節'],
    ),
    'fried noodles': FoodLabelMapping(
      primaryDishName: '焼きそば',
      candidates: ['ソース焼きそば', '塩焼きそば', 'あんかけ焼きそば'],
      ingredients: ['中華麺', '豚肉', 'キャベツ', '玉ねぎ', 'もやし'],
    ),
    'chow mein': FoodLabelMapping(
      primaryDishName: '焼きそば',
      candidates: ['ソース焼きそば', 'あんかけ焼きそば', '五目焼きそば'],
      ingredients: ['中華麺', '豚肉', 'キャベツ', 'もやし', 'キクラゲ'],
    ),
    'ramen': FoodLabelMapping(
      primaryDishName: 'ラーメン',
      candidates: ['醤油ラーメン', '味噌ラーメン', '豚骨ラーメン', '塩ラーメン'],
      ingredients: ['中華麺', 'チャーシュー', 'ネギ', 'メンマ', '卵'],
    ),
    'ramyun': FoodLabelMapping(
      primaryDishName: 'ラーメン',
      candidates: ['辛ラーメン', 'インスタントラーメン'],
      ingredients: ['中華麺', '卵', 'ネギ'],
    ),
    'udon': FoodLabelMapping(
      primaryDishName: 'うどん',
      candidates: ['かけうどん', 'きつねうどん', '天ぷらうどん', 'カレーうどん', '肉うどん'],
      ingredients: ['うどん', 'つゆ', 'ネギ', '油揚げ'],
    ),
    'soba': FoodLabelMapping(
      primaryDishName: 'そば',
      candidates: ['ざるそば', 'かけそば', '天ぷらそば', '鴨南蛮そば', 'とろろそば'],
      ingredients: ['そば', 'つゆ', 'ネギ', 'わさび'],
    ),
    'noodle': FoodLabelMapping(
      primaryDishName: '麺類',
      candidates: ['ラーメン', '焼きそば', 'うどん', 'そば', 'パスタ'],
      ingredients: ['麺', 'ネギ', '具材'],
    ),
    'noodles': FoodLabelMapping(
      primaryDishName: '麺類',
      candidates: ['ラーメン', '焼きそば', 'うどん', 'そば', 'パスタ'],
      ingredients: ['麺', 'ネギ', '具材'],
    ),
    'pasta': FoodLabelMapping(
      primaryDishName: 'パスタ',
      candidates: ['トマトパスタ', 'カルボナーラ', 'ペペロンチーノ', '和風パスタ', 'ミートソース'],
      ingredients: ['パスタ', 'オリーブオイル', 'トマト', 'ニンニク'],
    ),
    'spaghetti': FoodLabelMapping(
      primaryDishName: 'スパゲッティ',
      candidates: ['ミートソーススパゲッティ', 'ナポリタン', 'カルボナーラ', 'たらこスパゲッティ'],
      ingredients: ['スパゲッティ', '玉ねぎ', 'トマトソース', 'ベーコン'],
    ),
    'carbonara': FoodLabelMapping(
      primaryDishName: 'カルボナーラ',
      candidates: ['カルボナーラスパゲッティ', '濃厚カルボナーラ'],
      ingredients: ['パスタ', 'ベーコン', '卵', '生クリーム', '粉チーズ', '黒コショウ'],
    ),
    'lasagna': FoodLabelMapping(
      primaryDishName: 'ラザニア',
      candidates: ['ミートラザニア', 'チーズラザニア'],
      ingredients: ['ラザニアパスタ', 'ミートソース', 'ホワイトソース', 'チーズ'],
    ),

    // === カレー・洋食 ===
    'curry': FoodLabelMapping(
      primaryDishName: 'カレーライス',
      candidates: ['カレーライス', 'キーマカレー', 'カツカレー', 'チキンカレー', 'ポークカレー'],
      ingredients: ['玉ねぎ', '人参', 'じゃがいも', '肉', 'カレールー'],
    ),
    'hainanese curry rice': FoodLabelMapping(
      primaryDishName: 'カレーライス',
      candidates: ['カレーライス', 'チキンカレー', 'ポークカレー'],
      ingredients: ['ご飯', 'カレールー', '鶏肉', '玉ねぎ'],
    ),
    'chicken curry': FoodLabelMapping(
      primaryDishName: 'チキンカレー',
      candidates: ['チキンカレー', 'バターチキンカレー', 'スープカレー'],
      ingredients: ['鶏肉', '玉ねぎ', 'トマト', 'カレールー', 'ヨーグルト'],
    ),
    'mutton curry': FoodLabelMapping(
      primaryDishName: 'カレー',
      candidates: ['マトンカレー', 'キーマカレー', 'スパイスカレー'],
      ingredients: ['羊肉', 'スパイス', '玉ねぎ', 'トマト'],
    ),
    'red curry': FoodLabelMapping(
      primaryDishName: 'タイカレー',
      candidates: ['レッドカレー', 'グリーンカレー', 'イエローカレー'],
      ingredients: ['鶏肉', 'ココナッツミルク', 'タケノコ', 'ナス', 'カレーペースト'],
    ),
    'pizza': FoodLabelMapping(
      primaryDishName: 'ピザ',
      candidates: ['マルゲリータピザ', 'ミックスピザ', 'チーズピザ', '照り焼きチキンピザ'],
      ingredients: ['ピザ生地', 'チーズ', 'トマトソース', 'バジル'],
    ),
    'hamburger': FoodLabelMapping(
      primaryDishName: 'ハンバーガー',
      candidates: ['ハンバーガー', 'チーズバーガー', 'テリヤキバーガー'],
      ingredients: ['バンズ', 'パティ', 'レタス', 'トマト', 'チーズ'],
    ),
    'cheeseburger': FoodLabelMapping(
      primaryDishName: 'チーズバーガー',
      candidates: ['チーズバーガー', 'ダブルチーズバーガー', 'ベーコンチーズバーガー'],
      ingredients: ['バンズ', 'パティ', 'チェダーチーズ', 'レタス', 'ピクルス'],
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
    'salisbury steak': FoodLabelMapping(
      primaryDishName: 'ハンバーグステーキ',
      candidates: ['デミグラスハンバーグ', '和風おろしハンバーグ', 'チーズインハンバーグ'],
      ingredients: ['合い挽き肉', '玉ねぎ', '卵', 'デミグラスソース'],
    ),
    'steak': FoodLabelMapping(
      primaryDishName: 'ステーキ',
      candidates: ['ビーフステーキ', 'サーロインステーキ', 'ヒレステーキ', 'チキンステーキ'],
      ingredients: ['牛肉', '塩コショウ', 'ステーキソース', 'ニンニク'],
    ),
    'cheesesteak': FoodLabelMapping(
      primaryDishName: 'ステーキサンド',
      candidates: ['フィリーチーズステーキ', 'ビーフサンド'],
      ingredients: ['牛肉', 'チーズ', 'パン', '玉ねぎ'],
    ),
    'sandwich': FoodLabelMapping(
      primaryDishName: 'サンドイッチ',
      candidates: ['たまごサンド', 'ハムレタスサンド', 'カツサンド', 'BLTサンド', 'クラブサンド'],
      ingredients: ['食パン', '卵', 'ハム', 'レタス', 'マヨネーズ'],
    ),
    'club sandwich': FoodLabelMapping(
      primaryDishName: 'クラブハウスサンド',
      candidates: ['クラブハウスサンド', 'BLTサンド', 'チキンサンド'],
      ingredients: ['食パン', '鶏胸肉', 'ベーコン', 'トマト', 'レタス', 'マヨネーズ'],
    ),
    'french fries': FoodLabelMapping(
      primaryDishName: 'フライドポテト',
      candidates: ['フライドポテト', '皮付きポテト', 'ハッシュドポテト'],
      ingredients: ['じゃがいも', '塩', '揚げ油'],
    ),

    // === 和食・米・丼・中華 ===
    'fried rice': FoodLabelMapping(
      primaryDishName: 'チャーハン',
      candidates: ['炒飯', '五目チャーハン', 'キムチチャーハン', 'カニ炒飯'],
      ingredients: ['ご飯', '卵', 'ネギ', '焼豚', 'ごま油'],
    ),
    'chahan': FoodLabelMapping(
      primaryDishName: 'チャーハン',
      candidates: ['炒飯', '五目チャーハン', '高菜チャーハン'],
      ingredients: ['ご飯', '卵', '長ネギ', '焼豚', '醤油', 'ごま油'],
    ),
    'rice': FoodLabelMapping(
      primaryDishName: 'ご飯・丼もの',
      candidates: ['白ご飯', 'チャーハン', 'オムライス', '牛丼', '親子丼', 'カツ丼'],
      ingredients: ['お米', '卵', 'ネギ'],
    ),
    'donburi': FoodLabelMapping(
      primaryDishName: '丼もの',
      candidates: ['牛丼', '親子丼', 'カツ丼', '天丼', '豚丼'],
      ingredients: ['ご飯', '肉', '玉ねぎ', '卵', '醤油', 'みりん'],
    ),
    'gyudon': FoodLabelMapping(
      primaryDishName: '牛丼',
      candidates: ['牛丼', 'ねぎ玉牛丼', 'チーズ牛丼'],
      ingredients: ['ご飯', '牛肉', '玉ねぎ', '醤油', 'みりん', '生姜'],
    ),
    'katsudon': FoodLabelMapping(
      primaryDishName: 'カツ丼',
      candidates: ['カツ丼', 'ソースカツ丼', 'タレカツ丼'],
      ingredients: ['ご飯', '豚カツ', '玉ねぎ', '卵', '出汁', '三つ葉'],
    ),
    'oyakodon': FoodLabelMapping(
      primaryDishName: '親子丼',
      candidates: ['親子丼', '炭火焼き親子丼'],
      ingredients: ['ご飯', '鶏肉', '玉ねぎ', '卵', '出汁', '三つ葉'],
    ),
    'sushi': FoodLabelMapping(
      primaryDishName: '寿司',
      candidates: ['にぎり寿司', '海鮮丼', '巻き寿司', 'ちらし寿司'],
      ingredients: ['酢飯', '魚介類', '海苔', '醤油'],
    ),
    'sashimi': FoodLabelMapping(
      primaryDishName: '刺身',
      candidates: ['刺身盛り合わせ', '海鮮丼', 'マグロの刺身', 'サーモン刺身'],
      ingredients: ['鮮魚', '大根のツマ', 'わさび', '醤油'],
    ),
    'tempura': FoodLabelMapping(
      primaryDishName: '天ぷら',
      candidates: ['天ぷら盛り合わせ', '天丼', 'エビ天', 'かき揚げ'],
      ingredients: ['エビ', '季節の野菜', '小麦粉', '天つゆ'],
    ),
    'tonkatsu': FoodLabelMapping(
      primaryDishName: 'とんかつ',
      candidates: ['ロースカツ', 'ヒレカツ', 'カツレツ', '味噌カツ'],
      ingredients: ['豚ロース肉', 'パン粉', '卵', '小麦粉', 'キャベツ', 'とんかつソース'],
    ),
    'sukiyaki': FoodLabelMapping(
      primaryDishName: 'すき焼き',
      candidates: ['牛すき焼き', 'すき焼き鍋', 'すき焼きうどん'],
      ingredients: ['牛肉', '白菜', 'ネギ', '焼き豆腐', '春雨', '卵', '割り下'],
    ),
    'takoyaki': FoodLabelMapping(
      primaryDishName: 'たこ焼き',
      candidates: ['たこ焼き', '明石焼き', 'ネギマヨたこ焼き'],
      ingredients: ['タコ', '小麦粉', '出汁', '紅生姜', '天かす', 'ソース', '青のり'],
    ),
    'okonomiyaki': FoodLabelMapping(
      primaryDishName: 'お好み焼き',
      candidates: ['豚玉お好み焼き', '広島風お好み焼き', 'モダン焼き'],
      ingredients: ['キャベツ', '豚バラ肉', '小麦粉', '卵', '長芋', 'ソース', 'マヨネーズ'],
    ),
    'dumpling': FoodLabelMapping(
      primaryDishName: '餃子',
      candidates: ['焼き餃子', '水餃子', '小籠包', '揚げ餃子'],
      ingredients: ['餃子の皮', '豚ひき肉', 'キャベツ', 'ニラ', 'ニンニク'],
    ),
    'gyoza': FoodLabelMapping(
      primaryDishName: '餃子',
      candidates: ['焼き餃子', '水餃子', '羽根つき餃子'],
      ingredients: ['餃子の皮', '豚ひき肉', 'キャベツ', 'ニラ'],
    ),
    'dim sum': FoodLabelMapping(
      primaryDishName: '点心・飲茶',
      candidates: ['小籠包', '焼売', '春巻き', '海老蒸し餃子'],
      ingredients: ['豚肉', 'エビ', '小麦粉の皮'],
    ),
    'fried chicken': FoodLabelMapping(
      primaryDishName: '唐揚げ',
      candidates: ['鶏の唐揚げ', '竜田揚げ', 'チキン南蛮', '油淋鶏'],
      ingredients: ['鶏もも肉', '醤油', '生姜', '片栗粉', '揚げ油'],
    ),
    'karaage': FoodLabelMapping(
      primaryDishName: '唐揚げ',
      candidates: ['鶏の唐揚げ', '竜田揚げ'],
      ingredients: ['鶏肉', '醤油', 'ニンニク', '生姜', '片栗粉'],
    ),
    'yakitori': FoodLabelMapping(
      primaryDishName: '焼き鳥',
      candidates: ['焼き鳥盛り合わせ', 'ねぎま', 'つくね', 'もも串'],
      ingredients: ['鶏肉', '長ネギ', 'タレ', '塩'],
    ),
    'stir frying': FoodLabelMapping(
      primaryDishName: '野菜炒め・炒め物',
      candidates: ['野菜炒め', '肉野菜炒め', 'ホイコーロー', '焼きそば'],
      ingredients: ['キャベツ', 'もやし', '豚肉', '人参', 'ごま油'],
    ),
    'stir fry': FoodLabelMapping(
      primaryDishName: '野菜炒め・炒め物',
      candidates: ['野菜炒め', '豚キムチ', 'チンジャオロース'],
      ingredients: ['豚肉', 'キャベツ', 'もやし', 'ピーマン'],
    ),
    'fish': FoodLabelMapping(
      primaryDishName: '焼き魚・魚料理',
      candidates: ['鮭の塩焼き', '鯖の味噌煮', 'アジの開き', '煮魚'],
      ingredients: ['魚', '醤油', 'みりん', '生姜'],
    ),
    'seafood': FoodLabelMapping(
      primaryDishName: '魚介料理',
      candidates: ['海鮮丼', 'エビチリ', 'アサリの酒蒸し', '焼き魚'],
      ingredients: ['魚介類', 'ネギ', '生姜'],
    ),
    'meat': FoodLabelMapping(
      primaryDishName: '肉料理',
      candidates: ['生姜焼き', '豚の角煮', 'ステーキ', '焼肉', '唐揚げ'],
      ingredients: ['肉', '玉ねぎ', '醤油', 'みりん'],
    ),
    'pork': FoodLabelMapping(
      primaryDishName: '豚肉料理',
      candidates: ['豚の生姜焼き', '豚汁', 'とんかつ', '豚の角煮', '豚キムチ'],
      ingredients: ['豚肉', '玉ねぎ', '生姜', '醤油'],
    ),
    'beef': FoodLabelMapping(
      primaryDishName: '牛肉料理',
      candidates: ['牛丼', 'ビーフシチュー', 'ステーキ', '焼肉', 'すき焼き'],
      ingredients: ['牛肉', '玉ねぎ', '醤油', 'みりん'],
    ),
    'chicken': FoodLabelMapping(
      primaryDishName: '鶏肉料理',
      candidates: ['鶏の照り焼き', '焼き鳥', 'チキン南蛮', '唐揚げ', 'チキンソテー'],
      ingredients: ['鶏肉', '醤油', 'みりん', '酒'],
    ),
    'salad': FoodLabelMapping(
      primaryDishName: 'サラダ',
      candidates: ['グリーンサラダ', 'シーザーサラダ', 'ポテトサラダ', 'マカロニサラダ'],
      ingredients: ['レタス', 'トマト', 'きゅうり', 'ドレッシング'],
    ),
    'potato salad': FoodLabelMapping(
      primaryDishName: 'ポテトサラダ',
      candidates: ['ポテトサラダ', 'おつまみポテサラ'],
      ingredients: ['じゃがいも', 'きゅうり', '人参', 'ハム', 'マヨネーズ'],
    ),
    'cobb salad': FoodLabelMapping(
      primaryDishName: 'コブサラダ',
      candidates: ['コブサラダ', '具沢山シーザーサラダ'],
      ingredients: ['レタス', 'アボカド', 'トマト', 'ゆで卵', '鶏肉', 'コブドレッシング'],
    ),
    'soup': FoodLabelMapping(
      primaryDishName: '汁物・スープ',
      candidates: ['味噌汁', '豚汁', 'コーンスープ', 'コンソメスープ', 'ミネストローネ'],
      ingredients: ['豆腐', 'わかめ', 'ネギ', '出汁'],
    ),
    'miso soup': FoodLabelMapping(
      primaryDishName: '味噌汁',
      candidates: ['豆腐とわかめの味噌汁', '豚汁', 'なめこの味噌汁', 'あさりの味噌汁'],
      ingredients: ['味噌', '出汁', '豆腐', 'わかめ', 'ネギ'],
    ),
    'tofu': FoodLabelMapping(
      primaryDishName: '豆腐料理',
      candidates: ['冷奴', '麻婆豆腐', '湯豆腐', '揚げ出し豆腐', '豆腐ハンバーグ'],
      ingredients: ['豆腐', 'ネギ', '生姜', '醤油'],
    ),
    'egg': FoodLabelMapping(
      primaryDishName: '卵料理',
      candidates: ['目玉焼き', '卵焼き', 'オムレツ', 'スクランブルエッグ', 'ゆで卵'],
      ingredients: ['卵', '油', '調味料'],
    ),
    'omelet': FoodLabelMapping(
      primaryDishName: 'オムレツ',
      candidates: ['プレーンオムレツ', 'チーズオムレツ', 'オムライス', 'スパニッシュオムレツ'],
      ingredients: ['卵', '牛乳', 'バター', '塩コショウ'],
    ),
    'omelette': FoodLabelMapping(
      primaryDishName: 'オムレツ',
      candidates: ['プレーンオムレツ', 'チーズオムレツ', 'オムライス'],
      ingredients: ['卵', '牛乳', 'バター'],
    ),
    'bread': FoodLabelMapping(
      primaryDishName: 'パン',
      candidates: ['トースト', 'クロワッサン', '総菜パン', 'サンドイッチ'],
      ingredients: ['パン', 'バター'],
    ),
    'pancake': FoodLabelMapping(
      primaryDishName: 'パンケーキ・ホットケーキ',
      candidates: ['パンケーキ', 'ホットケーキ', 'スフレパンケーキ'],
      ingredients: ['小麦粉', '卵', '牛乳', 'バター', 'メープルシロップ'],
    ),
    'dessert': FoodLabelMapping(
      primaryDishName: 'デザート・スイーツ',
      candidates: ['ケーキ', 'プリン', 'パフェ', 'アイスクリーム', 'シュークリーム'],
      ingredients: ['砂糖', '生クリーム', 'フルーツ', '牛乳'],
    ),
    'cake': FoodLabelMapping(
      primaryDishName: 'ケーキ',
      candidates: ['ショートケーキ', 'チーズケーキ', 'チョコレートケーキ', 'ロールケーキ'],
      ingredients: ['小麦粉', '砂糖', '卵', '生クリーム'],
    ),

    // === ドリンク ===
    'coffee': FoodLabelMapping(
      primaryDishName: 'コーヒー',
      candidates: ['ホットコーヒー', 'アイスコーヒー', 'カフェラテ', 'カプチーノ', 'エスプレッソ'],
      ingredients: ['コーヒー豆', 'ミルク', '砂糖'],
      category: FoodCategory.drink,
    ),
    'espresso': FoodLabelMapping(
      primaryDishName: 'エスプレッソ',
      candidates: ['エスプレッソ', 'カフェラテ', 'カプチーノ', 'アメリカーノ'],
      ingredients: ['コーヒー豆'],
      category: FoodCategory.drink,
    ),
    'latte': FoodLabelMapping(
      primaryDishName: 'カフェラテ',
      candidates: ['カフェラテ', 'カプチーノ', 'キャラメルラテ', 'カフェモカ'],
      ingredients: ['エスプレッソ', '牛乳'],
      category: FoodCategory.drink,
    ),
    'cappuccino': FoodLabelMapping(
      primaryDishName: 'カプチーノ',
      candidates: ['カプチーノ', 'カフェラテ', 'フラットホワイト'],
      ingredients: ['エスプレッソ', 'フォームミルク'],
      category: FoodCategory.drink,
    ),
    'tea': FoodLabelMapping(
      primaryDishName: 'お茶・紅茶',
      candidates: ['緑茶', '紅茶', 'ほうじ茶', 'ウーロン茶', 'ミルクティー'],
      ingredients: ['茶葉', 'ミルク', 'レモン'],
      category: FoodCategory.drink,
    ),
    'green tea': FoodLabelMapping(
      primaryDishName: '緑茶・お茶',
      candidates: ['緑茶', '煎茶', '抹茶', 'ほうじ茶', '玄米茶'],
      ingredients: ['緑茶葉'],
      category: FoodCategory.drink,
    ),
    'matcha': FoodLabelMapping(
      primaryDishName: '抹茶',
      candidates: ['抹茶', '抹茶ラテ', '抹茶フラペチーノ'],
      ingredients: ['抹茶', '牛乳', '砂糖'],
      category: FoodCategory.drink,
    ),
    'juice': FoodLabelMapping(
      primaryDishName: 'ジュース',
      candidates: ['オレンジジュース', 'りんごジュース', '野菜ジュース', 'グレープフルーツジュース'],
      ingredients: ['果汁', 'フルーツ'],
      category: FoodCategory.drink,
    ),
    'smoothie': FoodLabelMapping(
      primaryDishName: 'スムージー',
      candidates: ['グリーンスムージー', 'バナナスムージー', 'ベリースムージー', 'マンゴースムージー'],
      ingredients: ['フルーツ', '野菜', 'ヨーグルト', '牛乳'],
      category: FoodCategory.drink,
    ),
    'beer': FoodLabelMapping(
      primaryDishName: 'ビール',
      candidates: ['生ビール', 'クラフトビール', '黒ビール', 'ノンアルコールビール'],
      ingredients: ['麦芽', 'ホップ'],
      category: FoodCategory.drink,
    ),
    'wine': FoodLabelMapping(
      primaryDishName: 'ワイン',
      candidates: ['赤ワイン', '白ワイン', 'スパークリングワイン', 'ロゼワイン'],
      ingredients: ['ぶどう'],
      category: FoodCategory.drink,
    ),
    'cocktail': FoodLabelMapping(
      primaryDishName: 'カクテル・サワー',
      candidates: ['レモンサワー', 'ハイボール', 'ジントニック', 'カシスオレンジ'],
      ingredients: ['リキュール', '炭酸水', 'レモン'],
      category: FoodCategory.drink,
    ),
    'alcohol': FoodLabelMapping(
      primaryDishName: 'お酒・アルコール',
      candidates: ['ビール', 'ハイボール', '日本酒', '焼酎', 'ワイン'],
      ingredients: ['アルコール'],
      category: FoodCategory.drink,
    ),
    'milk': FoodLabelMapping(
      primaryDishName: '牛乳・ミルク',
      candidates: ['牛乳', '豆乳', 'アーモンドミルク', 'オーツミルク'],
      ingredients: ['生乳'],
      category: FoodCategory.drink,
    ),
    'water': FoodLabelMapping(
      primaryDishName: '水・ミネラルウォーター',
      candidates: ['ミネラルウォーター', '炭酸水', '白湯'],
      ingredients: ['水'],
      category: FoodCategory.drink,
    ),
  };

  /// 検出されたラベル群が食事・飲み物に関連しているかを判定
  static bool isFoodOrDrink(List<String> rawLabels) {
    for (final raw in rawLabels) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == '__background__') continue;
      // 辞書に含まれるか
      for (final key in _dictionary.keys) {
        if (normalized == key || normalized.contains(key)) return true;
      }
      // 汎用食品またはドリンクに含まれるか
      if (_genericFoodLabels.contains(normalized) || _genericDrinkLabels.contains(normalized)) {
        return true;
      }
    }
    return false;
  }

  /// 非食品ラベルを日本語に翻訳
  static String translateNonFoodLabel(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final entry in _nonFoodTranslations.entries) {
      if (normalized == entry.key || normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return raw;
  }

  /// 検出されたラベル群から最適な料理名・候補・食材をマッピング
  static FoodLabelMapping? mapLabels(List<String> rawLabels) {
    // 1. まず具体的な料理・ドリンク辞書を検索（特定度の高い料理を優先）
    for (final raw in rawLabels) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == '__background__') continue;
      for (final entry in _dictionary.entries) {
        if (normalized == entry.key || normalized.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    // 2. 具体的な項目がなく、汎用ドリンク関連ラベルが含まれる場合
    for (final raw in rawLabels) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == '__background__') continue;
      if (_genericDrinkLabels.contains(normalized)) {
        return const FoodLabelMapping(
          primaryDishName: '飲み物・ドリンク',
          candidates: defaultDrinkCandidates,
          ingredients: [],
          category: FoodCategory.drink,
        );
      }
    }

    // 3. 具体的な項目がなく、汎用食品ラベルが含まれている場合
    for (final raw in rawLabels) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == '__background__') continue;
      if (_genericFoodLabels.contains(normalized)) {
        return const FoodLabelMapping(
          primaryDishName: '料理・食事',
          candidates: defaultMealCandidates,
          ingredients: [],
          category: FoodCategory.food,
        );
      }
    }

    return null;
  }

  /// 複数の検出ラベルをまとめて総合的な候補リストを生成
  static List<String> extractAllCandidates(List<String> rawLabels) {
    final candidates = <String>{};
    bool hasGenericFood = false;
    bool hasGenericDrink = false;

    for (final raw in rawLabels) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == '__background__') continue;
      bool matched = false;
      for (final entry in _dictionary.entries) {
        if (normalized == entry.key || normalized.contains(entry.key)) {
          candidates.add(entry.value.primaryDishName);
          candidates.addAll(entry.value.candidates);
          matched = true;
        }
      }
      if (!matched) {
        if (_genericDrinkLabels.contains(normalized)) {
          hasGenericDrink = true;
        } else if (_genericFoodLabels.contains(normalized)) {
          hasGenericFood = true;
        }
      }
    }

    if (hasGenericDrink) {
      candidates.addAll(defaultDrinkCandidates);
    }
    if (hasGenericFood || candidates.isEmpty) {
      candidates.addAll(defaultMealCandidates);
    }

    return candidates.toList();
  }
}
