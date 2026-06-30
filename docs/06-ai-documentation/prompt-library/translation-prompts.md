# Translation Prompts Library

## Overview

Multi-language content translation with cultural adaptation, platform tone preservation, and hashtag/mention handling.

---

## Translation System Prompt

### Base System Prompt

```
You are a professional content translator specializing in social media. You translate content while:

1. Preserving the original meaning and intent
2. Adapting to cultural context of the target language
3. Maintaining platform-appropriate tone
4. Handling hashtags, mentions, and links appropriately
5. Optimizing for the target audience's cultural norms
6. Preserving emojis and visual elements

Rules:
- Translate naturally, not word-for-word
- Adapt idioms and expressions to target culture
- Keep proper nouns, brand names, and URLs unchanged
- Maintain hashtag format but translate when appropriate
- Preserve @mentions unchanged
- Adjust humor and references for cultural relevance
- Maintain the same emotional impact
```

### Language-Specific Prompts

---

## Spanish Translation Prompt

```
Translate the following social media content to Spanish (Castilian/Latin American based on target):

Source Language: {source_language}
Target Language: Spanish ({variant} - castilian/latin_american)
Platform: {platform}
Tone: {tone}

Rules:
- Use appropriate formality level (tú/usted)
- Adapt cultural references to Spanish-speaking audience
- Keep hashtags in original language OR translate if they're descriptive
- Preserve @mentions
- Adapt date/time formats
- Use region-appropriate vocabulary

Target Variants:
- es-ES: Spain Spanish
- es-MX: Mexican Spanish
- es-AR: Argentine Spanish
- es-CO: Colombian Spanish
```

### Spanish Translation Example
```
Original (English):
"Hey everyone! Just dropped my latest guide on social media marketing. Check it out and let me know what you think! 🚀 #MarketingTips #SocialMedia"

Spanish (Latin American):
"¡Hola a todos! Acabo de publicar mi última guía sobre marketing en redes sociales. ¡Déjame saber qué te parece! 🚀 #ConsejosDeMarketing #RedesSociales"

Spanish (Spain):
"¡Hola a todos! Acabo de publicar mi última guía sobre marketing en redes sociales. ¡Déjame saber qué te parece! 🚀 #ConsejosDeMarketing #RedesSociales"
```

---

## French Translation Prompt

```
Translate to French:

Target Language: French ({variant} - france/canadian/belgian)
Platform: {platform}
Tone: {tone}

Rules:
- Use appropriate formality (tu/vous)
- Adapt cultural references
- French uses guillemets « » for quotes
- Preserve hashtags or translate descriptive ones
- French often uses more formal tone on professional platforms
- Adapt humor for French cultural context
```

### French Translation Example
```
Original:
"Can't wait to share this with you all! The results are incredible. 🎉"

French:
"J'ai hâte de partager ça avec vous tous ! Les résultats sont incroyables. 🎉"
```

---

## German Translation Prompt

```
Translate to German:

Target Language: German ({variant} - germany/austrian/swiss)
Platform: {platform}
Tone: {tone}

Rules:
- Use appropriate formality (du/Sie)
- German compounds words (keep readable)
- Preserve brand names
- German often uses more formal professional communication
- Adapt humor (German humor differs from English)
- Use appropriate capitalization rules
```

### German Translation Example
```
Original:
"Here are 5 tips to boost your productivity. Save this for later!"

German:
"Hier sind 5 Tipps, um deine Produktivität zu steigern. Speicher das für später!"
```

---

## Portuguese Translation Prompt

```
Translate to Portuguese:

Target Language: Portuguese ({variant} - brazilian/european)
Platform: {platform}
Tone: {tone}

Rules:
- Brazilian Portuguese is more casual/expressive
- European Portuguese is more formal
- Preserve hashtags (translate descriptive ones)
- Adapt cultural references to Brazilian/European context
- Brazil uses more exclamation marks and emojis
```

### Portuguese Translation Example
```
Original:
"This changed my life! You need to try this."

Brazilian Portuguese:
"Isso mudou minha vida! Você precisa experimentar isso! 🔥"

European Portuguese:
"Isto mudou a minha vida. Precisa de experimentar isto."
```

---

## Japanese Translation Prompt

```
Translate to Japanese:

Target Language: Japanese
Platform: {platform}
Tone: {tone}

Rules:
- Use appropriate keigo (politeness level)
- Preserve hashtags in English OR use Japanese hashtags
- Japanese social media uses specific formatting
- Adapt for Japanese cultural norms
- Keep brand names in original form
- Japanese often uses shorter sentences
- Use appropriate particle usage
- Preserve emoji (emoji originated in Japan)
```

### Japanese Translation Example
```
Original:
"Check out my new blog post! Link in bio. #Blogging #ContentCreation"

Japanese:
"新しいブログ記事をチェック！リンクはプロフィールにあります。 #ブログ #コンテンツ制作"
```

---

## Chinese Translation Prompt

```
Translate to Chinese:

Target Language: Chinese ({variant} - simplified/traditional)
Platform: {platform}
Tone: {tone}

Rules:
- Simplified Chinese: Mainland China, Singapore
- Traditional Chinese: Taiwan, Hong Kong
- Preserve hashtags (translate or keep English)
- Chinese platforms have different conventions
- Adapt cultural references appropriately
- Keep brand names in original form
- Use appropriate measure words
```

### Chinese Translation Example
```
Original:
"New video just dropped! Don't forget to subscribe. 🎬"

Simplified Chinese:
"新视频发布了！别忘了订阅。🎬"

Traditional Chinese:
"新影片發布了！別忘了訂閱。🎬"
```

---

## Arabic Translation Prompt

