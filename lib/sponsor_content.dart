import 'package:flutter/material.dart';

class SponsorContact {
  const SponsorContact(this.icon, this.value, this.action, {this.url});
  final String? url;
  final IconData icon;
  final String value, action;
}

class SponsorInfo {
  const SponsorInfo(
    this.name, {
    required this.logoAsset,
    this.heading = 'SUPPORTED BY',
    this.interactive = true,
    this.videoUrl,
    this.slogan = '“Your slogan goes here”',
    this.contacts = const [
      SponsorContact(Icons.call_outlined, '+63 XXX XXX XXXX', 'Call'),
      SponsorContact(Icons.email_outlined, 'email@example.com', 'Email'),
      SponsorContact(Icons.language, 'example.com', 'Visit'),
    ],
  });
  final String name;
  final String logoAsset;
  final String heading;
  final bool interactive;
  final String? videoUrl;
  Rect get cardBounds {
    final slot = sponsors.indexOf(this) - 3;
    if (slot == 0) return const Rect.fromLTWH(24, 154, 462, 222);
    return Rect.fromLTWH(24 + (slot - 1) * 158, 400, 146, 222);
  }

  Rect get collapsedLogoBounds => Rect.fromCenter(
    center: Offset(
      cardBounds.center.dx,
      cardBounds.top + (cardBounds.width < 150 ? 92 : 103),
    ),
    width: cardBounds.width < 150 ? 112 : 150,
    height: cardBounds.width < 150 ? 112 : 150,
  );
  Rect get expandedLogoBounds => Rect.fromCenter(
    center: Offset(
      cardBounds.center.dx,
      cardBounds.top + (cardBounds.width < 150 ? 66 : 80),
    ),
    width: cardBounds.width < 150 ? 60 : 64,
    height: cardBounds.width < 150 ? 60 : 64,
  );
  Rect get contactBounds => Rect.fromLTWH(
    cardBounds.left,
    expandedLogoBounds.bottom + 8,
    cardBounds.width,
    contacts.length * 18,
  );
  Rect get playButtonBounds => Rect.fromCenter(
    center: Offset(cardBounds.center.dx, contactBounds.bottom + 18),
    width: 28,
    height: 28,
  );

  final String slogan;
  final List<SponsorContact> contacts;
}

const sponsors = [
  SponsorInfo(
    'Puerto Princesa City',
    logoAsset: 'ppc_logo.png',
    heading: 'PRESENTED BY',
    interactive: false,
    slogan: '',
    contacts: [],
  ),
  SponsorInfo(
    'City Tourism Office',
    logoAsset: 'ct_logo.png',
    heading: '',
    interactive: false,
    slogan: '',
    contacts: [],
  ),
  SponsorInfo(
    'City Tourism Council',
    logoAsset: 'ctc_logo.png',
    heading: '',
    interactive: false,
    slogan: '',
    contacts: [],
  ),
  SponsorInfo(
    'SPEEDOVATE ICT SOLUTIONS',
    logoAsset: 'speedovate.jpg',
    heading: 'POWERED BY',
    videoUrl: 'https://www.facebook.com/share/v/1DiLDeMJTG/',
    slogan: '“We help leaders build and digitalize their systems”',
    contacts: [
      SponsorContact(
        Icons.call_outlined,
        '09926715321',
        'Call',
        url: 'tel:+639926715321',
      ),
      SponsorContact(
        Icons.email_outlined,
        'connect@speedovate.com',
        'Email',
        url: 'mailto:connect@speedovate.com',
      ),
      SponsorContact(
        Icons.language,
        'speedovate.com',
        'Visit',
        url: 'https://www.speedovate.com',
      ),
    ],
  ),
  SponsorInfo(
    'FOUR POINTS',
    logoAsset: 'fourpoints.jpg',
    videoUrl: 'https://www.facebook.com/reel/756294230139768',
    slogan:
        '“Experience paradise at our beachfront resort, just moments from the breathtaking UNESCO World Heritage Site Puerto Princesa Underground River”',
    contacts: [
      SponsorContact(
        Icons.call_outlined,
        '048 550 9000',
        'Call',
        url: 'tel:+63485509000',
      ),
      SponsorContact(
        Icons.email_outlined,
        'reservations.palawan@fourpoints.com',
        'Email',
        url: 'mailto:reservations.palawan@fourpoints.com',
      ),
      SponsorContact(
        Icons.language,
        'fourpointspalawan.com',
        'Visit',
        url: 'https://www.fourpointspalawan.com',
      ),
    ],
  ),
  SponsorInfo(
    'CASA GERMANA',
    logoAsset: 'casa_germana.jpg',
    videoUrl: 'https://www.facebook.com/share/r/19Vm3pJD9s/',
    slogan:
        '“A charming budget boutique hotel that offers comfortable accommodations at an affordable price.”',
    contacts: [
      SponsorContact(
        Icons.call_outlined,
        '0964 946 8416',
        'Call',
        url: 'tel:+639649468416',
      ),
      SponsorContact(
        Icons.email_outlined,
        'casagermanapalawan@gmail.com',
        'Email',
        url: 'mailto:casagermanapalawan@gmail.com',
      ),
      SponsorContact(
        Icons.language,
        'facebook.com/casagermanapalawan',
        'Visit',
        url: 'https://www.facebook.com/casagermanapalawan',
      ),
    ],
  ),
  SponsorInfo(
    'ASIA UNITED BANK',
    logoAsset: 'asia_united_bank.png',
    videoUrl: 'https://www.facebook.com/share/v/198jPDU5EG/',
    // Excerpt from the bank's published mission, not an invented tagline.
    slogan:
        '“Developing long-term partnerships with clients through the delivery of responsive, innovative, and value-added products and services”',
    contacts: [
      SponsorContact(
        Icons.call_outlined,
        '(02) 8282-8888',
        'Call',
        url: 'tel:+63282828888',
      ),
      SponsorContact(
        Icons.email_outlined,
        'customercare@aub.com.ph',
        'Email',
        url: 'mailto:customercare@aub.com.ph',
      ),
      SponsorContact(
        Icons.language,
        'aub.com.ph',
        'Visit',
        url: 'https://www.aub.com.ph/',
      ),
    ],
  ),
];
