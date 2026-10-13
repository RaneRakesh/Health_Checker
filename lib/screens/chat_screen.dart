import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  final String sender;
  final String text;
  final bool isEmergency;
  final List<String> sources;

  _ChatMessage({
    required this.sender,
    required this.text,
    this.isEmergency = false,
    this.sources = const [],
  });
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      sender: 'Assistant',
      text: 'Hello! I am your AI Health Assistant. How can I help you today? Please describe your symptoms.',
    ),
  ];
  late final ApiService _api;
  bool _isSending = false;
  String _selectedMode = 'short'; // 'short' (default) or 'detailed'

  @override
  void initState() {
    super.initState();
    _api = ApiService();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? presetText, String? modeOverride]) async {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty || _isSending) return;
    if (presetText == null) _controller.clear();

    final activeMode = modeOverride ?? _selectedMode;

    setState(() {
      _messages.add(_ChatMessage(sender: 'You', text: text));
      _isSending = true;
    });
    _scrollToBottom();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final uid = userProvider.uid ?? 'anonymous_user';

    try {
      final response = await _api.sendChat(uid, text, mode: activeMode);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reply = data['reply'] as String? ?? '(no reply)';
        final emergency = data['emergency'] as bool? ?? false;
        final rawSources = data['sources'] as List<dynamic>? ?? [];
        final sources = rawSources.map((s) => s.toString()).toList();

        setState(() {
          _messages.add(_ChatMessage(
            sender: 'Assistant',
            text: reply,
            isEmergency: emergency,
            sources: sources,
          ));
        });
      } else {
        setState(() {
          _messages.add(_ChatMessage(
            sender: 'Assistant',
            text: 'Error communicating with backend (${response.statusCode}). Is the backend server running on port ${ApiService.port}?',
          ));
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          sender: 'Assistant',
          text: 'Unable to connect to backend server: $e\nMake sure backend/main.py is running on port ${ApiService.port}.',
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Clear conversation',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(_ChatMessage(
                  sender: 'Assistant',
                  text: 'Hello! I am your AI Health Assistant. How can I help you today? Please describe your symptoms.',
                ));
              });
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Length Mode Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.tune, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text(
                      'AI Answer Depth:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      avatar: const Icon(Icons.flash_on, size: 14, color: Colors.orange),
                      label: const Text('⚡ Short / Concise', style: TextStyle(fontSize: 12)),
                      selected: _selectedMode == 'short',
                      selectedColor: Colors.green.shade100,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedMode = 'short');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: const Icon(Icons.menu_book, size: 14, color: Colors.indigo),
                      label: const Text('📖 Detailed Explanation', style: TextStyle(fontSize: 12)),
                      selected: _selectedMode == 'detailed',
                      selectedColor: Colors.indigo.shade100,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedMode = 'detailed');
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg.sender == 'You';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        constraints: const BoxConstraints(maxWidth: 620),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.green.shade600
                              : (msg.isEmergency ? Colors.red.shade50 : Colors.grey.shade100),
                          border: msg.isEmergency
                              ? Border.all(color: Colors.red.shade400, width: 2)
                              : Border.all(color: isUser ? Colors.transparent : Colors.grey.shade300),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    msg.isEmergency ? Icons.warning_amber_rounded : Icons.health_and_safety,
                                    size: 16,
                                    color: msg.isEmergency ? Colors.red : Colors.green.shade800,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    msg.isEmergency ? 'EMERGENCY WARNING' : 'AI Health Assistant',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: msg.isEmergency ? Colors.red.shade800 : Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                            SelectableText(
                              msg.text,
                              style: TextStyle(
                                color: isUser ? Colors.white : (msg.isEmergency ? Colors.red.shade900 : Colors.black87),
                                fontSize: 14.5,
                                height: 1.4,
                              ),
                            ),
                            if (msg.sources.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.science_outlined, size: 14, color: Colors.indigo),
                                        SizedBox(width: 4),
                                        Text(
                                          'Clinical R&D & Literature Citations:',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ...msg.sources.map((s) => Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: SelectableText(
                                        '• $s',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isSending)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: LinearProgressIndicator(),
                ),

              // Symptom Quick Action Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.flash_on, size: 15, color: Colors.orange),
                      label: const Text('Mild headache (Short)'),
                      onPressed: () => _send('I have had a mild headache for 2 days', 'short'),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.menu_book, size: 15, color: Colors.indigo),
                      label: const Text('📖 Explain headache in detail'),
                      onPressed: () => _send('Explain in detail why I have a headache for 2 days and what clinical research shows', 'detailed'),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.thermostat, size: 15, color: Colors.blue),
                      label: const Text('Fever 101°F with cough'),
                      onPressed: () => _send('I have a fever of 101°F with dry cough', 'short'),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.local_hospital, size: 15, color: Colors.red),
                      label: const Text('🚨 Severe chest pain'),
                      onPressed: () => _send('I have severe chest pain and shortness of breath', 'short'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Input Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: _selectedMode == 'short'
                              ? 'Describe symptoms (Short mode active)...'
                              : 'Ask medical question (Detailed explanation active)...',
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: Colors.green),
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _send(),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Disclaimer: Triage assistant for educational reference. Consult a licensed physician for diagnosis.',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
