// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/invoice_type_model.dart';
import 'package:LeLaundrette/model/paymenttype_model.dart';
import 'package:flutter/material.dart';

class AddDayBookController extends MyController {
  TextEditingController searchcontroller = TextEditingController();
  TextEditingController paidamountcontroller = TextEditingController();
  TextEditingController notescontroller = TextEditingController();
  TextEditingController deductionamountcontroller = TextEditingController();
  TextEditingController leavedayscontroller = TextEditingController();
  TextEditingController discountcontroller = TextEditingController();
  TextEditingController remarkscontroller = TextEditingController();
  TextEditingController advancecontroller = TextEditingController();

  TextEditingController quantitycontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();

  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController secondaryphonecontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController latitudecontroller = TextEditingController();
  TextEditingController longitudecontroller = TextEditingController();

  List<Map<String, dynamic>> addedRows = [];
  int nextId = 1;
  String? selectedPayment;
  String? selectedStatus;

  final TextEditingController driverController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeWorkController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController shiftingChargeController =
      TextEditingController();
  final TextEditingController driverSalaryController = TextEditingController();
  final TextEditingController driverBataController = TextEditingController();

  String selectedVehicle = '';
  String selectedDriver = '';

  void updateVehicle(String? vehicle) {
    selectedVehicle = vehicle ?? '';
    update();
  }

  void updateDriver(String? driver) {
    selectedDriver = driver ?? '';
    update();
  }

  void updatePaymentType(String? value) {
    selectedPayment = value ?? '';
    update();
  }

  void updateStatus(String? value) {
    selectedStatus = value ?? '';
    print(selectedStatus);
    update();
  }

  void reassignIDs() {
    int newId = 1;

    Map<String, String> driverIdMap = {};

    for (var item in data) {
      String driver = item['driver_name'];

      if (!driverIdMap.containsKey(driver)) {
        driverIdMap[driver] = newId.toString();
        newId++;
      }

      item['id'] = driverIdMap[driver]!;
    }

    nextId = newId;

    update();
  }


  // Voucher and branch data
  String vouchertypeid = "1";
  String branchids = "";

  late int totalpages;
  late int totalcount;

  // Main data list for items
  List<dynamic> data = [];

  // Settings and configuration
  Map<String, dynamic> companysettings = {};
  Map<String, dynamic> tax = {};
  Map<String, dynamic> currency = {};
  Map<String, dynamic> driverbalance = {};
  Map<String, dynamic> unit = {};

  // Selected values
  dynamic selectedvehicle;
  dynamic selectedcustomer;
  dynamic selectedbranch;
  dynamic selectedsalesman;
  dynamic selecteditem;
  PaymentTypeModel? selectedpaymenttype;
  InvoiceTypeModel? invoiceType;

  DateTime? voucherdate = DateTime.now();

  bool loading = false;
  bool maploading = false;

  int pagenumber = 1;
  int pagelimit = 20;

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void setPageNumber(int page) async {
    pagenumber = page;
    update();
  }

  void setVoucherDate(DateTime? value) {
    voucherdate = value;
    update();
  }

  // Customer selection methods
  void setCusotmer(dynamic value) {
    selectedcustomer = value;
    update();
  }

  void clearCustomerAddData() {
    namecontroller.clear();
    phonecontroller.clear();
    secondaryphonecontroller.clear();
    addresscontroller.clear();
    latitudecontroller.clear();
    longitudecontroller.clear();
  }

  // Branch selection
  void setBranch(dynamic value) {
    selectedbranch = value;
    update();
  }

  // Payment type selection
  void setPaymentType(PaymentTypeModel? value) {
    selectedpaymenttype = value;
    update();
  }

  // Invoice type selection
  void setInvoiceType(InvoiceTypeModel? value) {
    invoiceType = value;
    update();
  }

  // Salesman selection
  void setSalesman(dynamic value) {
    selectedsalesman = value;
    update();
  }

