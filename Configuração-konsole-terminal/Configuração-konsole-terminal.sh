#!/usr/bin/env bash
# Terminal konsole-terminal— Global Enhanced
# Zsh + Powerlevel10k + tema branco/verde + ícones • Plugins úteis • Padronização global
# Compatível com: Debian, Ubuntu, Kali Linux
# Terminais: Gnome Terminal, Konsole, Terminator, Tilix, etc.
# Melhorias: Logo do sistema, produtividade, aliases avançados

set -euo pipefail

# ---------------------------
# 0) Funções utilitárias
# ---------------------------
log() { printf "\033[1;32m[✓]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[✗]\033[0m %s\n" "$*"; }
info() { printf "\033[1;36m[ℹ]\033[0m %s\n" "$*"; }

run_as_user() {
  local user="$1"; shift
  if command -v runuser >/dev/null 2>&1; then
    runuser -l "$user" -c "$*"
  else
    su - "$user" -c "$*"
  fi
}

ensure_dir() { mkdir -p "$1"; }

# Detectar distro
detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

DISTRO=$(detect_distro)
info "Sistema detectado: $DISTRO"

# ---------------------------
# 1) Dependências do sistema
# ---------------------------
log "Instalando pacotes..."

# Atualizar repositórios
case "$DISTRO" in
  debian|ubuntu|kali)
    apt update -y -qq || true
    ;;
  *)
    warn "Distribuição não reconhecida, tentando apt..."
    apt update -y -qq 2>/dev/null || true
    ;;
esac

# Pacotes essenciais
DEPS=(
  zsh git curl wget unzip fzf ripgrep jq tmux
  python3 python3-pip
  fonts-powerline
  command-not-found
  neofetch screenfetch
  ncdu htop
  tree
  silversearcher-ag
)

# Pacotes específicos por distro
case "$DISTRO" in
  ubuntu|debian)
    DEPS+=(fd-find bat exa fonts-firacode)
    ;;
  kali)
    DEPS+=(fd-find bat eza fonts-firacode)
    ;;
esac

# Instalar com tratamento de erros
for pkg in "${DEPS[@]}"; do
  apt install -y -qq "$pkg" 2>/dev/null || warn "Pacote $pkg não disponível"
done

# Criar links simbólicos para compatibilidade
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

# Instalar eza se não estiver disponível
if ! command -v eza >/dev/null 2>&1 && ! command -v exa >/dev/null 2>&1; then
  info "Instalando eza..."
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list >/dev/null || true
  apt update -qq && apt install -y eza 2>/dev/null || warn "Não foi possível instalar eza"
fi

# Comando para listagem (eza ou exa ou ls)
if command -v eza >/dev/null 2>&1; then
  LS_CMD="eza"
elif command -v exa >/dev/null 2>&1; then
  LS_CMD="exa"
else
  LS_CMD="ls --color=auto"
fi

# ---------------------------
# 2) Lista de usuários-alvo
#    (UID >=1000) + root
# ---------------------------
USERS=()
while IFS=: read -r name _ uid _ _ home shell; do
  if [[ "$name" == "root" ]] || [[ "$uid" -ge 1000 ]]; then
    [[ -d "$home" ]] || continue
    [[ "$shell" =~ (false|nologin)$ ]] && continue
    USERS+=("$name")
  fi
done < <(getent passwd)

