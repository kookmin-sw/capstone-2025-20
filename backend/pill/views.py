from typing import Any
from django.shortcuts import render

import requests
from django.http import JsonResponse
from django.views.decorators.http import require_GET
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import *
from .serializer import DrugInfoSerializer
from urllib.parse import urlencode


# 공공 API 설정
API_URL = ""
API_KEY = "+4kJTquJH+HN8qmc6zWMIsGpgjI7AL0OM6vs0MsRERRBaBflhxYSWXua+qNYpZQijLaKcRRku0Q2jfBrTRXLmw=="  # 발급받은 API 키 입력

def fetch_and_save_data():
    """공공 API에서 데이터를 가져오는 함수"""
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
                        "ee_doc_id": item.get("EE_DOC_ID", ""),
                        "ud_doc_id": item.get("UD_DOC_ID", ""),
                        "nb_doc_id": item.get("NB_DOC_ID", ""),
                        "storage_method": item.get("STORAGE_METHOD", ""),
                        "valid_term": item.get("VALID_TERM", ""),
                        "pack_unit": item.get("PACK_UNIT", ""),
                        "ee_doc_data": item.get("EE_DOC_DATA", ""),
                        "ud_doc_data": item.get("UD_DOC_DATA", ""),
                        "nb_doc_data": item.get("NB_DOC_DATA", ""),
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

def get_drug_contraindications(serviceKey: str,
                               itemSeq: str,
                               pageNo: int = 1,
                               numOfRows: int = 100,
                               response_type: str = "json") -> dict:
    """
    병용금기(OpenAPI)로부터 특정 의약품(ItemSeq)과 병용이 불가능한 약에 대한 정보를 가져오는 함수
    :param serviceKey: OpenAPI 인증키(디코딩된 일반 문자열 형태)
    :param pageNo: 페이지 번호
    :param numOfRows: 한 페이지 결과 수
    :param response_type: 응답 형식 (ex. xml, json)
    :param itemSeq: 조회할 의약품 식별 번호
    :return: 병용금기 정보가 담긴 딕셔너리(또는 XML을 파싱한 결과)
    """

    # 실제 요청할 OpenAPI URL (예시: DUR 병용금기 정보)
    # 서비스별로 base_url과 endpoint가 달라질 수 있으므로, 실제 URL 확인 필요
    base_url = "apis.data.go.kr/1471000/DURPrdlstInfoService03/getDurPrdlstInfoList3"

    # 요청 파라미터 설정
    params = {
        "serviceKey": API_KEY,  # API 인증키
        "itemSeq": itemSeq,  # 조회할 의약품 식별 번호
        "pageNo": pageNo,  # 페이지 번호
        "numOfRows": numOfRows,  # 한 페이지 결과 수
        "type": response_type,  # 응답 형식
    }

    # GET 요청 보내기
    # url에 직접 파라미터를 붙여도 되지만, urllib.parse의 urlencode로 구성하면 가독성이 높음
    request_url = f"{base_url}?{urlencode(params)}"

    try:
        response = requests.get(request_url, timeout=10)
        response.raise_for_status()  # 상태 코드가 4xx, 5xx인 경우 예외 발생

        # 응답 형식(json/xml)에 따라 파싱 로직을 달리 적용
        if response_type.lower() == "json":
            return response.json()
        else:
            # XML로 넘어올 경우, 별도의 파싱 로직 필요 (예: xml.etree.ElementTree 등)
            return {"raw_data": response.text}

    except requests.exceptions.RequestException as e:
        print(f"[Error] 병용금기 정보 조회 중 오류가 발생했습니다: {e}")
        return {}

