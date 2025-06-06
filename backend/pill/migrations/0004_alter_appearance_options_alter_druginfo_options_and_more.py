# Generated by Django 5.1.7 on 2025-05-12 03:37

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('pill', '0003_druginfo_ee_doc_data_druginfo_ee_doc_id_and_more'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='appearance',
            options={'ordering': ['item_seq']},
        ),
        migrations.AlterModelOptions(
            name='druginfo',
            options={'ordering': ['item_seq']},
        ),
        migrations.RemoveField(
            model_name='druginfo',
            name='bar_code',
        ),
        migrations.RemoveField(
            model_name='druginfo',
            name='consgn_manuf',
        ),
        migrations.RemoveField(
            model_name='druginfo',
            name='created_at',
        ),
        migrations.RemoveField(
            model_name='druginfo',
            name='ee_doc_id',
        ),
        migrations.RemoveField(
            model_name='druginfo',
            name='etc_otc_code',
        ),
        migrations.RemoveField(
            model_name='druginfo',
            name='nb_doc_id',
        ),
        migrations.RemoveField(
            model_name='druginfo',
            name='pack_unit',
        ),
        migrations.RemoveField(
            model_name='druginfo',
            name='ud_doc_id',
        ),
        migrations.AlterField(
            model_name='druginfo',
            name='entp_name',
            field=models.CharField(max_length=255, null=True),
        ),
        migrations.AlterField(
            model_name='druginfo',
            name='item_name',
            field=models.CharField(max_length=255, null=True),
        ),
    ]
