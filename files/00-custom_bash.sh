if [[ $SHELL == "/bin/bash" ]]; then

	alias rm='rm -i'
	alias psa='ps aux'
	alias psag='ps aux | grep '
	alias ll='ls -al'
	alias llh='ls -alh'

	# LOG all users commands
#  	export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "$(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]"'
	export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "{ \"run_as\": \"$(whoami)\", \"pid\": \"$$\", \"command\": \"$(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" )\", \"return_code\": \"$RETRN_VAL\"}"'

	# developers shell

	# get current branch in git repo
	function parse_git_branch() {
		BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
		if [ ! "${BRANCH}" == "" ]
		then
			STAT=`parse_git_dirty`
			echo "[${BRANCH}${STAT}]"
		else
			echo ""
		fi
	}

	# get current status of git repo
	function parse_git_dirty {
		status=`git status 2>&1 | tee`
		dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
		untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
		ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
		newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
		renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
		deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
		bits=''
		if [ "${renamed}" == "0" ]; then
			bits=">${bits}"
		fi
		if [ "${ahead}" == "0" ]; then
			bits="*${bits}"
		fi
		if [ "${newfile}" == "0" ]; then
			bits="+${bits}"
		fi
		if [ "${untracked}" == "0" ]; then
			bits="?${bits}"
		fi
		if [ "${deleted}" == "0" ]; then
			bits="x${bits}"
		fi
		if [ "${dirty}" == "0" ]; then
			bits="!${bits}"
		fi
		if [ ! "${bits}" == "" ]; then
			echo " ${bits}"
		else
			echo ""
		fi
	}


	if ((${EUID:-0} || "$(id -u)")); then
		export PS1="\[\e[32m\]\u@\h: \[\e[m\]\[\e[34m\]\w\[\e[m\] \[\e[36m\]\`parse_git_branch\`\[\e[m\]\[\e[32m\]\\$\[\e[m\] "

	else
		# root
		export PS1="\[\e[31m\]\h: \[\e[m\]\[\e[34m\]\w\[\e[m\] \[\e[36m\]\`parse_git_branch\`\[\e[m\]\[\e[31m\]\\$\[\e[m\] "

	fi

fi