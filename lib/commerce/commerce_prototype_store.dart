import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

/// Sample catalogue records for the Member 3 prototype. Replace these with
/// Firestore records during the functional project phase.
class ShopProduct {
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'icon': icon.codePoint,
    'imagePath': imagePath,
    'imageBytes': imageBytes == null ? null : base64Encode(imageBytes!),
    'downloadAssetPath': downloadAssetPath,
    'digital': digital,
    'stock': stock,
    'published': published,
  };
  factory ShopProduct.fromJson(Map<String, dynamic> json) => ShopProduct(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    category: json['category'] as String,
    icon:
        const [
          Icons.menu_book_outlined,
          Icons.auto_stories_outlined,
          Icons.style_outlined,
          Icons.groups_2_outlined,
          Icons.download_outlined,
          Icons.inventory_2_outlined,
        ].firstWhere(
          (icon) => icon.codePoint == json['icon'],
          orElse: () => Icons.inventory_2_outlined,
        ),
    imagePath: json['imagePath'] as String?,
    imageBytes: json['imageBytes'] == null
        ? null
        : base64Decode(json['imageBytes'] as String),
    downloadAssetPath: json['downloadAssetPath'] as String?,
    digital: json['digital'] as bool,
    stock: json['stock'] as int,
    published: json['published'] as bool,
  );

  const ShopProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    this.imagePath,
    this.imageBytes,
    this.downloadAssetPath,
    this.digital = false,
    this.stock = 20,
    this.published = true,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final IconData icon;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String? downloadAssetPath;
  final bool digital;
  final int stock;
  final bool published;

  ShopProduct copyWith({
    String? name,
    String? description,
    double? price,
    String? category,
    bool? digital,
    int? stock,
    bool? published,
    String? imagePath,
    Uint8List? imageBytes,
    bool clearImagePath = false,
    bool clearImageBytes = false,
    String? downloadAssetPath,
  }) => ShopProduct(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    category: category ?? this.category,
    icon: icon,
    imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
    imageBytes: clearImageBytes ? null : imageBytes ?? this.imageBytes,
    downloadAssetPath: digital == false
        ? null
        : downloadAssetPath ?? this.downloadAssetPath,
    digital: digital ?? this.digital,
    stock: stock ?? this.stock,
    published: published ?? this.published,
  );
}

class CartLine {
  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };
  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    product: ShopProduct.fromJson(
      Map<String, dynamic>.from(json['product'] as Map),
    ),
    quantity: json['quantity'] as int,
  );

  const CartLine({required this.product, required this.quantity});
  final ShopProduct product;
  final int quantity;
  double get subtotal => product.price * quantity;
}

