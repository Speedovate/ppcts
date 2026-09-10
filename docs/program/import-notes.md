# September 11 program update

The verbatim supplied program is preserved in `summit-2026-source.txt`.
`lib/program_content.dart` contains 33 Day 1 entries and 31 Day 2 entries.

- Keep the existing start-time-only, title, representative layout. Panel discussion outlines are retained in the `details` data field, which the existing layout does not display.
- Best-practice sharing and moderator synthesis have no individual times in the source; they share the showcase's 11:02 AM start. Sports Development Tourism shares its parent session's 02:32 PM start. These are session start times, not invented individual slots.
- Normalize Day 1's noon Tokens of Appreciation to 12:02 PM. The source says AM. Day 2's 02:02 time is PM based on its placement in the PM session.
- Keep supplied start times, including overlaps. Malformed or backwards end times are not displayed because the UI shows only start times.
- Preserve the source's Christine Longno / Christine Logno spelling difference and the Officer / Coordinator role difference for Jovenee Sagun; these require organizer confirmation rather than guessing.
- Missing representatives reserve a blank line without visible placeholder text.
- Start Day 2 on a new page and derive each program footer's day from its content. The two sponsor pages remain at the beginning.
