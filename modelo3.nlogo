;==========================================
;Title: Instabilidade Financeira Regionalizado Netlogo 6.4.0
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

breed [techs tech]
breed [firms firm]

techs-own [A                      ; tecnologia de produto (diferenciação)
           T                      ; tecnologia de processo
           F]                     ; custo fixo e escala mínima

firms-own [Class1                 ; tipo de expectativa
           Class2                 ; Ponzi, Hedge e Especulativo
           Citzen                 ; localização
           A                      ; tecnologia de produto (diferenciação)
           T                      ; tecnologia de processo
           F                      ; custo fixo e escala mínima
           Mk                     ; markup
           K                      ; capital monetário
           L                      ; insumos (trabalhadores, horas de trabalho)
           Qs                     ; quantidade ofertada
           Qd                     ; quantidade demandada
           Qe                     ; quantidade esperada
           P                      ; preço
           V                      ; estoques
           R                      ; receita de vendas
           U                      ; grau de utilização da capacidade instalada = Qs
           Kmin                   ; capital mínimo
           Ppot                   ; preço para localização
           list-MemoD1            ; memória para projeção da demanda
           list-MemoD2            ; memória para projeção da demanda
           AProfit                ; lucros acumulados
           ADebit                 ; dívidas acumuladas
           Loan                   ; empréstimos
           Sd                     ; saldo devedor não honrado ou perda de capital do banco
           Wb                     ; despesas de produção dada a expectativa de demanda
           Rtot                   ; recursos totais da firma = receitas de vendas + lucros acumulados (AProfit)
           AM                     ; amortização
           J                      ; juros
           t1 t2 t3 t4 t5 t6 t7 t8]

patches-own [city                ; cidade / região
             PopL                ; população de trabalhadores
             PopF                ; população de firmas
             W                   ; salário ou preços dos insumos locais
             Y                   ; renda disponível local
             Ybarra              ; participação relativa da renda regional
             S                   ; renda não gasta (poupança)
             Frag1               ; taxa de inadimplência (indicador de fragilidade financeira regional)
             Frag2               ; versão suavisada de Frag1
             Frag3
             spread              ; spread
             list-Pt             ; preço com transporte local
             list-C              ; competitividade da firma local
             Cmed                ; competitividade média local
             list-M              ; market-share da firma local
             list-Qd             ; quantidade demandada local
             list-Qs             ; quantidade ofertada local
             list-Ex             ; gasto total na região
             List-MemoH          ; memória do banco local
             t2r                 ; juros esperados em cada região
             t3r                 ; amortizações esperadas em cada região
             Jr                  ; juros efetivos em cada região
             AMr                 ; amortizações efetivas em cada região
             Kfail               ; perda de capital do banco em cada região
             Credr               ; volume de crédito concedido em cada região
             Rr                  ; capital total local
             sigma               ; taxa desejada de aplicação em títulos (a taxa efetiva pode ser >= tx desejada)
             z                   ; taxa de juros de empréstimo regional
             h                   ; rendimento do ativo crédito regional em relação ao ativo títulos
             g                   ; desvio-padrão de h
             Pbank               ; preço limite estabelecido pelo banco (critério para concessão de financiamento)
             Pmed                ; preço médio local de mercado (variável Walrasiana do Banco!)
             Kr                  ; capital na região
             Lrr                 ; empregos na região
             r1 r2 r3 r4 r5      ; var auxiliares
             r6 r7 r8 r9]


globals [Kbank                   ; capital do banco
         Pbankmed                ; Pbank médio (ponderado pela renda relativa)
         Ktit                    ; capital do banco em títulos públicos
         Cred                    ; ativo crédito (volume de crédito concedido)
         Ytotal                  ; renda total
         Tax                     ; alíquota de imposto
         Yg                      ; renda do governo = despesas financeiras em títulos públicos
         Time                    ; períodos de produção (variável auxiliar)
         Wealth                  ; riqueza total da economia (R$) (variável auxiliar)
         Mmed                    ; market-share médio (variável auxiliar)
         Pmed-H
         spread-med
         r9-med                  ; desequilíbrio entre oferta e demanda de crédito (média ponderada)
         Vtotal                  ; total de estoques (variável auxiliar)
         list-F                  ; lista com firmas (lista auxiliar)
         list-P                  ; preços sem custo de transporte (lista auxiliar)
         list-A                  ; qualidade (lista auxiliar)
         list-L                  ; localização (lista auxiliar)
         list-U                  ; grau de utilização (lista auxiliar)
         n1 n2 n3                ; variáveis auxiliares da plotagem
         expec1 expec2           ; variáveis auxiliares da plotagem
         expec3 expec4           ; variáveis auxiliares da plotagem
         expec5 expec6           ; variáveis auxiliares da plotagem
         expec7 expec8           ; variáveis auxiliares da plotagem
         g1 g2 g3 g4 g5 g6       ; variáveis auxiliares da plotagem
         g9 g11 g12 g13 g14 g15  ; variáveis auxiliares da plotagem
         g16 g17 g18 g19         ; variáveis auxiliares da plotagem
         b1]


to start
  clear-output
  clear-all
  set-default-shape turtles "square"
  random-seed 1.0
  reset-ticks
  set Kbank 2000.0                                                                 ; capital inicial do banco
  ask patches [set sigma 0.1                                                       ; taxa desejada inicial de aplicação em títulos
               set z 0.01                                                          ; taxa de juros inicial
               set W 1.0                                                           ; salário regional inicial
               if memo = 3 [set list-MemoH n-values 40 [1.0]]                      ; memória do banco
               if memo = 2 [set list-MemoH n-values 20 [1.0]]                      ; memória do banco
               if memo = 1 [set list-MemoH n-values 10 [1.0]]                      ; memória do banco
               if memo = 0 [set list-MemoH n-values  2 [1.0]]]                     ; memória do banco
  set list-F n-values 1000 [0.0]                                                   ; cria lista de preços das firmas (auxiliar)
  set list-P n-values 1000 [0.0]                                                   ; cria lista de preços das firmas (auxiliar)
  set list-L n-values 1000 [-1 ]                                                   ; cria lista com localização das firmas (auxiliar)
  set list-U n-values 1000 [1.0]                                                   ; cria lista com localização das firmas (auxiliar)
  set list-A n-values 1000 [0.0]                                                   ; cria lista de qualidade (auxiliar)
  create-techs 1000 [technology                                                    ; cria parâmetros tecnológicos
                     set list-A replace-item who list-A A]                         ; atribui valores a lista de tecnologia de produto (auxiliar)
  initial-firms                                                                    ; localização inicial das firmas
  initial-regions                                                                  ; características iniciais das regiões
  Plot-information                                                                 ; gráficos
