part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const authentication = _Paths.authentication;
  static const dashboard = _Paths.dashboard;
  static const requests = _Paths.requests;
  static const tracking = _Paths.tracking;
  static const trips = _Paths.trips;
  static const profile = _Paths.profile;
  static const settings = _Paths.settings;
}

abstract class _Paths {
  _Paths._();
  static const home = '/home';
  static const authentication = '/authentication';
  static const dashboard = '/dashboard';
  static const requests = '/requests';
  static const tracking = '/tracking';
  static const trips = '/trips';
  static const profile = '/profile';
  static const settings = '/settings';
}
