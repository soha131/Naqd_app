import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naqd_app/cubit/CoorporateCubit.dart';
import 'package:naqd_app/cubit/SpendingCubit.dart';
import 'package:naqd_app/cubit/ocr_cubit.dart';
import 'package:naqd_app/splash/loading.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SpendingCubit()),  // Provide SpendingCubit
        BlocProvider(create: (context) => Coorporatecubit()),  // Provide AmountPredictionCubit
        BlocProvider(create: (context) => AmountPredictionCubit()),  // Provide AmountPredictionCubit
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
     /*   theme: ThemeData(
      fontFamily: 'Inter',
      textTheme: ThemeData.light().textTheme,
    ),*/debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
