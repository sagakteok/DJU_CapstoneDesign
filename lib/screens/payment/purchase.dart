import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  late final PaymentWidget _paymentWidget;
  AgreementWidgetControl? _agreementWidgetControl;
  bool _isPaymentReady = false;

  @override
  void initState() {
    super.initState();

    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm",
      customerKey: "user_1234",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final int price = num.tryParse(args?['price']?.toString() ?? '0')?.toInt() ?? 0;

      // 결제 수단 렌더링
      await _paymentWidget.renderPaymentMethods(
        selector: "payment-method-container",
        amount: Amount(
          value: price,
          currency: Currency.KRW,
          country: "KR",
        ),
      );

      // 동의창 렌더링
      _agreementWidgetControl = await _paymentWidget.renderAgreement(
        selector: "agreement-container",
      );

      setState(() {
        _isPaymentReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String productName = args?['name'] ?? '정기권';
    final int priceValue = num.tryParse(args?['price']?.toString() ?? '0')?.toInt() ?? 0;
    // 할인은 args로 받을 수 있게 처리, 없으면 0
    final int discountValue = num.tryParse(args?['discount']?.toString() ?? '0')?.toInt() ?? 0;
    final int totalValue = (priceValue - discountValue) >= 0 ? (priceValue - discountValue) : 0;

    final String price = NumberFormat('#,###원').format(priceValue);
    final String discount = NumberFormat('#,###원').format(discountValue);
    final String totalPrice = NumberFormat('#,###원').format(totalValue);
    final String currentDateTime = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now());

    final double buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // 공용 텍스트 스타일
    const TextStyle labelStyle = TextStyle(
      fontSize: 14,
      fontFamily: 'SpoqaHanSansNeo',
      fontWeight: FontWeight.w500,
      color: Color(0xFF2F3644),
    );

    const TextStyle valueStyle = TextStyle(
      fontSize: 16,
      fontFamily: 'SpoqaHanSansNeo',
      fontWeight: FontWeight.w700,
      color: Color(0xFF2F3644),
    );

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
          '결제하기',
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
                    // 상품명 타이틀(라벨) + 실제 상품명 (스타일 다르게)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '상품명: ',
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
                            productName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'SpoqaHanSansNeo',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF50A12E), // 녹색 강조(원래 의도대로)
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 상품금액 / 할인금액 (width: screenWidth * 0.92, 양 옆 배치)
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

                    // 총 결제 금액 박스 (width: screenWidth * 0.96, height: 50, radius 10, 그라데이션)
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
              // --------- 변경된 상품 / 금액 UI 끝 ---------

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
              SizedBox(
                width: buttonWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('구입 예정 일시: $currentDateTime',
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
                              const SnackBar(
                                  content: Text('결제 약관에 동의해야 결제 가능합니다.')),
                            );
                            return;
                          }

                          try {
                            final paymentInfo = PaymentInfo(
                              orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
                              orderName: productName,
                            );

                            final result = await _paymentWidget
                                .requestPayment(paymentInfo: paymentInfo);

                            if (result.success != null) {
                              const SnackBar(content: Text('결제 성공!'));
                              // 결제 성공 시 페이지 이동
                              Navigator.pushReplacementNamed(
                                  context, '/payment/PaymentComplete');
                            } else if (result.fail != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '결제 실패: ${result.fail!.errorMessage}')),
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
                              style: TextStyle(
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