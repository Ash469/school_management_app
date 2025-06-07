import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../services/class_services.dart';
import '../../utils/storage_util.dart'; // Make sure this is imported

class ClassManagementScreen extends StatefulWidget {
  final User user;
  
  const ClassManagementScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ClassManagementScreenState createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  // Replace dummy data with API data
  List<Map<String, dynamic>> _classes = [];
  
  // Add filter related properties
  List<Map<String, dynamic>> _filteredClasses = [];
  Map<String, bool> _activeFilters = {
    'class10': false,
    'class9': false,
    'class8': false,
    'mathSubject': false,
    'scienceSubject': false,
  };
  String _searchQuery = '';

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Initialize the class service
  late ClassService _classService;
  
  // Theme colors from app_theme.dart
  late Color _primaryColor;
  late Color _accentColor;
  late Color _tertiaryColor;
  late List<Color> _gradientColors;
  late List<Color> _cardColors;

  @override
  void initState() {
    super.initState();
    _loadThemeColors();
    _classService = ClassService(baseUrl: 'http://localhost:3000');
    _loadClasses();
  }

  void _loadThemeColors() {
    _primaryColor = AppTheme.getPrimaryColor(AppTheme.defaultTheme);
    _accentColor = AppTheme.getAccentColor(AppTheme.defaultTheme);
    _tertiaryColor = AppTheme.getTertiaryColor(AppTheme.defaultTheme);
    _gradientColors = AppTheme.getGradientColors(AppTheme.defaultTheme);
    _cardColors = [
      const Color(0xFFE3F2FD), // Vibrant blue shade
      const Color(0xFFE0F2F1), // Vibrant teal shade
      const Color(0xFFFFF8E1), // Vibrant amber shade
      const Color(0xFFF3E5F5), // Vibrant purple shade
    ];
  }

  // Load classes from API
  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Access values directly from StorageUtil memory cache
      final token = await StorageUtil.getString('accessToken');
      final schoolToken = await StorageUtil.getString('schoolToken');
      final schoolId = await StorageUtil.getString('schoolId');
      
