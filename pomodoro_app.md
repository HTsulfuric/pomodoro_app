# Pomodoro App Development Guide

このドキュメントは、SketchyBarベースのポモドーロタイマー開発から得られた知見をまとめ、独立したSwiftUIアプリ開発への指針を提供します。

## プロジェクト経緯

### Phase 1: SketchyBar実装 (caffeinate版)
- **アーキテクチャ**: Lua + シェルスクリプト + JSON状態管理
- **スリープ防止**: `caffeinate -i` によるシステムアイドルスリープ防止
- **通知**: `osascript`による通知 + `afplay`による音声
- **状態管理**: `/tmp/sketchybar_pomodoro_state.json`

### Phase 2: launchd実装 (省電力版)
- **アーキテクチャ**: launchdスケジューリング + リアルタイム表示
- **スリープ対応**: システムスリープ可能、指定時刻にwakeup
- **通知**: launchdジョブによる確実な実行
- **テスト仕様**: 1分タイマーで検証

### Phase 3: 方向転換 (独立アプリ化)
- **決定要因**: ロック画面制約の発見とGemini技術相談
- **新方針**: SwiftUI + UserNotifications.framework
- **目標**: App Store配布可能な独立アプリケーション

### Phase 4: プライバシー重視アーキテクチャ (現在)
- **アーキテクチャ**: SwiftUI + Privacy-Safe Integration
- **キーボード管理**: Carbon Event Manager (アクセシビリティ権限不要)
- **テーマシステム**: Protocol-Oriented + Dynamic Registration
- **外部統合**: Event-Driven SketchyBar + Menu Bar + URL Schemes
- **動的サイズ調整**: Monitor-Aware Responsive Design

## 重要な技術的発見

### 1. ロック画面通知の制約
```
✅ 音声 (afplay): ロック中でも再生
❌ osascript通知: ロック中は表示されない
❌ カスタムGUIウィンドウ: ロック中は表示不可
✅ UserNotifications.framework: ロック中でも表示される
```

**根本原因**: launchdから実行されるスクリプトはGUIセッションに属さないため、通知UIがセキュリティ制約でブロックされる

### 2. スリープ防止のアプローチ比較
| 方式 | 電力効率 | 確実性 | 実装複雑度 | 推奨度 |
|------|---------|--------|-----------|--------|
| `caffeinate -d` | 中 | △ | 低 | △ |
| `caffeinate -i` | 低 | ◎ | 低 | △ |
| `launchd` | 高 | ◎ | 中 | ◎ |
| UserNotifications | 高 | ◎ | 中 | ◎◎ |

### 3. 他アプリとの連携
- **Musicアプリ**: 再生中は自動でスリープ防止、一時停止時は解除
- **多くの実用場面**: 他のアプリが既にスリープを防いでいる
- **結論**: 独自のスリープ防止は実際には不要な場合が多い

### 4. 通知システムの技術的制約
```bash
# 問題のあるアプローチ
osascript -e 'display notification "..." with title "..."'  # ロック中NG

# 推奨アプローチ  
UserNotifications.framework  # ロック中でも表示、インタラクティブ対応
```

### 5. プライバシー重視設計の実現 (Phase 4)
```
✅ Carbon Event Manager: Opt+Shift+Pグローバルホットキー (権限不要)
✅ Menu Bar Integration: NSStatusItem経由の安全な制御
✅ URL Schemes: 外部制御用の標準的なAPI
❌ Accessibility API: 侵襲的権限が必要 → 代替手段採用
❌ Global Key Monitoring: プライバシー侵害 → ローカル監視のみ
```

**技術的成果**: アクセシビリティ権限なしでフル機能実現

### 6. テーマシステムアーキテクチャの進化
```swift
// Protocol-Oriented Design
ThemeDefinition + ThemeExperience
├── 動的テーマ登録 (ThemeRegistry)
├── 型消去ラッパー (AnyTheme/AnyThemeExperience)  
├── フルレイアウト制御 (makeFullLayoutView)
└── モニター対応動的サイジング (ScreenContext)
```

