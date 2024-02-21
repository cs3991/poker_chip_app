class Player {
  int id;
  String name;
  int sum;
  int bet;

  Player({
    required this.id,
    required this.name,
    this.sum = 1000,
    this.bet = 0,
  });
}
