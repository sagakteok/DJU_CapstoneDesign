import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'dart:convert'; // jsonEncode 사용
import 'package:http/http.dart' as http; // http.post 사용
import 'package:jwt_decoder/jwt_decoder.dart'; // JwtDecoder 사용
import '../../services/auth_service.dart'; // 서버에서 사용자 정보 가져오기
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CarLeavePurchaseScreen extends StatefulWidget {
  const CarLeavePurchaseScreen({super.key});

  @override
  State<CarLeavePurchaseScreen> createState() => _CarLeavePurchaseScreenState();
}

class _CarLeavePurchaseScreenState extends State<CarLeavePurchaseScreen> {
  late final PaymentWidget _paymentWidget;
  AgreementWidgetControl? _agreementWidgetControl;
  bool _isPaymentReady = false;

  @override
  void initState() {
    super.initState();

    _paymentWidget = PaymentWidget(
      clientKey: dotenv.env['PURCHASE_CLIENT_KEY']!,
      customerKey: dotenv.env['PURHCASE_CUSTOMER_KEY']!,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final int price = num.tryParse(args?['currentFee']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0')?.toInt() ?? 0;

      await _paymentWidget.renderPaymentMethods(
        selector: dotenv.env['PURHCASE_PAYMENT_METHODS_SELECTOR']!,
        amount: Amount(
          value: price,
          currency: Currency.KRW,
          country: "KR",
        ),
      );

      _agreementWidgetControl = await _paymentWidget.renderAgreement(
        selector: dotenv.env['PURHCASE_AGREEMENT_SELECTOR']!,
      );

      setState(() {
        _isPaymentReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // ✅ arguments에서 받기
    final String duration = args?['duration'] ?? '-';
    final String currentFeeRaw = args?['currentFee'] ?? '0';
    final int priceValue = num.tryParse(currentFeeRaw.replaceAll(RegExp(r'[^0-9]'), ''))?.toInt() ?? 0;

    // 할인금액 (일단 임시로 0 처리 가능)
    final int discountValue = 0;

    // 총 결제 금액 계산
    final int totalValue = (priceValue - discountValue) >= 0 ? (priceValue - discountValue) : 0;

    // 출력용 포맷
    final String price = NumberFormat('#,###원').format(priceValue);
    final String discount = NumberFormat('#,###원').format(discountValue);
    final String totalPrice = NumberFormat('#,###원').format(totalValue);
    final String currentDateTime = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now());

    final double buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '출차 결제',
          style: TextStyle(
            fontFamily: 'SpoqaHanSansNeo',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ 총 이용 시간 표시
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '총 이용 시간: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'SpoqaHanSansNeo',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2F3644),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            duration,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'SpoqaHanSansNeo',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF50A12E),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ✅ 금액 영역 (상품금액, 할인금액)
                    SizedBox(
                      width: screenWidth * 0.92,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '상품금액',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF414B6A),
                                ),
                              ),
                              Text(
                                price,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2F3644),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '할인금액',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF414B6A),
                                ),
                              ),
                              Text(
                                discount,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SpoqaHanSansNeo',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2F3644),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ✅ 총 결제 금액
                    Center(
                      child: Container(
                        width: screenWidth * 0.92,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF15C3AF), Color(0xFF76B55C)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '총 결제 금액',
                              style: TextStyle(
                                color: Color(0xFFECF2E9),
                                fontSize: 14,
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              totalPrice,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // ✅ Toss 위젯
              SizedBox(
                width: screenWidth * 0.92,
                height: 300,
                child: PaymentMethodWidget(
                  paymentWidget: _paymentWidget,
                  selector: "payment-method-container",
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: screenWidth * 0.92,
                height: 300,
                child: AgreementWidget(
                  paymentWidget: _paymentWidget,
                  selector: "agreement-container",
                ),
              ),

              const SizedBox(height: 20),

              // ✅ 결제 버튼
              SizedBox(
                width: buttonWidth,
                child: Column(
                  children: [
                    Text('결제 일시: $currentDateTime',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF376524),
                        )),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPaymentReady
                            ? () async {
                          final agreementStatus =
                          await _agreementWidgetControl?.getAgreementStatus();
                          if (agreementStatus?.agreedRequiredTerms != true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('결제 약관에 동의해야 결제 가능합니다.')),
                            );
                            return;
                          }

                          try {
                            final paymentInfo = PaymentInfo(
                              orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
                              orderName: '출차 결제',
                            );

                            final result = await _paymentWidget.requestPayment(
                                paymentInfo: paymentInfo);

                            if (result.success != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('결제 성공!')),
                              );

                              final authService = AuthService();
                              final token = await authService.getToken();

                              final host = dotenv.env['HOST_ADDRESS'];
                              final url = Uri.parse('$host/api/payment/leave');

                              Map<String, dynamic> payload = {
                                'amount': totalValue,
                                'duration': duration,
                              };

// ✅ 회원이면 user_id 포함 + 헤더에 토큰 추가
                              Map<String, String> headers = {'Content-Type': 'application/json'};
                              if (token != null) {
                                final decoded = JwtDecoder.decode(token);
                                payload['user_id'] = decoded['user_id'];
                                headers['Authorization'] = 'Bearer $token';
                              }

                              final response = await http.post(
                                url,
                                headers: headers,
                                body: jsonEncode(payload),
                              );

                              if (response.statusCode == 200) {
                                debugPrint('출차 결제 서버 확인 성공: ${response.body}');
                              } else {
                                debugPrint('출차 결제 서버 확인 실패: ${response.statusCode} ${response.body}');
                              }

                              Navigator.pushReplacementNamed(
                                  context, '/payment/PaymentComplete');
                            } else if (result.fail != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                    Text('결제 실패: ${result.fail!.errorMessage}')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('결제 오류: $e')),
                            );
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF76B55C), Color(0xFF25C1A1)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '$totalPrice 결제하기',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}