#!/bin/bash
#
# A small "library" to simplify the handling of commandline arguments.
# 
# Copyright (C) 2015 Kathrin Hanauer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

######################################################################
# ECLA variables.
######################################################################
ECLA_NAME="ECLA - Easy Command Line Arguments"
ECLA_VERSION="0.0.2"
ECLA_DESC="A small bash library to simplify the handling of \
commandline arguments"
######################################################################

######################################################################
# Program variables.
######################################################################
ECLA_PROGRAM_NAME="${0##*/}"
ECLA_PROGRAM_VERSION="0"
ECLA_PROGRAM_DESC=""
declare -a ECLA_ARG_NAME
declare -a ECLA_ARG_PARAMS
declare -a ECLA_ARG_OPTIONAL
declare -a ECLA_ARG_DESC
declare -a ECLA_ARG_CALLBACK
declare ECLA_UNPROCESSED_ARGS

ECLA_ARG_HELP="displays this help and exits."
ECLA_ARG_VERSION="displays the version and exits."
######################################################################

######################################################################
# Functions.
######################################################################
ecla_show_version() {
  echo -e "This is ${ECLA_PROGRAM_NAME} version ${ECLA_PROGRAM_VERSION}".
 
  if [ -n "$1" ]
  then
    exit $1
  fi
}
######################################################################

######################################################################
ecla_show_help() {
  echo -ne "This is ${ECLA_PROGRAM_NAME}" 
  
  if [ -n "${ECLA_PROGRAM_VERSION}" ]
  then
    echo -e " version ${ECLA_PROGRAM_VERSION}."
  else
    echo -e "."
  fi
  
  echo -e
  
  if [ -n "${ECLA_PROGRAM_DESC}" ]
  then
    echo -e "Description:"
    echo -e "${ECLA_PROGRAM_DESC}"
  echo -e
  fi
  
  echo -e "Usage:"
  
  local SHORTARGS=""
  local LONGARGS=""
  local MAX_ARG_PARAMLENGTH=0
	local A=""
  
  for A in ${!ECLA_ARG_NAME[*]}
  do
    if [ -z "${ECLA_ARG_PARAMS[$A]}" ]
    then
      SHORTARGS="${SHORTARGS}${ECLA_ARG_NAME[$A]}"
    else
      LENGTH=$(echo -ne "${ECLA_ARG_PARAMS[$A]}" | wc -m)
      if [ "${MAX_ARG_PARAMLENGTH}" -lt "${LENGTH}" ]
      then
        MAX_ARG_PARAMLENGTH="${LENGTH}"
      fi
      LONGARGS="${LONGARGS} [-${ECLA_ARG_NAME[$A]} ${ECLA_ARG_PARAMS[$A]}]"
    fi
  done
  
  echo -e "${0##*/} [-${SHORTARGS}]${LONGARGS}"
  
  
  local IND=" "
  
  for A in ${!ECLA_ARG_NAME[*]}
  do
    echo -e
    printf "${IND} -%c %-${MAX_ARG_PARAMLENGTH}s %s\n" "${ECLA_ARG_NAME[$A]}" "${ECLA_ARG_PARAMS[$A]}" "${ECLA_ARG_DESC[$A]}"
  done
  echo -e

  if [ -n "$1" ]
  then
    exit $1
  fi
}
######################################################################

