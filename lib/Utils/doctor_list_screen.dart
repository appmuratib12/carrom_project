import 'package:flutter/material.dart';


// ─── Brand colours ────────────────────────────────────────────────────────────
class AppColors {
  static const green = Color(0xFF1D9E75);
  static const greenLight = Color(0xFFE1F5EE);
  static const greenDark = Color(0xFF0F6E56);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const surface = Color(0xFFF9FAFB);
  static const sidebarBg = Color(0xFFF3F4F6);
  static const white = Colors.white;
  static const resetRed = Color(0xFFD85A30);
  static const resetRedLight = Color(0xFFFAECE7);
}

// ─── Filter Models ────────────────────────────────────────────────────────────
enum FilterType { experience, language, gender }

class FilterOption {
  final String id;
  final String label;
  const FilterOption({required this.id, required this.label});
}

class FilterConfig {
  final FilterType type;
  final String title;
  final IconData icon;
  final List<FilterOption> options;
  final bool isMultiSelect;

  const FilterConfig({
    required this.type,
    required this.title,
    required this.icon,
    required this.options,
    this.isMultiSelect = true,
  });
}

final List<FilterConfig> filterConfigs = [
  FilterConfig(
    type: FilterType.experience,
    title: 'Experience',
    icon: Icons.work_outline_rounded,
    isMultiSelect: true,
    options: [
      FilterOption(id: 'lt10', label: 'Less than 10 years'),
      FilterOption(id: '10-15', label: '10-15 years'),
      FilterOption(id: '15-20', label: '15 - 20 years'),
      FilterOption(id: 'gt20', label: 'More than 20 years'),
    ],
  ),
  FilterConfig(
    type: FilterType.language,
    title: 'Language',
    icon: Icons.language_rounded,
    isMultiSelect: true,
    options: [
      FilterOption(id: 'bengali', label: 'Bengali'),
      FilterOption(id: 'english', label: 'English'),
      FilterOption(id: 'gujarati', label: 'Gujarati'),
      FilterOption(id: 'hindi', label: 'Hindi'),
      FilterOption(id: 'kannada', label: 'Kannada'),
      FilterOption(id: 'malayalam', label: 'Malayalam'),
      FilterOption(id: 'marathi', label: 'Marathi'),
      FilterOption(id: 'odia', label: 'Odia'),
      FilterOption(id: 'punjabi', label: 'Punjabi'),
      FilterOption(id: 'tamil', label: 'Tamil'),
      FilterOption(id: 'telugu', label: 'Telugu'),
      FilterOption(id: 'urdu', label: 'Urdu'),
    ],
  ),
  FilterConfig(
    type: FilterType.gender,
    title: 'Gender',
    icon: Icons.people_outline_rounded,
    isMultiSelect: false,
    options: [
      FilterOption(id: 'any', label: 'No preference'),
      FilterOption(id: 'male', label: 'Male doctor'),
      FilterOption(id: 'female', label: 'Female doctor'),
    ],
  ),
];

// ─── Filter State ─────────────────────────────────────────────────────────────
class FilterState {
  final Set<String> experience;
  final Set<String> language;
  final String? gender;

  const FilterState({
    this.experience = const {},
    this.language = const {},
    this.gender,
  });

  FilterState copyWith({
    Set<String>? experience,
    Set<String>? language,
    String? gender,
    bool clearGender = false,
  }) {
    return FilterState(
      experience: experience ?? {...this.experience},
      language: language ?? {...this.language},
      gender: clearGender ? null : (gender ?? this.gender),
    );
  }

  Set<String> multiSelectFor(FilterType type) {
    if (type == FilterType.experience) return experience;
    if (type == FilterType.language) return language;
    return {};
  }

  int countFor(FilterType type) {
    if (type == FilterType.experience) return experience.length;
    if (type == FilterType.language) return language.length;
    if (type == FilterType.gender) return gender != null ? 1 : 0;
    return 0;
  }

  int get totalCount => experience.length + language.length + (gender != null ? 1 : 0);
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  FilterState _filters = const FilterState();

