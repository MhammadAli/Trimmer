part of 'app_cubit.dart';


abstract class AppStates {}

final class AppInitialState extends AppStates {}
final class AppSuccessState extends AppStates{}
final class AppErrorState extends AppStates{}
final class AppLoadingState extends AppStates{}
final class AppFetchDurationState extends AppStates{}
final class AppTrimmingLoadingState extends AppStates{}
final class AppTrimmingSuccessState extends AppStates{}
final class AppTrimmingErrorState extends AppStates{}