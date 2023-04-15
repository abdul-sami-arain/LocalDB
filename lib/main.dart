import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      final Database db = await _initDatabase();
      final List<Map<String, dynamic>> results = await db.query(
        'login',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (results.isNotEmpty) {
        // Login successful
        _errorMessage = '';
        _navigateToHomePage();
      } else {
        // Login failed
        _errorMessage = 'Invalid username or password';
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signup() async {
  setState(() {
    _isLoading = true;
  });

  final String username = _usernameController.text.trim();
  final String password = _passwordController.text.trim();

  if (_formKey.currentState!.validate()) {
    final Database db = await _initDatabase();
    final int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users WHERE username = ?', [username]));

    if (count == 0) {
      // User doesn't exist, create a new user
      await db.insert('users', {'username': username, 'password': password});
      _errorMessage = '';
      _navigateToHomePage();
    } else {
      // User already exists, show error message
      _errorMessage = 'Username already exists';
    }
  }

  setState(() {
    _isLoading = false;
  });
}


  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'login.db');

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE login(id INTEGER PRIMARY KEY, username TEXT, password TEXT)');
    });
  }

  void _navigateToHomePage() {
    Navigator.of(context as BuildContext).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Log in'),
              ),
              SizedBox(height: 16.0),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Welcome!'),
      ),
    );
  }
}
