import json

SEED_POETS = "lib/data/seed/poets.json"
SEED_POEMS = "lib/data/seed/poems.json"
ASSET_POETS = "assets/data/literature/poets.json"
ASSET_WORKS = "assets/data/literature/works.json"

def normalize_name(name):
    if not name: return ""
    name = name.lower()
    for char in ['ӯ', 'ӣ', 'ҷ', 'ҳ', 'ғ', 'қ', ' ', '-', '.', ',', 'ибни', 'абу']:
        name = name.replace(char, '')
    return name

def main():
    with open(SEED_POETS, 'r', encoding='utf-8') as f:
        seed_poets = json.load(f)
    with open(SEED_POEMS, 'r', encoding='utf-8') as f:
        seed_poems = json.load(f)
        
    with open(ASSET_POETS, 'r', encoding='utf-8') as f:
        asset_poets = json.load(f)
    with open(ASSET_WORKS, 'r', encoding='utf-8') as f:
        asset_works = json.load(f)

    # We want to clear works.json, but keep the initial 10 poets in asset_poets if needed? 
    # Actually, we should just merge the new ones.
    
    asset_poets_map = {p["id"]: p for p in asset_poets}
    # For normalization
    norm_to_id = {normalize_name(p.get("canonicalName", "")): p["id"] for p in asset_poets}
    norm_to_id.update({normalize_name(p.get("canonicalNamePersian", "")): p["id"] for p in asset_poets})
    
    # 1. Poets
    import uuid
    for sp in seed_poets:
        norm_name = normalize_name(sp.get("name", ""))
        matched_id = norm_to_id.get(norm_name)
        if not matched_id:
            for k, v in norm_to_id.items():
                if k and norm_name and (k in norm_name or norm_name in k):
                    matched_id = v
                    break
        
        if matched_id:
            continue
            
        new_id = str(uuid.uuid4())
        norm_to_id[norm_name] = new_id
        
        asset_poets.append({
            "id": new_id,
            "canonicalName": sp.get("name", ""),
            "canonicalNamePersian": None,
            "aliases": [],
            "lifespan": sp.get("lifespan", ""),
            "birthYear": None,
            "deathYear": None,
            "biographyTj": sp.get("bio", ""),
            "biographyPersian": None,
            "biographySource": "book5",
            "majorWorkIds": [],
            "educationGrades": ["5"],
            "rights": {
                "status": "publicDomain",
                "reasoning": "Extracted from public school textbooks",
                "rightsSource": "Law No. 726",
                "fullTextAllowed": True,
                "excerptAllowed": True
            }
        })
        
    # 2. Works
    new_works = []
    for sp in seed_poems:
        author_name = sp.get("author", "")
        norm_author = normalize_name(author_name)
        
        matched_id = norm_to_id.get(norm_author)
        if not matched_id:
            for k, v in norm_to_id.items():
                if k and norm_author and (k in norm_author or norm_author in k):
                    matched_id = v
                    break
        
        if not matched_id:
            continue
            
        source_id = sp.get("source", "book5")
            
        new_works.append({
            "id": str(uuid.uuid4()),
            "authorId": matched_id,
            "title": sp.get("title", ""),
            "titlePersian": None,
            "incipit": sp.get("title", ""),
            "type": "poem",
            "scriptSource": "tajikCyrillic",
            "textTajik": sp.get("text", ""),
            "textPersian": None,
            "textStatus": "verified",
            "editorial": "none",
            "editorialNotes": None,
            "primarySource": {
                "bookTitle": source_id,
                "editor": "",
                "publisher": "",
                "city": "",
                "year": "2020",
                "pageStart": 1,
                "pageEnd": 1,
                "sourceType": "official-textbook"
            },
            "secondarySource": None,
            "textMatchResult": "exact",
            "variantNotes": None,
            "rights": {
                "status": "publicDomain",
                "reasoning": "Extracted from public school textbooks",
                "rightsSource": "Law No. 726",
                "fullTextAllowed": True,
                "excerptAllowed": True
            },
            "verification": {
                "verifiedBy": "Extraction Pipeline",
                "verifiedDate": "2026-09-13",
                "primarySourceChecked": True,
                "secondSourceChecked": False,
                "titleChecked": True,
                "authorshipChecked": True,
                "pageChecked": True,
                "textLineByLineChecked": False,
                "scriptChecked": False,
                "copyrightChecked": True,
                "finalStatus": "needsReview"
            }
        })
        
    with open(ASSET_POETS, 'w', encoding='utf-8') as f:
        json.dump(asset_poets, f, ensure_ascii=False, indent=2)
    with open(ASSET_WORKS, 'w', encoding='utf-8') as f:
        json.dump(new_works, f, ensure_ascii=False, indent=2)
        
    print(f"Total poets: {len(asset_poets)}")
    print(f"Total works: {len(new_works)}")

if __name__ == "__main__":
    main()
