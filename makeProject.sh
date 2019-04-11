#!/usr/bin/env bash

set -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
# DIR is the full path to the directory where this file is.
# This lets this script make references to the other files
# without relying on relative paths.

function usage()
{
  local just_help=$1
  local missing_required=$2
  local invalid_argument=$3
  local invalid_option=$4

  local help="Usage: makeRepo.sh [OPTIONS]

[ENTER YOUR DESCRIPTION HERE]

Example: makeRepo.sh [ENTER YOUR EXAMPLE ARGUMENTS HERE]

Options (* indicates it is required):"
  local help_options="    \ \--interactive\ \[ENTER YOUR DESCRIPTION HERE]
    \ \--repo-name \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--description \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--email \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--already-repo \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--username \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--private\ \[ENTER YOUR DESCRIPTION HERE]
    \ \--include-issues\ \[ENTER YOUR DESCRIPTION HERE]
    \ \--include-projects\ \[ENTER YOUR DESCRIPTION HERE]
    \ \--include-wiki\ \[ENTER YOUR DESCRIPTION HERE]
    \ \--include-readme\ \[ENTER YOUR DESCRIPTION HERE]
    \ \--license \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--homepage \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
"

  if [ "$missing_required" != "" ]
  then
    echo "Missing required argument: $missing_required"
  fi

  if [ "$invalid_option" != "" ] && [ "$invalid_value" = "" ]
  then
    echo "Invalid option: $invalid_option"
  elif [ "$invalid_value" != "" ]
  then
    echo "Invalid value: $invalid_value for option: --$invalid_option"
  fi

  echo -e "
"
  echo "$help"
  echo "$help_options" | column -t -s'\'
  return
}

REQ_ARGS=(
  "already_repo"
  "username"
  "email"
  "repo_name"
  "description"
  "private"
  "include_issues"
  "include_projects"
  "include_wiki"
  "include_readme"
  "license"
  "homepage"
)

REQ_ARGS_PROMTS=(
  "Type 'true' if your current working directory is already a repository (otheriwse hit RETURN)"
  "Enter your username: "
  "Enter your email: "
  "Enter a repository name: "
  "Enter a description: (hit RETURN if you want to keep it blank)"
  "Type 'true' if you want your repository to be private, otherwise hit RETURN"
  "type 'false' if you DO NOT want your repository to have an issues board, otherwise hit RETURN"
  "type 'false' if you DO NOT want your repository to have projects, otherwise hit RETURN"
  "type 'false' if you DO NOT want your repository to have a wiki, otherwise hit RETURN"
  "type 'true' if you want your repository to include an empty README, otherwise hit RETURN"
  "Enter a license: (hit RETURN if you dont want to include a license)"
  "Enter your homepage: (hit RETURN if you dont want to include a homepage)"
)


function init_args()
{
# get command line arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
	--interactive)
		interactive="true"
		shift
		;;
  --already-repo)
		already_repo="true"
		shift
		;;
	--repo-name)
		repo_name="$2"
		shift 2
		;;
  --email)
		email="$2"
		shift 2
		;;
	--description)
		description="$2"
		shift 2
		;;
	--username)
		username="$2"
		shift 2
		;;
	--private)
		private="true"
		shift
		;;
	--include-issues)
		include_issues="true"
		shift
		;;
	--include-projects)
		include_projects="true"
		shift
		;;
	--include-wiki)
		include_wiki="true"
		shift
		;;
	--include-readme)
		include_readme="true"
		shift
		;;
	--license)
		license="$2"
		shift 2
		;;
	--homepage)
		homepage="$2"
		shift 2
		;;
	*)
		POSITIONAL+=("$1") # saves unknown option in array
		shift
		;;
esac
done

# Not using REQ_ARGS for this script because the idea
# is that the REQ_ARGS array only be used when running in interactive mode
#
# for i in "${REQ_ARGS[@]}"; do
#   # $i is the string of the variable name
#   # ${!i} is a parameter expression to get the value
#   # of the variable whose name is i.
#   req_var=${!i}
#   if [ "$req_var" = "" ]
#   then
#     usage "" "--$i"
#     exit
#   fi
# done
}
init_args $@

function run_interactive() {
  local cr=`echo $'\n.'`
  cr=${cr%.}
  # carriage return

  for i in "${!REQ_ARGS[@]}"; do
    # i is array index
    req_var=${REQ_ARGS[$i]}
    # req_var is the string of the required variable
    req_var_value=${!req_var}
    # req_var_value is the value of the variable whose name is req_var

    if [ -n "$req_var_value" ]
    then
      # if the variable was already passed in as an option
      # ask user if they agree with it (PRESS ENTER)
      # or to type a value if they want to change it
      read -p "Your value for argument '$req_var' is '$req_var_value' $cr Press RETURN to confirm, or enter the desired value for '$req_var' $cr" temp_val
      if [ -n "$temp_val" ]
      then
        eval $req_var="\"$temp_val\""
      fi
    else
      req_var_promt=${REQ_ARGS_PROMTS[$i]}
      read -p "$req_var_promt $cr" temp_val
      # sets the variable whose name is req_var to the value of temp_val
      eval $req_var="\"$temp_val\""
    fi
  done
}


if [ "$interactive" = true ]
then
  run_interactive
fi

resp_args="--username $username --repo-name $repo_name"

if [ -n "$homepage" ]
then
  resp_args="$resp_args --homepage $homepage"
fi
if [ -n "$description" ]
then
  resp_args="$resp_args --description $description"
fi
if [ -n "$license" ]
then
  resp_args="$resp_args --license $license"
fi
if [ -n "$private" ]
then
  resp_args="$resp_args --private $private"
fi
if [ -n "$include_issues" ]
then
  resp_args="$resp_args --include-issues $include_issues"
fi
if [ -n "$include_projects" ]
then
  resp_args="$resp_args --include-projects $include_projects"
fi
if [ -n "$include_wiki" ]
then
  resp_args="$resp_args --include-wiki $include_wiki"
fi
if [ -n "$include_readme" ]
then
  resp_args="$resp_args --include-readme $include_readme"
fi

resp=$(bash "$DIR/makeRemoteRepository.sh" "$resp_args")
echo "$resp"

repo_url="https://github.com/$username/$repo_name.git"
resp2_args="--username $username --remote-url $repo_url --directory $repo_name --email $email"

if [ "$already_repo" = true ]
then
  resp2_args="$resp2_args --already-repo"
fi

resp2=$(bash "$DIR/setupRepo.sh" "$resp2_args")
echo "$resp2"
