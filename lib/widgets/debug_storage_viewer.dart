import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/storage_util.dart';

class DebugStorageViewer extends StatefulWidget {
  const DebugStorageViewer({Key? key}) : super(key: key);

  @override
  _DebugStorageViewerState createState() => _DebugStorageViewerState();
}

class _DebugStorageViewerState extends State<DebugStorageViewer> {
  Map<String, dynamic> _storageData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  Future<void> _loadStorageData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      Map<String, dynamic> data = {};
      for (var key in keys) {
        data[key] = prefs.get(key);
      }
      
      setState(() {
        _storageData = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading storage data: $e");
      setState(() {
        _storageData = {};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStorageData,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await StorageUtil.clear();
              await _loadStorageData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _storageData.isEmpty
              ? const Center(child: Text('No data stored'))
              : ListView.builder(
                  itemCount: _storageData.length,
                  itemBuilder: (context, index) {
                    final key = _storageData.keys.elementAt(index);
                    final value = _storageData[key];
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        title: Text(key),
                        subtitle: Text(value.toString()),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            // In a real app, you would copy the value to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied: $value')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
