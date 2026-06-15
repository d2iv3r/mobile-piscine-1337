import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/diary_entry.dart';
import '../services/auth_service.dart';
import '../services/diary_service.dart';
import 'entry_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();
    final diaryService = DiaryService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<DiaryEntry>>(
          stream: diaryService.watchEntries(),
          builder: (context, snapshot) {
            final entries = snapshot.data ?? [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF2E7D52),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person, color: Color(0xFF2E7D52), size: 30)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Welcome',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        tooltip: 'Logout',
                        onPressed: () async {
                          await authService.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82))),
                  )
                else ...[
                  const SizedBox(height: 16),

                  _SectionCard(
                    title: 'Your last diary entries',
                    headerColor: const Color(0xFF4CAF82),
                    child: entries.isEmpty
                        ? _emptyState('No entries yet')
                        : Column(
                            children: entries.take(2).map((e) => _EntryRow(entry: e)).toList(),
                          ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: 'Total entries',
                    headerColor: const Color(0xFF66BB6A),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          '${entries.length}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: entries.isEmpty
                        ? 'Your feelings'
                        : 'Your feel for your ${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                    headerColor: const Color(0xFFA5D6A7),
                    child: entries.isEmpty
                        ? _emptyState('No data yet')
                        : _FeelingsBreakdown(entries: entries),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EntryScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text(
                          'New diary entry',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF82),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}


class _SectionCard extends StatelessWidget {
  final String title;
  final Color headerColor;
  final Widget child;

  const _SectionCard({required this.title, required this.headerColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: headerColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: headerColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final DiaryEntry entry;

  const _EntryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final feeling = Feeling.fromKey(entry.feeling);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EntryScreen(entry: entry)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8F0EB)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(entry.date),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
                  ),
                  Text(
                    DateFormat('MMM').format(entry.date),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(feeling.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Container(width: 1, height: 28, color: const Color(0xFFE0E0E0)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                entry.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FeelingsBreakdown extends StatelessWidget {
  final List<DiaryEntry> entries;

  const _FeelingsBreakdown({required this.entries});

  @override
  Widget build(BuildContext context) {
    final total = entries.length;
    final counts = <String, int>{};
    for (final e in entries) {
      counts[e.feeling] = (counts[e.feeling] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: Feeling.all.map((feeling) {
          final count = counts[feeling.key] ?? 0;
          final percent = total == 0 ? 0.0 : count / total;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(feeling.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 42,
                  child: Text(
                    '${(percent * 100).round()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFEFF5F1),
                      valueColor: AlwaysStoppedAnimation<Color>(_colorFor(feeling.key)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  feeling.label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _colorFor(String key) {
    switch (key) {
      case 'happy':
        return const Color(0xFF42A5F5);
      case 'satisfied':
        return const Color(0xFF66BB6A);
      case 'neutral':
        return const Color(0xFFFFCA28);
      case 'sad':
        return const Color(0xFFEF5350);
      case 'angry':
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }
}