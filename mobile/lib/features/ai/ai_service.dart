import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum ProviderHealth { healthy, degraded, down, unknown }

class AiProvider {
  final String name;
  final String baseUrl;
  final String? apiKey;
  final String model;
  final bool enabled;
  final int priority;
  final int dailyTokenLimit;
  final int tokensUsedToday;
  final DateTime? lastHealthCheck;
  final ProviderHealth health;
  final String? lastError;
  final int consecutiveFailures;

  const AiProvider({
    required this.name,
    required this.baseUrl,
    this.apiKey,
    this.model = '',
    this.enabled = true,
    this.priority = 0,
    this.dailyTokenLimit = 0,
    this.tokensUsedToday = 0,
    this.lastHealthCheck,
    this.health = ProviderHealth.unknown,
    this.lastError,
    this.consecutiveFailures = 0,
  });

  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;
  bool get isAvailable => enabled && hasApiKey;
  bool get isTokenExhausted => dailyTokenLimit > 0 && tokensUsedToday >= dailyTokenLimit;
  bool get isTokenLow => dailyTokenLimit > 0 && tokensUsedToday >= dailyTokenLimit * 0.8;
  double get tokenUsagePercent =>
      dailyTokenLimit > 0 ? tokensUsedToday / dailyTokenLimit : 0;
  int get tokensRemaining =>
      dailyTokenLimit > 0 ? dailyTokenLimit - tokensUsedToday : -1;

  Map<String, dynamic> toJson() => {
        'name': name,
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'model': model,
        'enabled': enabled,
        'priority': priority,
        'dailyTokenLimit': dailyTokenLimit,
        'tokensUsedToday': tokensUsedToday,
        'lastHealthCheck': lastHealthCheck?.toIso8601String(),
        'health': health.name,
        'lastError': lastError,
        'consecutiveFailures': consecutiveFailures,
      };

  factory AiProvider.fromJson(Map<String, dynamic> json) => AiProvider(
        name: json['name'] ?? '',
        baseUrl: json['baseUrl'] ?? '',
        apiKey: json['apiKey'],
        model: json['model'] ?? '',
        enabled: json['enabled'] ?? true,
        priority: json['priority'] ?? 0,
        dailyTokenLimit: json['dailyTokenLimit'] ?? 0,
        tokensUsedToday: json['tokensUsedToday'] ?? 0,
        lastHealthCheck: json['lastHealthCheck'] != null
            ? DateTime.tryParse(json['lastHealthCheck'])
            : null,
        health: ProviderHealth.values.firstWhere(
          (h) => h.name == json['health'],
          orElse: () => ProviderHealth.unknown,
        ),
        lastError: json['lastError'],
        consecutiveFailures: json['consecutiveFailures'] ?? 0,
      );

  AiProvider copyWith({
    String? name,
    String? baseUrl,
    String? apiKey,
    String? model,
    bool? enabled,
    int? priority,
    int? dailyTokenLimit,
    int? tokensUsedToday,
    DateTime? lastHealthCheck,
    ProviderHealth? health,
    String? lastError,
    int? consecutiveFailures,
  }) =>
      AiProvider(
        name: name ?? this.name,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        enabled: enabled ?? this.enabled,
        priority: priority ?? this.priority,
        dailyTokenLimit: dailyTokenLimit ?? this.dailyTokenLimit,
        tokensUsedToday: tokensUsedToday ?? this.tokensUsedToday,
        lastHealthCheck: lastHealthCheck ?? this.lastHealthCheck,
        health: health ?? this.health,
        lastError: lastError ?? this.lastError,
        consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      );
}

class AiUsageStats {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final int totalTokensUsed;
  final String? lastUsedProvider;
  final DateTime? lastUsedAt;

  const AiUsageStats({
    this.totalRequests = 0,
    this.successfulRequests = 0,
    this.failedRequests = 0,
    this.totalTokensUsed = 0,
    this.lastUsedProvider,
    this.lastUsedAt,
  });

