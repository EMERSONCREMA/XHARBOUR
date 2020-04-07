/***
* Futils.ch
*
* Header file defining definitions for file handling functions.
*/

#define CR    Chr(13)
#define LF    Chr(10)
#define CRLF  CR + LF

// File's current position
#xtranslate FTell(<fHandle>) => FSeek(<fHandle>, 0, FS_RELATIVE)