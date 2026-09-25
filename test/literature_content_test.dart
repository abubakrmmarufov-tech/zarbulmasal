import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Literary Content Validation', () {
    late List poets;
    late List works;
    late List sources;

    setUpAll(() {
      poets =
          jsonDecode(
                File('assets/data/literature/poets.json').readAsStringSync(),
              )
              as List;
      works =
          jsonDecode(
                File('assets/data/literature/works.json').readAsStringSync(),
              )
              as List;
      sources =
          jsonDecode(
                File('assets/data/literature/sources.json').readAsStringSync(),
              )
              as List;
    });

    test('No duplicate IDs', () {
      final poetIds = poets.map((p) => p['id']).toSet();
      expect(poetIds.length, poets.length, reason: 'Duplicate poet IDs found');

      final workIds = works.map((w) => w['id']).toSet();
      expect(workIds.length, works.length, reason: 'Duplicate work IDs found');

      final sourceIds = sources.map((s) => s['id']).toSet();
      expect(
        sourceIds.length,
        sources.length,
        reason: 'Duplicate source IDs found',
      );
    });

    test(
      'Canonical author records are unique and known duplicate merges stay resolved',
      () {
        String normalize(Object? value) => (value?.toString() ?? '')
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\u0400-\u04ff\u0600-\u06ff]+'), '');

        final names = <String>{};
        for (final poet in poets) {
          expect(
            names.add(normalize(poet['canonicalName'])),
            isTrue,
            reason: 'Duplicate canonical author: ${poet['canonicalName']}',
          );
        }

        final poetIds = poets.map((p) => p['id']).toSet();
        expect(
          poetIds.contains('3853d79b-0951-44c3-a5db-229649fa30b6'),
          isFalse,
        );
        expect(
          poetIds.contains('9a3f7c2a-a41d-4064-9ea7-766941c9ae35'),
          isFalse,
        );
        expect(
          poetIds.contains('bb00bac5-e207-4cc7-9539-a2af92b71281'),
          isFalse,
        );
        expect(
          poetIds.contains('beea5538-c891-4044-a75b-9bf21d1ef897'),
          isFalse,
        );
        expect(
          poetIds.contains('69d27d87-439e-4efe-a14f-a1196aa8471f'),
          isFalse,
        );
        expect(
          poetIds.contains('358dda13-365c-4434-87f0-d404b305adcb'),
          isFalse,
        );
        expect(
          poetIds.contains('01df7214-28b7-44ab-a1f4-898bb7e83950'),
          isFalse,
        );
        expect(
          poets.firstWhere(
            (p) => p['id'] == 'be19709e-c3af-460d-80b9-4c67046e8be3',
          )['canonicalName'],
          'Боботоҳири Урён',
        );
        expect(
          poets.firstWhere(
            (p) => p['id'] == '94d5f5e3-f9a6-4c3d-bd1b-a72f97a7e06e',
          )['aliases'],
          contains('Саноӣ'),
        );
      },
    );

    test(
      'Confirmed extraction artifacts remain auditable but are not public authors',
      () {
        const rejectedNames = {
          'Дар',
          'Мисраъҳои',
          'Номаълум',
          'Unknown',
          'Темурмалик',
          'султон Муҳаммад',
        };
        final rejectedIds = <String>{};
        for (final poet in poets) {
          final name = poet['canonicalName'] as String?;
          if (!rejectedNames.contains(name)) continue;
          expect(poet['recordStatus'], 'rejected', reason: name);
          rejectedIds.add(poet['id'] as String);
        }
        expect(rejectedIds, hasLength(rejectedNames.length));
        for (final work in works) {
          expect(
            rejectedIds.contains(work['authorId']),
            isFalse,
            reason:
                'Rejected author is still attached to a work: ${work['id']}',
          );
        }
      },
    );

    test('Unresolved reference authors stay in review and have no works', () {
      const reviewNames = {
        'Фарҳат',
        'Александр Пушкин',
        'Михаил Лермонтов',
        'Самуил Маршак',
        'Виктор Гюго',
        'Рафаэл Патканян',
        'Раҳимӣ',
        'Бадри Чочӣ',
      };
      final reviewIds = <String>{};
      for (final poet in poets) {
        final name = poet['canonicalName'] as String?;
        if (!reviewNames.contains(name)) continue;
        expect(poet['recordStatus'], 'review', reason: name);
        reviewIds.add(poet['id'] as String);
      }
      expect(reviewIds, hasLength(reviewNames.length));
      for (final work in works) {
        expect(
          reviewIds.contains(work['authorId']),
          isFalse,
          reason:
              'Review-only author is still attached to a work: ${work['id']}',
        );
      }
    });

    test(
      'Review-only authors retain exact Ministry source leads without promotion',
      () {
        final farhat = poets.firstWhere(
          (entry) => entry['canonicalName'] == 'Фарҳат',
        );
        final badri = poets.firstWhere(
          (entry) => entry['canonicalName'] == 'Бадри Чочӣ',
        );

        expect(farhat['recordStatus'], 'review');
        expect(
          farhat['biographySource'],
          contains(
            '«Таърихи халқи тоҷик», китоби дарсӣ барои синфи 11 (2022), с. 61',
          ),
        );
        expect(farhat['biographyQuarantineNote'], contains('М. Фарҳат'));
        expect(badri['recordStatus'], 'review');
        expect(
          badri['biographySource'],
          contains('«Адабиёти тоҷик», синфи 9 (2023), с. 8'),
        );
        expect(badri['biographyQuarantineNote'], contains('Бадри Чочӣ'));
      },
    );

    test(
      'International reference authors retain exact Ministry page leads without promotion',
      () {
        const expected = <String, String>{
          'Александр Пушкин': 'с. 11, 119',
          'Михаил Лермонтов': 'с. 275',
          'Самуил Маршак': 'с. 119',
          'Виктор Гюго': 'с. 12, 119',
          'Рафаэл Патканян': 'с. 119',
        };

        for (final entry in expected.entries) {
          final poet = poets.firstWhere(
            (candidate) => candidate['canonicalName'] == entry.key,
          );
          expect(poet['recordStatus'], 'review', reason: entry.key);
          expect(poet['biographySource'], contains(entry.value));
          expect(
            poet['biographyQuarantineNote'],
            contains('Review-only source lead'),
            reason: entry.key,
          );
          expect(poet['biographyTj'], isEmpty, reason: entry.key);
          expect(poet['portrait'], isNull, reason: entry.key);
        }
      },
    );

    test(
      'Textbook-explicit reference authors are source-backed but conservative',
      () {
        final hasanbek = poets.firstWhere(
          (entry) => entry['id'] == '7a4cc3dc-3d9c-4cf2-aa27-a9b66f68937f',
        );
        final abuSaid = poets.firstWhere(
          (entry) => entry['id'] == 'b28a4de3-06a8-406c-b2e9-db363f7aa2d5',
        );
        for (final entry in [hasanbek, abuSaid]) {
          expect(entry['recordStatus'], 'active');
          expect(entry['biographyTj'], isNotEmpty);
          expect(entry['biographyTjProvenance'], 'SOURCE_BACKED');
          expect(entry['biographyFaProvenance'], 'EDITORIAL_TRANSLATION');
          expect(entry['birthYear'], isNull);
          expect(entry['deathYear'], isNull);
          expect(entry['birthPlace'], isNull);
          expect(entry['majorWorkIds'], isEmpty);
        }
        expect(
          hasanbek['biographySource'],
          '«Адабиёти тоҷик», синфи 7 (2018), с. 150.',
        );
        expect(
          abuSaid['biographySource'],
          '«Адабиёти тоҷик», синфи 7 (2018), с. 159.',
        );
      },
    );

    test('Grade 8 early-literature biographies remain source-backed', () {
      final ozarbod = poets.firstWhere(
        (entry) => entry['id'] == '4830f7a5-85aa-4418-8785-40867a995614',
      );
      final masudi = poets.firstWhere(
        (entry) => entry['id'] == '58010d8f-2575-4b92-89e0-373f05b32929',
      );
      final abuHafs = poets.firstWhere(
        (entry) => entry['id'] == '2c8b026f-bab7-4cd8-9d86-26794a1573eb',
      );
      final muhammadVasif = poets.firstWhere(
        (entry) => entry['id'] == 'd708065a-1337-495f-ae6b-b0b5ce40e90f',
      );
      final firuzi = poets.firstWhere(
        (entry) => entry['id'] == 'cf6c66fa-1c48-4819-a4d9-287225e766b2',
      );
      final abuZirua = poets.firstWhere(
        (entry) => entry['id'] == '98e43b59-1d3a-440a-9d73-83b599cee7c5',
      );
      final kisoi = poets.firstWhere(
        (entry) => entry['id'] == '0079c49a-da77-47d1-bc1e-8ff4cbb9d337',
      );
      final balami = poets.firstWhere(
        (entry) => entry['id'] == 'cfe58486-55c2-474d-b329-248040b519ee',
      );
      final bassam = poets.firstWhere(
        (entry) => entry['id'] == '7d0a189b-d704-4c0e-bc8b-8504ffcb4e9f',
      );
      final muhammadMukhalad = poets.firstWhere(
        (entry) => entry['id'] == 'c76a0058-db4d-4bd3-83dd-a66f2b3578b4',
      );
      final mahmudWarraq = poets.firstWhere(
        (entry) => entry['id'] == '1b65d9d8-0e3d-4e02-8c65-30f98e84e109',
      );
      final abusulaik = poets.firstWhere(
        (entry) => entry['id'] == 'd1bb3938-3e96-42a9-b73d-bafbabf8554f',
      );
      final abushakur = poets.firstWhere(
        (entry) => entry['id'] == 'dea74b1e-32da-4afc-862f-4a08fd22f8f5',
      );
      final khusravani = poets.firstWhere(
        (entry) => entry['id'] == '91bf5726-5e0a-451e-be4b-7d91650f6cfa',
      );
      final yahyakhoja = poets.firstWhere(
        (entry) => entry['id'] == '1f97e6af-4d9c-4d58-9812-847d89348dfc',
      );
      final shahid = poets.firstWhere(
        (entry) => entry['id'] == 'a6b5eb18-39e9-4fdf-b492-e5956a553436',
      );
      final rabia = poets.firstWhere(
        (entry) => entry['id'] == '3d5d70c0-6294-4b7d-b830-79db08edd6b8',
      );
      final abulabbas = poets.firstWhere(
        (entry) => entry['id'] == '68bc433e-b316-46e1-bbe8-d53066764834',
      );
      final oghaji = poets.firstWhere(
        (entry) => entry['id'] == '5228f270-7e20-47cf-9e0b-4e6cc6fca51c',
      );
      final qamari = poets.firstWhere(
        (entry) => entry['id'] == '9915eac4-559e-4f20-9bdf-bb7a50e153db',
      );
      final abulMueyad = poets.firstWhere(
        (entry) => entry['id'] == 'ed2d18a8-f33e-4a66-8052-65128fe6295a',
      );
      final jaihony = poets.firstWhere(
        (entry) => entry['id'] == '717847cd-64b0-47e7-9d1c-75866e880647',
      );
      final abuAliBalami = poets.firstWhere(
        (entry) => entry['id'] == '9becac52-2650-408f-8ecf-d496a233d71a',
      );
      final masudSadiSalman = poets.firstWhere(
        (entry) => entry['id'] == '8c4f8cd7-4ae4-445c-b79b-bd10a6f83b65',
      );
      final zahiriSamarkandi = poets.firstWhere(
        (entry) => entry['id'] == 'ada69601-01d5-493f-b1a0-9b886be8daa8',
      );
      final nahviHerati = poets.firstWhere(
        (entry) => entry['id'] == '281c1b94-267e-4bbf-a7e5-47c24f99f0b5',
      );
      final qozizoda = poets.firstWhere(
        (entry) => entry['id'] == 'eb037eb9-ba72-49bd-b009-8f9c84d46105',
      );
      final zahiriFaryabi = poets.firstWhere(
        (entry) => entry['id'] == '381f06c4-cdbb-4b34-8a6f-fd16fa167cfa',
      );
      final salmaniSavaji = poets.firstWhere(
        (entry) => entry['id'] == '82f30a4e-f468-4a7d-bf03-bd29d3279fe0',
      );
      final amirShahi = poets.firstWhere(
        (entry) => entry['id'] == 'bda36de4-2636-4079-b473-d8f9f620820a',
      );
      final rashidiVatvat = poets.firstWhere(
        (entry) => entry['id'] == '16d7d64a-fca1-43cc-be01-86d776cde770',
      );
      final shamsTabrizi = poets.firstWhere(
        (entry) => entry['id'] == '1b50e1c6-7881-47ee-8965-4c19164dbf4a',
      );
      final ghaniKashmiri = poets.firstWhere(
        (entry) => entry['id'] == 'cef7fd49-54c8-4e46-9361-123cc52de5eb',
      );

      expect(ozarbod['biographyTj'], contains('124 панд'));
      expect(ozarbod['biographySource'], contains('с. 13–14'));
      expect(ozarbod['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(ozarbod['biographyFaProvenance'], 'EDITORIAL_TRANSLATION');
      expect(masudi['biographyTj'], contains('се байт'));
      expect(masudi['biographySource'], contains('с. 31–34'));
      expect(masudi['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(masudi['biographyFaProvenance'], 'EDITORIAL_TRANSLATION');
      expect(abuHafs['biographyTj'], contains('як байт'));
      expect(abuHafs['biographySource'], contains('с. 30'));
      expect(abuHafs['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(muhammadVasif['biographyTj'], contains('қасидае дар мадҳи Яъқуб'));
      expect(muhammadVasif['biographySource'], contains('с. 31–32'));
      expect(muhammadVasif['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(firuzi['biographyTj'], contains('896/897'));
      expect(firuzi['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(abuZirua['biographyTj'], contains('ҳамасри Рӯдакӣ'));
      expect(abuZirua['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(kisoi['biographyTj'], contains('охири асри X'));
      expect(kisoi['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(balami['biographyTj'], contains('вазири номии Сомониён'));
      expect(balami['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(bassam['biographyTj'], contains('пайравии Муҳаммад бинни Васиф'));
      expect(bassam['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(muhammadMukhalad['biographyTj'], contains('ба порсии дарӣ мадҳ'));
      expect(muhammadMukhalad['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(mahmudWarraq['biographyTj'], contains('835/836'));
      expect(mahmudWarraq['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(abusulaik['biographyTj'], contains('ҳазли малеҳ'));
      expect(abusulaik['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(abushakur['biographyTj'], contains('шеъри нағз'));
      expect(abushakur['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(khusravani['biographyTj'], contains('охири асри X'));
      expect(khusravani['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(yahyakhoja['biographyTj'], contains('ҳаҷвнигори бомаҳорат'));
      expect(yahyakhoja['biographySource'], contains('с. 95–96'));
      expect(yahyakhoja['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(shahid['biographyTj'], contains('Шаҳиди Балхӣ'));
      expect(shahid['biographyTj'], isNot(contains('АБУАБДУЛЛОҲИ РӮДАКӢ')));
      expect(shahid['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(rabia['biographyTj'], contains('нимаи дуюми асри IX'));
      expect(rabia['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(abulabbas['biographyTj'], contains('ду мисраъ'));
      expect(abulabbas['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(oghaji['biographyTj'], contains('парвози барф'));
      expect(oghaji['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(qamari['biographyTj'], contains('ду байти'));
      expect(qamari['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(
        abulMueyad['biographyTj'],
        contains('дар қатори шоирону нависандагони бузург'),
      );
      expect(abulMueyad['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(
        jaihony['biographyTj'],
        contains('дар қатори шоирону нависандагони бузург'),
      );
      expect(jaihony['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(
        abuAliBalami['biographyTj'],
        contains('дар қатори шоирону нависандагони бузург'),
      );
      expect(abuAliBalami['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(masudSadiSalman['biographyTj'], contains('дар Лоҳур'));
      expect(masudSadiSalman['biographyTj'], contains('«Ҳабсиёт»'));
      expect(masudSadiSalman['biographySource'], contains('с. 62–64'));
      expect(masudSadiSalman['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(zahiriSamarkandi['biographyTj'], contains('«Синдбоднома»'));
      expect(zahiriSamarkandi['biographySource'], contains('с. 51–53'));
      expect(zahiriSamarkandi['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(nahviHerati['biographyTj'], contains('шоирони машҳури Хуросон'));
      expect(nahviHerati['birthYear'], isNull);
      expect(nahviHerati['deathYear'], isNull);
      expect(nahviHerati['biographySource'], contains('с. 108'));
      expect(nahviHerati['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(qozizoda['biographyTj'], contains('писари қозии Сиистон'));
      expect(qozizoda['biographyTj'], contains('Мир Алишер ва Ҷомӣ'));
      expect(qozizoda['biographySource'], contains('с. 108–110'));
      expect(qozizoda['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(zahiriFaryabi['biographyTj'], contains('қасидасарои асри XII'));
      expect(zahiriFaryabi['biographySource'], contains('с. 33'));
      expect(zahiriFaryabi['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(zahiriFaryabi['biographyFaProvenance'], 'EDITORIAL_TRANSLATION');
      expect(salmaniSavaji['biographyTj'], contains('вазни арӯзӣ'));
      expect(salmaniSavaji['biographySource'], contains('с. 76'));
      expect(salmaniSavaji['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(amirShahi['biographyTj'], contains('байти машҳур'));
      expect(amirShahi['biographySource'], contains('с. 233'));
      expect(amirShahi['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(rashidiVatvat['biographyTj'], contains('замони Хоқонии Шарвонӣ'));
      expect(rashidiVatvat['biographySource'], contains('с. 251'));
      expect(rashidiVatvat['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(shamsTabrizi['biographyTj'], contains('соли 1244'));
      expect(shamsTabrizi['biographySource'], contains('с. 60–61'));
      expect(shamsTabrizi['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(ghaniKashmiri['biographyTj'], contains('сабки ҳиндӣ'));
      expect(ghaniKashmiri['biographySource'], contains('с. 168'));
      expect(ghaniKashmiri['biographyTjProvenance'], 'SOURCE_BACKED');
    });

    test('All authors referenced by works exist', () {
      final poetIds = poets.map((p) => p['id']).toSet();
      for (final work in works) {
        expect(
          poetIds.contains(work['authorId']),
          isTrue,
          reason:
              "Work ${work['id']} references unknown author ${work['authorId']}",
        );
      }
    });

    test('Known author biography mappings remain correct', () {
      final jalaluddin = poets.firstWhere(
        (entry) => entry['id'] == '0b0f1032-b36a-45e4-9930-8953b067db65',
      );
      final abuTahir = poets.firstWhere(
        (entry) => entry['id'] == 'b5c6d7e8-f9a0-4b1c-2d3e-4f5a6b7c8d9e',
      );

      expect(jalaluddin['biographyTj'], contains('Мавлоно Ҷалолиддини Балхӣ'));
      expect(jalaluddin['biographyTj'], isNot(contains('САНОИИ ҒАЗНАВӢ')));
      expect(jalaluddin['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(abuTahir['biographyTj'], contains('Абӯтоҳири Тарсусиро'));
      expect(abuTahir['biographyTj'], isNot(contains('ФАРОМУЗ ИБНИ ХУДОДОД')));
      expect(abuTahir['biographyTjProvenance'], 'SOURCE_BACKED');
    });

    test('Jadid-era biography records are not copied across authors', () {
      final sadriZiyo = poets.firstWhere(
        (entry) => entry['id'] == '79049bfd-1f01-4f9d-8e59-851cdbd4bba2',
      );
      final ajzi = poets.firstWhere(
        (entry) => entry['id'] == 'a2e5259d-9c1c-46f5-b845-04fb18d07858',
      );
      final ahmadjoni = poets.firstWhere(
        (entry) => entry['id'] == '26906a5a-692c-40a3-a991-6b3559cda394',
      );

      expect(sadriZiyo['biographyTj'], contains('Тазкори ашъор'));
      expect(sadriZiyo['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(ajzi['biographyTj'], contains('мактаби нав кушодааст'));
      expect(ajzi['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(ahmadjoni['biographyTj'], contains('як ғазали ӯро'));
      expect(ahmadjoni['biographyTjProvenance'], 'SOURCE_BACKED');
      expect(
        {
          sadriZiyo['biographyTj'],
          ajzi['biographyTj'],
          ahmadjoni['biographyTj'],
        }.length,
        3,
      );
    });

    test('One canonical work is retained per author/title/incipit', () {
      String normalize(Object? value) => (value?.toString() ?? '')
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\u0400-\u04ff\u0600-\u06ff]+'), '');

      final keys = <String>{};
      for (final work in works) {
        if ((work['verification'] as Map<String, dynamic>?)?['evidenceLevel'] ==
            'rejected') {
          continue;
        }
        final title = normalize(work['title']);
        if (title.isEmpty) continue;
        final key = [
          work['authorId'],
          title,
          normalize(work['incipit']),
        ].join('|');
        expect(
          keys.add(key),
          isTrue,
          reason: 'Duplicate canonical work mapping: ${work['id']}',
        );
      }
    });

    test('Ibn Sina rubai keeps the textbook attribution and exact page', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'dce12ea8-57c0-4c8e-a45e-cab1bd215437',
      );

      expect(work['authorId'], '1a55efdd-6a1f-43b8-834f-94af060b4329');
      expect(work['title'], 'Имрӯз бикун чу метавонӣ коре');
      expect(work['type'], 'rubai');
      expect(work['primarySource']['pageStart'], 62);
      expect(work['primarySource']['pageEnd'], 62);
      expect(
        work['primarySource']['sourceReference'],
        'docs/literature/pdfs/adabiet sinfi 5.pdf',
      );
      expect(work['verification']['evidenceLevel'], 'needsReview');
      expect(work['verification']['pageVerified'], isTrue);
      expect(work['secondarySource']['pageStart'], 142);
      expect(work['secondarySource']['pageEnd'], 142);
      expect(
        work['secondarySource']['sourceReference'],
        'docs/literature/pdfs/adabiyet sinfi 8.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/ibn_sina_imruz_bikun_grade8_2026_p142.png',
      );
      expect(work['textMatchResult'], 'exact');
      expect(work['rights']['status'], 'unknown');
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });
  });
}
