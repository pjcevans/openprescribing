# -*- coding: utf-8 -*-
# Generated by Django 1.9.1 on 2018-01-02 11:44
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('dmd', '0009_auto_20171213_1446'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='ncsoconcession',
            unique_together=set([('date', 'vmpp')]),
        ),
    ]
