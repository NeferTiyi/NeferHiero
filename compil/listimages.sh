#!/bin/tcsh

if ( $# < 1 ) then
  echo "usage: `basename $0` [-v] [-o OutDir] FileIn"
  exit
endif

set fg_verbose = ".false."
set fg_out     = ".false."

# Define directories
# ==================
switch ( ${HOSTNAME} )
  case "elkab":
    set DirHome = "/mnt/NeferHiero"
    breaksw
  case "*.ipsl.jussieu.fr":
    set DirHome = "/home_local/slipsl/Perso/GitRepo/NeferHiero"
    breaksw
  default:
    echo "Unknown host ${HOSTNAME}, we stop."
    exit 1
endsw
set ImgHome = "${DirHome}/images"
set DirOut  = "$PWD"

@ NArg = 1
while ( $NArg <= $# )
  switch ( $argv[$NArg] )
    case "-v":
      set fg_verbose = ".true."
      breaksw
    case "-o":
      set fg_out = ".true."
      @ NArg = $NArg + 1
      set DirOut = $DirHome/$argv[$NArg]
      if ( ! -d $DirOut ) then
        mkdir $DirOut
      endif
      breaksw
    default:
      set FileIn = `basename $argv[$NArg]`
      set PathIn = `dirname $argv[$NArg]`
      breaksw
  endsw
  @ NArg = $NArg + 1
end

# Does the input file exist ?
if ( ! -s $PathIn/$FileIn ) then
  echo "$FileIn not found, we stop."
  exit
endif

cd $PathIn

# Image dir
set ImgDir = `pwd | sed -e "s+documents+images+"`

rm ${FileIn}.full
if ( `head -n 1 $FileIn` != "%###include" ) then
  if ( `grep -c "%##preambule.tex" $FileIn` > 0 ) then
    cat preambule.tex >> ${FileIn}.full
  endif
endif
cat $FileIn >> ${FileIn}.full


# Find used image files
set InputList   = ""
set IncludeList = ""

if ( `grep -c "\\input" ${FileIn}_full.htx` > 0 ) then
  set fg_inputs = ".true."
  set InputList = `grep "\\input" ${FileIn}_full.htx | \
                        sed -e "s/\\input{//" -e "s/}//"`
endif

if ( `grep -c "\\include{" ${FileIn}_full.htx` > 0 ) then
  set fg_inputs = ".true."
  set IncludeList = `grep "\\include{" ${FileIn}_full.htx | \
                          sed -e "s/\\include{//" -e "s/}//"`
endif

set ImgList = "Img.tmp"
rm $ImgList

foreach InputFile ( ${FileIn}.full $InputList $IncludeList )
  if ( -s $InputFile ) then
    set File = "${InputFile}"
  else if ( -s $InputFile.htx ) then
    set File = "${InputFile}.htx"
  else
    set File = "${InputFile}.tex"
  endif
  grep "\\includegraphics" $File | \
       sed -e "s+.*\\includegraphics.*{\(.*\)}.*+\1+" | \
       sed -e "s+\(.*\)}.*+\1+" \
       >> $ImgList
end

# Get images extensions and path
set ImgUsed = "ImgUsed.tmp"
rm $ImgUsed
foreach ImgName ( `cat $ImgList` )
  find $ImgHome -name "$ImgName.*" >> $ImgUsed
end

# awk

exit
