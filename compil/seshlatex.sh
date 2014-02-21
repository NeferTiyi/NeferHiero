#!/bin/tcsh

if ( $# < 1 ) then
  echo "usage: `basename $0` [-v] [-d] [-u] [-o OutDir] FileIn.htx"
  exit
endif

set fg_view    = ".false."
set fg_clean   = ".false."
set fg_debug   = ".false."
set fg_upd     = ".false."
set fg_bib     = ".false."
set fg_out     = ".false."
set fg_windows = ".false."

#set ViewBin = "okular"
#set ViewBin = "evince"
set ViewBin = "xpdf"
# set BibBin  = "bibtex"
set BibBin  = "biber"

# Define directories
# ==================
switch ( ${HOSTNAME} )
  case "elkab":
    set DirHome = "/mnt/NeferHiero"
    breaksw
  case "*.ipsl.jussieu.fr":
    # set DirHome = "/home_local/slipsl/Perso/HieroSVN"
    set DirHome = "/home_local/slipsl/Perso/GitRepo/NeferHiero"
    breaksw
  default:
    echo "Unknown host ${HOSTNAME}, we stop."
    exit 1
endsw
set DirWin  = "$DirHome"
set DirOut  = "$PWD"

set HieroDef = "$DirHome/utils/HieroDef.txt"

set FilesDel = ""

@ NArg = 1
while ( $NArg <= $# )
  switch ( $argv[$NArg] )
    case "--view=*":
      set fg_view = ".true."
      set ViewBin = `echo $argv[$NArg] | cut -f2 -d=`
      breaksw
    case "-v":
      set fg_view = ".true."
      breaksw
    case "-c":
      set fg_clean = ".true."
      breaksw
    case "-d":
      set fg_debug = ".true."
      breaksw
    case "-u":
      set fg_upd = ".true."
      breaksw
    case "-b":
      set fg_bib   = ".true."
      set fg_debug = ".true."
      set fg_upd   = ".true."
      breaksw
    case "-o":
      set fg_out = ".true."
      @ NArg = $NArg + 1
      set DirOut = $DirHome/$argv[$NArg]
      if ( ! -d $DirOut ) then
        mkdir $DirOut
      endif
      breaksw
    case "-w":
      set fg_windows = ".true."
      breaksw
    default:
      set FileIn = `basename $argv[$NArg] .htx`
      set PathIn = `dirname $argv[$NArg]`
      breaksw
  endsw
  @ NArg = $NArg + 1
end

set TexComp = "pdflatex -output-directory=$DirOut"
set OutType = "pdf"

# Does the input file exist ?
if ( ! -s $PathIn/$FileIn.htx ) then
  echo "$FileIn.htx not found, we stop."
  exit
endif

cd $PathIn


# Construct bibliography

if ( $fg_bib == ".true." && \
     -f $DirOut/$FileIn.aux ) then
  echo "=================================== Bibliographie ==================================="
  cd $DirOut
  $BibBin $FileIn
  cd -
endif

# If the source has not been modified, don't compile again
set fg_compil = ".true."
if ( $fg_upd == ".false." ) then
  test $FileIn.htx -nt $DirOut/$FileIn.$OutType
  set rc_code = $?
  if ( $rc_code != 0 ) then
    set fg_compil = ".false."
  endif
  if ( $fg_clean == ".true." ) then
    set fg_compil = ".false."
  endif
endif


if ( `head -n 1 $FileIn.htx` == "%###include" ) then
  echo "Not a standalone file, we stop here."
  exit
endif

if ( $fg_compil == ".false." ) then
  echo "Nothing to do!"
else
  echo "=============================== preambule / HieroDef ================================"

  # Construct full file from preambule.tex, HieroDef.txt and $FileIn.htx
  rm -f ${FileIn}_full.htx

  if ( `grep -c "%##preambule.tex" $FileIn.htx` > 0 ) then
    echo " => preambule.tex"
    cat preambule.tex >> ${FileIn}_full.htx

    if ( `grep -c '%##short' $FileIn.htx` > 0 ) then
      cat ${FileIn}_full.htx | \
          sed -e "s+##short##+`grep '%##short'   $FileIn.htx | sed -e 's+%##short *++'`+"   \
              > ${FileIn}_full.htx.tmp
      set RC = $?
      if ( $RC != 0 ) then
        exit
      endif
    else
      cat ${FileIn}_full.htx | \
          sed -e "s+##short##+`grep '%##title'   $FileIn.htx | sed -e 's+%##title *++'`+"   \
              > ${FileIn}_full.htx.tmp
      set RC = $?
      if ( $RC != 0 ) then
        exit
      endif
    endif
    mv ${FileIn}_full.htx.tmp ${FileIn}_full.htx

    cat ${FileIn}_full.htx | \
        sed -e "s+##title##+`grep '%##title'   $FileIn.htx | sed -e 's+%##title *++'`+"  \
            -e "s+##short##+`grep '%##short'   $FileIn.htx | sed -e 's+%##short *++'`+"   \
            -e "s+##date##+`grep '%##date'     $FileIn.htx | sed -e 's+%##date *++'`+"   \
            -e "s+##author##+`grep '%##author' $FileIn.htx | sed -e 's+%##author *++'`+" \
            > ${FileIn}_full.htx.tmp
    set RC = $?
    if ( $RC != 0 ) then
      exit
    endif
    mv ${FileIn}_full.htx.tmp ${FileIn}_full.htx
  endif

  if ( `grep -c "%##HieroDef.txt" $FileIn.htx` > 0 ) then
    echo " => HieroDef.txt"
    cat $HieroDef  >> ${FileIn}_full.htx
  endif
  cat $FileIn.htx >> ${FileIn}_full.htx

  # Are there .htx inputs ?
  echo "================================= Inputs / Include ================================="
  set InputList   = ""
  set IncludeList = ""
  set fg_inputs = ".false."
  echo "* Inputs"
  grep  "\\input{" ${FileIn}_full.htx
  if ( `grep -c "\\input" ${FileIn}_full.htx` > 0 ) then
    set fg_inputs = ".true."
    set InputList = `grep "\\input" ${FileIn}_full.htx | sed -e "s/\\input{//" -e "s/}//"`
  else
    echo "No input"
  endif
  # echo $fg_inputs
  echo "====="
  echo $InputList

  echo "* Includes"
  grep  "\\include{" ${FileIn}_full.htx
  if ( `grep -c "\\include{" ${FileIn}_full.htx` > 0 ) then
    set fg_inputs = ".true."
    set IncludeList = `grep "\\include{" ${FileIn}_full.htx | sed -e "s/\\include{//" -e "s/}//"`
  else
    echo "No include"
  endif
  # echo $fg_inputs
  echo "====="
  echo $IncludeList

  if ( $fg_inputs == ".true." ) then
    foreach InputFile ( $InputList $IncludeList )
      if ( -s $InputFile.htx ) then
        test $InputFile.htx -nt $InputFile.tex
        set RC = $?
        if ( $RC == 0 ) then
          echo "========================= $InputFile.htx => $InputFile.tex ========================="
          rm ${InputFile}_full.htx
          if ( `grep -c "%##HieroDef.txt" ${InputFile}.htx` > 0 ) then
            echo " => HieroDef.txt"
            cat ${HieroDef}  > ${InputFile}_full.htx
          endif
          cat ${InputFile}.htx >> ${InputFile}_full.htx

          sesh < ${InputFile}_full.htx > ${InputFile}.tex
          if ( $? != 0 ) then
            echo "Something wrong happened"
            exit
          endif
          sed -e "s+\\rm +\\rmfamily +" \
              -e "s+\\sl +\\slshape +"  \
              ${InputFile}.tex > ${InputFile}_tmp.tex
          mv ${InputFile}_tmp.tex ${InputFile}.tex
        endif
        set FilesDel = "${FilesDel} ${InputFile}.tex ${InputFile}_full.htx"
      endif
    end
  endif

  echo "========================= $FileIn.htx => $FileIn.tex ========================="
  sesh < ${FileIn}_full.htx > ${FileIn}.tex
  if ( $? != 0 ) then
    echo "Something wrong happened"
    exit
  endif

  # Change \rm (hierotek +l ?!) en \rmfamily
  sed -e "s+\\rm +\\rmfamily +" \
      -e "s+\\sl +\\slshape +"  \
      ${FileIn}.tex > ${FileIn}_tmp.tex

  # Add Encoding
  #echo "%!TEX encoding = UTF-8 Unicode" > ${FileIn}.tex
  cat ${FileIn}_tmp.tex > ${FileIn}.tex

  echo "========================= $FileIn.tex => $FileIn.pdf ========================="
  $TexComp ./$FileIn.tex
  if ( $? != 0 ) then
    echo "Something wrong happened"
    exit
  endif

endif


# Open pdf document in viewer
if ( $fg_view == ".true." ) then
  echo "========================= View $FileIn.$OutType ========================="
  $ViewBin $DirOut/$FileIn.$OutType &
endif

# Copy $FileIn.pdf to windows directory
if ( $fg_windows == ".true." ) then
  echo "========================= Copy $FileIn.$OutType to Windows directory ========================="
  if ( ! -d "$DirWin/`basename $DirOut`" ) then
    mkdir "$DirWin/`basename $DirOut`"
  endif

  cp -v $FileIn.htx              $DirWin/`basename $DirOut`
  cp -v $DirOut/$FileIn.$OutType $DirWin/`basename $DirOut`
endif

# A little cleanin'
if ( $fg_debug == ".false." || $fg_clean == ".true." ) then
  echo "========================= A little cleanin' ========================="
  rm -v $DirOut/${FileIn}_full.htx \
        $DirOut/${FileIn}_tmp.tex  \
        $DirOut/${FileIn}.run.xml  \
        $DirOut/${FileIn}.aux  \
        $DirOut/${FileIn}.dic  \
        $DirOut/${FileIn}.toc  \
        $DirOut/${FileIn}.lof  \
        $DirOut/${FileIn}.lot  \
        $DirOut/${FileIn}.log  \
        $DirOut/${FileIn}.tex  \
        $DirOut/${FileIn}.blg  \
        $DirOut/${FileIn}.bbl  \
        $DirOut/${FileIn}.bcf  \
        $DirOut/${FileIn}.mtc  \
        $DirOut/${FileIn}.mtc0 \
        $DirOut/${FileIn}.maf  \
        $DirOut/pdfcolor.aux   \
        $FilesDel
#        ${FileIn}_full.aux  \
#        ${FileIn}_full.log  \
#        ${FileIn}_full.dic  \
#        ${FileIn}_full.tex  \



endif

exit
