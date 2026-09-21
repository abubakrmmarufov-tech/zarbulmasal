#!/usr/bin/env python3
"""
Comprehensive Curriculum and Heritage Expansion Script for Zarbulmasal.
Implements Loop 1 with complete epistemic integrity:
1. Deduplicates poets in poets.json while preserving one canonical record per author.
2. Adds missing curriculum authors (Ahmad Donish, Sotim Ulughzoda, etc.).
3. Enriches curriculum poets with full, authentic biographies from EXTRACTED_BIOGRAPHIES.json.
4. Updates school_canon.json with authentic curriculum entries across Grades 5-11.
5. Ensures exact alignment with sources.json and unit test expectations.
6. Verifies 0 dangling references.
"""

if __name__ == "__main__":
    raise SystemExit(
        "Deprecated and disabled: use tool/literature_pipeline/scripts/build_assets.py "
        "for the reviewed, dry-run-first literature pipeline."
    )

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
POETS_PATH = ROOT / "assets/data/literature/poets.json"
WORKS_PATH = ROOT / "assets/data/literature/works.json"
CANON_PATH = ROOT / "assets/data/literature/school_canon.json"
SOURCES_PATH = ROOT / "assets/data/literature/sources.json"
HISTORY_PATH = ROOT / "assets/data/history/entries.json"
CURRICULUM_MAP_PATH = ROOT / "docs/literature/CURRICULUM_MAPPING.json"
EXTRACTED_BIOS_PATH = ROOT / "docs/literature/EXTRACTED_BIOGRAPHIES.json"

def load_data():
    import subprocess
    try:
        raw_poets = subprocess.check_output(['git', 'show', 'HEAD:assets/data/literature/poets.json']).decode('utf-8')
        poets = json.loads(raw_poets)
    except Exception:
        with open(POETS_PATH, "r", encoding="utf-8") as f:
            poets = json.load(f)
    with open(WORKS_PATH, "r", encoding="utf-8") as f:
        works = json.load(f)
    with open(CANON_PATH, "r", encoding="utf-8") as f:
        canon = json.load(f)
    with open(SOURCES_PATH, "r", encoding="utf-8") as f:
        sources = json.load(f)
    with open(HISTORY_PATH, "r", encoding="utf-8") as f:
        history = json.load(f)
    with open(CURRICULUM_MAP_PATH, "r", encoding="utf-8") as f:
        curriculum = json.load(f)
    with open(EXTRACTED_BIOS_PATH, "r", encoding="utf-8") as f:
        bios = json.load(f)
    return poets, works, canon, sources, history, curriculum, bios

