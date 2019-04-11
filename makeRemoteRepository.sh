#!/usr/bin/env bash

function usage()
{
  local just_help=$1
  local missing_required=$2
  local invalid_argument=$3
  local invalid_option=$4

  local help="Usage: makeRemoteRepository.sh [OPTIONS]

[ENTER YOUR DESCRIPTION HERE]

Example: makeRemoteRepository.sh [ENTER YOUR EXAMPLE ARGUMENTS HERE]

Options (* indicates it is required):"
  local help_options="   *\ \--username \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
   *\ \--repo_name \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--description \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--private \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--include-issues \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--include-projects \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--include-wiki \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
    \ \--include-readme \<Parameter>\[ENTER YOUR DESCRIPTION HERE]
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
function init_args()
{
REQ_ARGS=("username" "repo_name" )

# get command line arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
	--username)
		username="$2"
		shift 2
		;;
	--repo-name)
		repo_name="$2"
		shift 2
		;;
	--description)
		description="$2"
		shift 2
		;;
	--private)
		private="$2"
		shift 2
		;;
	--include-issues)
		include_issues="$2"
		shift 2
		;;
	--include-projects)
		include_projects="$2"
		shift 2
		;;
	--include-wiki)
		include_wiki="$2"
		shift 2
		;;
	--include-readme)
		include_readme="$2"
		shift 2
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



json_data="{\"name\":\"$repo_name\""

if [ -n "$description" ]
then
  json_data="$json_data, \"description\": \"$description\""
fi

if [ -n "$homepage" ]
then
  json_data="$json_data, \"homepage\": \"$homepage\""
fi

if [ -n "$license" ]
then
  json_data="$json_data, \"license_template\": \"$license\""
fi

if [[ ( "$private" = true ) || ( "$private" = false ) ]]
then
  json_data="$json_data, \"private\": \"$private\""
fi

if [[ ( "$include_issues" = true ) || ( "$include_issues" = false ) ]]
then
  json_data="$json_data, \"has_issues\": \"$include_issues\""
fi

if [[ ( "$include_projects" = true ) || ( "$include_projects" = false ) ]]
then
  json_data="$json_data, \"has_projects\": \"$include_projects\""
fi

if [[ ( "$include_wiki" = true ) || ( "$include_wiki" = false ) ]]
then
  json_data="$json_data, \"has_wiki\": \"$include_wiki\""
fi

if [[ ( "$include_readme" = true ) || ( "$include_readme" = false ) ]]
then
  json_data="$json_data, \"auto_init\": \"$include_readme\""
fi

json_data="$json_data}"


curl -u "$username" -H "Accept: application/vnd.github.v3+json" -X POST https://api.github.com/user/repos -d "$json_data"
