import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import 'entry_screen.dart';

/// Exercise 01: Agenda Page
///
/// - Displays a calendar (current date selected by default).
/// - Selecting a date shows a scrollable list of entries from that date.
/// - Tapping an entry opens it (view/delete).
/// - The list updates live via Firestore snapshots.
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final DiaryService _diaryService = DiaryService();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D52),
        foregroundColor: Colors.white,
        title: const Text('Agenda', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<DiaryEntry>>(
        stream: _diaryService.watchEntries(),
        builder: (context, snapshot) {
          final allEntries = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          // Days that have at least one entry (used to mark the calendar).
          final entryDays = allEntries.map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet();

          // Entries for the currently selected day.
          final dayEntries = allEntries.where((e) => _isSameDay(e.date, _selectedDay)).toList();

          return CustomScrollView(
            slivers: [
              // ── Calendar ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => _isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: (day) {
                      final normalized = DateTime(day.year, day.month, day.day);
                      return entryDays.contains(normalized) ? [normalized] : [];
                    },
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    rowHeight: 40,
                    daysOfWeekHeight: 20,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF4CAF82).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF2E7D52),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFFEF5350),
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      outsideDaysVisible: false,
                    ),
                  ),
                ),
              ),

              // ── Selected day label ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.event_note_rounded, size: 18, color: Color(0xFF4CAF82)),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(_selectedDay),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Entries for selected day ────────────────────────────
              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82))),
                )
              else if (dayEntries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy_rounded, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No entries for this day',
                          style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _AgendaEntryTile(entry: dayEntries[index]),
                      childCount: dayEntries.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Agenda entry tile ───────────────────────────────────────────────────────

class _AgendaEntryTile extends StatelessWidget {
  final DiaryEntry entry;

  const _AgendaEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final feeling = Feeling.fromKey(entry.feeling);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8F0EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EC),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(feeling.emoji, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1A1A2E)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            entry.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EntryScreen(entry: entry)),
          );
        },
        ),
      ),
    );
  }
}