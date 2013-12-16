;+
;    Check files that MRTSwath failed to georeference due to unknown error
;    
;  Note: those files can be georeferenced by GEOREF_MOYD35_USING_MOYD03.pro 
;        in following data processing, which need to pay attention to the 
;        pixel size georeferenced by the procedure is a bit different from
;        that of MRTSwath.
;
;                       Version: 1.2.0 (2013-12-15)
;
;                    Author: Tony Tsai, Ph.D. Student
;          (Center for Earth System Science, Tsinghua University)
;               Contact Email: cai-j12@mails.tsinghua.edu.cn
;
;                    Copyright: belongs to Dr.Xu's Lab
;               (School of Environment, Tsinghua University)
; (College of Global Change and Earth System Science, Beijing Normal University)
;-
PRO CHECK_MRTSWATH_GEOREF
  COMPILE_OPT IDL2
  
  ; Customize year and pdir
  year = 2003
  pdir = 'H:\People\ZhangYawen\C6\'
  MOYD35Dir = pdir + 'MYD35\' + STRTRIM(STRING(year), 1) + '\'
  MOYD03Dir = pdir + 'MYD03\' + STRTRIM(STRING(year), 1) + '\'
  MOYD35GeoRefDir = pdir + 'MYD35GeoRef\' + STRTRIM(STRING(year), 1) + '\'
  
  ; Record HDF files that MRTSwath failed to georeference
  MRTSfile = MOYD35GeoRefDir + 'MRTSwathFail.txt'
  IF FILE_TEST(MRTSfile) EQ 1 THEN FILE_DELETE, MRTSfile
  
  MOYD35list = FILE_SEARCH(MOYD35Dir, '*.hdf', count = MOYD35_count, /FULLY_QUALIFY_PATH)
  IF MOYD35_count EQ 0 THEN RETURN
  
  FOR i = 0, MOYD35_count - 1 DO BEGIN
    fname = MOYD35list[i]
    fbname = FILE_BASENAME(fname)
    str = STRSPLIT(fbname, '.', /EXTRACT)
    pattern = str[0] + '_' + str[1] + '_' + str[2] + '_Cloud_Mask_b*.tif'
    TIFlist = FILE_SEARCH(MOYD35GeoRefDir, pattern, count = TIF_count)
    
    IF TIF_count LT 6 THEN BEGIN
      PRINT, TIFlist
      ; Write MOYD35 and MOYD03 HDF files to MRTSwathFail.txt
      OPENW, lun, MRTSfile, /GET_LUN, /APPEND
      PRINTF, lun, fbname
      
      pattern = 'MYD03.' + str[1] + '.' + str[2] + '*.hdf'
      MOYD03list = FILE_SEARCH(MOYD03Dir, pattern, count = MOYD03_count, /FULLY_QUALIFY_PATH)
      IF MOYD03_count EQ 1 THEN BEGIN
        MOYD03fname = MOYD03list[0]
        MOYD03fbname = FILE_BASENAME(MOYD03fname)
        PRINTF, lun, MOYD03fbname
      ENDIF
      FREE_LUN, lun
      
      IF TIF_count NE 0 THEN FILE_DELETE, TIFlist
    ENDIF
  ENDFOR
END