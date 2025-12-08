//
//  PredefinedVocabulary.swift
//  Nomi
//
//  Pre-generated vocabulary for each location across all languages.
//  These words are bundled with the app to provide instant access without API calls.
//

import Foundation

// MARK: - Predefined Word Structure

struct PredefinedWord {
    let targetWord: String
    let romanization: String?
    let englishWord: String
    let exampleSentence: String?
    let stickerEmoji: String // Emoji fallback when no asset image exists
    let stickerAsset: String? // Optional: Asset name for bundled sticker image
}

// MARK: - Vocabulary Data

enum PredefinedVocabulary {
    
    // MARK: - Japanese Vocabulary
    
    static let japanese: [Location: [PredefinedWord]] = [
        .cafe: [
            PredefinedWord(targetWord: "コーヒー", romanization: "koohii", englishWord: "coffee", exampleSentence: "コーヒーをください。", stickerEmoji: "☕️", stickerAsset: nil),
            PredefinedWord(targetWord: "お茶", romanization: "ocha", englishWord: "tea", exampleSentence: "お茶はいかがですか？", stickerEmoji: "🍵", stickerAsset: nil),
            PredefinedWord(targetWord: "ケーキ", romanization: "keeki", englishWord: "cake", exampleSentence: "このケーキはおいしいです。", stickerEmoji: "🍰", stickerAsset: nil),
            PredefinedWord(targetWord: "砂糖", romanization: "satou", englishWord: "sugar", exampleSentence: "砂糖を入れますか？", stickerEmoji: "🧂", stickerAsset: nil),
            PredefinedWord(targetWord: "ミルク", romanization: "miruku", englishWord: "milk", exampleSentence: "ミルクをお願いします。", stickerEmoji: "🥛", stickerAsset: nil),
            PredefinedWord(targetWord: "メニュー", romanization: "menyuu", englishWord: "menu", exampleSentence: "メニューを見せてください。", stickerEmoji: "📋", stickerAsset: nil),
            PredefinedWord(targetWord: "席", romanization: "seki", englishWord: "seat", exampleSentence: "この席は空いていますか？", stickerEmoji: "💺", stickerAsset: nil),
            PredefinedWord(targetWord: "カップ", romanization: "kappu", englishWord: "cup", exampleSentence: "カップをもう一つください。", stickerEmoji: "🫖", stickerAsset: nil),
        ],
        .restaurant: [
            PredefinedWord(targetWord: "ご飯", romanization: "gohan", englishWord: "rice", exampleSentence: "ご飯をください。", stickerEmoji: "🍚", stickerAsset: nil),
            PredefinedWord(targetWord: "水", romanization: "mizu", englishWord: "water", exampleSentence: "お水をお願いします。", stickerEmoji: "💧", stickerAsset: nil),
            PredefinedWord(targetWord: "箸", romanization: "hashi", englishWord: "chopsticks", exampleSentence: "箸を使えますか？", stickerEmoji: "🥢", stickerAsset: nil),
            PredefinedWord(targetWord: "美味しい", romanization: "oishii", englishWord: "delicious", exampleSentence: "とても美味しいです！", stickerEmoji: "😋", stickerAsset: nil),
            PredefinedWord(targetWord: "会計", romanization: "kaikei", englishWord: "bill/check", exampleSentence: "会計をお願いします。", stickerEmoji: "🧾", stickerAsset: nil),
            PredefinedWord(targetWord: "予約", romanization: "yoyaku", englishWord: "reservation", exampleSentence: "予約はありますか？", stickerEmoji: "📅", stickerAsset: nil),
            PredefinedWord(targetWord: "おすすめ", romanization: "osusume", englishWord: "recommendation", exampleSentence: "おすすめは何ですか？", stickerEmoji: "⭐️", stickerAsset: nil),
            PredefinedWord(targetWord: "魚", romanization: "sakana", englishWord: "fish", exampleSentence: "魚が好きです。", stickerEmoji: "🐟", stickerAsset: nil),
        ],
        .store: [
            PredefinedWord(targetWord: "いくら", romanization: "ikura", englishWord: "how much", exampleSentence: "これはいくらですか？", stickerEmoji: "❓", stickerAsset: nil),
            PredefinedWord(targetWord: "買う", romanization: "kau", englishWord: "to buy", exampleSentence: "これを買います。", stickerEmoji: "🛒", stickerAsset: nil),
            PredefinedWord(targetWord: "高い", romanization: "takai", englishWord: "expensive", exampleSentence: "少し高いですね。", stickerEmoji: "💎", stickerAsset: nil),
            PredefinedWord(targetWord: "安い", romanization: "yasui", englishWord: "cheap", exampleSentence: "これは安いです。", stickerEmoji: "💰", stickerAsset: nil),
            PredefinedWord(targetWord: "袋", romanization: "fukuro", englishWord: "bag", exampleSentence: "袋はいりますか？", stickerEmoji: "🛍️", stickerAsset: nil),
            PredefinedWord(targetWord: "現金", romanization: "genkin", englishWord: "cash", exampleSentence: "現金で払います。", stickerEmoji: "💵", stickerAsset: nil),
            PredefinedWord(targetWord: "カード", romanization: "kaado", englishWord: "card", exampleSentence: "カードで払えますか？", stickerEmoji: "💳", stickerAsset: nil),
            PredefinedWord(targetWord: "レシート", romanization: "reshiito", englishWord: "receipt", exampleSentence: "レシートをください。", stickerEmoji: "🧾", stickerAsset: nil),
        ],
        .station: [
            PredefinedWord(targetWord: "電車", romanization: "densha", englishWord: "train", exampleSentence: "電車は何時ですか？", stickerEmoji: "🚃", stickerAsset: nil),
            PredefinedWord(targetWord: "切符", romanization: "kippu", englishWord: "ticket", exampleSentence: "切符を買いました。", stickerEmoji: "🎫", stickerAsset: nil),
            PredefinedWord(targetWord: "出口", romanization: "deguchi", englishWord: "exit", exampleSentence: "出口はどこですか？", stickerEmoji: "🚪", stickerAsset: nil),
            PredefinedWord(targetWord: "入口", romanization: "iriguchi", englishWord: "entrance", exampleSentence: "入口はあちらです。", stickerEmoji: "🚶", stickerAsset: nil),
            PredefinedWord(targetWord: "ホーム", romanization: "hoomu", englishWord: "platform", exampleSentence: "3番ホームです。", stickerEmoji: "🚉", stickerAsset: nil),
            PredefinedWord(targetWord: "次", romanization: "tsugi", englishWord: "next", exampleSentence: "次の電車は10分後です。", stickerEmoji: "➡️", stickerAsset: nil),
            PredefinedWord(targetWord: "乗る", romanization: "noru", englishWord: "to ride", exampleSentence: "電車に乗ります。", stickerEmoji: "🚆", stickerAsset: nil),
            PredefinedWord(targetWord: "降りる", romanization: "oriru", englishWord: "to get off", exampleSentence: "次の駅で降ります。", stickerEmoji: "⬇️", stickerAsset: nil),
        ],
        .home: [
            PredefinedWord(targetWord: "部屋", romanization: "heya", englishWord: "room", exampleSentence: "私の部屋は二階です。", stickerEmoji: "🏠", stickerAsset: nil),
            PredefinedWord(targetWord: "ベッド", romanization: "beddo", englishWord: "bed", exampleSentence: "ベッドで寝ます。", stickerEmoji: "🛏️", stickerAsset: nil),
            PredefinedWord(targetWord: "窓", romanization: "mado", englishWord: "window", exampleSentence: "窓を開けてください。", stickerEmoji: "🪟", stickerAsset: nil),
            PredefinedWord(targetWord: "ドア", romanization: "doa", englishWord: "door", exampleSentence: "ドアを閉めてください。", stickerEmoji: "🚪", stickerAsset: nil),
            PredefinedWord(targetWord: "テレビ", romanization: "terebi", englishWord: "TV", exampleSentence: "テレビを見ます。", stickerEmoji: "📺", stickerAsset: nil),
            PredefinedWord(targetWord: "冷蔵庫", romanization: "reizouko", englishWord: "refrigerator", exampleSentence: "冷蔵庫に牛乳があります。", stickerEmoji: "🧊", stickerAsset: nil),
            PredefinedWord(targetWord: "お風呂", romanization: "ofuro", englishWord: "bath", exampleSentence: "お風呂に入ります。", stickerEmoji: "🛁", stickerAsset: nil),
            PredefinedWord(targetWord: "台所", romanization: "daidokoro", englishWord: "kitchen", exampleSentence: "台所で料理します。", stickerEmoji: "👨‍🍳", stickerAsset: nil),
        ],
        .park: [
            PredefinedWord(targetWord: "木", romanization: "ki", englishWord: "tree", exampleSentence: "大きい木があります。", stickerEmoji: "🌳", stickerAsset: nil),
            PredefinedWord(targetWord: "花", romanization: "hana", englishWord: "flower", exampleSentence: "きれいな花ですね。", stickerEmoji: "🌸", stickerAsset: nil),
            PredefinedWord(targetWord: "空", romanization: "sora", englishWord: "sky", exampleSentence: "今日は空が青いです。", stickerEmoji: "🌤️", stickerAsset: nil),
            PredefinedWord(targetWord: "鳥", romanization: "tori", englishWord: "bird", exampleSentence: "鳥が歌っています。", stickerEmoji: "🐦", stickerAsset: nil),
            PredefinedWord(targetWord: "散歩", romanization: "sanpo", englishWord: "walk", exampleSentence: "散歩しましょう。", stickerEmoji: "🚶", stickerAsset: nil),
            PredefinedWord(targetWord: "天気", romanization: "tenki", englishWord: "weather", exampleSentence: "今日は天気がいいです。", stickerEmoji: "☀️", stickerAsset: nil),
            PredefinedWord(targetWord: "ベンチ", romanization: "benchi", englishWord: "bench", exampleSentence: "ベンチに座りましょう。", stickerEmoji: "🪑", stickerAsset: nil),
            PredefinedWord(targetWord: "犬", romanization: "inu", englishWord: "dog", exampleSentence: "かわいい犬ですね。", stickerEmoji: "🐕", stickerAsset: nil),
        ],
        .hospital: [
            PredefinedWord(targetWord: "医者", romanization: "isha", englishWord: "doctor", exampleSentence: "医者に会いたいです。", stickerEmoji: "👨‍⚕️", stickerAsset: nil),
            PredefinedWord(targetWord: "薬", romanization: "kusuri", englishWord: "medicine", exampleSentence: "薬を飲みます。", stickerEmoji: "💊", stickerAsset: nil),
            PredefinedWord(targetWord: "痛い", romanization: "itai", englishWord: "painful", exampleSentence: "頭が痛いです。", stickerEmoji: "🤕", stickerAsset: nil),
            PredefinedWord(targetWord: "熱", romanization: "netsu", englishWord: "fever", exampleSentence: "熱があります。", stickerEmoji: "🤒", stickerAsset: nil),
            PredefinedWord(targetWord: "病院", romanization: "byouin", englishWord: "hospital", exampleSentence: "病院に行きます。", stickerEmoji: "🏥", stickerAsset: nil),
            PredefinedWord(targetWord: "風邪", romanization: "kaze", englishWord: "cold", exampleSentence: "風邪を引きました。", stickerEmoji: "🤧", stickerAsset: nil),
            PredefinedWord(targetWord: "元気", romanization: "genki", englishWord: "healthy/fine", exampleSentence: "元気ですか？", stickerEmoji: "💪", stickerAsset: nil),
            PredefinedWord(targetWord: "休む", romanization: "yasumu", englishWord: "to rest", exampleSentence: "今日は休みます。", stickerEmoji: "😴", stickerAsset: nil),
        ],
        .office: [
            PredefinedWord(targetWord: "仕事", romanization: "shigoto", englishWord: "work", exampleSentence: "仕事は何ですか？", stickerEmoji: "💼", stickerAsset: nil),
            PredefinedWord(targetWord: "会議", romanization: "kaigi", englishWord: "meeting", exampleSentence: "会議は3時からです。", stickerEmoji: "👥", stickerAsset: nil),
            PredefinedWord(targetWord: "電話", romanization: "denwa", englishWord: "phone", exampleSentence: "電話してください。", stickerEmoji: "📞", stickerAsset: nil),
            PredefinedWord(targetWord: "メール", romanization: "meeru", englishWord: "email", exampleSentence: "メールを送りました。", stickerEmoji: "📧", stickerAsset: nil),
            PredefinedWord(targetWord: "パソコン", romanization: "pasokon", englishWord: "computer", exampleSentence: "パソコンを使います。", stickerEmoji: "💻", stickerAsset: nil),
            PredefinedWord(targetWord: "上司", romanization: "joushi", englishWord: "boss", exampleSentence: "上司に報告します。", stickerEmoji: "👔", stickerAsset: nil),
            PredefinedWord(targetWord: "同僚", romanization: "douryou", englishWord: "colleague", exampleSentence: "同僚と昼ご飯を食べます。", stickerEmoji: "🤝", stickerAsset: nil),
            PredefinedWord(targetWord: "書類", romanization: "shorui", englishWord: "document", exampleSentence: "書類を準備してください。", stickerEmoji: "📄", stickerAsset: nil),
        ],
    ]
    
