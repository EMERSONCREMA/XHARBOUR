// Tbutils.ch
//
// Utility commands, translates, and constants for TBrowse and TBColumn
// classes
//
// Defines:
//    DEF_HSEP   Default heading separator characters
//    DEF_CSEP   Default column separator characters
//    DEF_FSEP   Default column footing characters
//
// Macros:
//    INCLAST   Increment last character of a string
//
// Translates:
//    myTBColumnNew  Allows keywords in myTBColumnNew() call
//    myTBRowseNew   Allows keywords in myTBRowseNew() call
//
// Commands:
//    CREATE TBROWSE  OBJECT  Allows keywords to create tbrowse object
//    CREATE TBCOLUMN OBJECT  Allows keywords to create tbcolumn object

    // Default column separator
    #define DEF_CSEP  " " + chr(179) + " "

    // Default heading separator
    #define DEF_HSEP chr(205) + chr(209) + chr(205)

    // Default footing separator
    #define DEF_FSEP chr(205) + chr(207) + chr(205)


    // Increment last character of a string. Useful for scoped tbrowses
    #define INCLAST(c) substr(c, 1, len(c) - 1) + ;
                       chr( asc( substr( c, len(c) ) ) + 1)


    #xtranslate APPEND_MODE(<oTbr>) ;
                =>                  ;
                DictAt(<oTbr>:cargo, "Append Mode")

    #xtranslate APPEND_MODE(<oTbr>, <lAppend>) ;
                =>                 ;
                DictPut(<oTbr>:cargo, "Append Mode", <lAppend>)


    #command CREATE TBCOLUMN OBJECT <oTbc> ;
             [BLOCK      <block>      ] ;
             [CARGO      <cargo>      ] ;
             [COLORBLOCK <colorBlock> ] ;
             [COLSEP     <colSep>     ] ;
             [DEFCOLOR   <defColor>   ] ;
             [FOOTING    <footing>    ] ;
             [FOOTSEP    <footSep>    ] ;
             [HEADING    <heading>    ] ;
             [HEADSEP    <headSep>    ] ;
             [WIDTH      <width>      ] ;
    => ;
    <oTbc> := myTBColumnNew(<block>,   <cargo>,   <colorBlock>, ;
                            <colSep>,  <defColor>,<footing>,    ;
                            <footSep>, <heading>, <headSep>,    ;
                            <width>)

    #xtranslate myTBColumnNew(                             ;
                              [ BLOCK      <block>      [,] ] ;
                              [ CARGO      <cargo>      [,] ] ;
                              [ COLORBLOCK <colorBlock> [,] ] ;
                              [ COLSEP     <colSep>     [,] ] ;
                              [ DEFCOLOR   <defColor>   [,] ] ;
                              [ FOOTING    <footing>    [,] ] ;
                              [ FOOTSEP    <footSep>    [,] ] ;
                              [ HEADING    <heading>    [,] ] ;
                              [ HEADSEP    <headSep>    [,] ] ;
                              [ WIDTH      <width>      [,] ] ;
                             )                                 ;
    => ;
    myTBColumnNew(<block>,   <cargo>,    <colorBlock>, ;
                  <colSep>,  <defColor>, <footing>,    ;
                  <footSep>, <heading>,  <headSep>,    ;
                  <width>)


    // Listing 1.7
    #command CREATE TBROWSE OBJECT <oTbr> ;
             [AUTOLITE             <autoLite>      ] ;
             [CARGO                <cargo>         ] ;
             [COLORSPEC            <colorSpec>     ] ;
             [COLPOS               <colPos>        ] ;
             [COLSEP               <colSep>        ] ;
             [FOOTSEP              <footSep>       ] ;
             [FREEZE               <freeze>        ] ;
             [GOBOTTOMBLOCK        <goBottomBlock> ] ;
             [GOTOPBLOCK           <goTopBlock>    ] ;
             [HEADSEP              <headSep>       ] ;
             [HITBOTTOM            <hitBottom>     ] ;
             [HITTOP               <hitTop>        ] ;
             [NBOTTOM              <nBottom>       ] ;
             [NLEFT                <nLeft>         ] ;
             [NRIGHT               <nRight>        ] ;
             [NTOP                 <nTop>          ] ;
             [ROWPOS               <rowPos>        ] ;
             [SKIPBLOCK            <skipBlock>     ] ;
             [STABLE               <stable>        ] ;
    => ;
    <oTbr> := MyTBrowseNew(<autoLite>, <cargo>,         <colorSpec>,  ;
                           <colPos>,   <colSep>,        <footSep>,    ;
                           <freeze>,   <goBottomBlock>, <goTopBlock>, ;
                           <headSep>,  <hitBottom>,     <hitTop>,     ;
                           <nBottom>,  <nLeft>,         <nRight>,     ;
                           <nTop>,     <rowPos>,        <skipBlock>,  ;
                           <stable> )


    // Listing 1.8
    #xtranslate myTbrowseNew( ;
                             [AUTOLITE      <autoLite>        [,] ] ;
                             [CARGO         <cargo>           [,] ] ;
                             [COLORSPEC     <colorSpec>       [,] ] ;
                             [COLPOS        <colPos>          [,] ] ;
                             [COLSEP        <colSep>          [,] ] ;
                             [FOOTSEP       <footSep>         [,] ] ;
                             [FREEZE        <freeze>          [,] ] ;
                             [GOBOTTOMBLOCK <goBottomBlock>   [,] ] ;
                             [GOTOPBLOCK    <goTopBlock>      [,] ] ;
                             [HEADSEP       <headSep>         [,] ] ;
                             [HITBOTTOM     <hitBottom>       [,] ] ;
                             [HITTOP        <hitTop>          [,] ] ;
                             [NBOTTOM       <nBottom>         [,] ] ;
                             [NLEFT         <nLeft>           [,] ] ;
                             [NRIGHT        <nRight>          [,] ] ;
                             [NTOP          <nTop>            [,] ] ;
                             [ROWPOS        <rowPos>          [,] ] ;
                             [SKIPBLOCK     <skipBlock>       [,] ] ;
                             [STABLE        <stable>          [,] ] ;
                            ) ;
    => ;
    MyTBrowseNew(<autoLite>, <cargo>,         <colorSpec>,  ;
                 <colPos>,   <colSep>,        <footSep>,    ;
                 <freeze>,   <goBottomBlock>, <goTopBlock>, ;
                 <headSep>,  <hitBottom>,     <hitTop>,     ;
                 <nBottom>,  <nLeft>,         <nRight>,     ;
                 <nTop>,     <rowPos>,        <skipBlock>,  ;
                 <stable> )

    #define ARRAY_SKIPPER(i, a) {|n, nSavei|  ;
                                 nSavei := i, ;
                                 i := iif (n > 0, ;
                                           Min(Len(a), i + n), ;
                                           Max(1, i + n)),     ;
                                 i - nSavei}