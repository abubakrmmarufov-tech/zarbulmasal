commit 34e0e71d2461edb187fbedcb937ac20480c88628
Author: ma'rufi <abubakrmmarufov@gmail.com>
Date:   Mon Sep 14 07:06:25 2026 +0800

    feat: improve mobile history and literature experience

diff --git a/lib/features/literature/presentation/oral_heritage_screen.dart b/lib/features/literature/presentation/oral_heritage_screen.dart
index 226e8b7..18733e9 100644
--- a/lib/features/literature/presentation/oral_heritage_screen.dart
+++ b/lib/features/literature/presentation/oral_heritage_screen.dart
@@ -1,12 +1,15 @@
 import 'package:flutter/material.dart';
 import 'package:flutter/services.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:go_router/go_router.dart';
 import '../../../core/design_system/design_system.dart';
 import '../../../core/l10n/app_translations.dart';
 import '../../../shared/providers/app_providers.dart';
 import '../../../shared/widgets/empty_state.dart';
 import '../data/literature_providers.dart';
 import '../domain/oral_heritage_entry.dart';
+import '../../history/data/history_providers.dart';
+import '../../history/domain/history_entry.dart';
 
 /// A screen displaying verified folklore and oral literary heritage
 /// of the Tajik people: proverbs, riddles, folk dubaytis, and folk rubais.
