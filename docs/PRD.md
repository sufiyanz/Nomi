# Nomi - Product Requirements Document

## Overview
Nomi is a language learning app focused on contextual, real-world vocabulary acquisition. Unlike traditional gamified language apps with streaks and guilt-inducing mechanics, Nomi encourages users to learn vocabulary in context by collecting stickers representing everyday objects from their surroundings - whether in a cinema, café, or train.

## Target Users
- Language learners seeking a low-pressure, contextual approach
- Users tired of streak-based gamification (e.g., Duolingo burnout)
- People who want to learn vocabulary relevant to their daily environments

## Core Features
1. **Sticker Collection**: Collect illustrated stickers representing real-world objects
2. **Spaces**: 10 location-based vocabulary categories (Home, Café, Restaurant, etc.)
3. **Multi-Language Support**: Learn vocabulary in different languages via language picker
4. **Streak System**: Simple daily streak - learn at least 1 word per day to maintain
5. **Apple Sign-In**: Simple, privacy-focused authentication

---

## Screens

### Screen 1: Welcome / Sign In

**Purpose**: First impression and authentication

**Visual Elements**:
- Dark charcoal background with subtle dotted grid pattern
- Centered app logo ("nomi" in pink on dark purple rounded square)
- Floating animated stickers scattered around edges (salad, stapler, coffee cup, croissant)
- Tagline text centered below logo
- Sign-in button at bottom
- Legal footer with Terms of Service and Privacy Policy links

**Copy**:
- Headline: "Less gamified guilt. More real-world recall."
- Subheadline: "Open it in a cinema, café or train and collect stickers from the room."
- Button: "Continue with Apple"
- Footer: "By pressing on "Continue with..." you agree to our Terms of Service and Privacy Policy"

**Interactions**:
- Stickers float gently with subtle animation
- Tap "Continue with Apple" → Native Apple Sign-In flow
- Tap Terms of Service → Opens Terms page
- Tap Privacy Policy → Opens Privacy page

**Technical Requirements**:
- Sign in with Apple (ASAuthorizationController)
- Floating animation for stickers (subtle up/down movement)

---

### Screen 2: Spaces (Home Screen)

**Purpose**: Main navigation - browse and select learning spaces

**Visual Elements**:
- Dark charcoal background with dotted grid pattern
- **Header Area**:
  - Settings icon (gear, top-left) → Opens Settings sheet
  - Language Picker (dropdown showing current language, e.g., "🇯🇵 Japanese")
  - Streak Counter (centered, shows flame icon + day count)
- **Carousel**: Horizontally scrollable space cards
  - Each card shows:
    - Space illustration/icon
    - Space name (e.g., "Home", "Café")
    - Progress indicator (e.g., "0/19" words collected)
- **Floating Stickers**: Decorative stickers around edges (same style as welcome screen)

**Spaces (10 at launch)**:
1. Home
2. Café
3. Restaurant
4. Office
5. Grocery Store
6. Train/Transit
7. Cinema
8. Gym
9. Park
10. Hospital/Pharmacy

**Streak System**:
- Streak increments when user learns at least 1 new word in a day
- Resets to 0 if a day is missed
- Display: 🔥 + number (e.g., "🔥 5" for 5-day streak)
- Streak of 0 shows "🔥 0" or empty state

**Interactions**:
- Swipe left/right to browse spaces
- Tap a space card → Opens Space Detail (word collection view)
- Tap language picker → Opens language selection dropdown/sheet
- Tap settings icon → Opens Settings sheet
- Streak counter is display-only (tappable for stats in future?)

**Technical Requirements**:
- Horizontal carousel (SwiftUI TabView or custom ScrollView)
- Language picker with supported languages
- Streak calculation based on last word learned date
- Persist selected language in UserDefaults/SwiftData

---

### Screen 3: Space Detail (Canvas View)

**Purpose**: Explore and collect vocabulary words within a space

**Visual Elements**:
- Dark background with dotted grid pattern
- **Header**:
  - Back button (top-left) → Returns to Spaces home
  - Space name (centered, e.g., "Café")
  - Progress counter (e.g., "5/19")
- **Canvas Area**:
  - Pannable, zoomable canvas (bounded, not infinite)
  - Stickers randomly scattered across canvas
  - Each sticker = one vocabulary word
  - Canvas size fits all words for that space
- **Bottom Tab Bar** (2 tabs):
  - Left: Canvas icon (current view, default)
  - Right: Review/List icon (collected words list)

**Sticker States**:
- **Uncollected**: Full opacity, vibrant colors
- **Collected/Learned**: Reduced opacity + checkmark badge
  - Shows user has already learned this word
  - Still tappable to review

**Sticker Design**:
- Hand-drawn illustration style (consistent with app)
- Each sticker represents an object relevant to the space
- Examples for Café: coffee cup, croissant, tea, scone, menu, chair, table, barista, etc.

**Interactions**:
- **Pan**: Drag to move around the canvas
- **Pinch**: Zoom in/out to see more or fewer stickers
- **Tap sticker**: Opens Word Card (learning view)
- **Tap back button**: Returns to Spaces home
- **Tap Review tab**: Switches to Review List view

**Technical Requirements**:
- Canvas: UIScrollView with zooming or SwiftUI ScrollView + MagnificationGesture
- Gesture handling: Pan + Pinch simultaneously
- Sticker positions: Pre-calculated random layout (seeded for consistency)
- Track collected state per word per user

---

### Screen 4: Word Card (Popup)

**Purpose**: Display word details and allow user to collect/learn the word

**Presentation**: Modal popup card over the canvas (dimmed background)

