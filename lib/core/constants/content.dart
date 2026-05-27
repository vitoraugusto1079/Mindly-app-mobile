import '../../data/models/game.dart';

// Tradução fiel de src/data/content.js

class LearningStep {
  final int id;
  final String titulo;
  final String conteudo;
  final String dica;
  const LearningStep({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.dica,
  });
}

const learningPath = [
  LearningStep(
    id: 1,
    titulo: 'O que é Neurodiversidade?',
    conteudo:
        'Neurodiversidade reconhece que cérebros funcionam de maneiras diferentes. Isso inclui TDAH, autismo, dislexia e outras variações.',
    dica: 'Não existe um jeito certo de aprender — existe o seu jeito.',
  ),
  LearningStep(
    id: 2,
    titulo: 'Como o cérebro aprende',
    conteudo:
        'O aprendizado acontece com repetição, emoção e prática. Algumas pessoas aprendem melhor visualmente, outras ouvindo ou fazendo.',
    dica: 'Teste diferentes métodos e observe o que funciona melhor para você.',
  ),
  LearningStep(
    id: 3,
    titulo: 'Estratégias de estudo',
    conteudo:
        'Dividir tarefas, usar cores, mapas mentais e pausas ajudam no foco e evitam sobrecarga.',
    dica:
        'Estudar menos tempo com qualidade é melhor do que estudar muito sem foco.',
  ),
  LearningStep(
    id: 4,
    titulo: 'Ambiente ideal',
    conteudo:
        'Um ambiente organizado, silencioso e confortável melhora muito a concentração.',
    dica: 'Pequenas mudanças no ambiente fazem grande diferença.',
  ),
  LearningStep(
    id: 5,
    titulo: 'Autoconhecimento',
    conteudo: 'Entender como você aprende é essencial para evoluir.',
    dica: 'Observe seus padrões — isso é sua maior vantagem.',
  ),
];

final games = [
  const Game(
    id: 'letras',
    title: 'Adivinha com letras',
    description:
        'Adivinhe as palavras com as letras embaralhadas e divirta-se aprendendo coisas novas.',
    prompt: 'Descubra a palavra secreta.',
    hint: 'Fruta vermelha com 7 letras',
    answer: 'morango',
    reward: 15,
  ),
  const Game(
    id: 'matematica',
    title: 'Charada matemática',
    description:
        'Resolva charadas de matemática e teste suas habilidades de raciocínio lógico rápido.',
    prompt: '20 passageiros × 3 viagens = ?',
    hint: 'Multiplique os dois números',
    answer: '60',
    reward: 15,
  ),
  const Game(
    id: 'rimas',
    title: 'Adivinha com rimas',
    description:
        'Adivinhe as palavras através de rimas criativas e melhore seu conhecimento.',
    prompt: 'Tem ponta mas não fere, escreve mas não fala.',
    hint: 'Você usa para escrever',
    answer: 'caneta',
    reward: 15,
  ),
];
