from django.urls import path
from .views import *

urlpatterns = [
    path('drug/', DrugListView.as_view(), name='drug_list'),  # 전체 의약품 리스트 예) 전체보기: api/drug, Search: api/drug/?search=195500005, api/drug/?search=타이레놀
    path("drug/update/", SaveDrugDataView.as_view(), name="fetch_and_save"),  # 의약품 정보 업데이트
    path('drug/search/appearance/', SearchDrugByAppearanceView.as_view(), name="drug_search_by_appearance"),  # 의약품 외형으로 검색
    path('drug_appearance/', AppearanceDetailView.as_view(), name='appearance_detail'),  # 외형 상세 정보 예) 전체보기: api/drug_appearance, Search: api/drug_appearance/?search=195500005, api/drug_appearance/?search=타이레놀
    path("drug_appearance/update/", SaveAppearanceDataView.as_view(), name="fetch_appearance_data"),  # 외형 정보 업데이트
    path('drug_check_contraindications/', CheckDrugContraindicationsView.as_view(),
         name='check_contraindications'), # 병용금기 확인, 예) /api/drug_check_contraindications/?drugA=201001011&drugB=200100101
    path('checkInteractions/', CheckInteractionsView.as_view(), name='check_interactions'),  # 병용 금기 확인 API
    
]
