#!/bin/bash

################################################################################
# Setup Completo de Desenvolvimento - COM MENU INTERATIVO
# JavaScript/TypeScript + Python (Django/Flask)
#
# Cobre: JS, JSX, TS, Node.js, Vite, React, HTML, CSS, Python, Django, Flask
# Não cria: .vscode/settings.json (você configura depois)
#
# Uso: bash setup-dev-complete.sh
#
# Autor: Alan Reis
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

################################################################################
# FUNÇÕES DO MENU
################################################################################

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║   🚀 SETUP COMPLETO - JAVASCRIPT + PYTHON (COM MENU)            ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

show_menu() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    ESCOLHA O QUE INSTALAR                         ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}\n"

    echo -e "${YELLOW}[1]${NC} JavaScript/TypeScript/React/Node.js/Vite"
    echo -e "    ${BLUE}→${NC} Prettier, ESLint (com plugins React)"
    echo -e "    ${BLUE}→${NC} Configurações para JS, JSX, TS, TSX, HTML, CSS"
    echo -e "    ${GREEN}→${NC} + Arquivos Universais (.editorconfig, .gitignore)\n"

    echo -e "${YELLOW}[2]${NC} Python/Django/Flask"
    echo -e "    ${BLUE}→${NC} Black, Pylint, isort, Flake8"
    echo -e "    ${BLUE}→${NC} Configurações para Python"
    echo -e "    ${GREEN}→${NC} + Arquivos Universais (.editorconfig, .gitignore)\n"

    echo -e "${YELLOW}[3]${NC} Instalar TUDO (JavaScript + Python)"
    echo -e "    ${BLUE}→${NC} Setup completo para projetos fullstack"
    echo -e "    ${GREEN}→${NC} + Arquivos Universais (.editorconfig, .gitignore)\n"

    echo -e "${YELLOW}[4]${NC} Apenas criar arquivos de configuração (sem instalar dependências)"
    echo -e "    ${BLUE}→${NC} Útil se você já tem tudo instalado"
    echo -e "    ${GREEN}→${NC} + Arquivos Universais (.editorconfig, .gitignore)\n"

    echo -e "${GREEN}✓ Arquivos universais são SEMPRE criados independente da opção!${NC}\n"

    echo -e "${RED}[0]${NC} Sair\n"

    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}\n"
}

show_banner

################################################################################
# FUNÇÕES DE INSTALAÇÃO
################################################################################

