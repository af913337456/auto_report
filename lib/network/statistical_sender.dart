import 'package:auto_report/banks/wave/config/config.dart';
import 'package:auto_report/network/proto/statistical_transfer_report.dart';
import 'package:auto_report/utils/log_helper.dart';
import 'package:http/http.dart' as http;

class StatisticalSender {
  // 测试服
  static const _host = "8.222.131.154";

  static Future<http.Response?> _post({
    required String path,
    Object? body,
  }) async {
    try {
      final url = Uri.http(_host, path);
      logger.i('url: ${url.toString()}');
      logger.i('host: $_host, path: $path');
      final response = await Future.any([
        http.post(url, body: body),
        Future.delayed(
            const Duration(seconds: Config.httpRequestTimeoutSeconds)),
      ]);
      return response;
    } catch (e, stack) {
      logger.e(e, stackTrace: stack);
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
      final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
      final reqBody = StatisticalTransferReport(
        orderId: orderId,
        targetNumber: targetNumber,
        sourceNumber: sourceNumber,
        money: money,
        bank: bank,
        timestamp: timestamp,
      );

      logger.i(
          'report to statistical server. timestamp: $timestamp, reqBody: ${reqBody.toString()}');
      final response = await _post(path: 'tool_apply', body: [reqBody]);

      if (response == null) return false;

      final body = response.body;
      logger.i('res body: $body');

      return true;
    } catch (e, stackTrace) {
      logger.e('e1: $e');
      logger.e('e2: $e', stackTrace: stackTrace);
    }
    return false;
  }
}
