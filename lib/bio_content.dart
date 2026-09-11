class BioNote {
  const BioNote(this.name, this.role, this.paragraphs);
  final String name, role;
  final List<String> paragraphs;
}

const bioNotes = [
  BioNote('CARLOS M. LIBOSADA JR.', 'Moderator', [
    'Carlos “Caloy” Libosada Jr. is one of the pioneering advocates for ecotourism and responsible tourism in the country. He started his career with the Department of Tourism in 1989 and served the agency as a Product Research and Development Officer for seven years.',
    'A graduate of B.S. Tourism from UP Diliman and M.S. Environmental Studies from Miriam College, he furthered his tourism and environmental advocacy by teaching Tourism Planning and Ecotourism at UP Diliman’s Asian Institute of Tourism for 15 years.',
    'He has been involved in numerous tourism and ecotourism development plans in the Philippines and other Asian countries. These include the tourism component of the Mt. Hamiguitan dossier for its inclusion in the UNESCO World Heritage List, the updating of the Tourism Management Plan for the Tubbataha Reefs Protected Area, and the formulation of the Occheauteal Beach Tourism Management Plan in Cambodia. His recent projects include the Camp John Hay Development and Management Plan, the updating of the Puerto Princesa City Tourism Master Plan, project preparation for ADB’s WildINVEST program (Wildlife Conservation Through Enforcement, Livelihoods and Tourism), and a study on Payment for Ecosystem Services (PES).',
    'Caloy has authored several books, including Ecotourism in the Philippines, Domestic Tourism, 26 Days Around the Philippines, and Introduction to Tourism. He also wrote publications commissioned by the Department of Tourism, including Birdwatching in the Philippines, Kayak Philippines, and Tourism Success Stories.',
  ]),
  BioNote('ANNA ORAIZA T. ABAN', 'Destination Marketing and Digital Tourism', [
    'Anna Oraiza T. Aban is the Marketing Manager of the Israel Ministry of Tourism, Philippines and Singapore. Born in Puerto Princesa City, Palawan, Philippines, she holds a bachelor’s degree with a major in Advertising from the University of Santo Tomas.',
    'She has been part of the Israel Ministry of Tourism since 2017, following the opening of the Israel Government Tourist Office in the Philippines.',
    'As Marketing Manager of the Israel Government Tourist Office in the Philippines and Singapore, Anna is responsible for the Philippine and Singapore markets, focusing on marketing initiatives, strategies, and tourism development to position Israel as a world class travel destination.',
  ]),
];
