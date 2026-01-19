# Renomeador de Arquivos

Script interativo com menu para renomear arquivos de qualquer tipo.

## 🚀 Como Usar

Execute o script:

```bash
python renomear_arquivos.py
```

## 📋 Fluxo de Uso

### 1. Configuração Inicial (Obrigatória)

Ao executar o script, você **DEVE** informar o caminho da pasta onde estão os arquivos:

```
Digite o caminho da pasta com os arquivos: D:\Músicas
```

- O caminho é **obrigatório** - não pode ser deixado em branco
- O script valida se a pasta existe antes de continuar
- Se a pasta não existir, você pode tentar novamente ou sair

### 2. Opções do Menu

Após configurar o caminho, o menu será exibido:

#### Opção 1: Remover números e hífen do início

Remove padrões como `29 -`, `30 -` do início dos nomes dos arquivos.

**Exemplo:**

- `29 - Zoação.mp3` → `Zoação.mp3`
- `100 - Música.mp3` → `Música.mp3`

#### Opção 2: Padronizar nomes

Substitui hífens (`-`) e underscores (`_`) por espaços e padroniza espaços múltiplos.

**Exemplo:**

- `Alok - Alive.mp3` → `Alok Alive.mp3`
- `Arquivo_com_underscore.mp3` → `Arquivo com underscore.mp3`
- `Múltiplos    espaços.mp3` → `Múltiplos espaços.mp3`

#### Opção 3: Capitalizar nomes

Deixa apenas a primeira letra de cada palavra maiúscula, resto minúsculo.

**Exemplo:**

- `ALOK - ALIVE.mp3` → `Alok - Alive.mp3`
- `DENNIS - A ESTRADA.mp3` → `Dennis - A Estrada.mp3`

#### Opção 4: Sair

Encerra o programa.

## ⚙️ Funcionalidades

- ✅ Caminho obrigatório no início (garante que você sempre saiba qual pasta está processando)
- ✅ Menu interativo fácil de usar
- ✅ Preview antes de renomear (mostra o que será feito)
- ✅ Processa todas as subpastas automaticamente
- ✅ Mostra progresso e estatísticas
- ✅ Tratamento de erros e arquivos duplicados
- ✅ Suporte a caracteres especiais (acentos, etc)

## 📝 Exemplo de Uso Completo

1. Execute: `python renomear_arquivos.py`
2. **Digite o caminho da pasta** (obrigatório):

   ```
   Digite o caminho da pasta com os arquivos: D:\Músicas
   ```

3. Escolha a opção desejada (1, 2 ou 3)
4. Escolha ver preview primeiro (recomendado - digite `s` ou apenas Enter)
5. Revise o preview para ver o que será feito
6. Se estiver satisfeito, execute a opção novamente e escolha `n` para não ver preview
7. Confirme a renomeação quando solicitado

## ⚠️ Importante

- **O caminho é obrigatório** - você deve informar antes de usar qualquer função
- O script sempre oferece preview primeiro (recomendado)
- Você precisa confirmar antes de renomear de verdade
- Faça backup dos seus arquivos antes de processar muitos arquivos
- O script processa **TODAS as subpastas** automaticamente

## 🔧 Configuração

Você pode editar o script para mudar:

- Extensão padrão (linha ~200): `extensao = ".mp3"` (pode ser alterado para `.txt`, `.jpg`, `.pdf`, etc)

**Nota:** O caminho não é mais configurável no código, pois é solicitado ao usuário no início da execução. O script funciona com qualquer tipo de arquivo, não apenas músicas.
