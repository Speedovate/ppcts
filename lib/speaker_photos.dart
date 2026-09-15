import 'dart:ui';

class SpeakerPhoto {
  const SpeakerPhoto(this.asset, this.crop);
  final String asset;
  // Normalized source rectangle, framing the face and upper body.
  final Rect crop;
}

// Matched to the labeled slides in the shared PPC Tourism Summit 2026 deck.
const speakerPhotos = <String, SpeakerPhoto>{
  'HON. LUCILO R. BAYRON': SpeakerPhoto(
    'lucilo_bayron.png',
    Rect.fromLTWH(.095, 0, .66, .647),
  ),
  'DEMETRIO “TOTO” C. ALVIOR JR.': SpeakerPhoto(
    'demetrio_alvior.png',
    Rect.fromLTWH(.16, .065, .68, .637),
  ),
  'CARLOS M. LIBOSADA JR.': SpeakerPhoto(
    'carlos_libosada.png',
    Rect.fromLTWH(.015, .06, .70, .775),
  ),
  'ROBERTO P. ALABADO III': SpeakerPhoto(
    'roberto_alabado.png',
    Rect.fromLTWH(.27, .035, .73, .493),
  ),
  'GEORGE MICHAEL T. IÑIGO': SpeakerPhoto(
    'george_inigo.png',
    Rect.fromLTWH(.08, .025, .84, .540),
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
    Rect.fromLTWH(.20, .04, .65, .432),
  ),
  'LEONORA C. ESCOLLANTE': SpeakerPhoto(
    'leonora_escollante.png',
    Rect.fromLTWH(.19, .085, .61, .596),
  ),
  'ANNA ORAIZA T. ABAN': SpeakerPhoto(
    'anna_aban.png',
    Rect.fromLTWH(.02, 0, .96, .962),
  ),
  'ENGR. JOVENEE C. SAGUN': SpeakerPhoto(
    'jovenee_sagun.png',
    Rect.fromLTWH(.105, .02, .85, .567),
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
