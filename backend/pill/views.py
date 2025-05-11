import requests
import json
from django.http import JsonResponse
from django.core.cache import cache
from django.db import transaction
from django.db.models import Q
from django.db.models import Prefetch
from django.views import View
from django.shortcuts import get_object_or_404
from rest_framework.generics import ListAPIView
from rest_framework.filters import SearchFilter
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.pagination import PageNumberPagination
from rest_framework import status
from .models import Appearance, DrugInfo
from .serializers import *

class SaveDrugDataView(APIView):
    """
    공공 API로부터 데이터를 가져와 DB에 저장하는 기능
    """
    API_URL = "http://apis.data.go.kr/1471000/DrugPrdtPrmsnInfoService06/getDrugPrdtPrmsnDtlInq05"
    API_KEY =

    def post(self, request):
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

            # DB에 업데이트(리턴값: 업데이트 된 의약품 수)
            saved_count = self.update_data_to_db(items)
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
    def update_data_to_db(self, data_list):
        """
        API 데이터를 DB에 저장하는 함수
        :param data_list: API에서 가져온 데이터의 리스트
        :return: 저장된 데이터 개수
        """
        saved_count = 0
        seq_list = [] # seq만 따로 저장
        drugs_to_create = []

        for data in data_list:
            serializer = DrugInfoSerializer(data=data)
            if serializer.is_valid():
                drugs_to_create.append(DrugInfo(**serializer.validated_data))
                seq_list.append(serializer.validated_data["item_seq"])
            else:
                print(f"Data validation error: {serializer.errors}")

        # 배치 저장
        if drugs_to_create:
            try:
                DrugInfo.objects.bulk_create(drugs_to_create, ignore_conflicts=True)
            except Exception as ex:
                print(f"DB 저장 중 오류 발생: {ex}")

        # 불필요 데이터 삭제
        self.delete_db_data(seq_list)

        return len(drugs_to_create)

    def delete_db_data(self, seq_list):
        """
           API에서 가져온 데이터를 기준으로 DB에 저장된 남은 데이터를 삭제
           :param seq_list: API에서 가져온 데이터 SEQ 리스트
           """
        # DB에 저장된 모든 데이터의 SEQ 조회
        existing_data = set(DrugInfo.objects.values_list("item_seq", flat=True))

        # 삭제 대상 계산
        delete_data = existing_data - set(seq_list)

        # 삭제 실행
        if delete_data:
            DrugInfo.objects.filter(item_seq__in=delete_data).delete()
            print(f"총 {len(delete_data)}개의 데이터를 삭제했습니다.")


class SaveAppearanceDataView(APIView):
    """
    공공 API로부터 약의 외형 데이터를 가져와 `Appearance` 모델에 저장하는 뷰
    """

    API_URL = "http://apis.data.go.kr/1471000/MdcinGrnIdntfcInfoService01/getMdcinGrnIdntfcInfoList01"
    API_KEY =

    def post(self, request):
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

            saved_count = self.update_appearance_data_to_db(items)
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
    def update_appearance_data_to_db(self, data_list):
        """
        API 데이터를 Appearance 모델에 저장 또는 업데이트
        :param data_list: API에서 가져온 외형 데이터 리스트
        :return: 저장된 데이터 개수
        """
        saved_count = 0
        seq_list = []  # seq만 따로 저장
        appearances_to_create = []

        for data in data_list:
            serializer = AppearanceSerializer(data=data)
            if serializer.is_valid():
                appearances_to_create.append(Appearance(**serializer.validated_data))
                seq_list.append(serializer.validated_data["item_seq"])
            else:
                print(f"Data validation error: {serializer.errors}")

        # 배치로 저장
        if appearances_to_create:
            try:
                Appearance.objects.bulk_create(appearances_to_create, ignore_conflicts=True)
            except Exception as ex:
                print(f"DB 저장 중 오류 발생: {ex}")

        # 불필요 데이터 삭제
        self.delete_db_data(seq_list)

        return len(appearances_to_create)

    def delete_db_data(self, seq_list):
        """
            API에서 가져온 데이터를 기준으로 DB에 저장된 남은 데이터를 삭제
            :param seq_list: API에서 가져온 데이터 리스트
            """
        # DB에 저장된 모든 데이터의 SEQ 조회
        existing_data_ids = set(Appearance.objects.values_list("item_seq", flat=True))

        # 삭제 대상 계산
        delete_data = existing_data_ids - set(seq_list)

        # 삭제 실행
        if delete_data:
            Appearance.objects.filter(item_seq__in=delete_data).delete()
            print(f"총 {len(delete_data)}개의 데이터를 삭제했습니다.")

class DrugListView(ListAPIView):
    """
    약물 데이터의 리스트를 페이지 단위로 반환하는 뷰
    """
    queryset = DrugInfo.objects.all()
    serializer_class = DrugInfoSerializer
    filter_backends = [SearchFilter]  # 검색 기능 추가
    search_fields = ['item_seq', 'item_name', 'entp_name']  # 검색 가능한 필드 정의

