#!/bin/bash
#  ---- META DATA ----
#  Author            :  Daniel Hillerström - dhille10@student.aau.dk
#  Date (YYYY-MM-DD) :  2010-09-13
#  Description       :  Links all tex- & bib-files together properly
#
#  Copyright (c) Daniel Hillerström 2011
#
#  Version history   :
#           - v1.0   :  2011-09-13 initial release
#           - v2.0   :  2012-02-05 Updated LINK-DOC to load DPL, accept CLI args, include bibliography files. Done various rewrites.
#           - v2.1   :  2012-02-07 Resolved txtroot & depth bug.
#           - v2.2   :  2012-05-13 Minor consistency update.            
#           - v2.3   :  2012-09-26 Fixed linking bug on MacOSX. Thanks to Frederik Mikkelsen for reporting and helping solving the bug.

# -----------------------------------------------
#        GLOBALLY ACCESSIBLE VARIABLES
# -----------------------------------------------
# The following variables are globally accessible
# their names are conventionally in uppercase.
# -----------------------------------------------
#   PASSED CLI ARGUMENTS
# -----------------------------------------------
declare -a CLIARGUMENTS=($@)
# -----------------------------------------------
#   PATH VARIABLES
# -----------------------------------------------
BASEDIR='songs'
DOCUMENT="$1"
TEXEXTENSION='.tex'
BIBEXTENSION='.bib'
INDEXNAME="index"
TMPINDEX="$BASEDIR/$SKIPTOKEN$INDEXNAME"
SOURCEDIR='Source/Bash'
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# -----------------------------------------------
#   VARIOUS VARIABLES
# -----------------------------------------------
declare -i LINKEDFILES=0
RETURNLINKEDFILES=false
IGNORETOKEN='@'
COMMENTMARK='%'
YEAR='2011'
VERSION='2.3'
SCRIPTNAME='link-doc'
AUTHORNAME='Daniel Hillerström'
AUTHORMAIL='http://github.com/dhil/best-aalborg-songbook'
# -----------------------------------------------
#   MACRO LANGUAGE VARIABLES
# -----------------------------------------------
MACROSTRING="\[$(echo $SCRIPTNAME | awk '{print toupper($0)}')\]"
INCLUDEMACRO='include'                            # Tell link-doc to do include
INPUTMACRO='input'                                # Tell link-doc to do input
IGNOREMACRO='ignore'                              # Tell link-doc to ignore the file