######################################################################
# Usage: add_argument <NAME> <PARAMS> <DESC> <CALLBACK>
# Adds a command line argument with parameters.
######################################################################
ecla_add_argument() {
  local NAME=$1
  local PARAMS=$2
  local DESC=$3
  local CALLBACK=$4

  local N=${#ECLA_ARG_NAME[*]}
  
  ECLA_ARG_NAME[$N]="${NAME}"
  ECLA_ARG_PARAMS[$N]="${PARAMS}"
  ECLA_ARG_DESC[$N]="${DESC}"
  ECLA_ARG_CALLBACK[$N]="${CALLBACK}"
}
######################################################################

######################################################################
# Usage: ecla_add_argument_noparam <NAME> <DESC> <CALLBACK>
# Adds a command line argument without parameters.
######################################################################
ecla_add_argument_noparam() {
  local NAME=$1
  local DESC=$2
  local CALLBACK=$3

  local N=${#ECLA_ARG_NAME[*]}
  
  ECLA_ARG_NAME[$N]="${NAME}"
  ECLA_ARG_PARAMS[$N]=""
  ECLA_ARG_DESC[$N]="${DESC}"
  ECLA_ARG_CALLBACK[$N]="${CALLBACK}"
}
######################################################################

######################################################################
# Usage: ecla_init <PROGRAMNAME> <VERSION> <DESCRIPTION>
######################################################################
ecla_init() {
  local NAME=$1
  local VERSION=$2
  local DESC=$3

  if [ -n "${NAME}" ]
  then
    ECLA_PROGRAM_NAME=${NAME}
  fi

  if [ -n "${VERSION}" ]
  then
    ECLA_PROGRAM_VERSION=${VERSION}
  fi

  ECLA_PROGRAM_DESC="${DESC}"

  ecla_add_argument_noparam "h" "${ECLA_ARG_HELP}" "ecla_show_help 0"
  ecla_add_argument_noparam "v" "${ECLA_ARG_VERSION}" "ecla_show_version 0"
}
######################################################################
ecla_parse() {
  local OPTIND=1 
  local OPTSTRING=""
	local A=""
  for A in ${!ECLA_ARG_NAME[*]}
  do
    OPTSTRING="${OPTSTRING}${ECLA_ARG_NAME[$A]}"
    if [ -n "${ECLA_ARG_PARAMS[$A]}" ]
    then
      OPTSTRING="${OPTSTRING}:"
    fi
  done

  while getopts "${OPTSTRING}" opt
  do
    for A in ${!ECLA_ARG_NAME[*]}
    do
      case "$opt" in
      ${ECLA_ARG_NAME[$A]})
        #eval "(${ECLA_ARG_CALLBACK[$A]} $OPTARG)" 
        ${ECLA_ARG_CALLBACK[$A]} $OPTARG
#        if [ "${ECLA_ARG_NAME[$A]}" = "h" ] || [ "${ECLA_ARG_NAME[$A]}" = "v" ]
#        then
#				  exit 0
#        fi
        ;;
      '?')
        ecla_show_help 1 >&2
#        exit 1
        ;;
      esac
    done
  done
  shift "$((OPTIND-1))" # Shift off the options
	ECLA_UNPROCESSED_ARGS=$*
}

######################################################################
ecla_unprocessed_args() {
	echo ${ECLA_UNPROCESSED_ARGS}
}

######################################################################
ecla_standalone() {
  ecla_init "${ECLA_NAME}" "${ECLA_VERSION}" "${ECLA_DESC}"
  ecla_add_argument_noparam "u" "Show usage guide." "ecla_example"
  ecla_parse "${@}"

#  ecla_add_argument "f" "FILE" "the input file." "setFile"
#  ecla_add_argument_noparam "q" "enable quiet mode." "setQuiet"
#  ecla_add_argument "o" "OUTPUT" "the output directory." "setOutput"
  
}
######################################################################

######################################################################
ecla_example() {
  cat << EOF

+------------------------------+
| A Small Usage Guide for ECLA |
+------------------------------+

#1: Source ECLA.
source ecla

#2: Initialize ECLA.
    This automatically adds support for -v (version) and
    -h (help) arguments.
ecla_init "<script name>" "<script version>" "<script description>"

#3: Specify the commandline arguments you want to support.
    NOTE: ECLA currently only supports one-letter-arguments.

    To specify an argument without parameter, e.g. "-q":
ecla_add_argument_noparam "q" "<argument description>" "<bash function>"

    To specify an argument with parameter, e.g. "-o output":
ecla_add_argument "o" "<parameter name>" "<argument description>" "<bash function>"

    Examples:
ecla_add_argument "o" "FILE" "the output file." "setOutput"
ecla_add_argument_noparam "q" "enable quiet mode." "setQuiet"

    What happens:
    If your script is called with argument "-q", ECLA calls a bash
    function named "setQuiet" (which you have to define yourself).
    If your script is called with argument "-o output", ECLA calls
    a bash function named "setOutput" with parameter "output" (which
    you again have to define yourself).
     
#4: Hand the commandline arguments passed to your script over to ECLA.
ecla_parse "\${@}"

#5: [OPTIONAL] Retrieve extra arguments, e.g., if your script is called
    with positional parameters.
EXTRA_ARGS=\$(ecla_unprocessed_args)  

EOF
}
######################################################################

# Behave differently when sourced or called directly. 
if [ ${BASH_SOURCE[0]} == $0 ]
then
  ecla_standalone "${@}"
  exit $?
fi
