"""G07 — prova de corrida da camada da comunidade (achado 3 da revisão): confirmações simultâneas do
mesmo envio e envios rivais do mesmo ISBN aprovados ao mesmo tempo. Antes da trava por ISBN, ~1 em 4
rodadas terminava em deadlock (40P01). Passa se todas as rodadas terminam certas e sem erro.

Uso (Ubuntu do WSL, com `supabase start`; só banco LOCAL — usuário e senha padrão do Supabase local):
  python3 tools/supabase/provar_corrida_comunidade.py --db-url postgresql://postgres:postgres@127.0.0.1:54322/postgres [--rodadas 40]
Cria contas de teste próprias e apaga tudo no fim.
"""
from __future__ import annotations

import argparse
import subprocess
import sys

PREFIXO = "00000000-0000-7000-8000-0000000c0"  # + 3 dígitos


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--db-url", required=True)
    ap.add_argument("--rodadas", type=int, default=40)
    a = ap.parse_args()
    if "127.0.0.1" not in a.db_url and "localhost" not in a.db_url:
        raise SystemExit("use só o banco LOCAL (127.0.0.1/localhost)")

    def psql(sql: str, bg: bool = False):
        args = ["psql", a.db_url, "-X", "-q", "-At", "-v", "ON_ERROR_STOP=1", "-c", sql]
        if bg:
            return subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        r = subprocess.run(args, capture_output=True, text=True)
        if r.returncode:
            raise SystemExit(f"psql falhou: {r.stderr.strip()}")
        return r.stdout.strip()

    nomes = "abcdef"
    users = {k: f"{PREFIXO}{i:03d}" for i, k in enumerate(nomes)}
    isbns: list[str] = []

    def como(u: str) -> str:
        return ("set role authenticated; select set_config('request.jwt.claims', "
                f"'{{\"sub\":\"{u}\",\"role\":\"authenticated\"}}', false);")

    def isbn(n: int) -> str:
        doze = f"97865{n:07d}"
        s = sum(int(c) * (1 if i % 2 == 0 else 3) for i, c in enumerate(doze))
        return doze + str((10 - s % 10) % 10)

    def limpar() -> None:
        ids = ",".join(f"'{u}'" for u in users.values())
        lista = ",".join(f"'{i}'" for i in isbns) or "''"
        psql(f"delete from auth.users where id in ({ids});"
             f"delete from catalog.editions where source = 'community' and isbn13 in ({lista});"
             "delete from catalog.works w where not exists (select 1 from catalog.editions e where e.work_id = w.id)"
             " and not exists (select 1 from public.posts p where p.work_id = w.id)"
             " and w.ol_work_key is null and w.created_at > now() - interval '1 hour';")

    limpar()
    psql("insert into auth.users (id, email) values "
         + ",".join(f"('{u}', 'corrida.{k}@exemplo.com')" for k, u in users.items())
         + "; insert into private.account_age (user_id, band, source) select id, '18_plus', 'birthdate' "
           f"from auth.users where id::text like '{PREFIXO}%';")
    erros: dict[str, int] = {}
    certas = 0
    try:
        for n in range(a.rodadas):
            psql(f"delete from private.quota_usage where user_id::text like '{PREFIXO}%';")
            # 1) duas confirmações simultâneas do mesmo envio → aprovado
            i1 = isbn(900000 + 2 * n)
            isbns.append(i1)
            s1 = psql(como(users["a"]) + f"select public.catalog_submit('{i1}', 'Livro {n}', 'X') ->> 'submission_id';").split()[-1]
            ps = [psql(como(users[k]) + f"select public.catalog_confirm('{s1}') ->> 'status';", bg=True) for k in "bc"]
            # 2) dois envios rivais do mesmo ISBN chegam à 2ª confirmação juntos → um aprovado, um recusado
            i2 = isbn(900000 + 2 * n + 1)
            isbns.append(i2)
            for p in ps:
                _, err = p.communicate()
                if p.returncode:
                    chave = err.strip().splitlines()[-1][:70]
                    erros[chave] = erros.get(chave, 0) + 1
            r1 = psql(f"select status from catalog.community_submissions where id = '{s1}'")
            u1 = psql(como(users["a"]) + f"select public.catalog_submit('{i2}', 'Um {n}', 'X') ->> 'submission_id';").split()[-1]
            u2 = psql(como(users["d"]) + f"select public.catalog_submit('{i2}', 'Dois {n}', 'Y') ->> 'submission_id';").split()[-1]
            psql(como(users["b"]) + f"select public.catalog_confirm('{u1}');")
            psql(como(users["e"]) + f"select public.catalog_confirm('{u2}');")
            ps = [psql(como(users["c"]) + f"select public.catalog_confirm('{u1}') ->> 'status';", bg=True),
                  psql(como(users["f"]) + f"select public.catalog_confirm('{u2}') ->> 'status';", bg=True)]
            for p in ps:
                _, err = p.communicate()
                if p.returncode:
                    chave = err.strip().splitlines()[-1][:70]
                    erros[chave] = erros.get(chave, 0) + 1
            r2 = psql(f"select string_agg(status, ',' order by status) from catalog.community_submissions where isbn13 = '{i2}'")
            ed = psql(f"select count(*) from catalog.editions where isbn13 = '{i2}'")
            certas += r1 == "approved" and r2 == "approved,rejected" and ed == "1"
    finally:
        limpar()
    print(f"{a.rodadas} rodadas: {certas} certas; erros: {erros or 'nenhum'}")
    sys.exit(0 if certas == a.rodadas and not erros else 1)


if __name__ == "__main__":
    main()