end


to initial-firms
  set g19 0
  repeat 400 [
    ask one-of techs [
      set breed firms                                     ; cria 400 firmas
      set color green                                     ; cor
      set heading 90                                      ; direção
      setxy g19 0                                         ; localização: distribui firmas entre regiões
      set g19 g19 + 1
      if g19 = 50 [set g19 0]
      show-turtle                                         ; mostrar
      set citzen xcor                                     ; localização
      set list-F replace-item who list-F 1.0              ; entra na lista de firmas
      set Mk 1.2                                          ; markup inicial
      set t6 3                                            ; parâmetro expectacional
      ifelse ExpHomogenea = true [set Class1 1       ]    ; expectativas
                                 [set Class1 random 8]    ; expectativas
      set Kmin (t6 * F * 1.0)                             ; escala inicial
      set list-MemoD1 n-values 10 [Kmin]                  ; escala inicial
    ]
  ]
end


to initial-regions  ;GLOBAL
  ask patches [set city pxcor                                                       ; código da região
               set list-M  (map [ l1 -> l1 * 1.0 / 300.0 ] list-F)                  ; cria lista de market-share regional
               set list-Pt n-values 1000 [0.0]                                      ; preço com transporte local
               set list-C  n-values 1000 [0.0]                                      ; competitividade da firma local
               set list-Qd n-values 1000 [0.0]                                      ; quantidade demandada local
               set list-Qs n-values 1000 [0.0]                                      ; quantidade ofertada local
               set list-Ex n-values 1000 [0.0]                                      ; gasto total na cidade / região
               set PopL 40]                                                         ; população de trabalhadores da região
end


to technology
  set breed techs                                                                   ; tecnologia
  set color gray                                                                    ; colorir
  hide-turtle                                                                       ; esconder
  loop [set A random-normal Acoef (Acoef * Asymmetry)                               ; tecnologia de produto
        set T random-normal Tcoef (Tcoef * Asymmetry)                               ; tecnologia de processo
        set F random-normal Fcoef (Fcoef * Asymmetry)                               ; escala mínima e custos fixos
        if ProdutoHomogeneo = true [set A  0.0                                      ; restrição tec
                                    if T > 0.1 and T <= 10.0 and                    ; restrição tec
                                       F > 0.0 and F <= 10.0 [stop]]                ; restrição tec
        if A > 0.0 and A <= 10.0 and                                                ; restrição tec
           T > 0.1 and T <= 10.0 and                                                ; restrição tec
           F > 0.0 and F <= 10.0 [stop]]                                            ; restrição tec
end


to run-world
  loop [Clear-data                                                                  ; Limpar listas e dados
        Entry                                                                       ; Entrada de novas firmas
        set Vtotal (sum [V] of firms)                                               ; Estoques totais
        ask firms [Expectation]                                                     ; Expectativas
        ask firms [DemandCredit]                                                    ; Demanda por crédito
        SupplyCredit                                                                ; Banco define o volume de capital a ser emprestado, dada a demanda total por crédito
        ask firms [GetLoan]                                                         ; Firma obtem empréstimos
        ask patches [LaborMarket]                                                   ; Firma compra insumos e contrata trabalhadores
        ask firms [Production]                                                      ; Firma define a produção
        ask firms [Price]                                                           ; Preço e Competitividade
        ask patches [Income]                                                        ; Renda, governo e tributação
        Government                                                                  ; Impostos e Renda Disponível
        ask patches [CompetitivenessIndex]                                          ; Competitividade local
        ask patches [MarketShare]                                                   ; Market-share local
        ask patches [Demand]                                                        ; Demanda local
        ask firms [Sales]                                                           ; Vendas e lucros
        ask patches [Consume]                                                       ; Consumo local
        ask firms [Adjust-Memory]                                                   ; Ajustar memória
        ask firms [Adjust-Expectation]                                              ; Ajustar expectativas
        ask firms [Adjust-Markup]                                                   ; Ajustar markup
        ask firms [FinancingRegime]                                                 ; Tipologia Hedge, Speculative, Ponzi
        BankBehaviour                                                               ; Ajuste no spread
        Dados                                                                       ; coletar dados
        tick                                                                        ; Períodos
        plot-information                                                            ; Imprime informações
        if break = true [set break false stop]
        if ticks >= history [stop]]
end


to Clear-Data ;GLOBAL
  set Ktit 0.0
  set list-F n-values 1000 [0.0]                                         ; cria lista de preços das firmas (auxiliar)
  set list-P n-values 1000 [0.0]                                         ; cria lista de preços das firmas (auxiliar)
  set list-L n-values 1000 [-1]                                          ; cria lista com localização das firmas (auxiliar)
  set list-U n-values 1000 [1.0]                                         ; cria lista com localização das firmas (auxiliar)
  ask firms [setxy Citzen 0]                                             ; retornar à região
  ask patches [
    set W 1.0                                                            ; salário local
    set Y 0.0                                                            ; renda local
    set Kr 0.0                                                           ; massa salarial local
    set Credr 0.0                                                        ; empréstimos contratados local
    set Lrr 0.0                                                          ; empregos na região
    set PopF 0.0                                                         ; população de firmas local
    set Cmed 0.0                                                         ; competitividade média local
    set list-Pt n-values 1000 [0.0]                                      ; preço com transporte local
    set list-C  n-values 1000 [0.0]                                      ; competitividade da firma local
    set list-Qd n-values 1000 [0.0]                                      ; quantidade demandada local
    set list-Qs n-values 1000 [0.0]                                      ; quantidade ofertada local
    set list-Ex n-values 1000 [0.0]                                      ; gasto total na cidade / região
    set Kr 0.0                                                           ; capital na região
    set t2r 0.0                                                          ; pagamento esperado de juros na região r
    set t3r 0.0                                                          ; amortizações esperadas na região r
    set Jr 0.0                                                           ; juros efetivamente pagos na região r
    set AMr 0.0                                                          ; amortizações efetivamente realizadas na região r
    set Kfail 0.0                                                        ; perda de capital na região r
    set Pmed 0.0                                                         ; Preço médio regional
    set Rr 0.0]                                                          ; soma das receitas das firmas locais