      print('DEBUG - Token from StorageUtil: ${token != null ? "Found" : "Not found"}');
      print('DEBUG - SchoolToken from StorageUtil: ${schoolToken != null ? "Found" : "Not found"}');
      print('DEBUG - School ID from StorageUtil: ${schoolId ?? "Not found"}');
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found. Please log in again.');
      }
      
      // No need to set SharedPreferences, just use the ClassService directly
      final classes = await _classService.getAllClasses();
      setState(() {
        _classes = classes;
        _filteredClasses = List.from(classes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load classes: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadClasses,
            textColor: Colors.white,
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  // Refresh classes data
  Future<void> _refreshClasses() async {
    await _loadClasses();
    _filterClasses();
  }

  // Filter classes based on current filter settings
  void _filterClasses() {
    setState(() {
      _filteredClasses = _classes.where((classData) {
        // If no filters are active, show all classes
        if (!_activeFilters.values.contains(true) && _searchQuery.isEmpty) {
          return true;
        }

        final className = classData['name'] as String;
        final subjects = classData['subjects'] as List<String>;
        
        bool matchesClassFilter = true;
        bool matchesSubjectFilter = true;
        bool matchesSearchQuery = true;
        
        // Check class name filters
        if (_activeFilters['class10'] == true || 
            _activeFilters['class9'] == true || 
            _activeFilters['class8'] == true) {
          matchesClassFilter = 
            (_activeFilters['class10'] == true && className.contains('10')) ||
            (_activeFilters['class9'] == true && className.contains('9')) ||
            (_activeFilters['class8'] == true && className.contains('8'));
        }

        // Check subjects filters
        if (_activeFilters['mathSubject'] == true || _activeFilters['scienceSubject'] == true) {
          matchesSubjectFilter = 
            (_activeFilters['mathSubject'] == true && 
              subjects.any((subject) => subject.toLowerCase().contains('math'))) ||
            (_activeFilters['scienceSubject'] == true && 
              subjects.any((subject) => subject.toLowerCase().contains('science') || 
                                         subject.toLowerCase().contains('physics') || 
                                         subject.toLowerCase().contains('chemistry') || 
                                         subject.toLowerCase().contains('biology')));
        }

        // Check search query
        if (_searchQuery.isNotEmpty) {
          matchesSearchQuery = 
            className.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (classData['classTeacher'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
            subjects.any((subject) => subject.toLowerCase().contains(_searchQuery.toLowerCase()));
        }

        return matchesClassFilter && matchesSubjectFilter && matchesSearchQuery;
      }).toList();
    });
  }

  void _showFilterDialog() {
    // Create a temporary copy of active filters that we can modify in the dialog
    final tempFilters = Map<String, bool>.from(_activeFilters);
    final searchController = TextEditingController(text: _searchQuery);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and title
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_accentColor, _accentColor.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _accentColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Filter Classes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search field
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search classes, teachers, subjects...',
                        prefixIcon: Icon(Icons.search, color: _accentColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  
                  // Filter sections scrollable content
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Class filters section
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade50,
                                  Colors.blue.shade100.withOpacity(0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.school, color: Colors.blue.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Filter by Class',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildFilterChip(
                                      'Class 10', 
                                      tempFilters['class10'] ?? false,
                                      (value) => setState(() => tempFilters['class10'] = value),
                                      Colors.blue,
                                    ),
                                    _buildFilterChip(
                                      'Class 9', 
                                      tempFilters['class9'] ?? false,
                                      (value) => setState(() => tempFilters['class9'] = value),
                                      Colors.blue,
                                    ),
                                    _buildFilterChip(
                                      'Class 8', 
                                      tempFilters['class8'] ?? false,
                                      (value) => setState(() => tempFilters['class8'] = value),
                                      Colors.blue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Subject filters section
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade50,
                                  Colors.green.shade100.withOpacity(0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.book, color: Colors.green.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Filter by Subject',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildFilterChip(
                                      'Mathematics', 
                                      tempFilters['mathSubject'] ?? false,
                                      (value) => setState(() => tempFilters['mathSubject'] = value),
                                      Colors.green,
                                    ),
                                    _buildFilterChip(
                                      'Science', 
                                      tempFilters['scienceSubject'] ?? false,
                                      (value) => setState(() => tempFilters['scienceSubject'] = value),
                                      Colors.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Actions row
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear All'),
                          onPressed: () {
                            setState(() {
                              tempFilters.updateAll((key, value) => false);
                              searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Apply Filters'),
                          onPressed: () {
                            // Apply the filter changes
                            _activeFilters = tempFilters;
                            _searchQuery = searchController.text;
                            _filterClasses();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to create consistent filter chips
  Widget _buildFilterChip(String label, bool selected, Function(bool) onSelected, Color color) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: color.withOpacity(0.15),
      checkmarkColor: color.withOpacity(0.8), // Using darker version of the same color
      labelStyle: TextStyle(
        color:  Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color:  Colors.grey.shade300),
      elevation: 1,
      shadowColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Management', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )
        ),
        backgroundColor: _primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshClasses,
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications'))
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _accentColor))
          : _hasError 
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _refreshClasses,
                  color: _primaryColor,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade100],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Classes',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_activeFilters.values.contains(true) || _searchQuery.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_filteredClasses.length}/${_classes.length}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              icon: Icon(Icons.filter_list, color: _accentColor),
                              label: Text(
                                _activeFilters.values.contains(true) ? 'Filters Applied' : 'Filter', 
                                style: TextStyle(color: _accentColor)
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: _accentColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: _activeFilters.values.contains(true) 
                                  ? _accentColor.withOpacity(0.1) 
                                  : Colors.transparent,
                              ),
                              onPressed: _showFilterDialog,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _classes.isEmpty 
                          ? _buildEmptyView() 
                          : _buildClassList(),
                      ),
                    ],
                  ),
                ),
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_accentColor, _accentColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showCreateClassDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add New Class", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // Build error view for API failures
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load classes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadClasses,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Build empty view when no classes are available
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Classes Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get started by creating your first class',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateClassDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Class'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Build the class list view
  Widget _buildClassList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: _filteredClasses.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_list_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No classes match your filters',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try changing your filter criteria',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Filters'),
                  onPressed: () {
                    setState(() {
                      _activeFilters.updateAll((key, value) => false);
                      _searchQuery = '';
                      _filterClasses();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 8),
            itemCount: _filteredClasses.length,
            itemBuilder: (context, index) {
              final classData = _filteredClasses[index];
              
              // Extract class teacher from data or use placeholder
              String classTeacherName = 'Not Assigned';
              if (classData.containsKey('classTeacher')) {
                if (classData['classTeacher'] is String) {
                  classTeacherName = classData['classTeacher'];
                } else if (classData['classTeacher'] is Map) {
                  classTeacherName = classData['classTeacher']['name'] ?? 'Not Assigned';
                }
              }
              
              // Get subjects or use empty list
              List<String> subjects = [];
              if (classData.containsKey('subjects')) {
                if (classData['subjects'] is List) {
                  subjects = List<String>.from(classData['subjects'].map((subject) {
                    if (subject is String) return subject;
                    if (subject is Map && subject.containsKey('name')) return subject['name'].toString();
                    return "Unknown Subject";
                  }));
                }
              }
              
              // Create gradient colors based on index
              final List<Color> gradientColors;
              switch (index % 4) {
                case 0:
                  gradientColors = [
                    const Color(0xFF90CAF9),
                    const Color(0xFFBBDEFB),
                  ];
                  break;
                case 1:
                  gradientColors = [
                    const Color(0xFF80CBC4),
                    const Color(0xFFB2DFDB),
                  ];
                  break;
                case 2:
                  gradientColors = [
                    const Color(0xFFFFD54F),
                    const Color(0xFFFFE082),
                  ];
                  break;
                case 3:
                  gradientColors = [
                    const Color(0xFFCE93D8),
                    const Color(0xFFE1BEE7),
                  ];
                  break;
                default:
                  gradientColors = [
                    const Color(0xFF90CAF9),
                    const Color(0xFFBBDEFB),
                  ];
              }
          
              final cardColor = _cardColors[index % _cardColors.length];
          
              return Card(
                elevation: 3,
                shadowColor: gradientColors[0].withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _showClassDetails(classData),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section with gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: gradientColors[0].withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                classData.containsKey('grade') ? classData['grade'].toString() : 
                                classData['name'].toString().substring(0, 1),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: gradientColors[0],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    classData['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Color(0x50000000),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Class Teacher: $classTeacherName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Color(0x50000000),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: gradientColors[0].withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${classData.containsKey('students') ? classData['students'].toString() : 
                                  (classData.containsKey('studentCount') ? classData['studentCount'].toString() : '0')} students',
                                style: TextStyle(
                                  color: gradientColors[0],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Body section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.book, color: gradientColors[0], size: 20),
                                const SizedBox(width: 6),
                                const Text(
                                  'Subjects:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            subjects.isEmpty 
                              ? Text(
                                  'No subjects assigned',
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: subjects
                                      .map((subject) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  gradientColors[0].withOpacity(0.2),
                                                  gradientColors[1].withOpacity(0.2),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: gradientColors[0].withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              subject,
                                              style: TextStyle(
                                                fontSize: 12, 
                                                color: gradientColors[0].withOpacity(0.8),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                          ],
                        ),
                      ),
                      // Footer with actions
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: gradientColors[0].withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              icon: Icon(Icons.edit, size: 18, color: gradientColors[0]),
                              label: Text('Edit', style: TextStyle(color: gradientColors[0])),
                              onPressed: () => _showEditClassDialog(classData),
                            ),
                            Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: IconButton(
                                    icon: Icon(Icons.people, color: Colors.green.shade400),
                                    onPressed: () => _showManageStudentsDialog(classData),
                                    tooltip: "Manage Students",
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: IconButton(
                                    icon: Icon(Icons.person_outline, color: Colors.blue.shade400),
                                    onPressed: () => _showManageTeachersDialog(classData),
                                    tooltip: "Manage Teachers",
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: IconButton(
                                    icon: Icon(Icons.book, color: Colors.orange.shade400),
                                    onPressed: () => _showManageSubjectsDialog(classData),
                                    tooltip: "Manage Subjects",
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: IconButton(
                                    icon: Icon(Icons.analytics, color: Colors.purple.shade400),
                                    onPressed: () => _showClassAnalyticsView(classData),
                                    tooltip: "Analytics",
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.grey,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'teachers',
                                      child: Row(
                                        children: [
                                          Icon(Icons.person_outline, color: Colors.blue.shade400, size: 20),
                                          const SizedBox(width: 8),
                                          const Text('Manage Teachers'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'students',
                                      child: Row(
                                        children: [
                                          Icon(Icons.people, color: Colors.green.shade400, size: 20),
                                          const SizedBox(width: 8),
                                          const Text('Manage Students'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'subjects',
                                      child: Row(
                                        children: [
                                          Icon(Icons.book, color: Colors.orange.shade400, size: 20),
                                          const SizedBox(width: 8),
                                          const Text('Manage Subjects'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete, color: Colors.red, size: 20),
                                          const SizedBox(width: 8),
                                          const Text('Delete Class'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    _handleMenuAction(value, classData);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // Methods for handling class operations
  void _showClassDetails(Map<String, dynamic> classData) async {
    try {
      setState(() => _isLoading = true);
      
      // Get detailed class information if we have an ID
      if (classData.containsKey('_id') || classData.containsKey('id')) {
        final String classId = classData['_id'] ?? classData['id'];
        final detailedClassData = await _classService.getClassById(classId);
        setState(() => _isLoading = false);
        _showClassDetailsDialog(detailedClassData);
      } else {
        setState(() => _isLoading = false);
        _showClassDetailsDialog(classData);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load class details: ${e.toString()}')),
      );
    }
  }

  void _showClassDetailsDialog(Map<String, dynamic> classData) {
    // Extract class teacher from data
    String classTeacherName = 'Not Assigned';
    if (classData.containsKey('classTeacher')) {
      if (classData['classTeacher'] is String) {
        classTeacherName = classData['classTeacher'];
      } else if (classData['classTeacher'] is Map) {
        classTeacherName = classData['classTeacher']['name'] ?? 'Not Assigned';
      }
    }
    
    // Get subjects or use empty list
    List<String> subjects = [];
    if (classData.containsKey('subjects')) {
      if (classData['subjects'] is List) {
        subjects = List<String>.from(classData['subjects'].map((subject) {
          if (subject is String) return subject;
          if (subject is Map && subject.containsKey('name')) return subject['name'].toString();
          return "Unknown Subject";
        }));
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(classData['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grade: ${classData['grade'] ?? 'Not specified'}'),
            const SizedBox(height: 8),
            Text('Section: ${classData['section'] ?? 'Not specified'}'),
            const SizedBox(height: 8),
            Text('Students: ${classData['studentCount'] ?? classData['students'] ?? 0}'),
            const SizedBox(height: 8),
            Text('Class Teacher: $classTeacherName'),
            if (subjects.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Subjects:'),
              const SizedBox(height: 8),
              ...subjects.map((subject) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• $subject'),
                  )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to detailed class view
              Navigator.pop(context);
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> classData) {
    switch (action) {
      case 'edit':
        _showEditClassDialog(classData);
        break;
      case 'students':
        _showManageStudentsDialog(classData);
        break;
      case 'subjects':
        _showManageSubjectsDialog(classData);
        break;
      case 'teachers':
        _showManageTeachersDialog(classData);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(classData);
        break;
      case 'analytics':
        _showClassAnalyticsView(classData);
        break;
    }
  }
  
  void _showManageStudentsDialog(Map<String, dynamic> classData) {
    // Ensure we have studentData, even if empty
    if (!classData.containsKey('studentsData')) {
      classData['studentsData'] = <Map<String, dynamic>>[];
    }
    
    List<Map<String, dynamic>> students = List<Map<String, dynamic>>.from(classData['studentsData']);
    
    // Controllers for adding new students
    final nameController = TextEditingController();
    final idController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Manage Students - ${classData['name']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Column(
                      children: [
                        // Name field
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Student Name',
                            hintText: 'Enter full name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // ID and Add button in a row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: idController,
                                decoration: InputDecoration(
                                  labelText: 'Student ID',
                                  hintText: 'ID',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (nameController.text.isNotEmpty && idController.text.isNotEmpty) {
                                  setState(() {
                                    students.add({
                                      'id': idController.text,
                                      'name': nameController.text,
                                      'attendance': 0.0,
                                      'grade': 'N/A',
                                    });
                                    nameController.clear();
                                    idController.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No students in this class yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add students using the form above',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _accentColor.withOpacity(0.2),
                                  child: Text(
                                    student['name'].toString().substring(0, 1),
                                    style: TextStyle(color: _accentColor),
                                  ),
                                ),
                                title: Text(
                                  student['name'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text('ID: ${student['id']} | Grade: ${student['grade']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        // Edit student functionality could be added here
                                        // For now, we'll just show a snackbar
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Edit student functionality coming soon')),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        setState(() {
                                          students.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _primaryColor),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text('Cancel', style: TextStyle(color: _primaryColor)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Update student data
                            setState(() {
                              final index = _classes.indexOf(classData);
                              if (index != -1) {
                                _classes[index]['studentsData'] = students;
                                _classes[index]['students'] = students.length;
                              }
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Student list updated successfully')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            );
          },
      ),
    );
  }

  void _showClassAnalyticsView(Map<String, dynamic> classData) async {
    // Show loading indicator
    setState(() => _isLoading = true);
    
    try {
      // Get class ID 
      final String classId = classData['_id'] ?? classData['id'];
      
      // Fetch analytics data from the API
      Map<String, dynamic> analytics;
      
      try {
        // Try to fetch analytics, handle potential null response
        final result = await _classService.getClassAnalytics(classId);
        analytics = result ?? {
          'attendancePct': 0,
          'avgGrade': 0,
          'passPct': 0
        };
      } catch (e) {
        // If there's an error fetching analytics, use default values
        analytics = {
          'attendancePct': 0,
          'avgGrade': 0,
          'passPct': 0
        };
        print('Error fetching analytics: ${e.toString()}');
      }
      
      // Hide loading indicator
      setState(() => _isLoading = false);
      
      // Get theme-appropriate colors for class based on index
      final int classIndex = _classes.indexOf(classData);
      final List<Color> gradientColors;
      switch (classIndex % 4) {
        case 0:
          gradientColors = [
            const Color(0xFF1E88E5),
            const Color(0xFF42A5F5),
          ];
          break;
        case 1:
          gradientColors = [
            const Color(0xFF26A69A),
            const Color(0xFF4DB6AC),
          ];
          break;
        case 2:
          gradientColors = [
            const Color(0xFFFFA000),
            const Color(0xFFFFCA28),
          ];
          break;
        case 3:
          gradientColors = [
            const Color(0xFFAB47BC),
            const Color(0xFFBA68C8),
          ];
          break;
        default:
          gradientColors = [
            const Color(0xFF1E88E5),
            const Color(0xFF42A5F5),
          ];
      }

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Analytics: ${classData['name']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Analytics cards
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Attendance card
                      _buildAnalyticsCard(
                        'Attendance',
                        '${analytics['attendancePct'] ?? 0}',
                        Icons.calendar_today,
                        Colors.blue,
                        'Average class attendance',
                      ),
                      const SizedBox(height: 16),
                      
                      // Average grade card
                      _buildAnalyticsCard(
                        'Average Grade',
                        (analytics['avgGrade'] ?? 0).toString(),
                        Icons.grade,
                        Colors.orange,
                        'Average class grade points',
                      ),
                      const SizedBox(height: 16),
                      
                      // Pass percentage card
                      _buildAnalyticsCard(
                        'Pass Rate',
                        '${analytics['passPct'] ?? 0}',
                        Icons.check_circle,
                        Colors.green,
                        'Class passing percentage',
                      ),
                    ],
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showClassAnalyticsView(classData);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Export Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Generating analytics report...')),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load analytics: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Helper method to build analytics card
  Widget _buildAnalyticsCard(
    String title, 
    String value, 
    IconData icon, 
    Color color,
    String description,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManageSubjectsDialog(Map<String, dynamic> classData) async {
    final subjectsController = TextEditingController();
    
    // Show loading state initially while we fetch current subjects
    setState(() => _isLoading = true);
    
    try {
      final String classId = classData['_id'] ?? classData['id'];
      
      // Get current subjects either from the class data or by fetching them
      List<String> subjects = [];
      
      // First try to use the subjects data from the class object
      if (classData.containsKey('subjects')) {
        if (classData['subjects'] is List) {
          subjects = List<String>.from(classData['subjects'].map((subject) {
            if (subject is String) return subject;
            if (subject is Map && subject.containsKey('name')) return subject['name'].toString();
            return "Unknown Subject";
          }));
        }
      } else {
        // If not in the class data, try to fetch them
        subjects = await _classService.getClassSubjects(classId);
      }
      
      setState(() => _isLoading = false);
      
      // Show the dialog with the fetched subjects
      showSubjectsManagementDialog(classData, subjects);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load subjects: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void showSubjectsManagementDialog(
    Map<String, dynamic> classData,
    List<String> initialSubjects
  ) {
    // Create a working copy of subjects that we'll modify in the dialog
    final subjects = List<String>.from(initialSubjects);
    final subjectsController = TextEditingController();
    
    // Common subject suggestions for convenience
    final List<String> subjectSuggestions = [
      'Mathematics', 'Physics', 'Chemistry', 'Biology',
      'History', 'Geography', 'English', 'Literature',
      'Computer Science', 'Art', 'Music', 'Physical Education'
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Manage Subjects - ${classData['name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: subjectsController,
                              decoration: InputDecoration(
                                labelText: 'Add Subject',
                                hintText: 'Enter subject name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (subjectsController.text.isNotEmpty) {
                                setState(() {
                                  subjects.add(subjectsController.text);
                                  subjectsController.clear();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Quick subject suggestions
                      Text(
                        'Common Subjects:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: subjectSuggestions.map((subject) => FilterChip(
                          label: Text(subject),
                          selected: subjects.contains(subject),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (!subjects.contains(subject)) {
                                  subjects.add(subject);
                                }
                              } else {
                                subjects.remove(subject);
                              }
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: _accentColor.withOpacity(0.2),
                          checkmarkColor: _accentColor,
                          avatar: subjects.contains(subject) ? Icon(Icons.check, size: 18, color: _accentColor) : null,
                          labelStyle: TextStyle(
                            color: subjects.contains(subject) ? _accentColor : Colors.black87,
                            fontWeight: subjects.contains(subject) ? FontWeight.bold : FontWeight.normal,
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Subjects',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _primaryColor,
                              ),
                            ),
                            Text(
                              '${subjects.length} subjects',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: subjects.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.subject,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No subjects added yet',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add subjects using the field above',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: subjects.length,
                              itemBuilder: (context, index) {
                                final subject = subjects[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _accentColor.withOpacity(0.1),
                                    child: Text(
                                      subject[0].toUpperCase(),
                                      style: TextStyle(
                                        color: _accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(subject),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        subjects.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _primaryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text('Cancel', style: TextStyle(color: _primaryColor)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final String classId = classData['_id'] ?? classData['id'];
                            Navigator.pop(context);
                            
                            // Show loading state
                            setState(() => _isLoading = true);
                            
                            // Call API to update subjects
                            final updatedSubjects = await _classService.setClassSubjects(classId, subjects);
                            

                            // Refresh the class data to show updated information
                            await _refreshClasses();
                            
                            // Show success message with the count of subjects
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Successfully updated ${updatedSubjects.length} subjects'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                          } catch (e) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update subjects: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            // Hide loading state
                            setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      );
  }

  void _showEditClassDialog(Map<String, dynamic> classData) {
    // Extract existing data with null safety
    final nameController = TextEditingController(text: classData['name'] as String? ?? '');
    final gradeController = TextEditingController(text: classData['grade']?.toString() ?? '');
    final sectionController = TextEditingController(text: classData['section']?.toString() ?? '');
    final yearController = TextEditingController(text: classData['year']?.toString() ?? DateTime.now().year.toString());
    
    // Track form validation errors
    Map<String, String?> errors = {
      'name': null,
      'grade': null,
      'section': null,
      'year': null,
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Class: ${classData['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Class Name*',
                    errorText: errors['name'],
                    hintText: 'e.g., Advanced Physics'
                  ),
                  onChanged: (value) {
                    setState(() {
                      errors['name'] = value.isEmpty ? 'Class name is required' : null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: gradeController,
                  decoration: InputDecoration(
                    labelText: 'Grade*',
                    errorText: errors['grade'],
                    hintText: 'e.g., 10'
                  ),
                  onChanged: (value) {
                    setState(() {
                      errors['grade'] = value.isEmpty ? 'Grade is required' : null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sectionController,
                  decoration: InputDecoration(
                    labelText: 'Section*',
                    errorText: errors['section'],
                    hintText: 'e.g., A'
                  ),
                  onChanged: (value) {
                    setState(() {
                      errors['section'] = value.isEmpty ? 'Section is required' : null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: yearController,
                  decoration: InputDecoration(
                    labelText: 'Academic Year*',
                    errorText: errors['year'],
                    hintText: 'e.g., 2025'
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      errors['year'] = value.isEmpty ? 'Academic year is required' : null;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: _primaryColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate all required fields
                bool hasErrors = false;
                setState(() {
                  errors['name'] = nameController.text.isEmpty ? 'Class name is required' : null;
                  errors['grade'] = gradeController.text.isEmpty ? 'Grade is required' : null;
                  errors['section'] = sectionController.text.isEmpty ? 'Section is required' : null;
                  errors['year'] = yearController.text.isEmpty ? 'Academic year is required' : null;
                  
                  hasErrors = errors.values.any((error) => error != null);
                });
                
                if (hasErrors) {
                  // Don't proceed if there are validation errors
                  return;
                }
                
                try {
                  final String classId = classData['_id'] ?? classData['id'];
                  Navigator.pop(context);
                  
                  setState(() => _isLoading = true);
                  await _classService.updateClass(
                    classId: classId,
                    name: nameController.text,
                    grade: gradeController.text,
                    section: sectionController.text,
                    year: yearController.text,
                    // We don't update teachers, subjects, or students here
                    // Those have their own dedicated management dialogs
                  );
                  
                  // Refresh class data after update
                  await _refreshClasses();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Class updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update class: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
              ),
              child: const Text('Save Changes'),
            ),
          ],
      ),
      ),
      );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class?'),
        content: Text('Are you sure you want to delete ${classData['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final String classId = classData['_id'] ?? classData['id'];
                Navigator.pop(context);
                
                setState(() => _isLoading = true);
                await _classService.deleteClass(classId);
                
                // Refresh class data after deletion
                await _refreshClasses();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete class: ${e.toString()}')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateClassDialog() {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();
    final sectionController = TextEditingController();
    final yearController = TextEditingController(text: DateTime.now().year.toString());
    final List<String> subjects = [];
    final subjectsController = TextEditingController();
    
    // Track form validation errors
    Map<String, String?> errors = {
      'name': null,
      'grade': null,
      'section': null,
      'year': null,
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Class Name*',
                    errorText: errors['name'],
                    hintText: 'e.g., Science 10A',
                  ),
                  onChanged: (value) {
                    setState(() {
                      errors['name'] = value.isEmpty ? 'Class name is required' : null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: gradeController,
                  decoration: InputDecoration(
                    labelText: 'Grade*',
                    errorText: errors['grade'],
                    hintText: 'e.g., 10'
                  ),
                  onChanged: (value) {
                    setState(() {
                      errors['grade'] = value.isEmpty ? 'Grade is required' : null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sectionController,
                  decoration: InputDecoration(
                    labelText: 'Section*',
                    errorText: errors['section'],
                    hintText: 'e.g., A'
                  ),
                  onChanged: (value) {
                    setState(() {
                      errors['section'] = value.isEmpty ? 'Section is required' : null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: yearController,
                  decoration: InputDecoration(
                    labelText: 'Academic Year*',
                    errorText: errors['year'],
                    hintText: 'e.g., 2023',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      errors['year'] = value.isEmpty ? 'Academic year is required' : null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Subjects section with clearer headers
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Subjects (Optional)', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add at least one subject for this class',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: subjectsController,
                            decoration: const InputDecoration(
                              labelText: 'Subject Name',
                              hintText: 'e.g., Mathematics',
                              helperText: 'Press + to add subject',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: _accentColor),
                          onPressed: () {
                            if (subjectsController.text.isNotEmpty) {
                              setState(() {
                                subjects.add(subjectsController.text);
                                subjectsController.clear();
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
                
                if (subjects.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Added Subjects (${subjects.length})', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          )
                        ),
                        const SizedBox(height: 8),
                        ...subjects.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(entry.value),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      subjects.removeAt(entry.key);
                                    });
                                  },
                                ),
                              ],
                            ),
                                                   );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: _primaryColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate all required fields
                bool hasErrors = false;
                setState(() {
                  errors['name'] = nameController.text.isEmpty ? 'Class name is required' : null;
                  errors['grade'] = gradeController.text.isEmpty ? 'Grade is required' : null;
                  errors['section'] = sectionController.text.isEmpty ? 'Section is required' : null;
                  errors['year'] = yearController.text.isEmpty ? 'Academic year is required' : null;
                  
                  hasErrors = errors.values.any((error) => error != null);
                });
                
                if (hasErrors) {
                  // Don't proceed if there are validation errors
                  return;
                }
                
                try {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  
                  // Create new class with the validated data
                  await _classService.createClass(
                    name: nameController.text,
                    grade: gradeController.text,
                    section: sectionController.text,
                    year: yearController.text,
                    subjects: subjects,
                  );
                  
                  // Refresh class data after creation
                  await _refreshClasses();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Class created successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create class: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
              ),
              child: const Text('Create'),
            ),
          ],
      ),
      ),
      );
  }

  void _showManageTeachersDialog(Map<String, dynamic> classData) async {
    // Get current teachers or empty list
    List<Map<String, dynamic>> teachers = [];
    List<String> selectedTeacherIds = [];
    
    // Show loading state
    setState(() => _isLoading = true);
    
    try {
      final String classId = classData['_id'] ?? classData['id'];
      
      // Fetch teachers for this class
      final classTeachers = await _classService.getClassTeachers(classId);
      
      // Extract teacher IDs for tracking selection
      selectedTeacherIds = classTeachers
          .map((teacher) => teacher['_id'] as String)
          .toList();
      
      // For simplicity in this example, let's create a dummy list of available teachers
      // In a real app, you would fetch this from your API
      teachers = [
        {'_id': '64a7d9d67eafca861d8211b0', 'name': 'John Smith', 'email': 'john@school.com', 'teacherId': 'T001'},
        {'_id': '64a7d9e87eafca861d8211b4', 'name': 'Sarah Williams', 'email': 'sarah@school.com', 'teacherId': 'T002'},
        {'_id': '64a7d9f97eafca861d8211b8', 'name': 'Michael Brown', 'email': 'michael@school.com', 'teacherId': 'T003'},
        {'_id': '64a7da0a7eafca861d8211bc', 'name': 'Jennifer Davis', 'email': 'jennifer@school.com', 'teacherId': 'T004'},
      ];
      
      setState(() => _isLoading = false);
      
      // Show the dialog
      showTeacherSelectionDialog(classData, teachers, selectedTeacherIds);
      
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load teachers: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void showTeacherSelectionDialog(
    Map<String, dynamic> classData, 
    List<Map<String, dynamic>> teachers,
    List<String> initialSelectedTeachers
  ) {
    // Create a new list to track selected teachers in the dialog
    final selectedTeacherIds = List<String>.from(initialSelectedTeachers);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Manage Teachers - ${classData['name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Select teachers to assign to this class',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = teachers[index];
                      final isSelected = selectedTeacherIds.contains(teacher['_id']);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected 
                            ? _accentColor 
                            : Colors.grey.shade200,
                          child: isSelected 
                            ? const Icon(Icons.check, color: Colors.white, size: 20) 
                            : Text(
                                teacher['name'].toString().substring(0, 1),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _accentColor,
                                ),
                              ),
                        ),
                        title: Text(
                          teacher['name'] as String,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${teacher['email']} | ID: ${teacher['teacherId']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          activeColor: _accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedTeacherIds.add(teacher['_id'] as String);
                              } else {
                                selectedTeacherIds.remove(teacher['_id'] as String);
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedTeacherIds.remove(teacher['_id'] as String);
                            } else {
                              selectedTeacherIds.add(teacher['_id'] as String);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Selected: ${selectedTeacherIds.length} teachers',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _primaryColor),
                        ),
                        child: Text('Cancel', style: TextStyle(color: _primaryColor)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            // Get class ID
                            final String classId = classData['_id'] ?? classData['id'];
                            Navigator.pop(context);
                            
                            // Show loading state
                            setState(() => _isLoading = true);
                            
                            // Call the API to update teachers
                            await _classService.setClassTeachers(classId, selectedTeacherIds);
                            
                            // Refresh class data
                            await _refreshClasses();
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Class teachers updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update teachers: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            // Hide loading state
                            setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      );
  }
}
