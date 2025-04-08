from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='DrugInfo',
            fields=[
                ('item_seq', models.CharField(max_length=20, primary_key=True, serialize=False)),
                ('item_name', models.CharField(max_length=255)),
                ('entp_name', models.CharField(max_length=255)),
                ('consgn_manuf', models.CharField(blank=True, max_length=255, null=True)),
                ('etc_otc_code', models.CharField(max_length=50)),
                ('chart', models.TextField(blank=True, null=True)),
                ('bar_code', models.TextField(blank=True, null=True)),
                ('material_name', models.TextField(blank=True, null=True)),
                ('storage_method', models.CharField(blank=True, max_length=255, null=True)),
                ('valid_term', models.CharField(blank=True, max_length=255, null=True)),
                ('pack_unit', models.CharField(blank=True, max_length=100, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),
    ]