@@ -26,6 +29,11 @@ class _OralHeritageScreenState extends ConsumerState<OralHeritageScreen> {
     final isPersian = lang == DisplayLanguage.persian;
 
     final oralAsync = ref.watch(oralHeritageProvider);
+    final historyEntries =
+        ref.watch(historyEntriesProvider).valueOrNull ?? const <HistoryEntry>[];
+    final textbookOral = historyEntries
+        .where((entry) => entry.kind == HistoryEntryKind.oral)
+        .toList(growable: false);
 
     return Scaffold(
       body: SafeArea(
@@ -56,42 +64,43 @@ class _OralHeritageScreenState extends ConsumerState<OralHeritageScreen> {
                     : 'Зарбулмасалҳо, чистонҳо, дубайтиҳо ва фолклори сабтшудаи мардуми тоҷик',
               ),
             ),
-            // Genre Filter Chips
-            SliverToBoxAdapter(
-              child: SingleChildScrollView(
-                scrollDirection: Axis.horizontal,
-                padding: const EdgeInsets.symmetric(
-                  horizontal: 24,
-                  vertical: 8,
-                ),
-                child: Row(
-                  children: [
-                    ChoiceChip(
-                      label: Text(isPersian ? 'همه' : 'Ҳама'),
-                      selected: _selectedType == null,
-                      onSelected: (selected) {
-                        if (selected) setState(() => _selectedType = null);
-                      },
-                    ),
-                    const SizedBox(width: 8),
-                    for (final type in OralHeritageType.values) ...[
-                      if (type != OralHeritageType.other) ...[
-                        ChoiceChip(
-                          label: Text(_typeName(type, isPersian)),
-                          selected: _selectedType == type,
-                          onSelected: (selected) {
-                            setState(() {
-                              _selectedType = selected ? type : null;
-                            });
-                          },
-                        ),
-                        const SizedBox(width: 8),
-                      ],
+            // Filters are useful only once verified entries exist. The empty
+            // state below is intentionally a source guide, not a fake catalog.
+            if (oralAsync.valueOrNull?.isNotEmpty == true)
+              SliverToBoxAdapter(
+                child: SingleChildScrollView(
+                  scrollDirection: Axis.horizontal,
+                  padding: const EdgeInsets.symmetric(
+                    horizontal: 24,
+                    vertical: 8,
+                  ),
+                  child: Row(
+                    children: [
+                      ChoiceChip(
+                        label: Text(isPersian ? 'همه' : 'Ҳама'),
+                        selected: _selectedType == null,
+                        onSelected: (selected) {
+                          if (selected) setState(() => _selectedType = null);
+                        },
+                      ),
+                      const SizedBox(width: 8),
+                      for (final type in OralHeritageType.values)
+                        if (type != OralHeritageType.other) ...[
+                          ChoiceChip(
+                            label: Text(_typeName(type, isPersian)),
+                            selected: _selectedType == type,
+                            onSelected: (selected) {
+                              setState(() {
+                                _selectedType = selected ? type : null;
+                              });
+                            },
+                          ),
+                          const SizedBox(width: 8),
+                        ],
                     ],
-                  ],
+                  ),
                 ),
               ),
-            ),
             const SliverToBoxAdapter(child: SizedBox(height: 12)),
             // List of entries
             oralAsync.when(
@@ -123,19 +132,34 @@ class _OralHeritageScreenState extends ConsumerState<OralHeritageScreen> {
                     : entries.where((e) => e.type == _selectedType).toList();
 
                 if (filtered.isEmpty) {
-                  return SliverFillRemaining(
-                    hasScrollBody: false,
-                    child: Center(
-                      child: EmptyState(
-                        icon: Icons.record_voice_over_outlined,
-                        title: isPersian
-                            ? 'نمونه‌ای یافت نشد'
-                            : 'Намунае ёфт нашуд',
-                        subtitle: isPersian
-                            ? 'مدخل‌های ادبیات عامیانه در مرحلهٔ بررسی و مقابله با کتاب‌های فولکلور قرار دارند.'
-                            : 'Намунаҳои фолклор дар марҳилаи санҷиш ва муқобала бо маҷмӯаҳои чопӣ қарор доранд.',
+                  return SliverMainAxisGroup(
+                    slivers: [
+                      SliverToBoxAdapter(
+                        child: _OralLogicGuide(isPersian: isPersian),
                       ),
-                    ),
+                      if (textbookOral.isNotEmpty)
+                        SliverList.builder(
+                          itemCount: textbookOral.length,
+                          itemBuilder: (context, index) => _TextbookOralCard(
+                            entry: textbookOral[index],
+                            isPersian: isPersian,
+                          ),
+                        ),
+                      SliverToBoxAdapter(
+                        child: Padding(
+                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
+                          child: OutlinedButton.icon(
+                            onPressed: () => context.push('/history'),
+                            icon: const Icon(Icons.timeline_outlined),
+                            label: Text(
+                              isPersian
+                                  ? 'مشاهدهٔ تاریخ و ریشهٔ روایت‌ها'
+                                  : 'Дидани таърих ва решаи ривоятҳо',
+                            ),
+                          ),
+                        ),
+                      ),
+                    ],
                   );
                 }
 
@@ -174,6 +198,131 @@ class _OralHeritageScreenState extends ConsumerState<OralHeritageScreen> {
   }
 }
 
+class _OralLogicGuide extends StatelessWidget {
+  final bool isPersian;
+
+  const _OralLogicGuide({required this.isPersian});
+
+  @override
+  Widget build(BuildContext context) {
+    final colors = Theme.of(context).colorScheme;
+    return Container(
+      margin: const EdgeInsets.fromLTRB(24, 8, 24, 12),
+      padding: const EdgeInsets.all(18),
+      decoration: BoxDecoration(
+        color: colors.primary.withValues(alpha: 0.07),
+        borderRadius: BorderRadius.circular(14),
+        border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Text(
+            isPersian ? 'منطق میراث شفاهی' : 'МАНТИҚИ МЕРОСИ ШИФОҲӢ',
+            style: QalamTypography.eyebrow(color: colors.primary),
+          ),
+          const SizedBox(height: 8),
+          Text(
+            isPersian
+                ? 'هر روایت سه لایه دارد: متن، نوع روایت و منبع. فقط متنی که مقابله و اجازهٔ نشر دارد در فهرست کامل می‌آید.'
+                : 'Ҳар ривоят се қабат дорад: матн, навъи ривоят ва сарчашма. Танҳо матни муқобилашуда ва иҷозадор дар феҳристи пурра меояд.',
+            style: QalamTypography.bodySecondary(
+              color: colors.onSurfaceVariant,
+            ),
+          ),
+          const SizedBox(height: 14),
+          Wrap(
+            spacing: 8,
+            runSpacing: 8,
+            children: [
+              _GuidePill(
+                label: isPersian
+                    ? '۱  Ҷудокунии ривоят'
+                    : '01  Ҷудокунии ривоят',
+              ),
+              _GuidePill(
+                label: isPersian ? '۲  Санҷиши манбаъ' : '02  Санҷиши манбаъ',
+              ),
+              _GuidePill(
+                label: isPersian ? '۳  Намоиши равшан' : '03  Намоиши равшан',
+              ),
+            ],
+          ),
+        ],
+      ),
+    );
+  }
+}
+
+class _GuidePill extends StatelessWidget {
+  final String label;
+
+  const _GuidePill({required this.label});
+
+  @override
+  Widget build(BuildContext context) {
+    final colors = Theme.of(context).colorScheme;
+    return Container(
+      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
+      decoration: BoxDecoration(
+        color: colors.surface,
+        borderRadius: BorderRadius.circular(20),
+      ),
+      child: Text(label, style: QalamTypography.meta(color: colors.primary)),
+    );
+  }
+}
+
+class _TextbookOralCard extends StatelessWidget {
+  final HistoryEntry entry;
+  final bool isPersian;
+
+  const _TextbookOralCard({required this.entry, required this.isPersian});
+
+  @override
+  Widget build(BuildContext context) {
+    final colors = Theme.of(context).colorScheme;
+    return Container(
+      margin: const EdgeInsets.fromLTRB(24, 6, 24, 6),
+      padding: const EdgeInsets.all(16),
+      decoration: BoxDecoration(
+        color: colors.surface,
+        borderRadius: BorderRadius.circular(12),
+        border: Border.all(color: colors.outlineVariant),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Text(
+            isPersian ? 'روایت در کتاب تاریخ' : 'РИВОЯТ ДАР КИТОБИ ТАЪРИХ',
+            style: QalamTypography.eyebrow(color: colors.primary),
+          ),
+          const SizedBox(height: 8),
+          Text(
+            entry.title,
+            style: QalamTypography.sectionTitle(
+              color: colors.onSurface,
+              fontSize: 18,
+            ),
+          ),
+          const SizedBox(height: 6),
+          Text(
+            entry.summary,
+            style: QalamTypography.bodySecondary(
+              color: colors.onSurfaceVariant,
+            ),
+          ),
+          const SizedBox(height: 10),
+          Text(
+            '${entry.sourceSection} · ${isPersian ? "صنف" : "Синфи"} ${entry.grade}',
+            style: QalamTypography.meta(color: colors.onSurfaceVariant),
+          ),
+        ],
+      ),
+    );
+  }
+}
+
 class _OralEntryCard extends StatelessWidget {
   final OralHeritageEntry entry;
   final bool isPersian;
