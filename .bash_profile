# There’s probably no .bashrc, but if it ever shows up, let’s include it too.
if [ -f ~/.bashrc ]; then 
    source ~/.bashrc 
fi

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensty
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensty
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensty backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[10;95m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

source ~/.git-completion.bash

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

__git_count_lines() { echo "$1" | egrep -c "^$2" ; }
__git_all_lines() { echo "$1" | grep -v "^$" | wc -l ; }

# Not pretty, but it loads a line from the file (first argument) into the variable (second argument)
__git_eread ()
{
	local f="$1" #Grab the first argument, should be a file name
	shift #drop first parameter and decrement index of others
	test -r "$f" && read "$@" <"$f" #If the file is readable, read a line into the variable named after the file path...
}

prompt_command () {
    local RetValue=$?

    local RetValueStr UserColor
    if [ $RetValue -eq 0 ]; then # set an error string for the prompt, if applicable
        RetValueStr=""
        UserColor=$BGreen
    else
        RetValueStr="($RetValue)"
        UserColor=$BRed
    fi

    # I would love to list out how the local commit compares to the remote, but apparently git5 obscures a bit of that
    #local AheadSymbol='↑'
    #local BehindSymbol='↓'
    #local LocalSymbol='🌎 '
    #local RemoteSymbol='🚀 '
    local SeparatorSymbol='|'
    local CleanSymbol='✔'
    local StagedSymbol='✚'
    local ConflictsSymbol='✖'
    local ChangedSymbol='!'
    local UntrackedSymbol='?'
    local StashedSymbol='$'

    local GitColor="$BBlack"
    local GitPromptStart
    local BranchColor="$White" BranchName
    #local DivergenceColor Locality Ahead Behind
    local ModeColor Mode
    local IgnoredColor="$Yellow" Ignored
    local Separator
    local CleanColor Clean
    local StagedColor Staged
    local ConflictsColor Conflicts
    local ChangedColor Changed
    local UntrackedColor Untracked
    local StashedColor Stashed
    local GitPromptEnd

    local repo_info rev_parse_exit_code
    local repo_info="$(git rev-parse \
        --git-dir \
        --is-inside-git-dir \
        --is-bare-repository \
        --is-inside-work-tree \
        --short HEAD 2>/dev/null)"
    local rev_parse_exit_code="$?"

    if [ "$repo_info" ]; then
        local short_sha
        if [ $rev_parse_exit_code ]; then
            short_sha="${repo_info##*$'\n'}" # store the last line of "repo_info" as "short_sha"
            repo_info="${repo_info%$'\n'*}" # drop the last line of "repo_info"
        fi
        local is_inside_worktree="${repo_info##*$'\n'}" # store the last line of "repo_info" as "inside_worktree"
        repo_info="${repo_info%$'\n'*}" # drop the last line of "repo_info"
        local is_bare_repo="${repo_info##*$'\n'}" # store the last line of...
        repo_info="${repo_info%$'\n'*}" # drop the last line of...
        local is_inside_git_dir="${repo_info##*$'\n'}" # store the last line of...
        local git_dir="${repo_info%$'\n'*}" # store everything but the last line of... (should only be one line left.)

        local step total
        if [ -d "$git_dir/rebase-merge" ]; then # if that's a directory...
            __git_eread "$git_dir/rebase-merge/head-name" BranchName
            __git_eread "$git_dir/rebase-merge/msgnum" step
            __git_eread "$git_dir/rebase-merge/end" total
            if [ -f "$git_dir/rebase-merge/interactive" ]; then
                Mode="|REBASE-i"
            else
                Mode="|REBASE-m"
            fi
        else # All remaining cases might not have BranchName set, so there's a cleanup after the ladder
            if [ -d "$git_dir/rebase-apply" ]; then
                __git_eread "$git_dir/rebase-apply/next" step
                __git_eread "$git_dir/rebase-apply/last" total
                if [ -f "$git_dir/rebase-apply/rebasing" ]; then
                    __git_eread "$git_dir/rebase-apply/head-name" BranchName
                    Mode="|REBASE"
                elif [ -f "$git_dir/rebase-apply/applying" ]; then
                    Mode="|AM"
                else
                    Mode="|AM/REBASE"
                fi
            elif [ -f "$git_dir/MERGE_HEAD" ]; then
                Mode="|MERGING"
            elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
                Mode="|CHERRY-PICKING"
            elif [ -f "$git_dir/REVERT_HEAD" ]; then
                Mode="|REVERTING"
            elif [ -f "$git_dir/BISECT_LOG" ]; then
                Mode="|BISECTING"
            fi

            if [ "$BranchName" ]; then
                :
            elif [ -h "$git_dir/HEAD" ]; then
                BranchName="$(git symbolic-ref HEAD 2>/dev/null)"
            else
                local head=""
                if ! __git_eread "$git_dir/HEAD" head; then
                    BranchName='_WE_DO_NOT_KNOW_A_BRANCH_NAME_'
                else
                    BranchName="${head#ref: }"
                    if [ "$head" = "$BranchName" ]; then
                        Mode="|DETACHED HEAD$Mode"
                        BranchName="\($(git describe HEAD 2>/dev/null)\)" || BranchName="\($short_sha...\)"
                    fi
                fi
            fi
        fi

        if [ "$step" ] && [ "$total" ]; then
            Mode="$Mode $step/$total"
        fi

        if [ "true" = "$is_inside_git_dir" ]; then
            BranchColor="$Yellow"
            if [ "true" = "$is_bare_repo" ]; then
                BranchName="BARE:$BranchName"
            else
                BranchName="GIT_DIR!"
            fi
        elif [ "true" = "$is_inside_worktree" ]; then
            git check-ignore -q .
            local ignore_exit_code=$?
            if [ $ignore_exit_code -eq 0 ]; then
                Ignored=' [directory ignored by git]'
            fi

            local gitStatus=$(git diff --name-status 2>&1)
            local stagedFiles=$(git diff --staged --name-status)

            local num_changed=$(( $(__git_all_lines "$gitStatus") - $(__git_count_lines "$gitStatus" U) ))
            local num_conflicts=$(__git_count_lines "$stagedFiles" U)
            local num_staged=$(( $(__git_all_lines "$stagedFiles") - num_conflicts ))
            local num_untracked=$(trim $(git ls-files --others --exclude-standard $(git rev-parse --show-cdup) | wc -l))
            local num_stashed=$(trim $(git stash list | wc -l))
            local clean=0
            if (( num_changed == 0 && num_staged == 0 && num_untracked == 0 && num_stashed == 0 )) ; then
                clean=1
            fi
        fi
        BranchName=${BranchName##refs/heads/}
        # this bit of indirection prevents us from evaluating a malicious branch name
        __git_branch_name=$BranchName
        BranchName="\${__git_branch_name}"

        GitPromptStart='['
        GitPromptEnd=']'
        Separator="$SeparatorSymbol"

        if [ "true" = "$is_inside_git_dir" ]; then
            Separator=''
        elif (( clean )); then
            CleanColor="$Green"
            Clean="$CleanSymbol"
        else
            if (( num_stashed )); then
                StashedColor="$BRed"
            else
                StashedColor="$Black"
            fi
            Stashed="$num_stashed$StashedSymbol"

            if (( num_conflicts )); then
                ConflictsColor="$Red"
            else
                ConflictsColor="$Black"
            fi
            Conflicts="$num_conflicts$ConflictsSymbol"

            if (( num_changed )); then
                ChangedColor="$Yellow"
            else
                ChangedColor="$Black"
            fi
            Changed="$num_changed$ChangedSymbol"

            if (( num_untracked )); then
                UntrackedColor="$Purple"
            else
                UntrackedColor="$Black"
            fi
            Untracked="$num_untracked$UntrackedSymbol"

            if (( num_staged )); then
                StagedColor="$Green"
            else
                StagedColor="$Black"
            fi
            Staged="$num_staged$StagedSymbol"
        fi
    else
        GitPromptStart=''
        BranchName=''
        #Locality=''
        Mode=''
        Ignored=''
        Separator=''
        Clean=''
        Conflicts=''
        Staged=''
        Changed=''
        Untracked=''
        Stashed=''
        GitPromptEnd=''
    fi
    local LOAD=$(uptime|awk '{min=NF-2;print $min}')
    export PS1="\[$UserColor\]\u$RetValueStr\[$BBlack\]@\[$BBlue\]\h\[$Black\]($LOAD)\[$Yellow\] \w \[$BRed\]\t\n\
\[$GitColor\]$GitPromptStart\[$BranchColor\]$BranchName\[$ModeColor\]$Mode\[$IgnoredColor\]$Ignored\[$GitColor\]$Separator\
\[$StashedColor\]$Stashed\[$ConflictsColor\]$Conflicts\[$ChangedColor\]$Changed\[$UntrackedColor\]$Untracked\[$StagedColor\]$Staged\
\[$CleanColor\]$Clean\[$GitColor\]$GitPromptEnd\[$BBlack\]>\[$Color_Off\] "
}
PROMPT_COMMAND=prompt_command

. $HOME/.bagpipe/setup.sh $HOME/.bagpipe orz-linux.kir.corp.google.com
export PATH=$HOME/bin:$PATH

export P4CONFIG=.p4config
export EDITOR="/usr/local/bin/mate -w"
export P4EDITOR=$EDITOR
export P4DIFF=opendiff
export FIGNORE=$FIGNORE:DS_Store
export BAZEL_COMPLETION_ALLOW_TESTS_FOR_RUN=true

source ~/repos/ishem/google3/tools/osx/blaze/bazel-complete.bash
function _git5_trampoline() {
  # Must be in a subshell.
  COMPREPLY=( $(source ~/git5_bash_completion_helper.sh) )
}

complete -o bashdefault -o default -o nospace -F _git5_trampoline git5 2>/dev/null || complete -o default -o nospace -F _git5_trampoline git5
