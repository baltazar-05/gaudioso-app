import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaudioso_app/services/api_service.dart';
import 'package:gaudioso_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String role;

  const ProfileScreen({
    super.key,
    required this.username,
    this.role = 'funcionario',
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isModified = false;
  bool _isSaving = false;
  bool _suppressChange = false;
  String _displayName = '';
  String _role = 'funcionario';
  XFile? _avatar;
  File? _avatarFile;
  String? _avatarUrl;
  bool _avatarChanged = false;
  final ImagePicker _picker = ImagePicker();
  late final String _avatarName;

  @override
  void initState() {
    super.initState();
    _avatarName = _avatarFileName(widget.username);
    _displayName = widget.username;
    _role = widget.role;
    _nameController = TextEditingController(text: widget.username);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _nameController.addListener(_onFieldChanged);
    _currentPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);

    _hydrateUser();
    _loadAvatarFromDisk();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _currentPasswordController.removeListener(_onFieldChanged);
    _newPasswordController.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _hydrateUser() async {
    final current = await AuthService().currentUser();
    if (!mounted || current == null) return;
    final nome = (current['nome'] as String?)?.trim();
    final role = (current['role'] as String?)?.trim();
    _avatarUrl = (current['avatarUrl'] as String?)?.trim();
    _suppressChange = true;
    setState(() {
      _displayName = (nome != null && nome.isNotEmpty) ? nome : widget.username;
      _nameController.text = _displayName;
      _role = role ?? _role;
      _isModified = false;
    });
    _suppressChange = false;
    await _ensureAvatarFromServer();
  }

  Future<void> _loadAvatarFromDisk() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_avatarName');
    if (await file.exists()) {
      setState(() {
        _avatarFile = file;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final dest = File('${dir.path}/$_avatarName');
      await dest.writeAsBytes(await picked.readAsBytes());
      setState(() {
        _avatar = picked;
        _avatarFile = dest;
        _isModified = true;
        _avatarChanged = true;
      });
    }
  }

  Future<void> _ensureAvatarFromServer() async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/$_avatarName');
    if (_avatarUrl == null || _avatarUrl!.isEmpty) {
      if (await dest.exists()) await dest.delete();
      setState(() => _avatarFile = null);
      return;
    }
    try {
      final bytes = await ApiService.getBytesAbsolute(_avatarUrl!);
      await dest.writeAsBytes(bytes);
      setState(() {
        _avatarFile = dest;
      });
    } catch (_) {
      // ignora falhas silenciosamente
    }
  }

  String _avatarFileName(String username) {
    final safe = username.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return 'profile_avatar_$safe.png';
  }

  void _onFieldChanged() {
    if (_suppressChange) return;
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    final messenger = ScaffoldMessenger.of(context);
    final newName = _nameController.text.trim();
    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    bool changedSomething = false;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar alterações'),
        content: const Text('Deseja salvar as alterações feitas no perfil?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Salvar')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _isSaving = true;
    });

    // Atualiza nome
    if (newName.isNotEmpty && newName != _displayName) {
      final err = await AuthService().updateNome(newName);
      if (err != null) {
        messenger.showSnackBar(SnackBar(content: Text(err)));
        setState(() => _isSaving = false);
        return;
      }
      changedSomething = true;
      _displayName = newName;
    }

    // Atualiza senha
    if (newPass.isNotEmpty) {
      if (currentPass.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('Informe a senha atual para alterar.')));
        setState(() => _isSaving = false);
        return;
      }
      if (newPass != confirmPass) {
        messenger.showSnackBar(const SnackBar(content: Text('A nova senha e a confirmacao precisam coincidir.')));
        setState(() => _isSaving = false);
        return;
      }
      final err = await AuthService().updateSenha(currentPass, newPass);
      if (err != null) {
        messenger.showSnackBar(SnackBar(content: Text(err)));
        setState(() => _isSaving = false);
        return;
      }
      changedSomething = true;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }

    if (_avatarChanged && _avatarFile != null) {
      final err = await AuthService().updateAvatar(_avatarFile!.path);
      if (err != null) {
        messenger.showSnackBar(SnackBar(content: Text(err)));
        setState(() {
          _isSaving = false;
        });
        return;
      }
      changedSomething = true;
      _avatarChanged = false;
    }

    setState(() {
      _isSaving = false;
      _isModified = false;
    });

    if (changedSomething) {
      if (mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('Perfil atualizado com sucesso.')));
      }
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Nada para salvar.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const brandGreen = Color(0xFF66BB6A);
    const brandDark = Color(0xFF2E7D32);
    final roleLabel = _role.toLowerCase() == 'admin' ? 'Administrador' : 'Funcionario';

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: kToolbarHeight + 4,
        iconTheme: const IconThemeData(color: Colors.black),
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Perfil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400)),
        leadingWidth: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.white,
                      backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : (_avatar != null ? FileImage(File(_avatar!.path)) : null),
                      child: _avatarFile == null && _avatar == null
                          ? const Icon(
                              Icons.person,
                              size: 64,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    roleLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Alterar nome",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: brandGreen, width: 1.8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Senha atual",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_clock, color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: brandGreen, width: 1.8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Nova senha",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: brandGreen, width: 1.8),
                          ),
                          hintText: '********',
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Confirmar nova senha",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_reset, color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: brandGreen, width: 1.8),
                          ),
                          hintText: '********',
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
                        child: _isModified
                            ? SizedBox(
                                key: const ValueKey('saveButton'),
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brandDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Salvar alteracoes',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                        ),
                                ),
                              )
                            : const SizedBox(key: ValueKey('empty')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _ProfileBottomBar(
        isAdmin: _role.toLowerCase() == 'admin',
        onTap: (i) => Navigator.pop(context, i),
      ),
    );
  }
}

class _ProfileBottomBar extends StatelessWidget {
  final bool isAdmin;
  final ValueChanged<int> onTap;
  const _ProfileBottomBar({required this.isAdmin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final inactive = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    final active = Theme.of(context).colorScheme.primary;
    final items = isAdmin
        ? [
            {'icon': Icons.home_outlined, 'label': 'Resumo'},
            {'icon': Icons.swap_vert, 'label': 'Fluxo'},
            {'icon': Icons.inventory_2_outlined, 'label': 'Estoque'},
            {'icon': Icons.insert_chart_outlined, 'label': 'Relatorios'},
          ]
        : [
            {'icon': Icons.home_outlined, 'label': 'Inicio'},
            {'icon': Icons.download_rounded, 'label': 'Entradas'},
            {'icon': Icons.upload_rounded, 'label': 'Saidas'},
          ];
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i]['icon'] as IconData, color: i == 0 ? active : inactive, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(fontSize: 11, color: i == 0 ? active : inactive, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