# ---------------------------
# 3) Função de configuração por usuário
# ---------------------------
configure_user() {
  local USERNAME="$1"
  local HOME_DIR
  HOME_DIR="$(getent passwd "$USERNAME" | cut -d: -f6)"

  local ZSH_DIR="$HOME_DIR/.oh-my-zsh"
  local ZSH_CUSTOM="$ZSH_DIR/custom"
  local PLUGINS_DIR="$ZSH_CUSTOM/plugins"
  local THEMES_DIR="$ZSH_CUSTOM/themes"

  local ZSHRC_FILE="$HOME_DIR/.zshrc"
  local ALIASES_FILE="$HOME_DIR/.bash_aliases"
  local FUNCTIONS_FILE="$HOME_DIR/.zsh_functions"
  local P10K_FILE="$HOME_DIR/.p10k.zsh"
  local PALETTE_FILE="$HOME_DIR/.p10k_palette_global.zsh"
  local FONT_DIR="$HOME_DIR/.local/share/fonts"

  log "Configurando usuário: $USERNAME ($HOME_DIR)"

  # Oh My Zsh
  if [[ ! -d "$ZSH_DIR" ]]; then
    run_as_user "$USERNAME" "git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git '$ZSH_DIR'" 2>/dev/null || warn "Erro ao clonar Oh My Zsh"
  else
    run_as_user "$USERNAME" "git -C '$ZSH_DIR' pull --ff-only" 2>/dev/null || true
  fi

  # Plugins essenciais
  ensure_dir "$PLUGINS_DIR"
  declare -A PLUGS=(
    [zsh-autosuggestions]=https://github.com/zsh-users/zsh-autosuggestions.git
    [zsh-syntax-highlighting]=https://github.com/zsh-users/zsh-syntax-highlighting.git
    [zsh-completions]=https://github.com/zsh-users/zsh-completions.git
    [history-substring-search]=https://github.com/zsh-users/zsh-history-substring-search.git
    [zsh-better-npm-completion]=https://github.com/lukechilds/zsh-better-npm-completion.git
    [zsh-interactive-cd]=https://github.com/changyuheng/zsh-interactive-cd.git
  )

  for name in "${!PLUGS[@]}"; do
    local dest="$PLUGINS_DIR/$name"
    local url="${PLUGS[$name]}"
    if [[ -d "$dest/.git" ]]; then
      run_as_user "$USERNAME" "git -C '$dest' pull --ff-only" 2>/dev/null || true
    else
      run_as_user "$USERNAME" "git clone --depth=1 '$url' '$dest'" 2>/dev/null || warn "Erro ao instalar plugin $name"
    fi
  done

  # Powerlevel10k
  ensure_dir "$THEMES_DIR"
  if [[ ! -d "$THEMES_DIR/powerlevel10k" ]]; then
    run_as_user "$USERNAME" "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '$THEMES_DIR/powerlevel10k'" 2>/dev/null || warn "Erro ao instalar Powerlevel10k"
  else
    run_as_user "$USERNAME" "git -C '$THEMES_DIR/powerlevel10k' pull --ff-only" 2>/dev/null || true
  fi

  # Nerd Font Meslo
  ensure_dir "$FONT_DIR"
  if [[ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]]; then
    run_as_user "$USERNAME" "wget -q -O '$FONT_DIR/Meslo.zip' 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip' && unzip -oq '$FONT_DIR/Meslo.zip' -d '$FONT_DIR' && rm '$FONT_DIR/Meslo.zip' && fc-cache -fv >/dev/null 2>&1" 2>/dev/null || warn "Erro ao instalar fonte"
  fi

  # Paleta — branco & verde (ícones pretos)
  cat > "$PALETTE_FILE" <<'EOF'
# Tema Branco & Verde (global)
export COLORTERM=truecolor
HTB_GREEN="#00ff96"
HTB_WHITE="#ffffff"
HTB_BLACK="#000000"
typeset -g POWERLEVEL9K_BACKGROUND="$HTB_WHITE"
typeset -g POWERLEVEL9K_FOREGROUND="$HTB_BLACK"
typeset -g POWERLEVEL9K_DIR_FOREGROUND="$HTB_BLACK"
typeset -g POWERLEVEL9K_DIR_BACKGROUND="$HTB_GREEN"
typeset -g POWERLEVEL9K_VCS_FOREGROUND="$HTB_BLACK"
typeset -g POWERLEVEL9K_VCS_BACKGROUND="$HTB_WHITE"
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND="$HTB_BLACK"
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND="$HTB_WHITE"
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND="$HTB_BLACK"
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND="$HTB_WHITE"
typeset -g POWERLEVEL9K_TIME_FOREGROUND="$HTB_BLACK"
typeset -g POWERLEVEL9K_TIME_BACKGROUND="$HTB_GREEN"
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND="$HTB_BLACK"
typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND="$HTB_WHITE"
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND="$HTB_BLACK"
typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND="$HTB_GREEN"
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND="$HTB_BLACK"
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND="$HTB_GREEN"
EOF

  # Config Powerlevel10k
  cat > "$P10K_FILE" <<'EOF'
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time command_execution_time)
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="❯ "
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=500
source ~/.p10k_palette_global.zsh
EOF

  # Funções úteis
  cat > "$FUNCTIONS_FILE" <<'EOF'
# 🛠️ Funções úteis para produtividade

# Criar diretório e entrar nele
mkcd() { mkdir -p "$1" && cd "$1"; }

# Extrair qualquer arquivo compactado
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' não pode ser extraído via extract()" ;;
    esac
  else
    echo "'$1' não é um arquivo válido"
  fi
}

# Buscar processo e matar
killp() {
  local pid
  pid=$(ps aux | fzf | awk '{print $2}')
  if [[ -n "$pid" ]]; then
    kill -9 "$pid"
    echo "Processo $pid terminado"
  fi
}

