#!/bin/sh
# CONFLUA.sh — confere a PROCEDÊNCIA para fora.
#
# O AMOR.SH confere o que é interno: integridade do livro, suite do
# protocolo, estado dos repositórios. Este confere o que depende de
# terceiros: cada DOI citado resolve? cada fonte ainda responde?
#
# E obedece RG-22 (registrum, 07/10/2026):
#   "Um 0 sem prova de execução não é dado."
# Toda consulta aqui registra SE o instrumento respondeu antes de
# registrar O QUE respondeu. Três estados, nunca dois:
#   ✅ EXECUTOU e confirmou
#   ⚠️  EXECUTOU e negou
#   ⬜ NÃO EXECUTOU  — não conta como negação
#
# sem dependências além de sh, curl e awk.   CC BY-SA · AMARYAPU

RAIZ="${AMOR_RAIZ:-$HOME/amor}"
UA="conflua/1.0 (+github.com/amaryapu)"
T=12
ok=0; neg=0; nao=0

linha() { printf '%s\n' "──────────────────────────────────────────────────────────────"; }
titulo() { printf '\n\033[1m%s\033[0m\n' "$1"; linha; }

# consulta(rótulo, url) — imprime estado e contabiliza, SEM confundir
# ausência de resposta com resposta negativa.
consulta() {
  _rot="$1"; _url="$2"
  _code=$(curl -s -o /dev/null -w '%{http_code}' -m "$T" -L -A "$UA" "$_url" 2>/dev/null)
  case "$_code" in
    000|"")  printf '  ⬜ %-44s NÃO EXECUTOU (sem resposta)\n' "$_rot"; nao=$((nao+1)) ;;
    2*|3*)   printf '  ✅ %-44s HTTP %s\n' "$_rot" "$_code"; ok=$((ok+1)) ;;
    404|410) printf '  ⚠️  %-44s HTTP %s — NÃO RESOLVE\n' "$_rot" "$_code"; neg=$((neg+1)) ;;
    429)     printf '  ⬜ %-44s HTTP 429 — COTA. não conta.\n' "$_rot"; nao=$((nao+1)) ;;
    *)       printf '  ⬜ %-44s HTTP %s — indeterminado\n' "$_rot" "$_code"; nao=$((nao+1)) ;;
  esac
}

printf '\n\033[1m  CONFLUA\033[0m — a procedência conferida para fora\n'
printf '  %s\n' "$(date '+%Y-%m-%d %H:%M')"
linha
printf '  RG-22: um 0 sem prova de execução não é dado.\n'
printf '  ⬜ NÃO EXECUTOU nunca é lido como negação.\n'

# ── 1 · rede ──────────────────────────────────────────────────────
titulo "1 · O INSTRUMENTO RESPONDE?"
_net=$(curl -s -o /dev/null -w '%{http_code}' -m 8 -A "$UA" https://doi.org 2>/dev/null)
case "$_net" in
  2*|3*) printf '  ✅ há rede. as conferências abaixo valem.\n' ;;
  *) printf '  ⬜ SEM REDE (doi.org → %s).\n' "${_net:-000}"
     printf '     Por RG-22, NADA abaixo seria conferência. Saindo.\n\n'
     exit 2 ;;
esac

# ── 2 · cada DOI citado ───────────────────────────────────────────
titulo "2 · PROCEDÊNCIA — cada DOI de referencias.bib resolve?"
BIB="$RAIZ/artigo/referencias.bib"
if [ ! -f "$BIB" ]; then
  printf '  ⬜ %s não encontrado. NÃO EXECUTOU.\n' "$BIB"; nao=$((nao+1))
else
  _n=0
  awk -F'[={} ]+' '/^[[:space:]]*doi[[:space:]]*=/{for(i=1;i<=NF;i++) if($i ~ /^10\./){print $i; break}}' "$BIB" \
  | sed 's/[,[:space:]]*$//' | sort -u | while read -r d; do
      [ -n "$d" ] || continue
      consulta "$d" "https://doi.org/$d"
    done
  _n=$(awk -F'[={} ]+' '/^[[:space:]]*doi[[:space:]]*=/{for(i=1;i<=NF;i++) if($i ~ /^10\./){print $i; break}}' "$BIB" | sort -u | wc -l | tr -d ' ')
  printf '\n  %s DOIs declarados em referencias.bib\n' "$_n"
