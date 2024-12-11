import 'dart:convert';

import 'package:auto_report/banks/wave/config/config.dart';
import 'package:auto_report/network/proto/statistical_transfer_report.dart';
import 'package:auto_report/utils/log_helper.dart';
import 'package:http/http.dart' as http;

class StatisticalSender {
  // 测试服
  static const _host = "47.84.202.171:7001";

  static Future<http.Response?> _post({
    required String path,
    Object? body,
  }) async {
    try {
      final url = Uri.http(_host, path);
      logger.i('url: ${url.toString()}');
      logger.i('host: $_host, path: $path, body: $body');
      final headers = {'Content-Type': 'application/json'};
      final timer = Future.delayed(
          const Duration(seconds: Config.httpRequestTimeoutSeconds));
      final response = await Future.any([
        http.post(url, headers: headers, body: body),
        timer,
      ]);
      return response;
    } catch (e, stack) {
      logger.e(e, stackTrace: stack);
      logger.e(e);
      return null;
    }
  }

  static Future<bool> report({
    required String orderId,
    required String targetNumber,
    required String sourceNumber,
    required double money,
    required String bank,
    required String channel,
  }) async {
    try {
      final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch * 10;
      final reqBody = StatisticalTransferReport(data: [
        StatisticalTransferReportData(
          orderId: orderId,
          targetNumber: targetNumber,
          sourceNumber: sourceNumber,
          money: money,
          bank: bank,
          channel: channel,
          timestamp: timestamp,
        )
      ]);

      logger.i(
          'report to statistical server. timestamp: $timestamp, reqBody: ${reqBody.toString()}');
      final response = await _post(
        path: 'api/post_data',
        body: jsonEncode(reqBody.toJson()),
      );

      if (response == null) return false;

      final body = response.body;
      logger.i('res body: $body, res code: ${response.statusCode}');

      return true;
    } catch (e, stackTrace) {
      logger.e('e1: $e');
      logger.e('e2: $e', stackTrace: stackTrace);
    }
    return false;
  }
}
