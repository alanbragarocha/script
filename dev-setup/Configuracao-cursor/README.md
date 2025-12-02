# Configuração Otimizada para o Editor Cursor

Este repositório contém um arquivo de `settings.json` (`Configuração cursor.txt`) com um conjunto de configurações otimizadas para o editor de código [Cursor](https://cursor.sh/), que é um fork do VS Code. O objetivo é fornecer uma base sólida e consistente para desenvolvimento, com foco em automação, padronização de código e uma melhor experiência de usuário.

## O que este arquivo configura?

Este `settings.json` abrange diversas áreas do editor para criar um ambiente de desenvolvimento produtivo e padronizado:

1.  **Formatação Automática:**
    -   O código é formatado automaticamente ao **salvar** e ao **colar**.
    -   [Prettier](https://prettier.io/) é definido como o formatador padrão para a maioria das linguagens (JavaScript, TypeScript, JSON, HTML, CSS, etc.).
    -   Para Python, o formatador padrão é o [Black](https://github.com/psf/black), seguindo as convenções da comunidade.

2.  **Padronização de Código:**
    -   **Consistência de Estilo:** Garante o uso de espaços em vez de TABs, fim de linha no padrão Unix (`\n`) e remoção de espaços desnecessários.
    -   **Integração com `.editorconfig`:** As configurações de indentação respeitam as regras definidas no arquivo `.editorconfig` do seu projeto, garantindo que todos no time usem o mesmo padrão.
    -   **Organização de `imports`:** As importações de módulos (em JS/TS, Python) são organizadas automaticamente ao salvar.

3.  **Qualidade de Código com ESLint:**
    -   Integra-se com o [ESLint](https://eslint.org/) para corrigir automaticamente problemas de código e estilo ao salvar, mantendo o código limpo e livre de erros comuns.

4.  **Configurações de Interface e Usabilidade:**
    -   **Auto-save:** Os arquivos são salvos automaticamente quando você troca de aba ou janela.
    -   **Terminal Integrado:** Define `zsh` como shell padrão no Linux e uma fonte legível (`MesloLGS NF`), que pode ser facilmente alterada.
    -   **Melhorias Visuais:** Habilita *breadcrumbs* (trilha de navegação), um minimapa útil e renderização de espaços em branco para maior clareza.

## Casos de Uso

- **Configuração Rápida de um Novo Ambiente:** Ao instalar o Cursor em uma nova máquina, basta copiar este conteúdo para seu `settings.json` para ter um ambiente de desenvolvimento produtivo em segundos.
- **Padronização em Equipes:** Compartilhe este arquivo como uma base de configuração para garantir que todos os desenvolvedores em um projeto sigam as mesmas regras de formatação e estilo.
- **Melhorar a Produtividade:** Automatize tarefas repetitivas como formatação e organização de código, permitindo que você se concentre no que realmente importa: a lógica da aplicação.

## Como Usar

1.  **Abra as Configurações do Cursor:**
    -   Use o atalho `Ctrl + Shift + P` (ou `Cmd + Shift + P` no macOS) para abrir a paleta de comandos.
    -   Digite `Preferences: Open User Settings (JSON)` e pressione Enter.

2.  **Copie e Cole o Conteúdo:**
    -   Abra o arquivo `Configuração cursor.txt` deste repositório.
    -   Copie todo o conteúdo do arquivo.
    -   Cole o conteúdo no seu arquivo `settings.json` que foi aberto no passo anterior.

3.  **Salve o Arquivo:**
    -   Salve o arquivo `settings.json`. O Cursor aplicará as configurações imediatamente.

4.  **Instale as Extensões Recomendadas:**
    Para que todas as funcionalidades operem corretamente, certifique-se de ter as seguintes extensões instaladas no seu editor:
    -   [Prettier - Code formatter](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
    -   [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
    -   [Black Formatter](https://marketplace.visualstudio.com/items?itemName=ms-python.black-formatter) (para desenvolvimento em Python)

E pronto! Seu editor está configurado com práticas modernas de desenvolvimento.