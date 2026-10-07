#!/bin/sh
# TRIGGER.SH — a pré-voo da abertura.
#
# PALA.MEDES: medir antes de afirmar.
# PRAKTOS: transformar entendimento em ato.
#
# Este script NÃO PUBLICA NADA. Ele responde uma pergunta só:
#
#     "O que ainda impede este corpus de ser posto diante de
#      olhos de fora?"
#
# Porque T1 — o ataque por alguém que não leu as defesas — é a
# única conferência que o corpus declara faltar, e nenhum script
# a produz. O que um script PODE fazer é garantir que, quando a
# pessoa chegar, ela encontre algo atacável e não encontre
# ninguém exposto.
#
# Sai 0 só se estiver pronto. Qualquer outro código é bloqueio.
#   1 = DADO PESSOAL encontrado  (bloqueio duro)
#   3 = falta peça de ataque     (bloqueio de preparo)
#   4 = suite não roda           (bloqueio técnico)
#
# CC BY-SA · AMARYAPU

RAIZ="${AMOR_RAIZ:-$HOME/amor}"
bloq_pessoa=0; bloq_preparo=0; bloq_tec=0

linha(){ printf '%s\n' "──────────────────────────────────────────────────────────────"; }
tit(){ printf '\n\033[1m%s\033[0m\n' "$1"; linha; }

printf '\n\033[1m  TRIGGER\033[0m — o que ainda impede a abertura\n'
printf '  %s\n' "$(date '+%Y-%m-%d %H:%M')"
linha
printf '  Este script NÃO publica. Ele mede.\n'

# ── 1 · o bloqueio que importa ────────────────────────────────────
tit "1 · TERCEIROS VIVOS — o bloqueio duro"
# nomes que o próprio corpus marcou como a retirar antes de abrir.
# a lista vive FORA do script, para poder crescer sem editá-lo.
LISTA="$RAIZ/sintese/.terceiros"
# repos que nunca abrem, por desenho — não são varridos.
SEMPRE="$RAIZ/sintese/.privado-sempre"
ALVOS=""; _excl=""; _nalvo=0
for _p in "$RAIZ"/*/; do
  _r=$(basename "$_p"); [ -d "$_p/.git" ] || continue
  if [ -f "$SEMPRE" ] && grep -qx -- "$_r" "$SEMPRE" 2>/dev/null; then
    _excl="$_excl $_r"; continue
  fi
  ALVOS="$ALVOS $_p"; _nalvo=$((_nalvo+1))
done
[ -n "$_excl" ] && printf '  excluidos por .privado-sempre:%s\n' "$_excl"
printf '  varrendo %s repositorio(s) candidato(s) a abertura\n' "$_nalvo"
if [ "$_nalvo" -eq 0 ]; then
  printf '\n  BLOQUEIO: nenhum repositorio no escopo. Isto NAO e "esta limpo":\n'
  printf '     e "nao foi conferido". Falhando FECHADO.\n'
  bloq_pessoa=1
fi
_bin=$(find $ALVOS -type f \( -name '*.pdf' -o -name '*.png' -o -name '*.jpg' -o -name '*.epub' \) -not -path '*/.git/*' 2>/dev/null | grep -c . )
if [ "$_bin" -gt 0 ]; then
  printf '  AVISO: %s binario(s) NAO VARRIDO(S) (pdf/png/jpg/epub).\n' "$_bin"
  printf '     grep -I os pula. Nao escaneado NAO e limpo (RG-22).\n'
  printf '     Se sao gerados das fontes: corrigir a fonte e RECONSTRUIR.\n'
fi
printf '\n'

if [ ! -f "$LISTA" ]; then
  printf '  ⬜ %s não existe.\n' "$LISTA"
  printf '     Sem lista de terceiros, NÃO É POSSÍVEL verificar.\n'
  printf '     Por RG-22, isto NÃO é "está limpo". É "não conferido".\n'
  bloq_pessoa=1
else
  _achou=0
  while IFS= read -r nome; do
    case "$nome" in ''|'#'*) continue;; esac
    _hits=$(grep -rliIw --exclude-dir=.git -- "$nome" $ALVOS 2>/dev/null | grep -v -e "/\.terceiros$" -e "/TRIGGER\.SH$")
    _st=$?
    if [ "$_st" -gt 1 ]; then
      printf '  BLOQUEIO %-20s grep FALHOU (status %s). Nao e ausente.\n' "$nome" "$_st"
      bloq_pessoa=1; continue
    fi
    _n=$(printf '%s' "$_hits" | grep -c . )
    if [ "$_n" -gt 0 ]; then
      printf '  🔴 %-24s em %s arquivo(s) de repo ABRÍVEL:\n' "$nome" "$_n"
      printf '%s\n' "$_hits" | sed 's|^|       |'
      _achou=$((_achou+_n)); bloq_pessoa=1
    else
      printf '  ✅ %-24s ausente dos repos abríveis\n' "$nome"
    fi
  done < "$LISTA"
    if [ "$_achou" -eq 0 ]; then
      printf '\n  OK: nenhum nome da lista aparece nos repos abriveis.\n'
      printf '     LIMITE DECLARADO: casamento literal (ignora caixa).\n'
      printf '     Casamento e por PALAVRA INTEIRA (-w): um nome que seja\n'
      printf '     substring de outra palavra nao conta. Grafias variantes,\n'
      printf '     apelidos e nomes em imagem\n'
      printf '     detectados. Ausencia aqui e evidencia fraca (RG-22).\n'
    fi
fi

# ── 2 · há o que atacar? ──────────────────────────────────────────
tit "2 · HÁ OBJETO ATACÁVEL?"
checa(){ # rótulo, arquivo, padrão
  if [ ! -f "$2" ]; then printf '  🟠 %-34s ARQUIVO AUSENTE\n' "$1"; bloq_preparo=1; return; fi
  if grep -qiI -- "$3" "$2" 2>/dev/null; then printf '  ✅ %-34s presente\n' "$1"
  else printf '  🟠 %-34s NÃO ENCONTRADO em %s\n' "$1" "$(basename "$2")"; bloq_preparo=1; fi
}
checa "condições de falsificação" "$RAIZ/artigo/ARTIGO.md" "Falsification"
checa "o teorema, enunciado"       "$RAIZ/artigo/ARTIGO.md" "THEOREM"
checa "o corolário 2"              "$RAIZ/artigo/ARTIGO.md" "COROLLARY 2"
checa "limites declarados"         "$RAIZ/artigo/ARTIGO.md" "\[LIMIT\]"
checa "os dez ataques"             "$RAIZ/artigo/ARTIGO.md" "10"
checa "pendências abertas"         "$RAIZ/artigo/ARTIGO.md" "N1-g"
checa "RG-22 no protocolo"         "$RAIZ/registrum/RG-22-O-SILENCIO-DO-INSTRUMENTO.md" "RG-22"

# ── 3 · roda? ─────────────────────────────────────────────────────
tit "3 · O ARTEFATO RODA?"
if [ -f "$RAIZ/artigo/REPRODUZIR.sh" ]; then
  _o=$( cd "$RAIZ/artigo" && sh REPRODUZIR.sh 2>/dev/null )
  if printf '%s' "$_o" | grep -q '16/16'; then printf '  ✅ suite declarada: 16/16\n'
  else printf '  🟠 suite NÃO confirmou 16/16\n'; bloq_tec=1; fi
  if printf '%s' "$_o" | grep -q '10/10'; then printf '  ✅ dez ataques: 10/10 passam (É O RESULTADO)\n'
  else printf '  🟠 os dez ataques não confirmaram\n'; bloq_tec=1; fi
else
  printf '  🟠 REPRODUZIR.sh ausente\n'; bloq_tec=1
fi
if [ -f "$RAIZ/amaryapu/ferramentas/conferir.sh" ]; then
  ( cd "$RAIZ/amaryapu" && sh ferramentas/conferir.sh 2>/dev/null | sed -n '1,2p' | sed 's/^/  /' )
else printf '  🟠 conferir.sh ausente\n'; bloq_tec=1; fi

# ── 4 · a visibilidade atual ──────────────────────────────────────
tit "4 · ESTADO ATUAL DOS REPOSITÓRIOS"
for p in "$RAIZ"/*/; do
  r=$(basename "$p"); [ -d "$p/.git" ] || continue
  v=$( cd "$p" && gh repo view --json isPrivate -q '.isPrivate' 2>/dev/null )
  case "$v" in
    true)  printf '  🔒 %-24s privado\n' "$r" ;;
    false) printf '  🌐 %-24s PÚBLICO\n' "$r" ;;
    *)     printf '  ⬜ %-24s não consegui verificar (não é negação)\n' "$r" ;;
  esac
