part of 'poker_cubit.dart';

enum Turn { preFlop, flop, turn, river, end }

class GameState {
  List<Player> players;
  int pot;
  Player dealer;
  Player activePlayer;
  int smallBlind;
  int bigBlind;
  Turn turn;
  int maxBet;
  List<Player> activePlayers;
  List<Player> foldedPlayers;
  List<Player> allInPlayers;
  Player lastRaisePlayer;

  GameState({
    required this.players,
    required this.pot,
    required this.dealer,
    required this.activePlayer,
    required this.activePlayers,
    required this.foldedPlayers,
    required this.allInPlayers,
    required this.smallBlind,
    required this.bigBlind,
    required this.turn,
    required this.maxBet,
    required this.lastRaisePlayer,
  });

  GameState copy() {
    return GameState(
      players: players,
      pot: pot,
      dealer: dealer,
      activePlayer: activePlayer,
      activePlayers: activePlayers,
      foldedPlayers: foldedPlayers,
      allInPlayers: allInPlayers,
      smallBlind: smallBlind,
      bigBlind: bigBlind,
      turn: turn,
      maxBet: maxBet,
      lastRaisePlayer: lastRaisePlayer,
    );
  }
}
