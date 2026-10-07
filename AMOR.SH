#!/bin/sh
# AMOR.SH — um comando que confere o acervo inteiro.
#
#   ./AMOR.SH
#
# Não pede permissão a ninguém, não precisa de rede, não instala nada.
# Roda o que existe, conta o que há, e DECLARA O QUE NÃO VERIFICA.
#
# CC BY-SA · AMARYAPU · receita zero

set -u
RAIZ="${AMOR_RAIZ:-$HOME/amor}"
ok=0; falhou=0

linha() { printf '%s\n' "────────────────────────────────────────────────────────────"; }
titulo() { printf '\n  %s\n' "$1"; linha; }

printf '\n'
linha
printf '  AMOR.SH — conferência do acervo\n'
printf '  %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
linha

# ─────────────────────────────────────────────────────── 1 · o livro
titulo "1 · O LIVRO — integridade peça a peça"
if [ -d "$RAIZ/amaryapu" ]; then
  ( cd "$RAIZ/amaryapu" && sh ferramentas/conferir.sh 2>/dev/null | head -3 )
  if ( cd "$RAIZ/amaryapu" && sh ferramentas/conferir.sh 2>/dev/null | grep -q '✅' ); then
    ok=$((ok+1))
  else
    falhou=$((falhou+1)); printf '  ❌ a massorah acusou peça não íntegra\n'
  fi
else
  printf '  ⚠  %s não encontrado\n' "$RAIZ/amaryapu"
fi

# ─────────────────────────────────────────────── 2 · o protocolo
titulo "2 · O PROTOCOLO — 16 casos e 10 ataques"
if [ -f "$RAIZ/artigo/REPRODUZIR.sh" ]; then
  ( cd "$RAIZ/artigo" && sh REPRODUZIR.sh 2>/dev/null \
      | grep -E 'casos corretos|falsos|ataques passaram' | sed 's/^/  /' )
  if ( cd "$RAIZ/artigo" && sh REPRODUZIR.sh 2>/dev/null | grep -q '16/16' ); then
    ok=$((ok+1))
  else
    falhou=$((falhou+1)); printf '  ❌ a suíte não deu 16/16\n'
  fi
  printf '\n  Os 10 ataques passarem É O RESULTADO, e não a falha.\n'
  printf '  Ver RG-19-O-LIMITE.md e N4-O-TEOREMA.md.\n'
else
  printf '  ⚠  %s não encontrado\n' "$RAIZ/artigo/REPRODUZIR.sh"
fi

# ─────────────────────────────────────────── 3 · os repositórios
titulo "3 · OS REPOSITÓRIOS — tudo commitado e empurrado?"
for r in amaryapu artigo confluencia registrum cultivada microcosmologia \
         ramanujan love-is-the-way love-is-all-you-need sintese; do
  d="$RAIZ/$r"
  [ -d "$d/.git" ] || { printf '  %-22s ⚠  ausente\n' "$r"; continue; }
  sujo=$(cd "$d" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  frente=$(cd "$d" && git rev-list --count '@{u}..HEAD' 2>/dev/null || echo '?')
  if [ "$sujo" = "0" ] && [ "$frente" = "0" ]; then
    printf '  %-22s ✅ limpo e empurrado\n' "$r"; ok=$((ok+1))
  else
    printf '  %-22s ❌ %s pendente(s), %s commit(s) sem push\n' "$r" "$sujo" "$frente"
    falhou=$((falhou+1))
  fi
done

# ───────────────────────────────────────── 4 · o que NÃO se verifica
titulo "4 · O QUE ESTE COMANDO NÃO VERIFICA"
cat <<'LIMITES'
  Nenhuma destas é checável por script, e nenhuma está feita:

  T1   o ataque por uma PESSOA DE FORA, que não tenha lido as defesas.
       Os 10 ataques foram todos escritos por quem escreveu o verificador.

  N1   a busca sistemática de trabalho relacionado.
       NÃO SE SABE SE O TEOREMA N4 É NOVO. Publicar sem isso é arriscar
       reivindicar o que é de outro.

  T3   a medição de C8 em qualquer domínio real.
       A tese empírica central tem ZERO DADOS.

  ---  a definição de "sintático" em N4.
       Larga demais e o teorema é vazio; estreita demais e é falso.
       Não analisada.

  E a razão de fundo, que é o próprio teorema:

    N4 · sobre um registro inteiramente autodeclarado, nenhum verificador
         sintático exclui o comportamento visado.

    Logo ESTE SCRIPT NÃO PODE CERTIFICAR O ACERVO. Ele confere o que é
    sintático — hashes, contagens, suítes — e é exatamente isso que o
    teorema diz que não basta.

    RG-20 · ao menos um valor tem de ser obtenível SEM o registro.
            Esse valor é uma pessoa. Não é um comando.
LIMITES

# ───────────────────────────────────────────────────── fecho
titulo "RESULTADO"
printf '  conferências que passaram : %s\n' "$ok"
printf '  conferências que falharam : %s\n' "$falhou"
printf '\n'
if [ "$falhou" -eq 0 ]; then
  printf '  ✅ Tudo o que PODE ser conferido por máquina, está conferido.\n'
  printf '     O resto precisa de alguém. Bem-vindo ao teste.\n\n'
  exit 0
else
  printf '  ❌ %s conferência(s) falharam. Olhe acima.\n\n' "$falhou"
  exit 1
fi