# Histórico com busca interativa (renomeado para evitar conflito)
hsearch() {
  fc -l 1 | fzf --tac | awk '{$1=""; print substr($0,2)}'
}

# Git diff com preview
gdiff() {
  git diff --name-only "$@" | fzf --preview 'git diff --color=always {} | head -500'
}

# Criar backup rápido de arquivo
backup() {
  local file="$1"
  cp "$file" "${file}.backup-$(date +%Y%m%d-%H%M%S)"
}

# Mostrar uso de disco por diretório
duh() {
  du -h --max-depth=1 "$@" | sort -hr
}

# Encontrar arquivos grandes
bigfiles() {
  local size="${1:-100M}"
  find . -type f -size +"$size" -exec ls -lh {} \; | awk '{print $9 ": " $5}'
}

# Limpar cache do sistema (requer sudo)
clearcache() {
  sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"
  echo "Cache limpo!"
}

# Monitorar mudanças em arquivo
watchfile() {
  local file="$1"
  watch -n 1 "cat '$file'"
}

# Info rápida do sistema
sysinfo() {
  echo "=== Informações do Sistema ==="
  echo "OS: $(lsb_release -d | cut -f2)"
  echo "Kernel: $(uname -r)"
  echo "Uptime: $(uptime -p)"
  echo "CPU: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
  echo "RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
  echo "Disco: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " usado)"}')"
}

# Criar servidor HTTP rápido em qualquer porta
serve() {
  local port="${1:-8000}"
  python3 -m http.server "$port"
}

# Buscar e substituir em múltiplos arquivos
replace-all() {
  local search="$1"
  local replace="$2"
  local path="${3:-.}"
  find "$path" -type f -exec sed -i "s/$search/$replace/g" {} +
  echo "Substituição concluída!"
}

# Corretor de comandos simples (alternativa ao thefuck)
fuck() {
  local last_command=$(fc -ln -1)
  echo "Último comando: $last_command"
  echo "Sugestões:"
  echo "  1. sudo $last_command"
  echo "  2. Refaça o comando corretamente"
  read -r "choice?Escolha (1/2) ou Enter para cancelar: "
  case $choice in
    1) eval "sudo $last_command" ;;
    2) echo "Digite o comando corrigido:" && read -r cmd && eval "$cmd" ;;
    *) echo "Cancelado" ;;
  esac
}

# Corrigir erro comum: comando não encontrado
command_not_found_handler() {
  local cmd="$1"
  echo "Comando '$cmd' não encontrado."

  # Sugestões comuns
  case "$cmd" in
    apt-get) echo "  Você quis dizer: apt" ;;
    python) echo "  Você quis dizer: python3" ;;
    pip) echo "  Você quis dizer: pip3" ;;
    *)
      # Buscar comandos similares
      if command -v apt-file >/dev/null 2>&1; then
        echo "  Procurando em pacotes disponíveis..."
        apt-file search -x "bin/$cmd$" 2>/dev/null | head -3
      fi
      ;;
  esac
  return 127
}
EOF

  # Aliases completos
  cat > "$ALIASES_FILE" <<EOF
# 🧭 Navegação
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# 📁 Listagem (usando $LS_CMD)
if command -v eza >/dev/null 2>&1 || command -v exa >/dev/null 2>&1; then
  alias ll='$LS_CMD -lh --icons --group-directories-first'
  alias la='$LS_CMD -A --icons --group-directories-first'
  alias l='$LS_CMD -1 --icons'
  alias lt='$LS_CMD --tree --level=2 --icons'
  alias llt='$LS_CMD -lh --tree --level=2 --icons'
else
  alias ll='ls -lhF'
  alias la='ls -AF'
  alias l='ls -1'
fi

# ⚙️ Sistema
alias upd='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean'
alias install='sudo apt install -y'
alias remove='sudo apt remove -y'
alias search='apt search'
alias cl='clear'
alias reload='source ~/.zshrc'
alias limpar-h='history -c'
alias top10='ps aux --sort=-%mem | head -n 11'
alias top10cpu='ps aux --sort=-%cpu | head -n 11'

# 🧠 Info
alias mem='free -h'
alias memtop='ps aux --sort=-%mem | head -n 20'
alias cpu='lscpu | grep "Model name"'
alias cpufreq='watch -n 1 "cat /proc/cpuinfo | grep MHz"'
alias temp='sensors 2>/dev/null || echo "Instale lm-sensors"'
alias disk='df -hT'
alias disks='lsblk'
alias mounted='mount | column -t'

