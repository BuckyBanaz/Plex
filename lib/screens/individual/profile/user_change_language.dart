import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/screens/widgets/custom_text_field.dart';
import '../../../constant/app_colors.dart';
import '../../../services/translations/locale_controller.dart';

class UserChangeLanguageScreen extends StatefulWidget {
  UserChangeLanguageScreen({Key? key}) : super(key: key);

  @override
  State<UserChangeLanguageScreen> createState() =>
      _UserChangeLanguageScreenState();
}

class _UserChangeLanguageScreenState extends State<UserChangeLanguageScreen> {
  final LocaleController controller = Get.find<LocaleController>();

  final List<_LanguageItem> _languages = [
    _LanguageItem('🇺🇸', 'English (United States)', 'en_US'),
    _LanguageItem('🇸🇦', 'العربية', 'ar_SA'),
  ];

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<_LanguageItem> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_languages);
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // debounce to avoid filtering on every keystroke immediately
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchCtrl.text.trim().toLowerCase();
      if (query.isEmpty) {
        setState(() => _filtered = List.from(_languages));
        return;
      }
      setState(() {
        _filtered = _languages.where((lang) {
          final name = lang.name.toLowerCase();
          final code = lang.code.toLowerCase();
          final flag = lang.flag.toLowerCase();
          return name.contains(query) || code.contains(query) || flag.contains(query);
        }).toList();
      });
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _filtered = List.from(_languages));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text(
          'change_language'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(IconlyLight.search, color: Colors.grey[400]),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                ),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close, size: 20),
                ),
              ),
            ),
          ),

          // Language List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:  [
                  Icon(Icons.translate, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No results found', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade200,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final lang = _filtered[index];

                return Obx(() {
                  final String currentCode =
                  LocaleController.localeToCode(controller.current.value);
                  final bool isSelected = (currentCode == lang.code);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    leading: Text(
                      lang.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      lang.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                      CupertinoIcons.check_mark_circled,
                      color: AppColors.primary,
                    )
                        : null,
                    onTap: () {
                      controller.saveAndChange(lang.code);
                      // optionally give small feedback
                      Get.snackbar(
                        'Language changed',
                        '${_languageLabelFor(lang.code)}',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(milliseconds: 900),
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  String _languageLabelFor(String code) {
    switch (code) {
      case 'ar_SA':
        return 'العربية';
      case 'en_US':
      default:
        return 'English (United States)';
    }
  }
}

class _LanguageItem {
  final String flag;
  final String name;
  final String code;

  _LanguageItem(this.flag, this.name, this.code);
}
