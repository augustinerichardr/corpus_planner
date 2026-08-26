import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';
import '../services/backup_vault_service.dart';
import '../widgets/settings/settings_components.dart';
import 'pricing_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPro = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadProStatus();
  }

  Future<void> _loadProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isPro = prefs.getBool('is_pro_unlocked') ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                children: [
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildVisuals(settings, cardBg, cardBorder),
                              const SizedBox(height: 12),
                              _buildDefaults(settings, cardBg, cardBorder),
                              const SizedBox(height: 12),
                              _buildStorage(settings, cardBg, cardBorder),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              _buildProSuite(settings, cardBg, cardBorder),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildVisuals(settings, cardBg, cardBorder),
                        const SizedBox(height: 12),
                        _buildDefaults(settings, cardBg, cardBorder),
                        const SizedBox(height: 12),
                        _buildProSuite(settings, cardBg, cardBorder),
                        const SizedBox(height: 12),
                        _buildStorage(settings, cardBg, cardBorder),
                      ],
                    ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'CorpusIQ Pro • Global Multi-Asset Financial Engine v1.0.0+15',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVisuals(SettingsService settings, Color bg, Color border) =>
      SettingsWrapperCard(
        title: 'Appearance & Font Scaling',
        cardBg: bg,
        cardBorder: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme Mode',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode, size: 14),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode, size: 14),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Auto'),
                    icon: Icon(Icons.brightness_auto, size: 14),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (v) => settings.setThemeMode(v.first),
              ),
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Text & Font Size',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                Text(
                  getFontScaleLabel(settings.fontScale),
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Slider(
              value: settings.fontScale,
              min: 0.85,
              max: 1.30,
              divisions: 3,
              activeColor: const Color(0xFF10B981),
              onChanged: settings.setFontScale,
            ),
          ],
        ),
      );

  Widget _buildDefaults(
    SettingsService settings,
    Color bg,
    Color border,
  ) =>
      SettingsWrapperCard(
        title: 'Financial Simulation & Global Currency',
        cardBg: bg,
        cardBorder: border,
        child: Column(
          children: [
            SettingDropdownTile(
              icon: Icons.currency_exchange,
              iconColor: const Color(0xFFF59E0B),
              label: 'Base Currency & Unit Engine',
              value: settings.defaultCurrency,
              items: SettingsService.supportedCurrencies,
              onChanged: (v) => settings.setDefaultCurrency(v!),
            ),
            const Divider(height: 14),
            SettingValueTile(
              icon: Icons.trending_up,
              iconColor: const Color(0xFF38BDF8),
              label: 'Default Equity Return Target',
              value:
                  '${settings.defaultExpectedReturn.toStringAsFixed(1)}% p.a.',
              onTap: () => showNumericEditDialog(
                context,
                title: 'Default Equity Return (%)',
                initial: settings.defaultExpectedReturn,
                onSaved: settings.setDefaultReturn,
              ),
            ),
            const Divider(height: 14),
            SettingValueTile(
              icon: Icons.stairs_outlined,
              iconColor: const Color(0xFFA78BFA),
              label: 'Annual SIP Step-Up %',
              value:
                  '${settings.defaultStepUpPercent.toStringAsFixed(1)}% p.a.',
              onTap: () => showNumericEditDialog(
                context,
                title: 'Default Annual Step-Up (%)',
                initial: settings.defaultStepUpPercent,
                onSaved: settings.setDefaultStepUp,
              ),
            ),
            const Divider(height: 14),
            SettingDropdownTile(
              icon: Icons.account_balance,
              iconColor: const Color(0xFF10B981),
              label: 'Tax Baseline Engine',
              value: settings.taxRegime,
              items: const [
                'New Regime (FY 2025-26)',
                'Old Regime (80C / 24b Active)',
              ],
              onChanged: (v) => settings.setTaxRegime(v!),
            ),
          ],
        ),
      );

  Widget _buildProSuite(SettingsService settings, Color bg, Color border) =>
      SettingsWrapperCard(
        title: 'Institutional Pro Suite',
        badge: _isPro ? 'PRO ACTIVE ✓' : 'PRO EXCLUSIVE',
        badgeColor: _isPro ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        cardBg: bg,
        cardBorder: border,
        child: Column(
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              iconColor: const Color(0xFFF59E0B),
              collapsedIconColor: Colors.grey,
              title: const Text(
                'Wealth Accumulation & Investment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              subtitle: const Text(
                'Monte Carlo, Inflation, Black Swan & Tax Harvesting',
                style: TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
              children: [
                _proToggle(
                  'Monte Carlo Stress Simulation',
                  'Simulates 10,000 randomized crash trajectories.',
                  settings.isMonteCarloEnabled,
                  (v) async {
                    if (!_isPro) {
                      final upgraded = await PricingModal.show(context);
                      if (upgraded == true) await _loadProStatus();
                      return;
                    }
                    await settings.setMonteCarloEnabled(v);
                  },
                ),
                const Divider(height: 12),
                _proToggle(
                  'Multi-Segment Inflation Basket',
                  'Overrides standard CPI for Education (10%) & Healthcare (12%).',
                  settings.isMultiSegmentInflationEnabled,
                  (v) async {
                    if (!_isPro) {
                      final upgraded = await PricingModal.show(context);
                      if (upgraded == true) await _loadProStatus();
                      return;
                    }
                    await settings.setMultiSegmentInflationEnabled(v);
                  },
                ),
                const Divider(height: 12),
                _proToggle(
                  'Black Swan Crisis Shock Mode',
                  'Models 2008 & 2020 sudden 40% crash recovery velocity.',
                  settings.isBlackSwanModeEnabled,
                  (v) async {
                    if (!_isPro) {
                      final upgraded = await PricingModal.show(context);
                      if (upgraded == true) await _loadProStatus();
                      return;
                    }
                    await settings.setBlackSwanModeEnabled(v);
                  },
                ),
                const Divider(height: 12),
                _proToggle(
                  'Factor Tax Harvesting Optimizer',
                  'Automates tax-loss harvesting rules for capital gains.',
                  settings.isTaxHarvestingEnabled,
                  (v) async {
                    if (!_isPro) {
                      final upgraded = await PricingModal.show(context);
                      if (upgraded == true) await _loadProStatus();
                      return;
                    }
                    await settings.setTaxHarvestingEnabled(v);
                  },
                ),
                const Divider(height: 12),
                _proToggle(
                  'Institutional PDF Export & Branding',
                  'Export clean advisory dossiers without watermarks.',
                  settings.isInstitutionalPdfEnabled,
                  (v) async {
                    if (!_isPro) {
                      final upgraded = await PricingModal.show(context);
                      if (upgraded == true) await _loadProStatus();
                      return;
                    }
                    await settings.setInstitutionalPdfEnabled(v);
                  },
                ),
              ],
            ),
            const Divider(height: 16),
            ExpansionTile(
              initiallyExpanded: false,
              iconColor: const Color(0xFF10B981),
              collapsedIconColor: Colors.grey,
              title: const Text(
                'Retirement Decumulation & Withdrawal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              subtitle: const Text(
                'SORR Stress Test, Tax-Aware SWP & Guardrails',
                style: TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
              children: [
                _proToggle(
                  'Sequence of Returns Risk (SORR)',
                  'Simulates severe bear market shock at retirement onset.',
                  settings.isSorrEnabled,
                  (v) async {
                    if (!_isPro) {
                      final upgraded = await PricingModal.show(context);
                      if (upgraded == true) await _loadProStatus();
                      return;
                    }
                    await settings.setSorrEnabled(v);
                  },
                ),
                const Divider(height: 12),
                _proToggle(
                  'Tax-Aware Net Withdrawal Engine',
                  'Factors in unit liquidation drag for capital gains taxes.',
                  settings.isTaxAwareSwpEnabled,
                  (v) async {
                    if (!_isPro) {
                      final upgraded = await PricingModal.show(context);
                      if (upgraded == true) await _loadProStatus();
                      return;
                    }
                    await settings.setTaxAwareSwpEnabled(v);
                  },
                ),
                const Divider(height: 12),
                _proToggle(
                  'Dynamic Guardrails (Guyton-Klinger)',
                  'Automates inflation freezes and withdrawal pay-cuts.',
                  settings.isGuardrailsEnabled,
                  (v) async {
                    if (!_isPro) {
                      final upgraded = await PricingModal.show(context);
                      if (upgraded == true) await _loadProStatus();
                      return;
                    }
                    await settings.setGuardrailsEnabled(v);
                  },
                ),
                const Divider(height: 12),
                _proToggle(
                  'Institutional SWP Longevity Dossier',
                  'Export formal retirement cashflow & depletion reports.',
                  settings.isSwpPdfEnabled,
                  (v) async {
                    if (!_isPro) {
                      final upgraded = await PricingModal.show(context);
                      if (upgraded == true) await _loadProStatus();
                      return;
                    }
                    await settings.setSwpPdfEnabled(v);
                  },
                ),
              ],
            ),
          ],
        ),
      );

  Widget _proToggle(
    String title,
    String sub,
    bool val,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(color: Colors.grey, fontSize: 10.5),
              ),
            ],
          ),
        ),
        Switch(
          value: val,
          activeColor: const Color(0xFF10B981),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStorage(SettingsService settings, Color bg, Color border) =>
      SettingsWrapperCard(
        title: 'Storage & Encrypted Vault',
        cardBg: bg,
        cardBorder: border,
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.cloud_download_outlined,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
              title: const Text(
                'Export Encrypted Portfolio JSON Backup',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Download snapshot of your SIP schedules and models.',
                style: TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
              onTap: _isExporting
                  ? null
                  : () async {
                      setState(() => _isExporting = true);
                      await BackupVaultService.exportBackup(
                        context: context,
                        settings: settings,
                        taxRegime: settings.taxRegime,
                        enableMonteCarlo: settings.isMonteCarloEnabled,
                        customInflationBasket:
                            settings.isMultiSegmentInflationEnabled,
                        educationInflation: 10.0,
                        healthcareInflation: 12.0,
                        whiteLabelPdf: settings.isInstitutionalPdfEnabled,
                      );
                      if (mounted) setState(() => _isExporting = false);
                    },
            ),
            const Divider(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFF10B981),
                size: 20,
              ),
              title: const Text(
                'Restore Portfolio from Backup',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Import a previously exported .json vault backup.',
                style: TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
              onTap: () => BackupVaultService.showRestoreDialog(
                context: context,
                settings: settings,
                onRestored: (r) => setState(() {
                  settings.setTaxRegime(
                      r['tax_regime']?.toString() ?? settings.taxRegime);
                  settings
                      .setMonteCarloEnabled(r['monte_carlo_enabled'] == true);
                  settings.setMultiSegmentInflationEnabled(
                      r['custom_inflation_basket'] == true);
                  settings
                      .setInstitutionalPdfEnabled(r['white_label_pdf'] == true);
                }),
              ),
            ),
          ],
        ),
      );
}
