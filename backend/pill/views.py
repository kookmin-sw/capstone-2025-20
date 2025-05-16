import requests
import json
from django.http import JsonResponse
from django.core.cache import cache
from django.db import transaction
from django.db.models import Q, OuterRef, Subquery
from django.db.models import Prefetch
from django.views import View
from django.urls import resolve, reverse
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import get_object_or_404
from rest_framework.generics import ListAPIView
from rest_framework.filters import SearchFilter
from rest_framework.views import APIView
from rest_framework.renderers import JSONRenderer
from rest_framework.response import Response
from rest_framework.test import APIRequestFactory
from rest_framework import status
from .models import *
from .serializers import *

class SaveDrugDataView(APIView):
    """
    공공 API로부터 데이터를 가져와 DB에 저장하는 기능
    """
    API_URL = "http://apis.data.go.kr/1471000/DrugPrdtPrmsnInfoService06/getDrugPrdtPrmsnDtlInq05"
    API_KEY =

    def post(self, request):
        """
        POST: 공공 API에서 의약품 데이터 저장하거나 업데이트
        """
        total_saved_count = 0
        page_no = 1
        num_of_rows = 100  # 한 페이지에서 가져올 데이터 수
        is_last_page = False  # 마지막 페이지 여부 확인
        all_item_seqs = []

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
            page_seq_list = self.update_data_to_db(items)
            all_item_seqs.extend(page_seq_list)  # 전체 API seq 수집
            total_saved_count += len(page_seq_list)
            total_count = response_data.get("body", {}).get("totalCount", 0)
            if page_no * num_of_rows >= total_count:
                is_last_page = True  # 모든 페이지 처리 완료
            else:
                page_no += 1  # 다음 페이지로 이동

        deleted_count = self.delete_db_data(all_item_seqs)

        return Response(
            {"message": f"총 {total_saved_count}개의 데이터가 저장되었고, {deleted_count}개의 불필요한 데이터가 삭제되었습니다."},
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
        seq_list = []  # seq만 따로 저장
        drugs_to_create = []  # 벌크

        # 데이터 검증 및 객체 생성
        for data in data_list:
            # API 데이터의 키를 소문자로 변환
            lowercase_data = {k.lower(): v for k, v in data.items()}
            seq_list.extend([lowercase_data.get("item_seq")])
            serializer = DrugInfoSerializer(data=lowercase_data)
            if serializer.is_valid():
                # 객체 생성만 하고 저장은 하지 않음
                drug = DrugInfo(**serializer.validated_data)
                drugs_to_create.append(drug)
                seq_list.append(serializer.validated_data["item_seq"])

        # 벌크 저장
        if drugs_to_create:
            try:
                DrugInfo.objects.bulk_create(drugs_to_create, ignore_conflicts=True)
            except Exception as ex:
                print(f"DB 저장 중 오류 발생: {ex}")

        print(f"총 저장된 갯수: {drugs_to_create}")
        return seq_list

    def delete_db_data(self, seq_list):
        """
           API에서 가져온 데이터를 기준으로 DB에 저장된 남은 데이터를 삭제
           :param seq_list: API에서 가져온 데이터 SEQ 리스트
           """
        if not seq_list:
            print("API에서 수신한 seq_list가 비어 있어 삭제 작업이 중단되었습니다.")
            return 0

        db_seq_set = set(DrugInfo.objects.values_list('item_seq', flat=True))
        seq_set = set(map(str, seq_list))
        db_seq_set = set(map(str, db_seq_set))
        # 삭제 대상 (db_seq_set에 있는데 seq_list에는 없는 경우)
        items_to_delete = list(db_seq_set - seq_set)

        if not items_to_delete:
            # 삭제할 데이터가 없는 경우
            print("삭제할 데이터가 없습니다.")
            return 0

        # 배치 크기 설정
        batch_size = 500  # 한 번에 처리할 개수

        deleted_count = 0
        for i in range(0, len(items_to_delete), batch_size):
            batch = items_to_delete[i:i + batch_size]
            with transaction.atomic():
                deleted_count += DrugInfo.objects.filter(item_seq__in=batch).delete()[0]

        return deleted_count

class SaveAppearanceDataView(APIView):
    """
    공공 API로부터 약의 외형 데이터를 가져와 `Appearance` 모델에 저장하는 뷰
    """
    API_URL = "http://apis.data.go.kr/1471000/MdcinGrnIdntfcInfoService01/getMdcinGrnIdntfcInfoList01"
    API_KEY =

    def post(self, request):
        """
        POST: 외형 데이터를 저장하거나 업데이트
        """
        total_saved_count = 0
        page_no = 1
        num_of_rows = 100  # 한 페이지에서 가져올 데이터 수
        is_last_page = False  # 마지막 페이지 여부 확인
        all_item_seqs = []

        while not is_last_page:
            response_data = self.fetch_page_data(page_no, num_of_rows)
            if response_data is None:
                return Response(
                    {"error": f"{page_no} 페이지 데이터 가져오기 실패"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

            items = response_data.get("body", {}).get("items", [])
            print(f"Info List (Page {page_no}): {len(items)}개")
            if not items:
                is_last_page = True  # 더 이상 데이터가 없으면 종료
                break

            page_seq_list = self.update_appearance_data_to_db(items)
            all_item_seqs.extend(page_seq_list)
            total_saved_count += len(page_seq_list)
            total_count = response_data.get("body", {}).get("totalCount", 0)
            if page_no * num_of_rows >= total_count:
                is_last_page = True  # 모든 페이지 처리 완료
            else:
                page_no += 1  # 다음 페이지로 이동

        # 불필요 데이터 삭제
        deleted_count = self.delete_db_data(all_item_seqs)

        return Response(
            {"message": f"총 {total_saved_count}개의 데이터가 저장되었고, {deleted_count}개의 불필요한 데이터가 삭제되었습니다."},
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
        seq_list = []  # seq만 따로 저장
        appearances_to_create = []

        for data in data_list:
            lowercase_data = {k.lower(): v for k, v in data.items()}
            seq_list.extend([lowercase_data.get("item_seq")])
            serializer = AppearanceSerializer(data=lowercase_data)
            if serializer.is_valid():
                appearances_to_create.append(Appearance(**serializer.validated_data))

        # 배치로 저장
        if appearances_to_create:
            try:
                Appearance.objects.bulk_create(appearances_to_create, ignore_conflicts=True)
            except Exception as ex:
                print(f"DB 저장 중 오류 발생: {ex}")

        print(f"총 저장된 갯수: {len(appearances_to_create)}")

        return seq_list

    def delete_db_data(self, seq_list):
        """
            API에서 가져온 데이터를 기준으로 DB에 저장된 남은 데이터를 삭제
            :param seq_list: API에서 가져온 데이터 리스트
            """
        if not seq_list:
            print("API에서 수신한 seq_list가 비어 있어 삭제 작업이 중단되었습니다.")
            return 0

        db_seq_set = set(Appearance.objects.values_list('item_seq', flat=True))
        seq_set = set(map(str, seq_list))
        db_seq_set = set(map(str, db_seq_set))
        # 삭제 대상 (db_seq_set에 있는데 seq_list에는 없는 경우)
        items_to_delete = list(db_seq_set - seq_set)

        if not items_to_delete:
            # 삭제할 데이터가 없는 경우
            print("삭제할 데이터가 없습니다.")
            return 0

        # 배치 크기 설정
        batch_size = 500  # 한 번에 처리할 개수

        deleted_count = 0
        for i in range(0, len(items_to_delete), batch_size):
            batch = items_to_delete[i:i + batch_size]
            with transaction.atomic():
                deleted_count += Appearance.objects.filter(item_seq__in=batch).delete()[0]

        return deleted_count

class DrugListView(ListAPIView):
    """
    약물 데이터의 리스트를 페이지 단위로 반환하는 뷰
    """
    queryset = DrugInfo.objects.all()
    serializer_class = DrugInfoSerializer
    filter_backends = [SearchFilter]  # 검색 기능 추가
    search_fields = ['item_seq', 'item_name', 'entp_name']  # 검색 가능한 필드 정의
    def get_queryset(self):
        # Appearance의 item_image를 참조하는 서브쿼리 작성
        item_image_subquery = Appearance.objects.filter(
            item_seq=OuterRef('item_seq')  # DrugInfo의 item_seq를 참조
        ).values('item_image')[:1]  # 처음 나온 하나의 결과만 가져옴

        # DrugInfo QuerySet에 item_image 서브쿼리를 주입
        return DrugInfo.objects.annotate(
            item_image=Subquery(item_image_subquery)
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

            # Appearance 검색 결과가 있는 경우 DrugListView 호출
            if appearances.exists():
                item_seqs = appearances.values_list("item_seq", flat=True)  # 검색된 item_seq 리스트
                drug_list_url = reverse("drug_list")
                factory = APIRequestFactory()
                http_request = factory.get(drug_list_url, {'item_seq__in': ','.join(map(str, item_seqs))})
                # DrugListView 호출
                resolved_view = resolve(drug_list_url)
                drug_list_response = resolved_view.func(http_request)

                result_data = drug_list_response.data

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

@method_decorator(csrf_exempt, name='dispatch')
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

            # 병용 금기 검사
            contraindications_view = CheckDrugContraindicationsView()
            is_safe = True
            conflicts = []

            # 모든 약물 조합 비교
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

    CACHE_TIMEOUT =  24 * 60 * 60

    @classmethod
    def get_cached_contraindication(cls, drug_a, drug_b):
        """캐시에서 병용 금기 데이터를 가져옴."""
        cache_key = f"contraindication:{drug_a}:{drug_b}"
        return cache.get(cache_key)

    @classmethod
    def set_cached_contraindication(cls, drug_a, drug_b, result):
        """병용 금기 데이터를 캐시에 저장."""
        cache_key = f"contraindication:{drug_a}:{drug_b}"
        cache.set(cache_key, result, timeout=cls.CACHE_TIMEOUT)

    def check_contraindicated_with_pagination(self, drug_a, drug_b):
        """
        약물 A의 병용 금기 데이터를 페이지별로 가져와 약물 B가 포함되는지 확인
        """
        page_no = 1
        num_of_rows = 100  # 한 페이지에서 가져올 데이터 개수
        is_last_page = False

        cached_result = self.get_cached_contraindication(drug_a, drug_b)
        if cached_result is not None:
            return cached_result

        while not is_last_page:
            # 공공 API를 호출하여 병용 금기 데이터를 가져옴
            response_data = self.fetch_contraindications_page(drug_a, page_no, num_of_rows)

            if response_data is None:
                raise Exception(f"병용 금기 데이터를 페이지 {page_no}에서 가져오는 데 실패했습니다.")

            print(f"drug_a: {drug_a}, drug_b: {drug_b}")

            # 현재 페이지의 병용 금기 데이터 리스트
            contraindications = response_data.get("body", {}).get("items", [])
            print(f"Page {page_no}: Found {len(contraindications)} items.")
            total_count = response_data.get("body", {}).get("totalCount", 0)  # 전체 데이터 개수
            # 병용 금기 데이터에서 약물 B가 포함되는지 확인
            for contraindication in contraindications:
                if int(contraindication.get("MIXTURE_ITEM_SEQ")) == drug_b:
                    self.set_cached_contraindication(drug_a, drug_b, contraindication)
                    print("병용금기 확인")
                    return contraindication

            # 다음 페이지 처리
            if page_no * num_of_rows >= total_count:
                is_last_page = True
            else:
                page_no += 1

        self.set_cached_contraindication(drug_a, drug_b, False)
        print("병용금기 없음")
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
