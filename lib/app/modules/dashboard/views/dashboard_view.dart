import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  // ── Palette ───────────────────────────────────────────────────────────
  static const _navy = Color(0xFF101828);
  static const _red = Color(0xFFD62839);
  static const _green = Color(0xFF16A34A);
  static const _background = Color(0xFFF7F8FA);
  static const _gray = Color(0xFF6B7280);
  static const _border = Color(0xFFEEF0F3);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.activeAssignment.value != null) ...[
                          _buildEmergencyAlert(),
                          const SizedBox(height: 22),
                        ],
                        _sectionTitle('Vehicle'),
                        const SizedBox(height: 12),
                        _buildVehicleCard(),
                        const SizedBox(height: 22),
                        _sectionTitle('Today'),
                        const SizedBox(height: 12),
                        _buildStats(),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionTitle('Pending requests'),
                            GestureDetector(
                              onTap: () => Get.toNamed(Routes.requests),
                              child: const Text(
                                'See all',
                                style: TextStyle(
                                  color: _red,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (controller.activeAssignment.value
                            case final assignment?)
                          _requestCard(
                            pickup: assignment.pickup,
                            hospital: assignment.hospital,
                            priority: assignment.priority,
                            distance: assignment.distance,
                            eta: assignment.eta,
                            critical:
                                assignment.priority.toLowerCase() == 'critical',
                          )
                        else
                          _card(
                            child: const Text(
                              'No pending requests',
                              style: TextStyle(color: _gray),
                            ),
                          ),
                        const SizedBox(height: 22),
                        _sectionTitle('Quick actions'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _actionButton(
                                icon: Icons.navigation_rounded,
                                text: 'Navigation',
                                backgroundColor: _navy,
                                textColor: Colors.white,
                                onTap: () => Get.toNamed(Routes.trips),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _actionButton(
                                icon: Icons.phone_outlined,
                                text: 'Requests',
                                backgroundColor: Colors.white,
                                textColor: const Color(0xFF1A1D23),
                                border: true,
                                onTap: () => Get.toNamed(Routes.requests),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _red.withValues(alpha: 0.25)),
                ),
                alignment: Alignment.center,
                child: Obx(
                  () => Text(
                    controller.driverInitials.value,
                    style: const TextStyle(
                      color: _red,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good evening',
                      style: TextStyle(color: _gray, fontSize: 12.5),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        controller.driverName.value,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: _gray,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: controller.isOnline.value
                      ? _green
                      : const Color(0xFFB0B6C0),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                controller.isOnline.value
                    ? 'Online · Receiving requests'
                    : 'Offline · Not receiving requests',
                style: const TextStyle(
                  color: _navy,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: controller.isOnline.value,
                  activeThumbColor: Colors.white,
                  activeTrackColor: _green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD6D9DE),
                  onChanged: controller.toggleOnlineStatus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Emergency alert ───────────────────────────────────────────────────

  Widget _buildEmergencyAlert() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Get.toNamed(Routes.requests),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _red,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _red.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.circle, color: Colors.white, size: 11),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active emergency request',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${controller.activeAssignment.value?.priority ?? 'Emergency'} · Respond now',
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ── Vehicle card ──────────────────────────────────────────────────────

  Widget _buildVehicleCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFDECEE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: _red,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.ambulanceName.value,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    'Plate ${controller.plateNumber.value}'
                    ' · ${controller.ambulanceType.value}',
                    style: const TextStyle(color: _gray, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Wrap(
                    spacing: 6,
                    children: [
                      _tag('Fuel ${controller.fuelPercent.value}%'),
                      _tag(
                        controller.equipmentReady.value
                            ? 'Equipment ready'
                            : 'Equipment not ready',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => _statBox(
              value: '${controller.tripsDone.value}',
              label: 'Trips done',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => _statBox(
              value: '${controller.distanceKm.value} km',
              label: 'Distance',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => _statBox(
              value: controller.activeTime.value,
              label: 'Active time',
            ),
          ),
        ),
      ],
    );
  }

  // ── Pending request card ──────────────────────────────────────────────

  Widget _requestCard({
    required String pickup,
    required String hospital,
    required String priority,
    required String distance,
    required String eta,
    bool critical = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Get.toNamed(Routes.requests),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '$pickup → $hospital',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: critical
                        ? const Color(0xFFFDECEE)
                        : const Color(0xFFFEF6E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: critical ? _red : const Color(0xFFB4790A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: _gray),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: const TextStyle(color: _gray, fontSize: 12),
                ),
                const SizedBox(width: 18),
                const Icon(Icons.schedule, size: 16, color: _gray),
                const SizedBox(width: 4),
                Text(
                  'ETA $eta',
                  style: const TextStyle(color: _gray, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom navigation ─────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _red,
      unselectedItemColor: const Color(0xFF9AA1AC),
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) {
        switch (index) {
          case 1:
            Get.toNamed(Routes.trips);
          case 2:
            Get.toNamed(Routes.tracking);
          case 3:
            Get.toNamed(Routes.profile);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.route_outlined),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Tracking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  // ── Shared small widgets ──────────────────────────────────────────────

  Widget _statBox({required String value, required String label}) {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _gray, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _gray,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
    bool border = false,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: border
              ? const BorderSide(color: Color(0xFFE3E6EA))
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(14),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF0F3)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1D23),
      ),
    );
  }
}