```
Translate to Arabic:

Target Language: Arabic ({variant} - standard/egyptian/saudi)
Platform: {platform}
Tone: {tone}

Rules:
- Right-to-left text direction
- Preserve hashtags (translate descriptive ones)
- Use Modern Standard Arabic for broad reach
- Adapt for cultural sensitivity
- Keep brand names in original form
- Arabic uses different punctuation conventions
- Consider religious/cultural references
```

---

## Hindi Translation Prompt

```
Translate to Hindi:

Target Language: Hindi
Platform: {platform}
Tone: {tone}

Rules:
- Use Devanagari script
- Preserve hashtags (translate or keep English)
- Hindi social media often uses Hinglish (Hindi-English mix)
- Adapt cultural references
- Keep brand names in original form
- Consider regional dialect variations
```

---

## Cultural Adaptation System

### Cultural Context Variables

```yaml
cultural_context:
  target_market: "japan"
  communication_style: "indirect"
  formality_level: "high"
  humor_style: "subtle"
  color_meanings:
    red: "luck, prosperity"
    white: "mourning"
    black: "formal, mystery"
  taboo_topics: ["death", "personal questions"]
  greeting_style: "formal"
  emoji_conventions: ["bow", "cherry_blossom", " seasonal references"]
```

### Adaptation Rules by Culture

| Culture | Formality | Humor | Directness | Emoji Use |
|---------|-----------|-------|------------|-----------|
| Japanese | High | Subtle | Indirect | Moderate |
| American | Low-Medium | Direct | Direct | High |
| German | Medium-High | Dry | Direct | Low |
| Brazilian | Low | Expressive | Indirect | Very High |
| British | Medium | Sarcastic | Indirect | Moderate |
| Indian | Medium | Varied | Moderate | High |
| French | Medium-High | Intellectual | Direct | Moderate |

---

## Platform-Specific Translation Rules

### Instagram Translation
```
Platform: Instagram
Rules:
- Keep hashtags in original OR translate (test both)
- Preserve emojis (universal language)
- Maintain line break formatting
- Keep @mentions unchanged
- Stories: use platform-specific sticker text
- Reels: subtitle translation separate from caption
```

### Twitter/X Translation
```
Platform: Twitter/X
Rules:
- Keep under 280 characters in target language
- Translate hashtags if they're descriptive
- Preserve trending hashtags in original
- Thread translation: maintain numbering
- Quote tweets: translate commentary, keep original
```

### LinkedIn Translation
```
Platform: LinkedIn
Rules:
- More formal translation acceptable
- Professional terminology important
- Article translations: full adaptation
- Preserve @mentions and company names
- Industry-specific jargon: use local equivalents
```

### TikTok Translation
```
Platform: TikTok
Rules:
- Keep trending sounds in original language
- Translate captions for accessibility
- Preserve #FYP and universal hashtags
- Adapt humor for cultural relevance
- Video text overlays: translate or localize
```

---

## Hashtag Translation Strategy

### Translation Options

| Strategy | When to Use | Example |
|----------|-------------|---------|
| Keep Original | Brand hashtags, trending tags | #JustDoIt → #JustDoIt |
| Translate | Descriptive hashtags | #MarketingTips → #ConsejosDeMarketing |
| Hybrid | Popular + translated | #SocialMedia + #MarketingDigital |
| Localize | Platform-specific | #MondayMotivation → #MotivaciónLunes |

### Hashtag Translation Rules

```typescript
interface HashtagTranslation {
  original: string;
  translated: string | null;
  strategy: 'keep' | 'translate' | 'hybrid' | 'localize';
  reason: string;
}

const translateHashtag = (hashtag: string, targetLang: string): HashtagTranslation => {
  // Brand hashtags: keep original
  if (isBrandHashtag(hashtag)) {
    return { original: hashtag, translated: null, strategy: 'keep', reason: 'Brand hashtag' };
  }
  
  // Trending hashtags: keep original
  if (isTrending(hashtag)) {
    return { original: hashtag, translated: null, strategy: 'keep', reason: 'Trending tag' };
  }
  
  // Descriptive hashtags: translate
  return { 
    original: hashtag, 
    translated: translateText(hashtag, targetLang), 
    strategy: 'translate', 
    reason: 'Descriptive hashtag' 
  };
};
```

---

## Translation Quality Assurance

### QA Checklist

```
□ Meaning preserved accurately
□ Tone matches original intent
□ Cultural references adapted appropriately
□ Hashtags handled correctly
□ @mentions preserved
□ Links/URLs unchanged
□ Character limits respected
□ Platform formatting maintained
□ Emoji usage appropriate
□ Grammar and spelling correct
□ Natural/native-sounding
□ No literal translations
□ Brand voice consistent
□ Call-to-action effective in target language
```

### Quality Scoring

| Metric | Weight | Description |
|--------|--------|-------------|
| Accuracy | 30% | Meaning preserved correctly |
| Fluency | 25% | Natural, native-sounding |
| Cultural Fit | 20% | Appropriate for target culture |
| Platform Compliance | 15% | Meets platform requirements |
| Brand Consistency | 10% | Maintains brand voice |

---

## Machine Translation + Human Review Pipeline

### Workflow

```
Original Content → MT Engine → Post-Editing → QA Review → Publish
       │              │              │              │
       ▼              ▼              ▼              ▼
   Source Lang    Initial        Human          Final
                  Translation   Refinement     Approval
```

### When to Use Each Approach

| Content Type | Approach | Reason |
|--------------|----------|--------|
| Evergreen content | MT + Full review | Quality critical |
| Time-sensitive | MT + Light review | Speed priority |
| Brand campaigns | Human translation | Brand voice critical |
| User comments | MT only | Volume, speed |
| Legal/compliance | Human only | Accuracy critical |
| Blog posts | MT + Review | Balance quality/speed |
