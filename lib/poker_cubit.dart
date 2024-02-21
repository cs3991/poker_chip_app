import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:poker/player.dart';

part 'poker_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit()
      : super(GameState(
          players: [],
          pot: 0,
          dealer: Player(id: 0, name: ''),
          activePlayer: Player(id: 0, name: ''),
          smallBlind: 5,
          bigBlind: 10,
          turn: Turn.preFlop,
          maxBet: 0,
          activePlayers: [],
          foldedPlayers: [],
          allInPlayers: [],
          lastRaisePlayer: Player(id: 0, name: ''),
        ));

  void initGame(List<String> players) {
    List<Player> playersList = [];
    for (int i = 0; i < players.length; i++) {
      playersList.add(Player(id: i, name: players[i]));
    }
    emit(GameState(
      players: playersList,
      pot: 0,
      dealer: playersList[0],
      activePlayer: playersList[1],
      activePlayers: playersList.sublist(0),
      foldedPlayers: [],
      allInPlayers: [],
      smallBlind: 5,
      bigBlind: 10,
      turn: Turn.preFlop,
      maxBet: 0,
      lastRaisePlayer: playersList[1],
    ));
  }

  void playerBet(int amount, Player player) {
    var nextState = state.copy();
    nextState.activePlayer = nextState
        .activePlayers[(nextState.activePlayers.indexOf(player) + 1) % nextState.activePlayers.length];
    if (amount == -1) {
      // fold
      nextState.foldedPlayers.add(player);
      nextState.activePlayers.remove(player);
    } else if (amount >= state.maxBet) {
      // check/call or raise
      if (amount > state.maxBet) {
        nextState.lastRaisePlayer = player;
      }
      player.sum -= amount;
      player.bet += amount;
      nextState.pot += amount;
      nextState.maxBet = amount;
      if (player.sum == 0) {
        nextState.allInPlayers.add(player);
        nextState.activePlayers.remove(player);
      }
    } else {
      // invalid
      throw Exception('Invalid bet');
    }

    if (nextState.activePlayer == nextState.lastRaisePlayer) {
      // end of round
      if (nextState.turn == Turn.river) {
        // end of game
        nextState.turn = Turn.end;
        emit(nextState);
        return;
        //   for (var player in nextState.activePlayers) {
        //     player.bet = 0;
        //   }
        //    var winners = nextState.activePlayers;
        //
        //   emit(nextState);
        //   return;
      }

      nextState.turn = Turn.values[(nextState.turn.index + 1) % Turn.values.length];
      nextState.activePlayer = nextState.activePlayers[
          (nextState.activePlayers.indexOf(nextState.dealer) + 1) % nextState.activePlayers.length];
      nextState.lastRaisePlayer = nextState.activePlayer;
      nextState.maxBet = 0;
      for (var player in nextState.players) {
        player.bet = 0;
      }
    }

    emit(nextState);
  }

  void playerFold() {
    playerBet(-1, state.activePlayer);
  }

  void playerCheckCall() {
    playerBet(state.maxBet, state.activePlayer);
  }

  void playerRaise(int amount) {
    playerBet(amount, state.activePlayer);
  }

  void roundOverWithOneWinner(Player winner) {
    var nextState = state.copy();
    nextState.turn = Turn.preFlop;
    for (var player in nextState.players) {
      player.bet = 0;
    }
    var nextDealerIndex = (nextState.players.indexOf(nextState.dealer) + 1) % nextState.players.length;
    nextState.dealer = nextState.players[nextDealerIndex];
    nextState.activePlayer = nextState.players[(nextDealerIndex + 1) % nextState.players.length];
    nextState.players.removeWhere((player) => player.sum == 0);
    nextState.activePlayers = nextState.players.sublist(0);
    nextState.maxBet = 0;
    nextState.lastRaisePlayer = nextState.activePlayer;
    nextState.foldedPlayers = [];
    nextState.allInPlayers = [];
    winner.sum += nextState.pot;
    nextState.pot = 0;
    emit(nextState);
  }
}
