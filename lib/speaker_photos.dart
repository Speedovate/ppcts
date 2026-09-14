import 'dart:ui';

class SpeakerPhoto {
  const SpeakerPhoto(this.asset, this.crop);
  final String asset;
  // Normalized source rectangle, framing the face and upper body.
  final Rect crop;
}

// Matched to the labeled slides in the shared PPC Tourism Summit 2026 deck.
const speakerPhotos = <String, SpeakerPhoto>{
  'LUCILO R. BAYRON': SpeakerPhoto(
    'lucilo_bayron.png',
    Rect.fromLTWH(.10, 0, .72, .706),
  ),
  'CARLOS M. LIBOSADA JR.': SpeakerPhoto(
    'carlos_libosada.png',
    Rect.fromLTWH(.04, 0, .85, .94),
  ),
  'ROBERTO P. ALABADO III': SpeakerPhoto(
    'roberto_alabado.png',
    Rect.fromLTWH(.28, 0, .65, .439),
  ),
  'ROY RODRIGUEZ': SpeakerPhoto(
    'roy_rodriguez.png',
    Rect.fromLTWH(.02, 0, .96, .91),
  ),
  'SENITH O. ARAEZ': SpeakerPhoto(
    'senith_araez.png',
    Rect.fromLTWH(.10, 0, .80, .759),
  ),
  'BRYAN JOHN S. DIZON': SpeakerPhoto(
    'bryan_dizon.png',
    Rect.fromLTWH(.20, .04, .65, .432),
  ),
  'MS. LEONORA C. ESCOLLANTE': SpeakerPhoto(
    'leonora_escollante.png',
    Rect.fromLTWH(.25, .12, .50, .333),
  ),
  'ANNA ORAIZA T. ABAN': SpeakerPhoto(
    'anna_aban.png',
    Rect.fromLTWH(.02, 0, .96, .962),
  ),
  'JOVENEE C. SAGUN': SpeakerPhoto(
    'jovenee_sagun.png',
    Rect.fromLTWH(.075, .02, .85, .567),
  ),
  'CHRISTINE LONGNO': SpeakerPhoto(
    'christine_longno.png',
    Rect.fromLTWH(.08, 0, .84, .776),
  ),
  'EARL H. TIMBANCAYA': SpeakerPhoto(
    'earl_timbancaya.png',
    Rect.fromLTWH(.18, .06, .64, .513),
  ),
};
