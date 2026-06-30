import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AiProvider {
  final String name;
  final String baseUrl;
  final String? apiKey;
  final String model;
  final bool enabled;

  const AiProvider({
    required this.name,
    required this.baseUrl,
    this.apiKey,
    this.model = '',
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'model': model,
        'enabled': enabled,
      };

  factory AiProvider.fromJson(Map<String, dynamic> json) => AiProvider(
        name: json['name'] ?? '',
        baseUrl: json['baseUrl'] ?? '',
        apiKey: json['apiKey'],
        model: json['model'] ?? '',
        enabled: json['enabled'] ?? true,
      );

  AiProvider copyWith({
    String? name,
    String? baseUrl,
    String? apiKey,
    String? model,
    bool? enabled,
  }) =>
      AiProvider(
        name: name ?? this.name,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        enabled: enabled ?? this.enabled,
      );
}

class AiService {
  static final AiService _instance = AiService._();
  factory AiService() => _instance;
  AiService._();

  List<AiProvider> _providers = [];
  bool _initialized = false;

  // Default free providers (user never sees these)
  static const _defaultProviders = [
    AiProvider(
      name: 'Gemini',
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta/models',
      model: 'gemini-2.0-flash',
      enabled: true,
    ),
    AiProvider(
      name: 'HuggingFace',
      baseUrl: 'https://api-inference.huggingface.co/models',
      model: 'meta-llama/Llama-2-7b-chat-hf',
      enabled: true,
    ),
    AiProvider(
      name: 'Cohere',
      baseUrl: 'https://api.cohere.ai/v1',
      model: 'command',
      enabled: true,
    ),
  ];

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('ai_providers');
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
    _initialized = true;
  }

  Future<void> saveProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _providers.map((p) => p.toJson()).toList();
    await prefs.setString('ai_providers', jsonEncode(json));
  }

  List<AiProvider> get providers => List.unmodifiable(_providers);

  void updateProvider(int index, AiProvider provider) {
    if (index >= 0 && index < _providers.length) {
      _providers[index] = provider;
      saveProviders();
    }
  }

  void addProvider(AiProvider provider) {
    _providers.add(provider);
    saveProviders();
  }

  void removeProvider(int index) {
    if (index >= 0 && index < _providers.length) {
      _providers.removeAt(index);
      saveProviders();
    }
  }

  // Main generate method — user never knows which provider is used
  Future<String> generate({
    required String prompt,
    required String task,
    Map<String, String>? context,
  }) async {
    await initialize();

    for (final provider in _providers.where((p) => p.enabled && p.apiKey != null && p.apiKey!.isNotEmpty)) {
      try {
        final result = await _callProvider(provider, prompt, task, context);
        if (result != null && result.isNotEmpty) {
          return result;
        }
      } catch (e) {
        debugPrint('AI provider ${provider.name} failed: $e');
        continue;
      }
    }

    // Fallback: generate locally (template-based)
    return _generateFallback(prompt, task);
  }

  Future<String?> _callProvider(
    AiProvider provider,
    String prompt,
    String task,
    Map<String, String>? context,
  ) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (provider.name == 'Gemini' && provider.apiKey != null) {
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
    }

    if (provider.name == 'HuggingFace' && provider.apiKey != null) {
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
    }

    if (provider.name == 'Cohere' && provider.apiKey != null) {
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
    }

    return null;
  }

  String _generateFallback(String prompt, String task) {
    // Template-based fallback when no API keys are configured
    final lowerTask = task.toLowerCase();
    final lowerPrompt = prompt.toLowerCase();

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