install_javascript() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}📦 INSTALANDO FERRAMENTAS JAVASCRIPT/TYPESCRIPT${NC}\n"

    # Detectar gerenciador de pacotes
    PACKAGE_MANAGER="npm"
    if [ -f "pnpm-lock.yaml" ] && command -v pnpm &> /dev/null; then
        PACKAGE_MANAGER="pnpm"
    elif [ -f "yarn.lock" ] && command -v yarn &> /dev/null; then
        PACKAGE_MANAGER="yarn"
    fi

    echo -e "${GREEN}✓${NC} Usando: ${CYAN}$PACKAGE_MANAGER${NC}\n"

    # Criar package.json se não existir
    if [ ! -f "package.json" ]; then
        echo -e "${YELLOW}Criando package.json...${NC}"
        npm init -y
    fi

    # Backup
    [ -f "package.json" ] && cp package.json "package.json.backup.$(date +%Y%m%d_%H%M%S)"

    # Verificar e instalar dependências
    DEPS_TO_INSTALL=()
    echo -e "${BLUE}Verificando dependências...${NC}\n"

    for dep in prettier eslint eslint-config-prettier eslint-plugin-prettier eslint-plugin-react eslint-plugin-react-hooks; do
        if grep -q "\"$dep\"" package.json 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $dep (já instalado)"
        else
            echo -e "${YELLOW}⊕${NC} $dep (será instalado)"
            DEPS_TO_INSTALL+=("$dep")
        fi
    done

    # Instalar
    if [ ${#DEPS_TO_INSTALL[@]} -gt 0 ]; then
        echo -e "\n${CYAN}Instalando ${#DEPS_TO_INSTALL[@]} dependências...${NC}\n"

        if [ "$PACKAGE_MANAGER" = "npm" ]; then
            npm install --save-dev "${DEPS_TO_INSTALL[@]}"
        elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
            yarn add -D "${DEPS_TO_INSTALL[@]}"
        elif [ "$PACKAGE_MANAGER" = "pnpm" ]; then
            pnpm add -D "${DEPS_TO_INSTALL[@]}"
        fi

        echo -e "\n${GREEN}✓${NC} Dependências instaladas!"
    else
        echo -e "\n${GREEN}✓${NC} Todas as dependências já instaladas!"
    fi

    # Adicionar scripts
    if command -v node &> /dev/null; then
        echo -e "\n${BLUE}Adicionando scripts ao package.json...${NC}"
        node <<'NODESCRIPT'
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
if (!pkg.scripts) pkg.scripts = {};
const scripts = {
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
};
let added = 0;
Object.keys(scripts).forEach(key => {
    if (!pkg.scripts[key]) {
        pkg.scripts[key] = scripts[key];
        added++;
    }
});
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
console.log(`✓ ${added} scripts adicionados`);
NODESCRIPT
    fi

    # Criar arquivos de configuração JS
    create_js_config_files

    echo -e "\n${GREEN}✅ JavaScript/TypeScript configurado!${NC}"
}

install_python() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}🐍 INSTALANDO FERRAMENTAS PYTHON${NC}\n"

    # Detectar Python
    PYTHON_CMD="python3"
    PIP_CMD="pip3"
    if ! command -v python3 &> /dev/null; then
        if command -v python &> /dev/null; then
            PYTHON_CMD="python"
            PIP_CMD="pip"
        else
            echo -e "${RED}❌ Python não encontrado!${NC}"
            echo -e "${YELLOW}Instale Python: https://www.python.org/downloads/${NC}"
            return 1
        fi
    fi

    echo -e "${GREEN}✓${NC} Python: ${CYAN}$($PYTHON_CMD --version)${NC}"

    # Verificar virtual environment
    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo -e "${YELLOW}⚠ Virtual environment não detectado${NC}"
        echo -e "${BLUE}Recomendado: python3 -m venv venv && source venv/bin/activate${NC}\n"
        echo -e "${YELLOW}Continuar mesmo assim? (s/n): ${NC}"
        read -r response
        if [[ ! "$response" =~ ^([sS]|[yY])$ ]]; then
            return 1
        fi
    else
        echo -e "${GREEN}✓${NC} Virtual env: ${CYAN}$VIRTUAL_ENV${NC}"
    fi

    # Verificar e instalar ferramentas
    echo -e "\n${BLUE}Verificando ferramentas Python...${NC}\n"
    PYTHON_TOOLS=()

    for tool in black pylint isort flake8 autopep8; do
        if $PIP_CMD show "$tool" &> /dev/null 2>&1; then
            version=$($PIP_CMD show "$tool" | grep Version | cut -d' ' -f2)
            echo -e "${GREEN}✓${NC} $tool ($version)"
        else
            echo -e "${YELLOW}⊕${NC} $tool (será instalado)"
            PYTHON_TOOLS+=("$tool")
        fi
    done

    # Instalar
    if [ ${#PYTHON_TOOLS[@]} -gt 0 ]; then
        echo -e "\n${CYAN}Instalando ${#PYTHON_TOOLS[@]} ferramentas...${NC}\n"
        $PIP_CMD install "${PYTHON_TOOLS[@]}"
        echo -e "\n${GREEN}✓${NC} Ferramentas instaladas!"
    else
        echo -e "\n${GREEN}✓${NC} Todas as ferramentas já instaladas!"
    fi

    # Criar requirements-dev.txt
    if [ ! -f "requirements-dev.txt" ]; then
        echo -e "\n${BLUE}Criando requirements-dev.txt...${NC}"
        cat > requirements-dev.txt << 'EOF'
# Ferramentas de Desenvolvimento Python
black>=23.0.0
pylint>=3.0.0
isort>=5.12.0
flake8>=6.0.0
autopep8>=2.0.0
EOF
        echo -e "${GREEN}✓${NC} requirements-dev.txt criado"
    fi

    # Criar arquivos de configuração Python
    create_python_config_files

    echo -e "\n${GREEN}✅ Python configurado!${NC}"
}

################################################################################
# FUNÇÕES DE CRIAÇÃO DE ARQUIVOS
################################################################################

################################################################################
# FUNÇÕES DE CRIAÇÃO DE ARQUIVOS
################################################################################

create_js_config_files() {
    echo -e "\n${BLUE}Criando arquivos de configuração JavaScript...${NC}\n"

    # .prettierrc
    cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "bracketSpacing": true,
  "jsxSingleQuote": false
}
EOF
    echo -e "${GREEN}✓${NC} .prettierrc"

    # .prettierignore
    cat > .prettierignore << 'EOF'
node_modules
dist
build
.next
out
coverage
*.min.js
*.min.css
package-lock.json
yarn.lock
__pycache__
*.pyc
venv
.venv
EOF
    echo -e "${GREEN}✓${NC} .prettierignore"

    # .eslintrc.json
    cat > .eslintrc.json << 'EOF'
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "prettier"
  ],
  "parserOptions": {
    "ecmaFeatures": { "jsx": true },
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "plugins": ["react", "prettier"],
  "rules": {
    "prettier/prettier": ["error", { "endOfLine": "auto" }],
    "no-console": "warn",
    "no-unused-vars": "warn",
    "react/react-in-jsx-scope": "off",
    "react/prop-types": "warn"
  },
  "settings": {
    "react": { "version": "detect" }
  }
}
EOF
    echo -e "${GREEN}✓${NC} .eslintrc.json"
}

