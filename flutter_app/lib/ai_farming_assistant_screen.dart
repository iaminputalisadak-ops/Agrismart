import 'package:flutter/material.dart';

import 'farmer_profile_storage.dart';
import 'farming_assistant_qa_bank.dart';
import 'l10n/app_localizations.dart';

class _ChatTurn {
  const _ChatTurn.user(this.message) : isAssistant = false;
  const _ChatTurn.assistant(this.message) : isAssistant = true;

  final bool isAssistant;
  final String message;
}

String _answerForFreeText(String query, String categoryFilter) {
  final q = query.toLowerCase().trim();
  if (q.isEmpty) {
    return '';
  }
  FarmingAssistantQa? best;
  var bestScore = 0;
  final qWords = q
      .split(RegExp(r'\s+'))
      .map((w) => w.replaceAll(RegExp(r'[^\w]'), ''))
      .where((w) => w.length > 2)
      .toList();
  if (qWords.isEmpty) {
    qWords.addAll(q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty));
  }
  for (final qa in kFarmingAssistantQaBank) {
    final text = '${qa.question} ${qa.answer}'.toLowerCase();
    var score = 0;
    final ql = qa.question.toLowerCase();
    if (ql.contains(q)) score += 10;
    for (final w in qWords) {
      if (w.length > 2 && text.contains(w)) score += 2;
    }
    if (categoryFilter != 'All' && qa.category == categoryFilter) {
      score += 1;
    }
    if (score > bestScore) {
      bestScore = score;
      best = qa;
    }
  }
  if (best != null && bestScore >= 2) {
    return best.answer;
  }
  return 'Thanks for your question. For the most reliable answer here, pick a '
      'similar question from the list below or try different keywords '
      '(crop name, pest, or fertilizer). Always confirm product choices and '
      'doses with your local agricultural extension officer.';
}

/// Farming Q&A: preset chips plus a text field so typed questions show in the thread.
class AiFarmingAssistantScreen extends StatefulWidget {
  const AiFarmingAssistantScreen({
    super.key,
    this.productContext,
    this.productShopCategory,
  });

  /// When opened from a product PDP, pre-filters Q&A and shows context in the intro.
  final String? productContext;

  /// One of: Seeds, Fertilizers, Pesticides — maps to assistant topic chips.
  final String? productShopCategory;

  @override
  State<AiFarmingAssistantScreen> createState() => _AiFarmingAssistantScreenState();
}

class _AiFarmingAssistantScreenState extends State<AiFarmingAssistantScreen> {
  final ScrollController _chatScroll = ScrollController();
  final TextEditingController _questionInput = TextEditingController();
  final FocusNode _questionFocus = FocusNode();
  final List<_ChatTurn> _turns = [];

  late String _categoryFilter;

  @override
  void initState() {
    super.initState();
    _categoryFilter = kFarmingAssistantCategories.first;
    final shop = widget.productShopCategory;
    if (shop != null) {
      final mapped = switch (shop) {
        'Seeds' => 'Seeds & crops',
        'Fertilizers' => 'Fertilizer & nutrition',
        'Pesticides' => 'Pests & disease',
        'Tools' => 'Soil & land',
        _ => null,
      };
      if (mapped != null && kFarmingAssistantCategories.contains(mapped)) {
        _categoryFilter = mapped;
      }
    }
    FarmerProfileController.instance.refresh();
  }

  @override
  void dispose() {
    _chatScroll.dispose();
    _questionInput.dispose();
    _questionFocus.dispose();
    super.dispose();
  }

  List<FarmingAssistantQa> get _filteredQuestions {
    if (_categoryFilter == 'All') {
      return List<FarmingAssistantQa>.from(kFarmingAssistantQaBank);
    }
    return kFarmingAssistantQaBank
        .where((q) => q.category == _categoryFilter)
        .toList();
  }

  void _afterChatAppend() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScroll.hasClients) return;
      _chatScroll.animateTo(
        _chatScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _onPickQuestion(FarmingAssistantQa qa) {
    FocusScope.of(context).unfocus();
    setState(() {
      _turns.add(_ChatTurn.user(qa.question));
      _turns.add(_ChatTurn.assistant(qa.answer));
    });
    _afterChatAppend();
  }

  void _sendTyped() {
    final text = _questionInput.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    _questionInput.clear();
    final reply = _answerForFreeText(text, _categoryFilter);
    setState(() {
      _turns.add(_ChatTurn.user(text));
      _turns.add(_ChatTurn.assistant(reply));
    });
    _afterChatAppend();
  }

  void _clearChat() {
    FocusScope.of(context).unfocus();
    setState(_turns.clear);
  }

  String _buildIntroCardText(FarmerProfile p) {
    final name = p.displayName.isEmpty ? 'there' : p.displayName;
    final hi = 'Hi, $name! I\'m your AgriSmart Assistant.\n\n'
        'Ask me about seeds, fertilizers, pests, irrigation, or weather. '
        'Type your question below and tap Send, or tap a preset question.\n\n'
        'Try:\n'
        '• Which fertilizer is best for wheat?\n'
        '• How to control leaf disease in cotton?\n'
        '• Best pesticide for rice crop?';
    if (widget.productContext != null) {
      return '$hi\n\n'
          '—\n'
          'Context from product page:\n${widget.productContext}';
    }
    return hi;
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.green,
      brightness: Brightness.light,
    );
    final cs = light.colorScheme;

    return Theme(
      data: light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(AppLocalizations.of(context).assistantTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearChat,
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: FarmerProfileController.instance,
          builder: (context, _) {
            final profile = FarmerProfileController.instance.profile;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _chatScroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    itemCount: 1 + _turns.length,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: cs.primaryContainer.withValues(alpha: 0.65),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _buildIntroCardText(profile),
                              style: const TextStyle(height: 1.35),
                            ),
                          ),
                        );
                      }
                  final turn = _turns[i - 1];
                  if (!turn.isAssistant) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Text(
                              turn.message,
                              style: TextStyle(color: cs.onPrimary, height: 1.3),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Text(
                            turn.message,
                            style: TextStyle(color: cs.onPrimaryContainer, height: 1.35),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Material(
              elevation: 6,
              color: cs.surface,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _questionInput,
                              focusNode: _questionFocus,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                hintText: 'Type your farming question…',
                                filled: true,
                                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: cs.outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: cs.outlineVariant),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: cs.primary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton.filled(
                            tooltip: 'Send',
                            onPressed: _sendTyped,
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: kFarmingAssistantCategories.map((c) {
                                  final selected = c == _categoryFilter;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: FilterChip(
                                      label: Text(
                                        c == 'All' ? 'All topics' : c,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      selected: selected,
                                      onSelected: (_) => setState(() => _categoryFilter = c),
                                      showCheckmark: false,
                                      visualDensity: VisualDensity.compact,
                                      selectedColor: cs.primary,
                                      labelStyle: TextStyle(
                                        color: selected ? cs.onPrimary : cs.onSurface,
                                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: 'Voice input (coming soon)',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Voice questions will be added in a future update.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.mic_none),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 152,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          itemCount: _filteredQuestions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final qa = _filteredQuestions[index];
                            return Material(
                              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => _onPickQuestion(qa),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.touch_app_outlined, size: 20, color: cs.primary),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          qa.question,
                                          style: TextStyle(
                                            color: cs.onSurface,
                                            height: 1.25,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.chevron_right, color: cs.outline),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
            );
          },
        ),
      ),
    );
  }
}
