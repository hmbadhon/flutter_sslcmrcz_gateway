import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sslcommerz/model/SSLCAdditionalInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCEMITransactionInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCShipmentInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/General.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/SSLCProductInitializer.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SSlComercz Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SSlComercz Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic formData = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            sslCommercePayment();
          },
          child: const Text('SSL Pay'),
        ),
      ),
    );
  }

  Future<void> sslCommercePayment() async {
    Sslcommerz sslCommerce = Sslcommerz(
      initializer: SSLCommerzInitialization(
        multi_card_name: formData['multicard'],
        currency: SSLCurrencyType.BDT,
        product_category: "Test",

        ///SSL SandBox ///
        ipn_url: "www.ipnurl.com",
        sdkType: SSLCSdkType.TESTBOX,
        store_id: 'testi6119f4717446f',
        store_passwd: 'testi6119f4717446f@ssl',

        ///SSL SandBox End///

        total_amount: 100.00,
        tran_id: DateTime.now().microsecondsSinceEpoch.toString(),
      ),
    );
    sslCommerce
        .addEMITransactionInitializer(
          sslcemiTransactionInitializer: SSLCEMITransactionInitializer(
            emi_options: 1,
            emi_max_list_options: 3,
            emi_selected_inst: 2,
          ),
        )
        .addShipmentInfoInitializer(
          sslcShipmentInfoInitializer: SSLCShipmentInfoInitializer(
            shipmentMethod: "yes",
            numOfItems: 10,
            shipmentDetails: ShipmentDetails(
              shipAddress1: 'Mirpur-1,Dhaka',
              shipCity: 'Dhaka',
              shipCountry: 'Bangladesh',
              shipName: 'Ship name 1',
              shipPostCode: '1216',
            ),
          ),
        )
        .addCustomerInfoInitializer(
          customerInfoInitializer: SSLCCustomerInfoInitializer(
            customerName: 'HM Badhon',
            customerEmail: '',
            customerAddress1: 'address',
            customerState: '',
            customerCity: '',
            customerPostCode: '1100',
            customerCountry: 'Bangladesh',
            customerPhone: '01684039512',
          ),
        )
        .addProductInitializer(
          sslcProductInitializer: SSLCProductInitializer(
            productName: "Gadgets",
            productCategory: "Widgets",
            general: General(
              general: "General Purpose",
              productProfile: "Product Profile",
            ),
          ),
        )
        .addAdditionalInitializer(
          sslcAdditionalInitializer: SSLCAdditionalInitializer(
            valueA: "app",
            valueB: "value b",
            valueC: "value c",
            valueD: "value d",
          ),
        );
    var result = await sslCommerce.payNow();
    log('ssl Result ====>' + result.toString());
    if (result is PlatformException) {
      log("the response is: " +
          result.message.toString() +
          " code: " +
          result.code.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? ''),
        ),
      );
    } else {
      SSLCTransactionInfoModel model = result;
      log("ssL json" + model.toJson().toString());
      if (model.aPIConnect == 'DONE' && model.status == 'VALID') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment success'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Failed'),
          ),
        );
      }
    }
  }
}
