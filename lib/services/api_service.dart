
class ApiService {
  final String baseUrl;
  final Map<String, String> headers;

  ApiService({
    required this.baseUrl,
    this.headers = const {
      'Content-Type': 'application/json',
    },
  });

  // Authentication methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    // This would be implemented with actual API calls in a real app
    // For now, we'll return mock data
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'token': 'mock_token',
      'user': {
        '_id': '1',
        'username': 'testuser',
        'email': email,
        'role': 'school_admin',
        'profile': {
          'firstName': 'Test',
          'lastName': 'User',
          'phoneNumber': '1234567890',
          'address': '123 Test St',
          'profilePicture': 'https://via.placeholder.com/150',
        },
        'schoolId': '1',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }
    };
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Registration successful. Please wait for admin approval.',
    };
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Password reset link sent to your email.',
    };
  }

  // User methods
  Future<Map<String, dynamic>> getUserProfile() async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      '_id': '1',
      'username': 'testuser',
      'email': 'test@example.com',
      'role': 'school_admin',
      'profile': {
        'firstName': 'Test',
        'lastName': 'User',
        'phoneNumber': '1234567890',
        'address': '123 Test St',
        'profilePicture': 'https://via.placeholder.com/150',
      },
      'schoolId': '1',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Profile updated successfully.',
    };
  }

  // School methods
  Future<List<Map<String, dynamic>>> getSchools() async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {
        '_id': '1',
        'name': 'Test School',
        'address': '123 School St',
        'contactEmail': 'school@example.com',
        'contactPhone': '1234567890',
        'logo': 'https://via.placeholder.com/150',
        'adminId': '1',
        'subscription': {
          'plan': 'premium',
          'startDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'endDate': DateTime.now().add(const Duration(days: 335)).toIso8601String(),
          'status': 'active',
        },
        'settings': {
          'theme': {'primary': '#1976D2'},
          'notifications': {'email': true, 'push': true},
          'academicYear': {
            'start': DateTime(2025, 6, 1).toIso8601String(),
            'end': DateTime(2026, 5, 31).toIso8601String(),
          },
        },
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }
    ];
  }

  // Class methods
  Future<List<Map<String, dynamic>>> getClasses(String schoolId) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {
        '_id': '1',
        'name': 'Class 10',
        'section': 'A',
        'schoolId': schoolId,
        'teacherId': '2',
        'students': ['3', '4', '5'],
        'subjects': ['1', '2', '3'],
        'schedule': [
          {
            'day': 'Monday',
            'periods': [
              {
                'subject': '1',
                'startTime': '08:00',
                'endTime': '09:00',
                'teacherId': '2',
              },
              {
                'subject': '2',
                'startTime': '09:00',
                'endTime': '10:00',
                'teacherId': '6',
              },
            ],
          },
          {
            'day': 'Tuesday',
            'periods': [
              {
                'subject': '3',
                'startTime': '08:00',
                'endTime': '09:00',
                'teacherId': '7',
              },
              {
                'subject': '1',
                'startTime': '09:00',
                'endTime': '10:00',
                'teacherId': '2',
              },
            ],
          },
        ],
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }
    ];
  }

  // Fee methods
  Future<List<Map<String, dynamic>>> getFees(String studentId) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {
        '_id': '1',
        'studentId': studentId,
        'schoolId': '1',
        'academicYear': '2025-2026',
        'feeStructure': {
          'tuitionFee': 5000.0,
          'libraryFee': 500.0,
          'transportFee': 1000.0,
          'examFee': 300.0,
          'otherFees': [
            {
              'name': 'Sports Fee',
              'amount': 200.0,
            },
            {
              'name': 'Computer Lab Fee',
              'amount': 300.0,
            },
          ],
          'totalAmount': 7300.0,
        },
        'payments': [
          {
            'amount': 3650.0,
            'paymentDate': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
            'paymentMethod': 'Credit Card',
            'transactionId': 'txn_123456',
            'status': 'completed',
            'receipt': 'https://example.com/receipts/123456',
          }
        ],
        'dueDate': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        'status': 'partial',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      }
    ];
  }

  Future<Map<String, dynamic>> makePayment(String feeId, Map<String, dynamic> paymentData) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Payment successful.',
      'receipt': 'https://example.com/receipts/123457',
    };
  }
}
