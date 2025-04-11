from typing import Any
from django.shortcuts import render

import logging
import requests
from django.http import JsonResponse
# from django.views.decorators.http import require_GET
from django.db import transaction
from django.db.models import Q
from django.db.models import Prefetch
from django.views import View
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.pagination import PageNumberPagination
from rest_framework import status
from .models import *
from .serializers import *

class FetchAndSaveDrugDataView(APIView):
    """
    공공 API로부터 데이터를 가져와 DB에 저장하는 기능
    """

    API_URL = "http://apis.data.go.kr/1471000/DrugPrdtPrmsnInfoService06/getDrugPrdtPrmsnDtlInq05"
    API_KEY =

    def get(self, request):
        """
        GET 요청 시 공공 API에서 데이터 fetch
        """
        total_saved_count = 0
        page_no = 1
        num_of_rows = 100  # 한 페이지에서 가져올 데이터 수
        is_last_page = False  # 마지막 페이지 여부 확인

        while not is_last_page:
            # 1. 페이지 데이터를 가져옴
            response_data = self.fetch_page_data(page_no, num_of_rows)
            if response_data is None:
                return Response(
                    {"error": f"{page_no} 페이지 데이터 가져오기 실패"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

            # 2. 해당 페이지 데이터 저장
            items = response_data.get("body", {}).get("items", [])
            print(f"Info List (Page {page_no}): {len(items)}개")
            if not items:
                is_last_page = True  # 더 이상 데이터가 없으면 종료
                break

            saved_count = self.save_data_to_db(items)
            total_saved_count += saved_count

            total_count = response_data.get("body", {}).get("totalCount", 0)
            if page_no * num_of_rows >= total_count:
                is_last_page = True  # 모든 페이지 처리 완료
            else:
                page_no += 1  # 다음 페이지로 이동

        return Response(
            {"message": f"총 {total_saved_count}개의 데이터가 저장되었습니다."},
            status=status.HTTP_200_OK,
        )

    def fetch_page_data(self, page_no, num_of_rows):
        """
        공공 API에서 데이터를 가져오는 함수
        """
        try:
            params = {
                "serviceKey": self.API_KEY,
                "type": "json",
                "pageNo": page_no,
                "numOfRows": num_of_rows
            }
            response = requests.get(self.API_URL, params=params)
            if response.status_code == 200:
                return response.json()
            else:
                print(f"API 호출 실패: {response.status_code} - {response.text}")
                return None

        except Exception as ex:
                print(f"API 호출 중 오류 발생: {ex}")
                return None

    @transaction.atomic
    def save_data_to_db(self, data_list):
        """
        API 데이터를 DB에 저장하는 함수
        :param data_list: API에서 가져온 데이터의 리스트
        :return: 저장된 데이터 개수
        """
        saved_count = 0
        drugs_to_create = []

        for data in data_list:
            try:
                # DrugInfo 객체 생성
                drug = DrugInfo(
                    item_seq=data.get("ITEM_SEQ"),
                    item_name=data.get("ITEM_NAME"),
                    entp_name=data.get("ENTP_NAME"),
                    consgn_manuf=data.get("CONSGN_MANUF"),
                    etc_otc_code=data.get("ETC_OTC_CODE"),
                    chart=data.get("CHART"),
                    bar_code=data.get("BAR_CODE"),
                    material_name=data.get("MATERIAL_NAME"),
                    ee_doc_id=data.get("EE_DOC_ID"),
                    ud_doc_id=data.get("UD_DOC_ID"),
                    nb_doc_id=data.get("NB_DOC_ID"),
                    storage_method=data.get("STORAGE_METHOD"),
                    valid_term=data.get("VALID_TERM"),
                    pack_unit=data.get("PACK_UNIT"),
                    ee_doc_data=data.get("EE_DOC_DATA"),
                    ud_doc_data=data.get("UD_DOC_DATA"),
                    nb_doc_data=data.get("NB_DOC_DATA"),
                )
                drugs_to_create.append(drug)

            except Exception as ex:
                print(f"데이터 생성 중 오류 발생: {ex}")
                continue
        # 배치 저장
        if drugs_to_create:
            try:
                DrugInfo.objects.bulk_create(drugs_to_create, ignore_conflicts=True)
                saved_count += len(drugs_to_create)
            except Exception as ex:
                print(f"DB 저장 중 오류 발생: {ex}")

        return saved_count


class FetchAndSaveAppearanceDataView(APIView):
    """
    공공 API로부터 약의 외형 데이터를 가져와 `Appearance` 모델에 저장하는 뷰
    """

    API_URL = "http://apis.data.go.kr/1471000/MdcinGrnIdntfcInfoService01/getMdcinGrnIdntfcInfoList01"
    API_KEY =

    def get(self, request):
        """
        GET: 외형 데이터를 저장하거나 업데이트
        """
        #공공 API 데이터 Fetch
        total_saved_count = 0
        page_no = 1
        num_of_rows = 100  # 한 페이지에서 가져올 데이터 수
        is_last_page = False  # 마지막 페이지 여부 확인

        while not is_last_page:
            # 1. 페이지 데이터를 가져옴
            response_data = self.fetch_page_data(page_no, num_of_rows)
            if response_data is None:
                return Response(
                    {"error": f"{page_no} 페이지 데이터 가져오기 실패"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

            # 2. 해당 페이지 데이터 저장
            items = response_data.get("body", {}).get("items", [])
            if not items:
                is_last_page = True  # 더 이상 데이터가 없으면 종료
                break

            saved_count = self.save_appearance_data_to_db(items)
            total_saved_count += saved_count

            # 3. 총 데이터 카운트를 확인하고 페이지를 넘김
            total_count = response_data.get("body", {}).get("totalCount", 0)
            if page_no * num_of_rows >= total_count:
                is_last_page = True  # 모든 페이지 처리 완료
            else:
                page_no += 1  # 다음 페이지로 이동

        return Response(
            {"message": f"총 {total_saved_count}개의 데이터가 저장되었습니다."},
            status=status.HTTP_200_OK,
        )


    def fetch_page_data(self, page_no, num_of_rows):
        """
        공공 API로부터 약 외형 데이터를 가져옵니다.
        """
        try:
            params = {
                "serviceKey": self.API_KEY,
                "type": "json",
                "pageNo": page_no,
                "numOfRows": num_of_rows
            }
            response = requests.get(self.API_URL, params=params)
            if response.status_code == 200:
                return response.json()
            else:
                print(f"API 호출 실패: {response.status_code} - {response.text}")
                return None
        except Exception as ex:
            print(f"API 호출 중 오류 발생: {ex}")
            return None

    @transaction.atomic
    def save_appearance_data_to_db(self, data_list):
        """
        API 데이터를 Appearance 모델에 저장 또는 업데이트
        :param data_list: API에서 가져온 외형 데이터 리스트
        :return: 저장된 데이터 개수
        """
        saved_count = 0
        appearances_to_create = []

        for data in data_list:
            try:
                # Appearance 객체 만들기
                appearance = Appearance(
                    item_seq=data.get("ITEM_SEQ"),
                    item_name=data.get("ITEM_NAME"),
                    item_image=data.get("ITEM_IMAGE"),
                    drug_shape=data.get("DRUG_SHAPE"),
                    print_front=data.get("PRINT_FRONT"),
                    print_back=data.get("PRINT_BACK"),
                    color_class1=data.get("COLOR_CLASS1"),
                    color_class2=data.get("COLOR_CLASS2"),
                    line_front=data.get("LINE_FRONT"),
                    line_back=data.get("LINE_BACK"),
                    leng_long=data.get("LENG_LONG"),
                    leng_short=data.get("LENG_SHORT"),
                    thick=data.get("THICK"),
                    img_regist_ts=data.get("IMG_REGIST_TS"),
                    item_permit_date=data.get("ITEM_PERMIT_DATE"),
                )
                appearances_to_create.append(appearance)
            except Exception as ex:
                print(f"데이터 생성 중 오류 발생: {ex}")
                continue

        # 배치로 저장
        if appearances_to_create:
            try:
                Appearance.objects.bulk_create(appearances_to_create, ignore_conflicts=True)
                saved_count += len(appearances_to_create)
            except Exception as ex:
                print(f"DB 저장 중 오류 발생: {ex}")

        return saved_count

class DrugListView(APIView):
    """
    약물 데이터의 리스트를 페이지 단위로 반환하는 뷰
    """
    def get(self, request):
        try:
            drugs = DrugInfo.objects.all() # 모든 약물 데이터를 가져옴
            paginator = PageNumberPagination()
            paginator.page_size = 10  # 한 페이지에 보여줄 데이터 수 설정
            paginated_drugs = paginator.paginate_queryset(drugs, request)  # 페이지 처리

            serializer = DrugInfoSerializer(paginated_drugs, many=True)  # 직렬화
            return paginator.get_paginated_response(serializer.data)  # 페이징된 응답 반환
        except Exception as ex:
            return Response(
                {"error": f"데이터를 가져오는 중 오류가 발생했습니다: {ex}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class DrugSearchByItemSeq(APIView):
    """
    특정 약물의 세부 정보를 반환하는 뷰 (item_seq를 기준으로 조회)
    """
    def get(self, request, item_seq):
        try:
            drug = get_object_or_404(DrugInfo, item_seq=item_seq)  # 아이템 일련번호로 약물 검색
            serializer = DrugInfoSerializer(drug)  # 직렬화
            return Response(serializer.data, status=status.HTTP_200_OK)  # 직렬화된 데이터 반환
        except Exception as ex:
            return Response(
                {"error": f"약물 세부 정보를 가져오는 중 오류가 발생했습니다: {ex}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class DrugSearchByNameView(APIView):
    """
    약물 이름을 기준으로 데이터를 검색해 반환하는 뷰
    """
    def get(self, request):
        try:
            query = request.query_params.get("name", "")  # URL 파라미터로 검색어 가져오기
            if not query:
                return Response(
                    {"error": "검색어를 입력해주세요."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            drugs = DrugInfo.objects.filter(item_name__icontains=query)  # 이름 기반 검색
            if not drugs.exists():
                return Response(
                    {"message": "검색된 결과가 없습니다."},
                    status=status.HTTP_404_NOT_FOUND
                )

            serializer = DrugInfoSerializer(drugs, many=True)  # 직렬화
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as ex:
            return Response(
                {"error": f"검색 중 오류가 발생했습니다: {ex}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class SearchDrugByAppearanceView(APIView):
    def get(self, request):
        """
        약물 외형을 기반으로 약물을 검색하고 의약품 정보를 반환하는 API
        """
        try:
            # 외형 관련 요청된 쿼리 파라미터 추출
            valid_fields = [
                "color_class1", "color_class2", "line_front", "line_back", "drug_shape ",
                "print_front", "print_back", "leng_long", "leng_short", "thick", "mark_code_front_anal",
                "mark_code_back_anal", "mark_code_front_img", "mark_code_back_img", "mark_code_front",
                "mark_code_back"
            ]
            filters = {
                f"{field}__icontains": request.query_params.get(field)
                for field in valid_fields if request.query_params.get(field)
            }

            # Appearance 모델 필터링
            appearances = Appearance.objects.filter(**filters)

            # Appearance 검색 결과가 있는 경우 DrugInfo에서 추가 정보 조회
            if appearances.exists():
                item_seqs = appearances.values_list("item_seq", flat=True)  # 검색된 item_seq 리스트
                drug_infos = DrugInfo.objects.filter(item_seq__in=item_seqs)  # DrugInfo 조회

                # Appearance와 DrugInfo 데이터 조합
                data = []
                for appearance in appearances:
                    drug_info = drug_infos.filter(item_seq=appearance.item_seq).first()  # 각각의 의약품 정보
                    data.append({
                        "item_seq": appearance.item_seq,
                        "appearance": {
                            "item_name": appearance.item_name,
                            "image": appearance.item_image,
                        },
                        "drug_info": {
                            "item_name": drug_info.item_name if drug_info else None,
                            "entp_name": drug_info.entp_name if drug_info else None,
                            "chart": drug_info.chart if drug_info else None,
                            "material_name": drug_info.material_name if drug_info else None,
                            "storage_method": drug_info.storage_method if drug_info else None,
                            "valid_term": drug_info.valid_term if drug_info else None,
                            "ee_doc_data": drug_info.ee_doc_data if drug_info else None,
                            "ud_doc_data": drug_info.ud_doc_data if drug_info else None,
                            "nb_doc_data": drug_info.nb_doc_data if drug_info else None,
                        } if drug_info else None
                    })

                return JsonResponse({"status": "success", "data": data}, status=200)

            else:
                return JsonResponse({"status": "success", "data": [], "message": "No matching drugs found."},
                                    status=200)

        except Exception as e:
            return JsonResponse({"status": "error", "message": str(e)}, status=500)


class AppearanceDetailView(APIView):
    """
    특정 약물의 외형 정보를 반환하는 뷰 (item_seq를 기준으로 조회)
    """
    def get(self, request, item_seq):
        try:
            appearance = get_object_or_404(Appearance, item_seq=item_seq)  # 외형 데이터를 item_seq로 검색
            serializer = AppearanceSerializer(appearance)  # 직렬화
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as ex:
            return Response(
                {"error": f"외형 데이터를 가져오는 중 오류가 발생했습니다: {ex}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class CheckInteractionsView(View):
    def post(self, request, *args, **kwargs):
        import json

        try:
            # 요청 데이터 파싱
            body = json.loads(request.body)
            item_seq_list = body.get("itemSeqList", [])
            if not item_seq_list or not isinstance(item_seq_list, list):
                return JsonResponse({"error": "Invalid itemSeqList format"}, status=400)

            # 병용 금기 검사 (임시 로직; 예: 특정 조건에 따라 임의로 false 설정)
            # 이 부분은 실제 비즈니스 로직 및 데이터를 기반으로 구현
            contraindications_view = CheckDrugContraindicationsWithPaginationView()
            is_safe = True
            conflicts = []

            # 모든 약물 조합 비교 (O(N^2) 방식)
            for i in range(len(item_seq_list)-1):
                for j in range(i + 1, len(item_seq_list)):
                    drug_a = item_seq_list[i]
                    drug_b = item_seq_list[j]

                    # CheckDrugContraindicationsWithPaginationView의 금기 확인 메서드 호출
                    result = contraindications_view.check_contraindicated_with_pagination(drug_a, drug_b)

                    # 금기일 경우 conflicts 리스트에 추가
                    if result:
                        conflicts.append({
                            "drugA": drug_a,
                            "drugB": drug_b,
                            "reason": result.get("PROHBT_CONTENT", "Unknown reason")
                        })

            # 병용 가능 여부 판단
            is_safe = len(conflicts) == 0

            # 최종 응답
            response = {"isSafe": is_safe}
            if conflicts:
                response["conflicts"] = conflicts

            return JsonResponse(response, status=200, json_dumps_params={'ensure_ascii': False})

        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)


class CheckDrugContraindicationsWithPaginationView(APIView):
    """
    두 약물 (A와 B)의 병용 금기 여부를 확인하는 API (페이징 처리된 병용 금기 데이터를 확인)
    """
    API_URL = "http://apis.data.go.kr/1471000/DURPrdlstInfoService03/getUsjntTabooInfoList03"  # 병용 금기 조회 API의 URL
    API_KEY =

    def get(self, request):
        """
        GET 요청: 약물 A를 기준으로 병용 금기 데이터를 페이지 단위로 검색하여 약물 B가 포함되는지 확인
        """
        try:
            drug_a = request.query_params.get("drugA")  # 약물 A의 이름 또는 ID
            drug_b = request.query_params.get("drugB")  # 약물 B의 이름 또는 ID

            # 필수 파라미터 확인
            if not drug_a or not drug_b:
                return Response(
                    {"error": "drugA(약물 A)와 drugB(약물 B) 정보를 모두 제공해야 합니다."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # 페이징 처리로 병용 금기 데이터를 가져와 B가 포함되는지 확인
            is_contraindicated = self.check_contraindicated_with_pagination(drug_a, drug_b)

            # 결과 반환
            if is_contraindicated:
                return Response(
                    {
                        "message": f"약물 A({drug_a})와 약물 B({drug_b})는 병용 금기입니다.",
                        "is_contraindicated": True,
                    },
                    status=status.HTTP_200_OK,
                )
            else:
                return Response(
                    {
                        "message": f"약물 A({drug_a})와 약물 B({drug_b})는 병용 금기가 아닙니다.",
                        "is_contraindicated": False,
                    },
                    status=status.HTTP_200_OK,
                )

        except Exception as ex:
            return Response(
                {"error": f"병용 금기 확인 중 오류가 발생했습니다: {ex}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

    def check_contraindicated_with_pagination(self, drug_a, drug_b):
        """
        약물 A의 병용 금기 데이터를 페이지별로 가져와 약물 B가 포함되는지 확인
        """
        page_no = 1
        num_of_rows = 100  # 한 페이지에서 가져올 데이터 개수
        is_last_page = False

        while not is_last_page:
            # 공공 API를 호출하여 병용 금기 데이터를 가져옴
            response_data = self.fetch_contraindications_page(drug_a, page_no, num_of_rows)

            if response_data is None:
                raise Exception(f"병용 금기 데이터를 페이지 {page_no}에서 가져오는 데 실패했습니다.")
            # if response_data is None:
            #     break

            # 현재 페이지의 병용 금기 데이터 리스트
            contraindications = response_data.get("body", {}).get("items", [])
            print(f"Page {page_no}: Found {len(contraindications)} items.")
            total_count = response_data.get("body", {}).get("totalCount", 0)  # 전체 데이터 개수
            # 병용 금기 데이터에서 약물 B가 포함되는지 확인
            for contraindication in contraindications:
                if contraindication.get("MIXTURE_ITEM_SEQ") == drug_b:
                    return True

            # 다음 페이지 처리
            if page_no * num_of_rows >= total_count:
                is_last_page = True
            else:
                page_no += 1

        return False  # 병용 금기 데이터에서 약물 B를 찾을 수 없음

    def fetch_contraindications_page(self, drug_a, page_no, num_of_rows):
        """
        특정 페이지의 병용 금기 데이터를 공공 API에서 가져오기
        """
        try:
            params = {
                "serviceKey": self.API_KEY,
                "type": "json",
                "typeName": "병용금기",
                "pageNo": page_no,
                "numOfRows": num_of_rows,
                "itemSeq": drug_a,  # 약물 번호로 검색
            }
            response = requests.get(self.API_URL, params=params)
            if response.status_code == 200:
                return response.json()
            else:
                print(f"API 호출 실패: {response.status_code} - {response.text}")
                return None
        except Exception as ex:
            print(f"API 호출 중 오류 발생: {ex}")
            return None
