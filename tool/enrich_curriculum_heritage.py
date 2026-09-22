import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
POETS_PATH = ROOT / "assets/data/literature/poets.json"
WORKS_PATH = ROOT / "assets/data/literature/works.json"
CANON_PATH = ROOT / "assets/data/literature/school_canon.json"
HISTORY_PATH = ROOT / "assets/data/history/entries.json"
CURRICULUM_MAP_PATH = ROOT / "docs/literature/CURRICULUM_MAPPING.json"

def run_enrichment(dry_run=True):
    with open(POETS_PATH, "r", encoding="utf-8") as f:
        poets = json.load(f)
    with open(WORKS_PATH, "r", encoding="utf-8") as f:
        works = json.load(f)
    with open(CANON_PATH, "r", encoding="utf-8") as f:
        canon = json.load(f)
    with open(HISTORY_PATH, "r", encoding="utf-8") as f:
        history = json.load(f)
    with open(CURRICULUM_MAP_PATH, "r", encoding="utf-8") as f:
        curriculum = json.load(f)

    print(f"Initial state: {len(poets)} poets, {len(works)} works, {len(canon)} canon entries, {len(history)} history entries.")

    # 1. Deduplication pairs (remove_id -> keep_id)
    merge_map = {
        "ac759bd8-fe4e-4ef3-9e2f-30226a014707": "a6dd1c54-753d-4a52-8e5b-5365b7908aa3", # Firdawsi
        "b5252e27-e6c6-401e-aca9-5fec3da36b65": "a6dd1c54-753d-4a52-8e5b-5365b7908aa3",
        "afc28bbb-ebba-4669-9715-a10cbbe7400a": "a6dd1c54-753d-4a52-8e5b-5365b7908aa3",
        "6e223a11-a2df-4298-bb14-2911af2da37d": "1a55efdd-6a1f-43b8-834f-94af060b4329", # Ibn Sina
        "732f0989-b849-4856-a0dd-ba2f64f1c9a0": "92753b88-1d31-4f79-aae4-5d36c83ab4a1", # Kaykovus
        "5ff997ff-991d-4d18-ba6e-8acaa7a15058": "8231eb1a-ac35-46d2-9e39-19d5603bfcec", # Asadii Tusi
        "ab679c6b-ce9a-4e85-bf3b-81a8bed84623": "be19709e-c3af-460d-80b9-4c67046e8be3", # Bobotohir
        "a0edb1e9-51b5-4ad1-ad0a-5d8af6a6a6da": "9debff75-8664-43ab-a7a9-ed1a4725f69b", # Jami
        "358dda13-365c-4434-87f0-d404b305adcb": "9debff75-8664-43ab-a7a9-ed1a4725f69b",
        "17559ef6-4071-495f-b966-e5be3b33d3a3": "7281c3ee-3fe9-4450-9b10-33d0d52f34e5", # Anvari
        "e948618d-0c4c-484b-b60b-c1658bc51d57": "b0133115-7ead-4ec8-bc6d-115f4540bdb2", # Daqiqi
        "da5e2975-a8e2-44ce-a30c-0e5d98f73844": "b0133115-7ead-4ec8-bc6d-115f4540bdb2",
        "44aaf1c8-ce97-4cd1-a21f-7de5db7c615d": "47c1dc67-363a-4506-8a9c-bbbb38f98d20", # Ayni
        "650312c1-094f-4cd9-9313-efe38bdbef0f": "282f4c69-1d14-4be2-89d3-d21f867e4964", # Farrukhi
        "da1e1d82-ceeb-4a9e-9e42-251b9b05d20c": "d1abb54a-9804-4baf-b238-fd2203d7673e", # Hafiz
        "0a3d3ab5-3edd-4075-b382-7d16a25bdf71": "455f0420-3834-48f0-86b9-7da673a2a684", # Bedil
        "74ea3b93-4c65-4605-95a7-8c2ec4c382cc": "310a8288-d554-4b9c-9ad1-3273b1edce85", # Lohuti
        "32624545-f720-4267-9669-d3648b7369ac": "310a8288-d554-4b9c-9ad1-3273b1edce85",
        "b299ac33-ad0c-4e9e-8bb3-aabfd19b8126": "c9ea2574-7623-4974-ada0-49c075b2831b", # Attor
        "7b8bcd3c-a1fa-4b9d-9378-76684d2495b0": "c9ea2574-7623-4974-ada0-49c075b2831b",
        "c4ed06c1-4e72-485e-bde4-8f1c06e969db": "3d5d70c0-6294-4b7d-b830-79db08edd6b8", # Robia Balkhi
        "8e7316a8-5101-4fd2-8a83-0a883a8da9fb": "121ce628-ff4b-44d2-a702-81db93040dee", # Soib
        "84e67a80-5859-48f9-a533-a1f999cb2939": "465d3f4a-4924-4ca6-9371-7266ae4393c7", # Shavkat
    }

    # Re-point works authorId
    redirected_works = 0
    for w in works:
        old_aid = w.get("authorId")
        if old_aid in merge_map:
            w["authorId"] = merge_map[old_aid]
            redirected_works += 1

    # Re-point canon authorId
    redirected_canon = 0
    for c in canon:
        old_aid = c.get("authorId")
        if old_aid in merge_map:
            c["authorId"] = merge_map[old_aid]
            redirected_canon += 1

    # Re-point history relatedAuthorIds
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

    print(f"Redirected references: {redirected_works} works, {redirected_canon} canon, {redirected_history} history.")

    # Merge poet aliases and metadata from removed into kept
    poet_dict = {p["id"]: p for p in poets}
    for rem_id, keep_id in merge_map.items():
        if rem_id in poet_dict and keep_id in poet_dict:
            rem_p = poet_dict[rem_id]
            keep_p = poet_dict[keep_id]
            # Add alias
            aliases = set(keep_p.get("aliases", []))
            aliases.add(rem_p["canonicalName"])
            for a in rem_p.get("aliases", []):
                aliases.add(a)
            keep_p["aliases"] = sorted(list(aliases))
            # Merge grades if any
            grades = set(keep_p.get("educationGrades", []))
            for g in rem_p.get("educationGrades", []):
                grades.add(g)
            keep_p["educationGrades"] = sorted(list(grades))

    # Filter out removed poets
    new_poets = [p for p in poets if p["id"] not in merge_map]
    print(f"Deduplicated poets: {len(poets)} -> {len(new_poets)} (removed {len(merge_map)} duplicate records).")

    return new_poets, works, canon, history

if __name__ == "__main__":
    run_enrichment(dry_run=True)
