/// Static content for the portfolio, sourced from Neesarg's résumé.
///
/// Kept in one place so copy edits never require touching layout code.
library;

class Contact {
  const Contact({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    required this.linkedIn,
    required this.location,
  });

  final String name;
  final String role;
  final String phone;
  final String email;
  final String linkedIn;
  final String location;
}

class ExperienceItem {
  const ExperienceItem({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.period,
    required this.tag,
    required this.bullets,
  });

  final String index;
  final String title;
  final String subtitle;
  final String period;
  final String tag;
  final List<String> bullets;
}

class Stat {
  const Stat({required this.value, required this.label});
  final String value;
  final String label;
}

/// A featured project for the visual phone-mockup gallery.
///
/// [shots] are asset paths. Drop matching PNG/JPGs into `assets/work/` and they
/// render automatically; until then a styled placeholder is shown.
class WorkProject {
  const WorkProject({
    required this.name,
    required this.tag,
    required this.blurb,
    required this.shots,
    required this.icon,
    required this.url,
  });

  final String name;
  final String tag;
  final String blurb;

  /// App Store screenshot asset paths (the focused card cycles through these).
  final List<String> shots;

  /// App icon asset path.
  final String icon;

  /// App Store listing URL.
  final String url;
}

class SkillGroup {
  const SkillGroup({required this.title, required this.skills});
  final String title;
  final List<String> skills;
}

class ResumeData {
  ResumeData._();

  static const contact = Contact(
    name: 'Neesarg Darji',
    role: 'Senior Flutter Developer',
    phone: '+91 74050 69568',
    email: 'nisd997@gmail.com',
    linkedIn: 'https://www.linkedin.com/in/neesarg-darji',
    location: 'Ahmedabad, India',
  );

  static const String heroLineOne = 'Senior';
  static const String heroLineTwo = 'Flutter';
  static const String heroLineThree = 'Developer';

  static const String intro =
      '5+ years shipping production iOS and Android apps in healthcare and '
      'e-commerce. I own architecture, coding standards and releases — with a '
      'focus on data-driven crash reduction and app stability.';

  static const String aboutExpanded =
      'I lead Flutter development on client projects across healthcare, '
      'e-commerce, e-learning, fitness and travel. From VoIP calling and '
      'real-time chat to clean-architecture rewrites and crash analytics at '
      'the scale of millions of reports — I care about apps that stay stable '
      'under real-world load, and teams that ship with confidence.';

  /// Headline numbers for the "by the numbers" strip.
  static const List<Stat> stats = [
    Stat(value: '5+', label: 'Years shipping'),
    Stat(value: '11+', label: 'Connected apps · AL OBEIKAN'),
    Stat(value: '5.3M', label: 'Crash reports analysed'),
    Stat(value: '116K', label: 'Crashes cleared · one pass'),
  ];

  static const List<SkillGroup> skillGroups = [
    SkillGroup(
      title: 'Core',
      skills: [
        'Flutter (iOS & Android)',
        'Dart',
        'REST APIs',
        'GraphQL',
        'Firebase',
      ],
    ),
    SkillGroup(
      title: 'Architecture & State',
      skills: [
        'MVVM',
        'Clean Architecture',
        'Bloc / Cubit',
        'Provider',
        'GetX',
        'Riverpod',
        'get_it / injectable',
      ],
    ),
    SkillGroup(
      title: 'Platform & Integrations',
      skills: [
        'VoIP',
        'FCM',
        'GoRouter & deep linking',
        'Payment gateways',
        'Real-time chat',
      ],
    ),
    SkillGroup(
      title: 'Quality & Delivery',
      skills: [
        'Firebase Analytics',
        'Mixpanel',
        'Luciq (Instabug)',
        'Crashlytics',
        'Shorebird',
        'CI/CD',
      ],
    ),
    SkillGroup(
      title: 'AI & Agents',
      skills: [
        'Google ADK',
        'Gemini',
        'Tool / function calling',
        'RAG',
        'Claude Code',
        'OpenAI Codex',
      ],
    ),
  ];

