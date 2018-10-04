ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_OBJCFLAGS += -include Freecell_Prefix.h -Winvalid-pch

PACKAGE_NAME=Freecell
APP_NAME=Freecell

VERSION=0

Freecell_OBJC_FILES=\
	Card.m\
	CardView.m\
	Game.m\
	GameController.m\
	GameView.m\
	History.m\
	HistoryController.m\
	PreferencesController.m\
	Result.m\
	Table.m\
	TableLocation.m\
	TableMove.m\
	main.m

Freecell_C_FILES=\
	vccRand.c

Freecell_RESOURCE_FILES=\
	Freecell.tiff\
	Licence.txt\
	Cards/bonded.png\
	Cards/large-bonded.png\
	Cards/unedited-bonded.png\
	Freecell.icns

Freecell_LOCALIZED_RESOURCE_FILES=\
        MainMenu.nib\
        InfoPlist.strings\
        Localizable.strings\
        Credits.html

Freecell_LANGUAGES=\
	English\
        Dutch\
        Finnish\
        French\
        Japanese\
        Spanish

Freecell_PRINCIPAL_CLASS=NSApplication
Freecell_APPLICATION_ICON=Freecell.tiff
Freecell_OBJC_PRECOMPILED_HEADERS=Freecell_Prefix.h

Freecell_MAIN_MODEL_FILE=Freecell

ADDITIONAL_CPPFLAGS+= -DGNUSTEP

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
