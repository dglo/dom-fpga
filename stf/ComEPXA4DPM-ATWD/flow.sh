#!/bin/sh
../../scripts/mkmif.sh > version_rom.mif
quartus_map --import_settings_files=on --export_settings_files=off simpletest -c simpletest
quartus_fit --import_settings_files=off --export_settings_files=off simpletest -c simpletest
quartus_asm --import_settings_files=off --export_settings_files=off simpletest -c simpletest
quartus_tan --import_settings_files=off --export_settings_files=off simpletest -c simpletest
quartus_eda --import_settings_files=off --export_settings_files=off simpletest -c simpletest
