import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeeCollectionScreen extends StatefulWidget {
  const FeeCollectionScreen({Key? key}) : super(key: key);

  @override
  _FeeCollectionScreenState createState() => _FeeCollectionScreenState();
}

class _FeeCollectionScreenState extends State<FeeCollectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All';
  
  // Sample data for student fees
  final List<Map<String, dynamic>> _studentFees = [
    {
      'id': 1,
      'studentName': 'John Doe',
      'studentId': 'ST001',
      'title': 'Tuition Fee',
      'amount': 5000,
      'status': 'Pending',
      'dueDate': DateTime.now().add(const Duration(days: 10)),
      'reminderSent': false,
    },
    {
      'id': 2,
      'studentName': 'Jane Smith',
      'studentId': 'ST002',
      'title': 'Library Fee',
      'amount': 500,
      'status': 'Paid',
      'paidDate': DateTime.now().subtract(const Duration(days: 5)),
      'receiptNo': 'REC00123',
    },
    {
      'id': 3,
      'studentName': 'Mike Johnson',
      'studentId': 'ST003',
      'title': 'Technology Fee',
      'amount': 1000,
      'status': 'Overdue',
      'dueDate': DateTime.now().subtract(const Duration(days: 15)),
      'reminderSent': true,
    },
  ];
  
  // Sample data for teacher payments
  final List<Map<String, dynamic>> _teacherPayments = [
    {
      'id': 1,
      'teacherName': 'Dr. Robert Smith',
      'teacherId': 'TCH001',
      'title': 'Salary',
      'amount': 15000,
      'status': 'Pending',
      'dueDate': DateTime.now().add(const Duration(days: 3)),
    },
    {
      'id': 2,
      'teacherName': 'Prof. Sarah Williams',
      'teacherId': 'TCH002',
      'title': 'Extra Classes',
      'amount': 2000,
      'status': 'Paid',
      'paidDate': DateTime.now().subtract(const Duration(days: 2)),
      'referenceNo': 'PAY00456',
    },
  ];
  
  // Fee structure for different classes/grades
  final List<Map<String, dynamic>> _feeStructure = [
    {
      'grade': 'Grade 1',
      'tuitionFee': 4000,
      'libraryFee': 300,
      'sportsFee': 500,
      'technologyFee': 800,
      'totalFee': 5600,
    },
    {
      'grade': 'Grade 2',
      'tuitionFee': 4500,
      'libraryFee': 300,
      'sportsFee': 500,
      'technologyFee': 800,
      'totalFee': 6100,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter fees based on status and search term
  List<Map<String, dynamic>> _getFilteredStudentFees() {
    return _studentFees.where((fee) {
      bool matchesStatus = _filterStatus == 'All' || fee['status'] == _filterStatus;
      bool matchesSearch = _searchController.text.isEmpty ||
          fee['studentName'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          fee['studentId'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          fee['title'].toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  // Filter teacher payments based on status and search term
  List<Map<String, dynamic>> _getFilteredTeacherPayments() {
    return _teacherPayments.where((payment) {
      bool matchesStatus = _filterStatus == 'All' || payment['status'] == _filterStatus;
      bool matchesSearch = _searchController.text.isEmpty ||
          payment['teacherName'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          payment['teacherId'].toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  // Generate receipt for a payment
  void _generateReceipt(Map<String, dynamic> fee) {
    // In a real app, this would create a PDF or print a receipt
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Receipt'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Receipt #: ${fee['receiptNo'] ?? 'REC' + DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
              const SizedBox(height: 8),
              Text('Date: ${DateFormat('MMM dd, yyyy').format(fee['paidDate'] ?? DateTime.now())}'),
              const SizedBox(height: 8),
              Text('Student: ${fee['studentName']} (${fee['studentId']})'),
              const SizedBox(height: 8),
              Text('Fee Type: ${fee['title']}'),
              const SizedBox(height: 8),
              Text('Amount Paid: \$${fee['amount']}'),
              const SizedBox(height: 16),
              const Text('Thank you for your payment!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement share or print functionality
              Navigator.pop(context);
            },
            child: const Text('Print/Share'),
          ),
        ],
      ),
    );
  }

  // Send payment reminder
  void _sendReminder(Map<String, dynamic> fee) {
    // In a real app, this would send an email or notification
    setState(() {
      fee['reminderSent'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment reminder sent to ${fee['studentName']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Mark payment as paid
  void _markAsPaid(Map<String, dynamic> fee) {
    setState(() {
      fee['status'] = 'Paid';
      fee['paidDate'] = DateTime.now();
      fee['receiptNo'] = 'REC' + DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    });
    _generateReceipt(fee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        title: const Text('Fee Collection', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.indigo,
          tabs: const [
            Tab(text: 'Student Fees'),
            Tab(text: 'Teacher Payments'),
            Tab(text: 'Fee Structure'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add new fee or payment
              _showAddDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID or fee type',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.indigo[300]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.indigo),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _filterStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'Overdue', child: Text('Overdue')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Student Fees Tab
                _buildStudentFeesTab(),
                
                // Teacher Payments Tab
                _buildTeacherPaymentsTab(),
                
                // Fee Structure Tab
                _buildFeeStructureTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show reports or analytics
          _showReportsDialog();
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.analytics, color: Colors.white),
        tooltip: 'View Reports',
      ),
    );
  }

  Widget _buildStudentFeesTab() {
    final filteredFees = _getFilteredStudentFees();
    return filteredFees.isEmpty
        ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment_outlined, size: 70, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No fee records found.', 
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            ],
          ))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredFees.length,
            itemBuilder: (context, index) {
              final fee = filteredFees[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                child: ExpansionTile(
                  childrenPadding: EdgeInsets.zero,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    '${fee['studentName']} - ${fee['title']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text('Amount: ', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                        Text('\$${fee['amount']}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 14)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getStatusColor(fee['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            fee['status'],
                            style: TextStyle(
                              color: _getStatusColor(fee['status']),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: _getStatusIcon(fee['status']),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.badge, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('Student ID: ${fee['studentId']}', 
                                style: TextStyle(color: Colors.grey[800])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                fee['status'] == 'Paid'
                                  ? 'Paid on: ${DateFormat('MMM dd, yyyy').format(fee['paidDate'])}'
                                  : 'Due on: ${DateFormat('MMM dd, yyyy').format(fee['dueDate'])}',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (fee['status'] != 'Paid')
                                TextButton.icon(
                                  icon: Icon(
                                    Icons.notifications,
                                    color: fee['reminderSent'] == true ? Colors.grey : Colors.amber[700],
                                  ),
                                  label: Text(
                                    fee['reminderSent'] == true ? 'Reminder Sent' : 'Send Reminder',
                                    style: TextStyle(
                                      color: fee['reminderSent'] == true ? Colors.grey : Colors.amber[700],
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: fee['reminderSent'] == true
                                      ? null
                                      : () => _sendReminder(fee),
                                ),
                              const SizedBox(width: 8),
                              if (fee['status'] != 'Paid')
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.payment, size: 18),
                                  label: const Text('Mark as Paid'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () => _markAsPaid(fee),
                                )
                              else
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.receipt, size: 18),
                                  label: const Text('View Receipt'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () => _generateReceipt(fee),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildTeacherPaymentsTab() {
    final filteredPayments = _getFilteredTeacherPayments();
    return filteredPayments.isEmpty
        ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 70, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No teacher payments found.', 
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            ],
          ))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredPayments.length,
            itemBuilder: (context, index) {
              final payment = filteredPayments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                child: ExpansionTile(
                  childrenPadding: EdgeInsets.zero,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    '${payment['teacherName']} - ${payment['title']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text('Amount: ', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                        Text('\$${payment['amount']}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 14)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getStatusColor(payment['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            payment['status'],
                            style: TextStyle(
                              color: _getStatusColor(payment['status']),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: _getStatusIcon(payment['status']),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.badge, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('Teacher ID: ${payment['teacherId']}', 
                                style: TextStyle(color: Colors.grey[800])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                payment['status'] == 'Paid'
                                  ? 'Paid on: ${DateFormat('MMM dd, yyyy').format(payment['paidDate'])}'
                                  : 'Due on: ${DateFormat('MMM dd, yyyy').format(payment['dueDate'])}',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (payment['status'] != 'Paid')
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.payment, size: 18),
                                  label: const Text('Process Payment'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      payment['status'] = 'Paid';
                                      payment['paidDate'] = DateTime.now();
                                      payment['referenceNo'] = 'PAY' + DateTime.now().millisecondsSinceEpoch.toString().substring(7);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Payment processed for ${payment['teacherName']}'),
                                        backgroundColor: Colors.green[700],
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                )
                              else
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.receipt, size: 18),
                                  label: const Text('View Payment Details'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () {
                                    // Show payment details
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Payment Details', style: TextStyle(color: Colors.indigo)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Reference #: ${payment['referenceNo']}'),
                                            const SizedBox(height: 8),
                                            Text('Date: ${DateFormat('MMM dd, yyyy').format(payment['paidDate'])}'),
                                            const SizedBox(height: 8),
                                            Text('Teacher: ${payment['teacherName']}'),
                                            const SizedBox(height: 8),
                                            Text('Payment For: ${payment['title']}'),
                                            const SizedBox(height: 8),
                                            Text('Amount: \$${payment['amount']}', 
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Close', style: TextStyle(color: Colors.indigo)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildFeeStructureTab() {
    return _feeStructure.isEmpty
        ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.list_alt_outlined, size: 70, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No fee structure defined.', 
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            ],
          ))
        : Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Fee Structure'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        // Show dialog to edit fee structure
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.indigo.withOpacity(0.1)),
                        dataRowColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.grey.withOpacity(0.08);
                            }
                            return Colors.white;
                          },
                        ),
                        border: TableBorder.all(
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        columnSpacing: 24,
                        horizontalMargin: 16,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.indigo,
                          fontSize: 15,
                        ),
                        dataTextStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text('Grade/Class'),
                          ),
                          DataColumn(
                            label: Text('Tuition Fee'),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text('Library Fee'),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text('Sports Fee'),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text('Technology Fee'),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text('Total Fee'),
                            numeric: true,
                          ),
                        ],
                        rows: _feeStructure.map((fee) => DataRow(
                          cells: [
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  fee['grade'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '\$${fee['tuitionFee']}',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '\$${fee['libraryFee']}',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '\$${fee['sportsFee']}',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '\$${fee['technologyFee']}',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '\$${fee['totalFee']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }
  
  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
        );
      case 'Pending':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.watch_later, color: Colors.amber[700], size: 20),
        );
      case 'Overdue':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error, color: Colors.red, size: 20),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.info, color: Colors.blue, size: 20),
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.amber[700]!;
      case 'Overdue':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  void _showAddDialog() {
    final _currentTab = _tabController.index;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _currentTab == 0 ? 'Add New Fee' : 'Add New Teacher Payment',
          style: const TextStyle(color: Colors.indigo),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: _currentTab == 0 ? 'Student Name' : 'Teacher Name',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: _currentTab == 0 ? 'Student ID' : 'Teacher ID',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.indigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  // Show date picker
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[800],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add new fee or payment
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fee Collection Reports', style: TextStyle(color: Colors.indigo)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportTile(
                icon: Icons.summarize,
                title: 'Fee Collection Summary',
                subtitle: 'View total collections and pending amounts',
                onTap: () {
                  Navigator.pop(context);
                  // Show fee collection summary
                },
              ),
              const Divider(),
              _buildReportTile(
                icon: Icons.pending_actions,
                title: 'Pending Payments Report',
                subtitle: 'List of all pending and overdue payments',
                onTap: () {
                  Navigator.pop(context);
                  // Show pending payments
                },
              ),
              const Divider(),
              _buildReportTile(
                icon: Icons.history,
                title: 'Payment History',
                subtitle: 'Complete history of all transactions',
                onTap: () {
                  Navigator.pop(context);
                  // Show payment history
                },
              ),
              const Divider(),
              _buildReportTile(
                icon: Icons.file_download,
                title: 'Export All Data',
                subtitle: 'Download data in Excel or PDF format',
                onTap: () {
                  Navigator.pop(context);
                  // Export data functionality
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.indigo,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.indigo),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: Colors.indigo.withOpacity(0.05),
    );
  }
}
