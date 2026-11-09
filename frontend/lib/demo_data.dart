class Conversation {
  const Conversation({
    required this.name,
    required this.initials,
    required this.preview,
    required this.time,
    required this.channel,
    required this.status,
    this.unread = false,
  });

  final String name;
  final String initials;
  final String preview;
  final String time;
  final String channel;
  final String status;
  final bool unread;
}

class Automation {
  const Automation({
    required this.name,
    required this.trigger,
    required this.updatedAt,
    required this.runs,
    required this.status,
    required this.colorValue,
  });

  final String name;
  final String trigger;
  final String updatedAt;
  final String runs;
  final String status;
  final int colorValue;
}

class Contact {
  const Contact({
    required this.name,
    required this.initials,
    required this.channel,
    required this.lastSeen,
    required this.tag,
  });

  final String name;
  final String initials;
  final String channel;
  final String lastSeen;
  final String tag;
}

const demoConversations = <Conversation>[
  Conversation(
    name: 'Carolina Mendes',
    initials: 'CM',
    preview: 'Perfeito, quero receber o catálogo.',
    time: 'Agora',
    channel: 'WhatsApp',
    status: 'Aguardando resposta',
    unread: true,
  ),
  Conversation(
    name: 'Rafael Lima',
    initials: 'RL',
    preview: 'Você consegue me ajudar com o pedido?',
    time: '8 min',
    channel: 'Instagram',
    status: 'Bot ativo',
  ),
  Conversation(
    name: 'Bianca Souza',
    initials: 'BS',
    preview: 'Obrigada! Vou conferir e retorno.',
    time: '32 min',
    channel: 'WhatsApp',
    status: 'Resolvida',
  ),
  Conversation(
    name: 'João Victor',
    initials: 'JV',
    preview: 'Qual é o prazo de entrega para São Paulo?',
    time: '1 h',
    channel: 'Messenger',
    status: 'Atendimento humano',
  ),
];

const demoAutomations = <Automation>[
  Automation(
    name: 'Boas-vindas — novos contatos',
    trigger: 'Quando alguém inicia uma conversa',
    updatedAt: 'Atualizada hoje',
    runs: '428 execuções',
    status: 'Ativa',
    colorValue: 0xFF0F766E,
  ),
  Automation(
    name: 'Catálogo de produtos',
    trigger: 'Palavra-chave: catálogo',
    updatedAt: 'Atualizada ontem',
    runs: '186 execuções',
    status: 'Ativa',
    colorValue: 0xFF7C3AED,
  ),
  Automation(
    name: 'Recuperação de interesse',
    trigger: 'Sem resposta por 24 horas',
    updatedAt: 'Revisão pendente',
    runs: '64 execuções',
    status: 'Rascunho',
    colorValue: 0xFFEA580C,
  ),
];

const demoContacts = <Contact>[
  Contact(
    name: 'Carolina Mendes',
    initials: 'CM',
    channel: 'WhatsApp',
    lastSeen: 'Agora',
    tag: 'Lead quente',
  ),
  Contact(
    name: 'Rafael Lima',
    initials: 'RL',
    channel: 'Instagram',
    lastSeen: '8 min atrás',
    tag: 'Novo contato',
  ),
  Contact(
    name: 'Bianca Souza',
    initials: 'BS',
    channel: 'WhatsApp',
    lastSeen: '32 min atrás',
    tag: 'Cliente',
  ),
  Contact(
    name: 'João Victor',
    initials: 'JV',
    channel: 'Messenger',
    lastSeen: '1 h atrás',
    tag: 'Suporte',
  ),
];