end


to Entry  ; GLOBAL VER
  if ticks <= 1 [stop]
  if entry? = false [stop]
  if one-of techs = nobody [stop]
  ask one-of techs [set g1 -1                                                       ; variável auxiliar
                    Potential-Location                                              ; identificar local ótimo
                    Potential-Entry]                                                ; avaliar se a entrada é possível, dado preço ótimo e Pbank
  if g1 = -1 [stop]                                                                 ; g1 = 0 significa que não houve entrada e a rotina é concluída
  ask patches [set list-M replace-item g1 list-M (1.0 / count firms)]               ; houve entrada e consumidores alocam renda (e market-share) para esse produto novo
end


to Potential-Location  ; TECH
  set breed firms                                                                   ; tecnologia vira firma
  ifelse ExpHomogenea = true [set Class1 1       ]                                  ; expectativas homogêneas
                             [set Class1 random 8]                                  ; expectativas heterogêneas
  set heading 90                                                                    ; posição inicial
  let temp1 0                                                                       ; variável auxiliar
  let temp2 0                                                                       ; variável auxiliar
  let temp3 0                                                                       ; variável auxiliar
  setxy 0 0                                                                         ; posição inicial para identificação do melhor local
  set Ppot 1000000
  repeat world-width [set t6 (3 * (1 + r3) ^ Entry-Y-sensibility)                                                                ; parâmetro expectacional: raiz controla sensibilidade de Ppot a Ybarra (r3)
                      set Kmin (t6 * F * W)                                                                                      ; capital inicial
                      set Mk 1.2                                                                                                 ; mark-up inicial
                      set L (Kmin / W)                                                                                           ; demanda de insumos planejada
                      set Qs (T * (L - F))                                                                                       ; oferta planejada
                      set P (Mk * Kmin * (1.0 + z)) / Qs                                                                         ; preço potencial
                      set temp1 city                                                                                             ; variável auxiliar - local potencial
                      set temp2 P                                                                                                ; variável auxiliar - preço potencial
                      set temp3 sum [(1 / world-width) * (temp2 * (1.0 + Tc * (abs (city - temp1))))] of patches                 ; preço potencial para cada localização alternativa
                      if (temp3 < Ppot) [set Ppot temp3 set citzen city]                                                         ; localização potencial
                      fd 1]                                                                                                      ; mover para o próximo local potencial e repetir o processo acima
end


to Potential-Entry  ; FIRM
  setxy Citzen 0
  if Pbank < Ppot [set breed techs stop]                                           ; restrição do banco via Pbank, dado o preço no local ótimo
  set list-L replace-item who list-L citzen                                        ; localização da firma (auxilia a definição de distâncias)
  set list-MemoD1 n-values 10 [Kmin]                                               ; memória inicial para quantidade produzida
  set PopF (PopF + 1)                                                              ; população de firmas em cada região
  show-turtle                                                                      ; aparecer
  set g1 who                                                                       ; variável auxiliar
end


to Expectation ; FIRM
  set list-MemoD2 (list item 0 list-MemoD1 item 1 list-MemoD1 item 2               ; memória
                   list-MemoD1 item 3 list-MemoD1 item 4 list-MemoD1)              ; memória
  if class1 = 0 [set Qe mean   list-MemoD1]                                        ; expectativas
  if class1 = 1 [set Qe max    list-MemoD1]                                        ; expectativas
  if class1 = 2 [set Qe min    list-MemoD1]                                        ; expectativas
  if class1 = 3 [set Qe median list-MemoD1]                                        ; expectativas
  if class1 = 4 [set Qe item 0 list-MemoD1]                                        ; expectativas
  if class1 = 5 [set Qe mean   list-MemoD2]                                        ; expectativas
  if class1 = 6 [set Qe max    list-MemoD2]                                        ; expectativas
  if class1 = 7 [set Qe min    list-MemoD2]                                        ; expectativas
end


to DemandCredit  ; FIRM
  set Qe (Qe - V)                                                                  ; descontando das expectativas de venda os estoques
  if Qe < 0.0 [set Qe 0.0]                                                         ; restrição
  set L (Qe / T) + F                                                               ; demanda por trabalhadores / insumos
  set Wb (L * W)                                                                   ; capital necessário, dado o nível de produção desejado
  ifelse AProfit < Wb [set Loan (Wb - AProfit)]                                    ; demanda por crédito > 0
                      [set Loan 0.0]                                               ; demanda por crédito = 0
end


to SupplyCredit  ; GLOBAL
  set g14 Kbank                                                                   ; capital do banco
  set g11 (sum [Loan] of firms)                                                   ; demanda de credito total
  ask firms [set r4 (r4 + loan)]                                                  ; demanda regional de crédito
  ask patches [set r7 (r4 / g11) * g14                                            ; oferta regional de crédito (provisório)
               set Credr (1.0 - sigma) * r7                                       ; oferta regional de credito ajustada
               set Ktit Ktit + (sigma * r7)                                       ; montante em títulos (provisório)
               ifelse r4 > Credr [set r6 (Credr / r4)]                            ; 1º caso: demanda de crédito supera oferta: cria redutor < 0
                                 [set r6 1.0]                                     ; demanda <= oferta : redutor 1.0
               ifelse r4 > 0 [set r9 (Credr / r4)]
                             [set r9 0.0]                                         ; auxiliar: desequilíbrio entre oferta e demanda (somente para plotagem)
               set r5 (r4 * r6)                                                   ; demanda por crédito ajustada pelo redutor
               if Credr > r5 [set r8 (Credr - r5)]]                               ; 2º caso: oferta maior que demanda: pode ocorrer no caso de redutor = 1.0
  set Ktit Ktit + (sum [r8] of patches)                                           ; soma o excedente ao Ktit anterior
  set Cred (g14 - Ktit)                                                           ; volume de recursos emprestados.
  ask patches [set Credr 0.0
               set r4 0.0
               set r5 0.0
               set r7 0.0
               set r8 0.0]
