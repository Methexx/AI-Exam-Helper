// ignore_for_file: avoid_print

import 'dart:io';
import 'package:git_hooks/git_hooks.dart';

void main(List<String> arguments) {
  Map<Git, UserBackFun> params = {
    Git.preCommit: preCommit,
    Git.prePush: prePush,
  };
  GitHooks.call(arguments, params);
}

Future<bool> preCommit() async {
  // Run dart format check
  print('🔍 Checking Dart formatting...');
  final formatResult = await Process.run('dart', [
    'format',
    '--set-exit-if-changed',
    '.',
  ], runInShell: true);

  if (formatResult.exitCode != 0) {
    print('❌ Code formatting issues found. Run "dart format ." to fix them.');
    return false;
  }
  print('✅ Formatting check passed');

  // Run flutter analyze
  print('🔍 Running Flutter analyze...');
  final analyzeResult = await Process.run('flutter', [
    'analyze',
  ], runInShell: true);

  if (analyzeResult.exitCode != 0) {
    print('❌ Linting issues found. Please fix them before committing.');
    print(analyzeResult.stdout);
    return false;
  }
  print('✅ Analysis passed');

  return true;
}

Future<bool> prePush() async {
  print('🔍 Running pre-push checks...');
  // You can add additional checks here like running tests
  return true;
}
