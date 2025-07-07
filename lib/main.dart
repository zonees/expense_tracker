import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'your_url',
    anonKey: 'your_anonKey',
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pelacak Pengeluaran',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF6B7280),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2563EB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

// Login Page
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 20, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (response.user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on AuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: Opacity(
                opacity: 1 - (_animation.value / 20),
                child: child,
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.account_balance_wallet, size: 80, color: Color(0xFF2563EB)),
                    ),
                    SizedBox(height: 16),
                    Text('Pelacak Pengeluaran', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Kelola keuangan Anda dengan mudah', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email wajib diisi';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
                        if (value.length < 6) return 'Kata sandi minimal 6 karakter';
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Masuk'),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: Text('Belum punya akun? Daftar', style: TextStyle(color: Color(0xFF2563EB))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Register Page
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 20, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kata sandi tidak cocok')),
        );
        return;
      }
      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (response.user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on AuthException catch (e) {
        if (e.statusCode == '429') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Batas pengiriman email tercapai. Coba lagi besok atau nonaktifkan verifikasi email.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mendaftar: ${e.message}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: Opacity(
                opacity: 1 - (_animation.value / 20),
                child: child,
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.person_add, size: 80, color: Color(0xFF2563EB)),
                    ),
                    SizedBox(height: 16),
                    Text('Buat Akun Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Mulai kelola keuangan Anda', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email wajib diisi';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
                        if (value.length < 6) return 'Kata sandi minimal 6 karakter';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Kata Sandi',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
                        if (value != _passwordController.text) return 'Kata sandi tidak cocok';
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _register,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.how_to_reg, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Daftar'),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text('Sudah punya akun? Masuk', style: TextStyle(color: Color(0xFF2563EB))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Home Page
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final user = supabase.auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pelacak Pengeluaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Row(
              children: [
                Text('Keluar', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Icon(Icons.logout, size: 20),
              ],
            ),
            onPressed: () async {
              await supabase.auth.signOut();
              provider.setExpenses([]);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        elevation: 2,
      ),
      body: StreamBuilder(
        stream: supabase
            .from('expenses')
            .stream(primaryKey: ['id'])
            .eq('user_id', user.id)
            .order('created_at', ascending: false),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error memuat data atau data kosong'));
          }
          final expenses = snapshot.data!;
          provider.setExpenses(expenses);
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pengeluaran', style: TextStyle(color: Colors.blue[100], fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(provider.total)}',
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: expenses.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return _buildExpenseItem(context, expense, index);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: Color(0xFF2563EB),
        child: Icon(Icons.add, size: 32, color: Colors.white),
        elevation: 6,
        tooltip: 'Tambah Pengeluaran',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text('Belum ada pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey[700])),
          Text('Tambahkan pengeluaran pertama Anda dengan menekan tombol + di bawah', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(BuildContext context, Map<String, dynamic> expense, int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        print('Long press detected on: ${expense['description']} with ID: ${expense['id']}');
        _showActionMenu(context, expense);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          title: Text(expense['description'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          subtitle: Row(
            children: [
              Chip(
                label: Text(expense['category'], style: TextStyle(fontSize: 12)),
                backgroundColor: _getCategoryColor(expense['category']),
              ),
              SizedBox(width: 8),
              Text(
                DateFormat('dd MMM yyyy').format(DateTime.parse(expense['created_at'])),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          trailing: Text(
            'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(expense['amount'])}',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context, Map<String, dynamic> expense) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Color(0xFF2563EB)),
              title: Text('Edit'),
              onTap: () {
                print('Edit selected for: ${expense['description']} with ID: ${expense['id']}');
                Navigator.pop(context);
                _showEditExpenseDialog(context, expense);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red[500]),
              title: Text('Hapus'),
              onTap: () {
                print('Delete selected for: ${expense['description']} with ID: ${expense['id']}');
                Navigator.pop(context);
                _showDeleteConfirmation(context, expense['id']);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int expenseId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, size: 48, color: Colors.red[500]),
                SizedBox(height: 16),
                Text('Hapus Pengeluaran?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Tindakan ini tidak dapat dibatalkan', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal', style: TextStyle(color: Colors.grey[700])),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _deleteExpenseWithAnimation(context, expenseId);
                          Navigator.pop(context);
                        },
                        child: Text('Hapus', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteExpenseWithAnimation(BuildContext context, int expenseId) async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Menghapus...'),
          ],
        ),
      ),
    );
    try {
      await Supabase.instance.client.from('expenses').delete().eq('id', expenseId);
      provider.removeExpense(expenseId); // Update local state
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus pengeluaran: $e')),
      );
    } finally {
      Navigator.pop(context);
    }
  }

  void _showEditExpenseDialog(BuildContext context, Map<String, dynamic> expense) {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: expense['amount'].toString());
  final _descriptionController = TextEditingController(text: expense['description']);
  String _selectedCategory = expense['category'];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Pengeluaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[500]),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
                      if (double.tryParse(value) == null) return 'Masukkan angka valid';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Deskripsi wajib diisi';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: ['Makanan', 'Transportasi', 'Lainnya']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category, style: TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                    validator: (value) => value == null ? 'Kategori wajib dipilih' : null,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Batal', style: TextStyle(color: Colors.grey[700])),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _updateExpense(
                                context,
                                expense['id'],
                                double.parse(_amountController.text),
                                _descriptionController.text,
                                _selectedCategory,
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Simpan', style: TextStyle(color: Colors.white)), // Pastikan teks ada
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2563EB), // Warna latar belakang
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Future<void> _updateExpense(BuildContext context, int id, double amount, String description, String category) async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    try {
      final response = await Supabase.instance.client
          .from('expenses')
          .update({
            'amount': amount,
            'description': description,
            'category': category,
            'created_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      provider.updateExpense(response); // Update local state
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengupdate pengeluaran: $e')),
      );
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(userId: Supabase.instance.client.auth.currentUser!.id),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan':
        return Colors.blue[100]!;
      case 'Transportasi':
        return Colors.green[100]!;
      default:
        return Colors.purple[100]!;
    }
  }
}

// Add Expense Dialog
class AddExpenseDialog extends StatefulWidget {
  final String? userId;

  AddExpenseDialog({this.userId});

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Makanan';
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 20, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    print('Tombol Simpan ditekan');
    if (_formKey.currentState!.validate()) {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      if (user == null || widget.userId == null || widget.userId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengguna tidak terautentikasi atau ID tidak valid')),
        );
        return;
      }

      try {
        final response = await supabase
            .from('expenses')
            .insert({
              'user_id': widget.userId,
              'amount': double.parse(_amountController.text),
              'description': _descriptionController.text,
              'category': _selectedCategory,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        provider.addExpense(response);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah pengeluaran: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Opacity(
            opacity: 1 - (_animation.value / 20),
            child: child,
          ),
        );
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tambah Pengeluaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[500]),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
                      if (double.tryParse(value) == null) return 'Masukkan angka valid';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Deskripsi wajib diisi';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: ['Makanan', 'Transportasi', 'Lainnya']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category, style: TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                    validator: (value) => value == null ? 'Kategori wajib dipilih' : null,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Batal', style: TextStyle(color: Colors.grey[700])),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addExpense,
                          child: Text('Simpan', style: TextStyle(color: Colors.white)), // Pastikan teks ada
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2563EB), // Warna latar belakang
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Delete Confirmation Dialog
class DeleteConfirmationDialog extends StatelessWidget {
  final int expenseId;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  DeleteConfirmationDialog({required this.expenseId, required this.onDelete, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete, size: 48, color: Colors.red[500]),
              SizedBox(height: 16),
              Text('Hapus Pengeluaran?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Tindakan ini tidak dapat dibatalkan', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        onCancel();
                        Navigator.pop(context);
                      },
                      child: Text('Batal', style: TextStyle(color: Colors.grey[700])),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        onDelete();
                        Navigator.pop(context);
                      },
                      child: Text('Hapus', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Expense Provider
class ExpenseProvider with ChangeNotifier {
  List<Map<String, dynamic>> _expenses = [];
  double _total = 0;

  List<Map<String, dynamic>> get expenses => _expenses;
  double get total => _total;

  void setExpenses(List<Map<String, dynamic>> expenses) {
    _expenses = expenses;
    _total = expenses.fold(0, (sum, expense) => sum + (expense['amount'] as num));
    notifyListeners();
  }

  void addExpense(Map<String, dynamic> expense) {
    _expenses.insert(0, expense); // Insert at the beginning to match order
    _total += (expense['amount'] as num);
    notifyListeners();
  }

  void removeExpense(int id) {
    _expenses.removeWhere((expense) => expense['id'] == id);
    _total = _expenses.fold(0, (sum, expense) => sum + (expense['amount'] as num));
    notifyListeners();
  }

  void updateExpense(Map<String, dynamic> updatedExpense) {
    final index = _expenses.indexWhere((expense) => expense['id'] == updatedExpense['id']);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      _total = _expenses.fold(0, (sum, expense) => sum + (expense['amount'] as num));
      notifyListeners();
    }
  }
}
