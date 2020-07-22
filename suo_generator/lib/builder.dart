import 'package:build/build.dart';
import 'package:suo_generator/src/index_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder indexBuilder(BuilderOptions options) =>
    LibraryBuilder(IndexGenerator(), generatedExtension: '.idx.dart');