**メリット**: 拡張性、保守性、パフォーマンスを同時実現

## SwiftUIアプリ設計指針

### アーキテクチャ選択理由
1. **UserNotifications.framework**: ロック画面対応の唯一の確実な方法
2. **SwiftUI**: モダンで宣言的なUI、メンテナンス性向上
3. **WindowGroup**: 通常のアプリウィンドウ、UI表現の自由度最大化
4. **完全独立**: SketchyBar等に依存しない、一般ユーザー向け設計

### 必須機能 (MVP)
- [x] **メインタイマーウィンドウ**: 大きく見やすいタイマー表示
- [x] **基本ポモドーロロジック**: 25分作業 / 5分休憩 / 15分長期休憩  
- [x] **インタラクティブ通知**: "Start Break" / "Skip" ボタン
- [x] **音声通知**: フェーズ切り替え時の音声アラート
- [x] **永続化**: セッション数、設定の保存
- [x] **コンパクトUI**: 邪魔にならないサイズ（300x400程度）

### 発展機能 (フルバージョン)
- [ ] **フローティングモード**: 最前面固定、半透明の常時表示
- [ ] **統計ダッシュボード**: Swift Chartsによる生産性分析
- [ ] **集中モード連携**: macOSの集中モードとの自動連携
- [ ] **テーマカスタマイゼーション**: 色、音、アイコンの変更
- [ ] **アニメーション**: プログレスリング、フェーズ切り替え効果
- [ ] **ウィジェット**: macOS通知センターウィジェット

## 技術スタック

### 選定理由と代替案
```swift
// 推奨技術スタック
SwiftUI                    // UI: 宣言的、リッチな表現力
UserNotifications         // 通知: ロック画面対応、インタラクティブ
WindowGroup              // ウィンドウ: 自由度の高いUI設計
UserDefaults/Core Data    // 永続化: 設定と統計データ
Swift Charts              // 統計: 美しいグラフ表示
AuthorizationCenter       // 集中モード: macOS深層統合
AVFoundation             // 音声: カスタム音声通知
```

### 却下された技術とその理由
- **MenuBarExtra**: SketchyBarとの競合、UI制約
- **Electron**: パフォーマンス劣化、ネイティブ統合の困難
- **React Native**: macOS対応の限界  
- **AppKit直接**: SwiftUIの方が開発効率高
- **terminal-notifier**: ロック画面制約は同じ

## 実装見積もり

### MVP版 (推奨開始点)
- **工数**: 2-3日 (SwiftUI経験者) / 1-2週間 (学習込み)
- **コード量**: 300-500行
- **機能範囲**: 基本タイマー + 通知 + メニューバー

### フルバージョン
- **工数**: 2-4ヶ月 (パートタイム) / 1ヶ月 (フルタイム)
- **コード量**: 1500-3000行
- **機能範囲**: 統計、カスタマイゼーション、高度な統合

## 開発ロードマップ

### Phase 1: 基盤構築 (Week 1)
1. Xcodeプロジェクト作成 (macOSアプリ)
2. WindowGroupの基本実装
3. タイマーロジック (ViewModel)
4. メインウィンドウUI (コンパクトサイズ)

### Phase 2: 通知システム (Week 2)
1. UserNotifications権限取得
2. 基本通知送信
3. インタラクティブ通知 (ボタン付き)
4. 音声通知統合

### Phase 3: UI/UX強化 (Week 3)
1. プログレスリング実装
2. アニメーション追加
3. 設定永続化
4. ウィンドウ管理 (リサイズ無効化等)

### Phase 4: 発展機能 (Month 2+)
1. フローティングモード実装
2. 統計機能 (Core Data + Swift Charts)
3. 集中モード連携
4. テーマシステム
5. App Store準備

## 設計パターン

