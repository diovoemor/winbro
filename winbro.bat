@rem #############################################################
@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!C:\usr\bin\perl.EXE -w
#line 15
##################################################################
# Script Name: Winbro, my Brotli build for Windows
# FileName: winbro.bat
# Date: October 6, 2017
# Copyright (c) 2017, Gregg Smith <gregg apachehaus com>
#
$wbv = '1.0.0';
$wbcy = '2017';
#
my $brolib = 'libbrotli';
my $sver= 'common/version.h';
my $obv=  'include/brotli/brotliv.h';
my $orc = 'brotli.rc';
my $omk = 'makefile.msvc';
my $odp = $brolib.'.def';
my $owt = 'winbuild.txt';
# 
##################################################################
system(CLS);
my ($broh,$rcfc,$makc,$dfc,$dfca,$dfcb,$dfcc);
my ($base,@bvc,$cry);


##################################################################
#COMMON#

sub read_file {
 (my $rf)=@_;
  my @fc; $rf=~s/\n//;
  if (-e "$rf") {
    open(R,$rf) || die ("Can't Open File: $rf\n"); 
    @fc = <R>;
    close(R);
  }
  else {
    die ("Cannot find file: $rf\n");
  }
  chop @fc;
  return @fc;
} # End sub read_file

##################################################################
#PRIVATE#

sub swapstuff {
  my (@stuff)=@_;
  my $swap = join("\n", @stuff);
  $swap=~s|<BVMR>|$bvmaj|g;
  $swap=~s|<BVMN>|$bvmin|g;
  $swap=~s|<BVRV>|$bvrev|g;
  $swap=~s|<BVSTR>|$bvstr|g;
  $swap=~s|<BROH>|$obv|g;
  $swap=~s|<BROLIB>|$brolib|g;
  $swap=~s|<RCFILE>|$orc|g;
  $swap=~s|<CPRT>|$cr[0]|g;
  (@stuff)=split(/\n/,$swap);
  return @stuff;
}

sub prelude {
  print "Winbro version $wbv\n";
  print "Copyright (c) ".$wbcy.", Gregg Smith\n\n"
}

sub verinfo {
  print "Version info\n------------\n";
  print "Major:    ".$bvmaj."\n";
  print "Minor:    ".$bvmin."\n";
  print "Revision: ".$bvrev."\n";
  print "String:   ".$bvstr."\n\n";
}

sub postlude {
  print "\nSee $owt for nmake command information.\n\n";
}

##################################################################
#MAIN#

&prelude;
my @data=<DATA>;
my $data = join("\n",@data);
$data=~s|\n\n|\n|g;

$base = 'c/' if -e './c';
$obv = $base.$obv; $sver = $base.$sver;
@bvc = read_file($sver);

my ($broh,$rcfc,$makc,$wtxt,$dfc,$dfca,$dfcb,$dfcc) = split(/<SPLIT>/,$data);

@cr = grep(/Copyright/,@bvc);
@bvc = grep(/BROTLI_VERSION/,@bvc);

($bvmaj,$bvmin,$bvrev)=($bvc[0] =~ / 0x(\d)(\d\d\d)(\d\d\d)/);
$bvmin = sprintf("%d",$bvmin);
$bvrev = sprintf("%d",$bvrev);
$bvstr = "$bvmaj.$bvmin.$bvrev";
&verinfo;
#my $cprt = $cr[0];
$cr[0] =~ s|^/\* ||;
my @brohc = swapstuff($broh);
$broh = join("\n",@brohc);
my @rcfcc = swapstuff($rcfc);
$rcfc =  join("\n",@rcfcc);
my @makcc = swapstuff($makc);
$makc =  join("\n",@makcc);
my $defc = $dfc;
$defc = $dfc.$dfca if $bvstr eq '0.6.0';

# Out: brotliv.h
print "Generating $obv\n";
open($f,">$obv") || die ("Can't open $obv for output");
print $f $broh."\n";
close($f);

# Out: brotli.rc
print "Generating $orc\n";
open($f,">$orc") || die ("Can't open $orc for output");
print $f $rcfc."\n";
close($f);

# Out: makefile.msvc
print "Generating $omk\n";
open($f,">$omk") || die ("Can't open $omk for output");
print $f $makc."\n";
close($f);

