eval "$(starship init zsh)"
source /home/vscode/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/vscode/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source <(kubectl completion zsh)
complete -o nospace -C /usr/bin/terraform terraform

alias k=kubectl
alias tf=terraform