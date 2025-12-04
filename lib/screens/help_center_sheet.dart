import 'package:flutter/material.dart';

class HelpCenterSheet extends StatefulWidget {
  final String username;
  final bool isAdmin;
  const HelpCenterSheet({super.key, required this.username, required this.isAdmin});

  @override
  State<HelpCenterSheet> createState() => _HelpCenterSheetState();
}

class _HelpCenterSheetState extends State<HelpCenterSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  final List<_FaqEntry> _knowledgeBase = [
    _FaqEntry(
      title: 'Registrar entrada de material',
      keywords: ['entrada', 'fornecedor', 'peso', 'material', 'compra'],
      answer:
          'Para registrar uma entrada: acesse Entradas > Novo, escolha o fornecedor, selecione o material, informe peso/valor unitario e salve. O estoque sera atualizado automaticamente.',
    ),
    _FaqEntry(
      title: 'Registrar saida (venda)',
      keywords: ['saida', 'venda', 'cliente', 'nota', 'nf'],
      answer:
          'Para registrar uma saida: acesse Saidas > Novo, selecione o cliente, escolha o material a partir do estoque, informe peso/valor e confirme. O movimento reduz o saldo do estoque.',
    ),
    _FaqEntry(
      title: 'Gerar relatorio ou PDF',
      keywords: ['relatorio', 'pdf', 'exportar', 'periodo'],
      answer:
          'Relatorios: abra Relatorios na aba inferior (ou no menu admin), escolha o tipo, defina o periodo e toque em Exportar PDF. O arquivo fica salvo e pode ser aberto direto pelo app.',
    ),
    _FaqEntry(
      title: 'Fluxo de lotes',
      keywords: ['fluxo', 'lote', 'rastreio', 'entrada', 'saida'],
      answer:
          'O Fluxo de Lotes mostra a linha do tempo de entradas/saidas do mesmo lote. Use a aba Fluxo para acompanhar e filtrar por data.',
    ),
    _FaqEntry(
      title: 'Estoque e saldo atual',
      keywords: ['estoque', 'saldo', 'material', 'quantidade'],
      answer:
          'O saldo atual de cada material aparece em Estoque. Sempre que registrar entrada ou saida, o app recalcula peso total e valor medio automaticamente.',
    ),
    _FaqEntry(
      title: 'Conta e perfil',
      keywords: ['perfil', 'senha', 'conta', 'usuario'],
      answer:
          'Para alterar dados de conta, abra o menu lateral > Perfil. Ali voce consegue atualizar nome, foto e redefinir senha.',
    ),
  ];

  final List<String> _quickPrompts = const [
    'Como registrar uma entrada?',
    'Como gerar um relatorio?',
    'Onde vejo o estoque?',
    'Como registrar uma saida?',
    'Fluxo de lotes funciona como?',
  ];

  @override
  void initState() {
    super.initState();
    _seedWelcome();
  }

  void _seedWelcome() {
    final firstName = widget.username.trim().split(' ').firstWhere((e) => e.isNotEmpty, orElse: () => 'por aqui');
    _messages.add(_ChatMessage(
      fromUser: false,
      text:
          'Oi, $firstName! Sou o assistente rapido do Gaudioso. Posso explicar como registrar entradas/saidas, gerar relatorios ou tirar duvidas gerais.',
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend([String? preset]) {
    final raw = (preset ?? _controller.text).trim();
    if (raw.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(fromUser: true, text: raw));
    });
    final answer = _pickAnswer(raw);
    setState(() {
      _messages.add(_ChatMessage(fromUser: false, text: answer));
    });
    _scrollToBottom();
  }

  String _pickAnswer(String question) {
    final normalized = question.toLowerCase();
    int bestScore = 0;
    _FaqEntry? best;

    for (final entry in _knowledgeBase) {
      final score = _score(normalized, entry.keywords);
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    if (best != null && bestScore > 0) {
      return best.answer;
    }

    return 'Ainda nao tenho essa resposta. Tente perguntar sobre entrada, saida, relatorio, estoque ou perfil. Se preferir, detalhe um pouco mais e eu tento ajudar.';
  }

  int _score(String question, List<String> keywords) {
    int score = 0;
    for (final kw in keywords) {
      if (kw.isEmpty) continue;
      if (question.contains(kw)) {
        score += kw.length >= 6 ? 3 : 2;
      }
    }
    return score;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent + 72;
      _scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(widget.isAdmin ? 'Assistente Admin' : 'Assistente', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Fechar',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ajuda rapida',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final align = msg.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                            final bubbleColor = msg.fromUser ? cs.primary : cs.surface;
                            final textColor = msg.fromUser ? Colors.white : cs.onSurface;
                            return Align(
                              alignment: align,
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: msg.fromUser ? 32 : 0,
                                  right: msg.fromUser ? 0 : 32,
                                  bottom: 10,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: bubbleColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(msg.text, style: TextStyle(color: textColor)),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_quickPrompts.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sugestoes:',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _quickPrompts
                                .map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      label: Text(p),
                                      onPressed: () => _handleSend(p),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Digite sua duvida...',
                                isDense: true,
                              ),
                              minLines: 1,
                              maxLines: 3,
                              onSubmitted: (_) => _handleSend(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _handleSend,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                            ),
                            icon: const Icon(Icons.send, size: 18),
                            label: const Text('Enviar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool fromUser;
  final String text;
  _ChatMessage({required this.fromUser, required this.text});
}

class _FaqEntry {
  final String title;
  final List<String> keywords;
  final String answer;
  const _FaqEntry({required this.title, required this.keywords, required this.answer});
}