end


to GetLoan  ; FIRM
  set Loan (Loan * r6)                                                             ; firma ajusta demanda por crédito ofertado pelo banco
  ifelse AProfit < Wb  [set K (Loan + AProfit)                                     ; com empréstimo
                        set AProfit 0.0]                                           ; com empréstimo
                      [set K Wb                                                    ; sem empréstimo
                        set AProfit (AProfit - Wb)]                                ; sem empréstimo
  set Sd (Sd + Loan)                                                               ; saldo devedor
  set ADebit (ADebit + Loan)                                                       ; dívidas acumuladas
  set Credr (Credr + Loan)                                                         ; volume de empréstimos contratados na região
  set Kr (Kr + K)                                                                  ; volume de capital na região
end


to LaborMarket  ; PATCHES
  if W-fix = true [set W 1.0 stop]
  let W2 (Kr / PopL) ^ 2                                                           ; salário nominal regional com população fixa
  set W (0.99 * W + (1 - 0.99) * W2)                                               ; ajustamento lento do salário
  if W < 1.0 [set W 1.0]                                                           ; salário mínimo ou de reserva - restrição
end


to Production  ; FIRM
  set L (K / W)                                                                    ; firma adquiri insumos
  set Y (Y + (L * W))                                                              ; massa salarial local
  if L < F or (L = F and V = 0.0) [set Kfail (Kfail + Sd)                          ; escala mínima e massa falida acrescida do saldo devedor ; Qs pode ser zero se L=F e V=0
                                   set breed techs                                 ; volta para o "armário de tecnologias"
                                   set list-L replace-item who list-L -1           ; sai do local
                                   set color gray                                  ; cor
                                   hide-turtle                                     ; esconder
                                   setxy 0 0                                       ; localiza tech na patch 0 0
                                   stop]                                           ; parar rotina
  set Qs (T * (L - F) + V)                                                         ; produção
  set Lrr (Lrr + L)                                                                ; emprego no local
  set PopF (PopF + 1)                                                              ; população de firmas
end


to Price  ; FIRM
  ifelse ADebit <= 0.0 and Aprofit <= 0.0 [set P P stop]                                        ; preço
                                          [set P Mk * ((ADebit * (1.0 + z)) + AProfit) / Qs]    ; preço
  set list-P replace-item who list-P P                                                          ; anuncia preço (sem custos de transporte)
  set list-L replace-item who list-L Citzen                                                     ; anuncia local de produção
  set list-F replace-item who list-F 1.0                                                        ; firma está ativa
end


to Income  ; PATCHES
  set Y (Y + S)                                                                    ; renda local + renda não-gasta
  set S 0.0                                                                        ; zerar
end


to Government  ; GLOBAL
  set Yg (i * Ktit)                                                                ; gasto do governo com juros
  set Ytotal (sum [Y] of patches)                                                  ; renda total = soma das renda regionais
  set Tax (Yg / Ytotal)                                                            ; alíquota de imposto de renda
  ask patches [set Y (Y * (1.0 - Tax))                                             ; renda disponível
              set Ybarra (Y / Ytotal)                                              ; participação relativa da renda regional
              ifelse Ybarra < 0.005 [set r3 0.005]                                 ; var auxiliar para determinação de t6
                                    [set r3 Ybarra]]
end


to CompetitivenessIndex  ; PATCHES
  set list-Pt (map [ [l1 l2] -> l1 * (1.0 + Tc * abs (pxcor - l2)) ] list-P list-L)                                                               ; define a lista de preços regionais (P fábrica * custo de transporte)
  let B 0                                                                                                                            ; variável auxiliar (índicer de um valor numa lista)
  repeat 1000 [if item B list-Pt > 0.0 [set list-C replace-item B list-C (1.0 / (item B list-Pt * (item B list-M ^ item B list-A)))] ; define a competitividade local da firma
               set B B + 1]                                                                                                           ; variável auxiliar
  set B (map [ [l1 l2] -> l1 * l2 ] list-C list-M)                                                                                                ; competitividade média ponderada pelo market-share
  set Cmed sum B                                                                                                                     ; competitividade média local
end


to MarketShare  ; PATCHES
  set list-M (map [ [l1 l2] -> l1 * (1.0 + Dem-sensibility * ((l2 / Cmed) - 1.0)) ] list-M list-C)                                                           ; define o market-share das firmas
  let B sum list-M                                                                                                                   ; soma dos market-shares
  set list-M (map [ l1 -> l1 / B ] list-M)                                                                                                   ; Ajusta o market-share: Sum Mi = 1.0
end


to Demand  ; PATCHES
  let B 0                                                                                                                   ; variável auxiliar
  repeat 1000 [if item B list-P > 0.0 [set list-Qd replace-item B list-Qd (item B list-M * Y / item B list-P)]              ; define a competitividade local da firma
              set B B + 1]                                                                                                  ; variável auxiliar
end


to Sales  ; FIRM
  let B who                                                                       ; variável temporária
  set Qd sum [item B list-Qd] of patches                                          ; quantidade demandada
  if Qd = Qs [set R (P * Qd) set V 0.0       set U 1.0]                           ; oferta = demanda e utilização máxima, confirma demanda
  if Qd > Qs [set R (P * Qs) set V 0.0       set U (Qs / Qd)]                     ; demanda > oferta e excesso de demanda, não-confirma demanda
  if Qd < Qs [set R (P * Qd) set V (Qs - Qd) set U 1.0]                           ; demanda < oferta e utilizacão ociosa, confirma demanda
  set list-U replace-item who list-U U                                            ; anuncia capacidade de entrega
  set t7 (P * R)                                                                  ; var auxiliar para o cálculo de Pmed
end


to Consume  ; PATCHES
  set list-Qs (map [ [l1 l2] -> l1 * l2 ] list-Qd list-U)                                         ; quantidade entregue
  set list-Ex (map [ [l1 l2] -> l1 * l2 ] list-Qs list-P)                                         ; despesas (expenditure)
  set S (Y - sum list-Ex)                                                          ; renda residual
