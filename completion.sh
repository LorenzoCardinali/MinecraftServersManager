#!/bin/bash

_completion() {
    local folders
    folders=$(find . -maxdepth 1 -type d -exec basename {} \; | grep -v '^.$')
    local commands="add start stop restart status console broad cmd"

    # If the first argument is provided, suggest server names
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        # List of server names (you can modify this to read from a config file)
        COMPREPLY=($(compgen -W "${folders} help" -- "${COMP_WORDS[1]}"))
        return 0
    fi

    # If the second argument is provided, suggest commands
    if [[ ${COMP_CWORD} -eq 2 ]] && [ "${COMP_WORDS[1]}" != "help" ]; then
        COMPREPLY=($(compgen -W "${commands}" -- "${COMP_WORDS[2]}"))
        return 0
    fi
}

# Register the completion function
complete -F _completion mcmanager.sh
