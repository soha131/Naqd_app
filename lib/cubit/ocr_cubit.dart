import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:naqd_app/cubit/ocr_model.dart';
import 'package:naqd_app/cubit/service.dart';
import 'ocr_state.dart';

class AmountPredictionCubit extends Cubit<AmountPredictionState> {
  AmountPredictionCubit() : super(AmountPredictionInitial());

  Future<double> total(File file, BuildContext context) async {
    try {
      emit(AmountPredictionLoading());
      AmountPrediction? result = await ApiService().fetchDataFromApi(file, context);

      if (result != null) {
        emit(AmountPredictionSuccess(result));  // Emit result when successful
        return result.total;  // Return the amount extracted from the result
      } else {
        emit(AmountPredictionError("No result returned from the API."));
        return 0.0;  // Return a default value in case no result is found
      }
    } catch (e) {
      emit(AmountPredictionError("Error: $e"));
      return 0.0;  // Return a default value in case of an error
    }
  }

}