end


to Adjust-Memory  ; FIRM
  set list-MemoD1 fput Qd list-MemoD1                                              ; ajustar memória
  set list-MemoD1 but-last list-MemoD1                                             ; ajustar memória
end


to Adjust-Expectation  ; FIRM
  if FlexExpectation = false [stop]                                                ; manter ou não a estratégia
  if (Qs - Qd) > (0.3 * Qd) [set class1 random 8]                                  ; troca de estratégia se houver erro
  if (Qd - Qs) > (0.3 * Qs) [set class1 random 8]                                  ; troca de estratégia se houver erro
end


to Adjust-Markup  ; FIRM
  set Mk Mk * (1.0 + Mk-sensibility * (Qd - Qs) / Qs)                              ; ajuste de mark-up
  if Mk < (1.0 + z) [set Mk (1.0 + z)]                                             ; mark-up mínimo
  if Mk > 1.9       [set Mk 1.9      ]                                             ; mark-up máximo
end


to FinancingRegime ; FIRM
  set Rtot (R + AProfit)                                                           ; recursos totais da firma
  set t2 (z * ADebit)                                                              ; juros
  set t3 (ADebit)                                                                  ; dívida
  set ADebit (ADebit + t2)                                                         ; dívida + juros
  if Rtot >= (t2 + t3)               [set AProfit (Rtot - t2 - t3)                 ; Hedge
                                      set J t2                                     ; Hedge
                                      set AM t3                                    ; Hedge
                                      set Class2 1                                 ; Hedge
                                      set color green]                             ; Hedge
  if Rtot >= t2 and Rtot < (t2 + t3) [set AProfit 0.0                              ; Speculative
                                      set J t2                                     ; Speculative
                                      set AM (Rtot - t2)                           ; Speculative
                                      set Class2 2                                 ; Speculative
                                      set color blue]                              ; Speculative
  if Rtot < t2                       [set AProfit 0.0                              ; Ponzi
                                      set J Rtot                                   ; Ponzi
                                      set AM 0.0                                   ; Ponzi
                                      set Class2 3                                 ; Ponzi
                                      set color red]                               ; Ponzi
  set ADebit (ADebit - J - AM)                                                     ; creditar o pagamento de juros e amortização
  if Adebit <= 0.0 [set Adebit 0.0]                                                ; restrição
  set Sd (Sd - AM)                                                                 ; creditar a amortização na dívida
  if  Sd <= 0.0 [set Sd 0.0]                                                       ; restrição
end


to BankBehaviour  ; GLOBAL
  ask firms  [set t2r (t2r + t2)                                                  ; juros esperados na região r
              set t3r (t3r + t3)                                                  ; amortizações esperadas na região r
              set Jr (Jr + J)                                                     ; juros efetivos na região r
              set AMr (AMr + AM)                                                  ; amortizações efetivas na região r
              set Rr (Rr + R)]                                                    ; soma das receitas das firmas locais (capital total local)
              ;set Pmed (Pmed + (t7 / Rr))]                                       ; preço médio LOCAL ponderado (ver definição de t7 em "to Sales")
  ask patches [set r1 (t2r + t3r)                                                  ; juros e amortização esperados
               set r2 (Jr + AMr)                                                   ; juros e amortização efetivos
               ifelse r1 > 0.0 [set Frag1 (r1 - r2) / r1]                          ; rendimentos esperados - rendimentos recebidos / rendimentos esperados
                               [set Frag1 0.0]
               if r1 > 0.0 and Frag1 < 0.05 [set Frag1 0.05]                       ; limite inferior
               set Frag2 (alfa * Frag2 + (1 - alfa) * Frag1)                       ; "média ponderada"
               set Frag3 (0.99 * Frag3 + (1 - 0.99) * Frag1)
               set spread Frag2
               ;ifelse frag2 < 0.05 [set spread 0.05]
               ;                    [set spread Frag2]                                      ; spread
               set z (1.0 + spread) * i                                                     ; juros = spread + juros gov
               Credit-Rationing
               set sigma frag3 ^ 4]                                                         ; taxa desejada de aplicação em títulos
               ;ifelse Frag2 > 0.6 [set sigma 1.0]
                                  ;[set sigma frag3 ^ 0.8]]
  set Kbank (Ktit + Yg + (sum [r2] of patches))                                           ; capital total do banco ao final do período
  set Pmed-H sum [P] of firms with [Class2 = 1] / count firms with [class2 = 1]     ; Preço médio das firmas Hedge
end


to Credit-Rationing
  ifelse Credr > 0.0 [set h ((Jr - Kfail) / Credr) / (Yg / Ktit)]                  ; rendimento líquido do ativo crédito na região r em relação ao rendimento das aplicações em títulos
                     [set h 1.0]                                                   ; se região estiver vazia, h = 1
  set list-MemoH fput h list-MemoH                                                 ; ajustar memória do banco
  set list-MemoH but-last list-MemoH                                               ; ajustar memória do banco
  set g standard-deviation list-MemoH                                              ; desvio-padrão
  if g = 0.0 [set Pbank 1000000 stop]                                              ; implica predisposição a emprestar em regiões vazias
  if h < 0 or Pbank < Pmed-H [set Pbank (Pmed-H / g) stop]
  if h >= 0 and h < 1 [set Pbank Pmed-H]
  if h >= 1 [set Pbank 1000000]
end