# Out: def file
print "Generating $odp\n";
open($f,">$odp") || die ("Can't open $odp for output");
print $f $defc."\n";
close($f);

print "Generating $owt\n";
open($f,">$owt") || die ("Can't open $owt for output");
print $f $wtxt."\n";
close($f);

&postlude;
exit 0;

##################################################################
#<SPLIT>
__DATA__
#ifndef BROTLIV_H
#define BROTLIV_H

#define BROTLI_VERSION_MAJOR       <BVMR>
#define BROTLI_VERSION_MINOR       <BVMN>
#define BROTLI_VERSION_REVISION    <BVRV>

#define BROTLI_VERSION_STRING      "<BVSTR>"
#define BROTLI_LIB_NAME            "<BROLIB>"

#define BROTLI_COPYRIGHT     "<CPRT>"

#endif /* BROTLIV_H */

<SPLIT>
  #include <winver.h>
  #include "<BROH>"

  #ifdef _WIN64
  #  define ARCH "64"
  #else
  #  define ARCH "32"
  #endif

  #ifdef BSTYLE
  #define BCOMMENT "Brotli Command Line Tool"
  #define BNAME    "brotli"
  #define BEXT     "exe"
  #else
  #define BCOMMENT "Brotli Compression Library"
  #define BNAME BROTLI_LIB_NAME
  #define BEXT  "dll"
  #endif

  VS_VERSION_INFO VERSIONINFO
    FILEVERSION    BROTLI_VERSION_REVISION, BROTLI_VERSION_MINOR, BROTLI_VERSION_REVISION, 0
    PRODUCTVERSION BROTLI_VERSION_REVISION, BROTLI_VERSION_MINOR, BROTLI_VERSION_REVISION, 0
    FILEFLAGSMASK  0x3fL
    FILEOS         0x40004L
    FILETYPE       0x2L
    FILESUBTYPE    0x0L
  #ifdef _DEBUG
    #define        BROCOMMENT  "MSVC Win" ARCH " debug build"
    #define        BDEBUG      "d"
    FILEFLAGS      0x1L
  #else
    #define        BROCOMMENT  "MSVC Win" ARCH " release build"
    #define        BDEBUG      ""
    FILEFLAGS      0x0L
  #endif
  BEGIN
    BLOCK "StringFileInfo"
    BEGIN
      BLOCK "040904b0"
      BEGIN
        VALUE "Comments", "Win" ARCH " MSVC Build"
        VALUE "FileDescription",  BCOMMENT
        VALUE "FileVersion",      BROTLI_VERSION_STRING
        VALUE "InternalName",     BNAME BDEBUG
        VALUE "LegalCopyright",   BROTLI_COPYRIGHT
        VALUE "OriginalFilename", BNAME BDEBUG "." BEXT
        VALUE "ProductName",      "Brotli"
        VALUE "ProductVersion",   BROTLI_VERSION_STRING
      END
    END
  BLOCK "VarFileInfo"
  BEGIN
    VALUE "Translation", 0x409, 1200
  END
  END
<SPLIT>#Index: makefile.msvc
#==============================================================================
# October 6, 2017
#
# NMAKE makefile for Brotli library for Windows VC++ developers. 
# Provided by Gregg Smith <gregg apachehaus com>
# Produces bro(tli).exe, brotli.dll and brotli.lib
#
# see winbuild.txt for usage information
#
#==============================================================================
!IF "$(PLATFORM)" == "X64"
ARCH     = X64
!ENDIF

!IF "$(ARCH)" == "x64" || "$(ARCH)" == "X64"
RCFLAGS  = -D_WIN64
!ELSE
ARCH     = X86
!ENDIF

!IF "$(INSTDIR)" == ""
INSTDIR = C:\Brotli
!ENDIF

COMPILER = cl
!IF "$(DEBUG)" == ""
CFLAGS = /nologo /MD /W3 /O2 /Oy- /Zi /c /I ../include \
         /D_CRT_SECURE_NO_DEPRECATE /DNDEBUG
!ELSE
SHORT = d
CFLAGS =/nologo /MDd /W3 /EHsc /Zi /Od /c /I ../include \
        /D_CRT_SECURE_NO_DEPRECATE /D_DEBUG
!ENDIF

