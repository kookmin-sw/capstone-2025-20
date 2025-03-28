from rest_framework import serializers
from .models import DrugInfo

class DrugInfoSerializer(serializers.ModelSerializer):
    class Meta:
        model = DrugInfo
        fields = '__all__'