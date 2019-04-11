#!/usr/bin/env bash

# stop script if any of the commands cause an error
set -e

function usage()
{
  local just_help=$1
  local missing_required=$2
  local invalid_argument=$3
  local invalid_option=$4

  local help="Usage: setupRepo.sh [OPTIONS]

[ENTER YOUR DESCRIPTION HERE]

Example: setupRepo.sh [ENTER YOUR EXAMPLE ARGUMENTS HERE]

Options (* indicates it is required):"
  local help_options="    \ \--already-repo\ \[ENTER YOUR DESCRIPTION HERE]
   *\ \--directory \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
   *\ \--name \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
   *\ \--username \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
   *\ \--email \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
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
function init_args()
{
REQ_ARGS=("remote_url")

# get command line arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
	--already-repo)
		already_repo="true"
		shift
		;;
	--directory)
		directory="$2"
		shift 2
		;;
  --remote-url)
		remote_url="$2"
		shift 2
		;;
	--username)
		username="$2"
		shift 2
		;;
	--email)
		email="$2"
		shift 2
		;;
	*)
		POSITIONAL+=("$1") # saves unknown option in array
		shift
		;;
esac
done

for i in "${REQ_ARGS[@]}"; do
  # $i is the string of the variable name
  # ${!i} is a parameter expression to get the value
  # of the variable whose name is i.
  req_var=${!i}
  if [ "$req_var" = "" ]
  then
    usage "" "--$i"
    exit
  fi
done
}
init_args $@

if [ "$already_repo" != true ]
then
  if [ -z "$directory" ]
  then
    echo "ERROR: If not providing the --already-repo flag, you must provide a '--directory' argument with the name of your desired repository directory."
    exit 1
  fi
  # if not already a repo, make a directory,
  # and run git init inside the empty directory
  mkdir "$directory"
  cd "$directory"
  git init
else
  # if its already a repo, it is assumed that this command is being ran
  # in a git repository
  if [ ! -d ".git" ]
  then
    echo "ERROR: You specified that the directory $PWD is a git repository, but no .git directory can be found."
    exit 1
  fi
fi

# I like having my git config be specific for every repository
# but some people just do this once globally. Comment out these lines
# If you do not want this
git config --local user.name "$username"
git config --local user.email "$email"

git remote add origin "$remote_url"

git pull origin master
git branch --set-upstream-to=origin/master master