# -----------------------------------------------
#                   ROUTINES
# -----------------------------------------------
# The following routines are logic abstractions.
# -----------------------------------------------
#   MACRO ARGUMENTS HANDLING
# -----------------------------------------------
# The following functions handle macro arguments
# -----------------------------------------------
#  TestMacroArg
# -----------------------------------------------
# Retrieves a macro argument from a specified file
# Input: DOCUMENT MACROARG
TestMacroArg()
{
  (grep "$MACROSTRING" "$1" | grep "$2")
  return $?
}
# -----------------------------------------------
#   DOCUMENT LINKING
# -----------------------------------------------
# The following functions are related to document linking
# -----------------------------------------------
#   WriteLink
# -----------------------------------------------
# Actually writes the include/input to the index file
WriteLink()
{
  # Including "%[LINK-DOC] include" in your document makes link-doc use include instead of input command
  # grep returns 0 on success
  filelinked=false
  # Check whether it is a tex file
  if [[ $1 == *$TEXEXTENSION && ! $(TestMacroArg "$1" "$IGNOREMACRO") ]]; then
    if [[ $(TestMacroArg "$1" "$INCLUDEMACRO") ]]; then
      echo "\\include{${1%.*}}" >> $2
    else
      echo "\\input{${1%.*}}" >> $2
    fi
    filelinked=true
  # Check whether it is a bib file
  elif [[ $1 == *$BIBEXTENSION && ! $(TestMacroArg "$1" "$IGNOREMACRO") ]]; then
    echo "\\bibliography{${1%.*}}" >> $2
    filelinked=true
  fi
  
  # Check whether LINKEDFILES should be incremented
  if [[ $filelinked == true ]]; then
    LINKEDFILES=$(($LINKEDFILES + 1))
  fi
}
# -----------------------------------------------
#   LinkFiles
# -----------------------------------------------
# Traverses all directories from argument "DIR" ($1) and downwards recursively
# Links the files together; the contents within a directory is sorted in ascending order.
# Argument 2 ($2) should be the index file
LinkFiles()
{
  # Check current depth
  if [[ $DEPTH -eq 0 || $3 -le $DEPTH ]]; then
    # Determine whether passed argument is a directory
    if [[ -d "$1" ]]; then
        # Get directory contents, filter out files with $IGNORETOKEN and whitespace
        declare -a contents=($(ls -B "$1" | grep -v -E "($IGNORETOKEN|\\s)" | sort))
        for item in ${contents[@]}; do
          LinkFiles "$1/$item" "$2" $(($3+1))
        done
    # ... or a file     
    elif [[ -f "$1" && $(echo "$1" | grep -E "($TEXEXTENSION|$BIBEXTENSION)") ]]; then
        WriteLink "$1" "$2"
    fi
  fi
}
# -----------------------------------------------
#   PrintHeaderInfo
# -----------------------------------------------
# Prints header info to index file
PrintHeaderInfo()
{
  echo "$COMMENTMARK Index file for $DOCUMENT"
  echo "$COMMENTMARK Automatically generated at $(date) by $SCRIPTNAME"
  echo "$COMMENTMARK Do not attempt to alter this file as it will be regenerated upon next compilation by $SCRIPTNAME"
}
# -----------------------------------------------
#   COMMANDLINE ARGUMENTS FUNCTIONS
# -----------------------------------------------
# The following functions form the valid cli argument list
# Double underscore       arg (__arg_)      is a call function for a long parameter
# Double underscore short arg (__shortarg_) is a call function for a short parameter.
#
# -----------------------------------------------
#  Argument Version Function
# -----------------------------------------------
__arg_version()
{
  echo "$SCRIPTNAME version $VERSION"
  echo "Copyright (c) $YEAR $AUTHORNAME <$AUTHORMAIL>"
  exit 0
}
# -----------------------------------------------
#  Argument Help & Short Argument Function
# -----------------------------------------------
__arg_help()
{
  __arg_usage 'noexit'
  echo 'Notice: DOCUMENT should be extensionless.'
  echo ''
  # Print cli parameter list
  echo 'Available OPTIONS:'
  printf '%2s%3s %-20s %-20s\n' ' ' ' ' '-r <txtroot>' 'use <txtroot> as document text root'
  printf '%2s%3s %-20s %-20s\n' ' ' ' ' '-d <depth>' 'the <depth> of traversal from textroot'
  printf '%2s%3s %-20s %-20s\n' ' ' ' ' '--return-num' 'returns number of linked files through exitcode'
  echo ''
  
  echo 'Additional available arguments:'
  printf '%2s%3s %-20s %-20s\n' ' ' ' ' '--version' 'print version information and exit'
  printf '%2s%3s %-20s %-20s\n' ' ' ' ' '--usage' 'print usage information and exit'
  printf '%2s%3s %-20s %-20s\n' ' ' '-h,' '--help' 'print this help message and exit'
  printf '%2s%3s %-20s %-20s\n' ' ' ' ' '--license' 'print license information and exit'
  echo ''
  echo 'You may specify in each text document whether it should be included, inputted or ignored.'
  echo "Report bugs to: $AUTHORMAIL, subject: LINK-DOC-bug."
  exit 0
}

