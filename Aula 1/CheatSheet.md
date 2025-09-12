# Econometria - Cheat Sheet
Tiago Afonso

-   [Importar dados](#importar-dados)
    -   [csv](#csv)
    -   [excel](#excel)
-   [Estimar modelo](#estimar-modelo)
    -   [Função `lm`](#função-lm)
-   [Testes de diagnóstico](#testes-de-diagnóstico)
    -   [Multicolineariedade](#multicolineariedade)
    -   [Heterocedasticidade](#heterocedasticidade)
    -   [Autocorrelação](#autocorrelação)
    -   [Normalidade dos Resíduos](#normalidade-dos-resíduos)
    -   [Especificação](#especificação)
    -   [Estabilidade](#estabilidade)
    -   [Graficamente](#graficamente)
-   [Comparar modelos](#comparar-modelos)

# Importar dados

## csv

``` r
# Carregar biblioteca
library(readxl)

#importar ficheiro

dados <- read.csv("Nome_do_ficheiro.csv")
```

## excel

``` r
# Carregar biblioteca
library(readxl)

#importar ficheiro

dados <- read_xlsx("Nome_do_ficheiro.xlsx")
```

# Estimar modelo

## Função `lm`

``` r
# Estimar modelo
modelo <- lm(y~x, dados)

#ver resultados
summary(modelo)
```

# Testes de diagnóstico

## Multicolineariedade

#### Teste VIF

``` r
# Carregar biblioteca
library(car)

# Teste VIF
vif(modelo)

#ou
library(performande)
check_collinearity(modelo)
```

#### Matriz das correlações

``` r
cor(dados$x1,dados$x2,dados$x3)
```

#### Matriz das correlações (gráfico)

``` r
cor_matrix <- cor(dados$x1,dados$x2,dados$x3)

library(corrplot)
cor_3 <- corrplot.mixed(cor_matrix)
```

## Heterocedasticidade

``` r
#teste BP
library(skedastic)
breusch_pagan(modelo)

#ou
library(performance)
check_heteroscedasticity(modelo)
```

## Autocorrelação

``` r
library(lmtest)
bftest(modelo)

#ou
library(performance)
check_autocorrelation(modelo)
```

## Normalidade dos Resíduos

``` r
#Shapiro
shapiro.test(m_reg$residuos)

# Jarque Bera
library(moments)
jarque.test(m_reg$residuos)

#OU
library(performance)
check_normality(modelo)
```

## Especificação

``` r
library(lmtest)
resettest(modelo)
```

## Estabilidade

``` r
library(strucchange)
sctest(modelo, type = "CUSUM")
plot(efp(modelo, data = dados, type = "Rec-CUSUM"))
```

## Graficamente

``` r
library(performance)
check_model(modelo, check = "all")
```

# Comparar modelos

``` r
library(performance)
modelo1 <- lm(y ~ x1+x2+x3, 
              data = dados)
modelo2 <- lm(y ~ x1+x2+x3+x4, 
              data = dados)
compare_performance(modelo1, modelo2)
```