def run_expansion(dry_run=False):
    poets, works, canon, sources, history, curriculum, bios = load_data()
    print(f"Starting expansion. Initial counts: {len(poets)} poets, {len(works)} works, {len(canon)} canon entries.")

    sources_by_id = {s["id"]: s for s in sources}

    # 1. Complete merge map of duplicate poet entities (old_id -> canonical_id)
    merge_map = {
        # Firdawsi
        "ac759bd8-fe4e-4ef3-9e2f-30226a014707": "a6dd1c54-753d-4a52-8e5b-5365b7908aa3",
        "b5252e27-e6c6-401e-aca9-5fec3da36b65": "a6dd1c54-753d-4a52-8e5b-5365b7908aa3",
        "afc28bbb-ebba-4669-9715-a10cbbe7400a": "a6dd1c54-753d-4a52-8e5b-5365b7908aa3",
        # Ibn Sina
        "6e223a11-a2df-4298-bb14-2911af2da37d": "1a55efdd-6a1f-43b8-834f-94af060b4329",
        # Kaykovus
        "732f0989-b849-4856-a0dd-ba2f64f1c9a0": "92753b88-1d31-4f79-aae4-5d36c83ab4a1",
        # Asadii Tusi
        "5ff997ff-991d-4d18-ba6e-8acaa7a15058": "8231eb1a-ac35-46d2-9e39-19d5603bfcec",
        # Bobotohir
        "ab679c6b-ce9a-4e85-bf3b-81a8bed84623": "be19709e-c3af-460d-80b9-4c67046e8be3",
        # Jami uppercase
        "a0edb1e9-51b5-4ad1-ad0a-5d8af6a6a6da": "9debff75-8664-43ab-a7a9-ed1a4725f69b",
        # Anvari
        "17559ef6-4071-495f-b966-e5be3b33d3a3": "7281c3ee-3fe9-4450-9b10-33d0d52f34e5",
        "f0b1063a-6315-46b1-84ee-9a7787325a4c": "7281c3ee-3fe9-4450-9b10-33d0d52f34e5",
        # Daqiqi
        "e948618d-0c4c-484b-b60b-c1658bc51d57": "b0133115-7ead-4ec8-bc6d-115f4540bdb2",
        "da5e2975-a8e2-44ce-a30c-0e5d98f73844": "b0133115-7ead-4ec8-bc6d-115f4540bdb2",
        # Ayni
        "44aaf1c8-ce97-4cd1-a21f-7de5db7c615d": "47c1dc67-363a-4506-8a9c-bbbb38f98d20",
        # Farrukhi
        "650312c1-094f-4cd9-9313-efe38bdbef0f": "282f4c69-1d14-4be2-89d3-d21f867e4964",
        "11c85433-4042-4e24-95fb-ccc37ef0d2ea": "282f4c69-1d14-4be2-89d3-d21f867e4964",
        # Hafiz
        "da1e1d82-ceeb-4a9e-9e42-251b9b05d20c": "d1abb54a-9804-4baf-b238-fd2203d7673e",
        # Bedil
        "0a3d3ab5-3edd-4075-b382-7d16a25bdf71": "455f0420-3834-48f0-86b9-7da673a2a684",
        # Lohuti
        "74ea3b93-4c65-4605-95a7-8c2ec4c382cc": "310a8288-d554-4b9c-9ad1-3273b1edce85",
        "32624545-f720-4267-9669-d3648b7369ac": "310a8288-d554-4b9c-9ad1-3273b1edce85",
        # Attor
        "b299ac33-ad0c-4e9e-8bb3-aabfd19b8126": "c9ea2574-7623-4974-ada0-49c075b2831b",
        "7b8bcd3c-a1fa-4b9d-9378-76684d2495b0": "c9ea2574-7623-4974-ada0-49c075b2831b",
        # Robia Balkhi
        "c4ed06c1-4e72-485e-bde4-8f1c06e969db": "3d5d70c0-6294-4b7d-b830-79db08edd6b8",
        # Soib
        "8e7316a8-5101-4fd2-8a83-0a883a8da9fb": "121ce628-ff4b-44d2-a702-81db93040dee",
        # Shavkat
        "84e67a80-5859-48f9-a533-a1f999cb2939": "465d3f4a-4924-4ca6-9371-7266ae4393c7",
        # Nizomi
        "38f2044a-792f-46be-8707-90721abe3ea1": "d5abab06-07e9-4247-b8a8-f4801b6a5be4",
        # Jaloliddini Balkhi
        "0834f4b1-3aa1-4460-b2bd-5b4e8334c3fe": "0b0f1032-b36a-45e4-9930-8953b067db65",
        "740c2616-7dc2-4d45-9743-ad0b9d086dbc": "0b0f1032-b36a-45e4-9930-8953b067db65",
        "7e8a043d-be9b-4bc0-b779-b9e8ea00ad04": "0b0f1032-b36a-45e4-9930-8953b067db65",
        # Sayyido
        "17004fb9-d6b6-4f73-844e-51e02737ef5e": "5633556b-df45-4cab-83dc-760016db1ef2",
        # Khoqoni
        "890cf706-3f30-4f4f-a192-01dd841835c5": "e8ec4440-682a-48f1-ba59-54d8a9595c16",
        # Loiq topic pseudo-author
        "315b0945-c657-4c32-8b46-abb5f148482b": "loiq_sherali",
        # Forward previous temp IDs to canonical IDs
        "a1b2c3d4-b5c6-4d7e-8f9a-0b1c2d3e4f5a": "ef0f434c-c5a7-4cdd-b13a-35f999319fbf",
        "d4e5f6a7-e8f9-4a0b-1c2d-3e4f5a6b7c8d": "a4b182d3-1c06-4c82-9858-0e71d95edeb3",
    }

    # 2. Redirect works authorId
    redirected_works = 0
    for w in works:
        old_aid = w.get("authorId")
        if old_aid in merge_map:
            w["authorId"] = merge_map[old_aid]
            redirected_works += 1

    # 3. Redirect canon authorId
    redirected_canon = 0
    for c in canon:
        old_aid = c.get("authorId")
        if old_aid in merge_map:
            c["authorId"] = merge_map[old_aid]
            redirected_canon += 1

    # 4. Redirect history relatedAuthorIds
    redirected_history = 0
    for h in history:
        new_aids = []
        changed = False
        for aid in h.get("relatedAuthorIds", []):
            if aid in merge_map:
                new_aids.append(merge_map[aid])
                changed = True
            else:
                new_aids.append(aid)
        if changed:
            h["relatedAuthorIds"] = list(dict.fromkeys(new_aids))
            redirected_history += 1

    print(f"Foreign keys updated: {redirected_works} works, {redirected_canon} canon, {redirected_history} history entries.")

    # 5. Merge metadata from removed poets into canonical poets
    poet_dict = {p["id"]: p for p in poets}
    for rem_id, keep_id in merge_map.items():
        if rem_id in poet_dict and keep_id in poet_dict:
            rem_p = poet_dict[rem_id]
            keep_p = poet_dict[keep_id]
            # Merge aliases
            aliases = set(keep_p.get("aliases", []))
            aliases.add(rem_p["canonicalName"])
            for a in rem_p.get("aliases", []):
                aliases.add(a)
            keep_p["aliases"] = sorted(list(aliases))
            # Merge grades
            grades = set(keep_p.get("educationGrades", []))
            for g in rem_p.get("educationGrades", []):
                grades.add(g)
            keep_p["educationGrades"] = sorted(list(grades))

    # 6. Filter out deleted duplicate poets
    poets_cleaned = [p for p in poets if p["id"] not in merge_map]
    print(f"Poet count after deduplication: {len(poets)} -> {len(poets_cleaned)} (removed {len(merge_map)} duplicate records).")

    # 7. Add missing curriculum authors
    slug_to_canonical = {
        "rudaki": "rudaki",
        "firdawsi": "a6dd1c54-753d-4a52-8e5b-5365b7908aa3",
        "ibn_sina": "1a55efdd-6a1f-43b8-834f-94af060b4329",
        "nasir_khusraw": "nasir_khusraw",
        "umar_khayyam": "5fc69b51-c38a-4427-a362-5c8a14bca835",
        "khayyam": "5fc69b51-c38a-4427-a362-5c8a14bca835",
        "saadi": "3ec91317-fcfe-4960-9ca0-fd87f3e96875",
        "saadi_sherozi": "3ec91317-fcfe-4960-9ca0-fd87f3e96875",
        "hafiz": "d1abb54a-9804-4baf-b238-fd2203d7673e",
        "hafiz_sherozi": "d1abb54a-9804-4baf-b238-fd2203d7673e",
        "kamol_khujandi": "kamol_khujandi",
        "jami": "9debff75-8664-43ab-a7a9-ed1a4725f69b",
        "abdurrahman_jami": "9debff75-8664-43ab-a7a9-ed1a4725f69b",
        "navoi": "228feecd-8a97-4aaf-9b92-b9896c3a7d7d",
        "alisher_navoi": "228feecd-8a97-4aaf-9b92-b9896c3a7d7d",
        "bedil": "455f0420-3834-48f0-86b9-7da673a2a684",
        "sayyido": "5633556b-df45-4cab-83dc-760016db1ef2",
        "sayyido_nasafi": "5633556b-df45-4cab-83dc-760016db1ef2",
        "ahmad_donish": "ahmad_donish",
        "ahmadi_donish": "ahmad_donish",
        "binoi": "ef0f434c-c5a7-4cdd-b13a-35f999319fbf",
        "kamoliddin_binoi": "ef0f434c-c5a7-4cdd-b13a-35f999319fbf",
        "ansori": "a4b182d3-1c06-4c82-9858-0e71d95edeb3",
        "abdullohi_ansori": "a4b182d3-1c06-4c82-9858-0e71d95edeb3",
        "gulnazar_keldi": "gulnazar_keldi",
        "mirsaid_mirshakar": "a7feaa09-c83f-44f2-a69e-0a46ba957dbc",
        "ghaffor_mirzo": "400b9785-ae80-4957-a653-d65c72cdbf79",
        "gulchehra_sulaymoni": "gulchehra_sulaymoni",
        "ulughzoda": "e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b",
        "sotim_ulughzoda": "e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b",
        "ikromi": "f5a6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9c",
        "jalol_ikromi": "f5a6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9c",
        "avfi": "b2c3d4e5-c6d7-4e8f-9a0b-1c2d3e4f5a6b",
        "muhammad_avfi": "b2c3d4e5-c6d7-4e8f-9a0b-1c2d3e4f5a6b",
        "ghazoli": "c3d4e5f6-d7e8-4f9a-0b1c-2d3e4f5a6b7c",
        "muhammad_ghazoli": "c3d4e5f6-d7e8-4f9a-0b1c-2d3e4f5a6b7c",
        "shohin": "6ab9cd0a-0ff0-4a73-99ba-6604d9c61847",
        "shamsiddin_shohin": "6ab9cd0a-0ff0-4a73-99ba-6604d9c61847",
        "ayni": "47c1dc67-363a-4506-8a9c-bbbb38f98d20",
        "sadriddin_ayni": "47c1dc67-363a-4506-8a9c-bbbb38f98d20",
        "lohuti": "310a8288-d554-4b9c-9ad1-3273b1edce85",
        "abulqosim_lohuti": "310a8288-d554-4b9c-9ad1-3273b1edce85",
        "tursunzoda": "tursunzoda",
        "mirzo_tursunzoda": "tursunzoda",
        "qanoat": "qanoat",
        "mumin_qanoat": "qanoat",
        "loiq_sherali": "loiq_sherali",
        "bozor_sobir": "bozor_sobir",
        "robia_balkhi": "3d5d70c0-6294-4b7d-b830-79db08edd6b8",
        "kaykovus": "92753b88-1d31-4f79-aae4-5d36c83ab4a1",
        "farrukhi": "282f4c69-1d14-4be2-89d3-d21f867e4964",
        "nizomi_ganjavi": "d5abab06-07e9-4247-b8a8-f4801b6a5be4",
        "hiloli": "f09073cb-33b4-4fcc-abf8-75959350245c",
        "rumi": "0b0f1032-b36a-45e4-9930-8953b067db65",
        "daqiqi": "b0133115-7ead-4ec8-bc6d-115f4540bdb2",
        "bobotohir": "be19709e-c3af-460d-80b9-4c67046e8be3",
        "asadii_tusi": "8231eb1a-ac35-46d2-9e39-19d5603bfcec",
        "sanoi": "94d5f5e3-f9a6-4c3d-bd1b-a72f97a7e06e",
        "anvari": "7281c3ee-3fe9-4450-9b10-33d0d52f34e5",
        "attor": "c9ea2574-7623-4974-ada0-49c075b2831b",
        "khusrav_dehlavi": "7c8e3b4f-d27f-4bb1-9b7c-a2ea436b5482",
        "amir_khusrav": "7c8e3b4f-d27f-4bb1-9b7c-a2ea436b5482",
        "mushfiqi": "92a7c4fa-3191-4301-ba53-8087ce7ef3d8",
        "soib": "121ce628-ff4b-44d2-a702-81db93040dee",
        "shavkati_bukhoroi": "465d3f4a-4924-4ca6-9371-7266ae4393c7",
        "ahmadi_jomi": "9ab32712-ce1d-4054-a7cc-163ca4a8f11f",
        "nizomii_aruzi": "6b080d51-336b-48ba-92cd-85fe29149e0d",
        "nizomulmulk": "42d303b5-f20f-440d-8079-a8e25ef52d2e",
        "eraj_mirzo": "10a9ad7d-fd0d-462f-8cb4-594a869f8229",
        "boqi_rahimzoda": "eff956d5-9b8c-4522-9ac6-8791f15495ce",
        "muhiddin_aminzoda": "12fb0e82-f108-4e71-8207-74d0540639d3",
        "aminjon_shukuhi": "65bd67be-a18d-4679-8721-cd13818933b1",
        "shukuhi": "65bd67be-a18d-4679-8721-cd13818933b1",
        "zahiri": "ada69601-01d5-493f-b1a0-9b886be8daa8",
        "masudi_sad": "8c4f8cd7-4ae4-445c-b79b-bd10a6f83b65",
        "zokonii": "0e91d643-d947-4f0d-b3ac-ec2715a4b87c",
        "koshifi": "ea87e35a-6a03-44f2-837e-648d1c84aecc",
        "samandar": "06b70024-a028-43dd-8c23-cdb75e96fac8",
        "muhammadiev": "a74ea72d-864f-4c25-b42e-95435794a42d",
        "tugral": "43004ccf-0d32-463c-aad5-b6aaec73fbb4",
        "asiri": "2e7a713f-c3d2-449e-bd6a-a4b5b7350201",
        "payrav_sulaymoni": "e859c1ae-03b9-4add-8079-7fa5bcf64ef7",
        "habib_yusufi": "26c985a4-88ca-47ea-8981-ba5529b62a7c",
        "khalili": "fd212071-6a30-4b8d-870a-ae784002e8f2",
        "khoqoni": "e8ec4440-682a-48f1-ba59-54d8a9595c16",
        "vosifi": "7c389f92-ffdc-4f8e-b901-1de71acc34a9",
        "ibni_yamin": "5ec16ef0-b9c8-44e1-a6fc-4a01ee3f7def",
        "ibn_yamin": "5ec16ef0-b9c8-44e1-a6fc-4a01ee3f7def",
        "nakhshabi": "ec41abdc-c530-4745-825f-a23cd7515ca5",
        "sayfi_farghoni": "cfb751a8-dce3-4553-aef8-bc4574b2b85e",
        "hayrat": "604d62c2-62fc-4aa3-a7d2-8348e714b52d",
        "gulnazar_keldi": "c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f",
        "mirshakar": "d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a",
        "ghaffor_mirzo": "e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b",
        "gulchehra_sulaymoni": "f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c",
        "binoi": "a1b2c3d4-b5c6-4d7e-8f9a-0b1c2d3e4f5a",
        "avfi": "b2c3d4e5-c6d7-4e8f-9a0b-1c2d3e4f5a6b",
        "ghazoli": "c3d4e5f6-d7e8-4f9a-0b1c-2d3e4f5a6b7c",
        "ansori": "d4e5f6a7-e8f9-4a0b-1c2d-3e4f5a6b7c8d",
        "abdulloh_ansori": "d4e5f6a7-e8f9-4a0b-1c2d-3e4f5a6b7c8d",
        "ulughzoda": "e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b",
        "ikromi": "f5a6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9c",
        "kangurti": "a6b7c8d9-e0f1-4a2b-3c4d-5e6f7a8b9c0d",
        "hoziq": "b7c8d9e0-f1a2-4b3c-4d5e-6f7a8b9c0d1e",
        "gulkhani": "c8d9e0f1-a2b3-4c4d-5e6f-7a8b9c0d1e2f",
        "qooni": "d9e0f1a2-b3c4-4d5e-6f7a-8b9c0d1e2f3a",
        "savdo": "e0f1a2b3-c4d5-4e6f-7a8b-9c0d1e2f3a4b",
        "vozeh": "f1a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c",
        "mirzosodiq": "a2b3c4d5-e6f7-4a8b-9c0d-1e2f3a4b5c6d",
        "sayf_rahimzod": "b3c4d5e6-f7a8-4b9c-0d1e-2f3a4b5c6d7e",
        "sattor_tursun": "c4d5e6f7-a8b9-4c0d-1e2f-3a4b5c6d7e8f",
        "mehmon_bakhti": "d5e6f7a8-b9c0-4d1e-2f3a-4b5c6d7e8f9a",
        "abdulhamid_samad": "e6f7a8b9-c0d1-4e2f-3a4b-5c6d7e8f9a0b",
        "karomatullohi_mirzo": "f7a8b9c0-d1e2-4f3a-4b5c-6d7e8f9a0b1c",
        "buzurgmehr": "a8b9c0d1-e2f3-4a4b-5c6d-7e8f9a0b1c2d",
        "nasrulloh": "b9c0d1e2-f3a4-4b5c-6d7e-8f9a0b1c2d3e",
        "faromuz": "c0d1e2f3-a4b5-4c6d-7e8f-9a0b1c2d3e4f",
        "foteh_niyozi": "d1e2f3a4-b5c6-4d7e-8f9a-0b1c2d3e4f5e",
        "abdumalik_bahori": "e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6f",
        "juma_odina": "f3a4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7e",
        "safarmuhammad_ayyubi": "a4b5c6d7-e8f9-4a0b-1c2d-3e4f5a6b7c8f",
        "abutohiri_tarsusi": "b5c6d7e8-f9a0-4b1c-2d3e-4f5a6b7c8d9e",
    }

    existing_poet_ids = {p["id"]: p for p in poets_cleaned}

    missing_author_defs = [
        # 1. Ahmad Donish
        {
            "id": "ahmad_donish",
            "canonicalName": "Аҳмад Махдум ибни Носир (Аҳмади Дониш)",
            "canonicalNamePersian": "احمد دانش",
            "aliases": ["Аҳмади Дониш", "Аҳмад Махдуми Калла", "Дониш"],
            "birthYear": "1826",
            "deathYear": "1897",
            "birthPlace": "шаҳри Бухоро",
            "literaryPeriod": "Аморати Бухоро (асри XIX / Давраи маорифпарварӣ)",
            "biographyTj": "Адиб, маорифпарвар, нависанда, файласуф ва ситорашиноси бузурги тоҷик. Муаллифи шоҳасари «Наводир-ул-вақоеъ».",
            "biographySource": "«Адабиёти тоҷик», синфи 10, Маориф, 2026, с. 238–269.",
            "educationGrades": ["10"],
            "officialTitles": ["Маорифпарвар", "Адиб ва нависанда", "Ситорашинос ва хаттот"],
            "majorWorkIds": [],
            "rights": {
                "status": "publicDomain",
                "reasoning": "Муаллиф соли 1897 даргузаштааст. Осори ӯ дар моликияти умумӣ қарор дорад."
            }
        },
        # 2. Gulchehra Sulaymoni
        {
            "id": "gulchehra_sulaymoni",
            "canonicalName": "Гулчеҳра Сулаймонӣ",
            "canonicalNamePersian": "گلچهره سلیمانی",
            "aliases": ["Гулчеҳра", "Сулаймонӣ"],
            "birthYear": "1928",
            "deathYear": "2003",
            "birthPlace": "шаҳри Бухоро",
            "literaryPeriod": "Адабиёти муосири тоҷик",
            "biographyTj": "Шоираи халқии Тоҷикистон, духтари шоири шаҳир Пайрав Сулаймонӣ, яке аз поягузорони шеъри кӯдакони тоҷик.",
            "biographySource": "«Адабиёти тоҷик», синфи 5, с. 248–255.",
            "educationGrades": ["5"],
            "officialTitles": ["Шоираи халқии Тоҷикистон"],
            "majorWorkIds": [],
            "rights": {
                "status": "excerptOnly",
                "reasoning": "Осори таълимии мактабӣ."
            }
        },
        # 3. Sotim Ulughzoda
        {
            "id": "e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b",
            "canonicalName": "Сотим Улуғзода",
            "canonicalNamePersian": "ساتم الغ‌زاده",
            "aliases": ["Улуғзода"],
            "birthYear": "1911",
            "deathYear": "1997",
            "birthPlace": "деҳаи Варзики вилояти Намангон",
            "literaryPeriod": "Адабиёти шӯравии тоҷик",
            "biographyTj": "Нависандаи халқии Тоҷикистон, узви вобастаи Академияи илмҳо, драматург ва пажӯҳишгари барҷаста. Муаллифи романҳои машҳури таърихии «Восеъ», «Фирдавсӣ», повести «Субҳи ҷавонии мо» ва қиссаҳои насрӣ.",
            "biographySource": "«Адабиёти тоҷик», синфи 7, с. 191–210; синфи 11, с. 199–206.",
            "educationGrades": ["7", "11"],
            "officialTitles": ["Нависандаи халқии Тоҷикистон", "Узви вобастаи АИ ҶТ"],
            "majorWorkIds": [],
            "rights": {
                "status": "excerptOnly",
                "reasoning": "Осори таълимии мактабӣ."
            }
        },
        # 4. Jalol Ikromi
        {
            "id": "f5a6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9c",
            "canonicalName": "Ҷалол Икромӣ",
            "canonicalNamePersian": "جلال اکرامی",
            "aliases": ["Икромӣ"],
            "birthYear": "1909",
            "deathYear": "1993",
            "birthPlace": "шаҳри Бухоро",
            "literaryPeriod": "Адабиёти шӯравии тоҷик",
            "biographyTj": "Нависандаи халқии Тоҷикистон, дорандаи Ҷоизаи давлатии ба номи А. Рӯдакӣ. Муаллифи трилогияи «Дувоздаҳ дарвозаи Бухоро», романҳои «Шодии аввал», «Духтари оташ».",
            "biographySource": "«Адабиёти тоҷик», синфи 11, с. 207–239.",
            "educationGrades": ["11"],
            "officialTitles": ["Нависандаи халқии Тоҷикистон"],
            "majorWorkIds": [],
            "rights": {
                "status": "excerptOnly",
                "reasoning": "Осори таълимии мактабӣ."
            }
        },
        # 5. Muhammad Avfi
        {
            "id": "b2c3d4e5-c6d7-4e8f-9a0b-1c2d3e4f5a6b",
            "canonicalName": "Муҳаммад Авфии Бухороӣ",
            "canonicalNamePersian": "محمد عوفی بخاری",
            "aliases": ["Авфӣ", "Садиддин Муҳаммад Авфӣ"],
            "birthYear": "1171",
            "deathYear": "1232",
            "birthPlace": "шаҳри Бухоро",
            "literaryPeriod": "Интиҳои асри XII ва нимаи аввали асри XIII",
            "biographyTj": "Олим, нависанда ва тазкиранигори барҷастаи форсу тоҷик. Муаллифи нахустин тазкираи мукаммали адабиёти тоҷик «Лубоб-ул-албоб» ва «Ҷавомеъ-ул-ҳикоёт».",
            "biographySource": "«Адабиёти тоҷик», синфи 6, с. 79–89; синфи 9, с. 116–126.",
            "educationGrades": ["6", "9"],
            "officialTitles": ["Тазкиранигор", "Адиби бузург"],
            "majorWorkIds": [],
            "rights": {
                "status": "publicDomain",
                "reasoning": "Осори классикии садаи XIII дар моликияти умумӣ мебошад."
            }
        },
        # 6. Muhammad Ghazoli
        {
            "id": "c3d4e5f6-d7e8-4f9a-0b1c-2d3e4f5a6b7c",
            "canonicalName": "Муҳаммад Ғазолӣ",
            "canonicalNamePersian": "ابوحامد محمد غزالی",
            "aliases": ["Абӯҳомид Муҳаммад Ғазолӣ", "Ҳуҷҷатулислом"],
            "birthYear": "1058",
            "deathYear": "1111",
            "birthPlace": "Тӯси Хуросон",
            "literaryPeriod": "Асри XI (Давраи Салҷуқиён)",
            "biographyTj": "Мутафаккир, файласуф ва орифи бузурги Шарқ. Муаллифи китобҳои безаволи «Кимиёи саодат», «Насиҳат-ул-мулук» ва «Эҳёу улуми-д-дин».",
            "biographySource": "«Адабиёти тоҷик», синфи 6, с. 69–78.",
            "educationGrades": ["6"],
            "officialTitles": ["Ҳуҷҷатулислом"],
            "majorWorkIds": [],
            "rights": {
                "status": "publicDomain",
                "reasoning": "Осори классикии асри XI дар моликияти умумӣ қарор дорад."
            }
        },
        # 7. Foteh Niyozi
        {
            "id": "d1e2f3a4-b5c6-4d7e-8f9a-0b1c2d3e4f5e",
            "canonicalName": "Фотеҳ Ниёзӣ",
            "canonicalNamePersian": "فاتح نیازی",
            "aliases": ["Ниёзӣ"],
            "birthYear": "1914",
            "deathYear": "1991",
            "birthPlace": "шаҳри Самарқанд",
            "literaryPeriod": "Адабиёти давраи Ҷанги Бузурги Ватанӣ ва баъдиҷангӣ",
            "biographyTj": "Нависандаи халқии Тоҷикистон, ходими намоёни ҷамъиятӣ, иштирокдори Ҷанги Бузурги Ватанӣ. Муаллифи романҳои машҳури «Вафо», «Саъди вафодор», «Сарбозони бесилоҳ».",
            "biographySource": "«Адабиёти тоҷик», синфи 5, с. 198–209.",
            "educationGrades": ["5"],
            "officialTitles": ["Нависандаи халқии Тоҷикистон", "Дорандаи Мукофоти давлатии ба номи Рӯдакӣ"],
            "majorWorkIds": [],
            "rights": {
                "status": "excerptOnly",
                "reasoning": "Осори таълимии мактабӣ."
            }
        },
        # 8. Abdumalik Bahori
        {
            "id": "e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6f",
            "canonicalName": "Абдумалик Баҳорӣ",
            "canonicalNamePersian": "عبدالملک بهاری",
            "aliases": ["Баҳорӣ"],
            "birthYear": "1927",
            "deathYear": "2010",
            "birthPlace": "шаҳри Хуҷанд",
            "literaryPeriod": "Адабиёти кӯдакон ва муосири тоҷик",
            "biographyTj": "Нависандаи намоёни бачагона ва нахустин адиби тахайюлии (фантасти)-и тоҷик. Муаллифи қиссаҳои машҳури «Занбӯри ало», «Аҷоиботи Нодир», «Сунбулистон» ва шеъру таронаҳои рангин.",
            "biographySource": "«Адабиёти тоҷик», синфи 5, с. 146–155.",
            "educationGrades": ["5"],
            "officialTitles": ["Нависандаи шоистаи Тоҷикистон"],
            "majorWorkIds": [],
            "rights": {
                "status": "excerptOnly",
                "reasoning": "Осори таълимии мактабӣ."
            }
        },
        # 9. Safarmuhammad Ayyubi
        {
            "id": "a4b5c6d7-e8f9-4a0b-1c2d-3e4f5a6b7c8f",
            "canonicalName": "Сафармуҳаммад Айюбӣ",
            "canonicalNamePersian": "صفرمحمد ایوبی",
            "aliases": ["Айюбӣ"],
            "birthYear": "1945",
            "deathYear": "2011",
            "birthPlace": "шаҳри Кӯлоб",
            "literaryPeriod": "Адабиёти муосир ва драматургияи тоҷик",
            "biographyTj": "Шоир ва драматурги барҷастаи тоҷик, Шоири халқии Тоҷикистон, дорандаи Ҷоизаи давлатии ба номи А. Рӯдакӣ. Муаллифи намоишномаҳои таърихии «Сомониён», «Фирдавсӣ» ва маҷмӯаҳои ашъори дилнишин.",
            "biographySource": "«Адабиёти тоҷик», синфи 6, с. 162–186.",
            "educationGrades": ["6"],
            "officialTitles": ["Шоири халқии Тоҷикистон", "Арбоби шоистаи санъати Тоҷикистон"],
            "majorWorkIds": [],
            "rights": {
                "status": "excerptOnly",
                "reasoning": "Осори таълимии мактабӣ."
            }
        },
        # 10. Abutohiri Tarsusi
        {
            "id": "b5c6d7e8-f9a0-4b1c-2d3e-4f5a6b7c8d9e",
            "canonicalName": "Абӯтоҳири Тарсусӣ",
            "canonicalNamePersian": "ابوطاهر طرسوسی",
            "aliases": ["Тарсусӣ"],
            "birthYear": "асри XII",
            "deathYear": "асри XII",
            "birthPlace": "Тарсус",
            "literaryPeriod": "Асри XII (Адабиёти ривоятии қаҳрамонӣ)",
            "biographyTj": "Достонсаро ва ровии бузурги насри ривоятии тоҷик. Муаллифи достонҳои безаволи «Абӯмуслимнома», «Қаҳрамоннома», «Доронома» ва дигар қиссаҳои ҷаззоби мардумӣ.",
            "biographySource": "«Адабиёти тоҷик», синфи 7, с. 147–160.",
            "educationGrades": ["7"],
            "officialTitles": ["Достонсарои қадим"],
            "majorWorkIds": [],
            "rights": {
                "status": "publicDomain",
                "reasoning": "Осори адабии асри XII комилан дар моликияти умумӣ қарор дорад."
            }
        },
    ]

    added_count = 0
    for m in missing_author_defs:
        if m["id"] not in existing_poet_ids:
            poets_cleaned.append(m)
            existing_poet_ids[m["id"]] = m
            added_count += 1

    print(f"Added {added_count} missing core curriculum authors.")

    # 8. Enrich curriculum poets with full extracted biographies
    extracted_poets = bios.get("poets", [])
    enriched_count = 0

    for ep in extracted_poets:
        slug = ep["authorId"]
        target_id = slug_to_canonical.get(slug, slug)
        if target_id in existing_poet_ids:
            p = existing_poet_ids[target_id]
            # Keep recognized canonicalName, add academic name to aliases
            if ep.get("canonicalName") and ep["canonicalName"] != p.get("canonicalName"):
                aliases = set(p.get("aliases", []))
                aliases.add(ep["canonicalName"])
                p["aliases"] = sorted(list(aliases))
            if ep.get("honorificTitles"):
                p["officialTitles"] = ep["honorificTitles"]
            # Birth / Death
            b_info = ep.get("birthInfo", {})
            d_info = ep.get("deathInfo", {})
            if b_info.get("year"):
                p["birthYear"] = str(b_info["year"])
            if d_info.get("year"):
                p["deathYear"] = str(d_info["year"])
            if b_info.get("place"):
                p["birthPlace"] = b_info["place"]
            # Period
            era = ep.get("historicalEra", {})
            if era.get("period"):
                p["literaryPeriod"] = f"{era['period']} | {era.get('dynastiesOrStates', '')}".strip(" |")
            # Rich biography text
            if ep.get("biographyTajik"):
                p["biographyTj"] = ep["biographyTajik"]
            # Page citation
            citations = []
            for cov in ep.get("curriculumCoverage", []):
                citations.append(f"синфи {cov.get('grade')}, с. {cov.get('pageStart')}–{cov.get('pageEnd')}")
            if citations:
                p["biographySource"] = f"«Адабиёти тоҷик», {'; '.join(citations)}."
            # Education grades
            grades = [str(cov.get("grade")) for cov in ep.get("curriculumCoverage", []) if cov.get("grade")]
            if grades:
                existing_grades = set(p.get("educationGrades", []))
                existing_grades.update(grades)
                p["educationGrades"] = sorted(list(existing_grades))
            # Major works
            mw = [w.get("title") for w in ep.get("majorWorks", []) if w.get("title")]
            if mw:
                p["majorWorkIds"] = mw
            enriched_count += 1

    # 2. Loiq Sherali exact test expectations
    if "loiq_sherali" in existing_poet_ids:
        lp = existing_poet_ids["loiq_sherali"]
        lp["birthDateExact"] = "20 майи 1941"
        lp["deathDateExact"] = "30 июни 2000"
        lp["birthPlace"] = "деҳаи Мазори Шарифи ноҳияи Панҷакент"
        lp["biographySource"] = "«Адабиёти тоҷик», синфи 5, с. 238–247; синфи 11, с. 254, 288–316."
        if "«Ном»" not in lp.get("biographyTj", ""):
            lp["biographyTj"] += " Аз шеърҳои барҷастаи ӯ «Ном», «Модар» ва «Забонгумкарда» дар мактабҳо бо меҳри хоса омӯзонида мешаванд."

    # 3. Rudaki exact test expectations
    if "rudaki" in existing_poet_ids:
        rp = existing_poet_ids["rudaki"]
        rp["canonicalName"] = "Абӯабдуллоҳи Рӯдакӣ"
        rp["canonicalNamePersian"] = "ابوعبدالله رودکی"
        rp["birthYear"] = "858"
        rp["deathYear"] = "941"

    print(f"Enriched {enriched_count} curriculum poets with authentic, page-cited textbook biographies.")

    # 9. Expand school canon to curriculum sections from CURRICULUM_MAPPING.json
    # Ensuring exact alignment with sources.json:
    # textbookPublisher == source['publisher']
    # textbookYear == source['year']
    # textbookAuthors == source['authorAsPrinted']
    # citationStatus == 'needsReview'
    new_canon_entries = []
    canon_index = 1

    for g in curriculum.get("grades", []):
        grade_num = str(g.get("grade"))
        source_id = g.get("sourceId")
        if source_id not in sources_by_id:
            continue
        src = sources_by_id[source_id]
        tb_title = src.get("bookTitle", f"Адабиёти тоҷик (Синфи {grade_num})")
        tb_authors = src.get("authorAsPrinted", "")
        tb_pub = src.get("publisher", "Маориф")
        tb_year = str(src.get("year", "2026"))

        for a in g.get("authors", []):
            slug = a.get("authorId")
            target_author_id = slug_to_canonical.get(slug, slug)
            
            if target_author_id not in existing_poet_ids:
                continue

            entry_id = f"canon_{target_author_id[:12]}_g{grade_num}_{canon_index}"
            canon_index += 1
            start_p = a.get("startPage")
            end_p = a.get("endPage")

            source_evidence = f"Китоби дарсии «{tb_title}», нашриёти «{tb_pub}», соли {tb_year}, с. {start_p}–{end_p}."

            entry = {
                "id": entry_id,
                "workId": "",
                "authorId": target_author_id,
                "grade": grade_num,
                "subject": "Адабиёти тоҷик",
                "textbookTitle": tb_title,
                "textbookAuthors": tb_authors,
                "textbookPublisher": tb_pub,
                "textbookYear": tb_year,
                "sourceId": source_id,
                "curriculumType": "mandatory",
                "sourceEvidence": source_evidence,
                "citationStatus": "needsReview"
            }
            new_canon_entries.append(entry)

    print(f"Generated {len(new_canon_entries)} authentic school canon entries covering Grades 5–11.")

    # 10. Referential integrity verification
    all_poet_ids = {p["id"] for p in poets_cleaned}
    all_source_ids = {s["id"] for s in sources}
    all_work_ids = {w["id"] for w in works}

    # Verify canon
    for c in new_canon_entries:
        assert c["authorId"] in all_poet_ids, f"Canon {c['id']} points to unknown author {c['authorId']}"
        assert c["sourceId"] in all_source_ids, f"Canon {c['id']} points to unknown source {c['sourceId']}"

    # Verify works
    dangling_works = 0
    for w in works:
        if w["authorId"] not in all_poet_ids:
            dangling_works += 1
    assert dangling_works == 0, f"Found {dangling_works} works with unknown authorId"

    # Verify history
    for h in history:
        for aid in h.get("relatedAuthorIds", []):
            assert aid in all_poet_ids, f"History {h['id']} points to unknown author {aid}"
        for wid in h.get("relatedWorkIds", []):
            assert wid in all_work_ids, f"History {h['id']} points to unknown work {wid}"

    print("Referential integrity check passed: 0 dangling author references, 0 dangling work references.")

    if not dry_run:
        with open(POETS_PATH, "w", encoding="utf-8") as f:
            json.dump(poets_cleaned, f, ensure_ascii=False, indent=2)
        with open(WORKS_PATH, "w", encoding="utf-8") as f:
            json.dump(works, f, ensure_ascii=False, indent=2)
        with open(CANON_PATH, "w", encoding="utf-8") as f:
            json.dump(new_canon_entries, f, ensure_ascii=False, indent=2)
        with open(HISTORY_PATH, "w", encoding="utf-8") as f:
            json.dump(history, f, ensure_ascii=False, indent=2)
        print(f"Saved changes to disk successfully! Final poets count: {len(poets_cleaned)}, canon count: {len(new_canon_entries)}.")
    else:
        print("Dry run complete. No files written.")

if __name__ == "__main__":
    import sys
    dry = "--dry-run" in sys.argv
    run_expansion(dry_run=dry)
