import 'dart:convert';

import 'package:suo/suo.dart';

@idxDocument
class Bike {
  @idxID
  final String serialNo;
  final String brand;
  @IdxIndex(name: 'modelColor')
  final String model;
  @IdxIndex(name: 'speedCount')
  final int speedCount;
  final int size;
  @IdxIndex(name: 'modelColor')
  final String color;
  final double wheelSize;
  Bike({
    this.serialNo,
    this.brand,
    this.model,
    this.speedCount,
    this.size,
    this.color,
    this.wheelSize,
  });

  Bike copyWith({
    String serialNo,
    String brand,
    String model,
    int speedCount,
    int size,
    String color,
    double wheelSize,
  }) {
    return Bike(
      serialNo: serialNo ?? this.serialNo,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      speedCount: speedCount ?? this.speedCount,
      size: size ?? this.size,
      color: color ?? this.color,
      wheelSize: wheelSize ?? this.wheelSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serialNo': serialNo,
      'brand': brand,
      'model': model,
      'speedCount': speedCount,
      'size': size,
      'color': color,
      'wheelSize': wheelSize,
    };
  }

  static Bike fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Bike(
      serialNo: map['serialNo'],
      brand: map['brand'],
      model: map['model'],
      speedCount: map['speedCount'],
      size: map['size'],
      color: map['color'],
      wheelSize: map['wheelSize'],
    );
  }

  String toJson() => json.encode(toMap());

  static Bike fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Bike(serialNo: $serialNo, brand: $brand, model: $model, speedCount: $speedCount, size: $size, color: $color, wheelSize: $wheelSize)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Bike &&
        o.serialNo == serialNo &&
        o.brand == brand &&
        o.model == model &&
        o.speedCount == speedCount &&
        o.size == size &&
        o.color == color &&
        o.wheelSize == wheelSize;
  }

  @override
  int get hashCode {
    return serialNo.hashCode ^
        brand.hashCode ^
        model.hashCode ^
        speedCount.hashCode ^
        size.hashCode ^
        color.hashCode ^
        wheelSize.hashCode;
  }
}
