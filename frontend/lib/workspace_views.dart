part of 'app_shell.dart';

class _AutomationsView extends StatelessWidget {
  const _AutomationsView({required this.onAction});

  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeading(
          title: 'Automações',
          subtitle: 'Crie jornadas simples para responder no momento certo.',
          trailing: FilledButton.icon(
            onPressed: () => onAction('Editor de automações em preparação.'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Nova automação'),
          ),
        ),
        const SizedBox(height: 22),
        AppCard(
          child: Column(
            children: demoAutomations
                .map(
                  (automation) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Color(automation.colorValue).withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.account_tree_outlined,
                          color: Color(automation.colorValue)),
                    ),
                    title: Text(
                      automation.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${automation.trigger} · ${automation.updatedAt} · ${automation.runs}',
                    ),
                    trailing: StatusPill(
                      label: automation.status,
                      tone: automation.status == 'Ativa'
                          ? StatusTone.positive
                          : StatusTone.warning,
                    ),
                    onTap: () => onAction('Detalhes de ${automation.name}.'),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _AudienceView extends StatefulWidget {
  const _AudienceView();

  @override
  State<_AudienceView> createState() => _AudienceViewState();
}

class _AudienceViewState extends State<_AudienceView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final contacts = demoContacts
        .where(
          (contact) => contact.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Audiência',
          subtitle: 'Encontre contatos, entenda o contexto e personalize a próxima conversa.',
        ),
        const SizedBox(height: 22),
        AppCard(
          child: Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  labelText: 'Buscar contatos',
                  hintText: 'Nome do contato',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              if (contacts.isEmpty)
                const EmptyState(
                  icon: Icons.person_search_outlined,
                  title: 'Nenhum contato encontrado',
                  message: 'Tente buscar por outro nome ou limpe o filtro.',
                )
              else
                ...contacts.map(
                  (contact) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Avatar(label: contact.initials, size: 40),
                    title: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('${contact.channel} · ${contact.lastSeen}'),
                    trailing: StatusPill(
                      label: contact.tag,
                      tone: StatusTone.info,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView({required this.demoMode});

  final bool demoMode;

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Configurações',
          subtitle: 'Ajuste canais, preferências e permissões do workspace.',
        ),
        const SizedBox(height: 22),
        if (widget.demoMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.science_outlined, color: scheme.onSecondaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Você está no modo demonstração. Conecte o Firebase para persistir usuários, contatos e automações.',
                      style: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Canais',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              const _ChannelRow(
                icon: Icons.chat_rounded,
                name: 'WhatsApp Business',
                status: 'Pronto para conectar',
              ),
              const _ChannelRow(
                icon: Icons.camera_alt_outlined,
                name: 'Instagram',
                status: 'Pronto para conectar',
              ),
              const _ChannelRow(
                icon: Icons.forum_outlined,
                name: 'Messenger',
                status: 'Pronto para conectar',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Notificações do workspace',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Receba alertas sobre conversas que precisam de atenção.'),
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
        ),
      ],
    );
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({
    required this.icon,
    required this.name,
    required this.status,
  });

  final IconData icon;
  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(status),
      trailing: OutlinedButton(
        onPressed: () {},
        child: const Text('Conectar'),
      ),
    );
  }
}
