import 'dart:ui';

class SpeakerPhoto {
  const SpeakerPhoto(this.asset, this.crop);
  final String asset;
  // Normalized square source rectangle centered on the head.
  // Negative offsets preserve headroom when the source ends at the hairline.
  final Rect crop;
}

// Matched to the labeled slides in the shared PPC Tourism Summit 2026 deck.
const speakerPhotos = <String, SpeakerPhoto>{
  'ERIC JOHN YAYEN': SpeakerPhoto(
    'eric_yayen.png',
    Rect.fromLTWH(.093, -.044, .58, .468),
  ),
  'ATTY. HERBERT S. DILIG': SpeakerPhoto(
    'herbert_dilig.png',
    Rect.fromLTWH(.122, -.05, .64, .64),
  ),
  'HON. LUCILO R. BAYRON': SpeakerPhoto(
    'lucilo_bayron.png',
    Rect.fromLTWH(.111, -.061, .66, .647),
  ),
  'DEMETRIO “TOTO” C. ALVIOR JR.': SpeakerPhoto(
    'demetrio_alvior.png',
    Rect.fromLTWH(.136, .076, .68, .637),
  ),
  'CARLOS M. LIBOSADA JR.': SpeakerPhoto(
    'carlos_libosada.png',
    Rect.fromLTWH(-.043, -.041, .82, .908),
  ),
  'ROBERTO P. ALABADO III': SpeakerPhoto(
    'roberto_alabado.png',
    Rect.fromLTWH(.244, -.003, .73, .493),
  ),
  'GEORGE MICHAEL T. IÑIGO': SpeakerPhoto(
    'george_inigo.png',
    Rect.fromLTWH(.100, .044, .84, .540),
  ),
  'ROY RODRIGUEZ': SpeakerPhoto(
    'roy_rodriguez.png',
    Rect.fromLTWH(.012, .07, .94, .890),
  ),
  'SENITH O. ARAEZ': SpeakerPhoto(
    'senith_araez.png',
    Rect.fromLTWH(.10, 0, .80, .759),
  ),
  'BRYAN JOHN S. DIZON': SpeakerPhoto(
    'bryan_dizon.png',
    Rect.fromLTWH(.211, .025, .65, .432),
  ),
  'LEONORA C. ESCOLLANTE': SpeakerPhoto(
    'leonora_escollante.png',
    Rect.fromLTWH(.183, .046, .61, .596),
  ),
  'ANNA ORAIZA T. ABAN': SpeakerPhoto(
    'anna_aban.png',
    // Keep the photo's cut-off bottom outside the visible circle.
    Rect.fromLTWH(-.006, .02, .96, .962),
  ),
  'ENGR. JOVENEE C. SAGUN': SpeakerPhoto(
    'jovenee_sagun.png',
    Rect.fromLTWH(.115, -.01, .85, .567),
  ),
  'ATTY. CHRISTINE N. LONGNO': SpeakerPhoto(
    'christine_longno.png',
    Rect.fromLTWH(.08, 0, .84, .776),
  ),
  'EARL H. TIMBANCAYA': SpeakerPhoto(
    'earl_timbancaya.png',
    Rect.fromLTWH(.207, .145, .64, .513),
  ),
};
