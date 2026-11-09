part of 'app_shell.dart';

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({
    required this.demoMode,
    required this.onNavigate,
    required this.onAction,
  });

  final bool demoMode;
  final ValueChanged<int> onNavigate;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeading(
          title: 'Bom dia, Marina 👋',
          subtitle: demoMode
              ? 'Veja como está a operação da Acme Commerce. Estes dados são de demonstração.'
              : 'Veja como está a operação da Acme Commerce nesta manhã.',
          trailing: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => onNavigate(1),
                icon: const Icon(Icons.forum_outlined, size: 18),
                label: const Text('Abrir inbox'),
              ),
              FilledButton.icon(
                onPressed: () => onAction('Editor de automações em preparação.'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Criar automação'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 1100
                ? (constraints.maxWidth - 36) / 4
                : constraints.maxWidth >= 720
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: const MetricCard(
                    label: 'Contatos ativos',
                    value: '1.248',
                    change: '+12,8% este mês',
                    icon: Icons.people_outline_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const MetricCard(
                    label: 'Taxa de resposta',
                    value: '89,4%',
                    change: '+4,2% vs. mês anterior',
                    icon: Icons.bolt_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const MetricCard(
                    label: 'Automações ativas',
                    value: '7',
                    change: '2 aguardando revisão',
                    icon: Icons.account_tree_outlined,
                    changeIsPositive: false,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const MetricCard(
                    label: 'Novos leads hoje',
                    value: '84',
                    change: '+18,0% desde ontem',
                    icon: Icons.trending_up_rounded,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1040;
            final activity = _ActivityCard(onNavigate: onNavigate);
            final nextSteps = _NextStepsCard(onAction: onAction);
            if (!wide) {
              return Column(
                children: [activity, const SizedBox(height: 20), nextSteps],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: activity),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: nextSteps),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        _AutomationSummary(onNavigate: onNavigate),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Conversas recentes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => onNavigate(1),
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...demoConversations.take(3).map(
                (conversation) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Avatar(label: conversation.initials, size: 40),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        conversation.time,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      conversation.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: conversation.unread
                      ? const StatusPill(
                          label: 'Novo',
                          tone: StatusTone.info,
                        )
                      : null,
                  onTap: () => onNavigate(1),
                ),
              ),
        ],
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard({required this.onAction});

  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximos passos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Deixe seu workspace pronto para escalar.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          _ChecklistItem(
            title: 'Conecte um canal',
            subtitle: 'WhatsApp, Instagram ou Messenger',
            done: true,
          ),
          _ChecklistItem(
            title: 'Crie sua primeira automação',
            subtitle: 'Comece com uma jornada de boas-vindas',
            done: false,
            onTap: () => onAction('Abrindo modelos de automação.'),
          ),
          _ChecklistItem(
            title: 'Convide seu time',
            subtitle: 'Colabore na caixa de entrada',
            done: false,
            onTap: () => onAction('Convites estarão disponíveis em breve.'),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.title,
    required this.subtitle,
    required this.done,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: done ? const Color(0xFF15803D) : scheme.outline,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          decoration: done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: done ? null : onTap,
    );
  }
}

class _AutomationSummary extends StatelessWidget {
  const _AutomationSummary({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Automações em destaque',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => onNavigate(2),
                child: const Text('Gerenciar automações'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...demoAutomations.map(
                (automation) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Color(automation.colorValue).withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.bolt_rounded,
                      color: Color(automation.colorValue),
                    ),
                  ),
                  title: Text(
                    automation.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(automation.trigger),
                  trailing: StatusPill(
                    label: automation.status,
                    tone: automation.status == 'Ativa'
                        ? StatusTone.positive
                        : StatusTone.warning,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
