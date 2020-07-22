import 'package:suo/suo.dart';

@IdxDocument()
class Noga {
  @IdxID()
  @IdxIndex(name: 'aida')
  final String logos;
  @IdxIndex(name: 'aida')
  final String bogos;

  @IdxID()
  final String nogos;

  @IdxIndex(name: 'fora')
  final String bocos;
  @IdxIndex(name: 'fora')
  final String rocos;

  Noga(this.logos, this.bogos, this.nogos, this.bocos, this.rocos);
}
