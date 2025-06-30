import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';
import 'package:desktop_search_a_holic/chatbot_service.dart';
import 'package:desktop_search_a_holic/chatbot_widgets.dart';

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;
  final ChatResponseType? responseType;
  final Map<String, dynamic>? data;
  final List<Map<String, dynamic>>? suggestions;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
    this.responseType,
    this.data,
    this.suggestions,
  });
}

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ChatBotService _chatBotService = ChatBotService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Get intelligent welcome message with business context
    try {
      ChatResponse dailySummary = await _chatBotService.getDailySummary();
      _addBotMessage(
        "🤖 Hello! I'm your enhanced AI business assistant.\n\n${dailySummary.text}\n\nWhat would you like to explore?",
        responseType: dailySummary.type,
        data: dailySummary.data,
        suggestions: dailySummary.suggestions,
      );
    } catch (e) {
      _addBotMessage(
        "🤖 Hello! I'm your AI business assistant. I can help you with:\n\n• 📊 Sales analytics and reports\n• 📦 Inventory management\n• ⚠️ Stock alerts and monitoring\n• 👥 Customer insights\n• 🎯 Business intelligence\n\nJust ask me anything in natural language!",
        suggestions: [
          {'text': 'Show today\'s summary', 'action': 'daily_summary'},
          {'text': 'Check stock alerts', 'action': 'stock_alerts'},
          {'text': 'What can you do?', 'action': 'capabilities'},
        ],
      );
    }
  }

  void _addBotMessage(
    String message, {
    ChatResponseType? responseType,
    Map<String, dynamic>? data,
    List<Map<String, dynamic>>? suggestions,
  }) {
    if (!mounted) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUserMessage: false,
          timestamp: DateTime.now(),
          responseType: responseType,
          data: data,
          suggestions: suggestions,
        ),
      );
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      setState(() {
        _messages.add(
          ChatMessage(
            text: userMessage,
            isUserMessage: true,
            timestamp: DateTime.now(),
          ),
        );
        _controller.clear();
        _isTyping = true;
      });
      _scrollToBottom();

      try {
        // Process message with advanced AI service
        ChatResponse response = await _chatBotService.processMessage(userMessage);
        
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
          
          _addBotMessage(
            response.text,
            responseType: response.type,
            data: response.data,
            suggestions: response.suggestions,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
          
          _addBotMessage(
            "I apologize, but I encountered an error processing your request. Please try again or rephrase your question.",
            suggestions: [
              {'text': 'Try again', 'action': 'retry'},
              {'text': 'Get help', 'action': 'help'},
              {'text': 'Contact support', 'action': 'support'},
            ],
          );
        }
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleActionPress(String action) async {
    setState(() {
      _isTyping = true;
    });

    try {
      ChatResponse response;
      
      switch (action) {
        case 'daily_summary':
          response = await _chatBotService.getDailySummary();
          break;
        case 'stock_alerts':
          response = await _chatBotService.processMessage('show me stock alerts');
          break;
        case 'today_sales':
          response = await _chatBotService.processMessage('show today\'s sales');
          break;
        case 'inventory_status':
          response = await _chatBotService.processMessage('inventory status');
          break;
        case 'business_overview':
          response = await _chatBotService.processMessage('business overview');
          break;
        case 'capabilities':
          response = _chatBotService.processMessage('what can you do?') as ChatResponse;
          break;
        default:
          response = await _chatBotService.processMessage(action.replaceAll('_', ' '));
      }
      
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        
        _addBotMessage(
          response.text,
          responseType: response.type,
          data: response.data,
          suggestions: response.suggestions,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        
        _addBotMessage(
          "I couldn't process that action right now. Please try again.",
          suggestions: [
            {'text': 'Try again', 'action': 'retry'},
            {'text': 'Get help', 'action': 'help'},
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'AI Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.scaffoldBackgroundColor,
              ),
              child: Column(
                children: <Widget>[
                  // Chat header with info
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: themeProvider.cardBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: themeProvider.gradientColors[0],
                          radius: 24,
                          child: const Icon(
                            Icons.smart_toy_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HealSearch Assistant',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ask me anything about the system',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      themeProvider.textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: themeProvider.iconColor,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor:
                                    themeProvider.cardBackgroundColor,
                                title: Text(
                                  'About AI Assistant',
                                  style:
                                      TextStyle(color: themeProvider.textColor),
                                ),
                                content: Text(
                                  'This AI assistant can help you navigate the system features and answer common questions. Try asking about products, orders, reports, or any other feature.',
                                  style:
                                      TextStyle(color: themeProvider.textColor),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'Got it',
                                      style: TextStyle(
                                          color:
                                              themeProvider.gradientColors[0]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Chat messages
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            // Show enhanced typing indicator
                            return _buildTypingIndicator(themeProvider);
                          }

                          return _buildEnhancedMessageBubble(
                            _messages[index],
                            themeProvider,
                          );
                        },
                      ),
                    ),
                  ),

                  // Suggestion chips
                  _buildSuggestionChips(themeProvider),

                  // Input field at the bottom
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: themeProvider.cardBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(color: themeProvider.textColor),
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(
                                color: themeProvider.textColor.withOpacity(0.6),
                              ),
                              filled: true,
                              fillColor: themeProvider.isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.message_outlined,
                                color: themeProvider.iconColor,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: themeProvider.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded),
                            color: Colors.white,
                            onPressed: _sendMessage,
                            tooltip: 'Send message',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMessageBubble(ChatMessage message, ThemeProvider themeProvider) {
    final isUserMessage = message.isUserMessage;
    final bubbleColor = isUserMessage
        ? themeProvider.gradientColors[0]
        : (themeProvider.isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade200);
    final textColor = isUserMessage ? Colors.white : themeProvider.textColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            CircleAvatar(
              backgroundColor: themeProvider.gradientColors[0].withOpacity(0.2),
              radius: 18,
              child: Icon(
                Icons.smart_toy_outlined,
                color: themeProvider.gradientColors[0],
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUserMessage 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Add data visualization for bot messages
                if (!isUserMessage && message.data != null) ...[
                  const SizedBox(height: 8),
                  DataVisualizationWidget(
                    data: message.data!,
                    title: _getDataTitle(message.responseType),
                  ),
                ],
                
                // Add action buttons for bot messages
                if (!isUserMessage && message.suggestions != null) ...[
                  const SizedBox(height: 8),
                  ActionButtonsWidget(
                    suggestions: message.suggestions,
                    onActionPressed: _handleActionPress,
                  ),
                ],
              ],
            ),
          ),
          if (isUserMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: themeProvider.cardBackgroundColor,
              radius: 18,
              child: Icon(
                Icons.person,
                color: themeProvider.textColor,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getDataTitle(ChatResponseType? responseType) {
    switch (responseType) {
      case ChatResponseType.data:
        return 'Business Data';
      case ChatResponseType.chart:
        return 'Analytics Chart';
      default:
        return 'Information';
    }
  }

  Widget _buildTypingIndicator(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: themeProvider.gradientColors[0].withOpacity(0.2),
            radius: 18,
            child: Icon(
              Icons.smart_toy_outlined,
              color: themeProvider.gradientColors[0],
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "AI is thinking",
                  style: TextStyle(
                    color: themeProvider.textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                TypingIndicatorWidget(themeProvider: themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(ThemeProvider themeProvider) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _chatBotService.getSmartSuggestions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final suggestion = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: themeProvider.gradientColors[0].withOpacity(0.3),
                    ),
                  ),
                  avatar: Icon(
                    _getActionIcon(suggestion['action'] ?? ''),
                    size: 16,
                    color: themeProvider.gradientColors[0],
                  ),
                  label: Text(
                    suggestion['text'] ?? '',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => _handleActionPress(suggestion['action'] ?? ''),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'daily_summary':
      case 'business_summary':
        return Icons.today_outlined;
      case 'stock_alerts':
        return Icons.warning_outlined;
      case 'today_sales':
        return Icons.trending_up_outlined;
      case 'inventory_status':
        return Icons.inventory_outlined;
      case 'capabilities':
        return Icons.help_outline;
      default:
        return Icons.arrow_forward_outlined;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
