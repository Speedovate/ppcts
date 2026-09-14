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
    this.videoUrl,
    this.slogan = '“Your slogan goes here”',
    this.contacts = const [
      SponsorContact(Icons.call_outlined, '+63 XXX XXX XXXX', 'Call'),
      SponsorContact(Icons.email_outlined, 'email@example.com', 'Email'),
      SponsorContact(Icons.language, 'www.example.com', 'Visit'),
    ],
  });
  final String name;
  final String logoAsset;
  final String heading;
  final String? videoUrl;
  Rect get playButtonBounds =>
      Rect.fromLTWH(233, contactBounds.bottom + 16, 44, 44);
  static const expandedLogoSize = 120.0;
  Rect get expandedLogoBounds {
    double height(String text, double size, FontWeight weight) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: size,
            fontWeight: weight,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 420);
      final result = painter.height;
      painter.dispose();
      return result;
    }

    final nameBottom =
        164 +
        height(heading, 14, FontWeight.normal) +
        height(name.toUpperCase(), 20, FontWeight.bold);
    return Rect.fromLTWH(
      (510 - expandedLogoSize) / 2,
      nameBottom + (164 - 135),
      expandedLogoSize,
      expandedLogoSize,
    );
  }

  double get sloganTop => expandedLogoBounds.bottom + 29;

  Rect get contactBounds {
    var textWidth = 0.0;
    for (final contact in contacts) {
      final painter = TextPainter(
        text: TextSpan(
          text: contact.value,
          style: const TextStyle(fontSize: 14, fontFamily: 'sans-serif'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (painter.width > textWidth) textWidth = painter.width;
      painter.dispose();
    }
    final width = 20 + 16 + textWidth;
    final sloganPainter = TextPainter(
      text: TextSpan(
        text: slogan,
        style: const TextStyle(fontSize: 14, fontFamily: 'sans-serif'),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 420);
    final belowSlogan = sloganTop + sloganPainter.height + 16;
    final sloganLeft = (510 - sloganPainter.width) / 2;
    sloganPainter.dispose();
    return Rect.fromLTWH(sloganLeft, belowSlogan, width, contacts.length * 38);
  }

  final String slogan;
  final List<SponsorContact> contacts;
}

const sponsors = [
  SponsorInfo(
    'SPEEDOVATE ICT SOLUTIONS',
    logoAsset: 'speedovate.jpg',
    heading: 'POWERED BY',
    videoUrl: 'https://www.facebook.com/share/v/1DiLDeMJTG/',
    slogan: '“We Help Leaders Build And Digitalize Their Systems”',
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
        'www.speedovate.com',
        'Visit',
        url: 'https://www.speedovate.com',
      ),
    ],
  ),
  SponsorInfo(
    'Four Points by Sheraton',
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
        'www.fourpointspalawan.com',
        'Visit',
        url: 'https://www.fourpointspalawan.com',
      ),
    ],
  ),
  SponsorInfo(
    'Casa Germana Boutique Hotel',
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
    'Asia United Bank',
    logoAsset: 'asia_united_bank.png',
    videoUrl: 'https://www.facebook.com/share/v/198jPDU5EG/',
    // Excerpt from the bank's published mission, not an invented tagline.
    slogan:
        '“developing long-term partnerships with clients through the delivery of responsive, innovative, and value-added products and services”',
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
        'www.aub.com.ph',
        'Visit',
        url: 'https://www.aub.com.ph/',
      ),
    ],
  ),
];
