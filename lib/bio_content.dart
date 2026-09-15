class BioNote {
  const BioNote(
    this.name,
    this.role,
    this.paragraphs, {
    this.isContinuation = false,
  });
  final bool isContinuation;
  final String name, role;
  final List<String> paragraphs;
}

// Source: docs/bios/source-2026-09-15.txt.
const bioNotes = [
  // Source: docs/bios/mayor-message-2026-09-15.txt.
  BioNote("HON. LUCILO R. BAYRON", "City Mayor\nPuerto Princesa", [
    "Warm greetings to all our tourism stakeholders, partners, industry leaders, communities, and guests gathered for the Puerto Princesa Tourism Summit.",
    "Tourism has always been one of the strongest pillars of Puerto Princesa. It has created livelihoods, encouraged investments, strengthened communities, and introduced the beauty of our city to the world. But tourism is constantly changing, and if we want Puerto Princesa to remain competitive, we must be willing to change with it.",
    "This Summit is more than a gathering. It is a meeting of minds, a sharing of responsibility, and a commitment to the future of our city. It gives us the opportunity to listen, to learn from one another, and to confront the challenges before us with one clear direction.",
    "Our goal is not simply to bring more visitors to Puerto Princesa. We want visitors to stay longer, experience more, return, and become ambassadors of our city. We want tourism to create meaningful opportunities for our people while protecting the forests, seas, culture, and communities that make Puerto Princesa truly distinct.",
    "As we move forward, we must continue to strengthen our established destinations while creating new experiences and opportunities. We must improve connectivity, infrastructure, services, marketing, and investments. We must embrace innovation while remaining faithful to our identity as a city that values environmental stewardship and sustainable development.",
    "But government cannot do this alone. The future of Puerto Princesa tourism will be built through partnership. It requires the commitment of our tourism enterprises, communities, barangays, national agencies, academe, investors, workers, and everyone who takes pride in welcoming people to our home.",
    "Today, I challenge all of us to look beyond where Puerto Princesa tourism is now and imagine where it can be in the years ahead. Let us be bold enough to innovate, responsible enough to protect what we have, and united enough to turn our plans into action.",
    "Puerto Princesa has everything it needs to move forward, our natural treasures, our culture, our strategic opportunities, and most importantly, our people.",
    "Together, let us build a tourism industry that is stronger, more inclusive, more competitive, and sustainable for generations to come.",
    "The future of Puerto Princesa tourism begins with the decisions we make today. Let us build that future together.",
  ]),
  BioNote("CARLOS M. LIBOSADA JR.", "Moderator\nTourism Summit", [
    "Carlos “Caloy” Libosada Jr. is one of the pioneering advocates for ecotourism and responsible tourism in the country. He started his career with the Department of Tourism in 1989 and served the agency as a Product Research and Development Officer for seven years.",
    "A graduate of Bachelor of Science in Tourism from University of the Philippines Diliman and Master of Science in Environmental Studies from Miriam College, he furthered his tourism and environmental advocacy by teaching Tourism Planning and Ecotourism at University of the Philippines Diliman’s Asian Institute of Tourism for 15 years.",
    "He has been involved in numerous tourism and ecotourism development plans in the Philippines and other Asian countries. These include the tourism component of the Mt. Hamiguitan dossier for its inclusion in the United Nations Educational, Scientific and Cultural Organization World Heritage List, the updating of the Tourism Management Plan for the Tubbataha Reefs Protected Area, and the formulation of the Occheauteal Beach Tourism Management Plan in Cambodia. His recent projects include the Camp John Hay Development and Management Plan, the updating of the Puerto Princesa City Tourism Master Plan, project preparation for Asian Development Bank’s WildINVEST program (Wildlife Conservation Through Enforcement, Livelihoods and Tourism), and a study on Payment for Ecosystem Services.",
    "Caloy has authored several books, including Ecotourism in the Philippines, Domestic Tourism, 26 Days Around the Philippines, and Introduction to Tourism. He also wrote publications commissioned by the Department of Tourism, including Birdwatching in the Philippines, Kayak Philippines, and Tourism Success Stories.",
  ]),
  BioNote(
    "ROBERTO P. ALABADO III",
    "Regional Director\nDepartment of Tourism, Mimaropa",
    [
      "Roberto P. Alabado III or “Robby” is a traveler and a passionate advocate of Philippine Culture and Biodiversity. He gained development perspectives through academic degrees in Bachelor of Science in Community Development and Master of Arts in Regional Development Planning from the University of the Philippines, and a Graduate Diploma in Regional Development Planning and Management from the Universitat Dortmund in Germany.",
      "His professional journey ranges from being part of the academe to working in different levels of our government. First steps of his career was in University of the Philippines Diliman and later University of the Philippines Mindanao then later he served the City Government of Davao City as its Acting City Planning and Development Coordinator. He became part of the Department of Tourism family in 2015, starting as Regional Director of Davao Region then as Director on Medical Travel and Wellness Tourism. In 2018 he was appointed as Assistant Secretary for Tourism Development Planning and in 2021 was appointed as Undersecretary for Tourism Regulation, Coordination, and Resource Generation. He was then with the Office of the Secretary and was appointed as a Bureau Director on Film Tourism and Sports Tourism. He was also tasked to supervise the Foreign Offices of the Department of Tourism and served as an Officer-in-Charge Regional Director of Department of Tourism, Mimaropa Region. This year, he was officially designated as a full-fledged Regional Director of the Regional Office.",
    ],
  ),
  BioNote(
    "GEORGE MICHAEL T. IÑIGO",
    "Hotel Manager\nBest Western Plus The Ivywall Hotel",
    [
      "With nine years of experience in the hospitality industry, he has built a career that spans culinary operations, hotel management, and hospitality leadership. He currently serves as Hotel Manager of Best Western Plus The Ivywall Hotel – Palawan.",
      "His professional journey began in 2017 with the Shangri-La Group as a Commis III Chef. He later joined Best Western Plus The Ivywall Resort – Panglao as a Commis I Chef before transitioning into management, serving as Management Trainee and Owner’s Representative in both Panglao and Palawan. In 2025, he took on the role of Hotel Manager at Best Western Plus The Ivywall Hotel – Palawan.",
      "He holds a Bachelor of Science in Hotel and Restaurant Management from Kalayaan College and has completed professional programs in Restaurant Concept and Entrepreneurship at the International School of Culinary Arts and Hotel Management, as well as the ServSafe Food Protection Manager Training Program and Certification at Enderun Colleges.",
      "Drawing from his experience across different areas of hospitality, he brings a hands-on and practical approach to hotel operations, service excellence, and leadership. At the Tourism Summit, he will share best practices in hotel operations, offering valuable insights based on his experience in the industry.",
    ],
  ),
  BioNote("ROY RODRIGUEZ", "Owner\nPalawan Butterfly Eco-Garden and Tribal Village", [
    "Roy Rodriguez is a Palawan-born entrepreneur and agritourism advocate committed to promoting sustainable agriculture, tourism, and community development.",
    "He is the owner of Palawan Butterfly Eco-Garden and Tribal Village and Rodriguez Integrated Farm, a Department of Agriculture–Agricultural Training Institute Certified Learning Site for Agriculture and a Technical Education and Skills Development Authority-accredited Farm School.",
    "Through his advocacy, he conducts agricultural scholarship and training programs across Palawan, providing opportunities for communities to develop skills and livelihoods in agriculture.",
    "He also pioneered the “Pick and Eat All You Can” fruit experience, now on its fourth year, featuring rambutan and other locally grown fruits. The initiative has grown into a recognized agritourism destination, showcasing Palawan’s agricultural potential and creating meaningful farm-to-tourism experiences",
  ]),
  BioNote("SENITH O. ARAEZ", "Owner\nWhistler Travel and Tours", [
    "Senith O. Araez is a tourism entrepreneur, women’s empowerment advocate, and global connector, serving as the General Manager and Owner of Whistler Travel and Tours, a Department of Tourism-accredited travel agency based in Puerto Princesa City, Palawan. Her work combines destination promotion, meaningful travel experiences, community participation, and international tourism engagement.",
    "She champions responsible and inclusive tourism while creating opportunities for women and local entrepreneurs. Through national and international platforms, she continues to promote Puerto Princesa and Palawan, bringing global perspectives home while keeping local communities at the heart of tourism development.",
    "Among her notable achievements are being a Philippine Fully Hosted Buyer at ITB India and the 6th Himalayan Travel Mart in 2026, being featured by Junior Chamber International and the World Trade Organization, receiving the Puerto Princesa City Mayor’s Award for Tourism Promotion in 2025, and becoming an International Visitor Leadership Program alumna of the United States Department of State. She also served as Project Lead of the Academy for Women Entrepreneurs Puerto Princesa, received United States Government recognition for her contributions to Academy for Women Entrepreneurs Philippines, and was a Puerto Princesa City Gawad Turismo Awardee in 2023 and 2024.",
  ]),
  BioNote("BRYAN JOHN S. DIZON", "President\nCity Tourism Council", [
    "Bryan John Dizon is a tourism, agriculture, and community development advocate with over 20 years of leadership experience across the corporate, government, and private sectors.",
    "He currently serves as President of the Association of Accredited Tourist Accommodations of Puerto Princesa Palawan, Incorporated, Board Director of the Puerto Princesa Chamber of Commerce and Industries, and President of the Puerto Princesa City Tourism Council for 2026–2028. He is also the Farm School Director of Javenri Harvest Farm, a Department of Tourism-accredited Farm Tourism Site, Technical Education and Skills Development Authority Farm School, and Department of Agriculture–Agricultural Training Institute Learning Site for Agriculture, and General Manager of Ala Amid Bed & Breakfast, a Mabuhay-accredited accommodation in Puerto Princesa since 2016.",
    "His advocacies focus on Sports Tourism, Farm Tourism, and Values-Based Service Excellence, promoting initiatives that create sustainable economic opportunities while strengthening local communities. He has worked closely with government agencies, tourism stakeholders, educational institutions, farmers, and community organizations to advance responsible tourism, environmental stewardship, workforce development, food security, and inclusive growth.",
    "A certified trainer, assessor, and development practitioner with regional and national-level experience, Bryan has led capability-building programs across the Philippines, helping organizations and communities enhance service quality, leadership, sustainability, and resilience. He is also a recognized trainer for the Department of Tourism’s Filipino Brand of Service Excellence, promoting a culture of service rooted in Filipino values, hospitality, and community pride.",
    "Drawing from his experience in tourism, agriculture, business, and community engagement, Bryan advocates for collaborative approaches that build resilient destinations, sustainable livelihoods, and stronger local economies.",
  ]),
  BioNote(
    "LEONORA C. ESCOLLANTE",
    "President\nPhilippine Paddling Federation Incorporated",
    [
      "Leonora C. Escollante is the President of the Philippine Paddling Federation, an Executive Board Member of the Philippine Olympic Committee, and the Chairperson of the Philippine Olympic Committee on Gender Equality — a role through which she champions inclusivity, empowerment, and equal opportunity in sports.",
      "A retired officer of the Philippine Navy, she brings discipline, integrity, and service to every endeavor she leads. She is also an International Coach and International Technical Official. Her remarkable career includes serving as Event Organizer for the 2024 International Canoe Federation World Dragon Boat Championships, an international event that earned multiple Sports Tourism Awards for excellence, organization, and impact for Puerto Princesa City.",
      "Under her leadership, the Philippine Paddling Federation continues to elevate the country’s reputation as a global hub for paddling and sports development — inspiring athletes, communities, and tourism partners alike.",
      "Today, she joins us to share her insights on how sports and tourism can work hand in hand to empower local communities, promote sustainability, and celebrate Filipino excellence on the world stage.",
      "Please welcome — President Leonora C. Escollante, a true advocate of sports, equality, and nation‑building.",
    ],
  ),
  BioNote(
    "ANNA ORAIZA T. ABAN",
    "Marketing Manager\nIsrael Ministry of Tourism, Philippines and Singapore",
    [
      "Anna Oraiza T. Aban is the Marketing Manager for the Israel Ministry of Tourism, overseeing markets in the Philippines and Singapore. Born and raised in Puerto Princesa, Palawan, she is the youngest daughter of the late Connie Aban and Jose Aban and brings a deep understanding of destination marketing shaped by her own roots in one of the Philippines' most celebrated tourist destinations.",
      "Anna Oraiza holds a bachelor’s degree in advertising from the University of Santo Tomas and is currently pursuing her master’s degree in marketing communications at the same university, furthering her expertise in strategic brand communication.",
      "She has been part of the Israel Ministry of Tourism since 2017, joining at the founding of the Israel Government Tourist Office in the Philippines. Since then, she has grown into her current role as Marketing Manager, leading marketing efforts across both the Philippine and Singapore markets. In December 2025, she was entrusted with pioneering the Ministry's market presence in Singapore, expanding her leadership beyond the Philippines.",
      "In this capacity, Anna develops and executes marketing initiatives, strategic partnerships, and tourism development programs aimed at positioning Israel as a world-class travel destination for audiences in Southeast Asia. Her work bridges cultural storytelling with modern marketing strategy, strengthening Israel's presence and appeal in these key markets.",
      "Her contributions to the industry have been widely recognized. In May 2026, she was honored as National Tourism Office Ambassador by the Global Tourism Business Association, and in 2024, she received the Icon of the Year for Tourism award accolades that reflect her sustained impact and leadership in the tourism marketing field.",
    ],
  ),
  BioNote(
    "ENGR. JOVENEE C. SAGUN",
    "City Planning and Development Officer\nPuerto Princesa",
    [
      "Engr. Jovenee C. Sagun, Environmental Planner, a seasoned professional with over three decades of experience in urban planning and development. Graduated with a Bachelor's Degree in Civil Engineering from Holy Trinity University (1989) and took a post graduate course at the University of the Philippines School of Urban and Regional Planning (2000).",
      "Since 1990, She has dedicated her career to the City Government of Puerto Princesa. She has served as the City Planning and Development Coordinator since 2005 leading initiatives that drive inclusive economic growth, vibrant cultural preservation, and sustainable development.",
      "Her dynamic leadership and technical expertise have been instrumental in shaping Puerto Princesa City's long-term urban planning strategies, ensuring balanced progress and environmental stewardship, while safeguarding its rich cultural heritage and community.",
    ],
  ),
  BioNote(
    "ATTY. CHRISTINE N. LONGNO",
    "Park Superintendent\nPuerto Princesa Underground River",
    [
      "Atty. Christine N. Longno is a lawyer who has been in public service since 2016 and currently serves as the Assistant City Legal Officer of the City Government of Puerto Princesa. She has been a member of the Puerto Princesa Subterranean River National Park Protected Area Management Board since 2019 and was designated as Protected Area Superintendent of the Puerto Princesa Subterranean River National Park in November 2025.",
      "Atty. Longno has experience in policy development, legal affairs, and protected area governance, with work that has brought her to two United Nations Educational, Scientific and Cultural Organization World Heritage Sites in Palawan. Early in her career, she served as Legal Assistant at the Tubbataha Reefs Natural Park, where she gained valuable experience in conservation and protected area management. Her continued involvement with the Puerto Princesa Subterranean River National Park as a Protected Area Management Board member and, later, as its Protected Area Superintendent has further strengthened her appreciation of the connection between law, conservation, communities, and sustainable development.",
      "While she has no formal background in tourism, she considers herself a lifelong learner and sees this as an opportunity rather than a limitation. She approaches tourism with the same principle she brings to public service: learn continuously, listen to the people involved, and find ways to make things work without losing sight of the bigger purpose.",
      "For Atty. Longno, the challenge is not simply to make Puerto Princesa Subterranean River National Park a successful tourism destination, but to ensure that tourism becomes a means of appreciating, supporting, and ultimately protecting the park. After all, the best tourism story is one where the visitor enjoys the wonder, the community benefits from it, and nature remains protected for those who come after us.",
    ],
  ),
  BioNote(
    "EARL H. TIMBANCAYA",
    "City Disaster Risk Reduction and Management Officer\nPuerto Princesa",
    [
      "Earl H. Timbancaya is a Disaster Risk Reduction and Management practitioner with over 15 years of experience in the field. He currently serves as the Disaster Risk Reduction and Management Officer of the Puerto Princesa City Disaster Risk Reduction and Management Office. He contributed exceptional dedication to empowering communities with the knowledge and skills necessary to prepare and respond to emergencies and extreme situations accordingly.",
      "His achievements focus on disaster management relations on the local level. He has experience working with international organizations, government agencies, civil society organizations, and the private sector on issues intersecting disasters, climate change, and public policy. This work includes social/environmental impact assessment, science-based risk communication, community profiling and needs assessment, and provision of capacity-building activities to its stakeholders.",
      "He holds a Bachelor’s Degree in Biology and acquired training and development interventions related to his current work, also a fellow of Watsons Institute International & Public Affairs at Brown University.",
      "Timbancaya is also one of the members of the National Pool of CADRES on Incident Command System.",
      "For high-density planned gatherings, has served as a member of the Regional Incident Management Team in Two Association of Southeast Asian Nations meetings held in the City of Puerto Princesa and the Miss World Beauty Pageant 2018 held at El Nido, Palawan,to include international Sports events like the IronMan70.1 Triathlon, the International Dragonboat Race, International Youth Table Tennis championship and various national sports events that were held in Puerto Princesa City.",
      "He also served as Emergency Operations Center Manager of the Puerto Princesa City Disaster Risk Reduction and Management Council for the Response Operations of Super Typhoon Yolanda in 2013, Coronavirus Disease 2019 in 2020, Super Typhoon Odette in 2021 including 3 presidential visits.",
      "He recently represented the City Government of Puerto Princesa along with other Department Heads for a World Smart City Expo 2025, held at Busan Exhibition and Convention Center, South Korea.",
    ],
  ),
];
