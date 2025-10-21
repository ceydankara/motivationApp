import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginMode = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _handleAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Kullanıcı adı ve şifre boş olamaz';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool success = false;
    if (_isLoginMode) {
      success = await _authService.login(username, password);
      if (!success) {
        setState(() {
          _errorMessage = 'Kullanıcı adı veya şifre hatalı';
        });
      }
    } else {
      success = await _authService.register(username, password);
      if (!success) {
        setState(() {
          _errorMessage = 'Bu kullanıcı adı zaten kullanılıyor';
        });
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Giriş Yap' : 'Kayıt Ol'),
        backgroundColor: const Color.fromARGB(255, 169, 209, 208),
        foregroundColor: const Color.fromARGB(255, 254, 237, 219),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo veya başlık
            const Icon(
              Icons.person,
              size: 80,
              color: Color.fromARGB(255, 39, 134, 133),
            ),
            const SizedBox(height: 32),

            // Başlık
            Text(
              _isLoginMode ? 'Hoş Geldiniz' : 'Hesap Oluştur',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 39, 134, 133),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoginMode ? 'Hesabınıza giriş yapın' : 'Yeni hesap oluşturun',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Hata mesajı
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              ),

            // Kullanıcı adı alanı
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Şifre alanı
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              enabled: !_isLoading,
              onSubmitted: (_) => _handleAuth(),
            ),
            const SizedBox(height: 24),

            // Giriş/Kayıt butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 39, 134, 133),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _isLoginMode ? 'Giriş Yap' : 'Kayıt Ol',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Mod değiştirme
            TextButton(
              onPressed: _isLoading ? null : _toggleMode,
              child: Text(
                _isLoginMode
                    ? 'Hesabınız yok mu? Kayıt olun'
                    : 'Zaten hesabınız var mı? Giriş yapın',
                style: const TextStyle(
                  color: Color.fromARGB(255, 39, 134, 133),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
