// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library stagehand.cli;

import 'dart:async';
import 'dart:io' as io;

import 'package:stagehand/stagehand.dart';
import 'package:stagehand/analytics/analytics_io.dart';
import 'package:stagehand/src/cli_app.dart';

void main(List<String> args) {
  CliApp app = new CliApp(generators, new CliLogger());

  try {
    app.process(args).catchError((e, st) {
      if (e is ArgError) {
        // These errors are expected.
        io.exit(1);
      } else {
        print('Unexpected error: ${e}\n${st}');
        _sendException(app.analytics, e, st).then((_) {
          io.exit(1);
        });
      }
    });
  } catch (e, st) {
    print('Unexpected error: ${e}\n${st}');
    _sendException(app.analytics, e, st);
  }
}

Future _sendException(Analytics analytics, var e, var st) {
  String str = '${st}';

  // Sanitize (file:///Users/sethladd/tmp/error.dart:3:13) to (error.dart:3:13).
  str = sanitizeFilePaths(str);

  // Shorten the stacktrace up a bit.
  str = str.replaceAll('.dart', '')
      .replaceAll('package:', '')
      .replaceAll('dart:', '')
      .replaceAll(new RegExp(r'\s+'), ' ');

  if (e != null) {
    str = '${e.runtimeType}: ${str}';
  }

  return analytics.sendException(str, true);
}
