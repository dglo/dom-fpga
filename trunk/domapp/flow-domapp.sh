#!/bin/sh
#../scripts/mkmif.sh > version_rom.mif
quartus_map --import_settings_files=on --export_settings_files=off domapp -c domapp
quartus_fit --import_settings_files=off --export_settings_files=off domapp -c domapp
quartus_asm --import_settings_files=off --export_settings_files=off domapp -c domapp
quartus_tan --import_settings_files=off --export_settings_files=off domapp -c domapp
quartus_eda --import_settings_files=off --export_settings_files=off domapp -c domapp
