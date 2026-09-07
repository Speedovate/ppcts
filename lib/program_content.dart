class ProgramEntry {
  const ProgramEntry(this.time, this.title, this.speaker, this.details);
  final String time, title, speaker, details;
}

class ProgramPage {
  const ProgramPage(this.title, this.entries);
  final String title;
  final List<ProgramEntry> entries;
}

// Previously missing times from 09:40 AM onward are sample times for preview.
const programPages = <ProgramPage>[
  ProgramPage("Arrival & opening", [
    ProgramEntry(
      "8:00 - 9:00 AM · 60 mins",
      "REGISTRATION OF PARTICIPANTS",
      "Secretariat/Registration Team",
      "Arrival, attendance confirmation, welcome coffee, networking and tourism AVPs.",
    ),
    ProgramEntry(
      "9:00 · 3 mins",
      "CALL TO ORDER",
      "Host: Ms. Rita Sarmiento (Tentative)",
      "Welcome and official opening.",
    ),
    ProgramEntry("9:03 · 5 mins", "INVOCATION", "City Choir", ""),
    ProgramEntry(
      "9:08 · 5 mins",
      "PHILIPPINE NATIONAL ANTHEM",
      "City Choir",
      "",
    ),
    ProgramEntry(
      "9:13 · 5 mins",
      "ACKNOWLEDGMENT OF GUESTS, OFFICIALS & PARTICIPANTS",
      "Host",
      "Recognition of officials, tourism stakeholders, partners and participating organizations.",
    ),
  ]),
  ProgramPage("Welcome & summit overview", [
    ProgramEntry(
      "9:21 · 8 mins",
      "WELCOME & OPENING REMARKS",
      "Speaker: Mayor Lucilo R. Bayron",
      "Tourism priorities, summit vision and active stakeholder participation.",
    ),
    ProgramEntry(
      "9:26 · 5 mins",
      "TOURISM SUMMIT OVERVIEW",
      "Host",
      "Theme, objectives, expected outputs, two-day program and participation guidelines. Questions may be submitted by QR code or in writing.",
    ),
    ProgramEntry(
      "9:31 · 5 mins",
      "PUERTO PRINCESA TOURISM OPENING PRODUCTION",
      "AV Team \nBanwa Dance Troupe",
      "Live cultural performance and tourism AVP featuring local attractions, products, people and experiences.",
    ),
  ]),
  ProgramPage("The state of tourism", [
    ProgramEntry(
      "09:40 AM",
      "PLENARY SESSION 1: THE STATE OF PHILIPPINE TOURISM",
      "Host",
      "Tourism performance, recovery, challenges and the private-sector perspective.",
    ),
    ProgramEntry(
      "09:45 AM",
      "National Tourism Landscape: Where Philippine Tourism Stands Today",
      "Speaker: DOT Sec",
      "• Current state of Philippine tourism\n• Tourism performance and recovery\n• Current tourism trends\n• Key challenges and opportunities\n• National tourism priorities\n• Implications for tourism destinations",
    ),
    ProgramEntry(
      "10:00 AM",
      "The Current State of Tourism in Puerto Princesa",
      "Speaker: Mr. Demetrio “Toto” Alvior",
      "• Tourism recovery status\n• Visitor trends and tourism performance\n• Current tourism landscape\n• Flagship tourism products\n• Key issues affecting tourism growth",
    ),
    ProgramEntry(
      "10:15 AM",
      "Private Sector Perspective: Tourism Industry Outlook & Current Challenges",
      "Speaker: Mr. Bryan John Dizon\nPresident, City Tourism Council",
      "• Industry experience and assessment\n• Current business environment\n• Key challenges faced by tourism establishments\n• Opportunities for industry growth\n• Priority concerns of tourism stakeholders",
    ),
  ]),
  ProgramPage("Dialogue & best practices", [
    ProgramEntry(
      "10:30 AM",
      "CONSOLIDATED PANEL DISCUSSION – SESSION 1",
      "Moderator: Mr. Caloy Libosada \nPanelists: \n• DOT Sec \n• Mr. Demetrio \"Toto\" Alvior, City Tourism Officer\n• Mr. Bryan John Dizon, President, City Tourism Council",
      "Moderator-framed discussion, cross-sector exchange and closing reflection. Connect • Collaborate • Adapt • Act.",
    ),
    ProgramEntry(
      "10:50 AM",
      "DISTRIBUTION OF TOKENS OF APPRECIATION",
      "Host/Organizing Committee (CTO & CTC)",
      "Recognition, presentation of tokens and photo opportunity.",
    ),
    ProgramEntry(
      "11:00 AM",
      "ICE BREAKER / BREATHER / HEALTH BREAK/ AM SNACKS",
      "",
      "",
    ),
    ProgramEntry(
      "11:15 AM",
      "PLENARY SESSION 2: BEST PRACTICES IN TOURISM",
      "Host",
      "Five-minute sharing of tourism initiatives, business practices, community engagement and destination experiences.",
    ),
    ProgramEntry(
      "11:20 AM",
      "Best Practice Sharing in Accommodation",
      "Astoria Palawan Representative",
      "• Tourism and hospitality practices\n• Lessons that may apply to Puerto Princesa",
    ),
  ]),
  ProgramPage("Industry insights & exchange", [
    ProgramEntry(
      "11:30 AM",
      "Best Practice Sharing in Tourist Destinations",
      "Mr. Roy Rodriguez – Butterfly Garden",
      "• Visitor experience and tourism attraction management\n• Community/destination engagement",
    ),
    ProgramEntry(
      "11:40 AM",
      "Best Practice Sharing in Restaurants",
      "Mr. Eric Yayen – Ka Inato",
      "• Local tourism enterprise practices\n• Product and service development",
    ),
    ProgramEntry(
      "11:50 AM",
      "Best Practice Sharing among Tour Operators",
      "Ms. Senith Arnaez – Tour Operator",
      "• Tour operations and destination experiences\n• Industry collaboration",
    ),
    ProgramEntry("12:00 PM", "LUNCH BREAK", "", ""),
    ProgramEntry(
      "01:00 PM",
      "CONSOLIDATED PANEL DISCUSSION AND PARTICIPANTS’ Q&A: SESSION 2",
      "Moderator: Sir Caloy\n• Astoria Palawan Representative\n• Mr. Roy Rodriguez\n• Mr. Eric Yayen\n• Ms. Senith Arnaez",
      "Panel discussion and participant questions on Session 2, submitted by QR code or in writing.",
    ),
    ProgramEntry(
      "01:25 PM",
      "DISTRIBUTION OF TOKENS OF APPRECIATION",
      "Host/Organizing Committee (CTO & CTC)",
      "Recognition, presentation of tokens and photo opportunity.",
    ),
    ProgramEntry("01:30 PM", "BREATHER/ ICE BREAKER/ AVP", "", "VENUE RESET"),
  ]),
  ProgramPage("Partnerships & opportunities", [
    ProgramEntry(
      "01:40 PM",
      "PLENARY SESSION 3: STRENGTHENING TOURISM PARTNERSHIPS",
      "Kadiwa Representative",
      "Private Sector–Kadiwa Partnership for Tourism Development: local products, enterprise and community opportunities, public-private collaboration and coordination.",
    ),
    ProgramEntry(
      "02:00 PM",
      "PLENARY SESSION 4: EMERGING TOURISM OPPORTUNITIES IN PUERTO PRINCESA",
      "Host",
      "Diversifying local tourism through community-based tourism, MICE, Halal tourism and sports tourism.",
    ),
    ProgramEntry(
      "02:05 PM",
      "Community-Based Sustainable Tourism (CBST)",
      "Speaker: Ms. Teresita Austria",
      "• Community participation\n• Sustainable livelihood opportunities\n• Community-based tourism products",
    ),
    ProgramEntry(
      "02:20 PM",
      "MICE Tourism Development",
      "MICE Tourism Representative – TBA",
      "• MICE market opportunities\n• Destination readiness\n• Opportunities for local tourism businesses",
    ),
    ProgramEntry(
      "02:35 PM",
      "Halal Tourism Opportunities",
      "Shroff Travel Representative (Tentative)",
      "• Inclusive tourism development\n• Market opportunities\n• Industry readiness",
    ),
  ]),
  ProgramPage("Sports, marketing & dialogue", [
    ProgramEntry(
      "02:50 PM",
      "Sports Tourism Development",
      "Swim League Philippines Representative",
      "• Sports events\n• Destination activation\n• Tourism opportunities",
    ),
    ProgramEntry("03:05 PM", "ICE BREAKER", "", ""),
    ProgramEntry(
      "03:10 PM",
      "PLENARY SESSION 5: DESTINATION MARKETING & DIGITAL TOURISM",
      "Speaker: Ms. Sally Lebante (TBD)",
      "• Current destination marketing initiatives\n• Digital platforms and tourism promotion\n• Social media and digital engagement\n• Strengthening Puerto Princesa’s destination branding\n• Opportunities for collaborative marketing",
    ),
    ProgramEntry(
      "03:30 PM",
      "CONSOLIDATED PANEL DISCUSSIONS AND Q&A – AFTERNOON SESSIONS",
      "Moderator: Sir Caloy\nSpeakers:\n• Kadiwa Representative\n• Tess Austria\n• MICE Tourism Representative\n• Shroff Travel Representative\n• Swim League Philippines Representative\n• Ms. Sally Lebante",
      "Moderator-led discussion linking partnerships, emerging opportunities and destination marketing. Participant questions, reactions and recommendations via QR code or written submissions; key takeaways and areas for action.",
    ),
  ]),
  ProgramPage("Synthesis & next steps", [
    ProgramEntry(
      "03:45 PM",
      "Afternoon Tea: Served during the Stakeholders’ Dialogue",
      "",
      "",
    ),
    ProgramEntry(
      "04:00 PM",
      "DISTRIBUTION OF TOKENS OF APPRECIATION",
      "Host/Organizing Committee",
      "Recognition of afternoon speakers, presentation of tokens and photo opportunity.",
    ),
    ProgramEntry(
      "04:10 PM",
      "HEALTH BREAK/ ICE BREAKER/ AVP",
      "",
      "Health break, ice breaker and AVP before the Day 1 synthesis.",
    ),
    ProgramEntry(
      "04:20 PM",
      "DAY 1 SYNTHESIS: WHAT WE HEARD & WHAT NEEDS TO CHANGE",
      "Moderator: Sir Caloy",
      "• Major tourism issues identified\n• Current challenges\n• Emerging tourism opportunities\n• Partnership and collaboration opportunities\n• Key recommendations\n• Priority areas to carry forward to Day 2",
    ),
    ProgramEntry(
      "04:45 PM",
      "DAY 1 CLOSING & PREVIEW OF DAY 2",
      "Host/Organizing Committee",
      "• Key takeaways from Day 1\n• Brief closing message\n• Preview of Day 2\n• Reminder on stakeholder participation",
    ),
    ProgramEntry("05:00 PM", "END OF DAY 1", "", ""),
  ]),
];