### 推奨アーキテクチャ
```
App
├── Models/
│   ├── PomodoroTimer.swift      // コアロジック
│   └── PomodoroSettings.swift   // 設定管理
├── ViewModels/
│   └── TimerViewModel.swift     // UI状態管理
├── Views/
│   ├── ContentView.swift        // メインウィンドウ
│   ├── TimerView.swift          // タイマー表示
│   ├── ControlsView.swift       // 操作ボタン
│   └── SettingsView.swift       // 設定画面
├── Services/
│   ├── NotificationManager.swift // 通知管理
│   └── SoundManager.swift       // 音声管理
└── Utilities/
    └── WindowManager.swift      // ウィンドウ管理
```

### 状態管理戦略
- **@ObservableObject**: タイマー状態 (即座の更新必要)
- **UserDefaults**: 設定 (永続化必要、変更頻度低)
- **Core Data**: 統計 (複雑なクエリ、履歴管理)

## 学んだ教訓

### 技術選択について
1. **プロトタイピングの価値**: SketchyBar版で要求仕様を明確化
2. **段階的進化**: シェルスクリプト → launchd → SwiftUIの自然な流れ
3. **制約の早期発見**: ロック画面テストの重要性
4. **技術的負債**: シェルスクリプトは限界がある

### ユーザー体験について
1. **通知の確実性**: 見逃しは致命的、音だけでは不十分
2. **一貫性**: ロック中とログイン中で同じ体験の提供
3. **軽量性**: 常駐アプリのリソース消費への配慮
4. **統合性**: macOSネイティブ機能との連携価値

## 次期開発への提言

### 最優先事項
1. **UserNotifications.frameworkの完全活用**
2. **ロック画面での動作テスト**
3. **コンパクトで美しいウィンドウUI**
4. **権限取得UXの改善**
5. **ウィンドウ位置の記憶機能**

### 避けるべき罠
1. **osascriptへの依存**: ロック画面で機能しない
2. **複雑な状態管理**: ファイルベースは脆弱
3. **機能の詰め込み**: MVPで価値実証を優先
4. **ウィンドウサイズの自由度**: 固定サイズが理想
5. **SketchyBarとの競合**: 完全に独立したデザイン

## 参考リソース

### Gemini提供知見
- [UserNotifications.framework技術詳細](conversation-context)
- [インタラクティブ通知実装パターン](conversation-context)  
- [独立アプリ vs 統合ツール比較分析](conversation-context)
- [macOSロック画面制約の技術的背景](conversation-context)

### 実装時の参照先
```swift
// 通知システム
UNNotificationAction     // ボタン定義
UNNotificationCategory   // 通知カテゴリ

// ウィンドウ管理
WindowGroup             // メインアプリウィンドウ
.windowResizability     // リサイズ制御
.windowStyle           // タイトルバー制御

// UI状態管理
@ObservableObject      // リアルタイム状態更新
@StateObject          // ライフサイクル管理
@AppStorage           // UserDefaults連携

// レイアウト
VStack/HStack         // 基本レイアウト
Circle/Path           // プログレスリング
Canvas               // カスタム描画
```

---

**最終更新**: 2025-08-03  
**現在のステータス**: Phase 4完了 - フル機能SwiftUIアプリとして稼働中  
**主要成果**: プライバシー重視設計 + 拡張可能テーマシステム + 外部統合

このドキュメントは、Phase 1-4の開発経験から得られた技術的知見の記録です。
類似プロジェクトや、SwiftUIアプリ開発の参考資料として活用してください。

## UI設計イメージ

```
┌─────────────────────────┐
│  🍅 Pomodoro Timer      │ ← タイトルバー（隠せる）
├─────────────────────────┤
│                         │
│    ⭕ 23:45              │ ← 大きなタイマー表示
│    Work Session         │ ← 現在のフェーズ
│                         │
│   Session 2/4           │ ← 進捗表示
│   ████████░░ 80%        │ ← プログレスバー
│                         │
│  [⏸️ Pause] [⏭️ Skip]    │ ← 操作ボタン
│  [🔄 Reset] [⚙️ Settings] │
│                         │
│ 💡 Floating Mode: [ ]   │ ← フローティング切替
└─────────────────────────┘
```