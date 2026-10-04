"""Confere as regras de forma das migrations do Supabase (Anexo 02 §5.4; PROMPT MESTRE G04).

1. Nome `<14 dígitos>_<assunto>.sql` (gerado por `supabase migration new <assunto>`), em ordem.
2. Toda migration TERMINA com o bloco "-- Permissões": depois do último cabeçalho
   `-- Permissões` só pode haver comentário, linha vazia, REVOKE, GRANT ou ALTER DEFAULT PRIVILEGES.
3. Toda função `security definer` declara `set search_path`.
4. Nenhum `create extension ... version` (o Supabase ignora a versão desde 05/08/2026).
5. Nenhuma migration já publicada foi alterada (compara com `git show <base>:<arquivo>` quando o
   arquivo existe na base; base padrão HEAD; no CI, a branch de destino do PR ou o commit anterior)
   — migration aplicada não se edita; cria-se outra. (--permitir-editar ARQ só antes do 1º push.)

Uso: python3 tools/supabase/verificar_migrations.py [--base REF] [--permitir-editar ARQ ...]
"""
import argparse
import pathlib
import re
import subprocess
import sys

RAIZ = pathlib.Path(__file__).resolve().parents[2]
PASTA = RAIZ / 'supabase' / 'migrations'
NOME = re.compile(r'^\d{14}_[a-z0-9_]+\.sql$')
PERMITIDO_NO_FIM = re.compile(r'^(revoke|grant|alter\s+default\s+privileges)\b', re.I)


def comandos(texto):
    """Divide em comandos SQL de nível superior, ignorando ';' dentro de $$…$$, aspas e comentários."""
    atual, saida, i, dolar = [], [], 0, None
    while i < len(texto):
        if dolar:
            j = texto.find(dolar, i)
            j = len(texto) if j < 0 else j + len(dolar)
            atual.append(texto[i:j]); i = j; dolar = None; continue
        m = re.match(r'\$[A-Za-z_]*\$', texto[i:])
        if m:
            dolar = m.group(0); atual.append(dolar); i += len(dolar); continue
        if texto.startswith('--', i):
            j = texto.find('\n', i); j = len(texto) if j < 0 else j
            i = j; continue
        if texto[i] == "'":
            j = i + 1
            while j < len(texto):
                if texto[j] == "'" and texto[j + 1:j + 2] == "'": j += 2; continue
                if texto[j] == "'": break
                j += 1
            atual.append(texto[i:j + 1]); i = j + 1; continue
        if texto[i] == ';':
            cmd = ''.join(atual).strip()
            if cmd: saida.append(cmd)
            atual = []; i += 1; continue
        atual.append(texto[i]); i += 1
    resto = ''.join(atual).strip()
    if resto: saida.append(resto)
    return saida


def verificar(arq, permitir_editar, base='HEAD'):
    erros = []
    texto = arq.read_text(encoding='utf-8')
    if not NOME.match(arq.name):
        erros.append('nome fora do padrão <14 dígitos>_<assunto>.sql')
    if '\r' in texto:
        erros.append('fim de linha CRLF (use LF — .gitattributes)')
    pos = [m.start() for m in re.finditer(r'^-- Permiss[õo]es', texto, re.M)]
    if not pos:
        erros.append('falta o bloco "-- Permissões" no fim')
    else:
        for c in comandos(texto[pos[-1]:]):
            if not PERMITIDO_NO_FIM.match(c):
                erros.append(f'comando depois do bloco de permissões: {c[:60]!r}')
    for m in re.finditer(r'create\s+(or\s+replace\s+)?function\s+([\w.]+)\s*\(.*?\$\$.*?\$\$[^;]*;', texto, re.S | re.I):
        cab = m.group(0).split('$$')[0].lower()
        if 'security definer' in cab and 'search_path' not in cab:
            erros.append(f'função security definer sem search_path: {m.group(2)}')
    if re.search(r'create\s+extension[^;]*\bversion\b', texto, re.I):
        erros.append('create extension com versão (ignorada pelo Supabase)')
    rel = arq.relative_to(RAIZ).as_posix()
    r = subprocess.run(['git', '-C', str(RAIZ), 'show', f'{base}:{rel}'], capture_output=True)
    if r.returncode == 0 and r.stdout.replace(b'\r\n', b'\n') != arq.read_bytes().replace(b'\r\n', b'\n') \
            and arq.name not in permitir_editar:
        erros.append(f'migration já publicada em {base} foi alterada (crie uma nova)')
    return erros


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--base', default='HEAD')
    ap.add_argument('--permitir-editar', nargs='*', default=[])
    a = ap.parse_args()
    arqs = sorted(PASTA.glob('*.sql'))
    if not arqs:
        print('nenhuma migration'); return 1
    falhou = False
    for arq in arqs:
        erros = verificar(arq, set(a.permitir_editar), a.base)
        print(('OK    ' if not erros else 'ERRO  ') + arq.name)
        for e in erros:
            print('      -', e)
        falhou |= bool(erros)
    print(f'{len(arqs)} migrations, {"com erros" if falhou else "todas conformes"}')
    return 1 if falhou else 0


if __name__ == '__main__':
    sys.exit(main())