**Visual Elements**:
- **Card Container**: Light cream/beige rounded rectangle
- **Close Button**: Pink X in dark circle (top-right corner)
- **Sticker Image**: Large illustration (same as canvas sticker), centered
- **Word in Target Language**: Large bold text (e.g., "コーヒーカップ")
- **Audio Button (Word)**: Pink speaker icon next to the word
- **Romanization**: Pink text below the word (e.g., "Kōhī Kappu")
- **English Section**:
  - Label: "English" (gray, small)
  - Translation: Bold black text (e.g., "Coffee Cup")
- **Example Sentence Section** ("Word in use"):
  - Label: "Word in use" (gray, small)
  - Sentence in target language with inline romanization
  - Audio button for sentence
  - English translation (pink text)
- **"Got it" Button**: Primary action button at bottom (pink, full-width)

**Content Structure**:
```
[Sticker Image]

コーヒーカップ  🔊
Kōhī Kappu

─────────────────
English
Coffee Cup

Word in use
コーヒーカップ (kōhi kappu) を (o) 取って (totte) ください (kudasai)  🔊
Please hand me the coffee cup

[ Got it ]
```

**Interactions**:
- **Tap 🔊 (word)**: Plays audio pronunciation of the word only
- **Tap 🔊 (sentence)**: Plays audio of the full example sentence
- **Tap "Got it"**: Marks word as collected, closes card, updates sticker state on canvas
- **Tap X**: Closes card without collecting
- **Tap outside card**: Closes card without collecting

**Technical Requirements**:
- Text-to-speech (TTS) for word and sentence audio (AVSpeechSynthesizer or cloud TTS)
- LLM-generated content: translations, romanization, example sentences
- Store collected state in local database (SwiftData)
- Animate card appearance (scale up + fade in)

---

### Screen 5: Review List

*To be documented - waiting for screenshot*

---

### Screen 5: Review (Reels-style)

**Purpose**: Quick, engaging review of collected vocabulary

**Presentation**: Full-screen vertical swipeable cards (like Instagram Reels/TikTok)

**Visual Elements**:
- **Header**:
  - Back button (top-left)
  - Progress indicator (e.g., "3/12")
- **Card Content** (full screen):
  - Large sticker illustration (centered)
  - Word in target language (large, bold)
  - Audio button (speaker icon)
  - Romanization (below word)
  - "Show Answer" button (initially hidden state)
- **After Reveal**:
  - English translation
  - Example sentence + translation
- **Self-Rating Buttons** (bottom):
  - 👎 Hard
  - 😐 Okay  
  - 👍 Easy

**Flow**:
1. Card shows sticker + target language word (answer hidden)
2. User taps "Show Answer" → Reveals English + example
3. User rates themselves (Hard/Okay/Easy)
4. Swipe up → Next word
5. Swipe down → Previous word

**Spaced Repetition** (simple):
- "Hard" words appear more frequently in future reviews
- "Easy" words appear less frequently
- "Okay" words maintain normal frequency

**Review Scope**: Words from current space only

**Empty State**: If no words collected, show message: "No words to review yet. Explore the space to collect some!"

**Technical Requirements**:
- Vertical paging (TabView with .page style or custom)
- Track review ratings per word
- Simple spaced repetition algorithm
- TTS for audio playback

---

### Screen 6: Settings

**Purpose**: App configuration and account management

**Presentation**: Modal sheet (slides up from Spaces home)

**Visual Elements**:
- **Header**: "Settings" title + Close button (X, top-right)
- Light cream/beige background
- Grouped sections with rounded cards

**Sections**:

**1. Notifications**
| Setting | Control |
|---------|---------|
| Daily reminder | Toggle (on/off) |
| Reminder time | Time picker (shown when toggle is on) |

**2. Account**
| Item | Display |
|------|---------|
| Apple ID | User's email (truncated) |
| Sign out | Red text + logout icon |

**3. About**
| Item | Action |
|------|--------|
| Version | "1.0" (display only) |
| Privacy policy | Opens external link |
| Terms of service | Opens external link |

**Interactions**:
- Toggle daily reminder on/off
- When on, tap time to open time picker
- Tap "Sign out" → Confirmation alert → Sign out → Return to Welcome screen
- Tap Privacy policy / Terms → Opens in Safari/in-app browser
- Tap X → Closes settings sheet

**Technical Requirements**:
- Local notifications scheduling (UNUserNotificationCenter)
- Time picker for reminder time
- Sign out clears local session
- Store notification preferences in UserDefaults

---

## Technical Requirements
- Platform: iOS
- Language: Swift / SwiftUI
- Minimum iOS Version: 17.0
- Authentication: Sign in with Apple only
- LLM Integration: For vocabulary translation and generation

---

## Supported Languages

**Base Language**: English (for translations and UI)

**Target Languages (10)**:
1. 🇪🇸 Spanish
2. 🇫🇷 French
3. 🇩🇪 German
4. 🇯🇵 Japanese
5. 🇮🇹 Italian
6. 🇰🇷 Korean
7. 🇨🇳 Mandarin Chinese
8. 🇧🇷 Portuguese
9. 🇷🇺 Russian
10. 🇸🇦 Arabic

---

## Design System

### Colors
- **Background**: Dark charcoal (#2A2A2A or similar)
- **Primary Accent**: Pink (#FFB6C1 or similar)
- **Text Primary**: White/Off-white
- **Text Secondary**: Gray (muted)

### Typography
- **Headlines**: Serif font (elegant, warm feel)
- **Body/UI**: Rounded sans-serif

### Visual Style
- Stickers: Hand-drawn illustration style with cream/white outlines
- Playful but sophisticated aesthetic
- Dotted grid pattern on dark backgrounds

---

## Data Models
*To be defined as screens are reviewed*

---

## Future Considerations
*To be added*
