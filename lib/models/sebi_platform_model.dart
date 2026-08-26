class SebiPlatform {
  final String name;
  final String entityType;
  final String sebiRegNumber;
  final String depositoryOrRta;
  final String format;
  final String brokerageFee;
  final String officialPortal;
  final String trustHighlight;

  const SebiPlatform({
    required this.name,
    required this.entityType,
    required this.sebiRegNumber,
    required this.depositoryOrRta,
    required this.format,
    required this.brokerageFee,
    required this.officialPortal,
    required this.trustHighlight,
  });
}

final List<SebiPlatform> kTrustedPlatforms = [
  const SebiPlatform(
    name: 'MF Central',
    entityType: 'Official QRTA Joint Initiative',
    sebiRegNumber: 'CAMS (INR000002810) & KFintech (INR000000221)',
    depositoryOrRta: 'Direct Registrar & Transfer Agent (CAMS & KFintech)',
    format: 'Non-Demat (Direct Statement of Account)',
    brokerageFee: '100% Free & Sovereign Direct',
    officialPortal: 'mfcentral.com',
    trustHighlight:
        'Direct official gateway mandated by SEBI; zero broker intermediation.',
  ),
  const SebiPlatform(
    name: 'Zerodha (Coin)',
    entityType: 'SEBI-Registered Stock Broker & Depository Participant',
    sebiRegNumber: 'INZ000031633 (NSE/BSE), CDSL DP ID: 12081600',
    depositoryOrRta: 'CDSL Demat',
    format: 'Demat Account',
    brokerageFee: '₹0 Commission on Direct Mutual Funds',
    officialPortal: 'coin.zerodha.com',
    trustHighlight:
        'Units reside in your Central Depository (CDSL) demat along with equities & SGBs.',
  ),
  const SebiPlatform(
    name: 'Groww',
    entityType: 'SEBI-Registered Stock Broker (Nextbillion Technology)',
    sebiRegNumber: 'INZ000301838, CDSL DP ID: 12088700',
    depositoryOrRta: 'BSE StAR MF / CDSL Demat',
    format: 'Demat / Exchange Order Routing',
    brokerageFee: '₹0 Commission on Direct Mutual Funds',
    officialPortal: 'groww.in',
    trustHighlight:
        'Automated 1-click UPI AutoPay with direct exchange settlement.',
  ),
  const SebiPlatform(
    name: 'Direct AMC Websites',
    entityType: 'SEBI-Registered Mutual Fund Houses (AMCs)',
    sebiRegNumber: 'SEBI (Mutual Funds) Regulations, 1996',
    depositoryOrRta: 'SBI MF, HDFC MF, ICICI Pru, Nippon, PPFAS, etc.',
    format: 'Folio-Direct (RTA SOA)',
    brokerageFee: 'Zero Middleman',
    officialPortal: 'amfiindia.com',
    trustHighlight:
        'Invest directly on fund house portals (e.g. sbimf.com, hdfcfund.com).',
  ),
];
