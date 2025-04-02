
from django.urls import path
from .views import *
from .models import DrugInfo

urlpatterns = [
    path('update_data/', fetch_data),
    path('data/', get_medicine_data),
    path('pill_appearance_update/', fetch_pill_appearance_data),
    path('pill_appearance_data/', get_pill_appearance_data),
    path('search_data_by_seq/', get_drug_info_by_seq, name='get_drug_info_by_seq'),
    path('search_data_by_name/', get_drug_info_by_name, name='get_drug_info_by_name'),
]