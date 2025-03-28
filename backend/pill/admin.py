from django.contrib import admin
from .models import *

@admin.register(DrugInfo)
class DrugInfoAdmin(admin.ModelAdmin):
    list_display = ('item_seq', 'item_name', 'entp_name')

@admin.register(Appearance)
class AppearanceAdmin(admin.ModelAdmin):
    list_display = ('item_seq', 'item_name', 'entp_name', 'chart')