    // MARK: - Korean Vocabulary
    
    static let korean: [Location: [PredefinedWord]] = [
        .cafe: [
            PredefinedWord(targetWord: "커피", romanization: "keopi", englishWord: "coffee", exampleSentence: "커피 주세요.", stickerEmoji: "☕️", stickerAsset: nil),
            PredefinedWord(targetWord: "차", romanization: "cha", englishWord: "tea", exampleSentence: "차 한 잔 주세요.", stickerEmoji: "🍵", stickerAsset: nil),
            PredefinedWord(targetWord: "케이크", romanization: "keikeu", englishWord: "cake", exampleSentence: "이 케이크 맛있어요.", stickerEmoji: "🍰", stickerAsset: nil),
            PredefinedWord(targetWord: "설탕", romanization: "seoltang", englishWord: "sugar", exampleSentence: "설탕 넣을까요?", stickerEmoji: "🧂", stickerAsset: nil),
            PredefinedWord(targetWord: "우유", romanization: "uyu", englishWord: "milk", exampleSentence: "우유 주세요.", stickerEmoji: "🥛", stickerAsset: nil),
            PredefinedWord(targetWord: "메뉴", romanization: "menyu", englishWord: "menu", exampleSentence: "메뉴 보여주세요.", stickerEmoji: "📋", stickerAsset: nil),
            PredefinedWord(targetWord: "자리", romanization: "jari", englishWord: "seat", exampleSentence: "이 자리 비어 있어요?", stickerEmoji: "💺", stickerAsset: nil),
            PredefinedWord(targetWord: "컵", romanization: "keop", englishWord: "cup", exampleSentence: "컵 하나 더 주세요.", stickerEmoji: "🫖", stickerAsset: nil),
        ],
        .restaurant: [
            PredefinedWord(targetWord: "밥", romanization: "bap", englishWord: "rice", exampleSentence: "밥 주세요.", stickerEmoji: "🍚", stickerAsset: nil),
            PredefinedWord(targetWord: "물", romanization: "mul", englishWord: "water", exampleSentence: "물 주세요.", stickerEmoji: "💧", stickerAsset: nil),
            PredefinedWord(targetWord: "젓가락", romanization: "jeotgarak", englishWord: "chopsticks", exampleSentence: "젓가락 사용할 수 있어요?", stickerEmoji: "🥢", stickerAsset: nil),
            PredefinedWord(targetWord: "맛있다", romanization: "masitda", englishWord: "delicious", exampleSentence: "정말 맛있어요!", stickerEmoji: "😋", stickerAsset: nil),
            PredefinedWord(targetWord: "계산", romanization: "gyesan", englishWord: "bill/check", exampleSentence: "계산해 주세요.", stickerEmoji: "🧾", stickerAsset: nil),
            PredefinedWord(targetWord: "예약", romanization: "yeyak", englishWord: "reservation", exampleSentence: "예약했어요.", stickerEmoji: "📅", stickerAsset: nil),
            PredefinedWord(targetWord: "추천", romanization: "chucheon", englishWord: "recommendation", exampleSentence: "추천 메뉴가 뭐예요?", stickerEmoji: "⭐️", stickerAsset: nil),
            PredefinedWord(targetWord: "생선", romanization: "saengseon", englishWord: "fish", exampleSentence: "생선을 좋아해요.", stickerEmoji: "🐟", stickerAsset: nil),
        ],
        .store: [
            PredefinedWord(targetWord: "얼마", romanization: "eolma", englishWord: "how much", exampleSentence: "이거 얼마예요?", stickerEmoji: "❓", stickerAsset: nil),
            PredefinedWord(targetWord: "사다", romanization: "sada", englishWord: "to buy", exampleSentence: "이거 살게요.", stickerEmoji: "🛒", stickerAsset: nil),
            PredefinedWord(targetWord: "비싸다", romanization: "bissada", englishWord: "expensive", exampleSentence: "좀 비싸네요.", stickerEmoji: "💎", stickerAsset: nil),
            PredefinedWord(targetWord: "싸다", romanization: "ssada", englishWord: "cheap", exampleSentence: "이건 싸요.", stickerEmoji: "💰", stickerAsset: nil),
            PredefinedWord(targetWord: "봉투", romanization: "bongtu", englishWord: "bag", exampleSentence: "봉투 필요해요?", stickerEmoji: "🛍️", stickerAsset: nil),
            PredefinedWord(targetWord: "현금", romanization: "hyeongeum", englishWord: "cash", exampleSentence: "현금으로 낼게요.", stickerEmoji: "💵", stickerAsset: nil),
            PredefinedWord(targetWord: "카드", romanization: "kadeu", englishWord: "card", exampleSentence: "카드로 계산할 수 있어요?", stickerEmoji: "💳", stickerAsset: nil),
            PredefinedWord(targetWord: "영수증", romanization: "yeongsujeung", englishWord: "receipt", exampleSentence: "영수증 주세요.", stickerEmoji: "🧾", stickerAsset: nil),
        ],
        .station: [
            PredefinedWord(targetWord: "기차", romanization: "gicha", englishWord: "train", exampleSentence: "기차가 몇 시예요?", stickerEmoji: "🚃", stickerAsset: nil),
            PredefinedWord(targetWord: "표", romanization: "pyo", englishWord: "ticket", exampleSentence: "표를 샀어요.", stickerEmoji: "🎫", stickerAsset: nil),
            PredefinedWord(targetWord: "출구", romanization: "chulgu", englishWord: "exit", exampleSentence: "출구가 어디예요?", stickerEmoji: "🚪", stickerAsset: nil),
            PredefinedWord(targetWord: "입구", romanization: "ipgu", englishWord: "entrance", exampleSentence: "입구는 저쪽이에요.", stickerEmoji: "🚶", stickerAsset: nil),
            PredefinedWord(targetWord: "플랫폼", romanization: "peullaetpom", englishWord: "platform", exampleSentence: "3번 플랫폼이에요.", stickerEmoji: "🚉", stickerAsset: nil),
            PredefinedWord(targetWord: "다음", romanization: "daeum", englishWord: "next", exampleSentence: "다음 기차는 10분 후예요.", stickerEmoji: "➡️", stickerAsset: nil),
            PredefinedWord(targetWord: "타다", romanization: "tada", englishWord: "to ride", exampleSentence: "기차를 타요.", stickerEmoji: "🚆", stickerAsset: nil),
            PredefinedWord(targetWord: "내리다", romanization: "naerida", englishWord: "to get off", exampleSentence: "다음 역에서 내려요.", stickerEmoji: "⬇️", stickerAsset: nil),
        ],
        .home: [
            PredefinedWord(targetWord: "방", romanization: "bang", englishWord: "room", exampleSentence: "제 방은 2층이에요.", stickerEmoji: "🏠", stickerAsset: nil),
            PredefinedWord(targetWord: "침대", romanization: "chimdae", englishWord: "bed", exampleSentence: "침대에서 자요.", stickerEmoji: "🛏️", stickerAsset: nil),
            PredefinedWord(targetWord: "창문", romanization: "changmun", englishWord: "window", exampleSentence: "창문 열어 주세요.", stickerEmoji: "🪟", stickerAsset: nil),
            PredefinedWord(targetWord: "문", romanization: "mun", englishWord: "door", exampleSentence: "문 닫아 주세요.", stickerEmoji: "🚪", stickerAsset: nil),
            PredefinedWord(targetWord: "텔레비전", romanization: "tellebijeon", englishWord: "TV", exampleSentence: "텔레비전을 봐요.", stickerEmoji: "📺", stickerAsset: nil),
            PredefinedWord(targetWord: "냉장고", romanization: "naengjanggo", englishWord: "refrigerator", exampleSentence: "냉장고에 우유가 있어요.", stickerEmoji: "🧊", stickerAsset: nil),
            PredefinedWord(targetWord: "욕실", romanization: "yoksil", englishWord: "bathroom", exampleSentence: "욕실에서 씻어요.", stickerEmoji: "🛁", stickerAsset: nil),
            PredefinedWord(targetWord: "부엌", romanization: "bueok", englishWord: "kitchen", exampleSentence: "부엌에서 요리해요.", stickerEmoji: "👨‍🍳", stickerAsset: nil),
        ],
        .park: [
            PredefinedWord(targetWord: "나무", romanization: "namu", englishWord: "tree", exampleSentence: "큰 나무가 있어요.", stickerEmoji: "🌳", stickerAsset: nil),
            PredefinedWord(targetWord: "꽃", romanization: "kkot", englishWord: "flower", exampleSentence: "예쁜 꽃이네요.", stickerEmoji: "🌸", stickerAsset: nil),
            PredefinedWord(targetWord: "하늘", romanization: "haneul", englishWord: "sky", exampleSentence: "오늘 하늘이 파래요.", stickerEmoji: "🌤️", stickerAsset: nil),
            PredefinedWord(targetWord: "새", romanization: "sae", englishWord: "bird", exampleSentence: "새가 노래해요.", stickerEmoji: "🐦", stickerAsset: nil),
            PredefinedWord(targetWord: "산책", romanization: "sanchaek", englishWord: "walk", exampleSentence: "산책할까요?", stickerEmoji: "🚶", stickerAsset: nil),
            PredefinedWord(targetWord: "날씨", romanization: "nalssi", englishWord: "weather", exampleSentence: "오늘 날씨가 좋아요.", stickerEmoji: "☀️", stickerAsset: nil),
            PredefinedWord(targetWord: "벤치", romanization: "benchi", englishWord: "bench", exampleSentence: "벤치에 앉을까요?", stickerEmoji: "🪑", stickerAsset: nil),
            PredefinedWord(targetWord: "강아지", romanization: "gangaji", englishWord: "dog", exampleSentence: "귀여운 강아지네요.", stickerEmoji: "🐕", stickerAsset: nil),
        ],
        .hospital: [
            PredefinedWord(targetWord: "의사", romanization: "uisa", englishWord: "doctor", exampleSentence: "의사 선생님을 만나고 싶어요.", stickerEmoji: "👨‍⚕️", stickerAsset: nil),
            PredefinedWord(targetWord: "약", romanization: "yak", englishWord: "medicine", exampleSentence: "약을 먹어요.", stickerEmoji: "💊", stickerAsset: nil),
            PredefinedWord(targetWord: "아프다", romanization: "apeuda", englishWord: "painful", exampleSentence: "머리가 아파요.", stickerEmoji: "🤕", stickerAsset: nil),
            PredefinedWord(targetWord: "열", romanization: "yeol", englishWord: "fever", exampleSentence: "열이 있어요.", stickerEmoji: "🤒", stickerAsset: nil),
            PredefinedWord(targetWord: "병원", romanization: "byeongwon", englishWord: "hospital", exampleSentence: "병원에 가요.", stickerEmoji: "🏥", stickerAsset: nil),
            PredefinedWord(targetWord: "감기", romanization: "gamgi", englishWord: "cold", exampleSentence: "감기에 걸렸어요.", stickerEmoji: "🤧", stickerAsset: nil),
            PredefinedWord(targetWord: "건강", romanization: "geongang", englishWord: "healthy", exampleSentence: "건강하세요?", stickerEmoji: "💪", stickerAsset: nil),
            PredefinedWord(targetWord: "쉬다", romanization: "swida", englishWord: "to rest", exampleSentence: "오늘은 쉬어요.", stickerEmoji: "😴", stickerAsset: nil),
        ],
        .office: [
            PredefinedWord(targetWord: "일", romanization: "il", englishWord: "work", exampleSentence: "무슨 일 하세요?", stickerEmoji: "💼", stickerAsset: nil),
            PredefinedWord(targetWord: "회의", romanization: "hoeui", englishWord: "meeting", exampleSentence: "회의는 3시부터예요.", stickerEmoji: "👥", stickerAsset: nil),
            PredefinedWord(targetWord: "전화", romanization: "jeonhwa", englishWord: "phone", exampleSentence: "전화해 주세요.", stickerEmoji: "📞", stickerAsset: nil),
            PredefinedWord(targetWord: "이메일", romanization: "imeil", englishWord: "email", exampleSentence: "이메일을 보냈어요.", stickerEmoji: "📧", stickerAsset: nil),
            PredefinedWord(targetWord: "컴퓨터", romanization: "keompyuteo", englishWord: "computer", exampleSentence: "컴퓨터를 사용해요.", stickerEmoji: "💻", stickerAsset: nil),
            PredefinedWord(targetWord: "상사", romanization: "sangsa", englishWord: "boss", exampleSentence: "상사에게 보고해요.", stickerEmoji: "👔", stickerAsset: nil),
            PredefinedWord(targetWord: "동료", romanization: "dongnyo", englishWord: "colleague", exampleSentence: "동료와 점심 먹어요.", stickerEmoji: "🤝", stickerAsset: nil),
            PredefinedWord(targetWord: "서류", romanization: "seoryu", englishWord: "document", exampleSentence: "서류 준비해 주세요.", stickerEmoji: "📄", stickerAsset: nil),
        ],
    ]
    