class ShopOrder {
  Map<String, dynamic> toJson() => {
    'number': number,
    'date': date.toIso8601String(),
    'lines': lines.map((e) => e.toJson()).toList(),
    'total': total,
    'paymentStatus': paymentStatus,
    'paymentMethod': paymentMethod,
    'fulfilmentStatus': fulfilmentStatus,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'customerPhone': customerPhone,
    'billingAddress': billingAddress,
    'shippingAddress': shippingAddress,
    'trackingNumber': trackingNumber,
    'stockReserved': stockReserved,
  };
  factory ShopOrder.fromJson(Map<String, dynamic> json) => ShopOrder(
    number: json['number'] as String,
    date: DateTime.parse(json['date'] as String),
    lines: (json['lines'] as List)
        .map((e) => CartLine.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    total: (json['total'] as num).toDouble(),
    paymentStatus: json['paymentStatus'] as String,
    paymentMethod: json['paymentMethod'] as String,
    fulfilmentStatus: json['fulfilmentStatus'] as String,
    customerName: json['customerName'] as String,
    customerEmail: json['customerEmail'] as String,
    customerPhone: json['customerPhone'] as String,
    billingAddress: json['billingAddress'] as String?,
    shippingAddress: json['shippingAddress'] as String?,
    trackingNumber: json['trackingNumber'] as String?,
    stockReserved: json['stockReserved'] as bool,
  );

  const ShopOrder({
    required this.number,
    required this.date,
    required this.lines,
    required this.total,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.fulfilmentStatus,
    required this.customerName,
    this.customerEmail = '',
    this.customerPhone = '',
    this.billingAddress,
    this.shippingAddress,
    this.trackingNumber,
    this.stockReserved = false,
  });

  final String number;
  final DateTime date;
  final List<CartLine> lines;
  final double total;
  final String paymentStatus;
  final String paymentMethod;
  final String fulfilmentStatus;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? billingAddress;
  final String? shippingAddress;
  final String? trackingNumber;
  final bool stockReserved;
  bool get hasDigital => lines.any((line) => line.product.digital);
  bool get hasPhysical => lines.any((line) => !line.product.digital);
}

class QuoteRequest {
  Map<String, dynamic> toJson() => {
    'reference': reference,
    'createdAt': createdAt.toIso8601String(),
    'customerName': customerName,
    'organizationName': organizationName,
    'email': email,
    'phone': phone,
    'lines': lines.map((e) => e.toJson()).toList(),
    'requirements': requirements,
    'status': status,
    'quotedTotal': quotedTotal,
    'adminNote': adminNote,
  };
  factory QuoteRequest.fromJson(Map<String, dynamic> json) => QuoteRequest(
    reference: json['reference'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    customerName: json['customerName'] as String,
    organizationName: json['organizationName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    lines: (json['lines'] as List)
        .map((e) => CartLine.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    requirements: json['requirements'] as String,
    status: json['status'] as String,
    quotedTotal: (json['quotedTotal'] as num?)?.toDouble(),
    adminNote: json['adminNote'] as String?,
  );

  const QuoteRequest({
    required this.reference,
    required this.createdAt,
    required this.customerName,
    required this.organizationName,
    required this.email,
    required this.phone,
    required this.lines,
    required this.requirements,
    this.status = 'New',
    this.quotedTotal,
    this.adminNote,
  });

  final String reference;
  final DateTime createdAt;
  final String customerName;
  final String organizationName;
  final String email;
  final String phone;
  final List<CartLine> lines;
  final String requirements;
  final String status;
  final double? quotedTotal;
  final String? adminNote;

  QuoteRequest copyWith({
    String? status,
    double? quotedTotal,
    String? adminNote,
  }) => QuoteRequest(
    reference: reference,
    createdAt: createdAt,
    customerName: customerName,
    organizationName: organizationName,
    email: email,
    phone: phone,
    lines: lines,
    requirements: requirements,
    status: status ?? this.status,
    quotedTotal: quotedTotal ?? this.quotedTotal,
    adminNote: adminNote ?? this.adminNote,
  );
}

class ContactEnquiry {
  Map<String, dynamic> toJson() => {
    'reference': reference,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'email': email,
    'phone': phone,
    'enquiryType': enquiryType,
    'message': message,
    'organization': organization,
    'status': status,
    'adminNote': adminNote,
  };
  factory ContactEnquiry.fromJson(Map<String, dynamic> json) => ContactEnquiry(
    reference: json['reference'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    enquiryType: json['enquiryType'] as String,
    message: json['message'] as String,
    organization: json['organization'] as String,
    status: json['status'] as String,
    adminNote: json['adminNote'] as String?,
  );

  const ContactEnquiry({
    required this.reference,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.phone,
    required this.enquiryType,
    required this.message,
    this.organization = '',
    this.status = 'New',
    this.adminNote,
  });

  final String reference;
  final DateTime createdAt;
  final String name;
  final String email;
  final String phone;
  final String organization;
  final String enquiryType;
  final String message;
  final String status;
  final String? adminNote;

  ContactEnquiry copyWith({String? status, String? adminNote}) =>
      ContactEnquiry(
        reference: reference,
        createdAt: createdAt,
        name: name,
        email: email,
        phone: phone,
        organization: organization,
        enquiryType: enquiryType,
        message: message,
        status: status ?? this.status,
        adminNote: adminNote ?? this.adminNote,
      );
}

class CommercePrototypeStore extends ChangeNotifier {
  CommercePrototypeStore._();
  static final CommercePrototypeStore instance = CommercePrototypeStore._();

  SharedPreferences? _preferences;
  Future<void> _pendingSave = Future.value();
  String? storageError;
  bool _loading = false;

  Future<void> load() async {
    _loading = true;
    try {
      _preferences = await SharedPreferences.getInstance();
      final raw = _preferences!.getString('alchemy_commerce_v1');
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final products = (data['_products'] as List)
            .map(
              (e) => ShopProduct.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        final orders = (data['_orders'] as List)
            .map((e) => ShopOrder.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final quoteRequests = (data['_quoteRequests'] as List)
            .map(
              (e) => QuoteRequest.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        final contactEnquiries = (data['_contactEnquiries'] as List)
            .map(
              (e) =>
                  ContactEnquiry.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        final cart = Map<String, int>.from(data['_cart'] as Map);
        final employees = (data['_employees'] as List)
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
        final assignments = (data['_assignments'] as List)
            .map((e) => Map<String, Object>.from(e as Map))
            .toList();
        _products
          ..clear()
          ..addAll(products);
        _orders
          ..clear()
          ..addAll(orders);
        _quoteRequests
          ..clear()
          ..addAll(quoteRequests);
        _contactEnquiries
          ..clear()
          ..addAll(contactEnquiries);
        _cart
          ..clear()
          ..addAll(cart);
        _employees
          ..clear()
          ..addAll(employees);
        _assignments
          ..clear()
          ..addAll(assignments);
      }
      storageError = null;
    } catch (_) {
      storageError =
          'Saved prototype data could not be loaded. Check device storage before making changes.';
    } finally {
      _loading = false;
    }
  }

  Future<void> flush() => _pendingSave;

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_loading || _preferences == null) return;
    final snapshot = jsonEncode({
      '_products': _products.map((e) => e.toJson()).toList(),
      '_orders': _orders.map((e) => e.toJson()).toList(),
      '_quoteRequests': _quoteRequests.map((e) => e.toJson()).toList(),
      '_contactEnquiries': _contactEnquiries.map((e) => e.toJson()).toList(),
      '_cart': _cart,
      '_employees': _employees,
      '_assignments': _assignments,
    });
    _pendingSave = _pendingSave.then((_) async {
      try {
        final saved = await _preferences!.setString(
          'alchemy_commerce_v1',
          snapshot,
        );
        storageError = saved
            ? null
            : 'Changes could not be saved on this device.';
      } catch (_) {
        storageError = 'Changes could not be saved on this device.';
      }
      super.notifyListeners();
    });
  }

  static const _starterProducts = <ShopProduct>[
    ShopProduct(
      id: 'clarity-workbook',
      name: 'Emotional Clarity Workbook',
      description:
          'A guided digital workbook with reflection prompts for emotional awareness and deliberate responses.',
      price: 29,
      category: 'Digital',
      icon: Icons.menu_book_outlined,
      digital: true,
      downloadAssetPath: 'assets/downloads/emotional_clarity_workbook.txt',
    ),
    ShopProduct(
      id: 'mindful-journal',
      name: 'Mindful Reflection Journal',
      description:
          'A printed journal designed to help individuals build a steady reflection practice.',
      price: 48,
      category: 'Physical',
      icon: Icons.auto_stories_outlined,
      imagePath: 'assets/images/impact_teachers_retreat.jpeg',
      stock: 35,
    ),
    ShopProduct(
      id: 'conversation-cards',
      name: 'Conversation Prompt Cards',
      description:
          'A physical set of prompts for connection and constructive team dialogue.',
      price: 65,
      category: 'Physical',
      icon: Icons.style_outlined,
      imagePath: 'assets/images/workshop_group_discussion.jpeg',
      stock: 18,
    ),
    ShopProduct(
      id: 'team-learning-kit',
      name: 'Team Learning Kit',
      description:
          'A practical activity kit for facilitated team learning and shared reflection.',
      price: 120,
      category: 'Physical',
      icon: Icons.groups_2_outlined,
      imagePath: 'assets/images/workshop_team_creativity.jpeg',
      stock: 12,
    ),
    ShopProduct(
      id: 'facilitator-guide',
      name: 'Facilitator Reflection Guide',
      description:
          'A downloadable guide with session planning notes and debrief questions.',
      price: 39,
      category: 'Digital',
      icon: Icons.description_outlined,
      digital: true,
      downloadAssetPath: 'assets/downloads/facilitator_reflection_guide.txt',
    ),
  ];
  static const _starterEmployees = <Map<String, String>>[
    {
      'name': 'Alicia Wong',
      'department': 'Human Resources',
      'email': 'alicia@example.com',
      'status': 'Active',
    },
    {
      'name': 'Daniel Lee',
      'department': 'Finance',
      'email': 'daniel@example.com',
      'status': 'Active',
    },
    {
      'name': 'Farah Nordin',
      'department': 'Management',
      'email': 'farah@example.com',
      'status': 'Active',
    },
  ];
  static const _starterAssignments = <Map<String, Object>>[
    {
      'course': 'Emotional Intelligence Fundamentals',
      'team': 'Human Resources',
      'employee': 'alicia@example.com',
      'due': '30 Oct 2026',
      'progress': 68,
      'score': 82,
      'hours': 12,
    },
    {
      'course': 'Leadership Essentials',
      'team': 'Management',
      'employee': 'farah@example.com',
      'due': '14 Nov 2026',
      'progress': 42,
      'score': 76,
      'hours': 8,
    },
  ];
  final List<ShopProduct> _products = List.of(_starterProducts);
  final Map<String, int> _cart = {};
  final List<ShopOrder> _orders = [];
  final List<QuoteRequest> _quoteRequests = [];
  final List<ContactEnquiry> _contactEnquiries = [];
  final List<Map<String, String>> _employees = _starterEmployees
      .map(Map<String, String>.of)
      .toList();
  final List<Map<String, Object>> _assignments = _starterAssignments
      .map(Map<String, Object>.of)
      .toList();

  List<ShopProduct> get products => List.unmodifiable(_products);
  List<ShopProduct> get publishedProducts =>
      _products.where((product) => product.published).toList();
  List<ShopOrder> get orders => List.unmodifiable(_orders);
  List<QuoteRequest> get quoteRequests => List.unmodifiable(_quoteRequests);
  List<ContactEnquiry> get contactEnquiries =>
      List.unmodifiable(_contactEnquiries);
  List<QuoteRequest> quoteRequestsFor(String email) => List.unmodifiable(
    _quoteRequests.where(
      (quote) => quote.email.toLowerCase() == email.toLowerCase(),
    ),
  );
  List<ShopOrder> ordersFor(String email) => List.unmodifiable(
    _orders.where(
      (order) => order.customerEmail.toLowerCase() == email.toLowerCase(),
    ),
  );
  List<String> assignedCoursesFor(String email) => _assignments
      .where(
        (a) => (a['employee'] as String).toLowerCase() == email.toLowerCase(),
      )
      .map((a) => a['course'] as String)
      .toList();

  void updateLearningProgress(
    String email,
    String course,
    int progress, {
    int? score,
  }) {
    var changed = false;
    for (final assignment in _assignments) {
      if ((assignment['employee'] as String).toLowerCase() ==
              email.toLowerCase() &&
          assignment['course'] == course) {
        assignment['progress'] = progress;
        if (score != null) assignment['score'] = score;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  String? activeEmployer;
  bool _belongsToEmployer(Map record) =>
      (record['organization'] ?? 'employer@mtalchemy.demo') == activeEmployer;
  List<Map<String, String>> get employees =>
      List.unmodifiable(_employees.where(_belongsToEmployer));
  List<Map<String, Object>> get assignments =>
      List.unmodifiable(_assignments.where(_belongsToEmployer));
  int get cartCount => _cart.values.fold(0, (sum, quantity) => sum + quantity);
  int cartQuantityFor(String id) => _cart[id] ?? 0;
  bool canAddToCart(String id) {
    final product = productById(id);
    return product != null &&
        product.published &&
        (product.digital || cartQuantityFor(id) < product.stock);
  }

  List<CartLine> get cartLines => _cart.entries
      .map((entry) {
        final product = productById(entry.key);
        return product == null
            ? null
            : CartLine(product: product, quantity: entry.value);
      })
      .whereType<CartLine>()
      .toList();
  double get subtotal => cartLines.fold(0, (sum, line) => sum + line.subtotal);
  bool get cartHasPhysical => cartLines.any((line) => !line.product.digital);
  double get shipping => cartHasPhysical && cartLines.isNotEmpty ? 10 : 0;
  double get total => subtotal + shipping;
  List<ShopOrder> get digitalOrders => _orders
      .where((order) => order.hasDigital && order.paymentStatus == 'Paid')
      .toList();
  List<ShopOrder> digitalOrdersFor(String email) => _orders
      .where(
        (order) =>
            order.customerEmail.toLowerCase() == email.toLowerCase() &&
            order.hasDigital &&
            order.paymentStatus == 'Paid',
      )
      .toList();

  ShopOrder? orderByNumber(String? number) {
    for (final order in _orders) {
      if (order.number == number) return order;
    }
    return null;
  }

  ShopProduct? productById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  QuoteRequest createQuoteRequest({
    required String customerName,
    required String organizationName,
    required String email,
    required String phone,
    required List<CartLine> lines,
    required String requirements,
  }) {
    final quote = QuoteRequest(
      reference:
          'QT${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      createdAt: DateTime.now(),
      customerName: customerName,
      organizationName: organizationName,
      email: email,
      phone: phone,
      lines: List.unmodifiable(lines),
      requirements: requirements,
    );
    _quoteRequests.insert(0, quote);
    notifyListeners();
    return quote;
  }

  void updateQuoteRequest(
    String reference, {
    required String status,
    double? quotedTotal,
    String? adminNote,
  }) {
    final index = _quoteRequests.indexWhere(
      (quote) => quote.reference == reference,
    );
    if (index < 0) return;
    _quoteRequests[index] = _quoteRequests[index].copyWith(
      status: status,
      quotedTotal: quotedTotal,
      adminNote: adminNote,
    );
    notifyListeners();
  }

  ContactEnquiry createContactEnquiry({
    required String name,
    required String email,
    required String phone,
    required String organization,
    required String enquiryType,
    required String message,
  }) {
    final now = DateTime.now();
    final enquiry = ContactEnquiry(
      reference: 'EN${now.millisecondsSinceEpoch.toString().substring(5)}',
      createdAt: now,
      name: name,
      email: email,
      phone: phone,
      organization: organization,
      enquiryType: enquiryType,
      message: message,
    );
    _contactEnquiries.insert(0, enquiry);
    notifyListeners();
    return enquiry;
  }

  void updateContactEnquiry(
    String reference, {
    required String status,
    String? adminNote,
  }) {
    final index = _contactEnquiries.indexWhere(
      (enquiry) => enquiry.reference == reference,
    );
    if (index < 0) return;
    _contactEnquiries[index] = _contactEnquiries[index].copyWith(
      status: status,
      adminNote: adminNote,
    );
    notifyListeners();
  }

  void addToCart(String id) {
    final product = productById(id);
    if (!canAddToCart(id) || product == null) return;
    final count = _cart[id] ?? 0;
    if (!product.digital && count >= product.stock) return;
    _cart[id] = count + 1;
    notifyListeners();
  }

  void setQuantity(String id, int quantity) {
    if (quantity <= 0) {
      _cart.remove(id);
    } else {
      final product = productById(id);
      if (product == null) return;
      if (!product.digital && product.stock <= 0) {
        _cart.remove(id);
      } else {
        _cart[id] = product.digital
            ? quantity
            : quantity.clamp(1, product.stock).toInt();
      }
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _cart.remove(id);
    notifyListeners();
  }

  ShopOrder? placeOrder({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String billingAddress,
    required String address,
    required String paymentMethod,
  }) {
    final lines = cartLines;
    if (lines.isEmpty) return null;
    if (lines.any(
      (line) =>
          !line.product.published ||
          (!line.product.digital && line.quantity > line.product.stock),
    )) {
      return null;
    }
    final order = ShopOrder(
      number: 'MA${DateTime.now().microsecondsSinceEpoch}',
      date: DateTime.now(),
      lines: List.unmodifiable(lines),
      total: total,
      paymentStatus: 'Pending',
      paymentMethod: paymentMethod,
      fulfilmentStatus: cartHasPhysical
          ? 'Pending'
          : lines.any((line) => line.product.digital)
          ? 'Pending'
          : 'Available',
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      billingAddress: billingAddress,
      shippingAddress: cartHasPhysical ? address : null,
      stockReserved: cartHasPhysical,
    );
    for (final line in lines.where((line) => !line.product.digital)) {
      final index = _products.indexWhere(
        (product) => product.id == line.product.id,
      );
      if (index >= 0) {
        _products[index] = _products[index].copyWith(
          stock: _products[index].stock - line.quantity,
        );
      }
    }
    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
    return order;
  }

  void addEmployee({
    required String name,
    required String department,
    required String email,
  }) {
    if (activeEmployer == null ||
        employees.any(
          (e) => e['email']!.toLowerCase() == email.trim().toLowerCase(),
        )) {
      return;
    }
    _employees.add({
      'organization': activeEmployer!,
      'name': name,
      'department': department,
      'email': email,
      'status': 'Invited',
    });
    notifyListeners();
  }

  void removeEmployee(String email) {
    _employees.removeWhere(
      (employee) => employee['email'] == email && _belongsToEmployer(employee),
    );
    _assignments.removeWhere(
      (assignment) =>
          assignment['employee'] == email && _belongsToEmployer(assignment),
    );
    notifyListeners();
  }

  void assignCourse({
    required String course,
    required String team,
    required String due,
    required String employeeEmail,
  }) {
    if (activeEmployer == null ||
        !employees.any((e) => e['email'] == employeeEmail)) {
      return;
    }
    if (assignments.any(
      (a) => a['employee'] == employeeEmail && a['course'] == course,
    )) {
      return;
    }
    _assignments.insert(0, {
      'organization': activeEmployer!,
      'course': course,
      'team': team,
      'due': due,
      'employee': employeeEmail,
      'progress': 0,
      'score': 0,
      'hours': 0,
    });
    notifyListeners();
  }

  void toggleProductPublished(String id) {
    final index = _products.indexWhere((product) => product.id == id);
    if (index < 0) return;
    _products[index] = _products[index].copyWith(
      published: !_products[index].published,
    );
    if (!_products[index].published) _cart.remove(id);
    notifyListeners();
  }

  void adjustStock(String id, int amount) {
    final index = _products.indexWhere((product) => product.id == id);
    if (index < 0 || _products[index].digital) return;
    _products[index] = _products[index].copyWith(
      stock: (_products[index].stock + amount).clamp(0, 9999).toInt(),
    );
    notifyListeners();
  }

  void addProduct({
    required String name,
    required double price,
    required bool digital,
    String? imagePath,
    Uint8List? imageBytes,
    String? downloadAssetPath,
    String? description,
    int stock = 10,
  }) {
    _products.add(
      ShopProduct(
        id: 'product-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description:
            description ??
            'A new ${digital ? 'digital' : 'physical'} MT Alchemy product.',
        price: price,
        category: digital ? 'Digital' : 'Physical',
        icon: digital ? Icons.download_outlined : Icons.inventory_2_outlined,
        imagePath: imagePath,
        imageBytes: imageBytes,
        downloadAssetPath: digital ? downloadAssetPath : null,
        digital: digital,
        stock: digital ? 0 : stock,
      ),
    );
    notifyListeners();
  }

  void updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required bool digital,
    required String imagePath,
    Uint8List? imageBytes,
    required String? downloadAssetPath,
    required int stock,
  }) {
    final index = _products.indexWhere((product) => product.id == id);
    if (index < 0) return;
    final current = _products[index];
    _products[index] = current.copyWith(
      name: name,
      description: description,
      price: price,
      category: digital ? 'Digital' : 'Physical',
      digital: digital,
      imagePath: imagePath,
      imageBytes: imageBytes,
      clearImagePath: imagePath.isEmpty,
      clearImageBytes: imageBytes == null,
      downloadAssetPath: downloadAssetPath,
      stock: digital ? 0 : stock,
    );
    notifyListeners();
  }

  void deleteProduct(String id) {
    _products.removeWhere((product) => product.id == id);
    _cart.remove(id);
    notifyListeners();
  }

  void resetDemoData() {
    _products
      ..clear()
      ..addAll(_starterProducts);
    _cart.clear();
    _orders.clear();
    _quoteRequests.clear();
    _contactEnquiries.clear();
    _employees
      ..clear()
      ..addAll(_starterEmployees.map(Map<String, String>.of));
    _assignments
      ..clear()
      ..addAll(_starterAssignments.map(Map<String, Object>.of));
    notifyListeners();
  }

  void updateOrderStatus(String number, String status) {
    final index = _orders.indexWhere((order) => order.number == number);
    if (index < 0) return;
    final previous = _orders[index];
    if (previous.hasPhysical) {
      final allowed = switch (previous.fulfilmentStatus) {
        'Pending' => {'Pending', 'Processing'},
        'Processing' => {'Processing', 'Shipped'},
        'Shipped' => {'Shipped', 'Delivered'},
        'Delivered' => {'Delivered'},
        _ => <String>{},
      };
      if (previous.paymentStatus != 'Paid' && status != 'Pending') return;
      if (!allowed.contains(status)) return;
    } else if (status != 'Pending' && status != 'Available') {
      return;
    }
    _orders[index] = ShopOrder(
      number: previous.number,
      date: previous.date,
      lines: previous.lines,
      total: previous.total,
      paymentStatus: previous.paymentStatus,
      paymentMethod: previous.paymentMethod,
      fulfilmentStatus: status,
      customerName: previous.customerName,
      customerEmail: previous.customerEmail,
      customerPhone: previous.customerPhone,
      billingAddress: previous.billingAddress,
      shippingAddress: previous.shippingAddress,
      trackingNumber: status == 'Shipped'
          ? 'MT-${number.substring(number.length - 6)}'
          : previous.trackingNumber,
      stockReserved: previous.stockReserved,
    );
    notifyListeners();
  }

  bool updatePaymentStatus(String number, String status) {
    final index = _orders.indexWhere((order) => order.number == number);
    if (index < 0) return false;
    final previous = _orders[index];
    // A paid order cannot be downgraded in this prototype: refunds and
    // post-dispatch stock adjustments require a real payment/fulfilment flow.
    if (previous.paymentStatus == 'Paid' && status != 'Paid') return false;
    if (!{'Pending', 'Paid', 'Failed'}.contains(status)) return false;
    var stockReserved = previous.stockReserved;
    if (previous.hasPhysical && status == 'Failed' && stockReserved) {
      for (final line in previous.lines.where(
        (line) => !line.product.digital,
      )) {
        final productIndex = _products.indexWhere(
          (product) => product.id == line.product.id,
        );
        if (productIndex >= 0) {
          _products[productIndex] = _products[productIndex].copyWith(
            stock: _products[productIndex].stock + line.quantity,
          );
        }
      }
      stockReserved = false;
    } else if (previous.hasPhysical && status != 'Failed' && !stockReserved) {
      final physicalLines = previous.lines
          .where((line) => !line.product.digital)
          .toList();
      final canReserve = physicalLines.every((line) {
        final product = productById(line.product.id);
        return product != null && product.stock >= line.quantity;
      });
      if (!canReserve) {
        // Rebuild dropdowns from the persisted status after a rejected change.
        notifyListeners();
        return false;
      }
      for (final line in physicalLines) {
        final productIndex = _products.indexWhere(
          (product) => product.id == line.product.id,
        );
        if (productIndex >= 0) {
          _products[productIndex] = _products[productIndex].copyWith(
            stock: _products[productIndex].stock - line.quantity,
          );
        }
      }
      stockReserved = true;
    }
    final nextFulfilment = status == 'Paid'
        ? previous.paymentStatus == 'Paid'
              ? previous.fulfilmentStatus
              : previous.hasPhysical
              ? 'Processing'
              : 'Available'
        : status == 'Failed'
        ? 'Pending'
        : previous.fulfilmentStatus;
    _orders[index] = ShopOrder(
      number: previous.number,
      date: previous.date,
      lines: previous.lines,
      total: previous.total,
      paymentStatus: status,
      paymentMethod: previous.paymentMethod,
      fulfilmentStatus: nextFulfilment,
      customerName: previous.customerName,
      customerEmail: previous.customerEmail,
      customerPhone: previous.customerPhone,
      billingAddress: previous.billingAddress,
      shippingAddress: previous.shippingAddress,
      trackingNumber: previous.trackingNumber,
      stockReserved: stockReserved,
    );
    notifyListeners();
    return true;
  }
}

String money(double value) => 'RM ${value.toStringAsFixed(2)}';
