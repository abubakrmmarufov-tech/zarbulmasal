import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Literary Content Validation', () {
    late List poets;
    late List works;
    late List sources;
    late List canon;

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
      canon =
          jsonDecode(
                File(
                  'assets/data/literature/school_canon.json',
                ).readAsStringSync(),
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
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
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

    test('Rudaki poem keeps the line-collated Maorif 2025 witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'rudaki_buyi_juyi_muliyon_grade5_2017_p54',
      );

      expect(work['authorId'], 'rudaki');
      expect(work['title'], 'Бӯйи Ҷӯйи Мулиён');
      expect(work['primarySource']['pageStart'], 54);
      expect(work['secondarySource']['pageStart'], 56);
      expect(work['secondarySource']['pageEnd'], 56);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01K6HGRAG6CPT6S1XBVK6KBPJT.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/rudaki_buyi_muliyon_maorif_2025_p56.png',
      );
      expect(work['textMatchResult'], 'minor-variant');
      expect(work['variantNotes'], contains('Дувоздаҳ мисраъ'));
      expect(work['rights']['status'], 'unknown');
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });

    test('Lo(iq) mother qasida records a title-only Maorif occurrence', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == '49a09b23-21e1-47a0-9cec-c5ae9c98b06b',
      );

      expect(work['secondarySource'], isNull);
      expect(work['sourceOccurrences'], hasLength(1));
      final occurrence = work['sourceOccurrences'].single;
      expect(occurrence['pageStart'], 304);
      expect(occurrence['pageEnd'], 304);
      expect(
        occurrence['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F02T45W6EQD3B5FPGGTTXJ.pdf',
      );
      expect(occurrence['sourceImageVerified'], isTrue);
      expect(
        occurrence['sourceImagePath'],
        'assets/data/literature/page_images/loiq_qasidai_modar_maorif_2022_p304.png',
      );
      expect(work['textStatus'], 'needsReview');
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });

    test('Lo(iq) four-line poem keeps the exact Maorif 2025 witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'b262d381-d677-47f7-8074-12f7bf1267da',
      );

      expect(work['authorId'], 'loiq_sherali');
      expect(work['title'], 'Шоири фарзонаро асру замон');
      expect(work['primarySource']['pageStart'], 288);
      expect(work['secondarySource']['pageStart'], 288);
      expect(work['secondarySource']['pageEnd'], 288);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01KH8MQHJJBRM70Q8FXHNNCGV5.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/loiq_shoiri_farzonaro_maorif_2025_p288.png',
      );
      expect(work['textMatchResult'], 'exact');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['rights']['status'], 'unknown');
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });

    test('Hafez ghazal keeps the exact Maorif 2023 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == '0f48abbb-5652-4054-b518-dae7ea332240',
      );

      expect(work['authorId'], 'd1abb54a-9804-4baf-b238-fd2203d7673e');
      expect(work['title'], 'Агар он турки шерозӣ ба даст орад дили моро');
      expect(work['sourceOccurrences'], hasLength(1));
      final occurrence = work['sourceOccurrences'].single;
      expect(occurrence['pageStart'], 201);
      expect(occurrence['pageEnd'], 201);
      expect(
        occurrence['sourceReference'],
        'docs/literature/pdfs/adabiet sinfi 10.pdf',
      );
      expect(occurrence['sourceImageVerified'], isTrue);
      expect(
        occurrence['sourceImagePath'],
        'assets/data/literature/page_images/hafez_agar_on_turki_grade10_2026_p201.png',
      );
      expect(work['secondarySource']['pageStart'], 173);
      expect(work['secondarySource']['pageEnd'], 173);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F20TCS153WXVYZ6XFCVGXM.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/hafez_agar_maorif_2023_p173.png',
      );
      expect(work['textMatchResult'], 'exact');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['rights']['status'], 'unknown');
    });

    test('Tursunzoda poem keeps the exact Maorif 2022 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'f4c025e3-48a1-4bc1-8e29-cf404472e590',
      );

      expect(work['authorId'], 'tursunzoda');
      expect(work['title'], 'Зан агар оташ намешуд...');
      expect(work['primarySource']['pageStart'], 161);
      expect(work['secondarySource']['pageStart'], 160);
      expect(work['secondarySource']['pageEnd'], 160);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F02T45W6EQD3B5FPGGTTXJ.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/tursunzoda_zan_agar_maorif_2022_p160.png',
      );
      expect(work['textMatchResult'], 'exact');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['rights']['status'], 'unknown');
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });

    test('Bozor poem keeps the exact Maorif 2022 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'ced3e012-00e7-4c97-bb64-61d3045459b2',
      );

      expect(work['authorId'], 'bozor_sobir');
      expect(work['title'], 'Забони модарӣ');
      expect(work['primarySource']['pageStart'], 313);
      expect(work['secondarySource']['pageStart'], 313);
      expect(work['secondarySource']['pageEnd'], 313);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F02T45W6EQD3B5FPGGTTXJ.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/bozor_zaboni_modari_maorif_2022_p313.png',
      );
      expect(work['textMatchResult'], 'exact');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['rights']['status'], 'unknown');
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });

    test('Rabi’a qasida keeps the exact Maorif 2022 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'f0d76502-0ef6-4660-856c-26d27e9baee9',
      );

      expect(work['authorId'], '3d5d70c0-6294-4b7d-b830-79db08edd6b8');
      expect(work['title'], 'Фишонд аз савсану гул симу зар бод');
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['primarySource']['pageStart'], 60);
      expect(work['secondarySource']['pageStart'], 61);
      expect(work['secondarySource']['pageEnd'], 62);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F0Y279HFXYHRM4396KWW0C.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(work['secondarySource']['sourceImagePaths'], hasLength(2));
      expect(work['textMatchResult'], 'exact');
      expect(work['rights']['status'], 'unknown');
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });

    test('Ayni poem keeps the line-collated Maorif 2022 second witness', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == '0136bbcb-75f0-4e53-b66f-1b4a12f6b211',
      );

      expect(work['authorId'], '47c1dc67-363a-4506-8a9c-bbbb38f98d20');
      expect(work['title'], 'Биёед, эй рафиқон, дарс хонем');
      expect(work['primarySource']['pageStart'], 153);
      expect(work['secondarySource']['pageStart'], 132);
      expect(work['secondarySource']['pageEnd'], 132);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F0Y279HFXYHRM4396KWW0C.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/ayni_biyod_maorif_2022_p132.png',
      );
      expect(work['textMatchResult'], 'minor-variant');
      expect(work['variantNotes'], contains('бекориву'));
      expect(work['variantNotes'], contains('бекорию'));
      expect(work['rights']['status'], 'unknown');
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });

    test(
      'Kamol Khujandi second witnesses stay attached to the correct ghazals',
      () {
        final oshubi = works.firstWhere(
          (entry) =>
              entry['id'] == 'kamol_khujandi_oshubi_joni_grade7_2018_p106',
        );
        final dust = works.firstWhere(
          (entry) =>
              entry['id'] ==
              'kamol_khujandi_dust_medorad_dilam_grade7_2018_p106_107',
        );

        expect(oshubi['title'], 'Ошӯби ҷонӣ');
        expect(oshubi['primarySource']['pageStart'], 106);
        expect(oshubi['primarySource']['pageEnd'], 106);
        expect(oshubi['secondarySource'], isNull);
        expect(oshubi['textStatus'], 'needsReview');

        expect(dust['title'], 'Дӯст медорад дилам ҷавру ҷафои дӯстро');
        expect(dust['primarySource']['pageStart'], 106);
        expect(dust['primarySource']['pageEnd'], 107);
        expect(dust['secondarySource']['pageStart'], 102);
        expect(dust['secondarySource']['pageEnd'], 103);
        expect(
          dust['secondarySource']['sourceReference'],
          'https://maorif.tj/storage/libraries/01KH604RAK569PDJBYDN82T6WE.pdf',
        );
        expect(dust['textStatus'], 'needsReview');
      },
    );

    test('Qanoat poem keeps the explicit textbook title and page span', () {
      final work = works.firstWhere(
        (entry) => entry['id'] == 'qanoat_mavj_dar_sahro_grade6_2014_p147_148',
      );

      expect(work['authorId'], 'qanoat');
      expect(work['title'], 'Мавҷ дар саҳро');
      expect(work['type'], 'poem');
      expect(work['primarySource']['pageStart'], 147);
      expect(work['primarySource']['pageEnd'], 148);
      expect(
        work['primarySource']['sourceReference'],
        'docs/literature/pdfs/adabiet sinfi 6.pdf',
      );
      expect(work['primarySource']['sourceImageVerified'], isTrue);
      expect(work['primarySource']['sourceImagePaths'], hasLength(2));
      expect(work['secondarySource']['pageStart'], 148);
      expect(work['secondarySource']['pageEnd'], 148);
      expect(
        work['secondarySource']['sourceReference'],
        'https://maorif.tj/storage/libraries/01J3F1F8T37FBPNG27VF4N5P15.pdf',
      );
      expect(work['secondarySource']['sourceImageVerified'], isTrue);
      expect(
        work['secondarySource']['sourceImagePath'],
        'assets/data/literature/page_images/qanoat_mavj_maorif_2022_p148.png',
      );
      expect(work['textMatchResult'], 'minor-variant');
      expect(work['variantNotes'], contains('Украина.Мавҷи'));
      expect(work['variantNotes'], contains('Украина! Мавҷи'));
      expect(work['verification']['evidenceLevel'], 'primaryChecked');
      expect(work['verification']['pageVerified'], isTrue);
      expect(work['rights']['status'], 'unknown');
      expect(work['textTajik'], isNull);
      expect(work['textPersian'], isNull);
    });

    test('Qanoat multi-page poem titles remain distinct canonical works', () {
      final expected = {
        'qanoat_mavji_odam_grade6_2014_p149_150': (149, 150, 'Мавҷи одам'),
        'qanoat_mavji_barodari_grade6_2014_p150_151': (
          150,
          151,
          'Мавҷи бародарӣ',
        ),
      };

      for (final entry in expected.entries) {
        final work = works.firstWhere(
          (candidate) => candidate['id'] == entry.key,
        );
        expect(work['authorId'], 'qanoat');
        expect(work['title'], entry.value.$3);
        expect(work['primarySource']['pageStart'], entry.value.$1);
        expect(work['primarySource']['pageEnd'], entry.value.$2);
        expect(work['primarySource']['sourceImageVerified'], isTrue);
        expect(work['primarySource']['sourceImagePaths'], hasLength(2));
        expect(work['sourceOccurrences'], hasLength(1));
        expect(work['sourceOccurrences'].single['pageStart'], 278);
        expect(
          work['sourceOccurrences'].single['sourceReference'],
          'docs/literature/pdfs/adabiyet sinfi 11.pdf',
        );
        expect(work['sourceOccurrences'].single['sourceImageVerified'], isTrue);
        expect(work['secondarySource']['pageStart'], entry.value.$1);
        expect(work['secondarySource']['pageEnd'], entry.value.$2);
        expect(
          work['secondarySource']['sourceReference'],
          'https://maorif.tj/storage/libraries/01J3F1F8T37FBPNG27VF4N5P15.pdf',
        );
        expect(work['secondarySource']['sourceImageVerified'], isTrue);
        expect(work['secondarySource']['sourceImagePaths'], hasLength(2));
        expect(work['textMatchResult'], 'exact');
        expect(work['verification']['evidenceLevel'], 'primaryChecked');
        expect(work['verification']['pageVerified'], isTrue);
        expect(work['rights']['status'], 'unknown');
      }
    });

    test('All works referenced by school canon exist', () {
      final workIds = works.map((w) => w['id']).toSet();
      for (final entry in canon) {
        if (entry['workId'] != null && entry['workId'].toString().isNotEmpty) {
          expect(
            workIds.contains(entry['workId']),
            isTrue,
            reason:
                "Canon entry ${entry['id']} references unknown work ${entry['workId']}",
          );
        }
      }
    });

    test('Editorially approved works have required provenance and rights', () {
      for (final work in works) {
        final verification = work['verification'] ?? {};
        if (verification['evidenceLevel'] == 'editoriallyApproved') {
          expect(
            work['primarySource'],
            isNotNull,
            reason: "Approved work ${work['id']} missing primarySource",
          );
          expect(
            work['textStatus'],
            equals('verified'),
            reason: "Approved work ${work['id']} must have verified textStatus",
          );
          final primarySource = work['primarySource'] as Map<String, dynamic>;
          expect(
            primarySource['pageStart'],
            isA<int>(),
            reason:
                "Approved work ${work['id']} needs a documented source page",
          );
          expect(
            verification['pageVerified'],
            isTrue,
            reason: "Approved work ${work['id']} must confirm its source page",
          );

          final rights = work['rights'];
          expect(
            rights,
            isNotNull,
            reason: "Work ${work['id']} missing rights",
          );
          expect(
            rights['status'],
            isNot(equals('unknown')),
            reason: "Approved work ${work['id']} has unknown rights",
          );
          expect(
            rights['status'],
            isNot(equals('blocked')),
            reason: "Approved work ${work['id']} has blocked rights",
          );
        }
      }
    });

    test('All works use the canonical verification schema', () {
      const evidenceLevels = {
        'extracted',
        'sourceLocated',
        'primaryChecked',
        'secondWitnessLocated',
        'collated',
        'editoriallyApproved',
        'rejected',
        'needsReview',
      };

      for (final work in works) {
        final verification = work['verification'];
        expect(verification, isA<Map>());
        expect(evidenceLevels, contains(verification['evidenceLevel']));
        final pageVerified = verification['pageVerified'];
        if (pageVerified != null) {
          expect(pageVerified, isA<bool>());
        }
        if (verification['evidenceLevel'] == 'primaryChecked' ||
            verification['evidenceLevel'] == 'editoriallyApproved') {
          expect(pageVerified, isTrue);
        }
        expect(verification, isNot(contains('finalStatus')));
        expect(verification, isNot(contains('pageChecked')));
      }
    });

    test(
      'Rejected extraction candidates carry an explicit quarantine reason',
      () {
        final rejected = works
            .where(
              (work) => work['verification']['evidenceLevel'] == 'rejected',
            )
            .toList();

        expect(rejected, isNotEmpty);
        final expectedDuplicateTargets = {
          'f577d913-68cf-4868-9f1c-20873b27586a':
              '7673c21c-eabd-4f67-954c-99af1028a7a7',
          'poem_3ec91317-fcfe-4960-9ca0-fd87f3e96875_80be041bf488740f':
              'd02917e3-6e5f-4f65-9166-ad705decb7be',
          '365b30a4-10ac-411c-918b-c5081254acc2':
              'd02917e3-6e5f-4f65-9166-ad705decb7be',
          'poem_tursunzoda_37aea1e9bce734d9':
              'f4c025e3-48a1-4bc1-8e29-cf404472e590',
          'poem_f09073cb-33b4-4fcc-abf8-75959350245c_44051f759d121097':
              'f9f475b2-5a47-4128-8c13-16d828359c3f',
          'poem_9ab32712-ce1d-4054-a7cc-163ca4a8f11f_28a16b52c71a8979':
              'fd2474e2-427e-4c38-8a72-4fe9b3581779',
          'poem_a6dd1c54-753d-4a52-8e5b-5365b7908aa3_a9179064e19a1450':
              'c03e8139-0ed8-4167-9ded-212ba3c7c564',
          'poem_5fc69b51-c38a-4427-a362-5c8a14bca835_def097ba98516b2e':
              'f3088f90-d92d-4008-83a8-a1963f50a717',
        };
        for (final work in rejected) {
          final verification = work['verification'] as Map<String, dynamic>;
          final reason = verification['rejectionReason'] as String;
          if (reason.startsWith('duplicate_canonical_work:')) {
            final expectedCanonical = expectedDuplicateTargets[work['id']];
            expect(expectedCanonical, isNotNull);
            expect(reason, 'duplicate_canonical_work:$expectedCanonical');
            expect(
              verification['verificationMethod'],
              'manualCanonicalDuplicateReview',
            );
            final canonicalWork = works.firstWhere(
              (candidate) => candidate['id'] == expectedCanonical,
            );
            expect(
              canonicalWork['verification']['evidenceLevel'],
              anyOf('primaryChecked', 'editoriallyApproved'),
              reason:
                  'Duplicate ${work['id']} must point to a checked canonical work',
            );
          } else {
            expect(
              reason,
              startsWith('extraction_false_positive:'),
              reason: 'Rejected work ${work['id']} needs an auditable reason',
            );
            expect(
              verification['verificationMethod'],
              anyOf(
                'conservativeFalseCandidateQuarantine',
                'manualContentTypeReview',
                'manualAttributionReview',
              ),
            );
          }
          expect(work['textTajik'], isNull);
          expect(work['textPersian'], isNull);
        }
      },
    );

    test('Newly promoted biographies cite the exact textbook pages', () {
      final expected = {
        'juma_odina': '«Адабиёти тоҷик», синфи 6 (2014), с. 155',
        'nasrulloh': '«Адабиёти тоҷик», синфи 8 (2026), с. 220–221',
        'faromuz': '«Адабиёти тоҷик», синфи 8 (2026), с. 226',
        'mirzosodiq': '«Адабиёти тоҷик», синфи 10 (2026), с. 163–165',
        'gulkhani': '«Адабиёти тоҷик», синфи 10 (2026), с. 207–209',
        'qooni': '«Адабиёти тоҷик», синфи 10 (2026), с. 216–217',
        'savdo': '«Адабиёти тоҷик», синфи 10 (2026), с. 270–272',
        'karomatullohi_mirzo': '«Адабиёти тоҷик», синфи 11 (2026), с. 390–392',
        'sayf_rahimzod': '«Адабиёти тоҷик», синфи 11 (2026), с. 317–318',
        'buzurgmehr': '«Адабиёти тоҷик», синфи 8 (2026), с. 19–21',
        'hoziq': '«Адабиёти тоҷик», синфи 10 (2026), с. 185–189',
        'vozeh': '«Адабиёти тоҷик», синфи 10 (2026), с. 319–322',
        'kangurti': '«Адабиёти тоҷик», синфи 11 (2026), с. 40–44',
        'sattor_tursun': '«Адабиёти тоҷик», синфи 11 (2026), с. 326–327',
        'mehmon_bakhti': '«Адабиёти тоҷик», синфи 11 (2026), с. 355–357',
        'abdulhamid_samad': '«Адабиёти тоҷик», синфи 11 (2026), с. 381–382',
      };
      for (final entry in expected.entries) {
        final poet = poets.firstWhere(
          (candidate) => candidate['id'] == entry.key,
        );
        expect(poet['biographyTj'], isNotEmpty);
        expect(poet['biographyTjProvenance'], 'SOURCE_BACKED');
        expect(poet['biographySource'], entry.value);
        expect(poet['biographyFaProvenance'], 'EDITORIAL_TRANSLATION');
      }
    });

    test('Pending page records use the exact textbook witness', () {
      final expected = {
        'b743e878-8215-4727-b67e-ad56dfccfbbe': (
          290,
          'docs/literature/pdfs/adabiyet sinfi 11.pdf',
          'Адабиёти тоҷик (давраи нав)',
        ),
        '0c468886-d790-46eb-bc2c-07ce1f306f8a': (
          298,
          'docs/literature/pdfs/adabiyet sinfi 11.pdf',
          'Адабиёти тоҷик (давраи нав)',
        ),
        '01c92ca0-db0b-4993-ad30-93ee6fc9126f': (
          12,
          'docs/literature/pdfs/adabiet sinfi 6.pdf',
          'Адабиёти тоҷик, синфи 6',
        ),
      };

      for (final entry in expected.entries) {
        final work = works.firstWhere(
          (candidate) => candidate['id'] == entry.key,
        );
        final source = work['primarySource'] as Map<String, dynamic>;
        expect(source['pageStart'], entry.value.$1);
        expect(source['pageEnd'], entry.value.$1);
        expect(source['sourceReference'], entry.value.$2);
        expect(source['bookTitle'], entry.value.$3);
        expect(source['sourceImageVerified'], isFalse);
      }
    });
  });
}
