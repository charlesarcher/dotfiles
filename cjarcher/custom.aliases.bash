alias h='cd ~/'
alias c='cd /home/carcher/code/'
alias s='cd /home/carcher/stage/'
alias i='cd /home/carcher/code/install'
alias j='jobs -l'
alias r='rlogin'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias glist='for ref in $(git for-each-ref --sort=-committerdate --format="%(refname)" refs/heads/ refs/remotes ); do git log -n1 $ref --pretty=format:"%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n" | cat ; done | awk '"'! a["'$0'"]++'"
# -> Prevents accidentally clobbering files.
alias mkdir='mkdir -p'
alias xemacs='\emacs -f server-start -fg white -bg black'
alias emacsserver='\emacs --daemon -q --load ~/.emacs.d/init.el -fg white -bg black'
alias demacsserver='\emacs --daemon -fg white -bg black'
alias emacs='emacsclient -nw'
alias doom=~/.config/emacs/bin/doom
alias aider='\aider --model anthropic/claude-sonnet-4-20250514 --api-key anthropic=${ANTHROPIC_API_KEY} --subtree-only --cache-prompts --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderg='\aider --model gemini/gemini-2.5-pro --api-key gemini=${GEMINI_API_KEY} --subtree-only --cache-prompts --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aidergf='\aider --model gemini/gemini-2.5-flash --api-key gemini=${GEMINI_API_KEY} --subtree-only --cache-prompts --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aidero='\aider --model openai/gpt-4.1 --api-key openai=${OPENAI_API_KEY} --subtree-only --cache-prompts --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderds='\aider --model deepseek/deepseek-coder --api-key deepseek=${DEEPSEEK_API_KEY} --subtree-only --cache-prompts --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderx='\aider --model xai/grok-4-latest --api-key xai=${XAI_API_KEY} --subtree-only --cache-prompts --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderk='\aider --model openrouter/moonshotai/kimi-k2 --api-key openrouter=${OPENROUTER_API_KEY} --subtree-only --cache-prompts --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderc-assistant='\aider -c ~/aider.assistant.conf.yaml --subtree-only --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderc-select='\aider -c ~/aider.select.conf.yaml --subtree-only --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderc-claude-opus-4-1='\aider -c ~/aider.claude-opus-4-1.conf.yaml --subtree-only --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderc-gemini-2.5-pro='\aider -c ~/aider.gemini-2.5-pro.conf.yaml --subtree-only --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderc-gpt-5='\aider -c ~/aider.gpt-5.conf.yaml --subtree-only --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderc-gemini-2.5-flash='\aider -c ~/aider.gemini-2.5-flash.conf.yaml --subtree-only --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias aiderc-claude-sonnet-4='\aider -c ~/aider.claude-sonnet-4.conf.yaml --subtree-only --no-gitignore --map-tokens 8192 --edit-format=udiff'
alias which='type -all'
alias ..='cd ..'
alias path='echo -e ${PATH//:/\\n}'
alias du='du -kh'
alias df='df -kTh'
alias rdm='rdm --daemon --data-dir /home/carcher/.cache/rtags'
alias ls='ls -hF --color'	# add colors for filetype recognition
alias la='ls -Al'               # show hidden files
alias lx='ls -lXB'              # sort by extension
alias lk='ls -lSr'              # sort by size
alias lc='ls -lcr'		# sort by change time
alias lu='ls -lur'		# sort by access time
alias lr='ls -lR'               # recursive ls
alias lt='ls -ltr'              # sort by date
alias lm='ls -al |more'         # pipe through 'more'
alias tree='tree -Csu'		# nice alternative to 'ls'
