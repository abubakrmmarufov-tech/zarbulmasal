import unittest

try:
    from quarantine_false_candidates import apply, classify, rejection_reason
except ModuleNotFoundError:
    from tool.literature_pipeline.scripts.quarantine_false_candidates import (
        apply,
        classify,
        rejection_reason,
    )


def work(title, *, level="needsReview", source_image=False):
    return {
        "id": title,
        "title": title,
        "primarySource": {"sourceImageVerified": source_image},
        "verification": {"evidenceLevel": level},
    }


class QuarantineFalseCandidatesTest(unittest.TestCase):
    def test_rejects_classroom_question(self):
        reason = rejection_reason(work("Ғазалро бурро хонед ва мазмунашро гӯед"))
        self.assertIn("textbook question", reason)

    def test_rejects_biographical_prose_lead(self):
        reason = rejection_reason(work("Соли 1977 шоир барои достонҳо"))
        self.assertIn("prose fragment", reason)

    def test_rejects_additional_exercise_and_prose_forms(self):
        titles = [
            "Мазмуну муҳтавои ғазали «Дар он саҳро»",
            "Кадом адиби тоҷик бахшидааст",
            "Дар роман персонажҳои мусбат",
            "Хулоса ва натиҷагириҳои худи муаллиф",
        ]
        for title in titles:
            self.assertIsNotNone(rejection_reason(work(title)), title)

    def test_rejects_extracted_narrative_sentences(self):
        titles = [
            "Дар яке аз шабҳои ҷумъаи соли 858 дар хонадони Муҳам-",
            "Чунин овардаанд, ки Наср ибн Аҳмад зимистон",
            "Амири Сомонӣ гуфт",
            "Маънои назм ба низом даровардан аст",
            "Рӯзе амири Сомонӣ Синоро имтиҳон карданӣ шуд",
        ]
        for title in titles:
            self.assertIsNotNone(rejection_reason(work(title)), title)

    def test_rejects_explicit_textbook_questions_and_tasks(self):
        titles = [
            "Дақиқӣ кӣ буд? Гуфтаҳои Фирдавсиро ба ёд оред...",
            "Қиссаи «Ситораҳо» кай навишта шудааст ва чӣ хел",
            "Аз матн мисраъҳоро ёфта ҷудо намоед",
            "Ба гуфтугузори қаҳрамонон диққат диҳед",
        ]
        for title in titles:
            self.assertIsNotNone(rejection_reason(work(title)), title)

    def test_rejects_additional_exercises_and_explanations(self):
        titles = [
            "Ҳангоми иҷрои супориш калимаҳои саховатмандро истифода баред",
            "Дар ин ҷумла кадом калимаҳо вазифаи муайянкунанда доранд?",
            "Аз «Фарҳанги забони тоҷикӣ» маънии онҳоро ёбед",
            "Ташбеҳ маънои чизеро ба чизе монанд кардан аст",
            "Меҳмон кист ва ӯ ба соҳибхона чӣ ҳақ дорад?",
            "бо наср иншо шудаанд ё бо назм? Аз мисолҳои китобатон зар...",
        ]
        for title in titles:
            self.assertIsNotNone(rejection_reason(work(title)), title)

    def test_rejects_narrative_and_biography_fragments(self):
        titles = [
            "Ду амирзода дар Миср буданд. Яке илм омӯхт ва дигаре",
            "Дарвеше танҳо дар гӯшаи саҳро нишаста буд. Подшоҳе",
            "Овардаанд, ки сипоҳи душман бисёр буду инон андак",
            "Рӯзе амири Сомонӣ Синоро имтиҳон карданӣ шуд",
            "Абӯҳомид Фаридуддин Аттор соли 1119 дар шаҳри",
            "Ансорӣ умри пурбаракат дида, соли 1088 дар зодгоҳаш",
        ]
        for title in titles:
            self.assertIsNotNone(rejection_reason(work(title)), title)

    def test_does_not_match_hudoyo_or_poetic_line(self):
        self.assertIsNone(rejection_reason(work("Худоё, арзу тули оламатро")))
        self.assertIsNone(rejection_reason(work("Бӯйи Ҷӯйи Мулиён")))

    def test_preserves_page_checked_and_image_inspected_records(self):
        self.assertIsNone(
            rejection_reason(work("Ғазалро хонед ва шарҳ диҳед", level="primaryChecked"))
        )
        self.assertIsNone(
            rejection_reason(work("Ғазалро хонед ва шарҳ диҳед", source_image=True))
        )

    def test_apply_only_changes_high_confidence_matches(self):
        works = [
            work("Ғазалро хонед ва шарҳ диҳед"),
            work("Бӯйи Ҷӯйи Мулиён"),
        ]
        self.assertEqual(apply(works), 1)
        self.assertEqual(works[0]["verification"]["evidenceLevel"], "rejected")
        self.assertEqual(works[1]["verification"]["evidenceLevel"], "needsReview")


if __name__ == "__main__":
    unittest.main()
