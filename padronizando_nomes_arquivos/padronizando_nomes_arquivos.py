import os
import re
import sys
from pathlib import Path


def safe_print(texto):
    """Imprime texto de forma segura, tratando encoding"""
    try:
        print(texto)
    except UnicodeEncodeError:
        texto_seguro = texto.encode('ascii', 'ignore').decode('ascii')
        print(texto_seguro)


def limpar_nome_arquivo(nome_arquivo):
    """Remove número e hífen do início do nome do arquivo"""
    nome_limpo = re.sub(r'^\d+\s*-\s*', '', nome_arquivo)
    return nome_limpo.strip()


def padronizar_nome(nome_arquivo):
    """Substitui hífens e underscores por espaços e padroniza espaços"""
    nome_limpo = nome_arquivo.replace('-', ' ').replace('_', ' ')
    nome_limpo = re.sub(r'\s+', ' ', nome_limpo)
    return nome_limpo.strip()


def capitalizar_nome(nome_arquivo):
    """Capitaliza o nome: primeira letra maiúscula, resto minúsculo"""
    partes = re.split(r'(\s+|\(|\)|\[|\]|\.|,|&|-)', nome_arquivo)
    resultado = []

    for parte in partes:
        if not parte:
            continue
        elif re.match(r'^\s+$', parte):
            resultado.append(parte)
        elif parte in '()[].,&-':
            resultado.append(parte)
        else:
            resultado.append(parte.capitalize())

    nome_capitalizado = ''.join(resultado)
    nome_capitalizado = re.sub(r'\s+', ' ', nome_capitalizado)
    return nome_capitalizado.strip()


def processar_arquivo(caminho_arquivo, funcao):
    """Processa um arquivo usando a função especificada"""
    try:
        pasta = os.path.dirname(caminho_arquivo)
        nome_antigo = os.path.basename(caminho_arquivo)
        nome_base, extensao = os.path.splitext(nome_antigo)

        # Aplica a função escolhida
        if funcao == 'remover_numero':
            nome_novo_base = limpar_nome_arquivo(nome_base)
        elif funcao == 'padronizar':
            nome_novo_base = padronizar_nome(nome_base)
        elif funcao == 'capitalizar':
            nome_novo_base = capitalizar_nome(nome_base)
        else:
            return False, "Função inválida"

        # Se não mudou nada
        if nome_novo_base == nome_base:
            return False, "Nome não precisa ser alterado"

        nome_novo = nome_novo_base + extensao
        caminho_novo = os.path.join(pasta, nome_novo)

        # Verifica se já existe
        if os.path.exists(caminho_novo) and caminho_novo != caminho_arquivo:
            # Se é capitalizar, verifica se é só diferença de case
            if funcao == 'capitalizar' and nome_novo.lower() == nome_antigo.lower():
                return False, "Nome não precisa ser alterado"
            return False, f"Arquivo '{nome_novo}' já existe!"

        return True, nome_novo

    except Exception as e:
        return False, str(e)


def renomear_arquivo(caminho_arquivo, caminho_novo):
    """Renomeia o arquivo"""
    try:
        os.rename(caminho_arquivo, caminho_novo)
        return True
    except Exception as e:
        return False


def mostrar_menu():
    """Mostra o menu principal"""
    print("\n" + "="*60)
    print("MENU DE RENOMEAÇÃO DE ARQUIVOS")
    print("="*60)
    print("1. Remover números e hífen do início (ex: '29 - Zoação' -> 'Zoação')")
    print("2. Padronizar nomes (substituir - e _ por espaços)")
    print("3. Capitalizar nomes (primeira letra maiúscula)")
    print("4. Sair")
    print("="*60)