to dados  ; GLOBAL
  set g17 sum [AProfit] of firms                                           ; soma dos lucros
  set g4  sum [a] of firms / count firms                                   ; "A" médio
  set g16 standard-deviation [K] of firms                                  ; desvio-padrão dos portes das firmas
  set g18 standard-deviation [P] of firms                                  ; desvio-padrão dos preços das firmas
  set Wealth (Kbank + g17 + sum [S] of patches)   ;print wealth            ; recursos totais da economia
  set spread-med sum [spread * Ybarra] of patches                          ; spread médio inter-regional
  set r9-med sum [r9 * Ybarra] of patches                                  ; indicador de desequilíbrio no mercado de crédito
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
      plot sum [S] of patches


  set-current-plot "Capital X Price"
    clear-plot

    create-temporary-plot-pen "cap_x_price"
    set-plot-pen-mode 2
      ask firms [plotxy K P]


  set-current-plot "Firms"
    create-temporary-plot-pen "qty_firms"
      plot (count firms)


  set-current-plot "Bank Balance-Sheet"
    create-temporary-plot-pen "Ktit"
    set-plot-pen-color green
      plot Ktit

    create-temporary-plot-pen "Cred"
    set-plot-pen-color red
      plot Cred


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


  set-current-plot "Income"
    create-temporary-plot-pen "Y"
    set-plot-pen-color blue
      plot sum [S + sum list-Ex] of patches


  set-current-plot "Tax Revenue"
    create-temporary-plot-pen "Yg"
    set-plot-pen-color red
      plot Yg


  set-current-plot "Spread medio"
    create-temporary-plot-pen "spread_medio"
      plot spread-med


  set-current-plot "r9-med"
    create-temporary-plot-pen "r9_med"
      plot r9-med


  set-current-plot "Regional Income"
    create-temporary-plot-pen "regional_income"
    plot-pen-reset
    set-plot-pen-mode 1
      ask patches [plotxy city Y]


  set-current-plot "Regional Wage"
    create-temporary-plot-pen "regional_wage"
    plot-pen-reset
    set-plot-pen-mode 1
      ask patches [plotxy city W]


  set-current-plot "Regional Firm"
    create-temporary-plot-pen "regional_firm"
    plot-pen-reset
    set-plot-pen-mode 1
      ask patches [plotxy city PopF]


  set-current-plot "Regional Loan"
    create-temporary-plot-pen "regional_loan"
    plot-pen-reset
    set-plot-pen-mode 1
      ask patches [plotxy city Credr]


  set-current-plot "Regional Labor"
    create-temporary-plot-pen "regional_labor"
    plot-pen-reset
    set-plot-pen-mode 1
      ask patches [plotxy city Lrr]


  set-current-plot "Regional spread"
    create-temporary-plot-pen "regional_spread"
    plot-pen-reset
    set-plot-pen-mode 1
      ask patches [plotxy city spread]


  set-current-plot "Regional Finance"
    create-temporary-plot-pen "regional_finance"
    plot-pen-reset

    set-plot-pen-mode 1
    set-plot-pen-color green
      ask patches [plotxy city count turtles-here with [color = blue or color = red or color = green]]

    set-plot-pen-color blue
      ask patches [plotxy city count turtles-here with [color = blue or color = red]]

    set-plot-pen-color red
      ask patches [plotxy city count turtles-here with [color = red]]


  set-current-plot "Tamanho X Spread"
    clear-plot

    create-temporary-plot-pen "tam_x_spread"
    set-plot-pen-mode 2
      ask firms [plotxy ybarra spread]


  set-current-plot "Tamanho X h"
    clear-plot

    create-temporary-plot-pen "tam_x_h"
    set-plot-pen-mode 2
      ask firms [plotxy ybarra h]

