# Setup Rápido de Ambiente de Desenvolvimento (JS/Python)

Este repositório contém um script de shell interativo (`Configuração-rápida-prettier-editorConfig-cursor`) projetado para configurar rapidamente um ambiente de desenvolvimento para projetos **JavaScript/TypeScript** e/ou **Python**.

Com um único comando, ele instala as ferramentas de _linting_ e formatação mais populares, cria os arquivos de configuração necessários e prepara seu projeto para um desenvolvimento limpo, padronizado e produtivo.

## Funcionalidades Principais

O script oferece um menu interativo para você escolher exatamente o que precisa:

1.  **Setup JavaScript/TypeScript:**
    -   **Instalação de Dependências:** Instala `prettier`, `eslint` e plugins essenciais para React (`eslint-plugin-react`, `eslint-plugin-react-hooks`).
    -   **Detecção de Gerenciador:** Detecta automaticamente se você está usando `npm`, `yarn` ou `pnpm`.
    -   **Criação de Arquivos:** Gera `.prettierrc`, `.prettierignore`, e um `.eslintrc.json` com regras recomendadas para Node.js, browser e React.
    -   **Scripts no `package.json`:** Adiciona comandos úteis como `format` e `lint` ao seu `package.json`.

2.  **Setup Python:**
    -   **Instalação de Ferramentas:** Instala `black`, `pylint`, `isort`, `flake8` e `autopep8` via `pip`.
    -   **Verificação de Ambiente Virtual:** Alerta o usuário caso não esteja em um ambiente virtual (`venv`), uma boa prática essencial em Python.
    -   **Criação de Arquivos:** Gera `pyproject.toml` (para configurar `black` e `isort`), `.pylintrc` e `.flake8` com configurações padronizadas.
    -   **Dependências de Desenvolvimento:** Cria um `requirements-dev.txt` para registrar as ferramentas.

3.  **Arquivos Universais (Sempre Criados):**
    -   **`.editorconfig`:** Garante consistência de indentação, codificação de caracteres e quebras de linha em qualquer editor ou IDE que suporte o padrão. Inclui configurações específicas para arquivos Python (`.py`).
    -   **`.gitignore`:** Cria um arquivo `.gitignore` abrangente para projetos Node.js e Python, ignorando pastas como `node_modules`, `venv`, arquivos de build e de sistema operacional.

4.  **Flexibilidade:**
    -   Você pode optar por instalar uma stack completa (JS + Python), apenas uma delas, ou **apenas criar os arquivos de configuração** sem instalar nenhuma dependência, ideal para projetos onde as ferramentas já estão instaladas.

## Casos de Uso

- **Início Rápido de Novos Projetos:** Comece um novo projeto (frontend, backend ou full-stack) com as melhores práticas de formatação e linting em menos de um minuto.
- **Padronização de Projetos Existentes:** Execute o script em um projeto legado para introduzir um padrão de código consistente.
- **Ferramenta de Ensino:** Use o script para demonstrar a importância e a configuração de ferramentas de qualidade de código.

## Como Usar

1.  **Coloque o Script no seu Projeto:**
    Copie o arquivo `Configuração-rápida-prettier-editorConfig-cursor` para a pasta raiz do seu projeto.

2.  **Dê Permissão de Execução:**
    Abra o terminal na pasta do projeto e torne o script executável:
    ```bash
    chmod +x Configuração-rápida-prettier-editorConfig-cursor
    ```

3.  **Execute o Script:**
    Rode o script para iniciar o menu interativo:
    ```bash
    ./Configuração-rápida-prettier-editorConfig-cursor
    ```

4.  **Escolha uma Opção no Menu:**
    Selecione a opção desejada (1 para JS, 2 para Python, 3 para ambos, 4 para apenas arquivos de configuração) e pressione Enter. O script cuidará do resto.

5.  **Instale as Extensões no Editor:**
    Após a execução do script, instale as extensões recomendadas no seu editor (VS Code, Cursor, etc.) para obter a integração completa:
    - **Sempre:** `EditorConfig for VS Code`
    - **Para JavaScript:** `Prettier - Code formatter`, `ESLint`
    - **Para Python:** `Python`, `Black Formatter`, `Pylint`

O script fornecerá um resumo claro do que foi feito e quais os próximos passos recomendados.