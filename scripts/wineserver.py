#!/usr/bin/env python3

import configparser
import os
import sys

flatpak_info = configparser.ConfigParser()
flatpak_info.read('/.flatpak-info')

ARCH_INFO = {
    'x86_64': {
        'machine': 'x86_64-linux-gnu',
        'bits': '64'
    },
    'i386': {
        'machine': 'i386-linux-gnu',
        'bits': '32'
    },
}

wineserver_binary = '/usr/lib/{machine}/bin/wineserver{bits}'.format(
    **ARCH_INFO[flatpak_info['Instance']['arch']]
)

os.execv(wineserver_binary, [wineserver_binary] + sys.argv[1:])
