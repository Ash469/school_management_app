class Fee {
  final String id;
  final String studentId;
  final String schoolId;
  final String academicYear;
  final FeeStructure feeStructure;
  final List<Payment> payments;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Fee({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.academicYear,
    required this.feeStructure,
    required this.payments,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['_id'],
      studentId: json['studentId'],
      schoolId: json['schoolId'],
      academicYear: json['academicYear'],
      feeStructure: FeeStructure.fromJson(json['feeStructure']),
      payments: (json['payments'] as List).map((e) => Payment.fromJson(e)).toList(),
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentId': studentId,
      'schoolId': schoolId,
      'academicYear': academicYear,
      'feeStructure': feeStructure.toJson(),
      'payments': payments.map((e) => e.toJson()).toList(),
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FeeStructure {
  final double tuitionFee;
  final double libraryFee;
  final double transportFee;
  final double examFee;
  final List<OtherFee> otherFees;
  final double totalAmount;

  FeeStructure({
    required this.tuitionFee,
    required this.libraryFee,
    required this.transportFee,
    required this.examFee,
    required this.otherFees,
    required this.totalAmount,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) {
    return FeeStructure(
      tuitionFee: json['tuitionFee'].toDouble(),
      libraryFee: json['libraryFee'].toDouble(),
      transportFee: json['transportFee'].toDouble(),
      examFee: json['examFee'].toDouble(),
      otherFees: (json['otherFees'] as List).map((e) => OtherFee.fromJson(e)).toList(),
      totalAmount: json['totalAmount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tuitionFee': tuitionFee,
      'libraryFee': libraryFee,
      'transportFee': transportFee,
      'examFee': examFee,
      'otherFees': otherFees.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }
}

class OtherFee {
  final String name;
  final double amount;

  OtherFee({
    required this.name,
    required this.amount,
  });

  factory OtherFee.fromJson(Map<String, dynamic> json) {
    return OtherFee(
      name: json['name'],
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}

class Payment {
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final String receipt;

  Payment({
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.receipt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      amount: json['amount'].toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      status: json['status'],
      receipt: json['receipt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status,
      'receipt': receipt,
    };
  }
}