def get_all_contraindications(serviceKey: str, itemSeq: str) -> list:
    """
    페이지네이션을 고려하여 해당 의약품(itemSeq)의 병용금기 정보를 모두 가져오는 함수.
    :param serviceKey: OpenAPI 인증키
    :param itemSeq: 병용금기 정보를 조회할 의약품 식별 번호(A 약)
    :return: (list) 병용금기 정보의 items 전체 리스트
    """

    first_page_data = get_drug_contraindications(
        serviceKey=serviceKey,
        itemSeq=itemSeq,
        pageNo=1,
        numOfRows=100,
        response_type="json"
    )

    body = first_page_data.get("body", {})
    total_count = body.get("totalCount", 0)
    first_items = body.get("items", [])

    # total_count가 0이면 데이터가 없음을 의미
    if not total_count:
        return []

    # 총 페이지 수 계산
    total_pages = (total_count // 100) + (1 if total_count % 100 != 0 else 0)

    # 첫 페이지의 items는 이미 확보했으므로 all_items에 담음
    all_items = []

    if first_items:
        all_items.extend(first_items)

    # 두 번째 페이지부터 마지막 페이지까지 반복 조회
    for page_no in range(2, total_pages + 1):
        page_data = get_drug_contraindications(
            serviceKey=serviceKey,
            itemSeq=itemSeq,
            pageNo=page_no,
            numOfRows=100,
            response_type="json"
        )

        items = page_data.get("body", {}).get("items", [])
        if items:
            all_items.extend(items)

    return all_items

def check_coadministration_info(serviceKey: str, itemSeqA: str, itemSeqB: str) -> dict:
    """
    A 약(itemSeqA)과 B 약(itemSeqB)을 함께 복용해도 되는지 확인하는 함수.

    :param serviceKey: OpenAPI 인증키
    :param itemSeqA: 병용금기 정보를 조회할 의약품(A 약) 식별 번호
    :param itemSeqB: 함께 복용할 B 약 식별 번호
    :return: True(함께 복용 가능), False(병용금기)
    """

    # A 약에 대한 병용금기 모든 리스트 조회
    all_items = get_all_contraindications(serviceKey, itemSeqA)

    # 항목을 순회하며 B 약이 병용금기인지 확인
    for item in all_items:
        mixture_seq = item.get("MIXTURE_ITEM_SEQ", "")
        if mixture_seq == itemSeqB:
            # 병용금기 대상 발견 시, 해당 사유(PROHBT_CONTENT) 함께 반환
            reason = item.get("PROHBT_CONTENT", "사유 정보 없음")
            return {
                "coadministration_ok": False,
                "reason": reason
            }

    # 끝까지 못 찾았다면 병용금기 대상 아님
    return {
        "coadministration_ok": True,
        "reason": None
    }

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

@require_GET
def get_drug_info_by_seq(request, item_seq):
    """
    GET 파라미터로 넘어온 PK(item_seq)를 이용해 DB 조회
    예: /get-drug-info-by-seq/?itemSeq=ABC12345
    """
    item_seq = request.GET.get('itemSeq')

    if not item_seq:
        return JsonResponse({"error": "PK(item_seq) 값이 전달되지 않았습니다."}, status=400)

    try:
        # item_seq를 PK로 지정했으므로, pk=item_seq로 조회
        drug = DrugInfo.objects.get(pk=item_seq)
    except DrugInfo.DoesNotExist:
        return JsonResponse({"error": f"'{item_seq}'에 해당하는 의약품을 찾을 수 없습니다."}, status=404)

    data = {
        "itemSeq": drug.item_seq,
        "itemName": drug.item_name,
        "entp_name": drug.entp_name,
        "etc_otc_code": drug.etc_otc_code,
        "chart": drug.chart,
        "storage_method": drug.storage_method,
        "valid_term": drug.valid_term,
        "ee_doc_data": drug.ee_doc_data,
        "ud_doc_data": drug.ud_doc_data,
        "nb_doc_data": drug.nb_doc_data
    }
    return JsonResponse(data, json_dumps_params={'ensure_ascii': False})



@require_GET
def get_drug_info_by_name(request):
    """
    프론트엔드에서 'item_name'이라는 쿼리 파라미터로 의약품 이름을 넘겨주면,
    DB에서 해당 이름의  정보를 조회하여 JSON으로 반환.
    """
    medicine_name = request.GET.get('item_name', '')

    if not medicine_name:
        return JsonResponse({"error": "의약품 이름이 전달되지 않았습니다."}, status=400)

    matched_drugs = DrugInfo.objects.filter(item_name__icontains=medicine_name)
    if not matched_drugs.exists():
        return JsonResponse({"error": f"'{medicine_name}'이(가) 포함된 의약품을 찾을 수 없습니다."}, status=404)

    # 여러 건이 검색될 수 있으므로 리스트 형태로 데이터 구성

    result_list = []
    for drug in matched_drugs:
        result_list.append({
            "itemSeq": drug.item_seq,
            "itemName": drug.item_name,
            "entp_name": drug.entp_name,
            "etc_otc_code": drug.etc_otc_code,
            "chart": drug.chart,
            "storage_method": drug.storage_method,
            "valid_term": drug.valid_term,
            "ee_doc_data": drug.ee_doc_data,
            "ud_doc_data": drug.ud_doc_data,
            "nb_doc_data": drug.nb_doc_data
        })

    return JsonResponse(result_list, safe=False, json_dumps_params={'ensure_ascii': False})

# if __name__ == "__main__":
#     SERVICE_KEY = "+4kJTquJH+HN8qmc6zWMIsGpgjI7AL0OM6vs0MsRERRBaBflhxYSWXua+qNYpZQijLaKcRRku0Q2jfBrTRXLmw=="
#     A_ITEM_SEQ = "201405281"
#     B_ITEM_SEQ = "200402617",
#
#     result_data = check_coadministration_info(SERVICE_KEY, A_ITEM_SEQ, B_ITEM_SEQ)
#     if result_data["coadministration_ok"]:
#         print(f"{A_ITEM_SEQ}와(과) {B_ITEM_SEQ}는 함께 복용 가능합니다.")
#     else:
#         print(f"{A_ITEM_SEQ}와(과) {B_ITEM_SEQ}는 병용금기 대상입니다.")
#         print(f"사유: {result_data['reason']}")