# 🙌 Git
alias gs='git status'
alias gss='git status -s'
alias gp='git pull'
alias gf='git fetch'
alias gc='git commit -m'
alias gca='git commit --amend'
alias ga='git add .'
alias gaa='git add --all'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gl='git log --oneline --graph --decorate'
alias gll='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gd='git diff'
alias gds='git diff --staged'
alias push='git push origin \$(git rev-parse --abbrev-ref HEAD)'
alias pull='git pull origin \$(git rev-parse --abbrev-ref HEAD)'
alias clone='git clone'

# 🐳 Docker / Compose
alias d='docker'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimg='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dstop='docker stop \$(docker ps -aq)'
alias drm='docker rm \$(docker ps -aq)'
alias drmi='docker rmi \$(docker images -q)'
alias dprune='docker system prune -af'
alias dc='docker compose'
alias dcb='docker compose build'
alias dcu='docker compose up -d'
alias dcup='docker compose up'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dcr='docker compose restart'

# 🧰 Dev / Rede
alias pyserv='python3 -m http.server'
alias pyserv8='python3 -m http.server 8080'
alias ports='sudo lsof -i -P -n | grep LISTEN'
alias myip='curl -s ifconfig.me'
alias localip='ip -br -4 a | grep UP'
alias pingg='ping -c 5 8.8.8.8'
alias pingl='ping -c 5 1.1.1.1'
alias speed='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
alias netstat='netstat -tulanp'

# 🔍 Busca
alias findf='fd --hidden --exclude .git'
alias findn='find . -name'
alias grep='grep --color=auto'
alias grepr='grep -r --color=auto'

# 📝 Edição
alias edit='nano'
alias v='vim'
alias nv='nvim'

# 🎨 Visual
alias neo='neofetch'
alias fetch='screenfetch'

# 🔐 Segurança / Pentest
alias nmap-quick='sudo nmap -T4 -F'
alias nmap-full='sudo nmap -T4 -A -v'
alias nmap-vuln='sudo nmap --script vuln'
alias ports-open='sudo nmap -sT -p-'
alias hydra-http='hydra -L users.txt -P passwords.txt'
alias metasploit='msfconsole -q'
alias burp='java -jar /opt/burpsuite/burpsuite.jar &'
alias wireshark='sudo wireshark &'

# 📦 Python / Pip
alias py='python3'
alias pip='pip3'
alias pipi='pip3 install'
alias pipu='pip3 install --upgrade'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# 📊 Produtividade
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux ls'
alias tk='tmux kill-session -t'
alias weather='curl wttr.in'
alias calc='bc -l'
alias timer='echo "Timer iniciado" && sleep'
alias now='date +"%Y-%m-%d %H:%M:%S"'

# 🔧 Correções rápidas (alternativa ao thefuck)
alias apt-get='apt'
alias please='sudo'
alias pls='sudo'
alias python='python3'
alias pip='pip3'

# 🧹 Limpeza
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'
alias rmtemp='rm -rf /tmp/* ~/.cache/*'
alias clearlog='sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;'
EOF

  # .zshrc completo
  cat > "$ZSHRC_FILE" <<'EOF'
# ============================================
# ZSH Configuration - Terminal Pro Enhanced
# ============================================

# Instant prompt do Powerlevel10k
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  sudo
  extract
  history-substring-search
  command-not-found
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-better-npm-completion
  zsh-interactive-cd
  docker
  pip
  npm
  python
  systemd
  kubectl
  terraform
)

source "$ZSH/oh-my-zsh.sh"

# ============================================
# Autocomplete avançado
# ============================================
autoload -Uz compinit
fpath=("$ZSH/custom/plugins/zsh-completions/src" $fpath)

# Cache do autocomplete
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi

# Configurações do autocomplete
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# ============================================
# Histórico
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=200000

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# ============================================
# Opções do shell
# ============================================
setopt autocd
setopt correct
setopt extended_glob
setopt completealiases
setopt notify
setopt prompt_subst
setopt interactivecomments

# Não fazer beep
unsetopt beep

# ============================================
# Key bindings
# ============================================
bindkey -e  # Modo emacs
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# ============================================
# Tema e paleta
# ============================================
[[ -f ~/.p10k_palette_global.zsh ]] && source ~/.p10k_palette_global.zsh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ============================================
# Aliases e funções
# ============================================
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
[[ -f ~/.zsh_functions ]] && source ~/.zsh_functions

# ============================================
# Editor padrão
# ============================================
if [[ -n "$SSH_CONNECTION" ]]; then
  export EDITOR='vim'
else
  if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
  else
    export EDITOR='vim'
  fi
fi

