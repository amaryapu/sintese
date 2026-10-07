# `love-is-all-you-need` — o protocolo executável

> **Onde a teoria vira código que roda.** O esquema, o benchmark, o verificador, e os dois
> resultados negativos.
>
> Fonte: **`amaryapu/love-is-all-you-need`** · `benchmark/`, `ferramentas/`, `esquema/`

---

## O que existe de executável

| | |
|---|---|
| `esquema/registro.schema.json` | os campos obrigatórios, formalizados |
| `ferramentas/conferir_registro.py` | o verificador |
| `ferramentas/benchmark.py` | a suíte |
| `benchmark/` **26 casos** | `M1–M7` (os modos), `P01–P03` (conformes), `T1–T6` (fronteiras), `A01–A10` (**adversariais**) |

E um comando, sem dependências: **`REPRODUZIR.sh`.**

> Qualquer pessoa reexecuta a suíte inteira. **Não é um argumento sobre um protocolo. É o
> protocolo.**

## Os sete modos

| | | classe |
|---|---|---|
| `M1` | campo ausente | ## **I** · destrutiva · **funde** |
| ## `M2` | ## **confissão sem interrupção** | ## **II** · **inerte** — a informação é preservada e **não é agida** |
| `M3` | reclassificação | **I** · funde |
| `M4` | desqualificação pela origem | **I** · apaga |
| `M5` | interrupção da transmissão | **I** · apaga |
| ## `M5′` | ## **transmissão `desviada`** | ## **I** · entrega ao destinatário errado — **e não quebra nada** |
| `M6` | a categoria que absolve | **I** · funde |
| `M7` | delegação do custo | **I** · funde |

**`M2` é a única classe `II`**, e a mais difícil: **não é falha de informação, é falha de
ação.** Nenhuma auditoria de existência de registro a detecta.

## Os dois resultados negativos

**`RG-19`** · Acrescentei três campos novos ao protocolo, derivados dos próprios ataques. Os
três passaram a disparar. A suíte foi a **16/16**.

> **E os dez ataques passaram de novo** — porque **todo campo novo continua sendo
> autodeclarado.**

**`N4`** · Formalizado a partir disso:

> Dado `D1` registro, `D2` verificador sintático, `D3` campo autodeclarado, `D4` **registro
> inteiramente autodeclarado**, `D5` adversário —
> **nenhum verificador sintático exclui o comportamento visado.**

E o corolário que aponta a saída: **`RG-20`** — ao menos um valor obtenível **sem** o
registro.

## E a lição de método que custou mais caro

**`R43`** · Uma checagem minha comparava o campo errado, e por isso **nunca disparava** — e o
caso conforme passava, **o que me fez acreditar que funcionava.**

> **`[REGRA]`** **Toda checagem nova entra com um teste de sanidade que a faz disparar.**
> **Um verificador que só foi testado em registros válidos não foi testado.**
