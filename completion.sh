#!/bin/bash
###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
######  ###  ##  ##   ## ######  ###  ##

_completion() {
    local commands="start stop restart status console broad cmd help"
    local servers="atm8 survival creative"
    
    # If the firts argument is provided, suggest commands
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${commands}" -- "${COMP_WORDS[1]}") )
        return 0
    fi
    
    # If the second argument is provided, suggest server names
    if [[ ${COMP_CWORD} -eq 2 ]]; then
        # List of server names (you can modify this to read from a config file)
        COMPREPLY=( $(compgen -W "${servers}" -- "${COMP_WORDS[2]}") )
        return 0
    fi
    
    # If the command is 'broad' or 'cmd', suggest a message or command
    if [[ ${COMP_CWORD} -eq 3 ]]; then
        if [[ "${COMP_WORDS[1]}" == "broad" ]]; then
            COMPREPLY=( $(compgen -W "Hello Goodbye Restarting" -- "${COMP_WORDS[3]}") )
            return 0
            elif [[ "${COMP_WORDS[1]}" == "cmd" ]]; then
            COMPREPLY=( $(compgen -W "list kick ban" -- "${COMP_WORDS[3]}") )
            return 0
        fi
    fi
}

# Register the completion function
complete -F _completion mcmanager.sh