from rest_framework import serializers
from .models import *


class DrugInfoSerializer(serializers.ModelSerializer):
    class Meta:
        model = DrugInfo
        fields = [
            "item_seq",  # 기본키
            "item_name",
            "entp_name",
            "chart",
            "material_name",
            "storage_method",
            "valid_term",
            "ee_doc_data",
            "ud_doc_data",
            "nb_doc_data",
        ]



class AppearanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Appearance
        fields = '__all__'
