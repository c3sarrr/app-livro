"""G03 · contrato de colunas — gera test/data/contracts/personal_columns.json.

Lê o information_schema de um Postgres com o SQL de referência aplicado
(handoff_v2/sql/00_stub_supabase_local.sql + 01_schema_booknest.sql) e grava, para cada tabela de
`personal`, as colunas na ordem do servidor com o `data_type`, mais o sha256 do SQL usado.
O teste `test/core/data/contracts/personal_columns_contract_test.dart` compara este arquivo com o
SQL (parser simples) e com o esquema local do drift. Rodar de novo sempre que o SQL mudar
(a G04 troca a fonte para `supabase/migrations`).

Uso:  python3 tools/contracts/gerar_contrato_personal.py --psql "psql -h /tmp -p 55432 -U postgres"
"""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess

RAIZ = pathlib.Path(__file__).resolve().parents[2]
SQL = RAIZ / 'handoff_v2' / 'sql'
SAIDA = RAIZ / 'test' / 'data' / 'contracts' / 'personal_columns.json'
BANCO = 'booknest_contrato_g03'


def psql(base, *args, entrada=None):
    cmd = shlex.split(base) + ['-v', 'ON_ERROR_STOP=1', '-q', *args]
    r = subprocess.run(cmd, input=entrada, capture_output=True, text=True, check=False)
    if r.returncode != 0:
        raise SystemExit(f'psql falhou: {r.stderr.strip()}')
    return r.stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--psql', default='psql', help='comando psql com host/porta/usuário')
    a = ap.parse_args()

    psql(a.psql, '-d', 'postgres', '-c', f'DROP DATABASE IF EXISTS {BANCO}')
    psql(a.psql, '-d', 'postgres', '-c', f'CREATE DATABASE {BANCO}')
    try:
        for f in ['00_stub_supabase_local.sql', '01_schema_booknest.sql']:
            psql(a.psql, '-d', BANCO, '-f', str(SQL / f))
        consulta = """
          select json_object_agg(t, cols order by t) from (
            select table_name t,
                   json_agg(json_build_array(column_name, data_type) order by ordinal_position) cols
              from information_schema.columns
             where table_schema = 'personal'
               and table_name in (select relname from pg_class c
                                   join pg_namespace n on n.oid = c.relnamespace
                                  where n.nspname = 'personal' and not c.relispartition
                                    and c.relkind in ('r', 'p'))
             group by table_name) x
        """
        tabelas = json.loads(psql(a.psql, '-d', BANCO, '-At', '-c', consulta))
        versao = psql(a.psql, '-d', BANCO, '-At', '-c', 'show server_version').strip()
    finally:
        psql(a.psql, '-d', 'postgres', '-c', f'DROP DATABASE IF EXISTS {BANCO}')

    sha = hashlib.sha256((SQL / '01_schema_booknest.sql').read_bytes()).hexdigest()
    # Uma coluna por linha ([nome, data_type]) para o diff ficar legível.
    linhas = [
        '{',
        f' "fonte": "handoff_v2/sql/01_schema_booknest.sql",',
        f' "sha256_da_fonte": "{sha}",',
        f' "postgres": {json.dumps(versao)},',
        ' "tabelas": {',
    ]
    for i, (t, cols) in enumerate(tabelas.items()):
        linhas.append(f'  "{t}": [')
        linhas += [f'   {json.dumps([c, d])}' + (',' if j < len(cols) - 1 else '') for j, (c, d) in enumerate(cols)]
        linhas.append('  ]' + (',' if i < len(tabelas) - 1 else ''))
    linhas += [' }', '}']
    SAIDA.parent.mkdir(parents=True, exist_ok=True)
    SAIDA.write_text('\n'.join(linhas) + '\n', encoding='utf-8', newline='\n')
    print(f'{SAIDA.relative_to(RAIZ)}: {len(tabelas)} tabelas, '
          f'{sum(len(c) for c in tabelas.values())} colunas')


if __name__ == '__main__':
    main()
