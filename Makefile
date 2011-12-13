OPTFLAGS=-g

include src/config.o

OBJ=src/sakura.o src/win-kbm.o

CFLAGS=$(OPTFLAGS) $(VTEINC) -DICON_DIR=\"$(ICON_DIR)\" -DEVILVTE_VERSION=\"$(EVILVTE_VERSION)\" -DG_DISABLE_DEPRECATED -DG_DISABLE_SINGLE_INCLUDES -DGDK_DISABLE_DEPRECATED -DGDK_DISABLE_SINGLE_INCLUDES -DGTK_DISABLE_DEPRECATED -DGTK_DISABLE_SINGLE_INCLUDES

ifneq (,$(findstring min,$(EVILVTE)))
	CFLAGS += -DEVILVTE_MINIMUM=1
endif

ifneq (,$(findstring max,$(EVILVTE)))
	CFLAGS += -DEVILVTE_MAXIMUM=1
endif

ifneq (,$(findstring test,$(EVILVTE)))
	CFLAGS += -DEVILVTE_TESTING=1
endif

ifeq ($(SUSE_DETECTED),TRUE)
CFLAGS += -DSUSE_DETECTED=1
endif

ifeq ($(XTST_DETECTED),TRUE)
CFLAGS += -DXTST_DETECTED=1
endif

all: evilvte showvte misc/evilvte.1

src/evilvte.h:
	sh src/evilvte.sh

evilvte: src/evilvte.h $(OBJ)
	$(CC) $(LDFLAGS) $(OBJ) $(LDLIBS) -o $(PROG)

strip: all
	strip --remove-section=.comment --remove-section=.note $(PROG)

showvte:
	head -n 16 src/showvte.sh > src/showvte
	tail -n 7 src/showvte.sh | head -n 6 >> src/showvte
	sh src/showvte.sh >> src/showvte
	tail -n 1 src/showvte.sh >> src/showvte
	sed 's/\t/ /g' src/config.h | tr -s ' ' ' ' | sed 's/^ //' | grep ^\#define | sed 's~/\*~\n~g' | grep -v \*\/ >> src/showvte
	chmod 755 src/showvte

misc/evilvte.1:
	sh src/manpage.sh

install:
	install -d $(bindir)
	install -m 755 $(PROG) src/showvte $(bindir)
	install -d $(ICON_DIR_INSTALL)
	install -m 644 misc/evilvte.png misc/evilvte.xpm $(ICON_DIR_INSTALL)
	install -d $(mandir)
	install -m 644 misc/evilvte.1 misc/showvte.1 $(mandir)
	install -d $(deskdir)
	install -m 644 misc/evilvte.desktop $(deskdir)

installstrip: strip
	install -d $(bindir)
	install -m 755 $(PROG) src/showvte $(bindir)
	install -d $(ICON_DIR_INSTALL)
	install -m 644 misc/evilvte.png misc/evilvte.xpm $(ICON_DIR_INSTALL)
	install -d $(mandir)
	install -m 644 misc/evilvte.1 misc/showvte.1 $(mandir)
	install -d $(deskdir)
	install -m 644 misc/evilvte.desktop $(deskdir)

clean: src/config.o
	rm -f $(PROG) src/showvte src/*.o src/???????.h misc/evilvte.1 src/max.h src/test.h

src/config.o:
	./configure

.PHONY: all evilvte strip showvte install installstrip clean