  void _openFilterSheet({FilterType initialTab = FilterType.experience}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => FilterBottomSheet(
          initialTab: initialTab,
          currentFilters: _filters,
          scrollController: scrollController,
          onApply: (updated) => setState(() => _filters = updated),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text(
          'Cardiac Sciences',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        mainAxisAlignment:MainAxisAlignment.start,
        children: [
          SizedBox(height:10,),
          Container(
            color:Colors.white,
            padding: const EdgeInsets.only(
                left: 15, right: 15, bottom: 12, top: 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filterConfigs.map((cfg) {
                  final count = _filters.countFor(cfg.type);
                  final isActive = count > 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      config: cfg,
                      isActive: isActive,
                      count: count,
                      onTap: () =>
                          _openFilterSheet(initialTab: cfg.type),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Container(height: 1, color: AppColors.border),

          // ── Doctor cards ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: const [
                _DoctorCard(
                  initials: 'RK',
                  name: 'Dr. Rajesh Kumar',
                  specialty: 'Cardiologist',
                  languages: 'Hindi, English',
                  experience: '22 yrs',
                  avatarColor: Color(0xFFB5D4F4),
                  avatarTextColor: Color(0xFF185FA5),
                ),
                SizedBox(height: 10),
                _DoctorCard(
                  initials: 'PS',
                  name: 'Dr. Priya Sharma',
                  specialty: 'Cardiac Surgeon',
                  languages: 'English',
                  experience: '14 yrs',
                  avatarColor: Color(0xFFF4C0D1),
                  avatarTextColor: Color(0xFF993556),
                ),
                SizedBox(height: 10),
                _DoctorCard(
                  initials: 'AM',
                  name: 'Dr. Arjun Mehta',
                  specialty: 'Interventional Cardiology',
                  languages: 'Hindi',
                  experience: '8 yrs',
                  avatarColor: Color(0xFFFAC775),
                  avatarTextColor: Color(0xFF854F0B),
                ),
                SizedBox(height: 10),
                _DoctorCard(
                  initials: 'SN',
                  name: 'Dr. Sunita Nair',
                  specialty: 'Electrophysiologist',
                  languages: 'Tamil, English',
                  experience: '17 yrs',
                  avatarColor: Color(0xFFC0DD97),
                  avatarTextColor: Color(0xFF3B6D11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final FilterConfig config;
  final bool isActive;
  final int count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.config,
    required this.isActive,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.green : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.green : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              config.icon,
              size: 14,
              color: isActive
                  ? AppColors.white
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              config.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.white
                    : AppColors.textSecondary,
              ),
            ),
            if (isActive && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isActive
                    ? AppColors.white
                    : AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────
class FilterBottomSheet extends StatefulWidget {
  final FilterType initialTab;
  final FilterState currentFilters;
  final ScrollController scrollController;
  final ValueChanged<FilterState> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialTab,
    required this.currentFilters,
    required this.scrollController,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterType _activeTab;
  late FilterState _localFilters;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _localFilters = widget.currentFilters.copyWith();
  }

  FilterConfig get _activeCfg =>
      filterConfigs.firstWhere((c) => c.type == _activeTab);

  // ── toggle multi-select ──
  void _toggleMulti(String id) {
    setState(() {
      final type = _activeTab;
      final cur = {..._localFilters.multiSelectFor(type)};
      cur.contains(id) ? cur.remove(id) : cur.add(id);
      if (type == FilterType.experience) {
        _localFilters = _localFilters.copyWith(experience: cur);
      } else {
        _localFilters = _localFilters.copyWith(language: cur);
      }
    });
  }

  // ── toggle select-all ──
  void _toggleAll() {
    setState(() {
      final type = _activeTab;
      final allIds =
      _activeCfg.options.map((o) => o.id).toSet();
      final cur = _localFilters.multiSelectFor(type);
      final next =
      cur.length == allIds.length ? <String>{} : allIds;
      if (type == FilterType.experience) {
        _localFilters = _localFilters.copyWith(experience: next);
      } else {
        _localFilters = _localFilters.copyWith(language: next);
      }
    });
  }

  // ── radio select ──
  void _selectRadio(String id) {
    setState(() {
      if (_localFilters.gender == id) {
        _localFilters = _localFilters.copyWith(clearGender: true);
      } else {
        _localFilters = _localFilters.copyWith(gender: id);
      }
    });
  }

  // ── reset active tab only ──
  void _resetActiveTab() {
    setState(() {
      switch (_activeTab) {
        case FilterType.experience:
          _localFilters = _localFilters.copyWith(experience: {});
          break;
        case FilterType.language:
          _localFilters = _localFilters.copyWith(language: {});
          break;
        case FilterType.gender:
          _localFilters = _localFilters.copyWith(clearGender: true);
          break;
      }
    });
  }

  int _tabCount(FilterType type) => _localFilters.countFor(type);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── drag handle ──
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── header row ──
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _resetActiveTab,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.resetRedLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.resetRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: AppColors.border),

          // ── sidebar + content ──
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SIDEBAR
                Container(
                  width: 130,
                  color: AppColors.sidebarBg,
                  child: ListView(
                    controller: widget.scrollController,
                    padding: EdgeInsets.zero,
                    children: filterConfigs.map((cfg) {
                      final isActive = _activeTab == cfg.type;
                      final count = _tabCount(cfg.type);
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _activeTab = cfg.type),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.green
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                  color: AppColors.border
                                      .withValues(alpha: 0.6),
                                  width: 0.5),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  cfg.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isActive
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (count > 0)
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white
                                        .withValues(alpha: 0.3)
                                        : AppColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? AppColors.white
                                            : AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // RIGHT CONTENT
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),

          // ── Apply button ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                  top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_localFilters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Right panel content ───────────────────────────────────────────────────
  Widget _buildContent() {
    final cfg = _activeCfg;

    if (!cfg.isMultiSelect) {
      // Radio list (Gender)
      return ListView(
        padding: const EdgeInsets.only(top: 4),
        children: cfg.options.map((opt) {
          final checked = _localFilters.gender == opt.id;
          return _OptionRow(
            label: opt.label,
            isSelected: checked,
            isRadio: true,
            onTap: () => _selectRadio(opt.id),
          );
        }).toList(),
      );
    }

    // Checkbox list (Experience / Language)
    final selected = _localFilters.multiSelectFor(cfg.type);
    final allSelected = selected.length == cfg.options.length;

    return ListView(
      padding: const EdgeInsets.only(top: 4),
      children: [
        // Select All row
        _OptionRow(
          label: 'Select All (${cfg.options.length})',
          isSelected: allSelected,
          isSelectAll: true,
          onTap: _toggleAll,
        ),
        ...cfg.options.map((opt) {
          final checked = selected.contains(opt.id);
          return _OptionRow(
            label: opt.label,
            isSelected: checked,
            onTap: () => _toggleMulti(opt.id),
          );
        }),
      ],
    );
  }
}

// ─── Option Row ───────────────────────────────────────────────────────────────
class _OptionRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isRadio;
  final bool isSelectAll;
  final VoidCallback onTap;

  const _OptionRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isRadio = false,
    this.isSelectAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected && !isSelectAll
              ? AppColors.greenLight.withValues(alpha: 0.5)
              : Colors.white,
          border: Border(
            bottom: BorderSide(
                color: AppColors.border.withValues(alpha: 0.7),
                width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isSelectAll ? 13 : 14,
                  fontWeight: isSelectAll
                      ? FontWeight.w500
                      : (isSelected
                      ? FontWeight.w500
                      : FontWeight.w400),
                  color: isSelected && !isSelectAll
                      ? AppColors.greenDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isRadio)
              _RadioDot(checked: isSelected)
            else
              _CheckBox(checked: isSelected),
          ],
        ),
      ),
    );
  }
}

// ─── Checkbox ─────────────────────────────────────────────────────────────────
class _CheckBox extends StatelessWidget {
  final bool checked;
  const _CheckBox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? AppColors.green : AppColors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: checked ? AppColors.green : AppColors.border,
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded,
          color: Colors.white, size: 13)
          : null,
    );
  }
}

// ─── Radio dot ────────────────────────────────────────────────────────────────
class _RadioDot extends StatelessWidget {
  final bool checked;
  const _RadioDot({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
          checked ? AppColors.green : AppColors.border,
          width: 2,
        ),
      ),
      child: checked
          ? Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
          ),
        ),
      )
          : null,
    );
  }
}

// ─── Doctor Card ──────────────────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final String initials;
  final String name;
  final String specialty;
  final String languages;
  final String experience;
  final Color avatarColor;
  final Color avatarTextColor;

  const _DoctorCard({
    required this.initials,
    required this.name,
    required this.specialty,
    required this.languages,
    required this.experience,
    required this.avatarColor,
    required this.avatarTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: avatarTextColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$specialty · $languages',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              experience,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.greenDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}