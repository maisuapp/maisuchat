part of 'app_shell.dart';

class _InboxView extends StatefulWidget {
  const _InboxView({required this.onAction});

  final ValueChanged<String> onAction;

  @override
  State<_InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<_InboxView> {
  int _selectedConversation = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeading(
          title: 'Inbox',
          subtitle: 'Acompanhe e assuma conversas antes que elas esfriem.',
          trailing: FilledButton.icon(
            onPressed: () => widget.onAction('Filtros avançados em breve.'),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('Filtrar'),
          ),
        ),
        const SizedBox(height: 22),
        AppCard(
          padding: EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 800;
              final list = _ConversationList(
                selectedIndex: _selectedConversation,
                onSelected: (index) =>
                    setState(() => _selectedConversation = index),
              );
              final detail = _ConversationDetail(
                conversation: demoConversations[_selectedConversation],
                onAction: widget.onAction,
              );
              if (compact) {
                return Column(
                  children: [
                    list,
                    Divider(height: 1, color: scheme.outlineVariant),
                    SizedBox(height: 540, child: detail),
                  ],
                );
              }
              return SizedBox(
                height: 560,
                child: Row(
                  children: [
                    SizedBox(width: 340, child: list),
                    VerticalDivider(width: 1, color: scheme.outlineVariant),
                    Expanded(child: detail),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar conversa',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 450,
          child: ListView.separated(
            itemCount: demoConversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = demoConversations[index];
              return ListTile(
                selected: selectedIndex == index,
                selectedTileColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                leading: Avatar(label: conversation.initials, size: 40),
                title: Text(
                  conversation.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  conversation.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  conversation.time,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                onTap: () => onSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ConversationDetail extends StatelessWidget {
  const _ConversationDetail({
    required this.conversation,
    required this.onAction,
  });

  final Conversation conversation;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(label: conversation.initials, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${conversation.channel} · online agora',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Mais opções',
                onPressed: () => onAction('Mais opções em breve.'),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 17, color: scheme.onTertiaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Janela de atendimento aberta por mais 22h 14min',
                    style: TextStyle(
                      color: scheme.onTertiaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Hoje, 10:42',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _MessageBubble(
                    text: 'Oi! Vi o anúncio e queria saber mais.',
                    fromUser: true,
                  ),
                  const _MessageBubble(
                    text: 'Oi, Carolina! Posso te enviar o catálogo completo. 😊',
                    fromUser: false,
                  ),
                  _MessageBubble(
                    text: conversation.preview,
                    fromUser: true,
                  ),
                  const Spacer(),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Escreva uma resposta…',
                      suffixIcon: IconButton(
                        tooltip: 'Enviar mensagem',
                        onPressed: () => onAction('Mensagem enviada no modo demonstração.'),
                        icon: const Icon(Icons.send_rounded),
                      ),
                      filled: true,
                      fillColor: scheme.surface,
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
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: fromUser ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(fromUser ? 14 : 4),
            bottomRight: Radius.circular(fromUser ? 4 : 14),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: fromUser ? scheme.onPrimary : scheme.onSurface),
        ),
      ),
    );
  }
}
