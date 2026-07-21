part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  final int tabIndex;
  const HomeState({this.tabIndex = 2});

  @override
  List<Object> get props => [tabIndex];
}

final class HomeInitial extends HomeState {
  const HomeInitial({super.tabIndex = 2});
}

final class HomeTabState extends HomeState {
  const HomeTabState(int index) : super(tabIndex: index);
}