  Map<String, dynamic> toJson() => {
        'totalRequests': totalRequests,
        'successfulRequests': successfulRequests,
        'failedRequests': failedRequests,
        'totalTokensUsed': totalTokensUsed,
        'lastUsedProvider': lastUsedProvider,
        'lastUsedAt': lastUsedAt?.toIso8601String(),
      };

  factory AiUsageStats.fromJson(Map<String, dynamic> json) => AiUsageStats(
        totalRequests: json['totalRequests'] ?? 0,
        successfulRequests: json['successfulRequests'] ?? 0,
        failedRequests: json['failedRequests'] ?? 0,
        totalTokensUsed: json['totalTokensUsed'] ?? 0,
        lastUsedProvider: json['lastUsedProvider'],
        lastUsedAt: json['lastUsedAt'] != null
            ? DateTime.tryParse(json['lastUsedAt'])
            : null,
      );

  double get successRate =>
      totalRequests > 0 ? successfulRequests / totalRequests : 0;
}

class AiService {
  static final AiService _instance = AiService._();
  factory AiService() => _instance;
  AiService._();

  List<AiProvider> _providers = [];
  AiUsageStats _stats = const AiUsageStats();
  bool _initialized = false;
  List<String> _lowTokenAlerts = [];

  // Callbacks for admin notifications
  Function(String providerName, int tokensRemaining)? onLowToken;
  Function(String providerName)? onTokenExhausted;
  Function(String providerName, String error)? onProviderDown;

  static const _defaultProviders = [
    AiProvider(
      name: 'Gemini',
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta/models',
      model: 'gemini-2.0-flash',
      apiKey: 'AQ.Ab8RN6KIfdAr1HoVQyGdGqcNjtBt3avN0g9zPVH4XAwWFdvN',
      enabled: true,
      priority: 0,
      dailyTokenLimit: 1500,
    ),
    AiProvider(
      name: 'HuggingFace',
      baseUrl: 'https://api-inference.huggingface.co/models',
      model: 'meta-llama/Llama-2-7b-chat-hf',
      enabled: true,
      priority: 1,
      dailyTokenLimit: 1000,
    ),
    AiProvider(
      name: 'Cohere',
      baseUrl: 'https://api.cohere.ai/v1',
      model: 'command',
      enabled: true,
      priority: 2,
      dailyTokenLimit: 1000,
    ),
  ];

  static const _providersKey = 'ai_providers_v2';
  static const _statsKey = 'ai_usage_stats';
  static const _alertsKey = 'ai_low_token_alerts';

  List<AiProvider> get providers => List.unmodifiable(_providers);
  AiUsageStats get stats => _stats;
  List<String> get lowTokenAlerts => List.unmodifiable(_lowTokenAlerts);

