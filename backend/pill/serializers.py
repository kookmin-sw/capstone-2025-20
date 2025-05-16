from rest_framework import serializers
from .models import *

class DrugInfoSerializer(serializers.ModelSerializer):
    # item_image를 읽기 전용 필드로 추가
    item_image = serializers.ReadOnlyField()

    class Meta:
        model = DrugInfo
        fields = [
            'item_seq', 'item_name', 'entp_name', 'chart',
            'material_name', 'storage_method', 'valid_term',
            'ee_doc_data', 'ud_doc_data', 'nb_doc_data',
            'item_image'
        ]

class AppearanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Appearance
        fields = '__all__'