create_python_config_files() {
    echo -e "\n${BLUE}Criando arquivos de configuração Python...${NC}\n"

    # pyproject.toml
    cat > pyproject.toml << 'EOF'
[tool.black]
line-length = 88
target-version = ['py38', 'py39', 'py310', 'py311']
extend-exclude = '''
/(\.git|\.venv|venv|env|build|dist|migrations|node_modules|staticfiles)/
'''

[tool.isort]
profile = "black"
line_length = 88
skip_glob = ["*/migrations/*", "*/venv/*", "*/node_modules/*"]
known_django = "django"
sections = ["FUTURE", "STDLIB", "DJANGO", "THIRDPARTY", "FIRSTPARTY", "LOCALFOLDER"]

[tool.pylint.format]
max-line-length = 88

[tool.pylint.messages_control]
disable = ["C0111", "C0103", "R0903"]
EOF
    echo -e "${GREEN}✓${NC} pyproject.toml"

    # .pylintrc
    cat > .pylintrc << 'EOF'
[MASTER]
ignore=migrations,node_modules,venv,.venv,staticfiles,media

[MESSAGES CONTROL]
disable=missing-docstring,invalid-name,too-few-public-methods

[FORMAT]
max-line-length=88
EOF
    echo -e "${GREEN}✓${NC} .pylintrc"

    # .flake8
    cat > .flake8 << 'EOF'
[flake8]
max-line-length = 88
ignore = E203,E501,W503
exclude = .git,__pycache__,.venv,venv,migrations,node_modules
EOF
    echo -e "${GREEN}✓${NC} .flake8"
}

create_universal_files() {
    echo -e "\n${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ CRIANDO ARQUIVOS UNIVERSAIS (sempre criados)${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}\n"

    echo -e "${BLUE}Estes arquivos funcionam para qualquer projeto:${NC}\n"

    # .editorconfig
    cat > .editorconfig << 'EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.py]
indent_size = 4

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EOF
    echo -e "${GREEN}✓${NC} .editorconfig ${CYAN}(configura indentação, encoding, line endings)${NC}"

    # .gitignore
    if [ ! -f .gitignore ]; then
        cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
.Python
venv/
.venv/
*.egg-info/
dist/
build/

# Django/Flask
*.log
db.sqlite3
media/
staticfiles/

# Node
node_modules/
dist/
build/
.next/

# IDEs
.vscode/
.idea/

# OS
.DS_Store

# Env
.env
EOF
        echo -e "${GREEN}✓${NC} .gitignore ${CYAN}(ignora arquivos desnecessários no git)${NC}"
    else
        echo -e "${YELLOW}⊘${NC} .gitignore ${CYAN}(já existe, não foi modificado)${NC}"
    fi

    echo -e "\n${GREEN}Arquivos universais criados! Funcionam para JS, Python, etc.${NC}"
}

