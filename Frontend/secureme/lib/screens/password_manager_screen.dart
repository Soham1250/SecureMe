import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../services/password_storage_service.dart';
import '../widgets/auth_dialog.dart';
import 'add_edit_password_screen.dart';

class PasswordManagerScreen extends StatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  State<PasswordManagerScreen> createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen> {
  final PasswordStorageService _storageService = PasswordStorageService();
  final TextEditingController _searchController = TextEditingController();

  List<PasswordEntry> _passwords = [];
  List<PasswordEntry> _filteredPasswords = [];
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
    _searchController.addListener(_filterPasswords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPasswords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final passwords = await _storageService.getAllPasswords();
      setState(() {
        _passwords = passwords;
        _filteredPasswords = passwords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPasswords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPasswords = _passwords;
      } else {
        _filteredPasswords = _passwords.where((password) {
          return password.title.toLowerCase().contains(query) ||
                 password.username.toLowerCase().contains(query) ||
                 (password.website?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _authenticate() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AuthDialog(),
    );

    if (result == true) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  Future<void> _addPassword() async {
    if (!_isAuthenticated) {
      await _authenticate();
      if (!_isAuthenticated) return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditPasswordScreen(),
      ),
    );

    if (result == true) {
      await _loadPasswords();
    }
  }

  Future<void> _editPassword(PasswordEntry password) async {
    if (!_isAuthenticated) {
      await _authenticate();
      if (!_isAuthenticated) return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPasswordScreen(password: password),
      ),
    );

    if (result == true) {
      await _loadPasswords();
    }
  }

  Future<void> _deletePassword(PasswordEntry password) async {
    if (!_isAuthenticated) {
      await _authenticate();
      if (!_isAuthenticated) return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Password'),
        content: Text('Are you sure you want to delete "${password.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deletePassword(password.id);
        await _loadPasswords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete password: $e')),
          );
        }
      }
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    if (!_isAuthenticated) {
      await _authenticate();
      if (!_isAuthenticated) return;
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label copied to clipboard')),
      );
    }
  }

  void _logout() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Lock',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPasswords,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPassword,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading passwords',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPasswords,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_passwords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.password,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No passwords stored',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Tap the + button to add your first password'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search passwords',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredPasswords.length,
            itemBuilder: (context, index) {
              final password = _filteredPasswords[index];
              return _buildPasswordCard(password);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordCard(PasswordEntry password) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            password.title.isNotEmpty 
                ? password.title[0].toUpperCase()
                : '?',
          ),
        ),
        title: Text(password.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${password.username}'),
            Text('Password: ${_isAuthenticated ? password.password : password.maskedPassword}'),
            if (password.website != null)
              Text('Website: ${password.website}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'copy_username':
                _copyToClipboard(password.username, 'Username');
                break;
              case 'copy_password':
                _copyToClipboard(password.password, 'Password');
                break;
              case 'edit':
                _editPassword(password);
                break;
              case 'delete':
                _deletePassword(password);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy_username',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy Username'),
              ),
            ),
            const PopupMenuItem(
              value: 'copy_password',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy Password'),
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
        onTap: () => _editPassword(password),
      ),
    );
  }
}
