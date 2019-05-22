# repo-starting-tools
A repository with tools to help automate the creation of repositories

## Installation

* Unix-like systems (linux, mac)

        git clone https://github.com/nikita-skobov/repo-starting-tools.git
        
        # for making a symbolic link:
        cd /usr/local/bin
        sudo ln -s /path/to/repo-starting-tools/*.sh . # makes a symbolic link to every .sh file within the repo-starting-tools directory.

        # for installing the scripts manually:
        cd /path/to/repo-starting-tools
        for i in *.sh; do sudo cp "$i" /usr/local/bin/; done # copy all files in repo-starting-tools directory with a .sh extension to /usr/local/bin


## Getting Started

```sh
makeProject.sh --interactive
```

The above command will run you through creating a project step by step. it will use makeRemoteRepository.sh and setupRepo.sh to create a github repo, and setup your local git repo to upstream the remote repo respectively. You can optionally pass in all of the required options to makeProject.sh instead of running it interactively. See the init_args() function in makeProject.sh for a list of the options it looks for.

makeProject.sh is designed to work for both repositories that already exist locally, that you want to create a remote for, as well as starting new repositories from scratch.