fi

# ── 3 · as fontes abertas que o corpus usa ────────────────────────
titulo "3 · AS FONTES — ainda respondem?"
consulta "planalto.gov.br (Constituição 1934)" "https://www.planalto.gov.br/ccivil_03/constituicao/constituicao34.htm"
consulta "planalto.gov.br (Lei 9.096/1995)"    "https://www.planalto.gov.br/ccivil_03/leis/l9096.htm"
consulta "en.wiktionary.org"                   "https://en.wiktionary.org/wiki/%CE%BA%CE%B1%CE%B9%CF%81%CF%8C%CF%82"
consulta "sefaria.org (texto massorético)"     "https://www.sefaria.org/api/texts/Proverbs.22.6?context=0"
consulta "api.crossref.org"                    "https://api.crossref.org/works/10.1145/3593434.3593453"
consulta "activism.net (manifesto cypherpunk)" "https://www.activism.net/cypherpunk/manifesto.html"
consulta "publicacoesacademicas.uniceub.br"    "https://publicacoesacademicas.uniceub.br/index/pt_BR"

# ── 4 · o interno, de relance ─────────────────────────────────────
titulo "4 · O INTERNO (detalhe: ./AMOR.SH)"
if [ -f "$RAIZ/amaryapu/ferramentas/conferir.sh" ]; then
  ( cd "$RAIZ/amaryapu" && sh ferramentas/conferir.sh 2>/dev/null | sed -n '1,3p' | sed 's/^/  /' )
else
  printf '  ⬜ conferir.sh não encontrado. NÃO EXECUTOU.\n'
fi
if [ -f "$RAIZ/artigo/REPRODUZIR.sh" ]; then
  ( cd "$RAIZ/artigo" && sh REPRODUZIR.sh 2>/dev/null | grep -E '16/16|10/10' | sed 's/^/  /' )
else
  printf '  ⬜ REPRODUZIR.sh não encontrado. NÃO EXECUTOU.\n'
fi

# ── 5 · o que segue aberto ────────────────────────────────────────
titulo "5 · O QUE ESTE COMANDO NÃO RESOLVE"
cat <<'ABERTO'
  T1     o ataque por uma PESSOA DE FORA, que não leu as defesas.
         Nunca aconteceu. Nenhum script produz isso.

  N1-g   alguém já formalizou impossibilidade sobre registro
         autodeclarado? E por RG-22 ela NÃO pode ser respondida
         por ausência: só busca POSITIVA, em base cuja cobertura
         do campo seja conhecida e declarada.

  N1-h   o IEEE Std 7000-2021, 82 páginas, não foi lido.

  T3     C8 medido em domínio real. Zero dados.

  E o limite de fundo: um DOI que resolve prova que o endereço
  existe. NÃO prova que o artigo diz o que a citação afirma.
  Isso é cost(examine), e é humano.
ABERTO

# ── fecho ─────────────────────────────────────────────────────────
linha
printf '  confirmadas .......... %s\n' "$ok"
printf '  negadas .............. %s\n' "$neg"
printf '  \033[1mnão executadas ....... %s\033[0m   ← não são negações\n' "$nao"
linha
if [ "$neg" -gt 0 ]; then
  printf '  ⚠️  %s procedência(s) NÃO RESOLVEM. Olhe acima.\n\n' "$neg"; exit 1
fi
if [ "$nao" -gt 0 ]; then
  printf '  ⬜ %s consulta(s) não executaram. O resultado é PARCIAL,\n' "$nao"
  printf '     e um resultado parcial não é um resultado negativo.\n\n'; exit 3
fi
printf '  ✅ Toda procedência declarada resolve.\n'
printf '     O que ela DIZ continua precisando de alguém.\n\n'
exit 0
