"""Tests for classify_forms.py (python3 -m unittest)."""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from classify_forms import classify, form_hint, rhyme_scheme, rhymes  # noqa: E402

GHAZAL = [
    'Ёди айёме, ки пур аз май сабӯе доштем,',
    'Шаб ҳама шаб бар сари ғам ҳою ҳуе доштем.',
    'Дар чаман будем бо ёрон ба сад айшу тараб,',
    'Бо гулу булбул ҳаме гуфту гӯе доштем.',
    'Гарчи имрӯз аз ватан дурем, лекин пеш аз ин',
    'Дар диёри хеш мо ҳам обрӯе доштем.',
]
MASNAVI = [
    'Шабе парвонае бо шамъ мегуфт,',
    'Ки: «Эй гардида дардат бо дилам ҷуфт!',
    'Ту медонӣ, ки ман дар ишқи рӯят',
    'Шабу рӯзам ба гирди ҷустуҷӯят.',
    'Чу ман, ту ҳам агар сӯзӣ, ҳамин аст,',
    'Ки ишқи мо ду тан ҳам дар замин аст».',
]
RUBAI = [
    'Бо мардуми нек бад намебояд буд,',
    'Дар бодия деву дад намебояд буд.',
    'Мафтуни маоши худ намебояд шуд,',
    'Мағрур ба ақли худ намебояд буд.',
]
QITA = [
    'Марди озода дар миёни гурӯҳ,',
    'Гарчи хушхӯю оқилу доност,',
    'Чун надорад зару сим, пас хор аст,',
    'Гарчи дар илм Буалӣ Синост.',
]


class RhymeTest(unittest.TestCase):
    def test_a_shared_radif_and_rhyme(self):
        self.assertTrue(rhymes(['… ҳою ҳуе доштем.', '… гуфту гӯе доштем.']))

    def test_lines_that_do_not_rhyme(self):
        self.assertFalse(rhymes(['Марди озода дар миёни гурӯҳ,',
                                 'Гарчи хушхӯю оқилу доност,']))

    def test_the_schemes(self):
        self.assertEqual(rhyme_scheme(GHAZAL), 'monorhyme')
        self.assertEqual(rhyme_scheme(MASNAVI), 'couplets')
        self.assertEqual(rhyme_scheme(RUBAI), 'quatrain')
        self.assertEqual(rhyme_scheme(QITA), 'monorhyme')
        self.assertIsNone(rhyme_scheme(GHAZAL[:5]))       # an odd line count


class HintTest(unittest.TestCase):
    def test_the_form_named_in_the_lead_in(self):
        self.assertEqual(form_hint('Чунончи, дар ин ғазал мегӯяд:'), 'ghazal')
        self.assertEqual(form_hint('Ҳофиз дар рубоии зер … медонад:'), 'rubai')
        self.assertEqual(form_hint('дар маснавии «Туҳфаи дӯстон» … мекунад:'), 'epic')
        self.assertEqual(form_hint('дар қитъаи зерин хеле хуб матраҳ кардааст:'), 'fragment')
        self.assertIsNone(form_hint('Шоир чунин мегӯяд:'))

    def test_a_poet_described_as_a_writer_of_a_form_is_no_hint(self):
        self.assertIsNone(form_hint(
            'Заҳири Форёбӣ, ки аз шоирони қасидасарои асри XII аст, мегӯяд:'))
        self.assertIsNone(form_hint('Ӯ ғазалсарои моҳир буд ва мегӯяд:'))

    def test_only_the_last_sentence_counts(self):
        self.assertIsNone(form_hint('Ӯ ғазал ҳам менавишт. Шоир чунин мегӯяд:'))


class ClassifyTest(unittest.TestCase):
    def test_a_named_form_that_the_rhyme_confirms(self):
        self.assertEqual(classify(GHAZAL, 'poem', 'дар ин ғазал мегӯяд:'), ('ghazal', 'lead-in'))
        self.assertEqual(classify(QITA, 'poem', 'дар қитъаи зерин:'), ('fragment', 'lead-in'))
        self.assertEqual(classify(RUBAI, 'poem', 'дар рубоии зер:'), ('rubai', 'lead-in'))

    def test_a_named_form_the_rhyme_contradicts_is_not_applied(self):
        self.assertEqual(classify(MASNAVI, 'poem', 'дар ин ғазал мегӯяд:'), ('poem', None))

    def test_couplet_rhyme_alone_is_a_masnavi(self):
        self.assertEqual(classify(MASNAVI, 'poem', 'Шоир мегӯяд:'), ('epic', 'rhyme'))

    def test_a_quatrain_alone_is_not_called_a_rubai(self):
        # aaba is also how a ghazal opens: the rhyme alone cannot tell.
        self.assertEqual(classify(RUBAI, 'poem', 'Шоир мегӯяд:'), ('poem', None))

    def test_a_printed_genre_heading_is_kept(self):
        self.assertEqual(classify(GHAZAL, 'qasida', ''), ('qasida', None))


if __name__ == '__main__':
    unittest.main()
