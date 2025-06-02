import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';
import 'dart:math';

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
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
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _addBotMessage("Hello! I'm your AI assistant. How can I help you today?");
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUserMessage: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _sendMessage() {
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

      // Simulate typing delay before bot response
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          _isTyping = false;
        });
        _generateBotResponse(userMessage);
      });
    }
  }

  void _generateBotResponse(String userMessage) {
    // Simple bot responses based on user input
    final userMessageLower = userMessage.toLowerCase();
    String botResponse;

    if (userMessageLower.contains('hello') ||
        userMessageLower.contains('hi') ||
        userMessageLower.contains('hey')) {
      botResponse = "Hello there! How can I assist you today?";
    } else if (userMessageLower.contains('product') &&
        (userMessageLower.contains('add') ||
            userMessageLower.contains('create'))) {
      botResponse =
          "To add a product, go to the 'Add Product' section from the sidebar. You'll need to fill in product details like name, price, quantity, etc.";
    } else if (userMessageLower.contains('product') &&
        userMessageLower.contains('edit')) {
      botResponse =
          "You can edit a product by navigating to the 'Products' section, finding the product you want to edit, and clicking on the edit icon.";
    } else if (userMessageLower.contains('order') ||
        userMessageLower.contains('purchase')) {
      botResponse =
          "To create a new order, go to the 'New Order' section. You can select products, specify quantities, and add customer information.";
    } else if (userMessageLower.contains('report') ||
        userMessageLower.contains('analytics')) {
      botResponse =
          "You can view comprehensive reports in the 'Reports' section. For graphical data visualization, check out 'BI Charts'.";
    } else if (userMessageLower.contains('password') &&
        userMessageLower.contains('change')) {
      botResponse =
          "To change your password, navigate to the 'Change Password' section or go to your profile and select 'Change Password' from there.";
    } else if (userMessageLower.contains('search') ||
        userMessageLower.contains('find')) {
      botResponse =
          "You can search for products using the search bar in the Products section. Just type what you're looking for and it will filter the results.";
    } else if (userMessageLower.contains('theme') ||
        userMessageLower.contains('dark') ||
        userMessageLower.contains('light')) {
      botResponse =
          "You can change the app theme by toggling the switch in the sidebar. This will switch between dark and light modes.";
    } else if (userMessageLower.contains('thank')) {
      botResponse =
          "You're welcome! Feel free to ask if you need any other assistance.";
    } else {
      // Default responses for unknown queries
      List<String> defaultResponses = [
        "I'm not sure I understand. Could you please rephrase your question?",
        "Interesting question. Let me help you with that, but could you be more specific?",
        "I'm here to help with your inventory management needs. What specific feature are you asking about?",
        "That's a good question! You can find most features in the sidebar menu. Is there something specific you're looking for?",
      ];

      botResponse = defaultResponses[Random().nextInt(defaultResponses.length)];
    }

    _addBotMessage(botResponse);
  }

  void _scrollToBottom() {
    // Add a small delay to ensure the list is updated before scrolling
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
                                'Search-A-Holic Assistant',
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
                            // Show typing indicator as the last item when the bot is "typing"
                            return _buildTypingIndicator(themeProvider);
                          }

                          return _buildMessageBubble(
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

  Widget _buildMessageBubble(ChatMessage message, ThemeProvider themeProvider) {
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
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
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
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(themeProvider),
                const SizedBox(width: 4),
                _buildDot(themeProvider, delay: 300),
                const SizedBox(width: 4),
                _buildDot(themeProvider, delay: 600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(ThemeProvider themeProvider, {int delay = 0}) {
    return AnimatedOpacityWidget(
      delay: delay,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: themeProvider.textColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(ThemeProvider themeProvider) {
    final suggestions = [
      'How to add a product?',
      'Create a new order',
      'View reports',
      'Change password',
    ];

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: themeProvider.gradientColors[0].withOpacity(0.3),
                ),
              ),
              label: Text(
                suggestions[index],
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 12,
                ),
              ),
              onPressed: () {
                _controller.text = suggestions[index];
                _sendMessage();
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class AnimatedOpacityWidget extends StatefulWidget {
  final Widget child;
  final int delay;

  const AnimatedOpacityWidget({
    required this.child,
    this.delay = 0,
    super.key,
  });

  @override
  _AnimatedOpacityWidgetState createState() => _AnimatedOpacityWidgetState();
}

class _AnimatedOpacityWidgetState extends State<AnimatedOpacityWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Delay the animation based on the provided delay
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