# ============================================
# FZF - Busca interativa
# ============================================
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null || tree -C {}'
    --preview-window=right:50%
    --bind 'ctrl-/:toggle-preview'
    --color=light
  "

  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh || true

  # Função para buscar e editar arquivo
  fe() {
    local file
    file=$(fzf --query="$1" --select-1 --exit-0)
    [ -n "$file" ] && ${EDITOR:-vim} "$file"
  }
fi

# ============================================
# Variáveis de ambiente
# ============================================
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Python
export PYTHONDONTWRITEBYTECODE=1
export PIP_REQUIRE_VIRTUALENV=false

# Menos (pager)
export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'

# Bat (cat com syntax highlighting)
if command -v bat >/dev/null 2>&1; then
  export BAT_THEME="GitHub"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# ============================================
# Mensagem de boas-vindas
# ============================================
# Logo do sistema desabilitado - use 'neo' ou 'fetch' manualmente

# ============================================
# Funções úteis inline
# ============================================
# Atualizar sistema rapidamente
quick-update() {
  echo "🔄 Atualizando sistema..."
  sudo apt update && sudo apt upgrade -y
  echo "✓ Sistema atualizado!"
}

# ============================================
# PATH adicional para ferramentas
# ============================================
# Adicionar Go
[[ -d /usr/local/go/bin ]] && export PATH="$PATH:/usr/local/go/bin"
[[ -d $HOME/go/bin ]] && export PATH="$PATH:$HOME/go/bin"

# Adicionar Rust
[[ -f $HOME/.cargo/env ]] && source $HOME/.cargo/env

# ============================================
# Fim da configuração
# ============================================
EOF

  # Permissões
  chown -R "$USERNAME:$USERNAME" "$HOME_DIR"/.{zshrc,bash_aliases,zsh_functions,p10k.zsh,p10k_palette_global.zsh} 2>/dev/null || true
  chown -R "$USERNAME:$USERNAME" "$ZSH_DIR" "$FONT_DIR" 2>/dev/null || true

  # Shell padrão
  chsh -s "$(command -v zsh)" "$USERNAME" 2>/dev/null || true
}

# ---------------------------
# 4) Aplicar em todos os usuários
# ---------------------------
for u in "${USERS[@]}"; do
  configure_user "$u"
done

# ---------------------------
# 5) /etc/skel para novos usuários
# ---------------------------
log "Configurando /etc/skel para novos usuários..."
ensure_dir /etc/skel

# Copiar arquivos de configuração para /etc/skel
if [[ -n "${USERS[0]}" ]]; then
  SAMPLE_HOME=$(getent passwd "${USERS[0]}" | cut -d: -f6)

  cp "$SAMPLE_HOME/.p10k_palette_global.zsh" /etc/skel/ 2>/dev/null || true
  cp "$SAMPLE_HOME/.p10k.zsh" /etc/skel/ 2>/dev/null || true
  cp "$SAMPLE_HOME/.bash_aliases" /etc/skel/ 2>/dev/null || true
  cp "$SAMPLE_HOME/.zsh_functions" /etc/skel/ 2>/dev/null || true
  cp "$SAMPLE_HOME/.zshrc" /etc/skel/ 2>/dev/null || true

  # Oh My Zsh estrutura
  if [[ -d "$SAMPLE_HOME/.oh-my-zsh" ]]; then
    ensure_dir /etc/skel/.oh-my-zsh/custom/themes
    ensure_dir /etc/skel/.oh-my-zsh/custom/plugins

    cp -r "$SAMPLE_HOME/.oh-my-zsh/custom/themes/powerlevel10k" /etc/skel/.oh-my-zsh/custom/themes/ 2>/dev/null || true

    for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
      cp -r "$SAMPLE_HOME/.oh-my-zsh/custom/plugins/$plugin" /etc/skel/.oh-my-zsh/custom/plugins/ 2>/dev/null || true
    done
  fi
fi

# ---------------------------
# 6) Configurar terminais
# ---------------------------
log "Configurando perfis de terminal..."

# Konsole (KDE)
if command -v konsole >/dev/null 2>&1; then
  KONSOLE_DIR="$HOME/.local/share/konsole"
  ensure_dir "$KONSOLE_DIR"

  cat > "$KONSOLE_DIR/TerminalPro.profile" <<'EOF'
[Appearance]
ColorScheme=WhiteOnBlack
Font=MesloLGS NF,12,-1,5,50,0,0,0,0,0

[General]
Name=Terminal Pro
Parent=FALLBACK/

[Scrolling]
HistorySize=10000

[Terminal Features]
BlinkingCursorEnabled=true
EOF

  log "Perfil Konsole criado"
fi
