import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../services/app_language_service.dart';
import '../services/speech/speech_recognition_service.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = AppLanguageService();

    return AnimatedBuilder(
      animation: languageService,
      builder: (context, _) {
        final t = _GuideTranslations.get(languageService.currentLanguage);

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: SafeArea(
            child: Column(
              children: [
                // Top Hub Header (Language Dropdown Removed; Globally Synced to Settings)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: const Color(0xFF1E293B),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF38BDF8),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t['hubTitle']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Voice Feedback',
                        icon: const Icon(
                          Icons.mic_rounded,
                          color: Color(0xFF38BDF8),
                          size: 20,
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const VoiceFeedbackDialog(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sub Tabs Bar
                Container(
                  color: const Color(0xFF1E293B),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: const Color(0xFF10B981),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF10B981),
                    unselectedLabelColor: const Color(0xFF94A3B8),
                    tabs: [
                      Tab(
                        icon:
                            const Icon(Icons.compare_arrows_rounded, size: 18),
                        text: t['tab1'],
                      ),
                      Tab(
                        icon:
                            const Icon(Icons.account_balance_rounded, size: 18),
                        text: t['tab2'],
                      ),
                      Tab(
                        icon: const Icon(Icons.pie_chart_outline_rounded,
                            size: 18),
                        text: t['tab3'],
                      ),
                      Tab(
                        icon: const Icon(Icons.credit_card_rounded, size: 18),
                        text: t['tab4'],
                      ),
                    ],
                  ),
                ),

                // Content View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildList(t['tab1Header']!, [
                        _cardData(
                          t['sipVsLumpTitle']!,
                          t['sipVsLumpBadge']!,
                          t['sipVsLumpSub']!,
                          [
                            t['sipVsLumpB1']!,
                            t['sipVsLumpB2']!,
                            t['sipVsLumpB3']!,
                          ],
                        ),
                        _cardData(
                          t['activeVsPassiveTitle']!,
                          t['activeVsPassiveBadge']!,
                          t['activeVsPassiveSub']!,
                          [
                            t['activeVsPassiveB1']!,
                            t['activeVsPassiveB2']!,
                          ],
                        ),
                      ]),
                      _buildList(t['govtSchemesHeader']!, [
                        _cardData(
                          t['ppfTitle']!,
                          t['ppfBadge']!,
                          t['ppfRate']!,
                          [
                            t['ppfB1']!,
                            t['ppfB2']!,
                            t['ppfB3']!,
                          ],
                        ),
                        _cardData(
                          t['npsTitle']!,
                          t['npsBadge']!,
                          t['npsRate']!,
                          [
                            t['npsB1']!,
                            t['npsB2']!,
                            t['npsB3']!,
                          ],
                        ),
                        _cardData(
                          t['ssyTitle']!,
                          t['ssyBadge']!,
                          t['ssyRate']!,
                          [
                            t['ssyB1']!,
                            t['ssyB2']!,
                            t['ssyB3']!,
                          ],
                        ),
                      ]),
                      _buildList(t['equityHeader']!, [
                        _cardData(
                          t['largeCapTitle']!,
                          t['largeCapBadge']!,
                          t['largeCapSub']!,
                          [
                            t['largeCapB1']!,
                            t['largeCapB2']!,
                          ],
                        ),
                        _cardData(
                          t['flexiCapTitle']!,
                          t['flexiCapBadge']!,
                          t['flexiCapSub']!,
                          [
                            t['flexiCapB1']!,
                            t['flexiCapB2']!,
                          ],
                        ),
                      ]),
                      _buildList(t['debtsHeader']!, [
                        _cardData(
                          t['homeLoanTitle']!,
                          t['homeLoanBadge']!,
                          t['homeLoanRate']!,
                          [
                            t['homeLoanB1']!,
                            t['homeLoanB2']!,
                          ],
                        ),
                        _cardData(
                          t['creditDebtTitle']!,
                          t['creditDebtBadge']!,
                          t['creditDebtRate']!,
                          [
                            t['creditDebtB1']!,
                            t['creditDebtB2']!,
                          ],
                          isWarn: true,
                        ),
                        _cardData(
                          t['emiMultiplierTitle']!,
                          t['emiMultiplierBadge']!,
                          t['emiMultiplierSub']!,
                          [
                            t['emiMultiplierB1']!,
                            t['emiMultiplierB2']!,
                          ],
                          isAccent: true,
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _cardData(
    String title,
    String badge,
    String sub,
    List<String> b, {
    bool isWarn = false,
    bool isAccent = false,
  }) =>
      {
        'title': title,
        'badge': badge,
        'sub': sub,
        'bullets': b,
        'warn': isWarn,
        'accent': isAccent,
      };

  Widget _buildList(String header, List<Map<String, dynamic>> cards) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        Text(
          header,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...cards.map((c) => _buildCard(c)),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> c) {
    final isWarn = c['warn'] as bool;
    final isAccent = c['accent'] as bool;
    final border = isWarn
        ? const Color(0xFFEF4444).withValues(alpha: 0.4)
        : (isAccent
            ? const Color(0xFF10B981).withValues(alpha: 0.4)
            : const Color(0xFF38BDF8).withValues(alpha: 0.3));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  c['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (isWarn ? Colors.red : const Color(0xFF0EA5E9))
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  c['badge'],
                  style: TextStyle(
                    color: isWarn
                        ? const Color(0xFFF87171)
                        : const Color(0xFF38BDF8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            c['sub'],
            style: TextStyle(
              color: isWarn ? const Color(0xFFF87171) : const Color(0xFF38BDF8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 16),
          ...(c['bullets'] as List<String>).map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// VOICE & TEXT FEEDBACK MODAL
// ---------------------------------------------------------
class VoiceFeedbackDialog extends StatefulWidget {
  const VoiceFeedbackDialog({super.key});
  @override
  State<VoiceFeedbackDialog> createState() => _VoiceFeedbackDialogState();
}

class _VoiceFeedbackDialogState extends State<VoiceFeedbackDialog> {
  final _msgCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _speech = SpeechRecognitionService();
  bool _isRec = false;
  bool _isSending = false;
  Timer? _timer;
  int _sec = 0;

  void _toggleVoice() {
    if (_isRec) {
      _timer?.cancel();
      _speech.stopListening();
      setState(() => _isRec = false);
    } else {
      setState(() {
        _isRec = true;
        _sec = 0;
      });
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => mounted ? setState(() => _sec++) : null,
      );
      _speech.startListening(
        langCode: 'en-IN',
        onResult: (res, _) =>
            mounted ? setState(() => _msgCtrl.text = res) : null,
        onError: (_) {
          _timer?.cancel();
          if (mounted) setState(() => _isRec = false);
        },
        onEnd: () {
          _timer?.cancel();
          if (mounted) setState(() => _isRec = false);
        },
      );
    }
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email and feedback message.'),
        ),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      final res = await http.post(
        Uri.parse('https://formspree.io/f/xrpzjppr'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'message': msg}),
      );
      if (res.statusCode >= 200 && res.statusCode < 300 && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Feedback dispatched!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        return;
      }
    } catch (_) {}
    final mail = Uri.parse(
      'mailto:ganymedeearth24@gmail.com?subject=Feedback&body=${Uri.encodeComponent(msg)}',
    );
    if (await canLaunchUrl(mail)) await launchUrl(mail);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stopListening();
    _msgCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        'Voice & Text Feedback',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggleVoice,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isRec
                      ? Colors.red.withValues(alpha: 0.2)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isRec ? Colors.redAccent : const Color(0xFF38BDF8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isRec ? Icons.stop_circle : Icons.mic,
                      color:
                          _isRec ? Colors.redAccent : const Color(0xFF38BDF8),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRec
                          ? 'Listening ($_sec s)... Tap Stop'
                          : 'Tap to Speak (Voice Input)',
                      style: TextStyle(
                        color:
                            _isRec ? Colors.redAccent : const Color(0xFF38BDF8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _msgCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Speech transcript or message...',
                hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                filled: true,
                fillColor: Color(0xFF0F172A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Your email for direct reply',
                hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                filled: true,
                fillColor: Color(0xFF0F172A),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.black,
          ),
          child: _isSending
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send'),
        ),
      ],
    );
  }
}

class _GuideTranslations {
  static Map<String, String> get(String lang) {
    switch (lang) {
      case 'ta':
        return {
          'hubTitle': 'நிதி அறிவு மையம்',
          'tab1': 'ஒப்பீடுகள்',
          'tab2': 'திட்டங்கள்',
          'tab3': 'பங்குகள்',
          'tab4': 'கடன்கள்',
          'tab1Header': 'முதலீட்டு உத்திகள்',
          'sipVsLumpTitle': 'SIP vs. மொத்த முதலீடு',
          'sipVsLumpBadge': 'இடர் குறைப்பு',
          'sipVsLumpSub': 'ரூபாய் செலவு சராசரியாக்கல் (RCA)',
          'sipVsLumpB1':
              'SIP சந்தை ஏற்ற இறக்கங்களை சராசரியாக்கி உணர்ச்சிவசப்பட்ட முடிவுகளைத் தடுக்கிறது.',
          'sipVsLumpB2':
              'சந்தை வீழ்ச்சியடையும் காலங்களில் மொத்த முதலீட்டை விட SIP அதிக லாபம் தரும்.',
          'sipVsLumpB3':
              'நீண்ட கால கூட்டு வட்டி பலன் பெற ஸ்டெப்-அப் SIP சிறந்தது.',
          'activeVsPassiveTitle': 'ஆக்டிவ் vs. இன்டெக்ஸ்',
          'activeVsPassiveBadge': 'TER Alpha',
          'activeVsPassiveSub': 'Nifty 50 vs. Active Funds',
          'activeVsPassiveB1':
              '85% க்கும் மேற்பட்ட ஆக்டிவ் லார்ஜ்-கேப் ஃபண்டுகள் இன்டெக்ஸை முந்துவதில்லை.',
          'activeVsPassiveB2':
              'குறைந்த கட்டணம் (TER < 0.2%) நீண்ட காலத்திற்கு அதிக லாபம் தரும்.',
          'govtSchemesHeader': 'அரசு சேமிப்பு திட்டங்கள்',
          'ppfTitle': 'PPF வைப்பு நிதி',
          'ppfBadge': '15-ஆண்டு லாக்-இன்',
          'ppfRate': '7.1% ஆண்டு வட்டி',
          'ppfB1': 'ஆண்டு வரம்பு: ₹500 முதல் அதிகபட்சம் ₹1.5 லட்சம் வரை.',
          'ppfB2':
              '15 ஆண்டுகள் முதிர்வு; 7வது ஆண்டில் பகுதி திரும்பப் பெறலாம்.',
          'ppfB3': 'முழு வரி விலக்கு (EEE) அந்தஸ்து.',
          'npsTitle': 'தேசிய ஓய்வூதியம் (NPS)',
          'npsBadge': 'ஓய்வு (வயது 60)',
          'npsRate': '10% – 12% சந்தை வருவாய்',
          'npsB1': 'பிரிவு 80CCD(1B) கீழ் ₹50,000 கூடுதல் வரி விலக்கு.',
          'npsB2': '75% வரை பங்குச் சந்தையில் (E) முதலீடு செய்யலாம்.',
          'npsB3': 'வயது 60ல் 60% வரி இல்லாத் தொகை; 40% ஓய்வூதியமாக மாறும்.',
          'ssyTitle': 'சுகன்யா சம்ரிதி (SSY)',
          'ssyBadge': 'பெண் குழந்தை (<10)',
          'ssyRate': '8.2% ஆண்டு வட்டி',
          'ssyB1': 'அனைத்து சேமிப்பு திட்டங்களிலும் அதிக அரசு வட்டி.',
          'ssyB2': '15 ஆண்டுகள் டெபாசிட்; 21 ஆண்டுகளில் முதிர்வு.',
          'ssyB3': 'முழு வரி விலக்கு (EEE) திட்டம்.',
          'equityHeader': 'பங்குச் சந்தை வழிகாட்டி',
          'largeCapTitle': 'லார்ஜ் கேப் ஃபண்டுகள்',
          'largeCapBadge': 'ஸ்திரத்தன்மை',
          'largeCapSub': 'நாட்டின் டாப் 100 நிறுவனங்கள்',
          'largeCapB1': 'நிலையான வளர்ச்சி மற்றும் டிவிடெண்ட் தரும்.',
          'largeCapB2': 'புதிய முதலீட்டாளர்களுக்கு ஏற்ற மிதமான ரிஸ்க்.',
          'flexiCapTitle': 'ஃப்ளெக்ஸி கேப் ஃபண்டுகள்',
          'flexiCapBadge': 'டைனமிக்',
          'flexiCapSub': 'அனைத்து வகை பங்குகள்',
          'flexiCapB1': 'வளர்ச்சிக்கு ஏற்ப பங்குகள் மாற்றப்படும்.',
          'flexiCapB2': '7+ வருட முதலீட்டிற்கு அதிக வளர்ச்சி வாய்ப்பு.',
          'debtsHeader': 'கடன்கள் & திருப்பி செலுத்துதல்',
          'homeLoanTitle': 'வீட்டுக் கடன் (Home Loan)',
          'homeLoanBadge': 'குறைந்த வட்டி',
          'homeLoanRate': '8.25% – 9.50% மிதக்கும் வட்டி',
          'homeLoanB1':
              'நீண்ட கால கடன். RBI ரெப்போ விகிதத்துடன் இணைக்கப்பட்டது.',
          'homeLoanB2':
              'பழைய வரி முறையில் வட்டி மற்றும் அசலுக்கு வரி விலக்கு உண்டு.',
          'creditDebtTitle': 'கிரெடிட் கார்டு பாக்கி',
          'creditDebtBadge': 'அதிக ஆபத்து',
          'creditDebtRate': '12.0% – 36.0%+ வட்டி',
          'creditDebtB1': 'உடனடியாக அடைக்க வேண்டிய முதன்மை கடன்.',
          'creditDebtB2': 'தினசரி கூட்டு வட்டி முதலீட்டு லாபத்தை அழிக்கும்.',
          'emiMultiplierTitle': 'EMI செல்வ பெருக்கி',
          'emiMultiplierBadge': 'முக்கிய உத்தி',
          'emiMultiplierSub': 'முடிந்த EMI → SIP',
          'emiMultiplierB1':
              'கடன் முடிந்தவுடன் அந்த பணத்தை செலவு செய்யாதீர்கள்.',
          'emiMultiplierB2':
              'உடனடியாக SIP ஆக மாற்றினால் ஓய்வூதிய நிதி பல மடங்கு உயரும்.',
        };
      case 'hi':
        return {
          'hubTitle': 'वित्तीय ज्ञान केंद्र',
          'tab1': 'तुलना',
          'tab2': 'भारत योजनाएं',
          'tab3': 'इक्विटी',
          'tab4': 'ऋण व ईएमआई',
          'tab1Header': 'रणनीतिक तुलना',
          'sipVsLumpTitle': 'SIP बनाम एकमुश्त (Lump Sum)',
          'sipVsLumpBadge': 'जोखिम प्रबंधन',
          'sipVsLumpSub': 'रुपया लागत औसत (RCA) लाभ',
          'sipVsLumpB1':
              'SIP बाजार के उतार-चढ़ाव को औसत करके भावनात्मक निर्णयों को रोकता है।',
          'sipVsLumpB2':
              'गिरावट के समय एकमुश्त निवेश की तुलना में SIP अधिक यूनिट्स दिलाता है।',
          'sipVsLumpB3':
              'वार्षिक स्टेप-अप SIP संपत्ति निर्माण को कई गुना तेज करता है।',
          'activeVsPassiveTitle': 'एक्टिव बनाम इंडेक्स फंड्स',
          'activeVsPassiveBadge': 'व्यय अनुपात',
          'activeVsPassiveSub': 'निफ्टी 50 बनाम एक्टिव फंड्स',
          'activeVsPassiveB1':
              '85% से अधिक एक्टिव लार्ज-कैप फंड बेंचमार्क को मात देने में विफल रहते हैं।',
          'activeVsPassiveB2':
              'अति-कम व्यय अनुपात (TER < 0.2%) लंबी अवधि में अधिक रिटर्न देता है।',
          'govtSchemesHeader': 'सरकारी बचत योजनाएं',
          'ppfTitle': 'पब्लिक प्रोविडेंट फंड (PPF)',
          'ppfBadge': '15-वर्षीय लॉक-इन',
          'ppfRate': '7.1% वार्षिक ब्याज',
          'ppfB1': 'वार्षिक सीमा: न्यूनतम ₹500 से अधिकतम ₹1.5 लाख।',
          'ppfB2': '15 वर्ष परिपक्वता; 7वें वर्ष से आंशिक निकासी की अनुमति।',
          'ppfB3': 'पूर्ण कर-मुक्त (EEE) दर्जा।',
          'npsTitle': 'राष्ट्रीय पेंशन प्रणाली (NPS)',
          'npsBadge': 'आयु 60 परिपक्वता',
          'npsRate': '10% – 12% बाजार आधारित',
          'npsB1': 'धारा 80CCD(1B) के तहत ₹50,000 की विशेष अतिरिक्त कर छूट।',
          'npsB2': 'इक्विटी (E) में 75% तक आवंटन संभव।',
          'npsB3':
              '60 वर्ष की आयु में 60% कर-मुक्त एकमुश्त; 40% से मासिक पेंशन।',
          'ssyTitle': 'सुकन्या समृद्धि योजना (SSY)',
          'ssyBadge': 'बालिका (< 10 वर्ष)',
          'ssyRate': '8.2% गारंटीकृत ब्याज',
          'ssyB1': 'सभी लघु बचत योजनाओं में सर्वाधिक सुरक्षित रिटर्न।',
          'ssyB2': '15 वर्ष जमा; 21 वर्ष में पूर्ण परिपक्वता।',
          'ssyB3': 'पूर्ण रूप से कर-मुक्त (EEE) योजना।',
          'equityHeader': 'इक्विटी और परिसंपत्ति आवंटन',
          'largeCapTitle': 'लार्ज कैप इंडेक्स फंड',
          'largeCapBadge': 'स्थिरता',
          'largeCapSub': 'देश की शीर्ष 100 दिग्गज कंपनियां',
          'largeCapB1': 'दीर्घकालिक पोर्टफोलियो की मजबूत रीढ़।',
          'largeCapB2': 'नियमित लाभांश और मध्यम बाजार उतार-चढ़ाव।',
          'flexiCapTitle': 'फ्लेक्सी-कैप म्यूचुअल फंड',
          'flexiCapBadge': 'गतिशील विकास',
          'flexiCapSub': 'लार्ज, मिड और स्मॉल कैप मिश्रण',
          'flexiCapB1':
              'फंड मैनेजर तेजी से बढ़ते क्षेत्रों में निवेश बदलते हैं।',
          'flexiCapB2': '7 से 10+ वर्षों के निवेश के लिए आदर्श विकल्प।',
          'debtsHeader': 'ऋण प्रबंधन और भुगतान',
          'homeLoanTitle': 'होम लोन (गृह ऋण)',
          'homeLoanBadge': 'कम ब्याज लागत',
          'homeLoanRate': '8.25% – 9.50% फ्लोटिंग दर',
          'homeLoanB1': 'लंबी अवधि का ऋण; आरबीआई रेपो रेट से जुड़ा।',
          'homeLoanB2': 'ब्याज और मूलधन दोनों पर कर छूट उपलब्ध।',
          'creditDebtTitle': 'क्रेडिट कार्ड व पर्सनल लोन',
          'creditDebtBadge': 'अति उच्च जोखिम',
          'creditDebtRate': '12.0% – 36.0%+ प्रति वर्ष',
          'creditDebtB1': 'डेट एवलांच पद्धति से सबसे पहले समाप्त करें।',
          'creditDebtB2':
              'दैनिक चक्रवृद्धि ब्याज सभी निवेश लाभ को मिटा देता है।',
          'emiMultiplierTitle': 'ईएमआई वेल्थ मल्टीप्लायर',
          'emiMultiplierBadge': 'प्रमुख रणनीति',
          'emiMultiplierSub': 'समाप्त ईएमआई → नई SIP',
          'emiMultiplierB1': 'ऋण समाप्त होने पर उस राशि को खर्च न करें।',
          'emiMultiplierB2':
              'तुरंत उस राशि की SIP शुरू करें और ₹30L–₹50L अतिरिक्त कोष बनाएं।',
        };
      case 'te':
        return {
          'hubTitle': 'ఆర్థిక జ్ఞాన కేంద్రం',
          'tab1': 'పోలికలు',
          'tab2': 'ప్రభుత్వ పథకాలు',
          'tab3': 'ఈక్విటీ',
          'tab4': 'అప్పులు & EMI',
          'tab1Header': 'వ్యూహాత్మక పోలికలు',
          'sipVsLumpTitle': 'SIP vs. ఒకేసారి పెట్టుబడి (Lump Sum)',
          'sipVsLumpBadge': 'రిస్క్ తగ్గింపు',
          'sipVsLumpSub': 'రూపీ కాస్ట్ యావరేజింగ్ ప్రయోజనం',
          'sipVsLumpB1': 'SIP మార్కెట్ హెచ్చుతగ్గులను క్రమబద్ధీకరిస్తుంది.',
          'sipVsLumpB2': 'మార్కెట్ పతనాల్లో SIP అధిక లాభాన్ని అందిస్తుంది.',
          'sipVsLumpB3': 'వార్షిక స్టెప్-అప్ SIP సంపదను వేగంగా పెంచుతుంది.',
          'activeVsPassiveTitle': 'యాక్టివ్ vs. ఇండెక్స్ ఫండ్లు',
          'activeVsPassiveBadge': 'ఖర్చు ఆదా',
          'activeVsPassiveSub': 'నిఫ్టీ 50 vs. యాక్టివ్ ఫండ్లు',
          'activeVsPassiveB1':
              '85% కంటే ఎక్కువ యాక్టివ్ లార్జ్-క్యాప్ ఫండ్లు ఇండెక్స్ కంటే తక్కువ రాబడిని ఇస్తాయి.',
          'activeVsPassiveB2':
              'తక్కువ ఖర్చు (TER < 0.2%) దీర్ఘకాలంలో అధిక రాబడినిస్తుంది.',
          'govtSchemesHeader': 'ప్రభుత్వ పొదుపు పథకాలు',
          'ppfTitle': 'పబ్లిక్ ప్రావిడెంట్ ఫండ్ (PPF)',
          'ppfBadge': '15 సంవత్సరాల లాక్-ఇన్',
          'ppfRate': '7.1% వార్షిక వడ్డీ',
          'ppfB1': 'వార్షిక పరిమితి: ₹500 నుండి ₹1.5 లక్షల వరకు.',
          'ppfB2':
              '15 సంవత్సరాల మెచ్యూరిటీ; 7వ సంవత్సరం నుండి పాక్షిక ఉపసంహరణ.',
          'ppfB3': 'పూర్తి పన్ను మినహాయింపు (EEE).',
          'npsTitle': 'జాతీయ పెన్షన్ పథకం (NPS)',
          'npsBadge': '60 ఏళ్ల మెచ్యూరిటీ',
          'npsRate': '10% – 12% మార్కెట్ లింక్డ్',
          'npsB1': 'సెక్షన్ 80CCD(1B) కింద అదనంగా ₹50,000 పన్ను మినహాయింపు.',
          'npsB2': 'ఈక్విటీలో 75% వరకు పెట్టుబడి అవకాశం.',
          'npsB3':
              '60 ఏళ్లకు 60% పన్ను రహిత విత్‌డ్రాయల్, 40% నెలవారీ పెన్షన్.',
          'ssyTitle': 'సుకున్య సమృద్ధి యోజన (SSY)',
          'ssyBadge': 'ఆడపిల్లలు (< 10 ఏళ్లు)',
          'ssyRate': '8.2% స్థిర వడ్డీ',
          'ssyB1': 'చిన్న పొదుపు పథకాలన్నింటిలోనూ అత్యధిక వడ్డీ.',
          'ssyB2': '15 ఏళ్ల డిపాజిట్; 21 ఏళ్లకు మెచ్యూరిటీ.',
          'ssyB3': 'సంపూర్ణ EEE పన్ను హోదా.',
          'equityHeader': 'ఈక్విటీ & కేటాయింపులు',
          'largeCapTitle': 'లార్జ్ క్యాప్ ఇండెక్స్ ఫండ్లు',
          'largeCapBadge': 'స్థిరత్వం',
          'largeCapSub': 'టాప్ 100 బ్లూచిప్ కంపెనీలు',
          'largeCapB1': 'దీర్ఘకాలిక పెట్టుబడులకు బలమైన పునాది.',
          'largeCapB2': 'స్థిరమైన డివిడెండ్లు మరియు మధ్యస్థ రిస్క్.',
          'flexiCapTitle': 'ఫ్లెక్సీ-క్యాప్ ఫండ్లు',
          'flexiCapBadge': 'వృద్ధి',
          'flexiCapSub': 'లార్జ్, మిడ్, స్మాల్ క్యాప్ కలయిక',
          'flexiCapB1': 'అవకాశాలను బట్టి ఫండ్ మేనేజర్ కేటాయింపులు మారుస్తారు.',
          'flexiCapB2': '7+ సంవత్సరాల పెట్టుబడికి అనుకూలం.',
          'debtsHeader': 'అప్పులు & చెల్లింపులు',
          'homeLoanTitle': 'గృహ రుణాలు (Home Loans)',
          'homeLoanBadge': 'తక్కువ వడ్డీ',
          'homeLoanRate': '8.25% – 9.50% ఫ్లోటింగ్ రేటు',
          'homeLoanB1': 'దీర్ఘకాలిక రుణం; RBI రెపో రేటుతో ముడిపడి ఉంటుంది.',
          'homeLoanB2': 'వడ్డీ మరియు అసలు రెండింటిపై పన్ను మినహాయింపులు కలవు.',
          'creditDebtTitle': 'వ్యక్తిగత రుణాలు & క్రెడిట్ కార్డులు',
          'creditDebtBadge': 'తీవ్ర నష్టం',
          'creditDebtRate': '12.0% – 36.0%+ వడ్డీ',
          'creditDebtB1': 'వెంటనే చెల్లించాల్సిన మొదటి అప్పు.',
          'creditDebtB2': 'రోజువారీ చక్రవడ్డీ లాభాలను తుడిచిపెడుతుంది.',
          'emiMultiplierTitle': 'EMI సంపద గుణకం',
          'emiMultiplierBadge': 'ముఖ్య వ్యూహం',
          'emiMultiplierSub': 'పూర్తయిన EMI → SIP',
          'emiMultiplierB1': 'రుణం ముగిసిన తర్వాత ఆ మొత్తాన్ని ఖర్చు చేయవద్దు.',
          'emiMultiplierB2':
              'వెంటనే SIP ప్రారంభించి ₹30L–₹50L అదనపు కార్పస్ నిర్మించండి.',
        };
      case 'kn':
        return {
          'hubTitle': 'ಹಣಕಾಸು ಜ್ಞಾನ ಕೇಂದ್ರ',
          'tab1': 'ಹೋಲಿಕೆಗಳು',
          'tab2': 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',
          'tab3': 'ಷೇರು ಮಾರುಕಟ್ಟೆ',
          'tab4': 'ಸಾಲಗಳು & EMI',
          'tab1Header': 'ಹೂಡಿಕೆ ತಂತ್ರಗಳು',
          'sipVsLumpTitle': 'SIP vs. ಒಟ್ಟು ಮೊತ್ತ (Lump Sum)',
          'sipVsLumpBadge': 'ಅಪಾಯ ನಿರ್ವಹಣೆ',
          'sipVsLumpSub': 'ರೂಪಾಯಿ ವೆಚ್ಚ ಸರಾಸರಿ ಪ್ರಯೋಜನ',
          'sipVsLumpB1': 'SIP ಮಾರುಕಟ್ಟೆಯ ಏರಿಳಿತಗಳನ್ನು ಸರಿದೂಗಿಸುತ್ತದೆ.',
          'sipVsLumpB2': 'ಮಾರುಕಟ್ಟೆ ಕುಸಿತದ ಸಮಯದಲ್ಲಿ SIP ಹೆಚ್ಚು ಪ್ರಯೋಜನಕಾರಿ.',
          'sipVsLumpB3':
              'ಸ್ಟೆಪ್-ಅಪ್ SIP ನಿಮ್ಮ ನಿವೃತ್ತಿ ನಿಧಿಯನ್ನು ದ್ವಿಗುಣಗೊಳಿಸುತ್ತದೆ.',
          'activeVsPassiveTitle': 'ಆಕ್ಟಿವ್ vs. ಇಂಡೆಕ್ಸ್ ಫಂಡ್‌ಗಳು',
          'activeVsPassiveBadge': 'ವೆಚ್ಚ ಉಳಿತಾಯ',
          'activeVsPassiveSub': 'ನಿಫ್ಟಿ 50 vs. ಆಕ್ಟಿವ್ ಫಂಡ್‌ಗಳು',
          'activeVsPassiveB1':
              '85% ಗಿಂತ ಹೆಚ್ಚು ಆಕ್ಟಿವ್ ಫಂಡ್‌ಗಳು ಇಂಡೆಕ್ಸ್‌ಗಿಂತ ಕಡಿಮೆ ಆದಾಯ ನೀಡುತ್ತವೆ.',
          'activeVsPassiveB2':
              'ಕಡಿಮೆ ವೆಚ್ಚ (TER < 0.2%) ದೀರ್ಘಾವಧಿಯಲ್ಲಿ ಹೆಚ್ಚಿನ ಲಾಭ ತರುತ್ತದೆ.',
          'govtSchemesHeader': 'ಸರ್ಕಾರಿ ಉಳಿತಾಯ ಯೋಜನೆಗಳು',
          'ppfTitle': 'ಸಾರ್ವಜನಿಕ ಭವಿಷ್ಯ ನಿಧಿ (PPF)',
          'ppfBadge': '15-ವರ್ಷಗಳ ಲಾಕ್-ಇನ್',
          'ppfRate': '7.1% ವಾರ್ಷಿಕ ಬಡ್ಡಿ',
          'ppfB1': 'ವಾರ್ಷಿಕ ಮಿತಿ: ₹500 ರಿಂದ ₹1.5 ಲಕ್ಷದವರೆಗೆ.',
          'ppfB2': '15 ವರ್ಷಗಳ ಮುಕ್ತಾಯ; 7ನೇ ವರ್ಷದಿಂದ ಭಾಗಶಃ ಹಿಂಪಡೆಯುವಿಕೆ.',
          'ppfB3': 'ಸಂಪೂರ್ಣ ತೆರಿಗೆ ಮುಕ್ತ (EEE) ಯೋಜನೆ.',
          'npsTitle': 'ರಾಷ್ಟ್ರೀಯ ಪಿಂಚಣಿ ವ್ಯವಸ್ಥೆ (NPS)',
          'npsBadge': 'ವಯಸ್ಸು 60 ರ ಮುಕ್ತಾಯ',
          'npsRate': '10% – 12% ಮಾರುಕಟ್ಟೆ ಆಧಾರಿತ',
          'npsB1':
              'ಸೆಕ್ಷನ್ 80CCD(1B) ಅಡಿಯಲ್ಲಿ ₹50,000 ಹೆಚ್ಚುವರಿ ತೆರಿಗೆ ವಿನಾಯಿತಿ.',
          'npsB2': 'ಈಕ್ವಿಟಿಯಲ್ಲಿ 75% ವರೆಗೆ ಹೂಡಿಕೆ ಮಾಡಲು ಅವಕಾಶ.',
          'npsB3': '60 ವರ್ಷದಲ್ಲಿ 60% ತೆರಿಗೆ ರಹಿತ ಮೊತ್ತ, 40% ಮಾಸಿಕ ಪಿಂಚಣಿ.',
          'ssyTitle': 'ಸುಕನ್ಯಾ ಸಮೃದ್ಧಿ ಯೋಜನೆ (SSY)',
          'ssyBadge': 'ಹೆಣ್ಣು ಮಗು (< 10 ವರ್ಷ)',
          'ssyRate': '8.2% ಖಚಿತ ಬಡ್ಡಿ',
          'ssyB1': 'ಎಲ್ಲಾ ಸಣ್ಣ ಉಳಿತಾಯ ಯೋಜನೆಗಳಲ್ಲೇ ಗರಿಷ್ಠ ಬಡ್ಡಿ.',
          'ssyB2': '15 ವರ್ಷ ಠೇವಣಿ; 21 ವರ್ಷಗಳಲ್ಲಿ ಮುಕ್ತಾಯ.',
          'ssyB3': 'ಸಂಪೂರ್ಣ ತೆರಿಗೆ ಮುಕ್ತ (EEE).',
          'equityHeader': 'ಈಕ್ವಿಟಿ ಮತ್ತು ಹಂಚಿಕೆ',
          'largeCapTitle': 'ಲಾರ್ಜ್ ಕ್ಯಾಪ್ ಇಂಡೆಕ್ಸ್ ಫಂಡ್‌ಗಳು',
          'largeCapBadge': 'ಸ್ಥಿರತೆ',
          'largeCapSub': 'ಟಾಪ್ 100 ಬ್ಲೂಚಿಪ್ ಕಂಪನಿಗಳು',
          'largeCapB1': 'ದೀರ್ಘಾವಧಿಯ ಪೋರ್ಟ್‌ಫೋಲಿಯೊದ ಮುಖ್ಯ ಆಧಾರ.',
          'largeCapB2': 'ಸ್ಥಿರ ಲಾಭಾಂಶ ಮತ್ತು ಮಧ್ಯಮ ಮಾರುಕಟ್ಟೆ ಅಪಾಯ.',
          'flexiCapTitle': 'ಫ್ಲೆಕ್ಸಿ-ಕ್ಯಾಪ್ ಫಂಡ್‌ಗಳು',
          'flexiCapBadge': 'ಬೆಳವಣಿಗೆ',
          'flexiCapSub': 'ಎಲ್ಲಾ ವರ್ಗದ ಷೇರುಗಳ ಮಿಶ್ರಣ',
          'flexiCapB1':
              'ಫಂಡ್ ಮ್ಯಾನೇಜರ್ ಬೆಳವಣಿಗೆಗೆ ಅನುಗುಣವಾಗಿ ಷೇರುಗಳನ್ನು ಬದಲಾಯಿಸುತ್ತಾರೆ.',
          'flexiCapB2': '7+ ವರ್ಷಗಳ ಹೂಡಿಕೆಗೆ ಅತ್ಯುತ್ತಮ ಆಯ್ಕೆ.',
          'debtsHeader': 'ಸಾಲಗಳು ಮತ್ತು ಮರುಪಾವತಿ',
          'homeLoanTitle': 'ಗೃಹ ಸಾಲಗಳು (Home Loans)',
          'homeLoanBadge': 'ಕಡಿಮೆ ಬಡ್ಡಿ',
          'homeLoanRate': '8.25% – 9.50% ಫ್ಲೋಟಿಂಗ್ ದರ',
          'homeLoanB1': 'ದೀರ್ಘಾವಧಿ ಸಾಲ; RBI ರೆಪೊ ದರಕ್ಕೆ ಲಿಂಕ್ ಆಗಿದೆ.',
          'homeLoanB2': 'ಬಡ್ಡಿ ಮತ್ತು ಅಸಲು ಎರಡರ ಮೇಲೂ ತೆರಿಗೆ ವಿನಾಯಿತಿ ಲಭ್ಯವಿದೆ.',
          'creditDebtTitle': 'ವೈಯಕ್ತಿಕ ಸಾಲ ಮತ್ತು ಕ್ರೆಡಿಟ್ ಕಾರ್ಡ್',
          'creditDebtBadge': 'ಅತಿ ಹೆಚ್ಚು ಅಪಾಯ',
          'creditDebtRate': '12.0% – 36.0%+ ಬಡ್ಡಿ',
          'creditDebtB1': 'ಮೊದಲು ಮರುಪಾವತಿಸಬೇಕಾದ ಅಪಾಯಕಾರಿ ಸಾಲ.',
          'creditDebtB2':
              'ದೈನಂದಿನ ಚಕ್ರಬಡ್ಡಿ ನಿಮ್ಮ ಹೂಡಿಕೆಯ ಲಾಭವನ್ನು ನಾಶಪಡಿಸುತ್ತದೆ.',
          'emiMultiplierTitle': 'EMI ವೆಲ್ತ್ ಮಲ್ಟಿಪ್ಲೈಯರ್',
          'emiMultiplierBadge': 'ಮುಖ್ಯ ತಂತ್ರ',
          'emiMultiplierSub': 'ಮುಗಿದ EMI → ಹೊಸ SIP',
          'emiMultiplierB1': 'ಸಾಲ ತೀರಿದ ತಕ್ಷಣ ಆ ಹಣವನ್ನು ವ್ಯರ್ಥ ಮಾಡಬೇಡಿ.',
          'emiMultiplierB2':
              'ತಕ್ಷಣವೇ SIP ಆರಂಭಿಸಿ ₹30L–₹50L ಹೆಚ್ಚುವರಿ ನಿಧಿ ನಿರ್ಮಿಸಿ.',
        };
      case 'ml':
        return {
          'hubTitle': 'ധനകാര്യ വിജ്ഞാന കേന്ദ്രം',
          'tab1': 'താരതമ്യങ്ങൾ',
          'tab2': 'പദ്ധതികൾ',
          'tab3': 'ഓഹരികൾ',
          'tab4': 'വായ്പകളും EMI-യും',
          'tab1Header': 'നിക്ഷേപ തന്ത്രങ്ങൾ',
          'sipVsLumpTitle': 'SIP vs. ലംപ് സം (Lump Sum)',
          'sipVsLumpBadge': 'റിസ്ക് കുറയ്ക്കൽ',
          'sipVsLumpSub': 'റുപ്പീ കോസ്റ്റ് ആവറേജിംഗ് നേട്ടം',
          'sipVsLumpB1': 'SIP വിപണിയിലെ ഏറ്റക്കുറച്ചിലുകളെ ക്രമീകരിക്കുന്നു.',
          'sipVsLumpB2':
              'വിപണി ഇടിയുന്ന സമയങ്ങളിൽ SIP കൂടുതൽ പ്രയോജനം നൽകുന്നു.',
          'sipVsLumpB3':
              'സ്റ്റെപ്പ്-അപ്പ് SIP സമ്പത്ത് വേഗത്തിൽ വർദ്ധിപ്പിക്കുന്നു.',
          'activeVsPassiveTitle': 'ആക്ടീവ് vs. ഇൻഡക്സ് ഫണ്ടുകൾ',
          'activeVsPassiveBadge': 'ചെലവ് ലാഭം',
          'activeVsPassiveSub': 'നിഫ്റ്റി 50 vs. ആക്ടീവ് ഫണ്ടുകൾ',
          'activeVsPassiveB1':
              '85% ആക്ടീവ് ലാർജ്-ക്യാപ് ഫണ്ടുകളും ഇൻഡക്സിനേക്കാൾ കുറഞ്ഞ റിട്ടേൺ നൽകുന്നു.',
          'activeVsPassiveB2':
              'കുറഞ്ഞ ചെലവ് (TER < 0.2%) ദീർഘകാലത്തേക്ക് ഉയർന്ന വരുമാനം നൽകുന്നു.',
          'govtSchemesHeader': 'സർക്കാർ നിക്ഷേപ പദ്ധതികൾ',
          'ppfTitle': 'പബ്ലിക് പ്രൊവിഡന്റ് ഫണ്ട് (PPF)',
          'ppfBadge': '15-വർഷത്തെ ലോക്ക്-ഇൻ',
          'ppfRate': '7.1% വാർഷിക പലിശ',
          'ppfB1': 'വാർഷിക പരിധി: ₹500 മുതൽ ₹1.5 ലക്ഷം വരെ.',
          'ppfB2': '15 വർഷത്തെ കാലാവധി; 7-ാം വർഷം മുതൽ പിൻവലിക്കാം.',
          'ppfB3': 'പൂർണ്ണ നികുതി രഹിത (EEE) പദവി.',
          'npsTitle': 'ദേശീയ പെൻഷൻ പദ്ധതി (NPS)',
          'npsBadge': '60 വയസ്സിൽ കാലാവധി',
          'npsRate': '10% – 12% വിപണി വരുമാനം',
          'npsB1': '80CCD(1B) പ്രകാരം ₹50,000 അധിക നികുതി ഇളവ്.',
          'npsB2': 'ഓഹരി വിപണിയിൽ 75% വരെ നിക്ഷേപിക്കാം.',
          'npsB3': '60 വയസ്സിൽ 60% നികുതി രഹിത തുക, 40% പെൻഷനായി മാറും.',
          'ssyTitle': 'സുകന്യ സമൃദ്ധി യോജന (SSY)',
          'ssyBadge': 'പെൺകുട്ടികൾ (< 10 വയസ്സ്)',
          'ssyRate': '8.2% ഉറപ്പായ പലിശ',
          'ssyB1': 'ചെറുകിട നിക്ഷേപങ്ങളിൽ ഏറ്റവും ഉയർന്ന പലിശ.',
          'ssyB2': '15 വർഷത്തെ നിക്ഷേപം; 21 വർഷത്തിൽ കാലാവധി.',
          'ssyB3': 'പൂർണ്ണ നികുതി രഹിത (EEE) പദ്ധതി.',
          'equityHeader': 'ഓഹരി നിക്ഷേപങ്ങൾ',
          'largeCapTitle': 'ലാർജ് ക്യാപ് ഇൻഡക്സ് ഫണ്ടുകൾ',
          'largeCapBadge': 'സ്ഥിരത',
          'largeCapSub': 'രാജ്യത്തെ മികച്ച 100 കമ്പനികൾ',
          'largeCapB1': 'ദീർഘകാല നിക്ഷേപങ്ങൾക്ക് സുരക്ഷിതമായ അടിത്തറ.',
          'largeCapB2': 'സ്ഥിരമായ ലാഭവിഹിതവും മിതമായ റിസ്കും.',
          'flexiCapTitle': 'ഫ്ലെക്സി-ക്യാപ് ഫണ്ടുകൾ',
          'flexiCapBadge': 'വളർച്ച',
          'flexiCapSub': 'ലാർജ്, മിഡ്, സ്മോൾ ക്യാപ് മിശ്രിതം',
          'flexiCapB1':
              'സാഹചര്യത്തിനനുസരിച്ച് ഫണ്ട് മാനേജർ നിക്ഷേപം മാറ്റുന്നു.',
          'flexiCapB2': '7+ വർഷത്തെ നിക്ഷേപത്തിന് ഏറ്റവും അനുയോജ്യം.',
          'debtsHeader': 'വായ്പകളും തിരിച്ചടവും',
          'homeLoanTitle': 'ഭവന വായ്പകൾ (Home Loans)',
          'homeLoanBadge': 'കുറഞ്ഞ പലിശ',
          'homeLoanRate': '8.25% – 9.50% ഫ്ലോട്ടിംഗ് പലിശ',
          'homeLoanB1':
              'ദീർഘകാല വായ്പ; RBI റിപ്പോ നിരക്കുമായി ബന്ധിപ്പിച്ചിരിക്കുന്നു.',
          'homeLoanB2': 'പലിശയ്ക്കും മുതലിനും നികുതി ഇളവുകൾ ലഭ്യമാണ്.',
          'creditDebtTitle': 'ക്രെഡിറ്റ് കാർഡും വ്യക്തിഗത വായ്പയും',
          'creditDebtBadge': 'ഉയർന്ന അപകടം',
          'creditDebtRate': '12.0% – 36.0%+ പലിശ',
          'creditDebtB1': 'ഉടൻ തന്നെ തിരിച്ചടയ്ക്കേണ്ട പ്രധാന ബാധ്യത.',
          'creditDebtB2':
              'ദൈനംദിന കൂട്ടുപലിശ നിങ്ങളുടെ സമ്പാദ്യം ഇല്ലാതാക്കും.',
          'emiMultiplierTitle': 'EMI വെൽത്ത് മൾട്ടിപ്ലയർ',
          'emiMultiplierBadge': 'പ്രധാന തന്ത്രം',
          'emiMultiplierSub': 'തീർന്ന EMI → പുതിയ SIP',
          'emiMultiplierB1': 'വായ്പ തീർന്നയുടൻ ആ തുക ചെലവഴിക്കാതിരിക്കുക.',
          'emiMultiplierB2':
              'ഉടൻ തന്നെ SIP ആക്കി മാറ്റി ₹30L–₹50L അധിക സമ്പത്ത് ഉണ്ടാക്കുക.',
        };
      default:
        return {
          'hubTitle': 'Financial Knowledge Hub',
          'tab1': 'Versus',
          'tab2': 'India Schemes',
          'tab3': 'Equity',
          'tab4': 'Debts & EMI',
          'tab1Header': 'Strategy Showdowns',
          'sipVsLumpTitle': 'SIP vs. Lump Sum',
          'sipVsLumpBadge': 'Timing Risk',
          'sipVsLumpSub': 'Rupee Cost Averaging Advantage',
          'sipVsLumpB1':
              'SIP eliminates emotional market timing by averaging market swings over cycles.',
          'sipVsLumpB2':
              'Outperforms lump sum deployments during volatile and downward market regimes.',
          'sipVsLumpB3':
              'Annual Step-Up SIP significantly accelerates terminal wealth compounding.',
          'activeVsPassiveTitle': 'Active vs. Index Funds',
          'activeVsPassiveBadge': 'Expense Alpha',
          'activeVsPassiveSub': 'Nifty 50 Index vs. Active Large Cap',
          'activeVsPassiveB1':
              'Over 85% of active large-cap funds fail to consistently outperform their benchmark.',
          'activeVsPassiveB2':
              'Ultra-low expense ratios (TER < 0.2%) compound greater net wealth over 15+ years.',
          'govtSchemesHeader': 'Government & Retirement Vehicles',
          'ppfTitle': 'Public Provident Fund (PPF)',
          'ppfBadge': '15-Yr Lock-In',
          'ppfRate': '7.1% p.a. (Govt Revised)',
          'ppfB1':
              'Annual limit: ₹500 minimum to ₹1.5 Lakh maximum per financial year.',
          'ppfB2':
              '15-year maturity; partial withdrawals permitted from the 7th financial year.',
          'ppfB3':
              'EEE tax status: Principal, accrued interest, and maturity sum are 100% tax-exempt.',
          'npsTitle': 'National Pension System (NPS)',
          'npsBadge': 'Age 60 Maturity',
          'npsRate': '10% – 12% Market Linked',
          'npsB1':
              'Section 80CCD(1B) provides an exclusive ₹50,000 tax deduction above the 80C limit.',
          'npsB2':
              'Active Choice permits up to 75% equity allocation (E) with corporate/govt debt.',
          'npsB3':
              'At age 60, 60% corpus is a tax-free lump sum; 40% converts to mandatory monthly annuity.',
          'ssyTitle': 'Sukanya Samriddhi Yojana (SSY)',
          'ssyBadge': 'Girl Child (< 10 Yrs)',
          'ssyRate': '8.2% p.a. Guaranteed',
          'ssyB1':
              'Highest guaranteed sovereign return among all small savings instruments.',
          'ssyB2':
              '15-year deposit tenure; matures in 21 years or upon marriage after age 18.',
          'ssyB3': 'Complete EEE tax-exempt status.',
          'equityHeader': 'Equity & Asset Allocation',
          'largeCapTitle': 'Large Cap Index Funds',
          'largeCapBadge': 'Core Stability',
          'largeCapSub': 'Top 100 Bluechip Indian Enterprises',
          'largeCapB1':
              'Forms the resilient core of long-term wealth compounding portfolios.',
          'largeCapB2':
              'Delivers consistent dividend reinvestment with moderate market volatility.',
          'flexiCapTitle': 'Flexi-Cap Mutual Funds',
          'flexiCapBadge': 'Dynamic Growth',
          'flexiCapSub': 'Large, Mid & Small Cap Blend',
          'flexiCapB1':
              'Fund manager actively rotates capital into high-growth emerging sectors.',
          'flexiCapB2':
              'Recommended equity vehicle for investment horizons exceeding 7 to 10+ years.',
          'debtsHeader': 'Liabilities & Payoff Frameworks',
          'homeLoanTitle': 'Home Loans (Mortgages)',
          'homeLoanBadge': 'Low Borrowing Cost',
          'homeLoanRate': '8.25% – 9.50% Floating Rate',
          'homeLoanB1':
              'Amortizes over 15–30 years; floating interest rate pegged to the RBI repo rate.',
          'homeLoanB2':
              'Tax deductions available on interest (Sec 24b) and principal repayment (Sec 80C).',
          'creditDebtTitle': 'Personal Loans & Credit Cards',
          'creditDebtBadge': 'Wealth Destroyer',
          'creditDebtRate': '12.0% – 36.0%+ p.a.',
          'creditDebtB1':
              'Must be repaid immediately using the Debt Avalanche payoff method.',
          'creditDebtB2':
              'High compounding daily interest rapidly erodes all portfolio capital gains.',
          'emiMultiplierTitle': 'The "EMI Unlock" Multiplier',
          'emiMultiplierBadge': 'Core Strategy',
          'emiMultiplierSub': 'Redirect Finished EMI → SIP',
          'emiMultiplierB1':
              'When any loan ends, avoid absorbing that free cashflow into lifestyle expenses.',
          'emiMultiplierB2':
              'Immediately channel the finished EMI into an equity SIP to build ₹30L–₹50L extra corpus.',
        };
    }
  }
}