CC = $(COMPILER) $(CFLAGS)
LB = lib /nologo
LINK = link /nologo
LD = $(LINK) /dll /manifest /subsystem:windows /machine:$(ARCH) /debug
LE = $(LINK) /manifest /subsystem:console /machine:$(ARCH) /debug
MT = mt
RC = rc

!IF EXIST (".\c\tools\brotli.c")
BROEXE = brotli
BP  = c/
BPW = c\ 
BPB = \..
!ELSE
BROEXE = bro
!ENDIF

LIBNAME = <BROLIB>
RCFILE  = <RCFILE>
COMOBJ  = $(BP)common/dictionary.obj $(BP)common/transform.obj
DECOBJS = $(BP)dec/bit_reader.obj $(BP)dec/decode.obj $(BP)dec/huffman.obj $(BP)dec/state.obj
ENCOBJS = $(BP)enc/backward_references.obj $(BP)enc/backward_references_hq.obj \
          $(BP)enc/block_splitter.obj $(BP)enc/bit_cost.obj $(BP)enc/brotli_bit_stream.obj \
          $(BP)enc/cluster.obj $(BP)enc/compress_fragment.obj $(BP)enc/compress_fragment_two_pass.obj \
          $(BP)enc/dictionary_hash.obj $(BP)enc/encode.obj $(BP)enc/encoder_dict.obj $(BP)enc/entropy_encode.obj \
          $(BP)enc/histogram.obj $(BP)enc/literal_cost.obj $(BP)enc/memory.obj $(BP)enc/metablock.obj \
          $(BP)enc/static_dict.obj $(BP)enc/utf8_util.obj

          
# intro comn decode encode install static cleanman cleanobj cleanrel outro res
all: intro comn decode encode brolib bro cleanman cleanobj outro

clean: cleanrel

comn:
   @cd $(BP)common
   $(CC) *.c
   @cd ..$(BPB)

decode:
   @cd $(BP)dec
   $(CC) *.c 
   @cd ..$(BPB)

encode:
   @cd $(BP)enc
   $(CC) *.c 
   @cd ..$(BPB)

bro: 
   cd $(BPW)tools
   $(CC) $(BROEXE).c 
   @cd ..$(BPB)
   $(LE) kernel32.lib broapp.res ./$(LIBNAME)$(SHORT).lib $(BP)tools/$(BROEXE).obj \
         /IMPLIB:./brotliapp.lib /OUT:./$(BROEXE)$(SHORT).exe
   $(MT) -manifest ./$(BROEXE)$(SHORT).exe.manifest -outputresource:./$(BROEXE)$(SHORT).exe;1

brolib: res
   $(LD) kernel32.lib brolib.res /DEF:$(LIBNAME).def /IMPLIB:./$(LIBNAME)$(SHORT).lib \
         /OUT:./$(LIBNAME)$(SHORT).dll $(COMOBJ) $(DECOBJS) $(ENCOBJS) 
   $(MT) -manifest ./$(LIBNAME)$(SHORT).dll.manifest -outputresource:./$(LIBNAME)$(SHORT).dll;2

res:
   $(RC) $(RCFLAGS) /fobrolib.res $(RCFILE)
   $(RC) $(RCFLAGS) -DBSTYLE /fobroapp.res $(RCFILE)

install:
   @xcopy /q /s /v /y $(BPW)include\*.* $(INSTDIR)\include\*.*
   @xcopy /q /s /v /y $(LIBNAME)$(SHORT).* $(INSTDIR)\*.*
   @copy /v /y $(BROEXE)$(SHORT).exe $(INSTDIR)\$(BROEXE)$(SHORT).exe

cleanobj:
   @del /s /q *.obj *.pdb *.res

cleanman:
   @del /s /q *.manifest

cleanrel:
   @del /s /q *.dll *.exe *.exp *.lib *.manifest *.pdb
#   @rd /s /q $(OUTDIR)

intro:
  @echo ###############################
  @echo # Building Brotli (MSVC) $(ARCH)  #
  @echo ###############################

outro:
  @echo ###############################
  @echo #  Building Brotli Complete   #
  @echo ###############################
