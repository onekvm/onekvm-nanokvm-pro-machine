PYTHON ?= python3

.PHONY: all clean test

# OE recipes install files directly; their default configure runs `make clean`.
all:

clean:

test:
	$(PYTHON) tests/edid-presets-test.py
	$(PYTHON) -m unittest tests/pack-pro-emmc-test.py
	sh tests/capture-chip-init-test.sh
