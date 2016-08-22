#!/bin/bash

#vagrant up mon0 --no-parallel && vagrant up osd0 osd1 --parallel
vagrant up mon0 --no-parallel && vagrant up osd0 osd1 osd2 --parallel
