DEFINT A-Z

TYPE RegType
 AX AS INTEGER
 BX AS INTEGER
 CX AS INTEGER
 DX AS INTEGER
 BP AS INTEGER
 SI AS INTEGER
 DI AS INTEGER
 Flags AS INTEGER
END TYPE

CONST FALSE = 0

DECLARE FUNCTION CodePageExists (RequestedCodePage)
DECLARE FUNCTION GetCodePage ()
DECLARE FUNCTION RequestCodePage ()
DECLARE SUB DisplayCodePages ()
DECLARE SUB DisplayExtendedCharacters ()
DECLARE SUB SetCodePage (NewCodePage)
DECLARE SUB INTERRUPT (intnum AS INTEGER, inreg AS RegType, outreg AS RegType)
DECLARE SUB Main ()

CALL Main
END

CodePages:
DATA 437, "United States (``PC-ASCII``)"
DATA 710, "Arabic (Transparent Arabic)"
DATA 720, "Arabic (Transparent ASMO)"
DATA 737, "Greek II"
DATA 850, "Multilingual (Latin I)"
DATA 850, "Multilingual (Latin I), euro"
DATA 852, "Slavic/Eastern European (Latin II)"
DATA 855, "Cyrillic I"
DATA 857, "Turkish"
DATA 860, "Portuguese"
DATA 861, "Icelandic"
DATA 862, "Hebrew"
DATA 863, "Canadian-French"
DATA 864, "Arabic"
DATA 865, "Nordic"
DATA 866, "Russian (Cyrillic II)"
DATA 869, "Greek"
DATA 912, "ISO 8859-2 (Latin)"
DATA 915, "ISO 8859-5 (Cyrillic)"
DATA 874, "Thai"
DATA 932, "Japanese"
DATA 934, "Korean"
DATA 936, "Chinese (Simplified)"
DATA 938, "Taiwan"
DATA 949, "Korean"
DATA 0, ""

FUNCTION CodePageExists (RequestedCodePage)
 Exists = FALSE

 RESTORE CodePages
 DO
  READ CodePage, PageName$
  Exists = (CodePage = RequestedCodePage)
 LOOP UNTIL CodePage = 0 OR Exists

 CodePageExists = Exists
END FUNCTION

SUB DisplayCodePages
 PRINT "Available code pages:"

 RESTORE CodePages
 DO
  READ CodePage, PageName$
  IF CodePage = 0 THEN EXIT DO
  PRINT USING " ### \                                \ "; CodePage; PageName$;
 LOOP
END SUB

SUB DisplayExtendedCharacters
 FOR Character = 128 TO 255
  PRINT USING "### \\    "; Character; CHR$(Character);
 NEXT Character
END SUB

FUNCTION GetCodePage
DIM Registers AS RegType

 Registers.AX = &H6601
 INTERRUPT &H21, Registers, Registers

 GetCodePage = Registers.BX
END FUNCTION

SUB Main
 SCREEN 0: WIDTH 80, 25: COLOR 7, 0: CLS

 PRINT "Code Pages - by: Peter Swinkels, ***2022***"

 PRINT
 DisplayCodePages

 PRINT
 PRINT
 PRINT "Active code page: "; GetCodePage

 PRINT
 NewCodePage = RequestCodePage

 IF NOT NewCodePage = 0 THEN
  SetCodePage NewCodePage
  DisplayExtendedCharacters
 END IF
END SUB

FUNCTION RequestCodePage
 DO
  LINE INPUT "Specify a code page: "; CodePage$
  NewCodePage = VAL(LTRIM$(RTRIM$(CodePage$)))

  IF NewCodePage = 0 THEN
   EXIT DO
  ELSE
   IF CodePageExists(NewCodePage) THEN
    EXIT DO
   ELSE
    PRINT "The specified code page does not exist!"
   END IF
  END IF
 LOOP

 RequestCodePage = NewCodePage
END FUNCTION

SUB SetCodePage (NewCodePage)
DIM Registers AS RegType

 Registers.AX = &H6602
 Registers.BX = NewCodePage
 INTERRUPT &H21, Registers, Registers
END SUB

