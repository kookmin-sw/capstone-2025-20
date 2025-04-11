from django.urls import path
from .views import *

urlpatterns = [
    path('drug/', DrugListView.as_view(), name='drug_list'),  # 전체 의약품 리스트
    path("drug/fetch/", FetchAndSaveDrugDataView.as_view(), name="fetch_and_save"),  # 의약품 정보 업데이트
    path('drug/search/name/', DrugSearchByNameView.as_view(), name='drug_search_by_name'),  # 의약품 이름으로 검색,  예) api/drug/search/?name=아스피린
    path('drug/search/appearance/', SearchDrugByAppearanceView.as_view(), name="drug_search_by_appearance"),  # 의약품 외형으로 검색
    path('drug/search/item_seq/<str:item_seq>/', DrugSearchByItemSeq.as_view(), name='drug_search_by_item_seq'),  # 의약품 번호로 검색,  예) api/drug/search/199001012
    path("drug_appearance/fetch/", FetchAndSaveAppearanceDataView.as_view(), name="fetch_appearance_data"),  # 외형 정보 업데이트
    path('drug_appearance/<str:item_seq>/', AppearanceDetailView.as_view(), name='appearance_detail'),  # 외형 상세 정보
    path('drug_check_contraindications/', CheckDrugContraindicationsWithPaginationView.as_view(),
            name='check_contraindications'), # 병용금기 확인, 예) /api/drug_check_contraindications/?drugA=201001011&drugB=200100101
    path('checkInteractions/', CheckInteractionsView.as_view(), name='check_interactions'),  # 병용 금기 확인 API
    
]
