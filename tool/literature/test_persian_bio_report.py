"""Tests for persian_bio_report.py (python3 -m unittest)."""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from persian_bio_report import compare_dates, gregorian_span, place_named  # noqa: E402


class SpanTest(unittest.TestCase):
    def test_persian_digits_with_the_gregorian_mark(self):
        bio = 'احمد جامی (۱۰۴۸–۱۱۴۱ م) متولد نامق ترشیز'
        self.assertEqual(gregorian_span(bio), ('1048', '1141'))

    def test_hijri_dates_are_skipped(self):
        bio = 'سعدی (۶۰۶–۶۹۰ ق / ۱۲۱۰–۱۲۹۱ م) شاعر'
        self.assertEqual(gregorian_span(bio), ('1210', '1291'))

    def test_a_single_marked_hijri_span_is_no_gregorian_span(self):
        self.assertIsNone(gregorian_span('رودکی (۲۴۴–۳۲۹ ه‍.ق)'))

    def test_an_unmarked_bracketed_span_counts(self):
        self.assertEqual(gregorian_span('لایق شیرعلی (1941-2000)'), ('1941', '2000'))

    def test_no_dates(self):
        self.assertIsNone(gregorian_span('شاعر بزرگ تاجیک'))


class CompareTest(unittest.TestCase):
    def test_equal_years_agree(self):
        self.assertIsNone(compare_dates(('1049', '1141'), ('1049', '1141')))

    def test_a_different_year_is_reported(self):
        self.assertEqual(compare_dates(('1049', '1141'), ('1048', '1141')),
                         'birth 1048 vs the textbook 1049')

    def test_an_approximate_textbook_year_allows_one_year(self):
        self.assertIsNone(compare_dates(('~980', '1037'), ('981', '1037')))

    def test_a_textbook_without_death_year_compares_birth_only(self):
        self.assertIsNone(compare_dates(('1946', None), ('1946', '2023')))


class PlaceTest(unittest.TestCase):
    def test_the_textbook_place_in_persian_script(self):
        self.assertTrue(place_named('Бухоро', 'در شهر بخارا زاده شد'))
        self.assertFalse(place_named('Ҷом', 'متولد نامق ترشیز'))

    def test_only_the_place_name_is_compared(self):
        self.assertTrue(place_named('шаҳри Бухоро', 'متولد بخارا'))
        self.assertTrue(place_named(
            'деҳаи Панҷрӯд (воқеъ дар ноҳияи кунунии Панҷакент)',
            'در روستای پنجرود زاده شد'))
        self.assertFalse(place_named('деҳаи Курговади ноҳияи Дарвоз',
                                     'متولد روستای پالمارک درواز'))


if __name__ == '__main__':
    unittest.main()