    // MARK: - Spanish Vocabulary
    
    static let spanish: [Location: [PredefinedWord]] = [
        .cafe: [
            PredefinedWord(targetWord: "café", romanization: nil, englishWord: "coffee", exampleSentence: "Un café, por favor.", stickerEmoji: "☕️", stickerAsset: nil),
            PredefinedWord(targetWord: "té", romanization: nil, englishWord: "tea", exampleSentence: "¿Quiere té?", stickerEmoji: "🍵", stickerAsset: nil),
            PredefinedWord(targetWord: "pastel", romanization: nil, englishWord: "cake", exampleSentence: "Este pastel está delicioso.", stickerEmoji: "🍰", stickerAsset: nil),
            PredefinedWord(targetWord: "azúcar", romanization: nil, englishWord: "sugar", exampleSentence: "¿Con azúcar?", stickerEmoji: "🧂", stickerAsset: nil),
            PredefinedWord(targetWord: "leche", romanization: nil, englishWord: "milk", exampleSentence: "Leche, por favor.", stickerEmoji: "🥛", stickerAsset: nil),
            PredefinedWord(targetWord: "menú", romanization: nil, englishWord: "menu", exampleSentence: "¿Me puede mostrar el menú?", stickerEmoji: "📋", stickerAsset: nil),
            PredefinedWord(targetWord: "mesa", romanization: nil, englishWord: "table", exampleSentence: "¿Esta mesa está libre?", stickerEmoji: "💺", stickerAsset: nil),
            PredefinedWord(targetWord: "taza", romanization: nil, englishWord: "cup", exampleSentence: "Otra taza, por favor.", stickerEmoji: "🫖", stickerAsset: nil),
        ],
        .restaurant: [
            PredefinedWord(targetWord: "arroz", romanization: nil, englishWord: "rice", exampleSentence: "Arroz, por favor.", stickerEmoji: "🍚", stickerAsset: nil),
            PredefinedWord(targetWord: "agua", romanization: nil, englishWord: "water", exampleSentence: "Agua, por favor.", stickerEmoji: "💧", stickerAsset: nil),
            PredefinedWord(targetWord: "tenedor", romanization: nil, englishWord: "fork", exampleSentence: "Necesito un tenedor.", stickerEmoji: "🍴", stickerAsset: nil),
            PredefinedWord(targetWord: "delicioso", romanization: nil, englishWord: "delicious", exampleSentence: "¡Está muy delicioso!", stickerEmoji: "😋", stickerAsset: nil),
            PredefinedWord(targetWord: "cuenta", romanization: nil, englishWord: "bill", exampleSentence: "La cuenta, por favor.", stickerEmoji: "🧾", stickerAsset: nil),
            PredefinedWord(targetWord: "reserva", romanization: nil, englishWord: "reservation", exampleSentence: "Tengo una reserva.", stickerEmoji: "📅", stickerAsset: nil),
            PredefinedWord(targetWord: "recomendar", romanization: nil, englishWord: "recommend", exampleSentence: "¿Qué me recomienda?", stickerEmoji: "⭐️", stickerAsset: nil),
            PredefinedWord(targetWord: "pescado", romanization: nil, englishWord: "fish", exampleSentence: "Me gusta el pescado.", stickerEmoji: "🐟", stickerAsset: nil),
        ],
        .store: [
            PredefinedWord(targetWord: "cuánto", romanization: nil, englishWord: "how much", exampleSentence: "¿Cuánto cuesta?", stickerEmoji: "❓", stickerAsset: nil),
            PredefinedWord(targetWord: "comprar", romanization: nil, englishWord: "to buy", exampleSentence: "Quiero comprar esto.", stickerEmoji: "🛒", stickerAsset: nil),
            PredefinedWord(targetWord: "caro", romanization: nil, englishWord: "expensive", exampleSentence: "Es un poco caro.", stickerEmoji: "💎", stickerAsset: nil),
            PredefinedWord(targetWord: "barato", romanization: nil, englishWord: "cheap", exampleSentence: "Esto es barato.", stickerEmoji: "💰", stickerAsset: nil),
            PredefinedWord(targetWord: "bolsa", romanization: nil, englishWord: "bag", exampleSentence: "¿Necesita bolsa?", stickerEmoji: "🛍️", stickerAsset: nil),
            PredefinedWord(targetWord: "efectivo", romanization: nil, englishWord: "cash", exampleSentence: "Pago en efectivo.", stickerEmoji: "💵", stickerAsset: nil),
            PredefinedWord(targetWord: "tarjeta", romanization: nil, englishWord: "card", exampleSentence: "¿Aceptan tarjeta?", stickerEmoji: "💳", stickerAsset: nil),
            PredefinedWord(targetWord: "recibo", romanization: nil, englishWord: "receipt", exampleSentence: "El recibo, por favor.", stickerEmoji: "🧾", stickerAsset: nil),
        ],
        .station: [
            PredefinedWord(targetWord: "tren", romanization: nil, englishWord: "train", exampleSentence: "¿A qué hora sale el tren?", stickerEmoji: "🚃", stickerAsset: nil),
            PredefinedWord(targetWord: "billete", romanization: nil, englishWord: "ticket", exampleSentence: "Compré el billete.", stickerEmoji: "🎫", stickerAsset: nil),
            PredefinedWord(targetWord: "salida", romanization: nil, englishWord: "exit", exampleSentence: "¿Dónde está la salida?", stickerEmoji: "🚪", stickerAsset: nil),
            PredefinedWord(targetWord: "entrada", romanization: nil, englishWord: "entrance", exampleSentence: "La entrada está allí.", stickerEmoji: "🚶", stickerAsset: nil),
            PredefinedWord(targetWord: "andén", romanization: nil, englishWord: "platform", exampleSentence: "Andén número 3.", stickerEmoji: "🚉", stickerAsset: nil),
            PredefinedWord(targetWord: "siguiente", romanization: nil, englishWord: "next", exampleSentence: "El siguiente tren es en 10 minutos.", stickerEmoji: "➡️", stickerAsset: nil),
            PredefinedWord(targetWord: "subir", romanization: nil, englishWord: "to board", exampleSentence: "Voy a subir al tren.", stickerEmoji: "🚆", stickerAsset: nil),
            PredefinedWord(targetWord: "bajar", romanization: nil, englishWord: "to get off", exampleSentence: "Bajo en la próxima estación.", stickerEmoji: "⬇️", stickerAsset: nil),
        ],
        .home: [
            PredefinedWord(targetWord: "habitación", romanization: nil, englishWord: "room", exampleSentence: "Mi habitación está arriba.", stickerEmoji: "🏠", stickerAsset: nil),
            PredefinedWord(targetWord: "cama", romanization: nil, englishWord: "bed", exampleSentence: "Duermo en la cama.", stickerEmoji: "🛏️", stickerAsset: nil),
            PredefinedWord(targetWord: "ventana", romanization: nil, englishWord: "window", exampleSentence: "Abre la ventana, por favor.", stickerEmoji: "🪟", stickerAsset: nil),
            PredefinedWord(targetWord: "puerta", romanization: nil, englishWord: "door", exampleSentence: "Cierra la puerta.", stickerEmoji: "🚪", stickerAsset: nil),
            PredefinedWord(targetWord: "televisor", romanization: nil, englishWord: "TV", exampleSentence: "Veo la televisión.", stickerEmoji: "📺", stickerAsset: nil),
            PredefinedWord(targetWord: "nevera", romanization: nil, englishWord: "refrigerator", exampleSentence: "Hay leche en la nevera.", stickerEmoji: "🧊", stickerAsset: nil),
            PredefinedWord(targetWord: "baño", romanization: nil, englishWord: "bathroom", exampleSentence: "Voy al baño.", stickerEmoji: "🛁", stickerAsset: nil),
            PredefinedWord(targetWord: "cocina", romanization: nil, englishWord: "kitchen", exampleSentence: "Cocino en la cocina.", stickerEmoji: "👨‍🍳", stickerAsset: nil),
        ],
        .park: [
            PredefinedWord(targetWord: "árbol", romanization: nil, englishWord: "tree", exampleSentence: "Hay un árbol grande.", stickerEmoji: "🌳", stickerAsset: nil),
            PredefinedWord(targetWord: "flor", romanization: nil, englishWord: "flower", exampleSentence: "¡Qué flor tan bonita!", stickerEmoji: "🌸", stickerAsset: nil),
            PredefinedWord(targetWord: "cielo", romanization: nil, englishWord: "sky", exampleSentence: "El cielo está azul hoy.", stickerEmoji: "🌤️", stickerAsset: nil),
            PredefinedWord(targetWord: "pájaro", romanization: nil, englishWord: "bird", exampleSentence: "El pájaro está cantando.", stickerEmoji: "🐦", stickerAsset: nil),
            PredefinedWord(targetWord: "paseo", romanization: nil, englishWord: "walk", exampleSentence: "¿Damos un paseo?", stickerEmoji: "🚶", stickerAsset: nil),
            PredefinedWord(targetWord: "clima", romanization: nil, englishWord: "weather", exampleSentence: "El clima está bueno hoy.", stickerEmoji: "☀️", stickerAsset: nil),
            PredefinedWord(targetWord: "banco", romanization: nil, englishWord: "bench", exampleSentence: "Sentémonos en el banco.", stickerEmoji: "🪑", stickerAsset: nil),
            PredefinedWord(targetWord: "perro", romanization: nil, englishWord: "dog", exampleSentence: "¡Qué perro tan lindo!", stickerEmoji: "🐕", stickerAsset: nil),
        ],
        .hospital: [
            PredefinedWord(targetWord: "médico", romanization: nil, englishWord: "doctor", exampleSentence: "Quiero ver al médico.", stickerEmoji: "👨‍⚕️", stickerAsset: nil),
            PredefinedWord(targetWord: "medicina", romanization: nil, englishWord: "medicine", exampleSentence: "Tomo la medicina.", stickerEmoji: "💊", stickerAsset: nil),
            PredefinedWord(targetWord: "dolor", romanization: nil, englishWord: "pain", exampleSentence: "Tengo dolor de cabeza.", stickerEmoji: "🤕", stickerAsset: nil),
            PredefinedWord(targetWord: "fiebre", romanization: nil, englishWord: "fever", exampleSentence: "Tengo fiebre.", stickerEmoji: "🤒", stickerAsset: nil),
            PredefinedWord(targetWord: "hospital", romanization: nil, englishWord: "hospital", exampleSentence: "Voy al hospital.", stickerEmoji: "🏥", stickerAsset: nil),
            PredefinedWord(targetWord: "resfriado", romanization: nil, englishWord: "cold", exampleSentence: "Tengo un resfriado.", stickerEmoji: "🤧", stickerAsset: nil),
            PredefinedWord(targetWord: "sano", romanization: nil, englishWord: "healthy", exampleSentence: "¿Estás sano?", stickerEmoji: "💪", stickerAsset: nil),
            PredefinedWord(targetWord: "descansar", romanization: nil, englishWord: "to rest", exampleSentence: "Hoy descanso.", stickerEmoji: "😴", stickerAsset: nil),
        ],
        .office: [
            PredefinedWord(targetWord: "trabajo", romanization: nil, englishWord: "work", exampleSentence: "¿Cuál es tu trabajo?", stickerEmoji: "💼", stickerAsset: nil),
            PredefinedWord(targetWord: "reunión", romanization: nil, englishWord: "meeting", exampleSentence: "La reunión es a las 3.", stickerEmoji: "👥", stickerAsset: nil),
            PredefinedWord(targetWord: "teléfono", romanization: nil, englishWord: "phone", exampleSentence: "Llámame por teléfono.", stickerEmoji: "📞", stickerAsset: nil),
            PredefinedWord(targetWord: "correo", romanization: nil, englishWord: "email", exampleSentence: "Envié un correo.", stickerEmoji: "📧", stickerAsset: nil),
            PredefinedWord(targetWord: "computadora", romanization: nil, englishWord: "computer", exampleSentence: "Uso la computadora.", stickerEmoji: "💻", stickerAsset: nil),
            PredefinedWord(targetWord: "jefe", romanization: nil, englishWord: "boss", exampleSentence: "Informo al jefe.", stickerEmoji: "👔", stickerAsset: nil),
            PredefinedWord(targetWord: "colega", romanization: nil, englishWord: "colleague", exampleSentence: "Almuerzo con mi colega.", stickerEmoji: "🤝", stickerAsset: nil),
            PredefinedWord(targetWord: "documento", romanization: nil, englishWord: "document", exampleSentence: "Prepara el documento.", stickerEmoji: "📄", stickerAsset: nil),
        ],
    ]
    
    // MARK: - Get Vocabulary for Language
    
    static func vocabulary(for language: Language) -> [Location: [PredefinedWord]] {
        switch language {
        case .japanese:
            return japanese
        case .korean:
            return korean
        case .spanish:
            return spanish
        default:
            // For languages without predefined vocabulary, use Japanese as a template
            // The words will still be in the target language via AI generation in production
            // For now, return Japanese so users can see the UI
            return japanese
        }
    }
    
    static func words(for language: Language, location: Location) -> [PredefinedWord] {
        return vocabulary(for: language)[location] ?? []
    }
}
