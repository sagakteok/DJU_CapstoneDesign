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
    final String price = NumberFormat('#,###원').format(priceValue);
    final String currentDateTime = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now());

    final double buttonWidth = MediaQuery.of(context).size.width * 0.85;
    final double screenHeight = MediaQuery.of(context).size.height;

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
              SizedBox(height: screenHeight * 0.1),
              SizedBox(
                width: buttonWidth,
                child: Column(
                  children: [
                    Text(productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF76B55C),
                        ),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text(price,
                        style: const TextStyle(
                          fontSize: 35,
                          fontFamily: 'SpoqaHanSansNeo',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2F3644),
                        ),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: buttonWidth,
                height: 250,
                child: PaymentMethodWidget(
                  paymentWidget: _paymentWidget,
                  selector: "payment-method-container",
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: buttonWidth,
                height: 150,
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
                              const SnackBar(
                                  content: Text('결제 성공!')
                              );
                              // 결제 성공 시 페이지 이동
                              Navigator.pushReplacementNamed(context, '/payment/PaymentComplete');
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
                            child: const Text(
                              '결제하기',
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