import 'package:flutter/material.dart';
import 'package:gift_bouqet/pages/user/testimoni.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../model/userModel.dart';
import '../../service/userService.dart';
import '../auth/login.dart';


class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  ProfilePage({super.key, required this.userData})
    : assert(userData['userId'] != null, 'UserData must contain userId');

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      dynamic userId = widget.userData['userId'];

      // Handle case where userId might be an int
      if (userId is int) {
        userId = userId.toString();
      }

      // First try to get from widget data
      if (userId == null || userId.toString().isEmpty) {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final cachedUserId = prefs.getString('userId');

        if (cachedUserId == null || cachedUserId.isEmpty) {
          throw Exception('User ID not available in cache');
        }

        // Update widget data with cached ID
        userId = cachedUserId;
      }

      // Initialize user from available data
      user = User(
        id: int.tryParse(userId.toString()) ?? 0,
        username: widget.userData['username']?.toString() ?? '',
        email: widget.userData['email']?.toString() ?? '',
        profilePicture: widget.userData['profilePicture']?.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (user!.id == 0) {
        throw Exception('Invalid user ID format');
      }

      // Load fresh data from API
      await _loadUserData();
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      debugPrint("Initialization error: $e");
    }
  }

  Future<void> _loadUserData() async {
    if (user == null || user!.id == 0) {
      setState(() => errorMessage = 'Invalid user data');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userModel = await UserService.getProfile();
      if (userModel.data?.user != null) {
        setState(() => user = userModel.data!.user);
        await _updateLocalCache(user!);
      } else {
        throw Exception(userModel.message ?? 'Failed to load user data');
      }
    } catch (e) {
      setState(
        () =>
            errorMessage =
                'Error: ${e.toString().replaceAll('Exception: ', '')}',
      );
      debugPrint("Error loading user: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Akun'),
            content: const Text('Apakah Anda yakin ingin menghapus akun Anda?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final response = await UserService.deleteUser();

        if (response.status == 'sukses') {
          await _logout();
        } else {
          throw Exception(response.message ?? 'Gagal menghapus akun');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus akun: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateLocalCache(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', updatedUser.id.toString());
    await prefs.setString('username', updatedUser.username?? '');
    await prefs.setString('email', updatedUser.email ?? '');
    if (updatedUser.profilePicture != null) {
      await prefs.setString('profilePicture', updatedUser.profilePicture!);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _refreshProfile() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _buildBodyContent());
  }

  Widget _buildBodyContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child:
          isLoading && user == null
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null && user == null
              ? _buildErrorWidget()
              : user == null
              ? _buildNoUserWidget()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Unknown error occurred',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _initializeUser,
                child: const Text('Try Again'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Login Again'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoUserWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No user data available', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _initializeUser,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildProfileAvatar(),
            const SizedBox(height: 20),
            _buildUserInfo(),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xff233743),
          backgroundImage:
              user?.profilePicture != null && user!.profilePicture!.isNotEmpty
                  ? NetworkImage(user!.profilePicture!)
                  : null,
          child:
              user?.profilePicture== null || user!.profilePicture!.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
        ),
        if (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          user?.username?? 'No username',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff233743),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'No email',
          style: TextStyle(fontSize: 14, color: Colors.brown.shade300),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildActionButton(
          icon: Icons.feedback,
          label: "Testimoni",
          color: const Color(0xff233743),
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpPage()),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          icon: Icons.logout,
          label: "Logout",
          color: Colors.brown.shade100,
          textColor: Colors.brown,
          onPressed: _showLogoutDialog,
        ),

        const SizedBox(height: 20),
        _buildActionButton(
          icon: Icons.delete_forever,
          label: "Hapus Akun",
          color: Colors.red.shade100,
          textColor: Colors.red,
          onPressed: _deleteAccount,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _logout();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
    );
  }
}
