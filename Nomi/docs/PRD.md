# Nomi - Product Requirements Document

## Overview

**App Name:** Nomi (のみ)  
**Platform:** iOS 26+  
**Technology:** Swift 6, SwiftUI  
**Version:** 1.0  
**Last Updated:** December 7, 2025

Nomi is a language learning app with a Japanese kawaii sticker aesthetic. Users collect vocabulary words as adorable stickers in location-themed journals, making language learning feel like a delightful collecting game.

---

## Table of Contents

1. [Product Vision](#product-vision)
2. [Target Audience](#target-audience)
3. [Core Concepts](#core-concepts)
4. [Feature Specifications](#feature-specifications)
5. [User Flows](#user-flows)
6. [Data Models](#data-models)
7. [AI Integration](#ai-integration)
8. [Design Guidelines](#design-guidelines)
9. [Technical Requirements](#technical-requirements)
10. [Future Considerations](#future-considerations)

---

## Product Vision

### Mission Statement
Make vocabulary learning feel like collecting treasures in a cozy journal, one kawaii sticker at a time.

### Core Philosophy
- **Simple:** One action at a time, no cognitive overload
- **Delightful:** Every interaction feels rewarding and cute
- **Effective:** Spaced repetition through flashcard revision
- **Personal:** Your journal, your collection, your progress

---

## Target Audience

### Primary Users
- Language learners (beginner to intermediate)
- Users who enjoy cute/kawaii aesthetics
- People who prefer visual learning
- Casual learners who want bite-sized sessions

### User Persona
**Mia, 24, Marketing Associate**
- Wants to learn Japanese before her trip to Tokyo
- Has 10-15 minutes daily during commute
- Loves collecting things and cute stationery
- Gets overwhelmed by traditional language apps

---

## Core Concepts

### The Journal Metaphor
Each language the user learns has its own journal. Within each journal are **location pages** (Cafe, Restaurant, Store, etc.). Each location contains vocabulary relevant to that setting, displayed as collectible kawaii stickers.

### Sticker Words
Every vocabulary word is represented as a kawaii sticker containing:
- A cute illustrated image representing the word
- The word in the target language
- The word in English (base language)

### Learning Loop
1. **Explore** - Visit a location in your journal
2. **Learn** - AI generates new sticker words for that location
3. **Collect** - Add learned words to your journal
4. **Revise** - Flashcard-style review of collected stickers

---

## Feature Specifications

### 1. Onboarding & Authentication

#### 1.1 Welcome Screen
- App logo with kawaii animation
- Tagline: "Collect words, learn languages"
- Single CTA: "Sign in with Apple" button

#### 1.2 Sign in with Apple
- Native Sign in with Apple implementation
- Minimal data collection (only Apple-provided identifier)
- Automatic account creation on first sign-in
- Seamless re-authentication on subsequent launches

#### 1.3 First-Time User Flow
After successful sign-in, new users proceed directly to language picker.

---

### 2. Language Selection & Management

#### 2.1 Initial Language Picker
- Display after first sign-in
- Grid of available languages with flags/icons
- Each language shows its name in both English and native script
- Single selection to start (can add more later)

#### 2.2 Supported Languages (v1.0)
| Language | Native Name | Flag |
|----------|-------------|------|
| Japanese | 日本語 | 🇯🇵 |
| Korean | 한국어 | 🇰🇷 |
| Spanish | Español | 🇪🇸 |
| French | Français | 🇫🇷 |
| German | Deutsch | 🇩🇪 |
| Italian | Italiano | 🇮🇹 |
| Portuguese | Português | 🇵🇹 |
| Mandarin Chinese | 中文 | 🇨🇳 |

#### 2.3 Language Switcher
- Accessible from main journal view (top navigation)
- Tap current language flag/icon to reveal switcher
- Shows all user's journals with word count
- "Add New Language" option at bottom
- Quick switch without leaving current context

---

### 3. Journal System

#### 3.1 Journal Home (Main View)
- Displays current language journal
- Language switcher in navigation bar
- Grid of location cards
- Each location card shows:
  - Location illustration (kawaii style)
  - Location name
  - Sticker count collected (e.g., "12 words")
  - Visual progress indicator

#### 3.2 Locations (v1.0)
| Location | Icon | Description |
|----------|------|-------------|
| ☕ Cafe | Coffee cup | Coffee, drinks, pastries, ordering |
| 🍜 Restaurant | Bowl with chopsticks | Food, dining, reservations |
| 🛒 Store | Shopping bag | Shopping, prices, products |
| 🚉 Station | Train | Transportation, directions, tickets |
| 🏠 Home | House | Household items, family, daily life |
| 🌳 Park | Tree | Nature, activities, weather |
| 🏥 Hospital | Medical cross | Health, body, emergencies |
| 🏢 Office | Building | Work, business, meetings |

#### 3.3 Location Journal Page
When user taps a location:
- Full-page journal aesthetic (paper texture, slight tilt)
- Collected stickers arranged organically (not rigid grid)
- Stickers can slightly overlap for natural feel
- Two floating action buttons:
  - **"+ Learn New"** - Add new words via AI
  - **"📖 Revise"** - Review collected words

---

### 4. Learning New Words

#### 4.1 Learn Flow Entry
- User taps "+ Learn New" in a location journal
- AI generates 3-5 new words relevant to that location
- Words user hasn't collected yet are prioritized

#### 4.2 Word Presentation
Each new word is presented one at a time:
- Large kawaii sticker image (AI-generated)
- Target language word (large, prominent)
- Romanization/pronunciation guide (where applicable)
- English translation
- Audio pronunciation button (AI TTS)
- Example sentence (optional, shown on tap)

#### 4.3 Collection Actions
For each word:
- **"Add to Journal"** - Saves sticker to collection, advances to next
- **"Skip"** - Don't add, advances to next
- **"I know this"** - Marks as known, doesn't add to revision queue

#### 4.4 Learning Session End
- Summary: "You collected X new stickers!"
- Animated stickers flying into journal
- Return to location journal page

---

### 5. Revision System

#### 5.1 Revision Entry
- User taps "📖 Revise" in a location journal
- Only collected stickers from that location are included
- Minimum 3 stickers required to start revision

#### 5.2 Flashcard Interface
- Card flip animation (3D transform)
- **Front:** Kawaii sticker + target language word
- **Back:** English translation + pronunciation

#### 5.3 Self-Assessment
After revealing back:
- **"Got it! ✓"** - Increases mastery level
- **"Still learning"** - Decreases mastery level

#### 5.4 Spaced Repetition Logic
- Words with lower mastery appear more frequently
- Mastery levels: 1 (new) → 5 (mastered)
- Simple algorithm based on consecutive correct answers

#### 5.5 Revision Session End
- Summary: "X words revised, Y mastered!"
- Progress animation
- Option to continue or return to journal

---

### 6. Settings

#### 6.1 Settings Access
- Gear icon in navigation bar (journal home)
- Modal sheet presentation

#### 6.2 Settings Options

##### Notifications
- **Daily Reminder Toggle** (ON/OFF)
- **Reminder Time Picker** (default: 9:00 AM)
- **Notification Preview:**
  - "Time to collect new words! 🌸"
  - "Your journal misses you! ✨"
  - (Randomized friendly messages)

##### Account
- **Apple ID** (display only, email if available)
- **Sign Out** button (with confirmation alert)

##### About
- App version
- Privacy Policy link
- Terms of Service link

---

## User Flows

### Flow 1: New User Onboarding
```
Launch App
    ↓
Welcome Screen
    ↓
Sign in with Apple
    ↓
Language Picker
    ↓
[Select Language]
    ↓
Journal Home (empty state)
    ↓
Prompt to visit first location
```

### Flow 2: Learning New Words
```
Journal Home
    ↓
Tap Location Card
    ↓
Location Journal Page
    ↓
Tap "+ Learn New"
    ↓
AI generates words
    ↓
Word 1 presented
    ↓
[Add/Skip/Know]
    ↓
... repeat for all words ...
    ↓
Session Summary
    ↓
Return to Location Journal
```

### Flow 3: Revision Session
```
Location Journal Page
    ↓
Tap "📖 Revise"
    ↓
Flashcard Front shown
    ↓
Tap to flip
    ↓
Flashcard Back revealed
    ↓
[Got it / Still learning]
    ↓
Next card
    ↓
... repeat ...
    ↓
Session Summary
    ↓
Return to Location Journal
```

### Flow 4: Language Switching
```
Journal Home
    ↓
Tap Language Switcher
    ↓
Language List appears
    ↓
[Tap existing language]
    ↓
Journal switches instantly
    
    OR
    
[Tap "Add New Language"]
    ↓
Language Picker
    ↓
[Select Language]
    ↓
New Journal created
    ↓
Navigate to new Journal Home
```

---

## Data Models

### User
```swift
struct User {
    let id: UUID
    let appleUserIdentifier: String
    var createdAt: Date
    var lastActiveAt: Date
}
```

### Language
```swift
struct Language {
    let id: UUID
    let code: String          // "ja", "ko", "es", etc.
    let name: String          // "Japanese"
    let nativeName: String    // "日本語"
    let flagEmoji: String     // "🇯🇵"
}
```

### Journal
```swift
struct Journal {
    let id: UUID
    let userId: UUID
    let languageId: UUID
    var createdAt: Date
    var lastOpenedAt: Date
}
```

### Location
```swift
struct Location {
    let id: UUID
    let name: String          // "Cafe"
    let icon: String          // "☕"
    let description: String
    let sortOrder: Int
}
```

### StickerWord
```swift
struct StickerWord {
    let id: UUID
    let journalId: UUID
    let locationId: UUID
    let targetWord: String        // "コーヒー"
    let romanization: String?     // "koohii"
    let englishWord: String       // "coffee"
    let stickerImageURL: String   // AI-generated image
    let audioURL: String?         // TTS audio
    var masteryLevel: Int         // 1-5
    var lastReviewedAt: Date?
    var collectedAt: Date
}
```

### NotificationSettings
```swift
struct NotificationSettings {
    var isEnabled: Bool
    var reminderTime: Date        // Time component only
}
```

---

## AI Integration

### 1. Word Generation
**Provider:** OpenAI GPT-4 (or equivalent)

**Prompt Strategy:**
```
Generate {count} vocabulary words for a {language} learner.
Context: {location} setting
Difficulty: Beginner to intermediate
Exclude: {already_collected_words}

For each word provide:
- Word in {language}
- Romanization (if applicable)
- English translation
- Brief example sentence
```

### 2. Sticker Image Generation
**Provider:** OpenAI DALL-E 3 (or equivalent)

**Prompt Strategy:**
```
Create a kawaii-style sticker illustration of "{word}".
Style: Japanese kawaii, soft pastel colors, cute rounded shapes,
       simple design, white background, sticker-like appearance.
Do not include any text in the image.
```

**Image Specifications:**
- Size: 512x512 px
- Format: PNG with transparency
- Style: Consistent kawaii aesthetic across all stickers

### 3. Text-to-Speech
**Provider:** Native iOS AVSpeechSynthesizer or OpenAI TTS

**Configuration:**
- Use native voice for target language
- Slower speaking rate for learning
- Cache audio files locally

---

## Design Guidelines

### Visual Style
- **Aesthetic:** Japanese kawaii, soft, cute, approachable
- **Color Palette:**
  - Primary: Soft pink (#FFB6C1)
  - Secondary: Cream/Beige (#FFF8DC)
  - Accent: Mint green (#98FF98)
  - Text: Warm gray (#4A4A4A)
- **Typography:**
  - Headings: Rounded sans-serif (SF Rounded)
  - Body: System default
  - Japanese text: Hiragino Sans
- **Iconography:** Rounded, filled icons with soft edges

### Animation Principles
- Bouncy, playful spring animations
- Subtle scale on tap (0.95 → 1.0)
- Sticker "pop" effect when collected
- Gentle floating/bobbing for idle states

### Journal Aesthetic
- Paper-like texture background
- Slightly tilted stickers for organic feel
- Soft drop shadows
- Tape/pin decorations on stickers
- Hand-drawn style borders

### Accessibility
- Support Dynamic Type
- VoiceOver labels for all stickers
- Sufficient color contrast
- Haptic feedback on interactions

---

## Technical Requirements

### Platform & SDK
- **iOS Version:** 26.0+
- **Swift Version:** 6.0
- **UI Framework:** SwiftUI
- **Minimum Device:** iPhone (no iPad optimization for v1.0)

### Architecture
- **Pattern:** MVVM with Swift Observation
- **Data Persistence:** SwiftData
- **Networking:** Swift async/await, URLSession
- **State Management:** @Observable, @Environment

### Dependencies (Minimal)
- Native frameworks only where possible
- OpenAI Swift SDK for AI features
- No third-party UI libraries

### Backend Requirements
- **Authentication:** Sign in with Apple (stateless JWT validation)
- **AI Proxy:** Simple API proxy for OpenAI calls (rate limiting, key management)
- **Image Storage:** Cloud storage for generated sticker images
- **Optional:** Sync service for cross-device (future consideration)

### Data Storage
- **Local:** SwiftData for all user data
- **Images:** Local cache + cloud backup
- **Audio:** Generated on-demand, cached locally

### Notifications
- Local notifications only (no push server needed)
- UNUserNotificationCenter
- Daily reminder scheduling

---

## Screen Inventory

| Screen | Type | Description |
|--------|------|-------------|
| Welcome | Full Screen | Sign in with Apple CTA |
| Language Picker | Full Screen | Initial language selection |
| Journal Home | Tab/Main | Grid of location cards |
| Location Journal | Full Screen | Sticker collection view |
| Learn Session | Full Screen | Word-by-word learning |
| Revision Session | Full Screen | Flashcard review |
| Language Switcher | Sheet | Switch/add languages |
| Settings | Sheet | Notifications, account |

---

## Success Metrics

### Engagement
- Daily Active Users (DAU)
- Session duration
- Words learned per session
- Revision completion rate

### Retention
- Day 1, 7, 30 retention
- Return to revision rate
- Language journal completion

### Learning
- Average mastery level progression
- Words reaching mastery level 5
- Cross-location vocabulary diversity

---

## Future Considerations (Post v1.0)

### Features Not in Scope for v1.0
- [ ] iPad support
- [ ] Multiple base languages (currently English only)
- [ ] Social features (sharing, friends)
- [ ] Achievements/badges
- [ ] Custom sticker collections
- [ ] Audio recording for pronunciation practice
- [ ] Offline AI mode
- [ ] Widget support
- [ ] iCloud sync
- [ ] Siri Shortcuts integration

### Potential v1.1 Features
- Additional locations
- Additional languages
- Sentence practice mode
- Statistics dashboard

---

## Appendix

### A. Localization
Base language for v1.0: English only
UI Localization: Not in scope for v1.0

### B. Privacy
- No personal data collection beyond Apple User ID
- All learning data stored locally
- AI requests anonymized (no user identifiers sent)
- Privacy policy required for App Store

### C. App Store Requirements
- Age rating: 4+
- Category: Education
- Screenshots: 6.7" iPhone required
- Preview video: Recommended

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 7, 2025 | - | Initial PRD |

---

*End of Document*
