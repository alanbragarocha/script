# 🚀 Terminal — Configuração Avançada de Terminal

Script automatizado para configuração profissional de terminal com **Zsh**, **Powerlevel10k**, tema customizado branco/verde, ícones e plugins de produtividade.

## 📋 Índice

- [Características](#-características)
- [Compatibilidade](#-compatibilidade)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [O que é instalado](#-o-que-é-instalado)
- [Customizações](#-customizações)
- [Aliases e Funções](#-aliases-e-funções)
- [Teclas de Atalho](#-teclas-de-atalho)
- [Solução de Problemas](#-solução-de-problemas)
- [Capturas de Tela](#-capturas-de-tela)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)

## ✨ Características

- ✅ Instalação automatizada de Zsh + Oh My Zsh
- ✅ Tema Powerlevel10k com paleta branca/verde personalizada
- ✅ Fontes Nerd Font (Meslo) com suporte a ícones
- ✅ Plugins essenciais de produtividade
- ✅ Aliases avançados para tarefas comuns
- ✅ Funções utilitárias integradas
- ✅ Autocomplete inteligente e busca fuzzy (FZF)
- ✅ Histórico expandido e compartilhado
- ✅ Suporte a múltiplos usuários (incluindo root)
- ✅ Configuração persistente para novos usuários (/etc/skel)
- ✅ Perfis de terminal para Konsole e outros

## 💻 Compatibilidade

### Distribuições Linux
- Debian 10+
- Ubuntu 20.04+
- Kali Linux 2021+
- Outras distribuições baseadas em Debian/Ubuntu

### Terminais Suportados
- GNOME Terminal
- Konsole (KDE)
- Terminator
- Tilix
- Alacritty
- Kitty
- Outros terminais com suporte a cores 256/true color

## 📦 Pré-requisitos

- Sistema Linux baseado em Debian/Ubuntu
- Acesso root (sudo)
- Conexão com a internet
- Terminal com suporte a fontes Nerd Font

## 🔧 Instalação

### Instalação Rápida

```bash
# Baixar o script
wget https://raw.githubusercontent.com/seu-usuario/terminal-config/main/Configuração_terminal_sh.sh

# Dar permissão de execução
chmod +x Configuração_terminal_sh.sh

# Executar como root
sudo ./Configuração_terminal_sh.sh
```

### Instalação Manual

```bash
# Clonar o repositório
git clone https://github.com/seu-usuario/terminal-config.git
cd terminal-config

# Executar o script
sudo bash Configuração_terminal_sh.sh
```

### Após a Instalação

1. **Reinicie o terminal** ou execute:
   ```bash
   exec zsh
   ```

2. **Configure a fonte** no seu emulador de terminal:
   - Abra as preferências do terminal
   - Selecione a fonte: **MesloLGS NF** (Regular, tamanho 12)

3. **Aproveite** seu novo terminal profissional! 🎉

## 📚 O que é instalado

### Pacotes do Sistema

#### Ferramentas Essenciais
- `zsh` - Shell avançado
- `git` - Controle de versão
- `curl`, `wget` - Download de arquivos
- `fzf` - Busca fuzzy interativa
- `ripgrep` - Busca rápida em arquivos
- `jq` - Processador JSON
- `tmux` - Multiplexador de terminal

#### Ferramentas de Desenvolvimento
- `python3`, `pip` - Python
- `fd-find` / `fd` - Alternativa moderna ao find
- `bat` - Cat com syntax highlighting
- `eza` / `exa` - Alternativa moderna ao ls

#### Ferramentas de Sistema
- `htop` - Monitor de processos
- `ncdu` - Analisador de disco
- `tree` - Visualizador de diretórios
- `neofetch`, `screenfetch` - Informações do sistema
- `fonts-powerline`, `fonts-firacode` - Fontes

### Plugins Zsh

- **zsh-autosuggestions** - Sugestões automáticas baseadas no histórico
- **zsh-syntax-highlighting** - Destaque de sintaxe em tempo real
- **zsh-completions** - Autocompletações adicionais
- **history-substring-search** - Busca no histórico
- **zsh-better-npm-completion** - Melhor autocomplete para npm
- **zsh-interactive-cd** - CD interativo com preview

### Plugins Oh My Zsh

```
git, sudo, extract, command-not-found, colored-man-pages,
docker, pip, npm, python, systemd, kubectl, terraform
```

## 🎨 Customizações

### Tema de Cores

O script configura automaticamente um tema com:
- **Fundo**: Branco (#ffffff)
- **Destaque**: Verde (#00ff96)
- **Texto**: Preto (#000000)

#### Personalizar Cores

Edite o arquivo `~/.p10k_palette_global.zsh`:

```bash
# Suas cores personalizadas
HTB_GREEN="#00ff96"    # Verde principal
HTB_WHITE="#ffffff"    # Fundo branco
HTB_BLACK="#000000"    # Texto preto
```

### Elementos do Prompt

**Lado Esquerdo:**
- Ícone do sistema operacional
- Diretório atual
- Status do Git

**Lado Direito:**
- Status do último comando
- Horário atual
- Tempo de execução do comando

## 🔨 Aliases e Funções

### Aliases de Navegação

```bash
..          # cd ..
...         # cd ../..
....        # cd ../../..
~           # cd ~
-           # cd -
```

### Aliases de Listagem

```bash
ll          # Lista detalhada com eza/exa
la          # Lista incluindo ocultos
lt          # Lista em árvore
l1          # Lista em coluna única
lsize       # Lista ordenada por tamanho
```

### Aliases de Sistema

```bash
update      # Atualizar sistema (apt update + upgrade)
cleanup     # Limpar cache e pacotes desnecessários
ports       # Listar portas abertas
myip        # Mostrar IP público
localip     # Mostrar IP local
```

### Aliases Git

```bash
g           # git
gs          # git status
ga          # git add
gc          # git commit
gp          # git push
gl          # git log formatado
```

### Funções Úteis

#### `mkcd`
Criar diretório e entrar nele:
```bash
mkcd novo-projeto
```

#### `extract`
Extrair qualquer arquivo compactado:
```bash
extract arquivo.tar.gz
extract arquivo.zip
extract arquivo.rar
```

#### `backup`
Criar backup com timestamp:
```bash
backup meu-arquivo.txt
# Cria: meu-arquivo.txt.backup.2024-12-07_15-30-45
```

#### `findfile`
Buscar arquivo por nome:
```bash
findfile "*.py"
```

#### `findtext`
Buscar texto em arquivos:
```bash
findtext "TODO" "*.js"
```

#### `killp`
Matar processo interativamente (com FZF):
```bash
killp
```

#### `fe`
Buscar e editar arquivo (com FZF):
```bash
fe
# ou
fe nome-parcial
```

#### `weather`
Ver previsão do tempo:
```bash
weather
weather Rio de Janeiro
```

#### `qrcode`
Gerar QR code no terminal:
```bash
qrcode "https://exemplo.com"
```

#### `calc`
Calculadora rápida:
```bash
calc "2 + 2"
calc "sqrt(16)"
```

#### `path`
Mostrar PATH formatado:
```bash
path
```

## ⌨️ Teclas de Atalho

### Navegação
- `Ctrl + A` - Início da linha
- `Ctrl + E` - Fim da linha
- `Ctrl + U` - Limpar linha
- `Ctrl + K` - Deletar até o fim
- `Ctrl + W` - Deletar palavra anterior

### Histórico
- `↑` / `↓` - Busca no histórico (substring)
- `Ctrl + R` - Busca reversa no histórico (FZF)
- `Ctrl + T` - Buscar arquivo (FZF)
- `Alt + C` - Buscar diretório (FZF)

### FZF
- `Ctrl + /` - Toggle preview
- `Ctrl + J` / `Ctrl + K` - Navegar
- `Enter` - Selecionar
- `Esc` - Cancelar

## 🐛 Solução de Problemas

### Ícones não aparecem

1. Verifique se a fonte Nerd Font está instalada:
   ```bash
   fc-list | grep -i meslo
   ```

2. Configure a fonte no terminal:
   - Nome: **MesloLGS NF**
   - Tamanho: 12

3. Reinicie o terminal

### Cores incorretas

1. Verifique o suporte a cores:
   ```bash
   echo $COLORTERM
   # Deve mostrar: truecolor
   ```

2. Teste as cores:
   ```bash
   curl -s https://gist.githubusercontent.com/lilydjwg/fdeaf79e921c2f413f44b6f613f6ad53/raw/94d8b2be62657e96488038b0e547e3009ed87d40/colors.py | python3
   ```

### Plugins não carregam

1. Verifique se os plugins foram instalados:
   ```bash
   ls ~/.oh-my-zsh/custom/plugins/
   ```

2. Reinstale plugins manualmente:
   ```bash
   git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
   ```

### Permissões

Se houver problemas com permissões:
```bash
# Corrigir permissões do usuário atual
sudo chown -R $USER:$USER ~/.oh-my-zsh ~/.zshrc
```

### Shell padrão não mudou

```bash
# Mudar shell manualmente
chsh -s $(which zsh)
# Depois faça logout e login novamente
```

## 📸 Capturas de Tela

### Prompt Principal
```
┌──(user㉿hostname)-[~/projects]
└─❯ 
```

### Git Status
```
┌──(user㉿hostname)-[~/repo] on  main ✗
└─❯ 
```

### Autocomplete
```
┌──(user㉿hostname)-[~]
└─❯ git p█
     push  pull
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📝 Changelog

### v1.0.0 (2024-12-07)
- ✅ Lançamento inicial
- ✅ Suporte para Debian/Ubuntu/Kali
- ✅ Tema branco/verde personalizado
- ✅ Configuração multi-usuário
- ✅ 100+ aliases e funções

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👤 Autor

Desenvolvido com ❤️ para a comunidade Linux

## 🙏 Agradecimentos

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Nerd Fonts](https://www.nerdfonts.com/)
- Todos os contribuidores dos plugins Zsh

## 📞 Suporte

- 🐛 **Issues**: [GitHub Issues](https://github.com/seu-usuario/terminal-config/issues)
- 💬 **Discussões**: [GitHub Discussions](https://github.com/seu-usuario/terminal-config/discussions)
- 📧 **Email**: seu-email@exemplo.com

---

⭐ Se este projeto foi útil, considere dar uma estrela!
