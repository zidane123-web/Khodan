import 'dart:io' show Platform;

import 'platform_info_types.dart';

PlatformInfo loadPlatformInfo() => PlatformInfo(
      platform: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
    );