show_summary() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ CONFIGURAÇÃO CONCLUÍDA!${NC}\n"

    echo -e "${BLUE}📦 Arquivos criados:${NC}\n"

    # Arquivos universais (sempre)
    echo -e "${GREEN}✓ Universais (sempre criados):${NC}"
    echo -e "  • .editorconfig"
    echo -e "  • .gitignore"
    echo ""

    # Arquivos JavaScript
    if [ "$1" = "js" ] || [ "$1" = "both" ]; then
        echo -e "${YELLOW}✓ JavaScript/TypeScript:${NC}"
        echo -e "  • .prettierrc"
        echo -e "  • .prettierignore"
        echo -e "  • .eslintrc.json"
        echo -e "  • package.json (atualizado com scripts)"
        echo ""
    fi

    # Arquivos Python
    if [ "$1" = "python" ] || [ "$1" = "both" ]; then
        echo -e "${PURPLE}✓ Python:${NC}"
        echo -e "  • pyproject.toml"
        echo -e "  • .pylintrc"
        echo -e "  • .flake8"
        echo -e "  • requirements-dev.txt"
        echo ""
    fi

    echo -e "${CYAN}📋 Próximos passos:${NC}\n"

    if [ "$1" = "js" ] || [ "$1" = "both" ]; then
        echo -e "${YELLOW}JavaScript/TypeScript:${NC}"
        echo -e "  ${CYAN}npm run format${NC}     # Formatar código"
        echo -e "  ${CYAN}npm run lint${NC}       # Verificar erros"
        echo ""
    fi

    if [ "$1" = "python" ] || [ "$1" = "both" ]; then
        echo -e "${YELLOW}Python:${NC}"
        echo -e "  ${CYAN}black .${NC}            # Formatar código"
        echo -e "  ${CYAN}pylint *.py${NC}        # Verificar erros"
        echo -e "  ${CYAN}isort .${NC}            # Organizar imports"
        echo ""
    fi

    echo -e "${YELLOW}📦 Instale extensões no Cursor:${NC}"
    echo "  • EditorConfig (sempre)"
    [ "$1" = "js" ] || [ "$1" = "both" ] && echo "  • Prettier, ESLint"
    [ "$1" = "python" ] || [ "$1" = "both" ] && echo "  • Python, Black Formatter, Pylint"

    echo -e "\n${GREEN}🚀 Pronto! Configure o settings.json depois!${NC}\n"
}

################################################################################
# LOOP PRINCIPAL DO MENU
################################################################################

while true; do
    show_menu

    echo -e -n "${YELLOW}Escolha uma opção [0-4]: ${NC}"
    read -r choice

    case $choice in
        1)
            show_banner
            echo -e "${GREEN}Você escolheu: JavaScript/TypeScript${NC}\n"
            install_javascript
            create_universal_files
            show_summary "js"
            break
            ;;
        2)
            show_banner
            echo -e "${GREEN}Você escolheu: Python${NC}\n"
            install_python
            create_universal_files
            show_summary "python"
            break
            ;;
        3)
            show_banner
            echo -e "${GREEN}Você escolheu: TUDO (JavaScript + Python)${NC}\n"
            install_javascript
            echo ""
            install_python
            create_universal_files
            show_summary "both"
            break
            ;;
        4)
            show_banner
            echo -e "${GREEN}Você escolheu: Apenas arquivos de configuração${NC}\n"
            echo -e "${YELLOW}Criando arquivos JS, Python e Universais...${NC}\n"
            create_js_config_files
            create_python_config_files
            create_universal_files
            echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
            echo -e "${GREEN}✅ Todos os arquivos criados!${NC}\n"
            echo -e "${BLUE}Arquivos JavaScript:${NC}"
            echo "  • .prettierrc, .prettierignore, .eslintrc.json"
            echo -e "\n${BLUE}Arquivos Python:${NC}"
            echo "  • pyproject.toml, .pylintrc, .flake8"
            echo -e "\n${BLUE}Arquivos Universais:${NC}"
            echo "  • .editorconfig, .gitignore"
            echo -e "\n${YELLOW}💡 Dica: Instale as dependências depois com npm/pip${NC}\n"
            break
            ;;
        0)
            echo -e "\n${YELLOW}Saindo... Até logo!${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Opção inválida! Escolha entre 0 e 4.${NC}\n"
            sleep 2
            show_banner
            ;;
    esac
done
