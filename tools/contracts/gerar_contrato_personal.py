"""Contrato de colunas aparelho ↔ servidor — gera test/data/contracts/personal_columns.json.

G04: a fonte passou a ser a migration das tabelas pessoais (`supabase/migrations/*_dados_pessoais.sql`).
Lê o information_schema de um banco do Supabase com as migrations aplicadas (o local do
`supabase start`, Postgres 17) e grava, para cada tabela de `personal`, as colunas na ordem do
servidor com o `data_type`, mais o caminho e o sha256 da migration. O teste
`test/core/data/contracts/personal_columns_contract_test.dart` compara este arquivo com a migration
(parser simples) e com o esquema local do drift. Rodar de novo sempre que a migration mudar.

Uso (no Ubuntu do WSL, com `supabase start` rodando):
  python3 tools/contracts/gerar_contrato_personal.py --db-url postgresql://postgres:postgres@127.0.0.1:54322/postgres
(usuário e senha padrão do Supabase LOCAL — não são segredo; nunca aponte para stg/prod.)
"""
import argparse
import hashlib
import json
import pathlib
import subprocess

RAIZ = pathlib.Path(__file__).resolve().parents[2]
SAIDA = RAIZ / 'test' / 'data' / 'contracts' / 'personal_columns.json'

CONSULTA = """
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


def migration_pessoal():
    achadas = sorted((RAIZ / 'supabase' / 'migrations').glob('*_dados_pessoais.sql'))
    if len(achadas) != 1:
        raise SystemExit(f'esperava 1 migration *_dados_pessoais.sql, achei {len(achadas)}')
    return achadas[0]


def psql(url, sql):
    r = subprocess.run(['psql', url, '-X', '-v', 'ON_ERROR_STOP=1', '-q', '-At', '-c', sql],
                       capture_output=True, text=True, check=False)
    if r.returncode != 0:
        raise SystemExit(f'psql falhou: {r.stderr.strip()}')
    return r.stdout.strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--db-url', required=True, help='URL do Postgres do Supabase LOCAL com as migrations aplicadas')
    a = ap.parse_args()
    if '127.0.0.1' not in a.db_url and 'localhost' not in a.db_url:
        raise SystemExit('use só o banco LOCAL (127.0.0.1/localhost)')

    tabelas = json.loads(psql(a.db_url, CONSULTA))
    versao = psql(a.db_url, 'show server_version')
    fonte = migration_pessoal()
    sha = hashlib.sha256(fonte.read_bytes()).hexdigest()
    # Uma coluna por linha ([nome, data_type]) para o diff ficar legível.
    linhas = [
        '{',
        f' "fonte": "{fonte.relative_to(RAIZ).as_posix()}",',
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
          f'{sum(len(c) for c in tabelas.values())} colunas (fonte {fonte.name}, Postgres {versao})')


if __name__ == '__main__':
    main()
