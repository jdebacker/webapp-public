# -*- coding: utf-8 -*-
# Generated by Django 1.9 on 2018-02-20 21:50
from __future__ import unicode_literals

import django.contrib.postgres.fields
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dynamic', '0020_auto_20180216_2003'),
    ]

    operations = [
        migrations.AddField(
            model_name='dynamicbehaviorsaveinputs',
            name='deprecated_fields',
            field=django.contrib.postgres.fields.ArrayField(base_field=models.CharField(blank=True, max_length=50), blank=True, null=True, size=None),
        ),
    ]