__shortarg_h()
{
  __arg_help
}
# -----------------------------------------------
#  Argument Usage Function
# -----------------------------------------------
__arg_usage() 
{
  echo "usage: $SCRIPTNAME DOCUMENT [OPTIONS]..."
  if [[ $1 != 'noexit' ]]; then
    exit 1
  fi
}
# -----------------------------------------------
#  Short Argument b (text basedir) Function
# -----------------------------------------------
__shortarg_b()
{
  declare -a args=($@)
  declare -i num=$((${args[0]}+1))
  if [[ $num -lt ${#args[*]} ]]; then
    ROOTDIR="${args[$num]}"
    if [[ ! -d "$BASEDIR" ]]; then
      printf "'$BASEDIR' is not a valid directory!\n"
      exit 1
    fi
  else
    printf "Missing document text root specification!\n"
    exit 1
  fi
}
# -----------------------------------------------
#  Short Argument D (depth) Function
# -----------------------------------------------
__shortarg_d()
{
  declare -a args=($@)
  declare -i num=$((${args[0]}+1))
  if [[ $num -lt ${#args[*]} ]]; then
    DEPTH=${args[$num]}
  else
    printf "Missing depth of traversal specification!\n"
    exit 1
  fi
}
# -----------------------------------------------
#  Argument Return num Function
# -----------------------------------------------
__arg_return_num()
{
  RETURNLINKEDFILES=true
}

# -----------------------------------------------
#   CLIArgsHandler
# -----------------------------------------------
# CLIArgsHandler loop through everything passed from cli
# Arguments with dash prefix (both double and single dash) 
# are interpretated as functions.
# Double dash (--) becomes __arg_
# Single dash (-)  becomes __shortarg_
# @Input: Array of strings
CLIArgsHandler()
{
  declare -a CLIArgs=($@)
  declare -i argnum=0
  declare -i argcount=${#CLIArgs[*]}

  local func=
  local isarg=false
  # Loop through each remaining argument
  while [[ $argnum -lt $argcount ]]; do
    local argument=${CLIArgs[$argnum]}
    # Test whether it's an argument
    if [[ $argument == '--'* ]]; then
      func=$(echo $argument | sed 's/--/__arg_/' | sed 's/-/_/')
      isarg=true
    elif [[ $argument == '-'* ]]; then
      func=$(echo $argument | sed 's/-/__shortarg_/' | sed 's/-/_/')
      isarg=true
    fi
    
    # Was it an argument? Then call the function
    if [[ $isarg == true ]]; then
      # Make sure the function exists
      if [[ $(type -t $func) ]]; then
        $func $(($argnum+1)) ${CLIArgs[@]}
        isarg=false # reset
        func=
      else
        printf "Unknown argument: $argument\n"
        exit 1
      fi
    fi
    # Increase current argument number by 1
    argnum=$(($argnum + 1))
  done
}

# -----------------------------------------------
#             SCRIPT MAIN BLOCK
# -----------------------------------------------
# Logic control
# Handle CLI Arguments
CLIArgsHandler ${CLIARGUMENTS[@]}
if [[ ${#CLIARGUMENTS[*]} -lt 1 ]]; then
  __arg_usage
  exit 1
fi

# Set index
INDEX="$BASEDIR/$INDEXNAME$TEXEXTENSION"
TMPINDEX="$BASEDIR/$IGNORETOKEN$INDEXNAME$TEXEXTENSION"

# If an index file already exist then remove it
if [[ -f $INDEX ]]; then
  rm $INDEX > /dev/null
fi

# Generated index file and write header info
PrintHeaderInfo > $TMPINDEX

# Start linking process
LinkFiles "$BASEDIR" "$TMPINDEX" 0

# Rename (remove $IGNORETOKEN) from index filename
mv "$TMPINDEX" "$INDEX"

# Write statistics
echo "Successfully linked $LINKEDFILES files."

# Call main procedure
cd "$EXECDIR"
# Determine and send exitcode
declare -i exitcode=$SUCCESS_EXITCODE
if [[ $RETURNLINKEDFILES == true ]]; then
  exitcode=$LINKEDFILES
fi
exit 0
