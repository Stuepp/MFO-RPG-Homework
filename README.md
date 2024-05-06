Trabalho 1

Métodos Formais 24 de abril de 2024

Contents

[1 Informações importantes](#_page0_x56.69_y466.54) 1

[2 Uma batalha vencível](#_page0_x56.69_y593.00) 1

1. [Ataques ](#_page1_x56.69_y56.69). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1. [Paralisia ](#_page1_x56.69_y132.73). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1. [Provocação ( taunt ) ](#_page1_x56.69_y250.27). . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1. Imunidade . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1. Criaturas . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1. Monstros . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1. Personagens . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
6. Iniciativa . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

[3 Atividades do trabalho](#_page2_x56.69_y366.35)

1. Especificação com as regras do jogo . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1. Invariantes . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1. Especificação com estratégia . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1. Especificação com dois monstros . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

1  Informações<a name="_page0_x56.69_y466.54"></a> importantes
- Data de entrega: 22 de maio (quarta-feira)
- Trabalho individual ou em dupla
- Especificações a serem entregues em TLA+ ou Quint.
- Formato de apresentação: Explicação breve do código (somente para a professora) + implementação de uma pequena modificação por membro.
- Nota: 50% código entregue + 50% apresentação.
2  Uma<a name="_page0_x56.69_y593.00"></a> batalha vencível

De forma semelhante aos exemplos de jogo da velha e pokemons, você deve especificar um jogo onde as partes fazem jogadas aleatórias, mostrando que assim ambas as partes podem vencer; e então especificar uma versão desse jogo onde os personagens usam uma estratégia que garante que eles não percam.

As regras dessa batalha são inspiradas em jogo de RPG, porém um tanto exageradas para que possamos explorar algumas correspondências interessantes com problemas e soluções reais.

1. Ataques

<a name="_page1_x56.69_y56.69"></a>Ataques são a forma de dar dano em criaturas. O dano é determinado por um inteiro, e ao receber um ataque, uma criatura perde uma quantidade de pontos de vida (HP - Health Points ) igual ao dano do ataque. Uma criatura morre quando seus pontos de vida chegam a zero.

2. Paralisia

<a name="_page1_x56.69_y132.73"></a>Criaturas podem ser paralisadas. Criaturas paralisadas não podem fazer nada em seu turno.

- A paralisia infringida por monstros é permanente, e só pode ser removida se um personagem (não paralisado) usar seu turno para isso, ajudando um jogador paralisado e assim removendo sua paral- isia.
- A paralisia infringida por personagens dura apenas um turno. Após perder um turno por paralisia, a criatura deixa de estar paralisada.
3. Provocação<a name="_page1_x56.69_y250.27"></a> (taunt )

Personagens da classe bárbaro tem habilidade de provocar um monstro para que ele passe a somente atacar o bárbaro, ignorando os outros personagens. Uma criatura provocada ataca somente quem a provocou. A provocação dura um turno, de forma que a criatura provocada deixa de estar provocada ao terminar seu turno.

4. Imunidade

<a name="_page1_x56.69_y338.60"></a>Personagens da classe clérigo tem habilidade de melhorar a defesa dos seus aliados, deixando-os imunes. Ao usar essa habilidade, todos os aliados, incluindo o clérigo em si, recebem imunidade, que dura até o início do próximo turno do clérigo. Criaturas imunes não podem receber dano. Todo dano infringido a elas é reduzido a zero.

5. Criaturas

<a name="_page1_x56.69_y429.05"></a>Essa batalha tem várias criaturas lutando entre si, entre elas monstros e personagens

- Monstros não atacam outros monstros
- Personagens não atacam outros personagens
- Podemos assumir que há somente um personagem de cada classe
1. Monstros

<a name="_page1_x56.69_y521.62"></a>Todos os monstros são iguais. Monstros tem 100 pontos de vida iniciais, e podem fazer as seguintes ações em seus turnos (uma ação por turno)

1. Atacar um personagem Os ataques de monstro sempre dão 20 de dano, exceto se esse for o primeiro turno de toda a batalha (ninguém jogou ainda), onde o ataque é mais fraco (ele ainda está carregando todo o seu poder). No primeiro turno, um monstro dá apenas 10 de dano.
1. Paralizar um personagem Um monstro pode paralizar um personagem. Essa paralisia é permanente, e só é removida quando outro personagem usa sua ação para remover a paralisia de um jogador específico.
2. Personagens

<a name="_page1_x56.69_y665.87"></a>Os ataques de personagem causam 10 de dano, independente da classe.

1\. Mago Um mago tem 20 pontos de vida iniciais e pode executar uma das seguintes ações em seu turno:

1. Atacar um monstro
1. Remover paralisia de um personagem
1. Paralizar um monstro
2. Clérigo Um clérigo tem 20 pontos de vida iniciais e pode executar uma das seguintes ações em seu turno:
   1. Atacar um monstro
   1. Remover paralisia de um personagem
   1. Imunizar todos os personagens
2. Bárbaro Um bárbaro tem 150 pontos de vida iniciais e pode executar uma das seguintes ações em seu turno:
   1. Atacar um monstro
   1. Remover paralisia de um personagem
   1. Provocar um monstro
6. Iniciativa

<a name="_page2_x56.69_y245.50"></a>No início da batalha, cada criatura roda um d20 (dado com 20 faces, de 1 até 20) para determinar sua iniciativa. Aqueles com maior iniciativa jogam primeiro, e os com menor iniciativa jogam por último. Se duas ou mais criaturas tiverem a mesma iniciativa, a ordem que elas jogam entre si não importa. Nesse caso, fica a critério de vocês qual o comportamento exato. Se uma criatura A tem iniciativa maior que a criatura B, A deve jogar antes de B. Após todas as criaturas jogarem uma vez, o ciclo reinicia seguindo as mesmas regras e a mesma iniciativa.

3  Atividades<a name="_page2_x56.69_y366.35"></a> do trabalho
1. Especificação<a name="_page2_x56.69_y392.96"></a> com as regras do jogo

Primeiramente, escreva uma especificação descrevendo o que pode acontecer nesse jogo. Considere que exista um único monstro, e um personagem de cada classe. Nessa versão, deve ser possível tanto que o monstro quanto que algum dos jogadores morra.

- Inclua uma (ou mains) variável(is) que registre informações relevantes sobre o que aconteceu no último turno, assim como fizemos para o exemplo do pokemon.
2. Invariantes

<a name="_page2_x56.69_y499.08"></a>Escreva duas invariantes:

1. O monstro não morre
1. Nenhum personagem morre

Nenhuma delas deve ser verdadeira nessa versão.

Você pode usar simuladores ao invés de model checkers para testar as invariantes em todas as etapas deste trabalho. Idealmente, devíamos usar model checkers, mas o modelo deste trabalho tem estados demais e execuções muito longas para uso de model checkers. Usaremos model checkers nos exemplos reais de sistemas distribuídos que veremos na disciplina.

3. Especificação<a name="_page2_x56.69_y643.72"></a> com estratégia

Agora, modifique a especificação (mas salve o arquivo! Você precisa entregar as duas) para que os per- sonagens utilizem uma estratégia, ao escolher suas ações, de forma que a invariante “nenhum personagem morre” seja verdadeira.

4. Especificação<a name="_page3_x56.69_y56.69"></a> com dois monstros

Por último, modifique a especificação anterior (com estratégia) para que a batalha seja contra dois mon- stros. Você pode escolher entregar um arquivo a mais com essa versão, ou simplesmente entregar com essa parte comentada, já que pode ser uma modificação de apenas uma linha.

Essa batalha é impossível, mesmo com as estratégias empregadas. Assim, a invariante “nenhum per- sonagem morre” deve ser violada. Se os personagens estiverem sobrevivendo na sua versão, pode ser que alguma regra não esteja definida corretamente.
4
