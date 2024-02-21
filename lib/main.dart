import 'package:flutter/material.dart';
import 'package:poker/poker_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => GameCubit(),
        child: const MyHomePage(title: 'Poker App'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> players = [
    'Cédric',
    'Evan',
    'Ludovic',
    'Mickaël',
    'Nicolas',
    'Pierre',
    'Sébastien',
    'Stéphane',
  ];

  var raise = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit, GameState>(
      listener: (context, state) {
        if (state.turn == Turn.end) {
          showDialog<String>(
            context: context,
            builder: (_) {
              return AlertDialog(
                alignment: Alignment.center,
                titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                contentTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                actionsPadding: const EdgeInsets.all(20),
                buttonPadding: const EdgeInsets.only(left: 8),
                contentPadding: const EdgeInsets.only(right: 24, left: 24, top: 16),
                titlePadding: const EdgeInsets.only(right: 24, left: 24, top: 24),
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 3,
                title: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Round over'),
                    ),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                content: Text(
                  'Who won?',
                  textAlign: TextAlign.center,
                ),
                actions: List.generate(
                  state.activePlayers.length,
                  (index) => TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<GameCubit>().roundOverWithOneWinner(state.activePlayers[index]);
                    },
                    child: Text(
                      state.activePlayers[index].name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ),
                // [
                //   TextButton(
                //     onPressed: () {
                //       Navigator.pop(context);
                //       // BlocProvider.of<GameCubit>(context).initGame();
                //     },
                //     child: Text(
                //       'Rejouer',
                //       style: Theme.of(context).textTheme.labelLarge?.copyWith(
                //             color: Theme.of(context).colorScheme.primary,
                //           ),
                //     ),
                //   ),
                // ],
              );
            },
            barrierDismissible: false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: BlocBuilder<GameCubit, GameState>(
          builder: (context, gameState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            context.read<GameCubit>().initGame(players);
                          },
                          icon: Icon(Icons.refresh_rounded)),
                      Expanded(
                          child: Text('Pot : ${gameState.pot}',
                              textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
                      Expanded(
                          child: Text('Turn : ${gameState.turn}',
                              textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Active player: ' + gameState.activePlayer.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () => context.read<GameCubit>().playerFold(), child: Text('Fold')),
                            ElevatedButton(
                                onPressed: () => context.read<GameCubit>().playerCheckCall(),
                                child: Text('Check/Call')),
                            ElevatedButton(
                                onPressed: raise < gameState.maxBet
                                    ? null
                                    : () {
                                        context.read<GameCubit>().playerRaise(raise);
                                        setState(() {
                                          raise = 0;
                                        });
                                      },
                                child: Text('Raise : ' + raise.toString())),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (raise - context.read<GameCubit>().state.bigBlind >= 0) {
                                    raise -= context.read<GameCubit>().state.bigBlind;
                                  } else {
                                    raise = 0;
                                  }
                                });
                              },
                              child: Text('-' + context.read<GameCubit>().state.bigBlind.toString()),
                            ),
                            Expanded(
                              child: Slider(
                                value: raise.toDouble(),
                                min: 0,
                                max: gameState.activePlayer.sum.toDouble(),
                                onChanged: (value) {
                                  setState(() {
                                    raise = value.toInt();
                                  });
                                  // context.read<PokerCubit>().playerBet(value.toInt(), gameState.activePlayer);
                                },
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (raise + context.read<GameCubit>().state.bigBlind <=
                                      gameState.activePlayer.sum) {
                                    raise += context.read<GameCubit>().state.bigBlind;
                                  } else {
                                    raise = gameState.activePlayer.sum;
                                  }
                                });
                              },
                              child: Text('+' + context.read<GameCubit>().state.bigBlind.toString()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Player', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Sum', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Bet', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      for (var player in gameState.players)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                player.name +
                                    (gameState.dealer == player ? ' (D)' : '') +
                                    (gameState.activePlayer == player ? ' (A)' : ''),
                                style: TextStyle(
                                    color: gameState.foldedPlayers.contains(player)
                                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                        : gameState.allInPlayers.contains(player)
                                            ? Colors.red
                                            : Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                player.sum.toString(),
                                style: TextStyle(
                                    color: gameState.foldedPlayers.contains(player)
                                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                        : gameState.allInPlayers.contains(player)
                                            ? Colors.red
                                            : Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                player.bet.toString(),
                                style: TextStyle(
                                    color: gameState.foldedPlayers.contains(player)
                                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                        : gameState.allInPlayers.contains(player)
                                            ? Colors.red
                                            : Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ],
                        ),
                    ],
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