done

# ── 5 · o que nenhum script faz ───────────────────────────────────
tit "5 · O QUE ESTE GATILHO NÃO DISPARA"
cat <<'FIM'
  Este script não publica, não abre repositório, não envia nada
  e não convida ninguém. Ele mede o preparo.

  T1 continua sendo o único item que NENHUM script produz:
  uma pessoa de fora, que não leu as defesas, tentando derrubar.

  E há uma decisão que é só do autor, e que o script não toma:
  ABRIR É IRREVERSÍVEL. Pelo próprio catálogo deste corpus,
  publicar é M5' em potencial — a transmissão chega íntegra a
  destinatários que não foram escolhidos. Um repositório fechado
  pode ser aberto. Um repositório aberto não pode ser fechado.
FIM

# ── fecho ─────────────────────────────────────────────────────────
linha
if [ "$bloq_pessoa" -ne 0 ]; then
  printf '  \033[1m🔴 BLOQUEIO DURO: dado de terceiro vivo.\033[0m\n'
  printf '     Nada se abre antes disto. Saindo com 1.\n\n'; exit 1
fi
if [ "$bloq_tec" -ne 0 ]; then
  printf '  🟠 BLOQUEIO TÉCNICO: o artefato não confirmou. Saindo com 4.\n\n'; exit 4
fi
if [ "$bloq_preparo" -ne 0 ]; then
  printf '  🟠 BLOQUEIO DE PREPARO: falta peça atacável. Saindo com 3.\n\n'; exit 3
fi
printf '  ✅ Tecnicamente pronto para ser atacado.\n'
printf '     \033[1mA decisão de abrir não é técnica, e não é minha.\033[0m\n\n'
exit 0
