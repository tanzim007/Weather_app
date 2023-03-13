import 'dart:convert';
import 'package:geocoding/geocoding.dart' as Geo;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/current_response_model.dart';
import '../models/forecast_response_model.dart';
import '../utils/constants.dart';

class WeatherProvider extends ChangeNotifier {
  CurrentResponseModel? currentResponseModel;
  ForecastResponseModel? forecastResponseModel;
  double latitude = 0.0, longitude = 0.0;
  String unit = metric; //imperial
  String unitSymbol = celsius;

  bool get isFahrenheit => unit == imperial;

  bool get hasDataLoaded => currentResponseModel != null &&
      forecastResponseModel != null;

  setNewLocation(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }

  Future<bool> setTempUnitPreferenceValue(bool value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setBool('unit', value);
  }

  Future<bool> getTempUnitPreferenceValue() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('unit') ?? false;
  }

  Future<bool> setDefaultCity(bool tag) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setBool('defaultCity', tag);
  }

  Future<bool> getDefaultCity() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('defaultCity') ?? false;
  }

  Future<void> setDefaultCityLatLng() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setDouble('lat', latitude);
    await pref.setDouble('lng', longitude);
  }

  Future<Map<String, double>> getDefaultCityLatLng() async {
    final pref = await SharedPreferences.getInstance();
    final lat = await pref.getDouble('lat') ?? 0.0;
    final lng = await pref.getDouble('lng') ?? 0.0;
    return {'lat' : lat, 'lng' : lng};
  }

  getWeatherData() {
    _getCurrentData();
    _getForecastData();
  }

  void _getCurrentData() async {
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weatherApikey');
    try {
      final response = await get(uri);
      final map = jsonDecode(response.body);
      if(response.statusCode == 200) {
        currentResponseModel = CurrentResponseModel.fromJson(map);
        print(currentResponseModel!.main!.temp!.round());
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  void _getForecastData() async {
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weatherApikey');
    try {
      final response = await get(uri);
      final map = jsonDecode(response.body);
      if(response.statusCode == 200) {
        forecastResponseModel = ForecastResponseModel.fromJson(map);
        print(forecastResponseModel!.list!.length);
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  void setTempUnit(bool value) {
    unit = value ? imperial : metric;
    unitSymbol = value ? fahrenheit : celsius;
    notifyListeners();
  }

  void convertCityToLatLng({
    required String result,
    required Function(String) onError
  }) async {
    try {
      final locList = await Geo.locationFromAddress(result);
      if(locList.isNotEmpty) {
        final location = locList.first;
        setNewLocation(location.latitude, location.longitude);
        getWeatherData();
      } else {
        onError('City not found');
      }
    } catch(error) {
      onError(error.toString());
    }
  }
}