<SPLIT># Build Examples:
#
# To build a Release dll, link library and executable,
# from the sources base folder use:
#     
#     nmake /f makefile.msvc [options]
#
#     Options:
#
#     Winbro gets x86 or x64 build target info directly
#     from Visual C++ 2010 and up. For an x64 build on 
#     Visual C++ less than 2010 use:
#    
#     nmake /f makefile.msvc arch=x64
#
#     For Debug build add "debug=1"
#     Example:
#     nmake /f makefile.msvc debug=1
#
# Install:
#
# To install binaries and includes to C:\Brotli use:
#
#     nmake /f makefile.msvc install
#
#     Use INSTDIR to override the default directory
#     Example:
#     nmake /f makefile.msvc instdir=Z:\MyApps\Brotli install
#
<SPLIT>EXPORTS
BrotliAllocate
BrotliBuildAndStoreHuffmanTreeFast
BrotliBuildCodeLengthsHuffmanTable
BrotliBuildHistogramsWithContext
BrotliBuildHuffmanTable
BrotliBuildMetaBlock
BrotliBuildMetaBlockGreedy
BrotliBuildSimpleHuffmanTable
BrotliClusterHistogramsCommand
BrotliClusterHistogramsDistance
BrotliClusterHistogramsLiteral
BrotliCompareAndPushToQueueCommand
BrotliCompareAndPushToQueueDistance
BrotliCompareAndPushToQueueLiteral
BrotliCompressFragmentFast
BrotliCompressFragmentTwoPass
BrotliConvertBitDepthsToSymbols
BrotliCreateBackwardReferences
BrotliCreateHuffmanTree
BrotliDecoderCreateInstance
BrotliDecoderDecompress
BrotliDecoderDecompressStream
BrotliDecoderDestroyInstance
BrotliDecoderErrorString
BrotliDecoderGetErrorCode
BrotliDecoderHasMoreOutput
BrotliDecoderHuffmanTreeGroupInit
BrotliDecoderIsFinished
BrotliDecoderIsUsed
BrotliDecoderStateCleanup
BrotliDecoderStateCleanupAfterMetablock
BrotliDecoderStateInit
BrotliDecoderStateMetablockBegin
BrotliDecoderTakeOutput
BrotliDecoderVersion
BrotliDestroyBlockSplit
BrotliEncoderCompress
BrotliEncoderCompressStream
BrotliEncoderCreateInstance
BrotliEncoderDestroyInstance
BrotliEncoderHasMoreOutput
BrotliEncoderIsFinished
BrotliEncoderMaxCompressedSize
BrotliEncoderSetParameter
BrotliEncoderTakeOutput
BrotliEncoderVersion
BrotliEstimateBitCostsForLiterals
BrotliFindAllStaticDictionaryMatches
BrotliFree
BrotliGetTransforms
BrotliHistogramBitCostDistanceCommand
BrotliHistogramBitCostDistanceDistance
BrotliHistogramBitCostDistanceLiteral
BrotliHistogramCombineCommand
BrotliHistogramCombineDistance
BrotliHistogramCombineLiteral
BrotliHistogramReindexCommand
BrotliHistogramReindexDistance
BrotliHistogramReindexLiteral
BrotliHistogramRemapCommand
BrotliHistogramRemapDistance
BrotliHistogramRemapLiteral
BrotliInitBitReader
BrotliInitBlockSplit
BrotliInitEncoderDictionary
BrotliInitMemoryManager
BrotliInitZopfliNodes
BrotliIsMostlyUTF8
BrotliOptimizeHistograms
BrotliOptimizeHuffmanCountsForRle
BrotliPopulationCostCommand
BrotliPopulationCostDistance
BrotliPopulationCostLiteral
BrotliSetDepth
BrotliSplitBlock
BrotliStoreHuffmanTree
BrotliStoreMetaBlock
BrotliStoreMetaBlockFast
BrotliStoreMetaBlockTrivial
BrotliStoreUncompressedMetaBlock
BrotliTransformDictionaryWord
BrotliWarmupBitReader
BrotliWipeOutMemoryManager
BrotliWriteHuffmanTree
BrotliZopfliComputeShortestPath
BrotliZopfliCreateCommands
<SPLIT>BrotliDecoderSetCustomDictionary
BrotliEncoderSetCustomDictionary
BrotliStoreSyncMetaBlock
<SPLIT>
<SPLIT>
<SPLIT>

#  $swap=~s|||g;

__END__
:endofperl