  /// Flat list used by the scrolling skills marquee.
  static const List<String> skillMarquee = [
    'Flutter',
    'Dart',
    'Bloc',
    'Clean Architecture',
    'VoIP',
    'FCM',
    'GraphQL',
    'Firebase',
    'Riverpod',
    'GetX',
    'Shorebird',
    'CI/CD',
    'Crashlytics',
    'Mixpanel',
    'GoRouter',
    'RAG',
    'Gemini',
  ];

  /// Live, shipped apps (real App Store listings). Screenshots + icons are
  /// pulled from the App Store and bundled under `assets/work/`.
  static const List<WorkProject> featuredWork = [
    WorkProject(
      name: 'eXtra',
      tag: 'Retail · E-Commerce',
      blurb:
          'Bilingual retail app for United Electronics (KSA) — cart, checkout '
          'and payments rebuilt into clean architecture at scale.',
      shots: [
        'assets/work/extra_1.png',
        'assets/work/extra_2.png',
        'assets/work/extra_3.png',
        'assets/work/extra_4.png',
      ],
      icon: 'assets/work/extra_icon.jpg',
      url: 'https://apps.apple.com/in/app/extra/id584430757',
    ),
    WorkProject(
      name: 'Saned Health',
      tag: 'Healthcare · Patient',
      blurb:
          'Patient super-app for the Al Obeikan health platform — appointments, '
          'instant consultations, home care and telemedicine.',
      shots: [
        'assets/work/saned_health_1.png',
        'assets/work/saned_health_2.png',
        'assets/work/saned_health_3.png',
        'assets/work/saned_health_4.png',
      ],
      icon: 'assets/work/saned_health_icon.jpg',
      url: 'https://apps.apple.com/in/app/saned-health/id1583962496',
    ),
    WorkProject(
      name: 'Second Opinion',
      tag: 'Telemedicine',
      blurb:
          'Connects patients with specialists for a trusted second medical '
          'opinion — bookings, chat and secure records.',
      shots: [
        'assets/work/second_opinion_1.png',
        'assets/work/second_opinion_2.png',
        'assets/work/second_opinion_3.png',
        'assets/work/second_opinion_4.png',
      ],
      icon: 'assets/work/second_opinion_icon.jpg',
      url: 'https://apps.apple.com/in/app/second-opinion/id6446490163',
    ),
    WorkProject(
      name: 'M-Provider',
      tag: 'Health · Provider',
      blurb:
          'Provider app for Meena Health — manage visits, availability and '
          'patient interactions.',
      shots: [
        'assets/work/m_provider_1.png',
        'assets/work/m_provider_2.png',
        'assets/work/m_provider_3.png',
        'assets/work/m_provider_4.png',
      ],
      icon: 'assets/work/m_provider_icon.jpg',
      url: 'https://apps.apple.com/in/app/m-provider/id6745809309',
    ),
    WorkProject(
      name: 'GlobCare',
      tag: 'Healthcare',
      blurb:
          'Digital health services app (Arabian Shifa) — appointments, '
          'consultations and care on the go.',
      shots: [
        'assets/work/globcare_1.png',
        'assets/work/globcare_2.png',
        'assets/work/globcare_3.png',
        'assets/work/globcare_4.png',
      ],
      icon: 'assets/work/globcare_icon.jpg',
      url: 'https://apps.apple.com/in/app/globcare/id1613719569',
    ),
    WorkProject(
      name: 'Farabi Lab Home Care',
      tag: 'Lab · Home Care',
      blurb:
          'At-home lab sample collection and results — book a visit, track the '
          'technician and get reports.',
      shots: [
        'assets/work/farabi_home_care_1.png',
        'assets/work/farabi_home_care_2.png',
        'assets/work/farabi_home_care_3.png',
        'assets/work/farabi_home_care_4.png',
      ],
      icon: 'assets/work/farabi_home_care_icon.jpg',
      url: 'https://apps.apple.com/in/app/farabi-lab-home-care/id6618148993',
    ),
    WorkProject(
      name: 'Second Opinion · Doctors',
      tag: 'Telemedicine · Doctor',
      blurb:
          'The clinician companion — manage consultation requests, patient '
          'cases and video visits.',
      shots: [
        'assets/work/second_opinion_doctors_1.png',
        'assets/work/second_opinion_doctors_2.png',
        'assets/work/second_opinion_doctors_3.png',
        'assets/work/second_opinion_doctors_4.png',
      ],
      icon: 'assets/work/second_opinion_doctors_icon.jpg',
      url: 'https://apps.apple.com/in/app/second-opinion-doctors/id6590627881',
    ),
    WorkProject(
      name: 'Saned Health Provider',
      tag: 'Healthcare · Provider',
      blurb:
          'Provider app for clinicians on the Saned platform — patient cases, '
          'scheduling and care coordination.',
      shots: [
        'assets/work/saned_health_provider_1.png',
        'assets/work/saned_health_provider_2.png',
        'assets/work/saned_health_provider_3.png',
        'assets/work/saned_health_provider_4.png',
      ],
      icon: 'assets/work/saned_health_provider_icon.jpg',
      url: 'https://apps.apple.com/in/app/saned-health-provider/id6449666704',
    ),
    WorkProject(
      name: 'Saned Care Provider',
      tag: 'Home Care · Provider',
      blurb:
          'Field app for care providers and ambulance crews — shared patient '
          'cases across the care network.',
      shots: [
        'assets/work/saned_care_provider_1.png',
        'assets/work/saned_care_provider_2.png',
        'assets/work/saned_care_provider_3.png',
        'assets/work/saned_care_provider_4.png',
      ],
      icon: 'assets/work/saned_care_provider_icon.jpg',
      url: 'https://apps.apple.com/in/app/saned-care-provider/id1631325091',
    ),
  ];

