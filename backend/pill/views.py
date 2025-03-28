from django.shortcuts import render

# Create your views here.
import requests
from django.http import JsonResponse
from rest_framework.response import Response
from .models import *
from .serializer import DrugInfoSerializer

# 공공 API 설정
API_URL = "" # 실제 API URL 입력
API_KEY = "+4kJTquJH+HN8qmc6zWMIsGpgjI7AL0OM6vs0MsRERRBaBflhxYSWXua+qNYpZQijLaKcRRku0Q2jfBrTRXLmw=="  # 발급받은 API 키 입력

def fetch_and_save_data():
    """공공 API에서 데이터를 가져오는 함수"""
    # total = 45530
    # params = {
    #     "serviceKey": API_KEY,
    #     "type": "json",
    #     "numOfRows": 10,  # 100까지 가능
    #     "pageNo": 1 # 100까지 가능
    # }
    # try:
    #     response = requests.get(API_URL, params=params)
    #     response.raise_for_status()
    #     raw_data = response.json()
    #
    #     # API 응답에서 필요한 데이터 추출
    #     items = raw_data.get("body", {}).get("items", [])

    API_URL = "http://apis.data.go.kr/1471000/DrugPrdtPrmsnInfoService06/getDrugPrdtPrmsnDtlInq05"
    # 초기 1회 요청으로 전체 개수 확인
    params_initial = {
        "serviceKey": API_KEY,
        "type": "json",
        "numOfRows": 1,  # 최소한의 요청
        "pageNo": 1
    }
    try:
        response_initial = requests.get(API_URL, params=params_initial)
        response_initial.raise_for_status()
        raw_data_initial = response_initial.json()

        # 총 데이터 개수
        total_count = raw_data_initial.get("body", {}).get("totalCount", 0)
        print("Total count:", total_count)

        # 한 페이지에서 몇 개씩 불러올지
        num_of_rows = 100  # API 허용 범위 내에서 최대값 사용
        total_pages = (total_count // num_of_rows) + 1

        # 반복하며 모든 페이지 데이터를 가져온 뒤 DB 저장
        for page in range(1, total_pages + 1):
            params = {
                "serviceKey": API_KEY,
                "type": "json",
                "numOfRows": num_of_rows,
                "pageNo": page
            }
            response = requests.get(API_URL, params=params)
            response.raise_for_status()

            raw_data = response.json()
            items = raw_data.get("body", {}).get("items", [])

            if not items:
                print(f"데이터가 더 이상 없으므로, 페이지 {page}에서 중단합니다.")
                break

            # 데이터 저장
            for item in items:
                medicine, created = DrugInfo.objects.update_or_create(
                    item_seq=item["ITEM_SEQ"],
                    defaults={
                        "item_name": item["ITEM_NAME"],
                        "entp_name": item["ENTP_NAME"],
                        "consgn_manuf": item.get("CNSGN_MANUF", ""),
                        "etc_otc_code": item["ETC_OTC_CODE"],
                        "chart": item.get("CHART", ""),
                        "bar_code": item.get("BAR_CODE", ""),
                        "material_name": item.get("MATERIAL_NAME", ""),
                        "storage_method": item.get("STORAGE_METHOD", ""),
                        "valid_term": item.get("VALID_TERM", ""),
                        "pack_unit": item.get("PACK_UNIT", ""),
                    }
                )
                if not created:
                    # 기존 데이터가 있으면 업데이트
                    medicine.save()

        return {f"message": "Data saved successfully Total count: {total_count}"}
    except requests.exceptions.RequestException as e:
        return {"error": str(e)}

def drug_appearance_fetch():
    params_initial = {
        "serviceKey": API_KEY,
        "type": "json",
        "numOfRows": 1,  # 최소한의 요청
        "pageNo": 1
    }
    API_URL = "http://apis.data.go.kr/1471000/MdcinGrnIdntfcInfoService01/getMdcinGrnIdntfcInfoList01"
    try:
        response_initial = requests.get(API_URL, params=params_initial)
        response_initial.raise_for_status()
        raw_data_initial = response_initial.json()

        # 총 데이터 개수
        total_count = raw_data_initial.get("body", {}).get("totalCount", 0)
        print("Total count:", total_count)

        # 한 페이지에서 몇 개씩 불러올지
        num_of_rows = 300  # API 허용 범위 내에서 최대값 사용
        total_pages = (total_count // num_of_rows) + 1

        # 반복하며 모든 페이지 데이터를 가져온 뒤 DB 저장
        for page in range(1, total_pages + 1):
            params = {
                "serviceKey": API_KEY,
                "type": "json",
                "numOfRows": num_of_rows,
                "pageNo": page
            }
            response = requests.get(API_URL, params=params)
            response.raise_for_status()

            raw_data = response.json()
            items = raw_data.get("body", {}).get("items", [])

            if not items:
                print(f"데이터가 더 이상 없으므로, 페이지 {page}에서 중단합니다.")
                break

            # 데이터 저장
            for item in items:
                medicine, created = Appearance.objects.update_or_create(
                    item_seq=item["ITEM_SEQ"],
                    defaults={
                        "item_name": item["ITEM_NAME"],
                        "entp_name": item["ENTP_NAME"],
                        "chart": item.get("CHART", ""),
                        "item_image": item.get("ITEM_IMAGE", ""),
                        "print_front": item.get("PRINT_FRONT", ""),
                        "print_back": item.get("PRINT_BACK", ""),
                        "drug_shape": item.get("DRUG_SHAPE", ""),
                        "color_class1": item.get("COLOR_CLASS1", ""),
                        "color_class2": item.get("COLOR_CLASS2", ""),
                        "line_front": item.get("LINE_FRONT", ""),
                        "line_back": item.get("LINE_BACK", ""),
                        "leng_long": item.get("LENG_LONG", ""),
                        "leng_short": item.get("LENG_SHORT", ""),
                        "thick": item.get("THICKT", ""),
                        "img_regist_ts": item.get("IMG_REGISTR_TS", ""),
                        "item_permit_date": item.get("ITEM_PERMIT_DATE", ""),
                        "form_code_name": item.get("FROM_CODE_NAME", ""),
                        "mark_code_front_anal": item.get("MARK_CODE_FRONT_ANAL", ""),
                        "mark_code_back_anal": item.get("MARK_CODE_BACK_ANAL", ""),
                        "mark_code_front_img": item.get("MARK_CODE_FRONT_IMG", ""),
                        "mark_code_back_img": item.get("MARK_CODE_BACK_IMG", ""),
                        "item_eng_name": item.get("ITEM_ENG_NAME", ""),
                        "change_date": item.get("CHANGE_DATE", ""),
                        "mark_code_front": item.get("MARK_CODE_FRONT", ""),
                        "mark_code_back": item.get("MARK_CODE_BACK", ""),
                        "edi_code": item.get("EDI_CODE", ""),
                        "bizrno": item.get("BIZRNO", ""),
                    }
                )
                if not created:
                    # 기존 데이터가 있으면 업데이트
                    medicine.save()

        return {f"message": "Data saved successfully Total count: {total_count}"}
    except requests.exceptions.RequestException as e:
        return {"error": str(e)}

# API 엔드포인트
def fetch_data(request):
    """DB에 저장"""
    data = fetch_and_save_data()
    return JsonResponse(data, json_dumps_params={"indent": 4, "ensure_ascii": False})

def get_medicine_data(request):
    """DB에 저장된 의약품 데이터를 반환하는 API"""
    medicines = DrugInfo.objects.all().values(
        "item_seq", "item_name", "entp_name", "consgn_manuf",
        "etc_otc_code", "chart", "bar_code", "material_name",
        "storage_method", "valid_term", "pack_unit", "created_at"
    )
    return JsonResponse({"data": list(medicines)}, json_dumps_params={"indent": 4, "ensure_ascii": False})

def fetch_pill_appearance_data(request):
    data = drug_appearance_fetch()
    return JsonResponse(data, json_dumps_params={"indent": 4, "ensure_ascii": False})

def get_pill_appearance_data(request):
    pill_appearances = Appearance.objects.all().values(
        "item_seq", "item_name", "entp_name", "chart", "item_image", "print_front",
        "print_back", "drug_shape", "color_class1", "color_class2", "line_front", "line_back",
        "leng_long", "leng_short", "thick", "img_regist_ts", "item_permit_date",
        "form_code_name", "mark_code_front_anal", "mark_code_back_anal", "mark_code_front_img",
        "mark_code_back_img", "item_eng_name", "change_date", "mark_code_front",
        "mark_code_back", "edi_code", "bizrno")
    return JsonResponse({"data": list(pill_appearances)}, json_dumps_params={"indent": 4, "ensure_ascii": False})