class DrugSearchByItemSeq(APIView):
    """
    특정 약물의 세부 정보를 반환하는 뷰 (item_seq를 기준으로 조회)
    """
    def get(self, request, item_seq):
        try:
            drug = get_object_or_404(DrugInfo, item_seq=item_seq)  # 아이템 일련번호로 약물 검색
            serializer = DrugInfoSerializer(drug)  # 직렬화
            return Response(serializer.data, status=status.HTTP_200_OK)  # 직렬화된 데이터 반환
        except DrugInfo.DoesNotExist:
            return Response({"error": "Drug not found"}, status=status.HTTP_404_NOT_FOUND)

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
    def post(self, request):
        """
        약물 외형을 기반으로 약물을 검색하고 의약품 정보를 반환하는 API
        """
        try:
            data = request.data
            query = Q()

            # 모양(shape) 필터 추가
            if "shape" in data and data["shape"]:
                shape_query = Q()
                for shape in data["shape"]:
                    shape_query |= Q(drug_shape__icontains=shape)
                query &= shape_query

            # 색상(color) 필터 추가
            if "color" in data and data["color"]:
                color_query = Q()
                for color in data["color"]:
                    color_query |= Q(color_class1__icontains=color) | Q(color_class2__icontains=color)
                query &= color_query

            # 분할선(line) 필터 추가
            if "line" in data and data["line"]:
                line_query = Q()
                for line in data["line"]:
                    line_query |= Q(line_front__icontains=line) | Q(line_back__icontains=line)
                query &= line_query

            # 제형(form) 필터 추가 - chart 필드 사용으로 수정
            if "form" in data and data["form"]:
                form_query = Q()
                for form in data["form"]:
                    form_query |= Q(chart__icontains=form)
                query &= form_query

            # 식별문자(text) 필터 추가
            if "text" in data and data["text"]:
                text_query = Q()
                for text in data["text"]:
                    text_query |= Q(print_front__icontains=text) | Q(print_back__icontains=text) | \
                                  Q(mark_code_front__icontains=text) | Q(mark_code_back__icontains=text) | \
                                  Q(mark_code_front_anal__icontains=text) | Q(mark_code_back_anal__icontains=text)
                query &= text_query

            # Appearance 모델 필터링 (최소한 하나의 필터가 있을 때만)
            if query != Q():
                appearances = Appearance.objects.filter(query)
            else:
                return Response({
                    "status": "error",
                    "message": "최소한 하나의 검색 조건이 필요합니다."
                }, status=status.HTTP_400_BAD_REQUEST)

            # Appearance 검색 결과가 있는 경우 DrugInfo에서 추가 정보 조회
            if appearances.exists():
                item_seqs = appearances.values_list("item_seq", flat=True)  # 검색된 item_seq 리스트
                drug_infos = DrugInfo.objects.filter(item_seq__in=item_seqs)  # DrugInfo 조회
                drug_info_serialized = DrugInfoSerializer(drug_infos, many=True).data

                result_data = []
                for appearance in appearances:
                    matched_drug_info = next(
                        (info for info in drug_info_serialized if info['item_seq'] == appearance.item_seq),
                        None
                    )
                    result_data.append({
                        "drug_info": matched_drug_info,
                        "appearance": {
                            "image": appearance.item_image,
                        },
                    })

                return Response({
                    "status": "success",
                    "count": len(result_data),
                    "data": result_data
                }, status=status.HTTP_200_OK)
            else:
                return Response({
                    "status": "success",
                    "count": 0,
                    "data": [],
                    "message": "검색 결과가 없습니다."
                }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({
                "status": "error",
                "message": str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class AppearanceDetailView(ListAPIView):
    """
    특정 약물의 외형 정보를 반환하는 뷰 
    """
    queryset = Appearance.objects.all()
    serializer_class = AppearanceSerializer
    filter_backends = [SearchFilter]  # 검색 기능 추가
    search_fields = ['item_seq', 'item_name', 'entp_name']  # 검색 가능한 필드 정의

class CheckInteractionsView(View):
    """
    의약품 리스트를 받아서 병용금기를 확인하는 뷰
    """
    def post(self, request, *args, **kwargs):
        try:
            # 요청 데이터 파싱
            body = json.loads(request.body)
            item_seq_list = body.get("itemSeqList", [])
            if not item_seq_list or not isinstance(item_seq_list, list):
                return JsonResponse({"error": "Invalid itemSeqList format"}, status=400)

            # 병용 금기 검사 (임시 로직; 예: 특정 조건에 따라 임의로 false 설정)
            # 이 부분은 실제 비즈니스 로직 및 데이터를 기반으로 구현
            contraindications_view = CheckDrugContraindicationsView()
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

class CheckDrugContraindicationsView(APIView):
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
            source = "API"

            # 필수 파라미터 확인
            if not drug_a or not drug_b:
                return Response(
                    {"error": "drugA(약물 A)와 drugB(약물 B) 정보를 모두 제공해야 합니다."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            # 캐시 키 생성 (약물 A와 약물 B 조합에 대한 고유 키)
            cache_key = f"contraindication_{min(drug_a, drug_b)}_{max(drug_a, drug_b)}"

            # 캐시 확인
            cached_result = cache.get(cache_key)
            if cached_result is not None:
                # 캐시에 저장된 데이터가 있다면 반환
                is_contraindicated = cached_result
                source = "CACHE"
            else:
                # 캐시에서 결과를 찾지 못한 경우 API 호출
                is_contraindicated = self.check_contraindicated_with_pagination(drug_a, drug_b)
                # 결과를 캐시에 저장 (24시간 동안 저장)
                cache.set(cache_key, is_contraindicated, timeout=24 * 60 * 60)

            # 결과 반환
            if is_contraindicated:
                return Response(
                    {
                        "message": f"약물 A({drug_a})와 약물 B({drug_b})는 병용 금기입니다.",
                        "is_contraindicated": True,
                        "sourse": source,
                    },
                    status=status.HTTP_200_OK,
                )
            else:
                return Response(
                    {
                        "message": f"약물 A({drug_a})와 약물 B({drug_b})는 병용 금기가 아닙니다.",
                        "is_contraindicated": False,
                        "sourse": source,
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