def executar_processamento(pasta_arquivos, extensao, funcao, modo_preview=True):
    """Executa o processamento dos arquivos"""
    pasta_path = Path(pasta_arquivos)

    if not pasta_path.exists():
        print(f"\nERRO: Pasta '{pasta_arquivos}' não encontrada!")
        return

    # Busca arquivos
    arquivos = list(pasta_path.rglob(f'*{extensao}'))

    if not arquivos:
        print(f"\nNenhum arquivo {extensao} encontrado!")
        return

    pastas_unicas = set(arquivo.parent for arquivo in arquivos)
    print(f"\nEncontrados {len(arquivos)} arquivo(s) em {len(pastas_unicas)} pasta(s)...")

    if modo_preview:
        print("\nMODO PREVIEW - Nenhum arquivo sera renomeado")
        print("Escolha a opção novamente e confirme para renomear de verdade\n")

    sucessos = 0
    erros = 0
    sem_mudanca = 0

    for arquivo in arquivos:
        sucesso, resultado = processar_arquivo(str(arquivo), funcao)
        caminho_relativo = arquivo.relative_to(pasta_path)
        pasta_arquivo = caminho_relativo.parent if caminho_relativo.parent != Path('.') else Path('.')

        if sucesso:
            if resultado == "Nome não precisa ser alterado":
                sem_mudanca += 1
            else:
                if not modo_preview:
                    # Renomeia de verdade
                    caminho_novo = os.path.join(arquivo.parent, resultado)
                    if renomear_arquivo(str(arquivo), caminho_novo):
                        if pasta_arquivo != Path('.'):
                            safe_print(f"OK [{pasta_arquivo}] {arquivo.name} -> {resultado}")
                        else:
                            safe_print(f"OK Renomeado: {arquivo.name} -> {resultado}")
                        sucessos += 1
                    else:
                        safe_print(f"ERRO ao renomear: {arquivo.name}")
                        erros += 1
                else:
                    # Preview
                    if pasta_arquivo != Path('.'):
                        safe_print(f"  [{pasta_arquivo}] Seria renomeado: {arquivo.name} -> {resultado}")
                    else:
                        safe_print(f"  Seria renomeado: {arquivo.name} -> {resultado}")
                    sucessos += 1
        else:
            if resultado != "Nome não precisa ser alterado":
                if pasta_arquivo != Path('.'):
                    safe_print(f"ERRO [{pasta_arquivo}] {arquivo.name}: {resultado}")
                else:
                    safe_print(f"ERRO em {arquivo.name}: {resultado}")
                erros += 1
            else:
                sem_mudanca += 1

    print(f"\n{'='*60}")
    if modo_preview:
        print(f"Preview: {sucessos} arquivo(s) seriam processados")
    else:
        print(f"Concluido! {sucessos} arquivo(s) processado(s)")
    print(f"  {erros} erro(s), {sem_mudanca} sem mudanca")
    print("="*60)


def main():
    """Função principal com menu interativo"""
    extensao = ".mp3"

    # Solicita o caminho obrigatoriamente no início
    print("="*60)
    print("CONFIGURAÇÃO INICIAL - CAMINHO DA PASTA")
    print("="*60)
    pasta_arquivos = None

    while pasta_arquivos is None:
        caminho_input = input("Digite o caminho da pasta com os arquivos: ").strip()

        if not caminho_input:
            print("ERRO: O caminho é obrigatório! Digite um caminho válido.")
            continue

        # Verifica se existe
        if not Path(caminho_input).exists():
            print(f"ERRO: Pasta '{caminho_input}' não encontrada!")
            continuar = input("Deseja tentar novamente? (s/n): ").strip().lower()
            if continuar != 's':
                print("Saindo...")
                return
            continue

        pasta_arquivos = caminho_input
        print(f"\nCaminho configurado: {pasta_arquivos}\n")

    while True:
        mostrar_menu()
        opcao = input("\nEscolha uma opção (1-4): ").strip()

        if opcao == '1':
            print("\nOpção 1: Remover números e hífen do início")
            confirmar = input("Deseja ver preview primeiro? (s/n) [s]: ").strip().lower()
            preview = confirmar != 'n'

            if not preview:
                confirmar_final = input("ATENÇÃO: Isso vai renomear os arquivos! Continuar? (s/n): ").strip().lower()
                if confirmar_final != 's':
                    print("Operação cancelada.")
                    continue

            executar_processamento(pasta_arquivos, extensao, 'remover_numero', preview)

        elif opcao == '2':
            print("\nOpção 2: Padronizar nomes (substituir - e _ por espaços)")
            confirmar = input("Deseja ver preview primeiro? (s/n) [s]: ").strip().lower()
            preview = confirmar != 'n'

            if not preview:
                confirmar_final = input("ATENÇÃO: Isso vai renomear os arquivos! Continuar? (s/n): ").strip().lower()
                if confirmar_final != 's':
                    print("Operação cancelada.")
                    continue

            executar_processamento(pasta_arquivos, extensao, 'padronizar', preview)

        elif opcao == '3':
            print("\nOpção 3: Capitalizar nomes")
            confirmar = input("Deseja ver preview primeiro? (s/n) [s]: ").strip().lower()
            preview = confirmar != 'n'

            if not preview:
                confirmar_final = input("ATENÇÃO: Isso vai renomear os arquivos! Continuar? (s/n): ").strip().lower()
                if confirmar_final != 's':
                    print("Operação cancelada.")
                    continue

            executar_processamento(pasta_arquivos, extensao, 'capitalizar', preview)

        elif opcao == '4':
            print("\nSaindo...")
            break

        else:
            print("\nOpção inválida! Escolha uma opção de 1 a 4.")

        input("\nPressione Enter para continuar...")


if __name__ == "__main__":
    main()
