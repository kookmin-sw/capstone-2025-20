from django.db import models

# Create your models here.
class DrugInfo(models.Model):
    item_seq = models.CharField(max_length=9, primary_key=True)  # 의약품 고유번호
    item_name = models.TextField(null=True, blank=True)  # 의약품 이름
    entp_name = models.TextField(null=True, blank=True)  # 제조사명
    chart = models.TextField(null=True, blank=True)  # 의약품 형태
    material_name = models.TextField(null=True, blank=True)  # 성분 정보
    storage_method = models.CharField(max_length=255, null=True, blank=True)  # 보관 방법
    valid_term = models.CharField(max_length=255, null=True, blank=True)  # 유효 기간
    ee_doc_data = models.TextField(null=True, blank=True)  # 효능,효과
    ud_doc_data = models.TextField(null=True, blank=True)  # 용법,용량
    nb_doc_data = models.TextField(null=True, blank=True)  # 사용상의 주의사항

    def __str__(self):
        return self.item_name

    class Meta:
        ordering = ['item_seq']  # 기본 정렬

class Appearance(models.Model):
    item_seq = models.CharField(max_length=9, primary_key=True)    # 의약품 고유번호
    item_name = models.TextField(null=True, blank=True)  # 의약품 이름
    entp_name =models.TextField(null=True, blank=True)
    chart = models.CharField(max_length=255, null=True, blank=True)
    item_image = models.URLField(null=True, blank=True)
    print_front = models.CharField(max_length=100, null=True, blank=True)
    print_back = models.CharField(max_length=100, null=True, blank=True)
    drug_shape = models.CharField(max_length=100, null=True, blank=True)
    color_class1 = models.CharField(max_length=100, null=True, blank=True)
    color_class2 = models.CharField(max_length=100, null=True, blank=True)
    line_front = models.CharField(max_length=50, null=True, blank=True)
    line_back = models.CharField(max_length=50, null=True, blank=True)
    leng_long = models.CharField(max_length=10, null=True, blank=True)
    leng_short = models.CharField(max_length=10, null=True, blank=True)
    thick = models.CharField(max_length=10, null=True, blank=True)
    img_regist_ts = models.CharField(max_length=20, null=True, blank=True)
    item_permit_date = models.CharField(max_length=20, null=True, blank=True)
    form_code_name = models.CharField(max_length=255, null=True, blank=True)
    mark_code_front_anal = models.CharField(max_length=255, null=True, blank=True)
    mark_code_back_anal = models.CharField(max_length=255, null=True, blank=True)
    mark_code_front_img = models.CharField(max_length=255, null=True, blank=True)
    mark_code_back_img = models.CharField(max_length=255, null=True, blank=True)
    item_eng_name = models.CharField(max_length=255, null=True, blank=True)
    change_date = models.CharField(max_length=20, null=True, blank=True)
    mark_code_front = models.CharField(max_length=255, null=True, blank=True)
    mark_code_back = models.CharField(max_length=255, null=True, blank=True)
    edi_code = models.CharField(max_length=50, null=True, blank=True)
    bizrno = models.CharField(max_length=50, null=True, blank=True)

    def __str__(self):
        return self.item_name

    class Meta:
        ordering = ['item_seq']  # 기본 정렬
