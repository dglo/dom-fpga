#!/bin/bash
../scripts/mkmif.sh > version_rom.mif
quartus_map --import_settings_files=on --export_settings_files=off dom -c dom
if [ $?>0 ]
then
    echo ' '
    echo '*************************'
    echo 'ERROR MAP ERROR MAP ERROR'
    echo $'\a'
    exit
fi
quartus_fit --import_settings_files=off --export_settings_files=off dom -c dom
quartus_asm --import_settings_files=off --export_settings_files=off dom -c dom
quartus_tan --import_settings_files=off --export_settings_files=off dom -c dom
quartus_eda --import_settings_files=off --export_settings_files=off dom -c dom
