import 'dart:io';

import 'package:flutter/material.dart';

//Renders a property image from [url] — asset path (assets/...) or network URL.
Widget propertyImage({
  required String url,
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  final isAsset = url.startsWith('assets/');
  final isFile =
      url.startsWith('file://') ||
      (url.isNotEmpty && !url.contains('://') && File(url).existsSync());
  if (isAsset) {
    return Image.asset(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) =>
          _placeholder(fit: fit, width: width, height: height),
    );
  }
  if (isFile) {
    final filePath = url.startsWith('file://')
        ? url.replaceFirst('file://', '')
        : url;
    return Image.file(
      File(filePath),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) =>
          _placeholder(fit: fit, width: width, height: height),
    );
  }

  return Image.network(
    url,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (_, __, ___) =>
        _placeholder(fit: fit, width: width, height: height),
  );
}

Widget _placeholder({
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  return Container(
    width: width,
    height: height,
    color: Colors.grey.shade300,
    child: Icon(Icons.home, size: 48, color: Colors.grey.shade500),
  );
}
