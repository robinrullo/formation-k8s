eval "$(starship init zsh)"
autoload -U +X bashcompinit && bashcompinit
autoload -U +X compinit && compinit

source /home/vscode/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/vscode/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source <(kubectl completion zsh)
complete -o nospace -C /usr/bin/terraform terraform

alias k=kubectl
alias tf=terraform