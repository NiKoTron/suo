import 'dart:math';
import 'package:suo/suo.dart';

import 'bike.dart';
import 'bike.idx.dart';
import 'ciphers.dart';

final docStorage = DocStorage<Bike>('./bike_storage',
    deSerialiser: Bike.fromJson,
    seriaiser: (b) => b.toJson(),
    cipher: B64Cipher(),
    indexedFactory: (b) => IndexedBike(b));

void main() {
  playWithDocStorage();
}

void playWithDocStorage() {
  bikes.forEach((element) {
    docStorage.save(element);
  });
}

List<Bike> bikes = [
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'gt',
      color: 'red',
      model: 'rukus',
      size: 54,
      speedCount: 9,
      wheelSize: 26.0),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'gt',
      color: 'blue',
      model: 'rukus',
      size: 56,
      speedCount: 11,
      wheelSize: 26.0),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'gt',
      color: 'yellow',
      model: 'avalanche',
      size: 56,
      speedCount: 27,
      wheelSize: 27.5),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'gt',
      color: 'red',
      model: 'avalanche',
      size: 58,
      speedCount: 27,
      wheelSize: 27.5),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'gt',
      color: 'white',
      model: 'avalanche',
      size: 56,
      speedCount: 11,
      wheelSize: 26),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'fuji',
      color: 'black',
      model: 'track',
      size: 56,
      speedCount: 1,
      wheelSize: 700),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'fuji',
      color: 'white',
      model: 'feather',
      size: 52,
      speedCount: 1,
      wheelSize: 700),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'cinelli',
      color: 'green',
      model: 'pista',
      size: 52,
      speedCount: 1,
      wheelSize: 700),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'cinelli',
      color: 'yellow',
      model: 'vigorelli',
      size: 52,
      speedCount: 1,
      wheelSize: 700),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'cinelli',
      color: 'yellow',
      model: 'vigorelli',
      size: 58,
      speedCount: 1,
      wheelSize: 700),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'cinelli',
      color: 'yellow',
      model: 'vigorelli',
      size: 56,
      speedCount: 1,
      wheelSize: 700),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'cinelli',
      color: 'green',
      model: 'vigorelli',
      size: 53,
      speedCount: 1,
      wheelSize: 700),
  Bike(
      serialNo: '${Random().nextInt(4294967296)}',
      brand: 'cinelli',
      color: 'green',
      model: 'vigorelli',
      size: 52,
      speedCount: 1,
      wheelSize: 700),
];