;;; dados para exportação ;;;

  if Data-Export = false [stop]

  set-current-plot "emprego"
    create-temporary-plot-pen "b1"
      ask patches with [city = 0] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b2"
      ask patches with [city = 1] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b3"
      ask patches with [city = 2] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b4"
      ask patches with [city = 3] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b5"
      ask patches with [city = 4] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b6"
      ask patches with [city = 5] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b7"
      ask patches with [city = 6] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b8"
      ask patches with [city = 7] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b9"
      ask patches with [city = 8] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b10"
      ask patches with [city = 9] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b11"
      ask patches with [city = 10] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b12"
      ask patches with [city = 11] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b13"
      ask patches with [city = 12] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b14"
      ask patches with [city = 13] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b15"
      ask patches with [city = 14] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b16"
      ask patches with [city = 15] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b17"
      ask patches with [city = 16] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b18"
      ask patches with [city = 17] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b19"
      ask patches with [city = 18] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b20"
      ask patches with [city = 19] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b21"
      ask patches with [city = 20] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b22"
      ask patches with [city = 21] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b23"
      ask patches with [city = 22] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b24"
      ask patches with [city = 23] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b25"
      ask patches with [city = 24] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b26"
      ask patches with [city = 25] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b27"
      ask patches with [city = 26] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b28"
      ask patches with [city = 27] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b29"
      ask patches with [city = 28] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b30"
      ask patches with [city = 29] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b31"
      ask patches with [city = 30] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b32"
      ask patches with [city = 31] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b33"
      ask patches with [city = 32] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b34"
      ask patches with [city = 33] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b35"
      ask patches with [city = 34] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b36"
      ask patches with [city = 35] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b37"
      ask patches with [city = 36] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b38"
      ask patches with [city = 37] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b39"
      ask patches with [city = 38] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b40"
      ask patches with [city = 39] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b41"
      ask patches with [city = 40] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b42"
      ask patches with [city = 41] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b43"
      ask patches with [city = 42] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b44"
      ask patches with [city = 43] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b45"
      ask patches with [city = 44] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b46"
      ask patches with [city = 45] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b47"
      ask patches with [city = 46] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b48"
      ask patches with [city = 47] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b49"
      ask patches with [city = 48] [set b1 lrr]
      plot b1

    create-temporary-plot-pen "b50"
      ask patches with [city = 49] [set b1 lrr]
      plot b1


  set-current-plot "spread"
    create-temporary-plot-pen "b1"
      ask patches with [city = 0] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b2"
      ask patches with [city = 1] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b3"
      ask patches with [city = 2] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b4"
      ask patches with [city = 3] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b5"
      ask patches with [city = 4] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b6"
      ask patches with [city = 5] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b7"
      ask patches with [city = 6] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b8"
      ask patches with [city = 7] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b9"
      ask patches with [city = 8] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b10"
      ask patches with [city = 9] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b11"
      ask patches with [city = 10] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b12"
      ask patches with [city = 11] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b13"
      ask patches with [city = 12] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b14"
      ask patches with [city = 13] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b15"
      ask patches with [city = 14] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b16"
      ask patches with [city = 15] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b17"
      ask patches with [city = 16] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b18"
      ask patches with [city = 17] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b19"
      ask patches with [city = 18] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b20"
      ask patches with [city = 19] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b21"
      ask patches with [city = 20] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b22"
      ask patches with [city = 21] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b23"
      ask patches with [city = 22] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b24"
      ask patches with [city = 23] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b25"
      ask patches with [city = 24] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b26"
      ask patches with [city = 25] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b27"
      ask patches with [city = 26] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b28"
      ask patches with [city = 27] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b29"
      ask patches with [city = 28] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b30"
      ask patches with [city = 29] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b31"
      ask patches with [city = 30] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b32"
      ask patches with [city = 31] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b33"
      ask patches with [city = 32] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b34"
      ask patches with [city = 33] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b35"
      ask patches with [city = 34] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b36"
      ask patches with [city = 35] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b37"
      ask patches with [city = 36] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b38"
      ask patches with [city = 37] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b39"
      ask patches with [city = 38] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b40"
      ask patches with [city = 39] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b41"
      ask patches with [city = 40] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b42"
      ask patches with [city = 41] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b43"
      ask patches with [city = 42] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b44"
      ask patches with [city = 43] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b45"
      ask patches with [city = 44] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b46"
      ask patches with [city = 45] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b47"
      ask patches with [city = 46] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b48"
      ask patches with [city = 47] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b49"
      ask patches with [city = 48] [set b1 spread]
      plot b1

    create-temporary-plot-pen "b50"
      ask patches with [city = 49] [set b1 spread]
      plot b1


  set-current-plot "salario"
    create-temporary-plot-pen "b1"
      ask patches with [city = 0] [set b1 w]
      plot b1

    create-temporary-plot-pen "b2"
      ask patches with [city = 1] [set b1 w]
      plot b1

    create-temporary-plot-pen "b3"
      ask patches with [city = 2] [set b1 w]
      plot b1

    create-temporary-plot-pen "b4"
      ask patches with [city = 3] [set b1 w]
      plot b1

    create-temporary-plot-pen "b5"
      ask patches with [city = 4] [set b1 w]
      plot b1

    create-temporary-plot-pen "b6"
      ask patches with [city = 5] [set b1 w]
      plot b1

    create-temporary-plot-pen "b7"
      ask patches with [city = 6] [set b1 w]
      plot b1

    create-temporary-plot-pen "b8"
      ask patches with [city = 7] [set b1 w]
      plot b1

    create-temporary-plot-pen "b9"
      ask patches with [city = 8] [set b1 w]
      plot b1

    create-temporary-plot-pen "b10"
      ask patches with [city = 9] [set b1 w]
      plot b1

    create-temporary-plot-pen "b11"
      ask patches with [city = 10] [set b1 w]
      plot b1

    create-temporary-plot-pen "b12"
      ask patches with [city = 11] [set b1 w]
      plot b1

    create-temporary-plot-pen "b13"
      ask patches with [city = 12] [set b1 w]
      plot b1

    create-temporary-plot-pen "b14"
      ask patches with [city = 13] [set b1 w]
      plot b1

    create-temporary-plot-pen "b15"
      ask patches with [city = 14] [set b1 w]
      plot b1

    create-temporary-plot-pen "b16"
      ask patches with [city = 15] [set b1 w]
      plot b1

    create-temporary-plot-pen "b17"
      ask patches with [city = 16] [set b1 w]
      plot b1

    create-temporary-plot-pen "b18"
      ask patches with [city = 17] [set b1 w]
      plot b1

    create-temporary-plot-pen "b19"
      ask patches with [city = 18] [set b1 w]
      plot b1

    create-temporary-plot-pen "b20"
      ask patches with [city = 19] [set b1 w]
      plot b1

    create-temporary-plot-pen "b21"
      ask patches with [city = 20] [set b1 w]
      plot b1

    create-temporary-plot-pen "b22"
      ask patches with [city = 21] [set b1 w]
      plot b1

    create-temporary-plot-pen "b23"
      ask patches with [city = 22] [set b1 w]
      plot b1

    create-temporary-plot-pen "b24"
      ask patches with [city = 23] [set b1 w]
      plot b1

    create-temporary-plot-pen "b25"
      ask patches with [city = 24] [set b1 w]
      plot b1

    create-temporary-plot-pen "b26"
      ask patches with [city = 25] [set b1 w]
      plot b1

    create-temporary-plot-pen "b27"
      ask patches with [city = 26] [set b1 w]
      plot b1

    create-temporary-plot-pen "b28"
      ask patches with [city = 27] [set b1 w]
      plot b1

    create-temporary-plot-pen "b29"
      ask patches with [city = 28] [set b1 w]
      plot b1

    create-temporary-plot-pen "b30"
      ask patches with [city = 29] [set b1 w]
      plot b1

    create-temporary-plot-pen "b31"
      ask patches with [city = 30] [set b1 w]
      plot b1

    create-temporary-plot-pen "b32"
      ask patches with [city = 31] [set b1 w]
      plot b1

    create-temporary-plot-pen "b33"
      ask patches with [city = 32] [set b1 w]
      plot b1

    create-temporary-plot-pen "b34"
      ask patches with [city = 33] [set b1 w]
      plot b1

    create-temporary-plot-pen "b35"
      ask patches with [city = 34] [set b1 w]
      plot b1

    create-temporary-plot-pen "b36"
      ask patches with [city = 35] [set b1 w]
      plot b1

    create-temporary-plot-pen "b37"
      ask patches with [city = 36] [set b1 w]
      plot b1

    create-temporary-plot-pen "b38"
      ask patches with [city = 37] [set b1 w]
      plot b1

    create-temporary-plot-pen "b39"
      ask patches with [city = 38] [set b1 w]
      plot b1

    create-temporary-plot-pen "b40"
      ask patches with [city = 39] [set b1 w]
      plot b1

    create-temporary-plot-pen "b41"
      ask patches with [city = 40] [set b1 w]
      plot b1

    create-temporary-plot-pen "b42"
      ask patches with [city = 41] [set b1 w]
      plot b1

    create-temporary-plot-pen "b43"
      ask patches with [city = 42] [set b1 w]
      plot b1

    create-temporary-plot-pen "b44"
      ask patches with [city = 43] [set b1 w]
      plot b1

    create-temporary-plot-pen "b45"
      ask patches with [city = 44] [set b1 w]
      plot b1

    create-temporary-plot-pen "b46"
      ask patches with [city = 45] [set b1 w]
      plot b1

    create-temporary-plot-pen "b47"
      ask patches with [city = 46] [set b1 w]
      plot b1

    create-temporary-plot-pen "b48"
      ask patches with [city = 47] [set b1 w]
      plot b1

    create-temporary-plot-pen "b49"
      ask patches with [city = 48] [set b1 w]
      plot b1

    create-temporary-plot-pen "b50"
      ask patches with [city = 49] [set b1 w]
      plot b1
