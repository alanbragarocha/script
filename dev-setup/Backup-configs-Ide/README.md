# Backup de Configurações de IDEs e Ferramentas

Este script (`Backup-configs-Ide.sh`) automatiza o processo de backup de diretórios de configuração de várias ferramentas de desenvolvimento, como Claude, Cursor e Gemini. Ele cria um arquivo `.zip` contendo essas configurações, facilitando a restauração em uma nova máquina ou a recuperação de um estado anterior.

## Funcionalidades

- **Backup Automatizado:** Com um único comando, faz o backup de múltiplos diretórios de configuração.
- **Flexibilidade de Destino:** Permite que o usuário especifique um diretório de destino para o backup. Caso nenhum seja fornecido, o padrão é `~/backups`.
- **Organização:** Os backups são nomeados com data e hora (`config_backup_YYYYMMDD_HHMMSS.zip`), facilitando a identificação.
- **Verificação de Existência:** O script verifica se os diretórios de configuração realmente existem antes de tentar o backup, evitando erros.
- **Preservação de Estrutura:** Mantém os caminhos relativos e links simbólicos dentro do arquivo `.zip`.

## Diretórios Incluídos no Backup

O script foi projetado para fazer backup dos seguintes diretórios (se existirem na sua pasta `HOME`):

- `.claude`
- `.cursor`
- `.gemini`
- `.config/Cursor`

## Casos de Uso

- **Migração de Ambiente:** Ao configurar um novo computador, você pode usar este script para transferir rapidamente todas as suas configurações de IDE e ferramentas.
- **Prevenção de Perdas:** Faça backups regulares para garantir que suas personalizações, extensões e configurações não sejam perdidas em caso de falha no disco ou erro de sistema.
- **Experimentação Segura:** Antes de testar uma nova configuração ou extensão que possa causar problemas, crie um ponto de restauração seguro.

## Como Usar

1.  **Dar Permissão de Execução:**
    Antes de executar o script pela primeira vez, você precisa torná-lo executável.

    ```bash
    chmod +x Backup-configs-Ide.sh
    ```

2.  **Execução Básica (Destino Padrão):**
    Para criar um backup no diretório padrão (`~/backups`):

    ```bash
    ./Backup-configs-Ide.sh
    ```

3.  **Execução com Destino Específico:**
    Para salvar o backup em um diretório diferente (ex: `/mnt/hd-externo/backups`):

    ```bash
    ./Backup-configs-Ide.sh /mnt/hd-externo/backups
    ```

## Como Restaurar

Para restaurar as configurações, basta descompactar o arquivo `.zip` desejado na sua pasta `HOME`.

```bash
unzip config_backup_YYYYMMDD_HHMMSS.zip -d "$HOME"
```

**Atenção:** A restauração irá sobrescrever as configurações atuais. Faça um backup das configurações existentes antes de restaurar um backup antigo, se necessário.