#!/usr/bin/env python3
"""
Author ID mapping: CURRICULUM_MAPPING IDs -> poets.json IDs
"""

# Maps CURRICULUM_MAPPING authorId to poets.json id
AUTHOR_ID_FIX = {
    # G5
    'rudaki': 'rudaki',
    'robia_balkhi': '3d5d70c0-6294-4b7d-b830-79db08edd6b8',
    'ibn_sino': '1a55efdd-6a1f-43b8-834f-94af060b4329',
    'abdulloh_ansori': 'a4b182d3-1c06-4c82-9858-0e71d95edeb3',
    'nizomulmulk': '42d303b5-f20f-440d-8079-a8e25ef52d2e',
    'ahmadi_jomi': '9ab32712-ce1d-4054-a7cc-163ca4a8f11f',
    'attor': 'c9ea2574-7623-4974-ada0-49c075b2831b',
    'saadi': '3ec91317-fcfe-4960-9ca0-fd87f3e96875',
    'binoi': 'ef0f434c-c5a7-4cdd-b13a-35f999319fbf',
    'hiloli': 'f09073cb-33b4-4fcc-abf8-75959350245c',
    'ayni': '47c1dc67-363a-4506-8a9c-bbbb38f98d20',
    'tursunzoda': 'tursunzoda',
    'eraj_mirzo': '10a9ad7d-fd0d-462f-8cb4-594a869f8229',  # Need to check
    'khalilullohi_khalili': 'fd212071-6a30-4b8d-870a-ae784002e8f2',
    'foteh_niyozi': 'd1e2f3a4-b5c6-4d7e-8f9a-0b1c2d3e4f5e',
    'mirsaid_mirshakar': 'a7feaa09-c83f-44f2-a69e-0a46ba957dbc',
    'gulnazar_keldi': 'gulnazar_keldi',
    'abdumalik_bahori': 'e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6f',
    'ghaffor_mirzo': '400b9785-ae80-4957-a653-d65c72cdbf79',  # Need to check

    # G6
    'kaykovus': '92753b88-1d31-4f79-aae4-5d36c83ab4a1',
    'farrukhi': '282f4c69-1d14-4be2-89d3-d21f867e4964',
    'nizomi_ganjavi': 'd5abab06-07e9-4247-b8a8-f4801b6a5be4',
    'ghazoli': 'c3d4e5f6-d7e8-4f9a-0b1c-2d3e4f5a6b7c',
    'sayfi_farghoni': 'cfb751a8-dce3-4553-aef8-bc4574b2b85e',
    'avfi': 'b2c3d4e5-c6d7-4e8f-9a0b-1c2d3e4f5a6b',
    'nakhshabi': 'ec41abdc-c530-4745-825f-a23cd7515ca5',
    'ibn_yamin': '5ec16ef0-b9c8-44e1-a6fc-4a01ee3f7def',
    'hafiz': 'd1abb54a-9804-4baf-b238-fd2203d7673e',
    'nosiri_bukhoroi': '337370dd-7731-490b-9e92-b7f9be6ba695',
    'vosifi': '7c389f92-ffdc-4f8e-b901-1de71acc34a9',
    'shavkari_bukhoroi': '465d3f4a-4924-4ca6-9371-7266ae4393c7',
    'nozimi_hiroti': '22097ef5-9ab2-4b03-a971-e62927f2f8c8',
    'ahmadi_donish': 'ahmad_donish',
    'lohuti': '310a8288-d554-4b9c-9ad1-3273b1edce85',
    'qanoat': 'qanoat',
    'juma_odina': 'juma_odina',  # Need to check
    'safarmuhammad_ayyubi': 'a4b5c6d7-e8f9-4a0b-1c2d-3e4f5a6b7c8f',

    # G7
    'abutohiri_tarsusi': 'b5c6d7e8-f9a0-4b1c-2d3e-4f5a6b7c8d9e',
    'firdawsi': 'a6dd1c54-753d-4a52-8e5b-5365b7908aa3',
    'zahiri_samarqandi': 'ada69601-01d5-493f-b1a0-9b886be8daa8',
    'nizomi_aruzi': '6b080d51-336b-48ba-92cd-85fe29149e0d',
    'masudi_sadi_salmon': '8c4f8cd7-4ae4-445c-b79b-bd10a6f83b65',
    'rumi': '0b0f1032-b36a-45e4-9930-8953b067db65',
    'ubaydi_zokoni': '0e91d643-d947-4f0d-b3ac-ec2715a4b87c',
    'kamoli_khujandi': 'kamol_khujandi',
    'jomi': '9debff75-8664-43ab-a7a9-ed1a4725f69b',
    'koshifi': 'ea87e35a-6a03-44f2-837e-648d1c84aecc',
    'samandar_tirmizi': '06b70024-a028-43dd-8c23-cdb75e96fac8',
    'sayyido': '5633556b-df45-4cab-83dc-760016db1ef2',
    'ulughzoda': 'e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b',
    'habib_yusufi': '26c985a4-88ca-47ea-8981-ba5529b62a7c',
    'boqi_rahimzoda': 'eff956d5-9b8c-4522-9ac6-8791f15495ce',
    'muhiddin_aminzoda': '12fb0e82-f108-4e71-8207-74d0540639d3',
    'muhammadiyev': 'a74ea72d-864f-4c25-b42e-95435794a42d',
    'shukuhi': '65bd67be-a18d-4679-8721-cd13818933b1',
    'loiq': 'loiq_sherali',

    # G8
    'buzurgmehr': 'buzurgmehr',
    'daqiqi': 'b0133115-7ead-4ec8-bc6d-115f4540bdb2',
    'bobotohir': 'be19709e-c3af-460d-80b9-4c67046e8be3',
    'asadii_tusi': '8231eb1a-ac35-46d2-9e39-19d5603bfcec',
    'nosiri_khusrav': 'nasir_khusraw',
    'khayyam': '5fc69b51-c38a-4427-a362-5c8a14bca835',
    'sanoi': '94d5f5e3-f9a6-4c3d-bd1b-a72f97a7e06e',
    'nasrulloh': 'nasrulloh',
    'faromuz': 'faromuz',
    'anvari': '7281c3ee-3fe9-4450-9b10-33d0d52f34e5',
    'khoqoni': 'e8ec4440-682a-48f1-ba59-54d8a9595c16',

    # G9
    'amir_khusrav': '7c8e3b4f-d27f-4bb1-9b7c-a2ea436b5482',
    'navoi': '228feecd-8a97-4aaf-9b92-b9896c3a7d7d',

    # G10
    'mushfiqi': '92a7c4fa-3191-4301-ba53-8087ce7ef3d8',
    'soib_tabrezi': '121ce628-ff4b-44d2-a702-81db93040dee',
    'bedil': '455f0420-3834-48f0-86b9-7da673a2a684',
    'mirzosodiq': 'mirzosodiq',
    'hoziq': 'hoziq',
    'gulkhani': 'gulkhani',
    'qooni': 'qooni',
    'savdo': 'savdo',
    'shamsuddini_shohin': '6ab9cd0a-0ff0-4a73-99ba-6604d9c61847',
    'hayrat': '604d62c2-62fc-4aa3-a7d2-8348e714b52d',
    'vozeh': 'vozeh',

    # G11
    'tughral': '43004ccf-0d32-463c-aad5-b6aaec73fbb4',
    'asiri': '2e7a713f-c3d2-449e-bd6a-a4b5b7350201',
    'kangurti': 'kangurti',
    'payrav_sulaymoni': 'e859c1ae-03b9-4add-8079-7fa5bcf64ef7',
    'ikromi': 'f5a6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9c',
    'rahim_jalil': 'ef5a57a2-8949-43dd-85eb-8ceaf78335f3',
    'sattor_tursun': 'sattor_tursun',
    'mehmon_bakhti': 'mehmon_bakhti',
    'abdulhamid_samad': 'abdulhamid_samad',
    'karomatullohi_mirzo': 'karomatullohi_mirzo',
    'sayf_rahimzod': 'sayf_rahimzod',
}

if __name__ == '__main__':
    import json
    from pathlib import Path

    ROOT = Path('/Users/m.a/Desktop/work/zarbulmasal')
    with open(ROOT / 'assets/data/literature/poets.json') as f:
        poets = json.load(f)

    valid_ids = {p['id'] for p in poets}

    print('Checking AUTHOR_ID_FIX...')
    invalid = []
    for k, v in AUTHOR_ID_FIX.items():
        if v not in valid_ids:
            print(f'  INVALID: {k} -> {v}')
            invalid.append((k, v))

    print(f'\nTotal mappings: {len(AUTHOR_ID_FIX)}')
    print(f'Valid: {len(AUTHOR_ID_FIX) - len(invalid)}')
    print(f'Invalid: {len(invalid)}')
