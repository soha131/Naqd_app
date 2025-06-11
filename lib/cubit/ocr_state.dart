
import 'package:naqd_app/cubit/ocr_model.dart';

abstract class AmountPredictionState {}

class AmountPredictionInitial extends AmountPredictionState {}

class AmountPredictionLoading extends AmountPredictionState {}

class AmountPredictionSuccess extends AmountPredictionState {
  final AmountPrediction prediction;
  AmountPredictionSuccess(this.prediction);
}

class AmountPredictionError extends AmountPredictionState {
  final String message;
  AmountPredictionError(this.message);
}
