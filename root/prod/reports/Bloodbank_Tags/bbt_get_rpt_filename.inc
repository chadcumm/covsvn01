;*****************************************************************************
;  	NOTE:  THIS INCLUDE FILE IS ALSO IN THE SCRIPT PROJECT NUMBER 1335
;	\CODE\SCRIPT\BBT_GENERATETAGSLABELS.  ANY CHANGES MADE TO THIS INCLUDE
;	MUST ALSO BE MADE TO THE SAME FILE IN THE SCRIPT PROJECT.
;*****************************************************************************

;*****************************************************************************
;  NOTE:  This file is a copy of mic_get_rpt_filename.inc.  It was copied in order to 
;   distribute the source to BBT clients through a template project
;*****************************************************************************
declare GetReportFilename(sFilename = vc) = vc
subroutine GetReportFilename(sFilename)
;  This subroutine is responsible for determining the next available file name for
;  a given report.  If the filename passed into this function already exists we will
;  append an '_' and and integer (starting at 1) at the end of the filename
;  (prior to the file extension) until we find a filename that does not exist.
 
;  Assumptions:
;      1) The sFilename parameter is prefixed with the proper logical such as CER_PRINT.
;         If the sFilename parameter is not prefixed with the proper logical the
;         FileFile function will default to CCLUSERDIR.
;      2) The last four characters of the sFilename parameter contain the file extension
;         such as .DAT or .CSV.
 
;  Parameters:
;      sFilename - This parameter contains the filename we want to use.  It is assumed
;                  this filename is prefixed with the proper logical and has a four
;                  character file extension.
 
  declare nFileExists          = i2 with noconstant(0)
  declare nNextSeq             = i2 with noconstant(0)
  declare sNewFilename         = vc with noconstant("")
  declare sFileExtension       = c4 with noconstant("")
  declare sFilenameNoExtension = vc with noconstant("")
 
  set nFileExists = FindFile(sFilename)
  if (nFileExists = 1)
    ; File already exists so append and increment a number to the end of the
    ; filename that was passed in until we find one that does not exist.
    while (nFileExists = 1)
      set sFileExtension = substring(textlen(sFilename) - 3, 4, sFilename)
      set sFilenameNoExtension substring(1, textlen(sFilename) - 4, sFilename)
      set nNextSeq = nNextSeq + 1
      set sNewFilename = build(sFilenameNoExtension, "_", cnvtstring(nNextSeq), sFileExtension)
 
      set nFileExists = FindFile(sNewFilename)
    endwhile
  else
    ; File does not exist so use filename that was passed in
    set sNewFilename = sFilename
  endif
 
  return (sNewFilename)
end

