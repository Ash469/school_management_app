import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResourceLibraryScreen extends StatefulWidget {
  const ResourceLibraryScreen({Key? key}) : super(key: key);

  @override
  _ResourceLibraryScreenState createState() => _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedCategory = "All";
  List<ResourceItem> _resources = [];

  // Example resource categories
  final List<String> _categories = [
    "All",
    "Notes",
    "Assignments",
    "Past Papers",
    "Reference Books",
    "Syllabus",
    "Videos",
    "Others"
  ];

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  // Mock function to fetch resources from API
  Future<void> _fetchResources() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    final mockResources = [
      ResourceItem(
        id: '1',
        title: 'Mathematics Formulas',
        description: 'Complete formula sheet for calculus and algebra',
        category: 'Notes',
        fileType: 'PDF',
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        fileSize: 2.4,
        uploadedBy: 'Mr. Johnson',
        downloadUrl: 'https://example.com/files/math_formulas.pdf',
      ),
      ResourceItem(
        id: '2',
        title: 'Physics Lab Report Template',
        description: 'Template for writing physics lab reports with examples',
        category: 'Assignments',
        fileType: 'DOCX',
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
        fileSize: 1.2,
        uploadedBy: 'Ms. Richards',
        downloadUrl: 'https://example.com/files/lab_template.docx',
      ),
      ResourceItem(
        id: '3',
        title: 'History Timeline - World War II',
        description: 'Comprehensive timeline of World War II events',
        category: 'Reference Books',
        fileType: 'PDF',
        uploadDate: DateTime.now().subtract(const Duration(days: 15)),
        fileSize: 5.7,
        uploadedBy: 'Dr. Williams',
        downloadUrl: 'https://example.com/files/ww2_timeline.pdf',
      ),
      ResourceItem(
        id: '4',
        title: 'Biology Cell Structure Video',
        description: 'Detailed video explaining cell structures and functions',
        category: 'Videos',
        fileType: 'MP4',
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        fileSize: 128.5,
        uploadedBy: 'Mrs. Thompson',
        downloadUrl: 'https://example.com/files/cell_structure.mp4',
      ),
      ResourceItem(
        id: '5',
        title: 'Chemistry Final Exam 2022',
        description: 'Previous year chemistry final exam questions',
        category: 'Past Papers',
        fileType: 'PDF',
        uploadDate: DateTime.now().subtract(const Duration(days: 60)),
        fileSize: 3.1,
        uploadedBy: 'Mr. Davis',
        downloadUrl: 'https://example.com/files/chem_exam_2022.pdf',
      ),
      ResourceItem(
        id: '6',
        title: 'English Literature Reading List',
        description: 'Required and recommended reading for the semester',
        category: 'Syllabus',
        fileType: 'PDF',
        uploadDate: DateTime.now().subtract(const Duration(days: 45)),
        fileSize: 0.8,
        uploadedBy: 'Ms. Anderson',
        downloadUrl: 'https://example.com/files/reading_list.pdf',
      ),
      ResourceItem(
        id: '7',
        title: 'Programming Project Guidelines',
        description: 'Instructions and rubric for the term project',
        category: 'Assignments',
        fileType: 'PDF',
        uploadDate: DateTime.now().subtract(const Duration(days: 7)),
        fileSize: 1.5,
        uploadedBy: 'Mr. Turner',
        downloadUrl: 'https://example.com/files/project_guidelines.pdf',
      ),
    ];
    
    setState(() {
      _resources = mockResources;
      _isLoading = false;
    });
  }

  List<ResourceItem> get _filteredResources {
    return _resources.where((resource) {
      final matchesCategory = _selectedCategory == "All" || 
                              resource.category == _selectedCategory;
      final matchesSearch = resource.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            resource.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            resource.uploadedBy.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showResourceUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This resource will be available for download soon.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Library'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredResources.isEmpty
                ? const Center(child: Text('No resources found'))
                : ListView.builder(
                    itemCount: _filteredResources.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final resource = _filteredResources[index];
                      return _buildResourceCard(resource);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search resources...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = "";
                  });
                },
              )
            : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: _categories.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResourceCard(ResourceItem resource) {
    final IconData fileIcon = _getFileTypeIcon(resource.fileType);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(fileIcon),
        ),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          resource.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download_outlined),
          onPressed: () => _showResourceUnavailableMessage(),
        ),
        onTap: () {
          _showResourceDetails(resource);
        },
      ),
    );
  }

  void _showResourceDetails(ResourceItem resource) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(resource.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Category: ${resource.category}'),
                const SizedBox(height: 8),
                Text('File type: ${resource.fileType}'),
                const SizedBox(height: 8),
                Text('Size: ${resource.fileSize} MB'),
                const SizedBox(height: 8),
                Text('Uploaded by: ${resource.uploadedBy}'),
                const SizedBox(height: 8),
                Text('Date: ${DateFormat('MMM dd, yyyy').format(resource.uploadDate)}'),
                const SizedBox(height: 16),
                Text(
                  resource.description,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CLOSE'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showResourceUnavailableMessage();
              },
              child: const Text('DOWNLOAD'),
            ),
          ],
        );
      }
    );
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOC':
      case 'DOCX':
        return Icons.description;
      case 'PPT':
      case 'PPTX':
        return Icons.slideshow;
      case 'XLS':
      case 'XLSX':
        return Icons.table_chart;
      case 'MP4':
      case 'AVI':
      case 'MOV':
        return Icons.video_library;
      case 'MP3':
      case 'WAV':
        return Icons.audio_file;
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        return Icons.image;
      case 'ZIP':
      case 'RAR':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class ResourceItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String fileType;
  final DateTime uploadDate;
  final double fileSize;  // in MB
  final String uploadedBy;
  final String downloadUrl;

  ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileType,
    required this.uploadDate,
    required this.fileSize,
    required this.uploadedBy,
    required this.downloadUrl,
  });
}
