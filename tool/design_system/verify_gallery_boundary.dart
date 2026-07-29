import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'verify_import_boundaries.dart' show verifyPublicBarrel;

const _registryPath =
    'lib/core/design_system/gallery/app_gallery_registry.dart';
const _barrelPath = 'lib/admin9_ui.dart';

void main() {
  final registry = File(_registryPath).readAsStringSync();
  final unit = parseString(content: registry, path: _registryPath).unit;
  final errors = <String>[];
  final registryClass = unit.declarations
      .whereType<ClassDeclaration>()
      .singleWhere(
        (declaration) =>
            declaration.namePart.typeName.lexeme == 'AppGalleryRegistry',
      );
  final fields = registryClass.body.childEntities
      .whereType<FieldDeclaration>()
      .toList();
  final routeName = fields
      .expand((field) => field.fields.variables)
      .singleWhere((variable) => variable.name.lexeme == 'routeName');
  if (routeName.initializer is! SimpleStringLiteral ||
      (routeName.initializer as SimpleStringLiteral).value !=
          '/__admin9/gallery') {
    errors.add('Gallery route name is not the frozen internal route');
  }
  final methods = registryClass.body.childEntities
      .whereType<MethodDeclaration>();
  final memberNames = <String>{
    ...fields.expand(
      (field) => field.fields.variables.map((variable) => variable.name.lexeme),
    ),
    ...methods.map((method) => method.name.lexeme),
  };
  const expectedMembers = <String>{
    'routeName',
    'isRegistered',
    'registeredRouteNames',
  };
  if (memberNames.length != expectedMembers.length ||
      !memberNames.containsAll(expectedMembers)) {
    errors.add('Gallery registry contains an unapproved registration seam');
  }
  final registered = methods.singleWhere(
    (method) => method.name.lexeme == 'isRegistered',
  );
  final routeNames = methods.singleWhere(
    (method) => method.name.lexeme == 'registeredRouteNames',
  );
  final registeredBody = registered.body;
  final routeNamesBody = routeNames.body;
  if (!registered.isGetter ||
      registeredBody is! ExpressionFunctionBody ||
      registeredBody.expression.toSource() != '!kReleaseMode') {
    errors.add('Gallery isRegistered must be exactly !kReleaseMode');
  }
  if (!routeNames.isGetter ||
      routeNamesBody is! ExpressionFunctionBody ||
      routeNamesBody.expression.toSource() !=
          'kReleaseMode ? const <String>{} : const <String>{routeName}') {
    errors.add(
      'Gallery registeredRouteNames must be empty in release and contain only '
      'routeName otherwise',
    );
  }
  errors.addAll(verifyPublicBarrel(File(_barrelPath)));
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('Gallery boundary: PASS (debug/profile seam, release guard)');
}
