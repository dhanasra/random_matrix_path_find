part of 'matrix_bloc.dart';

@immutable
abstract class MatrixState {}

class MatrixInitial extends MatrixState {}

class Loading extends MatrixState {}

class MatrixGenerated extends MatrixState {
  final Map cPT;

  MatrixGenerated({required this.cPT});

}
