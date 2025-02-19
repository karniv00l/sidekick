import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openLink(BuildContext context, String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw context.i18n(
      'modules:common.utils.couldNotLaunchUrl',
      variables: {'url': url},
    );
  }
}

Future<void> openPath(BuildContext context, String url) async {
  if (Platform.isWindows) {
    await Process.start('start', [url]);
  } else if (Platform.isMacOS) {
    await Process.start('open', [url]);
  }
  //TODO: missing linux
}

Future<void> openVsCode(
  BuildContext context,
  String path, {
  String? customLocation,
}) async {
  if (Platform.isWindows || Platform.isLinux) {
    await Process.run('code', [path], runInShell: true);
  } else {
    final vsCodeUri = 'vscode://file/$path';
    return await openLink(context, vsCodeUri);
  }
}

Future<void> openXcode(
  BuildContext context,
  String path, {
  String? customLocation,
}) async {
  final workspaceUri = '$path/ios/Runner.xcworkspace';
  return await openPath(context, workspaceUri);
}

Future<void> openCustom(
  BuildContext context,
  String path, {
  String? customLocation,
}) async {
  if (customLocation != null) {
    return await openPath(context, path);
  }
  if (Platform.isMacOS) {
    await Process.run(
      "open",
      ['-a $customLocation', path],
      runInShell: true,
    );
  } else {
    await Process.run(
      customLocation!,
      [path],
      runInShell: true,
    );
  }
}
