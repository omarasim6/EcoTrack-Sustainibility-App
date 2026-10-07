import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import '../auth/login_page.dart';

const primaryGreen = Color(0xFF134D3F);
const bgColor = Color(0xFFEEF4F6);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  String country = "Pakistan";
  String city = "Rawalpindi";
  int totalCoins = 0;

  bool notifications = true;
  bool darkMode = false;
  bool twoStepVerification = false;

  final Map<String, List<String>> countryCityMap = const {
    "Pakistan": ["Rawalpindi", "Islamabad", "Lahore", "Karachi"],
    "UAE": ["Dubai", "Abu Dhabi"],
    "USA": ["New York", "Los Angeles"],
  };

  final Map<String, String> countryFlags = const {
    "Pakistan": "🇵🇰",
    "UAE": "🇦🇪",
    "USA": "🇺🇸",
  };

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Map<String, dynamic> _decodeUsers(SharedPreferences prefs) {
    try {
      final raw = prefs.getString('users') ?? '';
      if (raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }

  Map<String, dynamic> _decodeRecord(Map<String, dynamic> users, String key) {
    final val = users[key];
    if (val == null) return {};
    if (val is Map) return Map<String, dynamic>.from(val);
    return {};
  }

  Future<void> _loadUser() async {
    final prefs        = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString('currentUser') ?? '';
    final users        = _decodeUsers(prefs);
    final userData     = _decodeRecord(users, currentEmail);

    setState(() {
      email      = currentEmail;
      name       = userData['name']       as String? ?? prefs.getString('name') ?? 'No Name';
      country    = userData['country']    as String? ?? 'Pakistan';
      city       = userData['city']       as String? ?? 'Rawalpindi';
      totalCoins = userData['totalCoins'] as int?    ?? prefs.getInt('totalCoins') ?? 0;
    });
  }

  Future<void> _persistUserFields(Map<String, dynamic> updates) async {
    final prefs        = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString('currentUser') ?? '';
    final users        = _decodeUsers(prefs);
    final userData     = _decodeRecord(users, currentEmail);

    final newEmail  = (updates['email'] as String?)?.trim() ?? currentEmail;
    final toStore   = Map<String, dynamic>.from(updates)..remove('email');

    userData.addAll(toStore);

    if (newEmail.isNotEmpty && newEmail != currentEmail) {
      users.remove(currentEmail);
      users[newEmail] = userData;

      await prefs.setString('currentUser', newEmail);
      await prefs.setString('email', newEmail);

      if (prefs.getBool('rememberMe') ?? false) {
        await prefs.setString('rememberedEmail', newEmail);
      }
    } else {
      users[currentEmail] = userData;
    }

    if (toStore.containsKey('name')) {
      await prefs.setString('name', userData['name'] as String? ?? '');
    }

    await prefs.setString('users', jsonEncode(users));
  }

  Future<void> _saveUserStat(String key, dynamic value) async {
    await _persistUserFields({key: value});
  }

  @override
  Widget build(BuildContext context) {
    final background = darkMode ? Colors.black : bgColor;
    final textColor  = darkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: _showCoinInfo,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade400,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 5),
                    Text(
                      '$totalCoins',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: primaryGreen),
          ),
          const SizedBox(height: 12),
          Text(name, style: TextStyle(fontSize: 20, color: textColor)),
          Text(email, style: TextStyle(color: textColor.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(
            "$city, $country",
            style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
          ),

          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade300, Colors.orange.shade400],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EcoCoins',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$totalCoins coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Daily login\nrewards',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _tile("Your profile",    Icons.person_outline,    _openProfile,        textColor),
          _tile("Change Password", Icons.lock_outline,      _openChangePassword, textColor),
          _tile("Settings",        Icons.settings_outlined, _openSettings,       textColor),
          _tile("Help Center",     Icons.help_outline,      _openHelp,           textColor),
          _tile("Logout",          Icons.logout,            _openLogout,         textColor, isDanger: true),
        ],
      ),
    );
  }

  void _showCoinInfo() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Text('🪙', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text('You have $totalCoins EcoCoins from daily login streaks!'),
      ]),
      backgroundColor: primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Widget _tile(
      String title,
      IconData icon,
      VoidCallback onTap,
      Color textColor, {
        bool isDanger = false,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDanger ? Colors.red : primaryGreen),
        title: Text(title,
            style: TextStyle(color: isDanger ? Colors.red : textColor)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _openProfile() {
    final formKey           = GlobalKey<FormState>();
    final nameCtrl          = TextEditingController(text: name);
    final emailCtrl         = TextEditingController(text: email);
    String selectedCountry  = country;
    String selectedCity     = city;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final cities = countryCityMap[selectedCountry] ?? [];
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16, right: 16, top: 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.65,
              child: Form(
                key: formKey,
                child: Column(children: [
                  _sheetHeader(ctx, "Edit Profile"),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _field("Name",  nameCtrl),
                          _field("Email", emailCtrl),
                          const Divider(height: 30),
                          Row(children: [
                            const Icon(Icons.location_on,
                                color: primaryGreen, size: 20),
                            const SizedBox(width: 6),
                            const Text("Location",
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 20),
                          _animatedSelector(
                            title: "Country",
                            value:
                            "${countryFlags[selectedCountry]} $selectedCountry",
                            onTap: () => _openSelector(
                              title: "Select Country",
                              items: countryCityMap.keys.toList(),
                              selected: selectedCountry,
                              onSelected: (val) => setModalState(() {
                                selectedCountry = val;
                                selectedCity    = countryCityMap[val]!.first;
                              }),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _animatedSelector(
                            title: "City",
                            value: selectedCity,
                            onTap: () => _openSelector(
                              title: "Select City",
                              items: cities,
                              selected: selectedCity,
                              onSelected: (val) =>
                                  setModalState(() => selectedCity = val),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () async {
                              final pos = await _getLocation();
                              if (!ctx.mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "Lat: ${pos.latitude}, Lng: ${pos.longitude}"),
                              ));
                            },
                            icon: const Icon(Icons.my_location,
                                color: Colors.white),
                            label: const Text("Auto Detect Location",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final newName  = nameCtrl.text.trim();
                      final newEmail = emailCtrl.text.trim();

                      await _persistUserFields({
                        'name':    newName,
                        'email':   newEmail,
                        'country': selectedCountry,
                        'city':    selectedCity,
                      });

                      setState(() {
                        name    = newName;
                        email   = newEmail;
                        country = selectedCountry;
                        city    = selectedCity;
                      });

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Profile updated ✅'),
                        backgroundColor: primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ));
                    },
                    child: const Text("Save",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }


  void _openChangePassword() {
    final formKey         = GlobalKey<FormState>();
    final currentPassCtrl = TextEditingController();
    final newPassCtrl     = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureCurrent   = true;
    bool obscureNew       = true;
    bool obscureConfirm   = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.58,
            child: Form(
              key: formKey,
              child: Column(children: [
                _sheetHeader(ctx, "Change Password"),
                const SizedBox(height: 16),
                _passwordField(
                  label: "Current Password",
                  controller: currentPassCtrl,
                  obscure: obscureCurrent,
                  onToggle: () =>
                      setModalState(() => obscureCurrent = !obscureCurrent),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _passwordField(
                  label: "New Password",
                  controller: newPassCtrl,
                  obscure: obscureNew,
                  onToggle: () =>
                      setModalState(() => obscureNew = !obscureNew),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Min 6 characters'
                      : null,
                ),
                const SizedBox(height: 12),
                _passwordField(
                  label: "Confirm New Password",
                  controller: confirmPassCtrl,
                  obscure: obscureConfirm,
                  onToggle: () =>
                      setModalState(() => obscureConfirm = !obscureConfirm),
                  validator: (v) =>
                  v != newPassCtrl.text ? 'Passwords do not match' : null,
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final prefs            = await SharedPreferences.getInstance();
                    final currentUserEmail = prefs.getString('currentUser') ?? '';
                    final users            = _decodeUsers(prefs);
                    final userData         = _decodeRecord(users, currentUserEmail);
                    final storedPass       = userData['password'] as String?;

                    if (storedPass == null ||
                        storedPass != currentPassCtrl.text) {
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Current password is incorrect'),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ));
                      return;
                    }

                    await _persistUserFields({'password': newPassCtrl.text});

                    if (prefs.getBool('rememberMe') ?? false) {
                      await prefs.setString(
                          'rememberedPassword', newPassCtrl.text);
                    }

                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Password updated ✅'),
                      backgroundColor: primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  child: const Text("Update Password",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.3,
            child: Column(children: [
              _sheetHeader(ctx, "Settings"),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text("Notifications"),
                value: notifications,
                activeColor: primaryGreen,
                onChanged: (val) {
                  setModalState(() => notifications = val);
                  setState(() => notifications = val);
                },
              ),
              SwitchListTile(
                title: const Text("Dark Mode"),
                value: darkMode,
                activeColor: primaryGreen,
                onChanged: (val) {
                  setModalState(() => darkMode = val);
                  setState(() => darkMode = val);
                },
              ),
              SwitchListTile(
                title: const Text("2-Step Verification"),
                value: twoStepVerification,
                activeColor: primaryGreen,
                onChanged: (val) {
                  setModalState(() => twoStepVerification = val);
                  setState(() => twoStepVerification = val);
                },
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Save",
                    style: TextStyle(color: Colors.white)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _openHelp() {
    final messageCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.67,
          child: Column(children: [
            _sheetHeader(ctx, "Help Center"),
            _field("Message", messageCtrl,
                icon: Icons.chat_bubble_outline, maxLines: 4),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.help_outline, color: primaryGreen, size: 18),
              const SizedBox(width: 6),
              const Text("FAQs",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ]),
            _faqTile(Icons.person_outline, "How to change profile?",
                "Go to Your Profile and edit info."),
            _faqTile(Icons.dark_mode_outlined, "How to enable dark mode?",
                "Go to Settings and toggle Dark Mode."),
            _faqTile(Icons.privacy_tip_outlined, "Is my data safe?",
                "Yes, it is securely stored on your device."),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Submit",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _faqTile(IconData icon, String q, String a) => ExpansionTile(
    leading: Icon(icon, color: primaryGreen),
    title: Text(q),
    children: [
      Padding(padding: const EdgeInsets.all(12), child: Text(a))
    ],
  );

  void _openLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Logout",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("Are you sure you want to logout?",
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel",
                style: GoogleFonts.poppins(
                    color: primaryGreen, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();

              final currentEmail = prefs.getString('currentUser') ?? '';
              if ((prefs.getBool('rememberMe') ?? false) &&
                  currentEmail.isNotEmpty) {
                await prefs.setString('rememberedEmail', currentEmail);
              }

              const sessionKeys = [
                'loggedIn',
                'currentUser',
                'name',
                'email',
                'streak',
                'last_open_time',
                'totalCoins',
                'totalQuiz',
                'totalVideos',
              ];
              for (final key in sessionKeys) {
                await prefs.remove(key);
              }

              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const LoginPage(),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
                    (route) => false,
              );
            },
            child: Text("Logout",
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController c, {
        IconData? icon,
        int maxLines = 1,
      }) {
    final focusNode = FocusNode();
    return StatefulBuilder(
      builder: (context, ss) {
        focusNode.addListener(() => ss(() {}));
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: c,
            focusNode: focusNode,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: (icon != null && !focusNode.hasFocus)
                  ? Icon(icon, color: primaryGreen)
                  : null,
              labelText: label,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.lock_outline, color: primaryGreen),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: primaryGreen,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _sheetHeader(BuildContext ctx, String title) => Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back, color: primaryGreen),
        onPressed: () => Navigator.pop(ctx),
      ),
      const SizedBox(width: 4),
      Text(title,
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600)),
    ],
  );

  Future<Position> _getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception("Location services disabled");
    }
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.deniedForever) {
      throw Exception("Location permissions permanently denied");
    }
    return Geolocator.getCurrentPosition();
  }

  Widget _animatedSelector({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              Row(children: [
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, color: primaryGreen),
              ]),
            ],
          ),
        ),
      );

  void _openSelector({
    required String title,
    required List<String> items,
    required String selected,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHeader(ctx, title),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    title: Text(item),
                    trailing: item == selected
                        ? const Icon(Icons.check, color: primaryGreen)
                        : null,
                    onTap: () {
                      onSelected(item);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}