  // Providers sorted by priority, only available ones
  List<AiProvider> get _availableProviders {
    return _providers
        .where((p) => p.isAvailable && !p.isTokenExhausted && p.health != ProviderHealth.down)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    // Load providers
    final stored = prefs.getString(_providersKey);
    if (stored != null) {
      try {
        final list = jsonDecode(stored) as List;
        _providers = list.map((e) => AiProvider.fromJson(e)).toList();
      } catch (_) {
        _providers = List.from(_defaultProviders);
      }
    } else {
      _providers = List.from(_defaultProviders);
    }

    // Load stats
    final statsJson = prefs.getString(_statsKey);
    if (statsJson != null) {
      try {
        _stats = AiUsageStats.fromJson(jsonDecode(statsJson));
      } catch (_) {}
    }

    // Load alerts
    final alertsJson = prefs.getString(_alertsKey);
    if (alertsJson != null) {
      try {
        _lowTokenAlerts = List<String>.from(jsonDecode(alertsJson));
      } catch (_) {}
    }

    _initialized = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _providersKey, jsonEncode(_providers.map((p) => p.toJson()).toList()));
    await prefs.setString(_statsKey, jsonEncode(_stats.toJson()));
    await prefs.setString(_alertsKey, jsonEncode(_lowTokenAlerts));
  }

  // ========== Provider Management ==========

  void updateProvider(int index, AiProvider provider) {
    if (index >= 0 && index < _providers.length) {
      _providers[index] = provider;
      _save();
    }
  }

  void addProvider(AiProvider provider) {
    // Assign priority to end of list
    final maxPriority = _providers.isEmpty
        ? 0
        : _providers.map((p) => p.priority).reduce((a, b) => a > b ? a : b) + 1;
    _providers.add(provider.copyWith(priority: maxPriority));
    _save();
  }

  void removeProvider(int index) {
    if (index >= 0 && index < _providers.length) {
      _providers.removeAt(index);
      _save();
    }
  }

  void moveProvider(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _providers.length) return;
    if (newIndex < 0 || newIndex >= _providers.length) return;

    final provider = _providers.removeAt(oldIndex);
    _providers.insert(newIndex, provider);

    // Update priorities
    for (int i = 0; i < _providers.length; i++) {
      _providers[i] = _providers[i].copyWith(priority: i);
    }
    _save();
  }

  // ========== Token Tracking ==========

  Future<void> _trackTokenUsage(String providerName, int estimatedTokens) async {
    final index = _providers.indexWhere((p) => p.name == providerName);
    if (index < 0) return;

    final provider = _providers[index];
    final newTokensUsed = provider.tokensUsedToday + estimatedTokens;
    _providers[index] = provider.copyWith(tokensUsedToday: newTokensUsed);

    // Update global stats
    _stats = AiUsageStats(
      totalRequests: _stats.totalRequests + 1,
      successfulRequests: _stats.successfulRequests + 1,
      totalTokensUsed: _stats.totalTokensUsed + estimatedTokens,
      lastUsedProvider: providerName,
      lastUsedAt: DateTime.now(),
    );

    // Check for low token alerts
    if (_providers[index].isTokenLow && !_lowTokenAlerts.contains(providerName)) {
      _lowTokenAlerts.add(providerName);
      onLowToken?.call(providerName, _providers[index].tokensRemaining);
    }

    if (_providers[index].isTokenExhausted) {
      if (!_lowTokenAlerts.contains('${providerName}_exhausted')) {
        _lowTokenAlerts.add('${providerName}_exhausted');
        onTokenExhausted?.call(providerName);
      }
    }

    _save();
  }

  Future<void> resetDailyTokens() async {
    for (int i = 0; i < _providers.length; i++) {
      _providers[i] = _providers[i].copyWith(
        tokensUsedToday: 0,
        consecutiveFailures: 0,
        health: ProviderHealth.unknown,
      );
    }
    _lowTokenAlerts.clear();
    _stats = const AiUsageStats();
    _save();
  }

  // ========== Health Checking ==========

  Future<ProviderHealth> checkProviderHealth(AiProvider provider) async {
    if (!provider.hasApiKey) return ProviderHealth.unknown;

    try {
      // Simple health check - make a minimal request
      final headers = {'Content-Type': 'application/json'};

      if (provider.name == 'Gemini') {
        final url = Uri.parse(
            '${provider.baseUrl}/${provider.model}:generateContent?key=${provider.apiKey}');
        final body = jsonEncode({
          'contents': [{'parts': [{'text': 'Hi'}]}],
          'generationConfig': {'maxOutputTokens': 5},
        });
        final response =
            await http.post(url, headers: headers, body: body).timeout(
                  const Duration(seconds: 10),
                );
        if (response.statusCode == 200) return ProviderHealth.healthy;
        if (response.statusCode == 429) return ProviderHealth.degraded;
        return ProviderHealth.down;
      }

      if (provider.name == 'HuggingFace') {
        headers['Authorization'] = 'Bearer ${provider.apiKey}';
        final url =
            Uri.parse('${provider.baseUrl}/${provider.model}');
        final response = await http
            .post(url,
                headers: headers,
                body: jsonEncode({'inputs': 'Hi', 'parameters': {'max_new_tokens': 5}}))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) return ProviderHealth.healthy;
        if (response.statusCode == 429) return ProviderHealth.degraded;
        return ProviderHealth.down;
      }

      if (provider.name == 'Cohere') {
        headers['Authorization'] = 'Bearer ${provider.apiKey}';
        headers['Cohere-Version'] = '2024-12-19';
        final url = Uri.parse('${provider.baseUrl}/generate');
        final body = jsonEncode({
          'model': provider.model,
          'prompt': 'Hi',
          'max_tokens': 5,
        });
        final response =
            await http.post(url, headers: headers, body: body).timeout(
                  const Duration(seconds: 10),
                );
        if (response.statusCode == 200) return ProviderHealth.healthy;
        if (response.statusCode == 429) return ProviderHealth.degraded;
        return ProviderHealth.down;
      }

      return ProviderHealth.unknown;
    } catch (e) {
      return ProviderHealth.down;
    }
  }

  Future<void> checkAllProvidersHealth() async {
    for (int i = 0; i < _providers.length; i++) {
      if (!_providers[i].hasApiKey) continue;

      final health = await checkProviderHealth(_providers[i]);
      _providers[i] = _providers[i].copyWith(
        health: health,
        lastHealthCheck: DateTime.now(),
      );

      if (health == ProviderHealth.down) {
        onProviderDown?.call(_providers[i].name, 'Provider unreachable');
      }
    }
    _save();
  }

  // ========== Main Generate Method ==========

  Future<String> generate({
    required String prompt,
    required String task,
    Map<String, String>? context,
  }) async {
    await initialize();

    final available = _availableProviders;
    String? lastError;

    for (final provider in available) {
      try {
        debugPrint('Trying AI provider: ${provider.name}');
        final result = await _callProvider(provider, prompt, task, context);
        if (result != null && result.isNotEmpty) {
          // Track token usage (estimate ~1 token per 4 chars)
          final estimatedTokens = ((prompt.length + result.length) / 4).ceil();
          await _trackTokenUsage(provider.name, estimatedTokens);

          // Reset consecutive failures on success
          final index = _providers.indexWhere((p) => p.name == provider.name);
          if (index >= 0) {
            _providers[index] = _providers[index].copyWith(
              consecutiveFailures: 0,
              health: ProviderHealth.healthy,
            );
            _save();
          }

          return result;
        }
      } catch (e) {
        debugPrint('AI provider ${provider.name} failed: $e');
        lastError = e.toString();

        // Track failure
        final index = _providers.indexWhere((p) => p.name == provider.name);
        if (index >= 0) {
          final failures = _providers[index].consecutiveFailures + 1;
          ProviderHealth newHealth = ProviderHealth.healthy;
          if (failures >= 3) newHealth = ProviderHealth.down;
          else if (failures >= 1) newHealth = ProviderHealth.degraded;

          _providers[index] = _providers[index].copyWith(
            consecutiveFailures: failures,
            health: newHealth,
            lastError: lastError,
          );

          if (failures >= 3) {
            onProviderDown?.call(provider.name, lastError);
          }
          _save();
        }
        continue;
      }
    }

    // All providers failed - use template fallback
    _stats = AiUsageStats(
      totalRequests: _stats.totalRequests + 1,
      failedRequests: _stats.failedRequests + 1,
      totalTokensUsed: _stats.totalTokensUsed,
      lastUsedProvider: 'fallback',
      lastUsedAt: DateTime.now(),
    );
    _save();

    return _generateFallback(prompt, task);
  }

  // ========== Provider API Calls ==========

  Future<String?> _callProvider(
    AiProvider provider,
    String prompt,
    String task,
    Map<String, String>? context,
  ) async {
    final headers = {'Content-Type': 'application/json'};

    if (provider.name == 'Gemini' && provider.hasApiKey) {
      headers['x-goog-api-key'] = provider.apiKey!;
      final url = Uri.parse(
          '${provider.baseUrl}/${provider.model}:generateContent?key=${provider.apiKey}');
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$task\n\n$prompt'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
        }
      });
      final response =
          await http.post(url, headers: headers, body: body).timeout(
                const Duration(seconds: 30),
              );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      }
      if (response.statusCode == 429) {
        throw Exception('Rate limited');
      }
    }

    if (provider.name == 'HuggingFace' && provider.hasApiKey) {
      headers['Authorization'] = 'Bearer ${provider.apiKey}';
      final url = Uri.parse('${provider.baseUrl}/${provider.model}');
      final body = jsonEncode({
        'inputs': '$task: $prompt',
        'parameters': {
          'max_new_tokens': 512,
          'temperature': 0.7,
        }
      });
      final response =
          await http.post(url, headers: headers, body: body).timeout(
                const Duration(seconds: 30),
              );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data[0]['generated_text'];
        }
      }
      if (response.statusCode == 429) {
        throw Exception('Rate limited');
      }
    }

    if (provider.name == 'Cohere' && provider.hasApiKey) {
      headers['Authorization'] = 'Bearer ${provider.apiKey}';
      headers['Cohere-Version'] = '2024-12-19';
      final url = Uri.parse('${provider.baseUrl}/generate');
      final body = jsonEncode({
        'model': provider.model,
        'prompt': '$task\n\n$prompt',
        'max_tokens': 512,
        'temperature': 0.7,
      });
      final response =
          await http.post(url, headers: headers, body: body).timeout(
                const Duration(seconds: 30),
              );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'];
      }
      if (response.statusCode == 429) {
        throw Exception('Rate limited');
      }
    }

    // Generic OpenAI-compatible fallback
    if (provider.apiKey != null && provider.apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${provider.apiKey}';
      final url = Uri.parse('${provider.baseUrl}/chat/completions');
      final body = jsonEncode({
        'model': provider.model,
        'messages': [
          {'role': 'system', 'content': task},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
      });
      final response =
          await http.post(url, headers: headers, body: body).timeout(
                const Duration(seconds: 30),
              );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'];
      }
    }

    return null;
  }

  // ========== Template Fallback ==========

  String _generateFallback(String prompt, String task) {
    final lowerTask = task.toLowerCase();

    if (lowerTask.contains('caption') || lowerTask.contains('post')) {
      return _generateCaption(prompt);
    }
    if (lowerTask.contains('hashtag')) {
      return _generateHashtags(prompt);
    }
    if (lowerTask.contains('idea') || lowerTask.contains('content')) {
      return _generateIdeas(prompt);
    }
    if (lowerTask.contains('bio') || lowerTask.contains('profile')) {
      return _generateBio(prompt);
    }
    return 'Here\'s a suggestion for "$prompt": Consider focusing on your audience\'s interests and posting consistently for best engagement. Try using relevant hashtags and engaging visuals to boost your reach.';
  }

  String _generateCaption(String prompt) {
    final captions = [
      '✨ $prompt — because every moment tells a story. #ContentCreator #DigitalMarketing',
      '🚀 Level up your content game! $prompt #GrowthMindset #CreatorLife',
      '💡 Pro tip: $prompt — what are your thoughts? Drop a comment below! #Engagement',
      '🎯 $prompt — consistency is key to building your brand. #CreatorEconomy',
      '🌟 $prompt — the best time to start was yesterday. The second best time is now. #Motivation',
    ];
    return captions[DateTime.now().millisecond % captions.length];
  }

  String _generateHashtags(String prompt) {
    final words = prompt.split(' ').take(5).join(' ');
    return '#${words.replaceAll(' ', '')} #ContentCreator #DigitalMarketing #SocialMedia #GrowthHacking #CreatorEconomy #OnlineMarketing #BrandBuilding #ContentStrategy #MarketingTips';
  }

  String _generateIdeas(String prompt) {
    return 'Content ideas for "$prompt":\n\n'
        '1. Behind-the-scenes look at your process\n'
        '2. Quick tips carousel (swipeable posts)\n'
        '3. User-generated content showcase\n'
        '4. Day-in-the-life Reel/Stories\n'
        '5. Myth-busting post about common misconceptions';
  }

  String _generateBio(String prompt) {
    return '👋 $prompt\n'
        '🎯 Helping you grow your digital presence\n'
        '📱 Daily tips on content & marketing\n'
        '🔗 Link below for free resources\n'
        '#Creator #Marketing #Growth';
  }
}
