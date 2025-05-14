from rest_framework import serializers
from .models import *


class DrugInfoSerializer(serializers.ModelSerializer):
    class Meta:
        model = DrugInfo
        fields = '__all__'

class AppearanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Appearance
        fields = '__all__'
