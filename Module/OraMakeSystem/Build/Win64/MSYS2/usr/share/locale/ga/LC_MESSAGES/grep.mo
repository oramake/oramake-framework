??    r      ?  ?   <      ?	  ?   ?	  ?   ?
  ?   L  ?  D       /  )    Y  ?  y  Q  0  ?  ?  k    G  ?     ?  0   ?          ,  ,   H     u  ,   ?  ,   ?  '   ?  -         C  (   d  (   ?     ?     ?     ?  q   ?     j     n  *        ?  Q   ?  ?        T     k     ?     ?  $   ?     ?     ?               ,     5  :   T     ?     ?  #   ?     ?     ?  3   
     >     F  &   Y     ?     ?     ?     ?     ?  (   ?         #     0  ;   G  3   ?  /   ?  +   ?  '      #   ;      _            ?      ?      ?   4   ?      ?   "   !  !   A!     c!  0   |!  -   ?!      ?!     ?!     "     0"  $   ?"     d"     "     ?"     ?"     ?"     ?"     ?"  $   #     4#     E#  >   Y#     ?#     ?#  P   ?#  ,   $  *   J$     u$     ?$     ?$     ?$     ?$     ?$     ?$  B   ?$     4%  ?  @%  ?   ?&  ?   ?'  1  ?(    ?)  )   ,  s  .,  2  ?-  ?  ?.  ?  ?0  ?  ?2  ?  ]4  R  ?5     >7  7   Y7     ?7     ?7  5   ?7     8  2   $8  5   W8  2   ?8  6   ?8  %   ?8  3   9  6   Q9     ?9     ?9     ?9  e   ?9     (:     +:  C   <:  3   ?:  b   ?:  M   ;     e;  %   ~;  !   ?;  $   ?;  2   ?;     <      :<     [<     k<     x<  '   ?<  N   ?<     =     =     ;=     [=  -   x=  A   ?=     ?=     ?=  ;   >     L>     h>     v>     ?>     ?>  +   ?>     ?>  7  ?>     "@  K   ;@  5   ?@  1   ?@  -   ?@  )   A  %   GA  !   mA     ?A     ?A     ?A  '   ?A  M   ?A      6B  #   WB     {B     ?B  B   ?B  5   ?B  /   *C  &   ZC     ?C     ?C  0   ?C     ?C  '   D     -D  $   KD  >   pD     ?D     ?D  1   ?D     E     &E  N   FE     ?E     ?E  \   ?E  .   /F  )   ^F     ?F     ?F     ?F  (   ?F  '   ?F     ?F     G  ^   G     wG         S   K   %       P           '   O   F       ?       o       V   h   N   !   d   &       $                                M   ;   D   +   @            Z   -                 l   E             r       i   7      R   9         e   =           0   <      C   ,       
                  c       m      (   1   J               T   ^   	   ]          b       A      L   :   Y   W             B      g   "   )       8   4   H   `          I   G   j   >   [      .   2           3       X                 \   U   #   n         f   a   6   q       /   p              k       _   *           5       Q    
Context control:
  -B, --before-context=NUM  print NUM lines of leading context
  -A, --after-context=NUM   print NUM lines of trailing context
  -C, --context=NUM         print NUM lines of output context
 
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

 
Miscellaneous:
  -s, --no-messages         suppress error messages
  -v, --invert-match        select non-matching lines
  -V, --version             display version information and exit
      --help                display this help text and exit
 
Output control:
  -m, --max-count=NUM       stop after NUM matches
  -b, --byte-offset         print the byte offset with output lines
  -n, --line-number         print line number with output lines
      --line-buffered       flush output on every line
  -H, --with-filename       print the file name for each match
  -h, --no-filename         suppress the file name prefix on output
      --label=LABEL         use LABEL as the standard input file name prefix
 
Report bugs to: %s
       --include=FILE_PATTERN  search only files that match FILE_PATTERN
      --exclude=FILE_PATTERN  skip files and directories matching FILE_PATTERN
      --exclude-from=FILE   skip files matching any file pattern from FILE
      --exclude-dir=PATTERN  directories that match PATTERN will be skipped.
   -E, --extended-regexp     PATTERN is an extended regular expression (ERE)
  -F, --fixed-strings       PATTERN is a set of newline-separated strings
  -G, --basic-regexp        PATTERN is a basic regular expression (BRE)
  -P, --perl-regexp         PATTERN is a Perl regular expression
   -I                        equivalent to --binary-files=without-match
  -d, --directories=ACTION  how to handle directories;
                            ACTION is 'read', 'recurse', or 'skip'
  -D, --devices=ACTION      how to handle devices, FIFOs and sockets;
                            ACTION is 'read' or 'skip'
  -r, --recursive           like --directories=recurse
  -R, --dereference-recursive  likewise, but follow all symlinks
   -L, --files-without-match  print only names of FILEs containing no match
  -l, --files-with-matches  print only names of FILEs containing matches
  -c, --count               print only a count of matching lines per FILE
  -T, --initial-tab         make tabs line up (if needed)
  -Z, --null                print 0 byte after FILE name
   -NUM                      same as --context=NUM
      --color[=WHEN],
      --colour[=WHEN]       use markers to highlight the matching strings;
                            WHEN is 'always', 'never', or 'auto'
  -U, --binary              do not strip CR characters at EOL (MSDOS/Windows)
  -u, --unix-byte-offsets   report offsets as if CRs were not there
                            (MSDOS/Windows)

   -e, --regexp=PATTERN      use PATTERN for matching
  -f, --file=FILE           obtain PATTERN from FILE
  -i, --ignore-case         ignore case distinctions
  -w, --word-regexp         force PATTERN to match only whole words
  -x, --line-regexp         force PATTERN to match only whole lines
  -z, --null-data           a data line ends in 0 byte, not newline
   -o, --only-matching       show only the part of a line matching PATTERN
  -q, --quiet, --silent     suppress all normal output
      --binary-files=TYPE   assume that binary files are TYPE;
                            TYPE is 'binary', 'text', or 'without-match'
  -a, --text                equivalent to --binary-files=text
 %s home page: <%s>
 %s home page: <http://www.gnu.org/software/%s/>
 %s%s argument '%s' too large %s: invalid option -- '%c'
 %s: option '%c%s' doesn't allow an argument
 %s: option '%s' is ambiguous
 %s: option '%s' is ambiguous; possibilities: %s: option '--%s' doesn't allow an argument
 %s: option '--%s' requires an argument
 %s: option '-W %s' doesn't allow an argument
 %s: option '-W %s' is ambiguous
 %s: option '-W %s' requires an argument
 %s: option requires an argument -- '%c'
 %s: unrecognized option '%c%s'
 %s: unrecognized option '--%s'
 ' 'egrep' means 'grep -E'.  'fgrep' means 'grep -F'.
Direct invocation as either 'egrep' or 'fgrep' is deprecated.
 (C) (standard input) -P supports only unibyte and UTF-8 locales Binary file %s matches
 Example: %s -i 'hello world' menu.h main.c

Regexp selection and interpretation:
 General help using GNU software: <http://www.gnu.org/gethelp/>
 Invalid back reference Invalid character class name Invalid collation character Invalid content of \{\} Invalid preceding regular expression Invalid range end Invalid regular expression Memory exhausted Mike Haertel No match No previous regular expression PATTERN is, by default, a basic regular expression (BRE).
 Packaged by %s
 Packaged by %s (%s)
 Premature end of regular expression Regular expression too big Report %s bugs to: %s
 Search for PATTERN in each FILE or standard input.
 Success Trailing backslash Try '%s --help' for more information.
 Unknown system error Unmatched ( or \( Unmatched ) or \) Unmatched [, [^, [:, [., or [= Unmatched \{ Usage: %s [OPTION]... PATTERN [FILE]...
 Valid arguments are: When FILE is -, read standard input.  With no FILE, read . if a command-line
-r is given, - otherwise.  If fewer than two FILEs are given, assume -h.
Exit status is 0 if any line is selected, 1 otherwise;
if any error occurs and -q is not given, the exit status is 2.
 Written by %s and %s.
 Written by %s, %s, %s,
%s, %s, %s, %s,
%s, %s, and others.
 Written by %s, %s, %s,
%s, %s, %s, %s,
%s, and %s.
 Written by %s, %s, %s,
%s, %s, %s, %s,
and %s.
 Written by %s, %s, %s,
%s, %s, %s, and %s.
 Written by %s, %s, %s,
%s, %s, and %s.
 Written by %s, %s, %s,
%s, and %s.
 Written by %s, %s, %s,
and %s.
 Written by %s, %s, and %s.
 Written by %s.
 ` ambiguous argument %s for %s character class syntax is [[:space:]], not [:space:] conflicting matchers specified exceeded PCRE's backtracking limit exceeded PCRE's line length limit exhausted PCRE JIT stack failed to allocate memory for the PCRE JIT stack failed to return to initial working directory input file %s is also the output input is too large to count internal PCRE error: %d internal error internal error (should never happen) invalid %s%s argument '%s' invalid argument %s for %s invalid character class invalid content of \{\} invalid context length argument invalid matcher %s invalid max count invalid suffix in %s%s argument '%s' memory exhausted no syntax specified others, see <http://git.sv.gnu.org/cgit/grep.git/tree/AUTHORS> recursive directory loop regular expression too big support for the -P option is not compiled into this --disable-perl-regexp binary the -P option only supports a single pattern unable to record current working directory unbalanced ( unbalanced ) unbalanced [ unfinished \ escape unknown binary-files type unknown devices method warning: %s: %s warning: GREP_OPTIONS is deprecated; please use an alias or script write error Project-Id-Version: grep 2.26.37
Report-Msgid-Bugs-To: bug-grep@gnu.org
POT-Creation-Date: 2017-02-09 20:23-0800
PO-Revision-Date: 2017-01-04 15:48-0500
Last-Translator: Kevin Scannell <kscanne@gmail.com>
Language-Team: Irish <gaeilge-gnulinux@lists.sourceforge.net>
Language: ga
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bugs: Report translation errors to the Language-Team address.
 
Rialú comhthéacs:
  -B, --before-context=UIMH taispeáin UIMH líne de chomhthéacs tosaigh
  -A, --after-context=UIMH  taispeáin UIMH líne de chomhthéacs deiridh
  -C, --context=UIMHIR      taispeáin UIMHIR líne de chomhthéacs
 
Ceadúnas GPLv3+: GNU GPL leagan 3 nó níos nuaí <http://gnu.org/licenses/gpl.html>.
Is saorbhogearra é seo: ceadaítear duit é a athrú agus a athdháileadh.
Níl baránta AR BITH ann, an oiread atá ceadaithe de réir dlí.
 
Roghanna éagsúla:
  -s, --no-messages         ná taispeáin teachtaireachtaí earráide
  -v, --invert-match        taispeáin na línte GAN teaghrán comhoiriúnach
  -V, --version             taispeáin eolas faoin leagan agus scoir
      --help                taispeáin an chabhair seo agus scoir
 
Rialú aschurtha:
  -m, --max-count=UIMHIR    stop i ndiaidh UIMHIR líne chomhoiriúnach
  -b, --byte-offset         taispeáin an fritháireamh birt san aschur
  -n, --line-number         taispeáin líne-uimhreacha san aschur
      --line-buffered       déan sruthlú an aschuir i ndiaidh gach líne
  -H, --with-filename       taispeáin ainm comhaid le línte comhoiriúnacha
  -h, --no-filename         ná taispeáin ainmneacha comhad
      --label=LIPÉAD        úsáid LIPÉAD mar ainm ar an ngnáth-ionchur
 
Seol tuairiscí ar fhabhtanna chuig: %s
       --include=PATRÚN      déan cuardach i gcomhaid chomhoiriúnacha amháin
      --exclude=PATRÚN      ná déan cuardach i gcomhaid chomhoiriúnacha
      --exclude-from=COMHAD ná déan cuardach i gcomhaid atá comhoiriúnach le
                              haon phatrún i gCOMHAD
      --exclude-dir=PATRÚN  ná déan cuardach i gcomhadlanna comhoiriúnacha.
   -E, --extended-regexp     is slonn ionadaíochta feabhsaithe (ERE) é PATRÚN
  -F, --fixed-strings       is tacar teaghrán é PATRÚN, scartha le línte nua
  -G, --basic-regexp        is slonn ionadaíochta bunúsach (BRE) é PATRÚN
  -P, --perl-regexp         is slonn ionadaíochta Perl é PATRÚN
   -I                        ar comhbhrí le '--binary-files=without-match'
  -d, --directories=MODH    modh oibre le haghaidh comhadlanna;
                            MODH = 'read', 'recurse', nó 'skip'
  -D, --devices=MODH        modh oibre le haghaidh gléasanna, FIFOnna,
                              agus soicéid; MODH = 'read' nó 'skip'
  -r, --recursive           ar comhbhrí le '--directories=recurse'
  -R, --dereference-recursive  mar an gcéanna, ach lean naisc shiombalacha
   -L, --files-without-match ná taispeáin ach ainmneacha comhaid GAN
                              teaghrán comhoiriúnach
  -l, --files-with-matches  ná taispeáin ach ainmneacha comhaid LE
                              teaghrán comhoiriúnach
  -c, --count               ná taispeáin ach líon na dteaghrán comhoiriúnach
                              i ngach comhad
  -T, --initial-tab         Ailínigh na táib (más gá)
  -Z, --null                priontáil beart '0' i ndiaidh ainm an chomhaid
   -UIMHIR                   ar comhbhrí le '--context=UIMHIR'
      --color[=CATHAIN],
      --colour[=CATHAIN]    aibhsigh na teaghráin chomhoiriúnacha;
                            CATHAIN = 'always', 'never' nó 'auto'.
  -U, --binary              ná scrios carachtair CR (MSDOS/Windows)
  -u, --unix-byte-offsets   ná bac le CRanna agus fritháirimh á ríomh
                            (MSDOS/Windows)

   -e, --regexp=PATRÚN       déan cuardach ar PATRÚN
  -f, --file=COMHAD         faigh PATRÚN as COMHAD
  -i, --ignore-case         déan neamhaird de chás na litreacha
  -w, --word-regexp         meaitseálann PATRÚN focail iomlána amháin
  -x, --line-regexp         meaitseálann PATRÚN línte iomlána amháin
  -z, --null-data           léiríonn beart '0' deireadh na líne (vs. \n)
   -o, --only-matching       ná taispeáin ach an teaghrán comhoiriúnach
  -q, --quiet, --silent     múch an gnáth-aschur
      --binary-files=CINEÁL glac le comhaid dhénártha mar CINEÁL;
                            CINEÁL = 'binary', 'text', nó 'without-match'
  -a, --text                ar comhbhrí le '--binary-files=text'
 Leathanach baile %s: <%s>
 Leathanach baile %s: <http://www.gnu.org/software/%s/>
 argóint %s%s rómhór: '%s' %s: rogha neamhbhailí -- '%c'
 %s: ní cheadaítear argóint i ndiaidh rogha '%c%s'
 %s: tá rogha '%s' débhríoch
 %s: tá rogha '%s' débhríoch; féidearthachtaí: %s: ní cheadaítear argóint i ndiaidh rogha '--%s'
 %s: tá argóint de dhíth i ndiaidh rogha '--%s'
 %s: ní cheadaítear argóint i ndiaidh rogha '-W %s'
 %s: tá an rogha '-W %s' débhríoch
 %s: tá argóint de dhíth i ndiaidh rogha '-W %s'
 %s: tá argóint de dhíth i ndiaidh na rogha -- '%c'
 %s: rogha anaithnid '%c%s'
 %s: rogha anaithnid '--%s'
 ' 'egrep' = 'grep -E', agus 'fgrep' = 'grep -F'.
Tá na horduithe 'egrep' agus 'fgrep' imithe i léig.
 © (gnáth-ionchur) Tacaíonn an rogha -P logchaighdeáin aonbhearta agus UTF-8 amháin Teaghrán comhoiriúnach sa chomhad dhénártha %s
 Mar shampla: %s -i 'Dia duit' rogha.h príomh.c

Roghnú agus léirmhíniú sloinn ionadaíochta:
 Cabhair ghinearálta maidir le bogearraí GNU: <http://www.gnu.org/gethelp/>
 Cúltagairt neamhbhailí Ainm neamhbhailí ar aicme charachtar Carachtar neamhbhailí cóimheasa Ábhar neamhbhailí laistigh de \{\} Tá an slonn ionadaíochta roimhe seo neamhbhailí Deireadh raoin neamhbhailí Slonn ionadaíochta neamhbhailí Cuimhne ídithe Mike Haertel Níl a leithéid ann Níl aon slonn ionadaíochta roimhe seo Is slonn ionadaíochta bunúsach (BRE) é PATRÚN, de réir réamhshocraithe.
 Arna phacáistiú ag %s
 Arna phacáistiú ag %s (%s)
 Deireadh an tsloinn gan choinne Slonn ionadaíochta rómhór Seol tuairiscí ar fhabhtanna i %s chuig: %s
 Déan cuardach ar PATRÚN i ngach COMHAD nó sa ghnáth-ionchur.
 D'éirigh leis Cúlslais ag an deireadh Bain triail as '%s --help' chun tuilleadh eolais a fháil.
 Earráid anaithnid chórais ( nó \( corr ) nó \) corr [, [^, [:, [., nó [= corr \{ corr Úsáid: %s [ROGHA]... PATRÚN [COMHAD]...
 Na hargóintí bailí: Más é '-' an COMHAD, léigh ón ionchur caighdeánach. Gan COMHAD ar bith,
léigh . má tá an rogha -r ann, agus - mura bhfuil. Má tá níos lú ná dhá
chomhad ann, úsáid '-h'. Stádas scortha: 0 (roghnaíodh aon líne ar a laghad),
1 (níor roghnaíodh), nó 2 (earráid ar bith agus níor tugadh -q).
 Scríofa ag %s agus %s.
 Scríofa ag %s, %s, %s,
%s, %s, %s, %s,
%s, %s, agus daoine eile nach iad.
 Scríofa ag %s, %s, %s,
%s, %s, %s, %s,
%s, agus %s.
 Scríofa ag %s, %s, %s,
%s, %s, %s, %s,
agus %s.
 Scríofa ag %s, %s, %s,
%s, %s, %s, agus %s.
 Scríofa ag %s, %s, %s,
%s, %s, agus %s.
 Scríofa ag %s, %s, %s,
%s, agus %s.
 Scríofa ag %s, %s, %s,
agus %s.
 Scríofa ag %s, %s, agus %s.
 Scríofa ag %s.
 ` argóint dhébhríoch %s le haghaidh %s Is é [[:space:]] an chomhréir cheart in aicme carachtar, in ionad [:space:] sonraíodh patrúin chontrártha sáraíodh teorainn PCRE ar chúlú sáraíodh uasfhad líne PCRE cruach PCRE JIT líonta níorbh fhéidir cuimhne a dháil le haghaidh na cruaiche PCRE JIT níorbh fhéidir filleadh ar an mbunchomhadlann oibre is ionann an t-inchomhad %s agus an t-aschomhad tá an t-ionchur rómhór le háireamh earráid inmheánach PCRE: %d earráid inmheánach earráid inmheánach (ní tharlaíonn seo riamh) argóint neamhbhailí %s%s '%s' argóint neamhbhailí %s le haghaidh %s Aicme charachtar neamhbhailí ábhar neamhbhailí laistigh de \{\} tá an argóint a shonraíonn fad an chomhthéacs neamhbhailí meaitseálaí neamhbhailí %s uasmhéid neamhbhailí iarmhír neamhbhailí tar éis argóint %s%s '%s' cuimhne ídithe níor sonraíodh aon chomhréir agus daoine eile, féach ar <http://git.sv.gnu.org/cgit/grep.git/tree/AUTHORS> lúb athchúrsach i gcomhadlann slonn ionadaíochta rómhór Tiomsaíodh an clár dénártha seo le --disable-perl-regexp agus gan tacaíocht do rogha -P Ní thacaíonn rogha -P ach le patrún amháin ní féidir an chomhadlann oibre a fháil ( corr ) corr [ corr Seicheamh éalúcháin \ gan chríochnú cineál anaithnid de chomhad dénártha modh anaithnid gléasanna rabhadh: %s: %s rabhadh: ní mholtar GREP_OPTIONS a úsáid a thuilleadh; bain úsáid as ailias nó as script earráid sa scríobh 