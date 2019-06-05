OBJS = circular_buffer.o  midi.o fft.o pitch_detector.o formant_corrector.o pitch_shifter.o lfo.o quantizer.o talentedhack.o pitch_smoother.o
DEBUG =-g
CFLAGS = --std=c99 -Wall -fPIC -I/usr/include/lv2 `pkg-config --cflags fftw3f lv2-plugin` -O3 $(DEBUG)
LDFLAGS = $(DEBUG) `pkg-config --libs fftw3f` -shared

PREFIX = /usr
LIBDIR = $(PREFIX)/lib
LV2_PATH ?= $(LIBDIR)/lv2
PKG_LV2 = $(LV2_PATH)/talentedhack.lv2

INSTALL = install
INSTALL_DIR = $(INSTALL) -d -m 0755
INSTALL_BIN = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 0644

TTLS = manifest.ttl talentedhack.ttl
SOS = talentedhack.so
TARGETS = $(SOS)

all: talentedhack.so

talentedhack.so: $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) -o $@

cleanall: clean
	$(RM) talentedhack.so &>/dev/null;

clean:
	$(RM) $(OBJS) &>/dev/null;
	$(RM) dependencies/*.d &>/dev/null;

-include $(addprefix  dependencies/, $(OBJS:.o=.d))

%.o:%.c
	$(CC) -MMD -MP -c $(CFLAGS) $*.c -o $*.o; \
	mkdir -p dependencies
	mv $*.d dependencies/

install_local: $(TARGETS)
	echo "Copying this directory to ~/.lv2 ..."
	cp -r ../`basename \`pwd\`` ~/.lv2/

install: $(TARGETS) $(TTLS)
	$(INSTALL_DIR) $(DESTDIR)$(PKG_LV2)
	$(INSTALL_BIN) $(SOS) $(DESTDIR)$(PKG_LV2)
	$(INSTALL_DATA) $(TTLS) $(DESTDIR)$(PKG_LV2)

tarballs: $(TARGETS)
	cd ..; rm talentedhack_source.tar.gz; tar -czvf talentedhack_source.tar.gz talentedhack.lv2/*.c talentedhack.lv2/*.h talentedhack.lv2/dependencies/*.d talentedhack.lv2/*.ttl talentedhack.lv2/Makefile;
	cd ..; rm talentedhack_linux_x86.tar.gz; tar -czvf talentedhack_linux_x86.tar.gz talentedhack.lv2/*.ttl talentedhack.lv2/talentedhack.so;

.PHONY : clean cleanall install tarballs