  static const List<ExperienceItem> experience = [
    ExperienceItem(
      index: '01',
      title: 'AL OBEIKAN',
      subtitle: 'Healthcare Platform',
      period: '2021 — Present',
      tag: 'Healthcare',
      bullets: [
        'Built and shipped 11+ connected apps for patients, doctors, care providers, ambulance crews and admins.',
        'Built patient medical history, diagnosis charts and secure access to medical reports.',
        'Implemented incoming calls with VoIP push on iOS and FCM on Android.',
        'Connected the ambulance and doctor apps so both sides work on the same patient case.',
        'Built pharmacy platform apps with e-prescriptions, delivery and HyperPay.',
      ],
    ),
    ExperienceItem(
      index: '02',
      title: 'EXTRA',
      subtitle: 'E-Commerce App',
      period: '2021 — Present',
      tag: 'E-Commerce',
      bullets: [
        'Re-developed and stabilized a bilingual (English/Arabic) retail app across cart, checkout and payments.',
        'Restructured all 26 modules into clean architecture with Bloc/Cubit and a single Dio network layer.',
        'Analyzed 5.3M crash reports in Luciq and found 71% were network drops, not real crashes.',
        'Fixed the splash-screen crash behind 25% of reports — one pass cleared 116K crashes for 35K users.',
        'Defined crash-handling standards and rolled out Shorebird code push and CI/CD.',
      ],
    ),
    ExperienceItem(
      index: '03',
      title: 'MKAT',
      subtitle: 'Ticketing App',
      period: '2021 — Present',
      tag: 'Support',
      bullets: [
        'Built a support ticketing app where users raise tickets with voice notes and images and track them to closure.',
        'Added event booking, Razorpay payments and a learning video library.',
        'Set up Bloc architecture, FCM notifications, Crashlytics and multi-environment builds.',
      ],
    ),
    ExperienceItem(
      index: '04',
      title: 'Shala Yoga',
      subtitle: 'Fitness App',
      period: '2021 — Present',
      tag: 'Fitness',
      bullets: [
        'Built a subscription app for structured yoga programs and classes.',
        'Added instructor chat, video lessons and a rewards system to keep users engaged.',
      ],
    ),
    ExperienceItem(
      index: '05',
      title: 'Open edX',
      subtitle: 'E-Learning App',
      period: '2021 — Present',
      tag: 'E-Learning',
      bullets: [
        'Built a mobile client for the Open edX platform with course outlines, programs, discussions and handouts.',
        'Added video lessons (YouTube and hosted) and in-app rendering of HTML course units.',
      ],
    ),
  ];

  static const String company = 'CodeTrade India Pvt. Ltd.';
  static const String companyRole = 'Senior Flutter Developer · 2021 — Present';
  static const String education =
      'B.E. Computer Engineering — SAL Institute of Technology & Engineering '
      'Research, Ahmedabad · CGPA 8.28 · 2021';
}
