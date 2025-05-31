import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class ClassManagementScreen extends StatefulWidget {
  final User user;
  
  const ClassManagementScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ClassManagementScreenState createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final List<Map<String, dynamic>> _classes = [
    {
      'name': 'Class 10A',
      'students': 32,
      'subjects': ['Mathematics', 'Physics', 'Chemistry', 'Biology'],
      'classTeacher': 'Mr. Robert Johnson',
      'studentsData': [
        {'id': '001', 'name': 'Alice Parker', 'attendance': 0.92, 'grade': 'A'},
        {'id': '002', 'name': 'Bob Wilson', 'attendance': 0.88, 'grade': 'B+'},
        {'id': '003', 'name': 'Carol Smith', 'attendance': 0.95, 'grade': 'A-'},
        {'id': '004', 'name': 'David Johnson', 'attendance': 0.85, 'grade': 'B'},
      ],
    },
    {
      'name': 'Class 9B',
      'students': 28,
      'subjects': ['Mathematics', 'Science', 'History', 'Geography'],
      'classTeacher': 'Ms. Sarah Williams'
    },
    {
      'name': 'Class 8C',
      'students': 30,
      'subjects': ['English', 'Mathematics', 'Science', 'Social Studies'],
      'classTeacher': 'Mr. David Miller'
    },
  ];

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

  bool _isLoading = false;
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
    _filteredClasses = List.from(_classes); // Initialize filtered classes
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
            color: _primaryColor,
            fontWeight: FontWeight.bold,
          )
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: _primaryColor),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: _accentColor),
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
          : Column(
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
                  child: Container(
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
                                              classData['name'].toString().substring(classData['name'].toString().length - 3),
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
                                                  'Class Teacher: ${classData['classTeacher']}',
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
                                              '${classData['students']} students',
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
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: (classData['subjects'] as List<String>)
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
                  ),
                ),
              ],
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

  void _showClassDetails(Map<String, dynamic> classData) {
    // Show class details in a dialog or navigate to a new screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(classData['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Students: ${classData['students']}'),
            const SizedBox(height: 8),
            Text('Class Teacher: ${classData['classTeacher']}'),
            const SizedBox(height: 16),
            const Text('Subjects:'),
            const SizedBox(height: 8),
            ...((classData['subjects'] as List<String>).map((subject) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $subject'),
                ))),
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

  void _showClassAnalyticsView(Map<String, dynamic> classData) {
    // Sample performance data for demonstration
    final performanceData = {
      'attendance': 0.89,
      'averageGrade': 78.5,
      'assignmentsCompleted': 0.92,
      'subjects': {
        'Mathematics': 82.5,
        'Science': 75.0,
        'English': 79.8,
        'History': 76.2,
      },
      'monthlyAttendance': [
        {'month': 'Jan', 'value': 0.92},
        {'month': 'Feb', 'value': 0.89},
        {'month': 'Mar', 'value': 0.95},
        {'month': 'Apr', 'value': 0.85},
        {'month': 'May', 'value': 0.88},
      ],
    };
    
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colorful header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            classData['name'].toString().substring(classData['name'].toString().length - 2),
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
                                'Analytics for ${classData['name']}',
                                style: const TextStyle(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Color(0x70000000),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Class Teacher: ${classData['classTeacher']}',
                                style: const TextStyle(
                                  fontSize: 14, 
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Color(0x50000000),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Key stats in the header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildHeaderStat(
                          '${classData['students']}',
                          'Students',
                          Icons.people,
                        ),
                        _buildHeaderStat(
                          '${((performanceData['attendance'] as double) * 100).toStringAsFixed(0)}%',
                          'Attendance',
                          Icons.calendar_today,
                        ),
                        _buildHeaderStat(
                          '${performanceData['averageGrade']}',
                          'Avg. Grade',
                          Icons.grade,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Content area
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  children: [
                    // Performance Overview Section
                    
                    
                    const SizedBox(height: 24),
                    
                    // Subject Performance Section
                    _buildAnalyticsSection(
                      'Subject Performance',
                      [_buildSubjectPerformance(performanceData['subjects'] as Map<String, dynamic>, gradientColors)],
                      icon: Icons.school,
                      iconColor: gradientColors[0],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Monthly Attendance Section
                    _buildAnalyticsSection(
                      'Monthly Attendance',
                      [_buildMonthlyAttendance(performanceData['monthlyAttendance'] as List<Map<String, dynamic>>, gradientColors)],
                      icon: Icons.date_range,
                      iconColor: gradientColors[0],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.print),
                          label: const Text('Print Report'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Printing report...')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: gradientColors[0],
                            side: BorderSide(color: gradientColors[0]),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Download PDF'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Generating PDF report...')),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gradientColors[0],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(String label, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(String title, List<Widget> children, {IconData? icon, Color? iconColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? Colors.blue, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSubjectPerformance(Map<String, dynamic> subjects, List<Color> gradientColors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gradientColors[0].withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: subjects.entries.map((entry) {
            final double grade = entry.value as double;
            final Color gradeColor = _getColorForGrade(grade);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: gradeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: gradeColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          grade.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: gradeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 12,
                        width: (MediaQuery.of(context).size.width - 64) * (grade / 100),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              gradeColor,
                              gradeColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: gradeColor.withOpacity(0.3),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMonthlyAttendance(List<Map<String, dynamic>> data, List<Color> gradientColors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gradientColors[0].withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Attendance Rate',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: gradientColors[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gradientColors[0].withOpacity(0.3)),
                  ),
                  child: Text(
                    'Average: ${(data.map((m) => m['value'] as double).reduce((a, b) => a + b) / data.length * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gradientColors[0],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180, // Adjusted height to prevent overflow
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((monthData) {
                  final double value = monthData['value'] as double;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(value * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: gradientColors[0],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 120 * value, // Reduced max height to fit better
                          width: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradientColors[0],
                                gradientColors[1],
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.3),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          monthData['month'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: gradientColors[0],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForGrade(double grade) {
    if (grade >= 90) return Colors.green.shade600;
    if (grade >= 80) return Colors.blue.shade600;
    if (grade >= 70) return Colors.amber.shade600;
    if (grade >= 60) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  void _showManageSubjectsDialog(Map<String, dynamic> classData) {
    final subjectsController = TextEditingController();
    final List<String> subjects = List<String>.from(classData['subjects']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Manage Subjects for ${classData['name']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: subjectsController,
                        decoration: const InputDecoration(
                          labelText: 'Add Subject',
                          hintText: 'Enter subject name',
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
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Current Subjects', 
                  style: TextStyle(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        title: Text(subjects[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update subjects in class data
                setState(() {
                  final index = _classes.indexOf(classData);
                  if (index != -1) {
                    _classes[index]['subjects'] = subjects;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subjects updated successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditClassDialog(Map<String, dynamic> classData) {
    final nameController = TextEditingController(text: classData['name'] as String);
    final teacherController = TextEditingController(text: classData['classTeacher'] as String);
    final studentsController = TextEditingController(text: classData['students'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Class Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: teacherController,
                decoration: const InputDecoration(labelText: 'Class Teacher'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: studentsController,
                decoration: const InputDecoration(labelText: 'Number of Students'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update class data
              if (nameController.text.isNotEmpty && teacherController.text.isNotEmpty) {
                setState(() {
                  final index = _classes.indexOf(classData);
                  if (index != -1) {
                    _classes[index]['name'] = nameController.text;
                    _classes[index]['classTeacher'] = teacherController.text;
                    _classes[index]['students'] = int.tryParse(studentsController.text) ?? _classes[index]['students'];
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
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
            onPressed: () {
              // Delete the class
              setState(() {
                _classes.remove(classData);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Class deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateClassDialog() {
    final nameController = TextEditingController();
    final teacherController = TextEditingController();
    final studentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Class Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: teacherController,
                decoration: const InputDecoration(labelText: 'Class Teacher'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: studentsController,
                decoration: const InputDecoration(labelText: 'Number of Students'),
                keyboardType: TextInputType.number,
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
            onPressed: () {
              // Create new class
              if (nameController.text.isNotEmpty && teacherController.text.isNotEmpty) {
                setState(() {
                  _classes.add({
                    'name': nameController.text,
                    'classTeacher': teacherController.text,
                    'students': int.tryParse(studentsController.text) ?? 0,
                    'subjects': ['Mathematics', 'Science', 'English', 'Social Studies'],
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class created successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
