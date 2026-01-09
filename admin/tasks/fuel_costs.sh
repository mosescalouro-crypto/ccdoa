#!/bin/bash

/usr/bin/curl -sk -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36" https://hnd.aero/Pilots | grep -A 30 "<h3>Current Fuel Price</h3>" &&

exit 0;