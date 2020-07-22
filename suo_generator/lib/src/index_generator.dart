import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:suo/suo.dart';

final _dartfmt = DartFormatter();

class IndexGenerator extends GeneratorForAnnotation<IdxDocument> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generateSource(element);
  }

  String _generateSource(Element element) {
    var visitor = IndexVisitor();
    element.visitChildren(visitor);

    return _genIndexedEntityClass('${visitor.className}', visitor.source,
        visitor.indexId, visitor.indexedFields);
  }

  String _genIndexedEntityClass(String baseName, String baseSource,
      List<String> ids, Map<String, List<String>> indexedFields) {
    final idsExp = ids.map((e) => '\${o?.' + e + '}').toList().join('');

    final idcs = literalList(indexedFields.keys
        .map(
          (key) => refer('Index', 'package:suo/suo.dart').newInstance(
            [
              literal('$key'),
              Method((mb) => mb
                ..requiredParameters.add(Parameter((pb) => pb
                  ..type = refer('$baseName')
                  ..name = 'v'))
                ..lambda = true
                ..body = refer('sha256', 'package:crypto/crypto.dart')
                    .property('convert')
                    .call([
                  refer('utf8', 'dart:convert').property('encode').call([
                    literal(
                      indexedFields[key]
                          .map((e) => '\${v?.' + e + '}')
                          .toList()
                          .join(''),
                    ),
                  ])
                ]).code).closure.property('toString').call([])
            ],
          ),
        )
        .toList());

    final clazz = Class((b) => b
      ..name = 'Indexed$baseName'
      ..extend =
          refer('IndexedEntity<$baseName, String>', 'package:suo/suo.dart')
      ..constructors.add(
        Constructor((b) => b
          ..requiredParameters.add(
            Parameter((pb) => pb
              ..type = refer('$baseName', baseSource)
              ..name = 'value'),
          )
          ..initializers.add(refer('super').call([
            refer('value'),
            Method((mb) => mb
              ..requiredParameters.add(
                Parameter((pb) => pb
                  ..type = refer('$baseName', baseSource)
                  ..name = 'o'),
              )
              ..lambda = true
              ..body = refer('sha256', 'package:crypto/crypto.dart')
                  .property('convert')
                  .call([
                refer('utf8', 'dart:convert').property('encode').call([
                  literal('$idsExp'),
                ]),
              ]).code).closure.property('toString').call([]),
            idcs
          ]).code)),
      ));

    final emitter = DartEmitter(Allocator(), true, true);
    final library = Library((b) => b.body.add(clazz));
    return _dartfmt.format('${library.accept(emitter)}');
  }
}

class IndexVisitor extends SimpleElementVisitor {
  DartType className;
  String get source => className?.element?.librarySource?.shortName;

  Map<String, List<String>> indexedFields = {};
  List<String> indexId = [];

  @override
  void visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType;
  }

  @override
  void visitFieldElement(FieldElement element) {
    element.metadata.forEach((el) {
      final con = el.computeConstantValue();
      final typeName = con?.type?.toString();
      if (typeName == 'IdxIndex') {
        final field = con?.getField('name')?.toStringValue();
        if (indexedFields.containsKey(field)) {
          indexedFields[field].add(element.name);
        } else {
          indexedFields[field] = [element.name];
        }
      }
      if (typeName == 'IdxID') {
        indexId.add(element.name);
      }
    });
  }
}
