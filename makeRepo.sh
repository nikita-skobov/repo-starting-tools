#!/usr/bin/env bash

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
  "username"
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
  "Enter your username: "
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
	--repo-name)
		repo_name="$2"
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


resp=$(./makeRemote.sh "$username" "$json_data")
echo "$resp"