end
@#$#@#$#@
GRAPHICS-WINDOW
7
22
986
50
-1
-1
19.42
1
10
1
1
1
0
0
0
1
0
49
0
0
0
0
1
ticks
30.0

SLIDER
5
452
207
485
Acoef
Acoef
0
1.0
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
5
412
208
445
Asymmetry
Asymmetry
0
1.0
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
6
491
207
524
Tcoef
Tcoef
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
6
530
207
563
Fcoef
Fcoef
0
10
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
7
141
208
174
History
History
0
2000
320.0
1
1
NIL
HORIZONTAL

SLIDER
7
590
207
623
i
i
0.0
0.02
0.01
0.0020
1
NIL
HORIZONTAL

SLIDER
7
628
207
661
alfa
alfa
0.9
1.0
0.99
0.01
1
NIL
HORIZONTAL

SLIDER
7
667
207
700
memo
memo
0
3
0.0
1
1
NIL
HORIZONTAL

SLIDER
5
771
207
804
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
6
266
207
299
Tc
Tc
0.0
0.1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
5
732
207
765
Dem-sensibility
Dem-sensibility
0
0.1
0.004
0.0010
1
NIL
HORIZONTAL

SLIDER
6
305
208
338
Entry-Y-sensibility
Entry-Y-sensibility
0
0.0050
0.001
0.0010
1
NIL
HORIZONTAL

SWITCH
113
103
207
136
Break
Break
1
1
-1000

SWITCH
6
809
207
842
ExpHomogenea
ExpHomogenea
0
1
-1000

SWITCH
7
847
207
880
FlexExpectation
FlexExpectation
0
1
-1000

SWITCH
7
887
207
920
ProdutoHomogeneo
ProdutoHomogeneo
1
1
-1000

SWITCH
6
102
99
135
Entry?
Entry?
0
1
-1000

SWITCH
55
1452
158
1485
Break
Break
1
1
-1000

SWITCH
6
345
207
378
W-fix
W-fix
1
1
-1000

SWITCH
41
1580
165
1613
Data-Export
Data-Export
1
1
-1000

BUTTON
5
65
99
98
NIL
start
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
113
66
208
99
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

BUTTON
60
1411
150
1444
NIL
Run-World
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
7
180
101
225
Time
ticks
3
1
11

MONITOR
114
181
207
226
NIL
count firms
3
1
11

PLOT
221
692
594
894
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
599
66
972
268
Firms
time
pop
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
600
483
972
683
Inventory and Savings
time
q and $
0.0
10.0
0.0
0.1
true
true
"" ""
PENS

PLOT
601
692
972
895
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
219
277
593
478
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

PLOT
601
276
973
479
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
218
66
591
269
Income
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
221
483
594
685
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
222
900
596
1102
Regional Income
City
$
0.0
50.0
0.0
10.0
true
false
"" ""
PENS

PLOT
600
1109
974
1311
Regional Wage
City
$
0.0
50.0
0.0
2.0
true
false
"" ""
PENS

PLOT
601
1317
975
1519
Regional Loan
City
$
0.0
50.0
0.0
10.0
true
false
"" ""
PENS

PLOT
221
1109
595
1311
Regional Labor
City
L
0.0
50.0
0.0
10.0
true
false
"" ""
PENS

PLOT
600
900
974
1102
Regional Firm
City
Firm
0.0
50.0
0.0
10.0
true
false
"" ""
PENS

PLOT
220
1317
594
1519
Regional Finance
City
H, S & P
0.0
50.0
0.0
10.0
true
false
"" ""
PENS

PLOT
1
930
221
1080
Regional spread
city
z
0.0
50.0
0.0
0.1
true
false
"" ""
PENS

PLOT
2
1080
221
1230
Spread Medio
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
4
1232
222
1382
r9-med
NIL
NIL
0.0
10.0
0.0
2.0
true
false
"" ""
PENS

PLOT
221
1530
421
1680
emprego
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
428
1527
628
1677
spread
NIL
NIL
0.0
10.0
0.0
0.1
true
false
"" ""
PENS

PLOT
637
1527
837
1677
salario
NIL
NIL
0.0
10.0
0.0
2.0
true
false
"" ""
PENS

PLOT
14
1683
389
1930
Tamanho X Spread
NIL
NIL
0.0
0.2
0.0
0.1
true
false
"" ""
PENS

PLOT
405
1684
825
1928
Tamanho X h
NIL
NIL
0.0
0.2
0.0
10.0
true
false
"" ""
PENS

TEXTBOX
70
388
150
406
Technology
12
0.0
1

TEXTBOX
66
571
148
589
Financial Sector
12
0.0
1

TEXTBOX
70
711
138
729
Firm Strategy
12
0.0
1

TEXTBOX
52
246
140
264
Locational Factors
12
0.0
1

@#$#@#$#@
## CREDITS AND REFERENCES

Title: Instabilidade Financeira Regionalizado Netlogo 6.4.0
Author: Iago Rosa & Teófilo de Paula
Date: Nov 2023

Updated from: Instabilidade Financeira Netlogo 3.1.5
(https://gmdesenvolvimento.wixsite.com/grupo/publicacoes)

Reference: DE PAULA, T. H. P.; Crocco. Financiamento e diversidade
produtiva: um modelo baseado em agentes com flutuações cíclicas emergentes.
Revista de Economia Contemporânea (Impresso), v. 17, p. 5-38, 2013

How to cite:
Rosa, I. & De Paula, T. Instabilidade Financeira Netlogo 6.4.0. Grupo de
Pesquisa Moeda e Desenvolvimento
(https://gmdesenvolvimento.wixsite.com/grupo). Instituto Três Rios –
ITR/UFRRJ. Três Rios – RJ, 2023.
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
