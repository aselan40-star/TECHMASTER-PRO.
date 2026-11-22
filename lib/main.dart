import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TechMasterProApp());
}

/// ---------------------------------------------------------------------------
/// ROLES & FORMATTING HELPERS
/// ---------------------------------------------------------------------------

enum UserRole {
  guest,
  studentPending,
  studentApproved,
  admin,
}

extension UserRoleExt on UserRole {
  String get key {
    switch (this) {
      case UserRole.guest:
        return 'guest';
      case UserRole.studentPending:
        return 'student_pending';
      case UserRole.studentApproved:
        return 'student_approved';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get label {
    switch (this) {
      case UserRole.guest:
        return 'Guest / Customer';
      case UserRole.studentPending:
        return 'Student (Pending)';
      case UserRole.studentApproved:
        return 'Student (Approved)';
      case UserRole.admin:
        return 'Admin / Owner';
    }
  }

  bool get canAccessAcademy =>
      this == UserRole.studentApproved || this == UserRole.admin;

  bool get isAdmin => this == UserRole.admin;
}

String formatRs(int amount) {
  final str = amount.toString();
  final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return 'Rs. $formatted';
}

/// ---------------------------------------------------------------------------
/// DATA MODELS
/// ---------------------------------------------------------------------------

enum RepairStatus { received, inRepair, ready }

extension RepairStatusExt on RepairStatus {
  String get label {
    switch (this) {
      case RepairStatus.received:
        return 'Received';
      case RepairStatus.inRepair:
        return 'In Repair';
      case RepairStatus.ready:
        return 'Ready';
    }
  }

  Color get color {
    switch (this) {
      case RepairStatus.received:
        return const Color(0xFFD97706);
      case RepairStatus.inRepair:
        return const Color(0xFF2563EB);
      case RepairStatus.ready:
        return const Color(0xFF059669);
    }
  }

  RepairStatus get next {
    switch (this) {
      case RepairStatus.received:
        return RepairStatus.inRepair;
      case RepairStatus.inRepair:
        return RepairStatus.ready;
      case RepairStatus.ready:
        return RepairStatus.received;
    }
  }
}

class RepairJob {
  final String ticketId;
  final String customerOrShop;
  final String phoneModel;
  final String fault;
  RepairStatus status;

  RepairJob({
    required this.ticketId,
    required this.customerOrShop,
    required this.phoneModel,
    required this.fault,
    this.status = RepairStatus.received,
  });
}

class AcademyGuide {
  final String id;
  final String title;
  final String category;
  final String summary;
  final List<String> steps;
  final String photoUrl;

  AcademyGuide({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.steps,
    this.photoUrl = '',
  });
}

class StoreItem {
  final String id;
  final String title;
  final String category;
  final int priceRs;
  final String badge;
  final String summary;
  final String guideOrSpecs;

  StoreItem({
    required this.id,
    required this.title,
    required this.category,
    required this.priceRs,
    required this.badge,
    required this.summary,
    required this.guideOrSpecs,
  });
}

class SoftwareItem {
  final String id;
  final String title;
  final String category;
  final String badge;
  final String summary;
  final String howToUse;
  final String linkOrDeskInfo;
  final bool requiresApprovedStudent;

  SoftwareItem({
    required this.id,
    required this.title,
    required this.category,
    required this.badge,
    required this.summary,
    required this.howToUse,
    required this.linkOrDeskInfo,
    this.requiresApprovedStudent = false,
  });
}

class StudentRecord {
  final String id;
  final String name;
  final String phone;
  final String batch;
  int totalFee;
  int paidAmount;
  bool isApproved;

  StudentRecord({
    required this.id,
    required this.name,
    required this.phone,
    required this.batch,
    this.totalFee = 35000,
    required this.paidAmount,
    this.isApproved = false,
  });

  int get dueAmount => (totalFee - paidAmount).clamp(0, totalFee);
}

/// ---------------------------------------------------------------------------
/// MAIN APP & STATE CONTAINER
/// ---------------------------------------------------------------------------

class TechMasterProApp extends StatelessWidget {
  const TechMasterProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechMaster Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF0284C7),
          surface: const Color(0xFFF8FAFC),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  UserRole _currentRole = UserRole.guest;
  String? _currentUserStudentId;

  final List<RepairJob> _repairJobs = [
    RepairJob(
      ticketId: 'REP-201',
      customerOrShop: 'Kasun Perera',
      phoneModel: 'iPhone 13 Pro',
      fault: 'No Power / Short on VDD_MAIN',
      status: RepairStatus.inRepair,
    ),
    RepairJob(
      ticketId: 'REP-202',
      customerOrShop: 'City Mobile Hub (B2B)',
      phoneModel: 'Samsung Galaxy A54',
      fault: 'Charging IC Replacement & Sub-board Flex',
      status: RepairStatus.ready,
    ),
    RepairJob(
      ticketId: 'REP-203',
      customerOrShop: 'Nimal Silva',
      phoneModel: 'Redmi Note 12',
      fault: 'Dead Boot after Water Damage',
      status: RepairStatus.received,
    ),
  ];

  final List<AcademyGuide> _academyGuides = [
    AcademyGuide(
      id: 'AC-01',
      title: 'iPhone No-Power 4-Step DC Supply Diagnosis',
      category: 'Common Faults',
      summary:
          'Fast isolation of primary vs secondary line shorts using DC power supply boot amp readings.',
      steps: [
        'Connect board to DC Power Supply set at 4.2V / 3.0A without pressing power key.',
        'If current jumps immediately before boot press, primary rail (VDD_MAIN / BATT_VCC) is shorted.',
        'Apply rosin smoke and inject 1.0V–1.8V on the shorted line to spot the heating capacitor.',
        'If standby is 0.000A and pressing power sticks at 60–90mA, check PMIC clock/reset lines and NAND.',
      ],
      photoUrl: '',
    ),
    AcademyGuide(
      id: 'AC-02',
      title: 'Safe Glue Removal Around Black-Pasted CPU/RAM',
      category: 'Easy Tricks',
      summary:
          'Prevent pad ripping when lifting underfilled BGA chips on Samsung & Xiaomi boards.',
      steps: [
        'Set hot air station to 260°C with 40% airflow to soften edge epoxy.',
        'Use a thin hooked blade gently at 15 degrees—never pry upward.',
        'Clean remaining resin on pads with 320°C iron, flux, and flat wick without pressure.',
      ],
      photoUrl: '',
    ),
    AcademyGuide(
      id: 'AC-03',
      title: 'Samsung A-Series Backlight & Display Boost IC Ways',
      category: 'IC Ways',
      summary:
          'Pinout trace for Anode (LED+), Cathode (LED-), and PWM enable lines when display is dark.',
      steps: [
        'Check diode value on Display Connector Anode pin (expected 0.450V–0.650V in reverse bias).',
        'Verify VBAT (3.8V–4.2V) reaches the boost coil input before LCD is connected.',
        'If 4.2V is present at Anode but does not boost to 18V–24V on boot, replace Boost IC & Schottky diode.',
      ],
      photoUrl: '',
    ),
  ];

  final List<StoreItem> _storeItems = [
    StoreItem(
      id: 'ST-01',
      title: 'Quick 861DW Hot Air Rework Station',
      category: 'Repair Tools',
      priceRs: 68500,
      badge: 'In Stock',
      summary: '1000W brushless vortex air station with 3 programmable channels.',
      guideOrSpecs:
          'Recommended Profiles:\n• CH1 (Charging Ports): 340°C / Air 50\n• CH2 (BGA IC Lift): 380°C / Air 45\n• CH3 (Shield Removal): 410°C / Air 60',
    ),
    StoreItem(
      id: 'ST-02',
      title: 'Mechanic Short Killer Pro Box (30A)',
      category: 'Repair Tools',
      priceRs: 14500,
      badge: 'In Stock',
      summary: 'Instant short-circuit thermal locator with audible buzzer & polarity protection.',
      guideOrSpecs:
          'Usage Guide:\n• Always start at 1.2V / 5A on CPU/NAND adjacent lines.\n• Never exceed 1.8V on secondary buck lines to protect SoC.',
    ),
    StoreItem(
      id: 'ST-03',
      title: 'iPhone 12 (128GB) — Factory Unlocked',
      category: 'Buy / Sell Phones',
      priceRs: 118000,
      badge: 'Grade A • 89% Battery',
      summary: 'Original housing & True Tone active. Full 30-day shop warranty.',
      guideOrSpecs:
          'Inspection & Trade-In:\n• All FaceID, cameras, and 5G bands verified.\n• Visit Repair Desk or WhatsApp +94 77 000 0000 for trade-in valuation.',
    ),
  ];

  final List<SoftwareItem> _softwareItems = [
    SoftwareItem(
      id: 'SW-01',
      title: 'TechMaster Schematic & Bitmap Helper',
      category: 'Custom Apps',
      badge: 'Academy Exclusive',
      summary: 'Offline boardview, diode-mode reference values, and charging ways database.',
      howToUse:
          '1. Select phone brand & PCB revision.\n2. Tap any connector pin to view expected diode reading.\n3. Follow highlighted red trace to PMIC/CPU.',
      linkOrDeskInfo: 'Portal: academy.techmasterpro.lk/bitmap (Student Login)',
      requiresApprovedStudent: true,
    ),
    SoftwareItem(
      id: 'SW-02',
      title: 'UnlockTool / Chimera Server Credits',
      category: 'Unlock Tools',
      badge: 'Instant Activation',
      summary: 'FRP reset, Mi Account bypass, bootloader unlock & MDM services for shops.',
      howToUse:
          '1. Install latest USB drivers.\n2. Put device in EDL / BROM / Download mode.\n3. Request instant OTP activation from Admin Desk.',
      linkOrDeskInfo: 'Service Desk WhatsApp: +94 77 000 0000',
      requiresApprovedStudent: false,
    ),
    SoftwareItem(
      id: 'SW-03',
      title: 'Qualcomm HS-USB QDLoader 9008 & MTK VCOM Pack',
      category: 'Drivers & Flash',
      badge: 'Verified v2.4',
      summary: 'Clean Windows 10/11 signed drivers for dead-boot flashing & EDL recovery.',
      howToUse:
          '1. Disable Windows Driver Signature Enforcement if needed.\n2. Run installer as Administrator and reboot PC.\n3. Verify port detection in Device Manager.',
      linkOrDeskInfo: 'Download Mirror: mirror.techmasterpro.lk/drivers-pack',
      requiresApprovedStudent: false,
    ),
  ];

  final List<StudentRecord> _students = [
    StudentRecord(
      id: 'STU-101',
      name: 'Tharindu Bandara',
      phone: '+94 71 234 5678',
      batch: 'Weekday',
      totalFee: 35000,
      paidAmount: 20000,
      isApproved: true,
    ),
    StudentRecord(
      id: 'STU-102',
      name: 'Sajith Fernando',
      phone: '+94 76 987 6543',
      batch: 'Sunday',
      totalFee: 35000,
      paidAmount: 15000,
      isApproved: false,
    ),
  ];

  void _navigateToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _addRepairJob(RepairJob job) {
    setState(() => _repairJobs.insert(0, job));
  }

  void _cycleRepairStatus(RepairJob job) {
    if (!_currentRole.isAdmin) return;
    setState(() => job.status = job.status.next);
  }

  void _addAcademyGuide(AcademyGuide guide) {
    setState(() => _academyGuides.insert(0, guide));
  }

  void _addStoreItem(StoreItem item) {
    setState(() => _storeItems.insert(0, item));
  }

  void _addSoftwareItem(SoftwareItem item) {
    setState(() => _softwareItems.insert(0, item));
  }

  void _registerStudent(StudentRecord record) {
    setState(() {
      _students.insert(0, record);
      _currentUserStudentId = record.id;
      if (_currentRole == UserRole.guest) {
        _currentRole = UserRole.studentPending;
      }
    });
  }

  void _approveStudent(StudentRecord student) {
    setState(() {
      student.isApproved = true;
      if (_currentUserStudentId == student.id &&
          _currentRole == UserRole.studentPending) {
        _currentRole = UserRole.studentApproved;
      }
    });
  }

  void _rejectStudent(StudentRecord student) {
    setState(() {
      _students.removeWhere((s) => s.id == student.id);
      if (_currentUserStudentId == student.id) {
        _currentUserStudentId = null;
        if (_currentRole == UserRole.studentPending ||
            _currentRole == UserRole.studentApproved) {
          _currentRole = UserRole.guest;
        }
      }
    });
  }

  void _updateStudentPayment(StudentRecord student, int newPaidAmount) {
    setState(() {
      student.paidAmount = newPaidAmount.clamp(0, student.totalFee);
    });
  }

  @override
  Widget build(BuildContext context) {
    final myStudentRecord = _currentUserStudentId == null
        ? null
        : _students.cast<StudentRecord?>().firstWhere(
              (s) => s?.id == _currentUserStudentId,
              orElse: () => null,
            );

    final pages = [
      HomeTab(
        role: _currentRole,
        repairJobs: _repairJobs,
        onAddRepair: _addRepairJob,
        onCycleStatus: _cycleRepairStatus,
        onNavigateTab: _navigateToTab,
      ),
      AcademyTab(
        role: _currentRole,
        guides: _academyGuides,
        onAddGuide: _addAcademyGuide,
        onGoToRegister: () => _navigateToTab(4),
      ),
      StoreTab(
        role: _currentRole,
        items: _storeItems,
        onAddItem: _addStoreItem,
      ),
      SoftwareTab(
        role: _currentRole,
        items: _softwareItems,
        onAddItem: _addSoftwareItem,
        onGoToRegister: () => _navigateToTab(4),
      ),
      AccountTab(
        role: _currentRole,
        onChangeRole: (newRole) => setState(() => _currentRole = newRole),
        myStudentRecord: myStudentRecord,
        allStudentsForAdmin: _currentRole.isAdmin ? _students : const [],
        onRegisterStudent: _registerStudent,
        onApproveStudent: _approveStudent,
        onRejectStudent: _rejectStudent,
        onUpdatePayment: _updateStudentPayment,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.memory, color: Color(0xFF38BDF8)),
            SizedBox(width: 8),
            Text(
              'TechMaster Pro',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _currentRole.isAdmin
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
            ),
            child: Text(
              _currentRole.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _navigateToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Academy',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Store/Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal),
            label: 'Software',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TAB 1: HOME DASHBOARD + REPAIR BOOKING & TRACKING
/// ---------------------------------------------------------------------------

class HomeTab extends StatelessWidget {
  final UserRole role;
  final List<RepairJob> repairJobs;
  final ValueChanged<RepairJob> onAddRepair;
  final ValueChanged<RepairJob> onCycleStatus;
  final ValueChanged<int> onNavigateTab;

  const HomeTab({
    super.key,
    required this.role,
    required this.repairJobs,
    required this.onAddRepair,
    required this.onCycleStatus,
    required this.onNavigateTab,
  });

  void _openBookRepairSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final faultCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Book a Repair Job',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Generate a live repair ticket for customer or B2B shop handover.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Customer or Shop Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Brand & Model (e.g., iPhone 14 Pro)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.smartphone),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: faultCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Reported Fault / Issue',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty ||
                        modelCtrl.text.trim().isEmpty ||
                        faultCtrl.text.trim().isEmpty) {
                      return;
                    }
                    final nextNum = 201 + repairJobs.length;
                    onAddRepair(
                      RepairJob(
                        ticketId: 'REP-$nextNum',
                        customerOrShop: nameCtrl.text.trim(),
                        phoneModel: modelCtrl.text.trim(),
                        fault: faultCtrl.text.trim(),
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: const Text('Create Repair Ticket'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF0369A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mobile Repair & Academy Hub',
                style: TextStyle(
                  color: Color(0xFF7DD3FC),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Board-Level Diagnostics, Tools & Training',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF0F172A),
                ),
                onPressed: () => _openBookRepairSheet(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  'Book New Repair',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Quick Services',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.3,
          children: [
            _QuickServiceCard(
              icon: Icons.build_circle,
              title: 'Book a Repair',
              subtitle: 'Live Ticket ID',
              color: const Color(0xFF0284C7),
              onTap: () => _openBookRepairSheet(context),
            ),
            _QuickServiceCard(
              icon: Icons.phone_android,
              title: 'Buy / Sell Phones',
              subtitle: 'Tested Units',
              color: const Color(0xFF059669),
              onTap: () => onNavigateTab(2),
            ),
            _QuickServiceCard(
              icon: Icons.handyman,
              title: 'Repair Tools',
              subtitle: 'Stations & Boxes',
              color: const Color(0xFFD97706),
              onTap: () => onNavigateTab(2),
            ),
            _QuickServiceCard(
              icon: Icons.vpn_key,
              title: 'Unlock & Apps',
              subtitle: 'Server & Drivers',
              color: const Color(0xFF7C3AED),
              onTap: () => onNavigateTab(3),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Repair Jobs & Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (role.isAdmin)
              const Text(
                'Tap status badge to update',
                style: TextStyle(fontSize: 11, color: Color(0xFF0284C7)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ...repairJobs.map((job) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          job.ticketId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.phoneModel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: role.isAdmin ? () => onCycleStatus(job) : null,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: job.status.color.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: job.status.color),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                job.status.label,
                                style: TextStyle(
                                  color: job.status.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              if (role.isAdmin) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.sync,
                                  size: 14,
                                  color: job.status.color,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fault: ${job.fault}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Client / Shop: ${job.customerOrShop}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _QuickServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(28),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TAB 2: ACADEMY HUB (LOCKED FOR GUESTS & PENDING STUDENTS)
/// ---------------------------------------------------------------------------

class AcademyTab extends StatefulWidget {
  final UserRole role;
  final List<AcademyGuide> guides;
  final ValueChanged<AcademyGuide> onAddGuide;
  final VoidCallback onGoToRegister;

  const AcademyTab({
    super.key,
    required this.role,
    required this.guides,
    required this.onAddGuide,
    required this.onGoToRegister,
  });

  @override
  State<AcademyTab> createState() => _AcademyTabState();
}

class _AcademyTabState extends State<AcademyTab> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Common Faults',
    'Easy Tricks',
    'IC Ways',
  ];

  Widget _buildPhotoPreview(String photoUrl, String category, {double height = 130}) {
    if (photoUrl.trim().isEmpty) {
      return _photoFallbackBox(category, height);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        photoUrl.trim(),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoFallbackBox(category, height),
      ),
    );
  }

  Widget _photoFallbackBox(String category, double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.developer_board, size: 32, color: Color(0xFF475569)),
          const SizedBox(height: 6),
          Text(
            '$category • Board Diagram / Photo',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  void _openGuideDetail(AcademyGuide guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.78,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  guide.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guide.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _buildPhotoPreview(guide.photoUrl, guide.category, height: 180),
                const SizedBox(height: 14),
                Text(
                  guide.summary,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Step-by-Step Repair Procedure',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...guide.steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF0F172A),
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  void _openAddGuideSheet() {
    final titleCtrl = TextEditingController();
    final summaryCtrl = TextEditingController();
    final stepsCtrl = TextEditingController();
    final photoCtrl = TextEditingController();
    String category = 'Common Faults';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Academy Fault / Guide',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Common Faults', 'Easy Tricks', 'IC Ways']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => category = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Guide Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: summaryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Short Summary',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stepsCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Repair Steps (one step per line)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: photoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Photo / Schematic URL (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (titleCtrl.text.trim().isEmpty ||
                              summaryCtrl.text.trim().isEmpty) {
                            return;
                          }
                          final parsedSteps = stepsCtrl.text
                              .split('\n')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .toList();
                          widget.onAddGuide(
                            AcademyGuide(
                              id: 'AC-${DateTime.now().millisecondsSinceEpoch}',
                              title: titleCtrl.text.trim(),
                              category: category,
                              summary: summaryCtrl.text.trim(),
                              steps: parsedSteps.isEmpty
                                  ? [summaryCtrl.text.trim()]
                                  : parsedSteps,
                              photoUrl: photoCtrl.text.trim(),
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Publish Academy Guide'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.role.canAccessAcademy) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFFEF3C7),
                    child: Icon(Icons.lock, size: 30, color: Color(0xFFD97706)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Academy Vault Locked',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.role == UserRole.studentPending
                        ? 'Your student registration is currently Pending Admin Approval. Once approved, Common Faults, Easy Tricks, and IC Ways will unlock automatically.'
                        : 'Common Faults, Easy Tricks, IC Ways, and PCB schematic photos are restricted to Approved Academy Students.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: widget.onGoToRegister,
                    icon: const Icon(Icons.app_registration),
                    label: Text(
                      widget.role == UserRole.studentPending
                          ? 'View Registration Status'
                          : 'Register as Student',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final filtered = _selectedCategory == 'All'
        ? widget.guides
        : widget.guides.where((g) => g.category == _selectedCategory).toList();

    return Scaffold(
      floatingActionButton: widget.role.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openAddGuideSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add Guide'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          ...filtered.map((guide) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openGuideDetail(guide),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPhotoPreview(guide.photoUrl, guide.category),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          guide.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        guide.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guide.summary,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TAB 3: STORE & TOOLS HUB
/// ---------------------------------------------------------------------------

class StoreTab extends StatefulWidget {
  final UserRole role;
  final List<StoreItem> items;
  final ValueChanged<StoreItem> onAddItem;

  const StoreTab({
    super.key,
    required this.role,
    required this.items,
    required this.onAddItem,
  });

  @override
  State<StoreTab> createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  String _selectedCategory = 'All';

  void _openAddListingSheet() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final badgeCtrl = TextEditingController(text: 'In Stock');
    final summaryCtrl = TextEditingController();
    final specsCtrl = TextEditingController();
    String category = 'Repair Tools';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Store / Tool Listing',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Repair Tools', 'Buy / Sell Phones']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => category = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Item / Phone Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (Rs.)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: badgeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Stock / Condition Badge',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: summaryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Short Summary',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: specsCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Temp Guide / Condition & Inquiry Details',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final price = int.tryParse(priceCtrl.text.trim());
                          if (titleCtrl.text.trim().isEmpty || price == null) {
                            return;
                          }
                          widget.onAddItem(
                            StoreItem(
                              id: 'ST-${DateTime.now().millisecondsSinceEpoch}',
                              title: titleCtrl.text.trim(),
                              category: category,
                              priceRs: price,
                              badge: badgeCtrl.text.trim(),
                              summary: summaryCtrl.text.trim(),
                              guideOrSpecs: specsCtrl.text.trim(),
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Save Listing'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? widget.items
        : widget.items.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      floatingActionButton: widget.role.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openAddListingSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add Listing'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: ['All', 'Repair Tools', 'Buy / Sell Phones'].map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          ...filtered.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.badge,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                        Text(
                          formatRs(item.priceRs),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    if (item.guideOrSpecs.isNotEmpty) ...[
                      const Divider(height: 18),
                      Text(
                        item.guideOrSpecs,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TAB 4: SOFTWARE, UNLOCK TOOLS & CUSTOM APPS HUB
/// ---------------------------------------------------------------------------

class SoftwareTab extends StatefulWidget {
  final UserRole role;
  final List<SoftwareItem> items;
  final ValueChanged<SoftwareItem> onAddItem;
  final VoidCallback onGoToRegister;

  const SoftwareTab({
    super.key,
    required this.role,
    required this.items,
    required this.onAddItem,
    required this.onGoToRegister,
  });

  @override
  State<SoftwareTab> createState() => _SoftwareTabState();
}

class _SoftwareTabState extends State<SoftwareTab> {
  String _selectedCategory = 'All';

  void _openAddSoftwareSheet() {
    final titleCtrl = TextEditingController();
    final badgeCtrl = TextEditingController(text: 'v1.0');
    final summaryCtrl = TextEditingController();
    final howToCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    String category = 'Custom Apps';
    bool requiresStudent = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Software / Unlock Tool',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Custom Apps', 'Unlock Tools', 'Drivers & Flash']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => category = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Software / Tool Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: badgeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Version / Status Badge',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: summaryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Summary',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: howToCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'How-to-Use Guide',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: linkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Link or Desk Contact Info',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Approved Students Only'),
                      value: requiresStudent,
                      onChanged: (v) =>
                          setModalState(() => requiresStudent = v),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (titleCtrl.text.trim().isEmpty) return;
                          widget.onAddItem(
                            SoftwareItem(
                              id: 'SW-${DateTime.now().millisecondsSinceEpoch}',
                              title: titleCtrl.text.trim(),
                              category: category,
                              badge: badgeCtrl.text.trim(),
                              summary: summaryCtrl.text.trim(),
                              howToUse: howToCtrl.text.trim(),
                              linkOrDeskInfo: linkCtrl.text.trim(),
                              requiresApprovedStudent: requiresStudent,
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Publish Software Tool'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? widget.items
        : widget.items.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      floatingActionButton: widget.role.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openAddSoftwareSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add Tool'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Custom Apps', 'Unlock Tools', 'Drivers & Flash']
                  .map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          ...filtered.map((item) {
            final isLocked =
                item.requiresApprovedStudent && !widget.role.canAccessAcademy;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.badge,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5B21B6),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (item.requiresApprovedStudent)
                          Icon(
                            isLocked ? Icons.lock : Icons.verified_user,
                            size: 18,
                            color: isLocked
                                ? const Color(0xFFD97706)
                                : const Color(0xFF059669),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const Divider(height: 18),
                    if (isLocked)
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Locked: Approved Academy Students only.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: widget.onGoToRegister,
                            child: const Text('Unlock'),
                          ),
                        ],
                      )
                    else ...[
                      Text(
                        item.howToUse,
                        style: const TextStyle(fontSize: 12.5, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.linkOrDeskInfo,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TAB 5: ACCOUNT, STUDENT REGISTRATION & ADMIN-ONLY FEES PANEL
/// ---------------------------------------------------------------------------

class AccountTab extends StatefulWidget {
  final UserRole role;
  final ValueChanged<UserRole> onChangeRole;
  final StudentRecord? myStudentRecord;
  final List<StudentRecord> allStudentsForAdmin;
  final ValueChanged<StudentRecord> onRegisterStudent;
  final ValueChanged<StudentRecord> onApproveStudent;
  final ValueChanged<StudentRecord> onRejectStudent;
  final void Function(StudentRecord student, int newPaidAmount) onUpdatePayment;

  const AccountTab({
    super.key,
    required this.role,
    required this.onChangeRole,
    required this.myStudentRecord,
    required this.allStudentsForAdmin,
    required this.onRegisterStudent,
    required this.onApproveStudent,
    required this.onRejectStudent,
    required this.onUpdatePayment,
  });

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _totalFeeCtrl = TextEditingController(text: '35000');
  final _paidNowCtrl = TextEditingController();
  String _selectedBatch = 'Weekday';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _totalFeeCtrl.dispose();
    _paidNowCtrl.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final totalFee = int.tryParse(_totalFeeCtrl.text.trim()) ?? 35000;
    final paidNow = int.tryParse(_paidNowCtrl.text.trim()) ?? 0;

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Student Name and Phone.')),
      );
      return;
    }

    widget.onRegisterStudent(
      StudentRecord(
        id: 'STU-${100 + DateTime.now().second}',
        name: name,
        phone: phone,
        batch: _selectedBatch,
        totalFee: totalFee,
        paidAmount: paidNow.clamp(0, totalFee),
        isApproved: false,
      ),
    );

    _nameCtrl.clear();
    _phoneCtrl.clear();
    _paidNowCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration submitted. Awaiting Admin approval.'),
      ),
    );
  }

  void _openEditPaymentDialog(StudentRecord student) {
    final ctrl = TextEditingController(text: student.paidAmount.toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Update Payment • ${student.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Course Fee: ${formatRs(student.totalFee)}'),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Paid Amount (Rs.)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final val = int.tryParse(ctrl.text.trim());
                if (val != null) {
                  widget.onUpdatePayment(student, val);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFFF1F5F9),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Role Switcher (Testing Mode)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: UserRole.values.map((r) {
                    return ChoiceChip(
                      label: Text(r.label, style: const TextStyle(fontSize: 12)),
                      selected: widget.role == r,
                      onSelected: (_) => widget.onChangeRole(r),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (widget.myStudentRecord != null && !widget.role.isAdmin) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Academy Enrollment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 18),
                  Text('Name: ${widget.myStudentRecord!.name}'),
                  const SizedBox(height: 4),
                  Text('Phone / WhatsApp: ${widget.myStudentRecord!.phone}'),
                  const SizedBox(height: 4),
                  Text('Batch: ${widget.myStudentRecord!.batch}'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: widget.myStudentRecord!.isApproved
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.myStudentRecord!.isApproved
                          ? 'Status: Approved (Academy Unlocked)'
                          : 'Status: Pending Admin Approval',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: widget.myStudentRecord!.isApproved
                            ? const Color(0xFF166534)
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (!widget.role.isAdmin && widget.myStudentRecord == null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Academy Student Registration',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enroll in Practical Mobile Hardware & Micro-Soldering.',
                    style: TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Student Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone / WhatsApp Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select Batch',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Weekday', label: Text('Weekday')),
                      ButtonSegment(value: 'Saturday', label: Text('Saturday')),
                      ButtonSegment(value: 'Sunday', label: Text('Sunday')),
                    ],
                    selected: {_selectedBatch},
                    onSelectionChanged: (s) =>
                        setState(() => _selectedBatch = s.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _totalFeeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Course Fee (Rs.)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _paidNowCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Paid Now / Initial Deposit (Rs.)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submitRegistration,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Registration'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        if (widget.role.isAdmin) ...[
          const Text(
            'Admin Panel • Student Registrations & Fees',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Confidential: Visible exclusively to Admin / Owner.',
            style: TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
          ),
          const SizedBox(height: 12),
          ...widget.allStudentsForAdmin.map((student) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: student.isApproved
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            student.isApproved ? 'Approved' : 'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: student.isApproved
                                  ? const Color(0xFF166534)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.phone} • ${student.batch} Batch',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FeeStat(
                          label: 'Total Fee',
                          value: formatRs(student.totalFee),
                          color: const Color(0xFF0F172A),
                        ),
                        _FeeStat(
                          label: 'Paid',
                          value: formatRs(student.paidAmount),
                          color: const Color(0xFF059669),
                        ),
                        _FeeStat(
                          label: 'Due',
                          value: formatRs(student.dueAmount),
                          color: student.dueAmount > 0
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF059669),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openEditPaymentDialog(student),
                          icon: const Icon(Icons.payments_outlined, size: 16),
                          label: const Text('Edit Payment'),
                        ),
                        if (!student.isApproved)
                          FilledButton.icon(
                            onPressed: () => widget.onApproveStudent(student),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Approve'),
                          ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                          ),
                          onPressed: () => widget.onRejectStudent(student),
                          icon: const Icon(Icons.close, size: 16),
                          label: Text(student.isApproved ? 'Remove' : 'Reject'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _FeeStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FeeStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
            color: color,
          ),
        ),
      ],
    );
  }
}