  // Item selection and management
  void setItem(dynamic value) {
    selecteditem = value;
    if (value != null) {
      unit = {
        'unit_id': value['unit_id'],
        'unit_name': value['unit_name'],
      };
      pricecontroller.text = value['sale_rate'].toString();
    }
    update();
  }

  void setTax(dynamic value) {
    tax = value;
    update();
  }

  // Add item to list
  void addItem() {
    if (selecteditem == null || quantitycontroller.text.isEmpty) return;

    double quantity = double.tryParse(quantitycontroller.text) ?? 0;
    double rate = double.tryParse(pricecontroller.text) ?? 0;
    double taxPercentage =
        double.tryParse(tax['tax_percentage']?.toString() ?? '0') ?? 0;
    double netAmount = rate * (1 + (taxPercentage / 100));

    // Store customer_name for grouping
    String customerName = selectedcustomer?['name']?.toString() ?? 'Unknown';

    data.add({
      'item_id': selecteditem['item_id'],
      'item_name': selecteditem['item_name'],
      'item_code': selecteditem['item_code'],
      'item_image': selecteditem['item_image'],
      'quantity': quantity.toString(),
      'rate': rate.toString(),
      'tax_type_id': tax['tax_id'],
      'tax_type_name': tax['tax_code'],
      'tax_percentage': taxPercentage.toString(),
      'unit_id': unit['unit_id'],
      'unit_name': unit['unit_name'],
      'net': netAmount.toStringAsFixed(2),
      'customer_name': customerName, // Add customer name for grouping
      'current_available_quantity': selecteditem['current_available_quantity'],
    });

    // Clear input fields
    selecteditem = null;
    quantitycontroller.clear();
    pricecontroller.clear();
    tax = {};
    unit = {};

    update();
  }

  // Remove item from list
  void removeItem(int index) {
    if (index >= 0 && index < data.length) {
      data.removeAt(index);
      update();
    }
  }

  // Calculate totals
  String calculateTotal(List<dynamic> items) {
    double total = 0;
    for (var item in items) {
      double rate = double.tryParse(item['rate']?.toString() ?? '0') ?? 0;
      double quantity =
          double.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      total += rate * quantity;
    }
    return total.toString();
  }

  String calculateTotalTax(List<dynamic> items) {
    double totalTax = 0;
    for (var item in items) {
      double rate = double.tryParse(item['rate']?.toString() ?? '0') ?? 0;
      double quantity =
          double.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      double taxPercentage =
          double.tryParse(item['tax_percentage']?.toString() ?? '0') ?? 0;
      totalTax += (rate * quantity) * (taxPercentage / 100);
    }
    return totalTax.toString();
  }

  String calculateTotalNet(List<dynamic> items) {
    double totalNet = 0;
    for (var item in items) {
      double net = double.tryParse(item['net']?.toString() ?? '0') ?? 0;
      double quantity =
          double.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      totalNet += net * quantity;
    }
    return totalNet.toString();
  }

  // Load initial data
  void loadData() async {
    try {
      setLoading(true);

      // Load company settings or other initial data if needed
      // Example:
      // companysettings = await APIService.getCompanySettings();
      // currency = await APIService.getDefaultCurrency();

      setLoading(false);
    } catch (e) {
      setLoading(false);
      print('Error loading data: $e');
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    searchcontroller.dispose();
    paidamountcontroller.dispose();
    notescontroller.dispose();
    deductionamountcontroller.dispose();
    leavedayscontroller.dispose();
    discountcontroller.dispose();
    remarkscontroller.dispose();
    advancecontroller.dispose();
    quantitycontroller.dispose();
    pricecontroller.dispose();
    namecontroller.dispose();
    phonecontroller.dispose();
    secondaryphonecontroller.dispose();
    addresscontroller.dispose();
    latitudecontroller.dispose();
    longitudecontroller.dispose();
    driverController.dispose();
    vehicleController.dispose();
    locationController.dispose();
    timeWorkController.dispose();
    amountController.dispose();
    shiftingChargeController.dispose();
    driverSalaryController.dispose();
    driverBataController.dispose();
    super.dispose();
  }
}
