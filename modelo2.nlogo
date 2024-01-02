;==========================================
;Title: Instabilidade Financeira Netlogo 6.4.0
;Author: Iago Rosa & Teófilo de Paula
;Date: Nov 2023
;
;Updated from: Instabilidade Financeira Netlogo 3.1.5
;(https://gmdesenvolvimento.wixsite.com/grupo/publicacoes)
;
;Reference: DE PAULA, T. H. P.; Crocco. Financiamento e diversidade
;produtiva: um modelo baseado em agentes com flutuações cíclicas emergentes.
;Revista de Economia Contemporânea (Impresso), v. 17, p. 5-38, 2013
;
;How to cite:
;Rosa, I. & De Paula, T. Instabilidade Financeira Netlogo 6.4.0. Grupo de
;Pesquisa Moeda e Desenvolvimento
;(https://gmdesenvolvimento.wixsite.com/grupo). Instituto Três Rios –
;ITR/UFRRJ. Três Rios – RJ, 2023.
;==========================================

; Nesta versão a variável tempo é referenciada por ticks
; Isso porque ticks tornou-se nativo e padrão recomendável

breed [techs tech]
breed [firms firm]

techs-own [A                     ; tecnologia de produto (diferenciação)
           T                     ; tecnologia de processo
           F ]                   ; custo fixo e escala mínima


firms-own [ Class1                ; tipo de expectativa
            Class2                ; Ponzi, Hedge e Especulativo
            Mk                    ; markup
            A                     ; tecnologia de produto (diferenciação)
            T                     ; tecnologia de processo
            F                     ; custo fixo e escala mínima
            K                     ; capital monetário
            L                     ; insumos (trabalhadores, horas de trabalho)
            Qs                    ; quantidade ofertada
            Qd                    ; quantidade demandada
            Qe                    ; quantidade esperada
            P                     ; preço
            C                     ; competitividade da firma
            M                     ; market-share
            V                     ; estoques
            R                     ; receita de vendas
            Kmin                  ; capital mínimo
            list-MemoD1           ; memória para projeção da demanda
            list-MemoD2           ; memória para projeção da demanda
            AProfit               ; lucros acumulados
            ADebit                ; dívidas acumuladas
            Loan                  ; empréstimos
            Sd                    ; saldo devedor não honrado ou perda de capital do banco
            Wb                    ; despesas de produção dada a expectativa de demanda
            Rtot                  ; recursos totais da firma = receitas de vendas + lucros acumulados (AProfit)
            AM                    ; amortização
            J                     ; juros
            t1 t2 t3 ]

globals [ W                      ; salário ou preços dos insumos
          Y                      ; renda disponível
          Yg                     ; rendimentos dos títulos
          S                      ; renda não gasta (poupança)
          Wealth                 ; riqueza total da economia (R$)
          Pmed                   ; preço médio de mercado  (variável Walrasiana do Banco!)
          Cmed                   ; competitividade média
          Vtotal                 ; total de estoques
          Wtotal                 ; massa salarial (custo dos insumos)
          Kbank                  ; capital do banco
          Ktit                   ; capital do banco em títulos públicos
          Cred                   ; ativo crédito (volume de crédito concedido)
          Kfail                  ; empréstimos não honrados (somatório de SD)
          h                      ; indicador de desempenho do ativo crédito em relação ao ativo títulos públicos
          g                      ; desvio-padrão de h
          Pbank                  ; preço limite estabelecido pelo banco (critério para concessão de financiamento)
          spread                 ; spread
          z                      ; taxa de juros de mercado = f (spread + i)
          Frag1                  ; taxa de inadimplência (indicador de fragilidade financeira)
          Frag2                  ; versão suavizada de Frag1
          sigma                  ; taxa desejada de aplicação em títulos (a taxa efetiva pode ser >= tx desejada)
          list-MemoH             ; memória do banco
          n1 n2 n3               ; variáveis auxiliares da plotagem
          expec1 expec2          ; variáveis auxiliares da plotagem
          expec3 expec4          ; variáveis auxiliares da plotagem
          expec5 expec6          ; variáveis auxiliares da plotagem
          expec7 expec8          ; variáveis auxiliares da plotagem
          g1 g2 g3 g4 g5 g7 g8 g10 g11 g12 g13 g14 g16 g17 g18 g19 ]



to start
  clear-output
  clear-all
  random-seed 1.0
  reset-ticks

  set Kbank 1000.0
  set sigma 0.1
  set W 1.0
  set z 0.1

  if memo = 3 [set list-MemoH n-values 40 [1.0]]
  if memo = 2 [set list-MemoH n-values 20 [1.0]]
  if memo = 1 [set list-MemoH n-values 10 [1.0]]
  if memo = 0 [set list-MemoH n-values  5 [1.0]]

  create-techs 300 [technology]
  repeat 100 [
    ask one-of techs [
      set breed firms
      set color green
      rt random 360
      jump random 360

      set M (1.0 / 100.0)
      set Mk 1.2
      ifelse ExpectativaHomogenea = true [set t3 3                        set Class1 4       ]
                                          [set t3 (1.1 + random-float 8.9) set Class1 random 8]
      set Kmin (t3 * F * W)
      set list-MemoD1 n-values 10 [Kmin]
    ]
  ]

  Global-Competitiveness
  Plot-information
end

to technology
  loop [
    set A random-normal Acoef (Acoef * Asymmetry)
    set T random-normal Tcoef (Tcoef * Asymmetry)
    set F random-normal Fcoef (Fcoef * Asymmetry)
    if ProdutoHomogeneo = true [
      set A 0.0
      if T > 0.0 and T <= 10.0 and F > 0.0 and F <= 10.0 [stop]
    ]
    if A > 0.0 and A <= 10.0 and T > 0.0 and T <= 10.0 and F > 0.0 and F <= 10.0 [stop]
  ]
end
to run-world
  loop [
    Entry                               ; Entrada de novas firmas

    set Vtotal (sum [V] of firms)       ; Estoques totais
    ask firms [Expectation]             ; Expectativas
    ask firms [CreditMarket]            ; Demanda por crédito

    Limit-Kbank                         ; Banco define o volume de capital a ser emprestado, dada a demanda total por crédito

    ask firms [Production]              ; Firma define a produção

    Dispersao                           ; Dispersão de preços e tamanhos

    ask firms [Price-Competitiveness]   ; Preço e Competitividade
    ask firms [Global-Competitiveness]  ; Competitividade média

    MarketShare                         ; Market-share da firma
    Price-Level                         ; Preço médio de mercado
    Income-Government                   ; Renda, governo e tributação

    ask firms [Sales-Profit]            ; Vendas e lucros
    ask firms [Markup]                  ; Markup
    ask firms [FinancingRegime]         ; Tipologia Hedge, Speculative, Ponzi

    BankBehaviour                       ; Ajuste no spread

    tick                                ; Períodos
    plot-information                    ; Imprime informações
    if break = true [set break false stop]
    if ticks >= history [stop]
  ]
end

to entry
  if Entry? = false [stop]
  if ticks = 0 [stop]
  if one-of techs = nobody [stop]

  ask one-of techs [
    set breed firms
    set color green

    set M (1.0 / count firms)
    set Mk 1.2

    ifelse ExpectativaHomogenea = true [
      set t3 3
      set Class1 4
    ]
    [
      set t3 (1.1 + random-float 8.9)
      set Class1 random 8
    ]

    set Kmin (t3 * F * W)
    set list-MemoD1 n-values 10 [Kmin]
    set L (Kmin / W)
    set Qs (T * (L - F))
    set P (Mk * Kmin * (1.0 + z)) / Qs

    if P > Pbank [set breed techs stop]
    setxy random 100 random 100
  ]
end

to Expectation
  set list-MemoD2 (list item 0
                   list-MemoD1 item 1
                   list-MemoD1 item 2
                   list-MemoD1 item 3
                   list-MemoD1 item 4
                   list-MemoD1)

  if class1 = 0 [set Qe mean   list-MemoD1]
  if class1 = 1 [set Qe max    list-MemoD1]
  if class1 = 2 [set Qe min    list-MemoD1]
  if class1 = 3 [set Qe median list-MemoD1]
  if class1 = 4 [set Qe item 0 list-MemoD1]
  if class1 = 5 [set Qe mean   list-MemoD2]
  if class1 = 6 [set Qe max    list-MemoD2]
  if class1 = 7 [set Qe min    list-MemoD2]
end

to CreditMarket
  set Qe (Qe - V)                               ; descontando das expectativas de venda os estoques
  if Qe < 0.0 [set Qe 0.0]                      ; restrição

  set L (Qe / T) + F                            ; demanda por trabalhadores / insumos
  set Wb (L * W)                                ; capital necessário, dado o nível de produção desejado

  ifelse AProfit < Wb [set Loan (Wb - AProfit)] ; demanda por crédito > 0
                      [set Loan 0.0]            ; demanda por crédito = 0
end

to Limit-Kbank
  set g11 sum [Loan] of firms                    ; demanda de crédito total
  set g14 Kbank                                  ; capital do banco

  set Ktit (sigma * Kbank)                       ; montante mínimo em títulos
  set Kbank (Kbank - Ktit)                       ; define capital disponível para empréstimos

  ifelse g11 > Kbank [set g13 (Kbank / g11)]     ; se demanda de crédito superar capital disponível, cria redutor
                     [set g13 1.0]               ; redutor 1.0
  set g12 (g11 * g13)                            ; ajusta demanda por crédito por meio do redutor

  if Kbank > g12 [set Ktit Ktit + (Kbank - g12)] ; pode ocorrer no caso de redutor = 1.0, assim Ktit é acrescido da diferença (Kbank - g12)
  set Kbank (g14 - Ktit)                         ; deduz do Kbank original o Ktit final; tem-se assim o volume de crédito concedido
  set Cred Kbank                                 ; volume de recursos emprestados.
end

to production
  set Loan (Loan * g13)                                                ; firma ajusta demanda por crédito ofertado pelo banco

  ifelse AProfit < Wb [set K (Loan + AProfit)                          ; com empréstimo
                       set AProfit 0.0]                                ; com empréstimo
                      [set K Wb                                        ; sem empréstimo
                       set AProfit (AProfit - Wb)]                     ; sem empréstimo

  set Sd (Sd + Loan)                                                   ; saldo devedor
  set ADebit (ADebit + Loan)                                           ; dívidas acumuladas
  set Kbank (Kbank - Loan)                                             ; banco transfere capital
  set Wtotal (Wtotal + K)                                              ; soma deve ser igual a Wealth
  set L (K / W)                                                        ; firma adquire insumos

  if L < F or (L = F and V = 0.0) [set Kfail (Kfail + Sd)              ; escala mínima e massa falida acrescida do saldo devedor
                                   set breed techs                     ; volta para o "armário de tecnologias"
                                   set color black
                                   stop]
  set Qs (T * (L - F) + V)                                             ; produção
end

to Dispersao
  if ticks = 0 [stop]                                                  ; não calcula a média no período 0
  set g16 standard-deviation [K] of firms                              ; desvio-padrão dos portes das firmas
  set g18 standard-deviation [P] of firms                              ; desvio-padrão dos preços das firmas
end

to Price-Competitiveness
  ifelse ADebit <= 0.0 and AProfit <= 0.0 [set P P]                         ; preço
                         [set P Mk * ((ADebit * (1.0 + z)) + AProfit) / Qs] ; preço
  set C (1.0 / (P * M ^ A))                                                 ; define a competitividade da firma, dada a rigidez a ganhar mercados definida por M^A
end                                                                         ; ao multiplicar o K próprio (Aprofit) pela taxa de juros 1+z.

to Global-Competitiveness
  set Cmed (sum [C * M] of firms)                                       ; competitividade média
end

to MarketShare
  ask firms [set M (M * (1.0 + 0.10 * ((C / Cmed) - 1.0)))]                  ; market-share da firma
  set g5 (sum [M] of firms)                                                  ; soma dos market-shares
  ask firms [set M (M * 1.0 / g5)]                                           ; Ajusta o market-share: Sum Mi = 1.0
end

to Price-Level
  set Pmed sum [P * M] of firms with [Class2 = 1]                             ; Pmed determinado somente por firmas Hedge
  set g19 sum [P * M] of firms                                                ; preço médio exclui as pequenas firmas (Plotagem).
end

to Income-Government
  set Y (Wtotal + S)                                                           ; renda local + renda não-gasta
  set Wtotal 0.0                                                               ; zerar
  set S 0.0                                                                    ; zerar
  set Yg (i * Ktit)                                                            ; gasto do governo com juros
  set Y (Y - Yg)                                                               ; renda disponível, supondo que Tax = Juros
end

to Sales-Profit
  set Qd (M * Y / P)                                                           ; quantidade demandada

  if Qd = Qs [set R (P * Qd)    set V 0.0    set S (S + 0.0)            ]      ; oferta = demanda
  if Qd > Qs [set R (P * Qs)    set V 0.0    set S (S + (P * (Qd - Qs)))]      ; oferta > demanda
  if Qd < Qs [set R (P * Qd)    set V (Qs - Qd)  set S (S + 0.0)        ]      ; oferta < demanda

  set list-MemoD1 fput Qd list-MemoD1                                          ; ajustar memória
  set list-MemoD1 but-last list-MemoD1                                         ; ajustar memória

  if FlexExpectation = false [stop]                                            ; manter ou não a estratégia
  if (Qs - Qd) > (0.3 * Qd) [set class1 random 8]                              ; troca de estratégia se houver erro
  if (Qd - Qs) > (0.3 * Qs) [set class1 random 8]                              ; troca de estratégia se houver erro
end

to Markup
  set Mk Mk * (1.0 + Mk-sensibility * (Qd - Qs) / Qs)                          ; ajuste de mark-up
  ;if Mk < (1.0 + z) [set Mk (1.0 + z)]                                        ; mark-up mínimo
  ;if Mk > 1.9       [set Mk 1.9      ]                                        ; mark-up máximo
end

to FinancingRegime
  set Rtot (R + AProfit)                                                       ; recursos totais da firma
  set t1 (z * ADebit)                                                          ; juros
  set t2 (ADebit)                                                              ; dívida
  set ADebit (ADebit + t1)                                                     ; dívida + juros

  if Rtot >= (t1 + t2)               [set AProfit (Rtot - t1 - t2)             ; Hedge
                                      set J t1                                 ; Hedge
                                      set AM t2                                ; Hedge
                                      set Class2 1                             ; Hedge
                                      set color green]                         ; Hedge
  if Rtot >= t1 and Rtot < (t1 + t2) [set AProfit 0.0                          ; Speculative
                                      set J t1                                 ; Speculative
                                      set AM (Rtot - t1)                       ; Speculative
                                      set Class2 2                             ; Speculative
                                      set color blue]                          ; Speculative
  if Rtot < t1                       [set AProfit 0.0                          ; Ponzi
                                      set J Rtot                               ; Ponzi
                                      set AM 0.0                               ; Ponzi
                                      set Class2 3                             ; Ponzi
                                      set color red]                           ; Ponzi

  set ADebit (ADebit - J - AM)                                                 ; creditar o pagamento de juros e amortização
  if Adebit <= 0.0 [set Adebit 0.0]                                            ; restrição
  set Sd (Sd - AM)                                                             ; creditar a amortização na dívida
  if  Sd <= 0.0 [set Sd 0.0]                                                   ; restrição
  set g7 (g7 + t1 + t2)                                                        ; juros e amortização esperados.
  set g8 (g8 + J + AM)                                                         ; juros e amortização efetivados.
  set g10 (g10 + J)                                                            ; juros recebidos.
end

to BankBehaviour
  set h ((g10 - Kfail) / Cred) / (Yg / Ktit)                                     ; rendimento líquido de aplicações privadas em relação a rendimento em títulos públicos
  set list-MemoH fput h list-MemoH                                               ; ajustar memória do banco
  set list-MemoH but-last list-MemoH                                             ; ajustar memória do banco
  set g standard-deviation list-MemoH                                            ; desvio-padrão
  set Pbank (Pmed / g)

  set Frag1 (g7 - g8) / g7                                                       ; rendimentos esperados - rendimentos recebidos / rendimentos esperados
  if Frag1 < 0.05 [set Frag1 0.05]                                               ; limite inferior
  set Frag2 (alfa * Frag2 + (1 - alfa) * Frag1)                                  ; "média ponderada"
  set spread Frag2                                                               ; spread
  set z (1.0 + spread) * i                                                       ; juros = spread + juros gov

  set g1 (teto_Ktit / piso_Ktit)                                                 ; var auxiliar
  set sigma (piso_Ktit * (g1 ^ Frag2))                                           ; taxa desejada de aplicações em títulos

  set Kbank (Ktit + Yg + g8)                                                     ; capital do banco = capital títulos + juros gov + juros privados
  set g17 sum [AProfit] of firms                                                 ; soma dos lucros
  set Wealth (Kbank + g17 + S)                                                   ; wealth
  set Kfail 0.0                                                                  ; zerar Kfail

  set g7 0.0                                                                     ; zerar g7
  set g8 0.0                                                                     ; zerar g8
  set g10 0.0                                                                    ; zerar g10
  set g4 sum [a] of firms / count firms                                          ; "A" médio
end


to plot-information
  set-current-plot "Capital X Tech"
    clear-plot

    create-temporary-plot-pen "A"
    set-plot-pen-color red
    set-plot-pen-mode 2
    ask firms [plotxy K A]

    create-temporary-plot-pen "T"
    set-plot-pen-color blue
    set-plot-pen-mode 2
    ask firms [plotxy K T]

    create-temporary-plot-pen "F"
    set-plot-pen-color green
    set-plot-pen-mode 2
    ask firms [plotxy K F]


  set-current-plot "Inventory and Savings"
    create-temporary-plot-pen "V"
    set-plot-pen-color red
    plot Vtotal

    create-temporary-plot-pen "S"
    set-plot-pen-color blue
    plot S


  set-current-plot "Capital X Price"
    clear-plot

    create-temporary-plot-pen "cap_x_price"
    set-plot-pen-mode 2
    ask firms [plotxy K P]


  set-current-plot "Firms"
    create-temporary-plot-pen "qty_firms"
    plot count firms


  set-current-plot "Bank Balance-Sheet"
    create-temporary-plot-pen "Ktit"
    set-plot-pen-color green
    plot Ktit

    create-temporary-plot-pen "Cred"
    set-plot-pen-color red
    plot Cred


  set-current-plot "Financial Fragility (Spread)"
    create-temporary-plot-pen "Spread"
    set-plot-pen-color blue
    plot Frag2


  set-current-plot "Firm Financial Regime (%)"
    set n1 (count firms with [class2 = 1] / count firms) * 100
    set n2 (count firms with [class2 = 2] / count firms) * 100
    set n3 (count firms with [class2 = 3] / count firms) * 100

    create-temporary-plot-pen "hedge"
    set-plot-pen-color green
    plot n1

    create-temporary-plot-pen "Spec"
    set-plot-pen-color blue
    plot n2

    create-temporary-plot-pen "Ponzi"
    set-plot-pen-color red
    plot n3


  set-current-plot "Y"
    create-temporary-plot-pen "Y"
    set-plot-pen-color blue
    plot Y


  set-current-plot "Tax Revenue"
    create-temporary-plot-pen "Yg"
    set-plot-pen-color red
    plot Yg


  set-current-plot "Price Level"
    create-temporary-plot-pen "Pmed"
    set-plot-pen-color black
    plot g19

    create-temporary-plot-pen "Pmed_Hedge"
    set-plot-pen-color green
    plot Pmed

    ;create-temporary-plot-pen "PEspec"
    ;set-plot-pen-color blue
    ;plot g2

    ;create-temporary-plot-pen "PPonzi"
    ;set-plot-pen-color red
    ;plot g3


  set-current-plot "Expectation"
    set expec1 (count firms with [class1 = 0] / count firms) * 100
    set expec2 (count firms with [class1 = 1] / count firms) * 100
    set expec3 (count firms with [class1 = 2] / count firms) * 100
    set expec4 (count firms with [class1 = 3] / count firms) * 100
    set expec5 (count firms with [class1 = 4] / count firms) * 100
    set expec6 (count firms with [class1 = 5] / count firms) * 100
    set expec7 (count firms with [class1 = 6] / count firms) * 100
    set expec8 (count firms with [class1 = 7] / count firms) * 100

    create-temporary-plot-pen "expec1"
    set-plot-pen-color green
    plot expec1

    create-temporary-plot-pen "expec2"
    set-plot-pen-color blue
    plot expec2

    create-temporary-plot-pen "expec3"
    set-plot-pen-color red
    plot expec3

    create-temporary-plot-pen "expec4"
    set-plot-pen-color black
    plot expec4

    create-temporary-plot-pen "expec5"
    set-plot-pen-color yellow
    plot expec5

    create-temporary-plot-pen "expec6"
    set-plot-pen-color gray
    plot expec6

    create-temporary-plot-pen "expec7"
    set-plot-pen-color brown
    plot expec7

    create-temporary-plot-pen "expec8"
    set-plot-pen-color orange
    plot expec8


  set-current-plot "Amed"
    create-temporary-plot-pen "am"
    plot g4


  set-current-plot "geral"
    create-temporary-plot-pen "cf"
    plot (count firms)

    create-temporary-plot-pen "y"
    plot Y

    create-temporary-plot-pen "Yg"
    plot Yg

    create-temporary-plot-pen "Pmed"
    plot Pmed

    create-temporary-plot-pen "Ktit"
    plot Ktit

    create-temporary-plot-pen "Cred"
    plot Cred

    create-temporary-plot-pen "Frag2"
    plot Frag2

    create-temporary-plot-pen "n1"
    plot n1

    create-temporary-plot-pen "n2"
    plot n2

    create-temporary-plot-pen "n3"
    plot n3

    create-temporary-plot-pen "Amed"
    plot g4

    create-temporary-plot-pen "Pbank"
    plot Pbank

    create-temporary-plot-pen "s"
    plot s

    create-temporary-plot-pen "h"
    plot h


  set-current-plot "FFR"
    set n1 (count firms with [class2 = 1])
    set n2 (count firms with [class2 = 2])
    set n3 (count firms with [class2 = 3])

    create-temporary-plot-pen "hedge"
    set-plot-pen-color green
    plot n1

    create-temporary-plot-pen "Spec"
    set-plot-pen-color blue
    plot n2

    create-temporary-plot-pen "Ponzi"
    set-plot-pen-color red
    plot n3

    create-temporary-plot-pen "Total"
    set-plot-pen-color black
    plot (count firms)


  set-current-plot "KP-var"
    create-temporary-plot-pen "K-var"
    set-plot-pen-color red
    plot g16

    create-temporary-plot-pen "P-var"
    set-plot-pen-color green
    plot g18
end

@#$#@#$#@
GRAPHICS-WINDOW
0
10
209
208
-1
-1
5.743
1
10
1
1
1
0
1
1
1
-17
17
-16
16
1
1
1
Time
30.0

SLIDER
2
299
203
332
History
History
0
2000
1000.0
1
1
NIL
HORIZONTAL

SLIDER
2
599
205
632
i
i
0
0.02
0.01
0.002
1
NIL
HORIZONTAL

SLIDER
1
636
204
669
alfa
alfa
0.9
1
0.95
0.01
1
NIL
HORIZONTAL

SLIDER
1
673
205
706
memo
memo
0
3
2.0
1
1
NIL
HORIZONTAL

SLIDER
1
709
205
742
piso_Ktit
piso_Ktit
0
0.2
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
1
747
205
780
teto_Ktit
teto_Ktit
0.8
0.95
0.9
0.01
1
NIL
HORIZONTAL

SLIDER
1
812
204
845
Mk-sensibility
Mk-sensibility
0.0
0.0020
0.001
5.0E-4
1
NIL
HORIZONTAL

SLIDER
0
423
205
456
Asymmetry
Asymmetry
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
0
459
206
492
Acoef
Acoef
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
0
496
206
529
Tcoef
Tcoef
0.1
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
0
531
204
564
Fcoef
Fcoef
0
10
1.0
1
1
NIL
HORIZONTAL

SWITCH
1
260
95
293
Entry?
Entry?
0
1
-1000

SWITCH
104
260
202
293
Break
Break
1
1
-1000

SWITCH
3
849
204
882
ExpectativaHomogenea
ExpectativaHomogenea
1
1
-1000

SWITCH
4
887
204
920
FlexExpectation
FlexExpectation
1
1
-1000

SWITCH
4
927
204
960
ProdutoHomogeneo
ProdutoHomogeneo
1
1
-1000

MONITOR
5
339
97
384
Time
ticks
3
1
11

BUTTON
1
218
94
251
NIL
Start
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
104
219
202
252
NIL
Run-World
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
607
220
979
423
Firm Financial Regime (%)
time
%
0.0
10.0
0.0
100.0
true
true
"" ""
PENS

PLOT
224
10
597
213
Y
time
$
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
607
432
979
634
Price Level
time
$
0.0
10.0
0.0
3.0
true
true
"" ""
PENS

PLOT
227
642
600
844
Tax Revenue
time
$
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
323
1075
483
1195
Expectation
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
486
1076
646
1196
Amed
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS

PLOT
159
1075
319
1195
geral
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
651
1076
811
1196
ffr
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
816
1076
976
1196
KP-var
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS

PLOT
227
851
600
1053
Capital X Price
K
P
0.0
10.0
0.0
5.0
true
false
"" ""
PENS

PLOT
605
10
978
212
Firms
time
pop
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" "plot count firms"

PLOT
606
642
978
842
Inventory and Savings
time
q and $
0.0
100.0
0.0
0.1
true
true
"" ""
PENS

PLOT
226
431
600
634
Financial Fragility (Spread)
time
spread
0.0
10.0
0.0
0.5
true
false
"" ""
PENS

PLOT
607
851
978
1054
Capital X Tech
K
A, T and F
0.0
10.0
0.0
3.0
true
true
"" ""
PENS

PLOT
225
221
599
422
Bank Balance-Sheet
time
$
0.0
10.0
0.0
10.0
true
true
"" ""
PENS

MONITOR
106
339
204
384
NIL
count firms
17
1
11

TEXTBOX
69
401
138
419
Technology
12
0.0
1

TEXTBOX
83
578
141
596
Financial
12
0.0
1

TEXTBOX
80
790
120
808
Firm
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
