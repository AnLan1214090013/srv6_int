#!/usr/bin/env python
import argparse
import sys
import socket
import random
import struct

from scapy.all import *

pkt = IPv6()