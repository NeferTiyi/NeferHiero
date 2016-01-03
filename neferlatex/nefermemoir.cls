% .. Identification ..
% ====================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nefermemoir}%
  [2015/06/20 v0.1 based on memoir class]

% .. Code initial ..
% ==================
\usepackage{etoolbox}
\providebool{hiero}
\providebool{egypto}
\providebool{coptic}

% .. Declaration options ..
% =========================
\DeclareOption{coptic}{\booltrue{coptic}}
\DeclareOption{egypto}{\booltrue{egypto}}
\DeclareOption{hiero}{%
  \booltrue{egypto}\booltrue{hiero}%
  \PassOptionsToPackage{hiero}{neferegypto}%
}
\DeclareOption{background}{%
  \PassOptionsToPackage{background}{nefertiyi}%
}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{memoir}}

% .. Execution options ..
% =======================
\ProcessOptions

% .. Chargement extensions ..
% ===========================
\LoadClass{memoir}

\ifbool{coptic}{\RequirePackage{coptic}}{}

\RequirePackage{nefertiyi}%

\ifbool{egypto}{\RequirePackage{neferegypto}}{}

% .. Commandes spéciales ..
% =========================

% Numérotation des division et prise en compte dans la TOC
\maxsecnumdepth{subsection}
\maxtocdepth{subsection}
\setcounter{lofdepth}{2}
\setcounter{lotdepth}{2}

\counterwithin{part}{book}
\counterwithin{chapter}{book}

% Apparence des numéros de divisions
\renewcommand{\thepart}{\arabic{part}}
\renewcommand{\thechapter}{\arabic{chapter}}
\renewcommand{\thesubsection}{\alph{subsection})}

% Indentation et largeur des numéros dans la TOC
\cftsetindents{book}{\cftbookindent}{3.0em}
\cftsetindents{part}{\cftpartindent}{2.6em}
\cftsetindents{chapter}{\cftchapterindent}{1.8em}
\cftsetindents{subsection}{\cftsubsectionindent}{1.4em}

\cftsetindents{table}{\cfttableindent}{4.5em}
\cftsetindents{figure}{\cftfigureindent}{4.5em}
% \cftsetindents{subfigure}{\cftfigureindent}{3.0em}

% Pointillés dans la TOC
\renewcommand{\cftsectiondotsep}{9}
\renewcommand{\cftsubsectiondotsep}{1}


% Entry         Level        Standard        memoir class
%                         indent numwidth   indent numwidth 
% ---------------------------------------------------------
% book             -2       —      —          0.0    —
% part             -1       0.0    —          0.0    1.5 
% chapter           0       0.0    1.5        0.0    1.5
% section           1       1.5    2.3        1.5    2.3
% subsection        2       3.8    3.2        3.8    3.2
% subsubsection     3       7.0    4.1        7.0    4.1
% paragraph         4      10.0    5.0       10.0    5.0
% subparagraph      5      12.0    6.0       12.0    6.0
% figure/table     (1)      1.5    2.3        0.0    1.5
% subfigure/table  (2)      —      —          1.5    2.3


% Macro               Default           Usage
% ---------------------------------------------------------------------
% \abstractname       Abstract          title for abstract environment
% \alsoname           see also          used by \seealso
% \amname             am                used in printing time of day
% \appendixname       Appendix          name for an appendix heading
% \appendixpagename   Appendices        name for an \appendixpage
% \appendixtocname    Appendices        ToC entry announcing appendices
% \bibname            Bibliography      title for \thebibliography
% \bookname           Book              name for \book heading
% \bookrefname        Book              used by \Bref
% \chaptername        Chapter           name for \chapter heading
% \chapterrefname     Chapter           used by \Cref
% \contentsname       Contents          title for \tableofcontents
% \figurename         Figure            name for ﬁgure \caption
% \figurerefname      Figure            used by \fref
% \glossaryname       Glossary          title for \theglossary
% \indexname          Index             title for \theindex
% \lcminusname        minus             used in named number formatting
% \listfigurename     List of Figures   title for \listoffigugres
% \listtablename      List of Tables    title for \listoftables
% \minusname          minus             used in named number formatting
% \namenumberand      and               used in named number formatting
% \namenumbercomma    ,                 used in named number formatting
% \notesname          Notes             title of \notedivision
% \pagename           page              for your use
% \pagerefname        page              used by \pref
% \partname           Part              name for \part heading
% \partrefname        Part              used by \Pref
% \pmnane             pm                used in printing time of day
% \sectionrefname     §                 used by \Sref
% \seename            see               used by \see
% \tablename          Table             name for table \caption
% \tablerefname       Table             used by \tref
% \ucminusname        Minus             used in named number formatting
% ---------------------------------------------------------------------

\AtBeginDocument{%
  \renewcommand{\figurerefname}{figure}
  \renewcommand{\tablerefname}{tableau}
  \renewcommand{\appendixrefname}{annexe~}
  \renewcommand{\bookrefname}{livre~}
  \renewcommand{\chapterrefname}{chapitre~}
  \renewcommand{\partrefname}{partie~}

  \renewcommand{\bookname}{Livre}
  \renewcommand{\appendixpagename}{Annexes}
  \renewcommand{\appendixtocname}{\appendixpagename}
  \renewcommand{\listfigurename}{Table des illustrations}
}

\setlength{\cftbookindent}{-3em}

\setpnumwidth{2.55em}
\setrmarg{3.55em}


% Page size
\settypeblocksize{22cm}{15cm}{*}
\setulmargins{*}{*}{1}
\setlrmargins{*}{*}{1.3}
% \setmarginnotes{17pt}{51pt}{\onelineskip}
\setheadfoot{2\onelineskip}{5\onelineskip}
\setheaderspaces{*}{2\onelineskip}{*}
\checkandfixthelayout


% Floats
\setfloatadjustment{figure}{\centerfloat}
\setfloatadjustment{table}{\centerfloat}
\newsubfloat{figure}

% Captions
\captionnamefont{\small\bfseries\sffamily}
\captiontitlefont{\small\sffamily}
\subcaptionlabelfont{\bfseries\sffamily}
\subcaptionfont{\sffamily}
\captiondelim{~-- }

\newcommand{\CaptionNormal}{%
  \captionwidth{0.75\linewidth}%
  \changecaptionwidth%
  \hangcaption%
}
\newcommand{\CaptionPetit}{%
  \normalcaptionwidth%
  \normalcaption%
}

\renewcommand\@memfront@floats{%
  \counterwithout{figure}{chapter}
  \counterwithout{table}{chapter}
}
\renewcommand\@memmain@floats{%
  \counterwithout{figure}{chapter}
  \counterwithout{table}{chapter}
  \counterwithin{figure}{book}
  \counterwithin{table}{book}
}
\renewcommand\@memback@floats{%
  \counterwithout{figure}{chapter}
  \counterwithout{table}{chapter}
  \setcounter{figure}{0}
  \setcounter{table}{0}
}

\endinput
