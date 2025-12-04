# Class12 - DFE e DK
Tiago Afonso
2025-12-04

# Goal: Apply DFE and DK iusing R

Dynamic Fixed Effects (DFE) or Panel Autoregressive Distributed Lag
(PARDL) models.

Driscol and Kraay (2000) estimator,

## Load libraries

``` r
library(lfe)
library(lmtest)
library(sandwich)
library(stargazer)
library(tidyverse)
library(plm)
library(readxl)
library(ARDL)
library(broom)
library(car)
```

## Load data

Data from Excel `wdi_class5.xlsx`

``` r
wdi <- read_excel("wdi_class5.xlsx")

# summarise data
wdi %>%
    summary()
```

       country               time           gdp                 gfcf          
     Length:456         Min.   :2000   Min.   :1.398e+10   Min.   :2.555e+09  
     Class :character   1st Qu.:2006   1st Qu.:6.466e+10   1st Qu.:1.230e+10  
     Mode  :character   Median :2012   Median :2.321e+11   Median :5.170e+10  
                        Mean   :2012   Mean   :6.489e+11   Mean   :1.352e+11  
                        3rd Qu.:2017   3rd Qu.:6.983e+11   3rd Qu.:1.404e+11  
                        Max.   :2023   Max.   :3.702e+12   Max.   :7.618e+11  
          pop               trade             agri                ser           
     Min.   :  436300   Min.   : 45.14   Min.   :1.097e+08   Min.   :8.607e+09  
     1st Qu.: 4880378   1st Qu.: 69.05   1st Qu.:2.232e+09   1st Qu.:5.103e+10  
     Median :10508278   Median : 92.21   Median :4.689e+09   Median :1.428e+11  
     Mean   :21189549   Mean   :114.25   Mean   :1.027e+10   Mean   :4.204e+11  
     3rd Qu.:37971253   3rd Qu.:143.34   3rd Qu.:1.277e+10   3rd Qu.:4.696e+11  
     Max.   :83901923   Max.   :412.18   Max.   :3.810e+10   Max.   :2.389e+12  
          ind           
     Min.   :1.966e+09  
     1st Qu.:1.304e+10  
     Median :6.202e+10  
     Mean   :1.477e+11  
     3rd Qu.:1.493e+11  
     Max.   :9.608e+11  

## Prepare data

**Per capita values** and **LN’s**

``` r
wdi <- wdi |>
    mutate(
        gdp_pc = gdp / pop,
        gfcf_pc = gfcf / pop
    )

# Generate log variables for better interpretation:

wdi <- wdi |>
    mutate(
        log_gdp = log(gdp),
        log_gfcf = log(gfcf),
        log_pop = log(pop),
        log_trade = log(trade),
        log_agri = log(agri),
        log_ser = log(ser),
        log_ind = log(ind),
        log_gdp_pc = log(gdp_pc),
        log_gfcf_pc = log(gfcf_pc)
    )
```

Delare panel data and check panel structure

``` r
pwdi <- pdata.frame(wdi, index = c("country", "time"))

# check panel structure
pdim(pwdi)
```

    Balanced Panel: n = 19, T = 24, N = 456

## Estimate Pooled OLS \| Fixed Effects \| Random Effects

Pooled model with `plm()` function

$$
{log_gdp_pc}_{it} = \beta_0 + \beta_1 {log_gfcf_pc}_{it} + \beta_2 {log_pop}_{it} + \beta_3 {log_trade}_{it} + \beta_4 {log_agri}_{it} + \beta_5 {log_ser}_{it} + \beta_6 {log_ind}_{it} + u_{it}
$$

``` r
# pooled OLS
pooled_ols <- plm(log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser + log_ind, data = pwdi, model = "pooling")
```

Fixed effects model

$$
{log_gdp_pc}_{it} = \alpha_i + \beta_1 {log_gfcf_pc}_{it} + \beta_2 {log_pop}_{it} + \beta_3 {log_trade}_{it} + \beta_4 {log_agri}_{it} + \beta_5 {log_ser}_{it} + \beta_6 {log_ind}_{it} + u_{it}
$$

``` r
# fixed effects
fe <- plm(log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser + log_ind, data = pwdi, model = "within")
```

Random effects model

$$
{log_gdp_pc}_{it} = \beta_0 + \beta_1 {log_gfcf_pc}_{it} + \beta_2 {log_pop}_{it} + \beta_3 {log_trade}_{it} + \beta_4 {log_agri}_{it} + \beta_5 {log_ser}_{it} + \beta_6 {log_ind}_{it} + u_{i} + \epsilon_{it}
$$

``` r
# random effects
re <- plm(log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser + log_ind, data = pwdi, model = "random")
```

Compare all models

    Warning: package 'modelsummary' was built under R version 4.5.2

<table style="width:83%;">
<colgroup>
<col style="width: 19%" />
<col style="width: 18%" />
<col style="width: 22%" />
<col style="width: 23%" />
</colgroup>
<thead>
<tr>
<th></th>
<th>Pooled OLS</th>
<th>Fixed Effects</th>
<th>Random Effects</th>
</tr>
</thead>
<tbody>
<tr>
<td>(Intercept)</td>
<td>1.224***</td>
<td></td>
<td>0.932***</td>
</tr>
<tr>
<td></td>
<td>(0.043)</td>
<td></td>
<td>(0.079)</td>
</tr>
<tr>
<td>log_gfcf_pc</td>
<td>0.027***</td>
<td>0.008</td>
<td>0.025***</td>
</tr>
<tr>
<td></td>
<td>(0.007)</td>
<td>(0.005)</td>
<td>(0.006)</td>
</tr>
<tr>
<td>log_pop</td>
<td>-0.949***</td>
<td>-0.821***</td>
<td>-0.921***</td>
</tr>
<tr>
<td></td>
<td>(0.008)</td>
<td>(0.011)</td>
<td>(0.010)</td>
</tr>
<tr>
<td>log_trade</td>
<td>-0.013**</td>
<td>0.012*</td>
<td>0.024***</td>
</tr>
<tr>
<td></td>
<td>(0.004)</td>
<td>(0.006)</td>
<td>(0.006)</td>
</tr>
<tr>
<td>log_agri</td>
<td>0.003</td>
<td>0.018***</td>
<td>0.002</td>
</tr>
<tr>
<td></td>
<td>(0.003)</td>
<td>(0.004)</td>
<td>(0.005)</td>
</tr>
<tr>
<td>log_ser</td>
<td>0.724***</td>
<td>0.671***</td>
<td>0.677***</td>
</tr>
<tr>
<td></td>
<td>(0.004)</td>
<td>(0.007)</td>
<td>(0.007)</td>
</tr>
<tr>
<td>log_ind</td>
<td>0.213***</td>
<td>0.285***</td>
<td>0.250***</td>
</tr>
<tr>
<td></td>
<td>(0.005)</td>
<td>(0.007)</td>
<td>(0.007)</td>
</tr>
<tr>
<td>Num.Obs.</td>
<td>456</td>
<td>456</td>
<td>456</td>
</tr>
<tr>
<td>R2</td>
<td>0.999</td>
<td>0.995</td>
<td>0.994</td>
</tr>
<tr>
<td>R2 Adj.</td>
<td>0.999</td>
<td>0.995</td>
<td>0.994</td>
</tr>
<tr>
<td>AIC</td>
<td>-2156.2</td>
<td>-2759.7</td>
<td>-2584.9</td>
</tr>
<tr>
<td>BIC</td>
<td>-2123.2</td>
<td>-2730.8</td>
<td>-2551.9</td>
</tr>
<tr>
<td>RMSE</td>
<td>0.02</td>
<td>0.01</td>
<td>0.01</td>
</tr>
</tbody><tfoot>
<tr>
<td colspan="4"><ul>
<li>p &lt; 0.1, * p &lt; 0.05, ** p &lt; 0.01, *** p &lt; 0.001</li>
</ul></td>
</tr>
</tfoot>
&#10;</table>

## RE vs OLS

``` r
# RE vs OLS
plmtest(pooled_ols, type = "bp")
```


        Lagrange Multiplier Test - (Breusch-Pagan)

    data:  log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser +  ...
    chisq = 1443.6, df = 1, p-value < 2.2e-16
    alternative hypothesis: significant effects

H0 is rejected, so RE is preferred over OLS.

## FE vs RE

``` r
# FE vs RE
phtest(fe, re)
```


        Hausman Test

    data:  log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser +  ...
    chisq = 223.25, df = 6, p-value < 2.2e-16
    alternative hypothesis: one model is inconsistent

H0 is rejected, so FE is preferred over RE.

## Robust hausman test

``` r
# alternative hausman test
# Robust Hausman Test (accounting for heteroskedasticity/serial correlation)
phtest(fe, re, vcov = vcovHC)
```


        Hausman Test

    data:  log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser +  ...
    chisq = 223.25, df = 6, p-value < 2.2e-16
    alternative hypothesis: one model is inconsistent

## Munlak test

``` r
# 1. Criar médias das variáveis que variam no tempo
wdi_means <- wdi %>%
    group_by(country) %>%
    mutate(
        mean_log_gfcf_pc = mean(log_gfcf_pc),
        mean_log_pop = mean(log_pop),
        mean_log_trade = mean(log_trade),
        mean_log_agri = mean(log_agri),
        mean_log_ser = mean(log_ser),
        mean_log_ind = mean(log_ind)
    )

# 2. Estimar modelo RE com estas médias adicionadas (Correlated Random Effects)
cre_model <- plm(
    log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser + log_ind +
        mean_log_gfcf_pc + mean_log_pop + mean_log_trade + mean_log_agri + mean_log_ser + mean_log_ind,
    data = wdi_means,
    index = c("country", "time"),
    model = "random"
)

# 3. Testar se as médias são conjuntamente zero (Teste de Wald)
# Se p-value < 0.05, rejeita-se RE (prefere-se FE)
linearHypothesis(cre_model, matchCoefs(cre_model, "mean_"))
```


    Linear hypothesis test:
    mean_log_gfcf_pc = 0
    mean_log_pop = 0
    mean_log_trade = 0
    mean_log_agri = 0
    mean_log_ser = 0
    mean_log_ind = 0

    Model 1: restricted model
    Model 2: log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser + 
        log_ind + mean_log_gfcf_pc + mean_log_pop + mean_log_trade + 
        mean_log_agri + mean_log_ser + mean_log_ind

      Res.Df Df  Chisq Pr(>Chisq)    
    1    449                         
    2    443  6 186.62  < 2.2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

$$
H_0: \text{the is no correlation between the individual effects and the explanatory variables}
$$

$$
H_a: \text{the is a correlation between the individual effects and the explanatory variables}
$$

The null hypothesis is rejected, so FE is preferred over RE.

## Angrist and Newey’s version of Chamberlain test for fixed effects

$$
H_0: \text{the restrictions in the fixed effects model are valid}
$$

$$
H_a: \text{the restrictions in the fixed effects model are not valid}
$$

``` r
#
plm::aneweytest(log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser + log_ind, data = pwdi, index = c("country", "time"))
```


        Angrist and Newey's test of within model

    data:  log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser +     log_ind
    chisq = -2902, df = 3306, p-value = 1
    alternative hypothesis: within specification does not apply

The null hypothesis is not rejected, so strict exogeneity is valid.

## Specification tests

Wooldridge test for serial correlation in panel models

``` r
pbgtest(fe)
```


        Breusch-Godfrey/Wooldridge test for serial correlation in panel models

    data:  log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser +  ...
    chisq = 258.52, df = 24, p-value < 2.2e-16
    alternative hypothesis: serial correlation in idiosyncratic errors

Modified BNF–Durbin–Watson Test and Baltagi–Wu’s LBI Test for Panel
Models

H0: No serial correlation

``` r
pbnftest(fe)
```


        Bhargava/Franzini/Narendranathan Panel Durbin-Watson Test

    data:  log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser +  ...
    DW = 0.49024
    alternative hypothesis: serial correlation in idiosyncratic errors

Durbin–Watson Test for Panel Models

``` r
pdwtest(fe)
```


        Durbin-Watson test for serial correlation in panel models

    data:  log_gdp_pc ~ log_gfcf_pc + log_pop + log_trade + log_agri + log_ser +  ...
    DW = 0.55739, p-value < 2.2e-16
    alternative hypothesis: serial correlation in idiosyncratic errors

H0: No serial correlation

Heteroskedasticity test

``` r
bptest(fe)
```


        studentized Breusch-Pagan test

    data:  fe
    BP = 61.031, df = 6, p-value = 2.778e-11

H0: Homoskedasticity

# Estimate Robust standard errors

``` r
coeftest(fe, vcov = function(x) plm::vcovHC(x, method = "arellano", type = "HC1"))
```


    t test of coefficients:

                  Estimate Std. Error  t value Pr(>|t|)    
    log_gfcf_pc  0.0080881  0.0091136   0.8875  0.37532    
    log_pop     -0.8208460  0.0298243 -27.5227  < 2e-16 ***
    log_trade    0.0123994  0.0081266   1.5258  0.12779    
    log_agri     0.0176554  0.0097446   1.8118  0.07071 .  
    log_ser      0.6714460  0.0192720  34.8405  < 2e-16 ***
    log_ind      0.2845460  0.0218733  13.0089  < 2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Compare with the original summary of the Fixed Effects model:

<table style="width:69%;">
<colgroup>
<col style="width: 19%" />
<col style="width: 26%" />
<col style="width: 23%" />
</colgroup>
<thead>
<tr>
<th></th>
<th>FE (Standard SE)</th>
<th>FE (Robust SE)</th>
</tr>
</thead>
<tbody>
<tr>
<td>log_gfcf_pc</td>
<td>0.008</td>
<td>0.008</td>
</tr>
<tr>
<td></td>
<td>(0.005)</td>
<td>(0.009)</td>
</tr>
<tr>
<td>log_pop</td>
<td>-0.821***</td>
<td>-0.821***</td>
</tr>
<tr>
<td></td>
<td>(0.011)</td>
<td>(0.030)</td>
</tr>
<tr>
<td>log_trade</td>
<td>0.012*</td>
<td>0.012</td>
</tr>
<tr>
<td></td>
<td>(0.006)</td>
<td>(0.008)</td>
</tr>
<tr>
<td>log_agri</td>
<td>0.018***</td>
<td>0.018+</td>
</tr>
<tr>
<td></td>
<td>(0.004)</td>
<td>(0.010)</td>
</tr>
<tr>
<td>log_ser</td>
<td>0.671***</td>
<td>0.671***</td>
</tr>
<tr>
<td></td>
<td>(0.007)</td>
<td>(0.019)</td>
</tr>
<tr>
<td>log_ind</td>
<td>0.285***</td>
<td>0.285***</td>
</tr>
<tr>
<td></td>
<td>(0.007)</td>
<td>(0.022)</td>
</tr>
<tr>
<td>Num.Obs.</td>
<td>456</td>
<td>456</td>
</tr>
<tr>
<td>R2</td>
<td>0.995</td>
<td>0.995</td>
</tr>
<tr>
<td>R2 Adj.</td>
<td>0.995</td>
<td>0.995</td>
</tr>
<tr>
<td>AIC</td>
<td>-2759.7</td>
<td>-2759.7</td>
</tr>
<tr>
<td>BIC</td>
<td>-2730.8</td>
<td>-2730.8</td>
</tr>
<tr>
<td>RMSE</td>
<td>0.01</td>
<td>0.01</td>
</tr>
<tr>
<td>Std.Errors</td>
<td></td>
<td>Custom</td>
</tr>
</tbody><tfoot>
<tr>
<td colspan="3"><ul>
<li>p &lt; 0.1, * p &lt; 0.05, ** p &lt; 0.01, *** p &lt; 0.001</li>
</ul></td>
</tr>
</tfoot>
&#10;</table>

Test conteporaneous correlation CD test

``` r
#|
pcdtest(fe, test = "cd")
pcdtest(fe, test = "lm")
pcdtest(fe, test = "sclm")
pcdtest(fe, test = "bcsclm")
```

all results

<div id="qprgpfsztx" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#qprgpfsztx table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#qprgpfsztx thead, #qprgpfsztx tbody, #qprgpfsztx tfoot, #qprgpfsztx tr, #qprgpfsztx td, #qprgpfsztx th {
  border-style: none;
}
&#10;#qprgpfsztx p {
  margin: 0;
  padding: 0;
}
&#10;#qprgpfsztx .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#qprgpfsztx .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#qprgpfsztx .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#qprgpfsztx .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#qprgpfsztx .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#qprgpfsztx .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#qprgpfsztx .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#qprgpfsztx .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#qprgpfsztx .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#qprgpfsztx .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#qprgpfsztx .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#qprgpfsztx .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#qprgpfsztx .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#qprgpfsztx .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#qprgpfsztx .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qprgpfsztx .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#qprgpfsztx .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#qprgpfsztx .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#qprgpfsztx .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qprgpfsztx .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#qprgpfsztx .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qprgpfsztx .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#qprgpfsztx .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qprgpfsztx .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#qprgpfsztx .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qprgpfsztx .gt_left {
  text-align: left;
}
&#10;#qprgpfsztx .gt_center {
  text-align: center;
}
&#10;#qprgpfsztx .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#qprgpfsztx .gt_font_normal {
  font-weight: normal;
}
&#10;#qprgpfsztx .gt_font_bold {
  font-weight: bold;
}
&#10;#qprgpfsztx .gt_font_italic {
  font-style: italic;
}
&#10;#qprgpfsztx .gt_super {
  font-size: 65%;
}
&#10;#qprgpfsztx .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#qprgpfsztx .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#qprgpfsztx .gt_indent_1 {
  text-indent: 5px;
}
&#10;#qprgpfsztx .gt_indent_2 {
  text-indent: 10px;
}
&#10;#qprgpfsztx .gt_indent_3 {
  text-indent: 15px;
}
&#10;#qprgpfsztx .gt_indent_4 {
  text-indent: 20px;
}
&#10;#qprgpfsztx .gt_indent_5 {
  text-indent: 25px;
}
&#10;#qprgpfsztx .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#qprgpfsztx div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>

| Cross-Section Dependence Tests on FE model |           |         |
|--------------------------------------------|-----------|---------|
| Test                                       | Statistic | P-Value |
| cd                                         | 0.0630    | 0.9498  |
| lm                                         | 948.4901  | 0.0000  |
| sclm                                       | 42.0418   | 0.0000  |
| bcsclm                                     | 41.6288   | 0.0000  |

</div>

# Driscoll-Kraay standard errors with pooled OLS

``` r
# Driscoll-Kraay standard errors (Robust to cross-sectional and temporal dependence)
# vcovSCC is the function for Spatial Correlation Consistent covariance matrix
coeftest(pooled_ols, vcov = function(x) vcovSCC(x, type = "HC1", maxlag = 4))
```


    t test of coefficients:

                  Estimate Std. Error  t value  Pr(>|t|)    
    (Intercept)  1.2236551  0.0452382  27.0491 < 2.2e-16 ***
    log_gfcf_pc  0.0271243  0.0146992   1.8453  0.065654 .  
    log_pop     -0.9485278  0.0173332 -54.7233 < 2.2e-16 ***
    log_trade   -0.0130651  0.0042263  -3.0914  0.002116 ** 
    log_agri     0.0032372  0.0031472   1.0286  0.304218    
    log_ser      0.7240940  0.0069188 104.6555 < 2.2e-16 ***
    log_ind      0.2133069  0.0098386  21.6807 < 2.2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

# Driscoll-Kraay standard errors with fe

``` r
# Driscoll-Kraay standard errors (Robust to cross-sectional and temporal dependence)
# vcovSCC is the function for Spatial Correlation Consistent covariance matrix
coeftest(fe, vcov = function(x) vcovSCC(x, type = "HC1", maxlag = 4))
```


    t test of coefficients:

                  Estimate Std. Error  t value Pr(>|t|)    
    log_gfcf_pc  0.0080881  0.0076085   1.0630  0.28836    
    log_pop     -0.8208460  0.0117761 -69.7046  < 2e-16 ***
    log_trade    0.0123994  0.0048556   2.5537  0.01100 *  
    log_agri     0.0176554  0.0073672   2.3965  0.01698 *  
    log_ser      0.6714460  0.0077571  86.5591  < 2e-16 ***
    log_ind      0.2845460  0.0117514  24.2138  < 2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Compare pooled OLS, FE, RE, FE_robust, DK_pooled_ols and DK_fe

<table style="width:96%;">
<colgroup>
<col style="width: 12%" />
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 15%" />
<col style="width: 15%" />
<col style="width: 16%" />
<col style="width: 10%" />
</colgroup>
<thead>
<tr>
<th></th>
<th>Pooled OLS</th>
<th>Fixed Effects</th>
<th>Random Effects</th>
<th>FE (Robust SE)</th>
<th>DK (Pooled OLS)</th>
<th>DK (FE)</th>
</tr>
</thead>
<tbody>
<tr>
<td>(Intercept)</td>
<td>1.224***</td>
<td></td>
<td>0.932***</td>
<td></td>
<td>1.224***</td>
<td></td>
</tr>
<tr>
<td></td>
<td>(0.043)</td>
<td></td>
<td>(0.079)</td>
<td></td>
<td>(0.045)</td>
<td></td>
</tr>
<tr>
<td>log_gfcf_pc</td>
<td>0.027***</td>
<td>0.008</td>
<td>0.025***</td>
<td>0.008</td>
<td>0.027+</td>
<td>0.008</td>
</tr>
<tr>
<td></td>
<td>(0.007)</td>
<td>(0.005)</td>
<td>(0.006)</td>
<td>(0.009)</td>
<td>(0.015)</td>
<td>(0.008)</td>
</tr>
<tr>
<td>log_pop</td>
<td>-0.949***</td>
<td>-0.821***</td>
<td>-0.921***</td>
<td>-0.821***</td>
<td>-0.949***</td>
<td>-0.821***</td>
</tr>
<tr>
<td></td>
<td>(0.008)</td>
<td>(0.011)</td>
<td>(0.010)</td>
<td>(0.030)</td>
<td>(0.017)</td>
<td>(0.012)</td>
</tr>
<tr>
<td>log_trade</td>
<td>-0.013**</td>
<td>0.012*</td>
<td>0.024***</td>
<td>0.012</td>
<td>-0.013**</td>
<td>0.012*</td>
</tr>
<tr>
<td></td>
<td>(0.004)</td>
<td>(0.006)</td>
<td>(0.006)</td>
<td>(0.008)</td>
<td>(0.004)</td>
<td>(0.005)</td>
</tr>
<tr>
<td>log_agri</td>
<td>0.003</td>
<td>0.018***</td>
<td>0.002</td>
<td>0.018+</td>
<td>0.003</td>
<td>0.018*</td>
</tr>
<tr>
<td></td>
<td>(0.003)</td>
<td>(0.004)</td>
<td>(0.005)</td>
<td>(0.010)</td>
<td>(0.003)</td>
<td>(0.007)</td>
</tr>
<tr>
<td>log_ser</td>
<td>0.724***</td>
<td>0.671***</td>
<td>0.677***</td>
<td>0.671***</td>
<td>0.724***</td>
<td>0.671***</td>
</tr>
<tr>
<td></td>
<td>(0.004)</td>
<td>(0.007)</td>
<td>(0.007)</td>
<td>(0.019)</td>
<td>(0.007)</td>
<td>(0.008)</td>
</tr>
<tr>
<td>log_ind</td>
<td>0.213***</td>
<td>0.285***</td>
<td>0.250***</td>
<td>0.285***</td>
<td>0.213***</td>
<td>0.285***</td>
</tr>
<tr>
<td></td>
<td>(0.005)</td>
<td>(0.007)</td>
<td>(0.007)</td>
<td>(0.022)</td>
<td>(0.010)</td>
<td>(0.012)</td>
</tr>
<tr>
<td>Num.Obs.</td>
<td>456</td>
<td>456</td>
<td>456</td>
<td>456</td>
<td>456</td>
<td>456</td>
</tr>
<tr>
<td>R2</td>
<td>0.999</td>
<td>0.995</td>
<td>0.994</td>
<td>0.995</td>
<td>0.999</td>
<td>0.995</td>
</tr>
<tr>
<td>R2 Adj.</td>
<td>0.999</td>
<td>0.995</td>
<td>0.994</td>
<td>0.995</td>
<td>0.999</td>
<td>0.995</td>
</tr>
<tr>
<td>AIC</td>
<td>-2156.2</td>
<td>-2759.7</td>
<td>-2584.9</td>
<td>-2759.7</td>
<td>-2156.2</td>
<td>-2759.7</td>
</tr>
<tr>
<td>BIC</td>
<td>-2123.2</td>
<td>-2730.8</td>
<td>-2551.9</td>
<td>-2730.8</td>
<td>-2123.2</td>
<td>-2730.8</td>
</tr>
<tr>
<td>RMSE</td>
<td>0.02</td>
<td>0.01</td>
<td>0.01</td>
<td>0.01</td>
<td>0.02</td>
<td>0.01</td>
</tr>
<tr>
<td>Std.Errors</td>
<td></td>
<td></td>
<td></td>
<td>Custom</td>
<td>Custom</td>
<td>Custom</td>
</tr>
</tbody><tfoot>
<tr>
<td colspan="7"><ul>
<li>p &lt; 0.1, * p &lt; 0.05, ** p &lt; 0.01, *** p &lt; 0.001</li>
</ul></td>
</tr>
</tfoot>
&#10;</table>

# Dynamic Fixed Effects (DFE)

The Dynamic Fixed Effects (DFE) estimator assumes homogeneity of slope
coefficients (both short-run and long-run) across cross-sections,
allowing only the intercepts to vary. It is estimated using the standard
Fixed Effects (Within) estimator on a dynamic specification (including
lags of the dependent variable).

p-ARDL:

$$
\Delta \ln(gdp_{pc})_{it} = \alpha_i + \sum_{k=1}^{K} \delta_{k}^* \Delta X_{ki,t} + \phi \left( \ln(gdp_{pc})_{i,t-1} - \sum_{k=1}^{K} \theta_k X_{ki,t-1} \right) + \epsilon_{it}
$$

Where: \* $\Delta \ln(gdp_{pc})_{it}$ represents the dependent variable.
\* $\alpha_i$ are the country-specific fixed effects. \* $\delta_{k}^*$
are the short-run coefficients for current and lagged changes in the
independent variables $X_k$ (e.g., $ln_{gfcf_pc}$, $ln_{pop}$, etc.). \*
$\phi$ is the error correction term coefficient, indicating the speed of
adjustment back to long-run equilibrium (expected to be negative). \*
$\left( \ln(gdp_{pc})_{i,t-1} - \sum_{k=1}^{K} \theta_k X_{ki,t-1} \right)$
is the Error Correction Term (ECT), representing the deviation from the
long-run equilibrium in the previous period. \* $\theta_k$ are the
long-run coefficients for the independent variables $X_k$. \*
$\epsilon_{it}$ is the error term.

``` r
# Assuming 'country' and 'time' are your panel identifiers
# Create first differences for the ARDL specification
# Note: We use the variables created earlier: log_gdp_pc, log_gfcf_pc, log_pop, etc.

pwdi$d_log_gdp_pc <- diff(pwdi$log_gdp_pc, lag = 1)
pwdi$d_log_gfcf_pc <- diff(pwdi$log_gfcf_pc, lag = 1)
pwdi$d_log_pop <- diff(pwdi$log_pop, lag = 1)
pwdi$d_log_trade <- diff(pwdi$log_trade, lag = 1)
pwdi$d_log_agri <- diff(pwdi$log_agri, lag = 1)
pwdi$d_log_ser <- diff(pwdi$log_ser, lag = 1)
pwdi$d_log_ind <- diff(pwdi$log_ind, lag = 1)

# Estimate DFE (Dynamic Fixed Effects)
# The equation includes the lagged dependent variable in levels, lagged independent variables in levels (ECT),
# and short-run dynamics (differenced variables).

dfe_model <- plm(
    d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade +
        lag(log_gdp_pc, 1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 1),
    data = pwdi,
    model = "within"
)

summary(dfe_model)
```

    Oneway (individual) effect Within Model

    Call:
    plm(formula = d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade + 
        lag(log_gdp_pc, 1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + 
        lag(log_trade, 1), data = pwdi, model = "within")

    Balanced Panel: n = 19, T = 23, N = 437

    Residuals:
         Min.   1st Qu.    Median   3rd Qu.      Max. 
    -0.134446 -0.009121  0.001769  0.010796  0.197558 

    Coefficients:
                         Estimate Std. Error t-value  Pr(>|t|)    
    d_log_gfcf_pc        0.189784   0.013095 14.4928 < 2.2e-16 ***
    d_log_pop           -0.956076   0.293759 -3.2546  0.001229 ** 
    d_log_trade          0.175182   0.019152  9.1472 < 2.2e-16 ***
    lag(log_gdp_pc, 1)  -0.197891   0.020883 -9.4762 < 2.2e-16 ***
    lag(log_gfcf_pc, 1)  0.098548   0.011176  8.8175 < 2.2e-16 ***
    lag(log_pop, 1)     -0.071673   0.023855 -3.0045  0.002823 ** 
    lag(log_trade, 1)    0.080564   0.013764  5.8533 9.863e-09 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

    Total Sum of Squares:    0.58226
    Residual Sum of Squares: 0.26446
    R-Squared:      0.5458
    Adj. R-Squared: 0.51817
    F-statistic: 70.5559 on 7 and 411 DF, p-value: < 2.22e-16

## DFE with Driscoll-Kraay Standard Errors

Since DFE is just a FE model with lags, we can also apply Driscoll-Kraay
standard errors to it.

``` r
dfe_model <- plm(
    d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade + d_log_agri + d_log_ser + d_log_ind +
        lag(log_gdp_pc, 1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 1) +
        lag(log_agri, 1) + lag(log_ser, 1) + lag(log_ind, 1),
    data = pwdi,
    model = "within"
)
```

With Driscoll-Kraay standard errors

``` r
coeftest(dfe_model, vcov = function(x) vcovSCC(x, type = "HC1", maxlag = 4))
```

Compare DFE and DFE with Driscoll-Kraay Standard Errors

<table style="width:94%;">
<colgroup>
<col style="width: 30%" />
<col style="width: 27%" />
<col style="width: 36%" />
</colgroup>
<thead>
<tr>
<th></th>
<th>DFE (Standard SE)</th>
<th>DFE (Driscoll-Kraay SE)</th>
</tr>
</thead>
<tbody>
<tr>
<td>d_log_gfcf_pc</td>
<td>0.011*</td>
<td>0.011</td>
</tr>
<tr>
<td></td>
<td>(0.005)</td>
<td>(0.015)</td>
</tr>
<tr>
<td>d_log_pop</td>
<td>-1.058***</td>
<td>-1.058***</td>
</tr>
<tr>
<td></td>
<td>(0.092)</td>
<td>(0.082)</td>
</tr>
<tr>
<td>d_log_trade</td>
<td>0.018**</td>
<td>0.018***</td>
</tr>
<tr>
<td></td>
<td>(0.007)</td>
<td>(0.005)</td>
</tr>
<tr>
<td>d_log_agri</td>
<td>0.024***</td>
<td>0.024***</td>
</tr>
<tr>
<td></td>
<td>(0.004)</td>
<td>(0.003)</td>
</tr>
<tr>
<td>d_log_ser</td>
<td>0.642***</td>
<td>0.642***</td>
</tr>
<tr>
<td></td>
<td>(0.015)</td>
<td>(0.056)</td>
</tr>
<tr>
<td>d_log_ind</td>
<td>0.273***</td>
<td>0.273***</td>
</tr>
<tr>
<td></td>
<td>(0.008)</td>
<td>(0.014)</td>
</tr>
<tr>
<td>lag(log_gdp_pc, 1)</td>
<td>-0.219***</td>
<td>-0.219***</td>
</tr>
<tr>
<td></td>
<td>(0.033)</td>
<td>(0.040)</td>
</tr>
<tr>
<td>lag(log_gfcf_pc, 1)</td>
<td>0.009*</td>
<td>0.009+</td>
</tr>
<tr>
<td></td>
<td>(0.004)</td>
<td>(0.005)</td>
</tr>
<tr>
<td>lag(log_pop, 1)</td>
<td>-0.183***</td>
<td>-0.183***</td>
</tr>
<tr>
<td></td>
<td>(0.028)</td>
<td>(0.038)</td>
</tr>
<tr>
<td>lag(log_trade, 1)</td>
<td>0.006</td>
<td>0.006</td>
</tr>
<tr>
<td></td>
<td>(0.005)</td>
<td>(0.004)</td>
</tr>
<tr>
<td>lag(log_agri, 1)</td>
<td>0.000</td>
<td>0.000</td>
</tr>
<tr>
<td></td>
<td>(0.003)</td>
<td>(0.005)</td>
</tr>
<tr>
<td>lag(log_ser, 1)</td>
<td>0.143***</td>
<td>0.143***</td>
</tr>
<tr>
<td></td>
<td>(0.023)</td>
<td>(0.031)</td>
</tr>
<tr>
<td>lag(log_ind, 1)</td>
<td>0.055***</td>
<td>0.055***</td>
</tr>
<tr>
<td></td>
<td>(0.011)</td>
<td>(0.010)</td>
</tr>
<tr>
<td>Num.Obs.</td>
<td>437</td>
<td>437</td>
</tr>
<tr>
<td>R2</td>
<td>0.958</td>
<td>0.958</td>
</tr>
<tr>
<td>R2 Adj.</td>
<td>0.955</td>
<td>0.955</td>
</tr>
<tr>
<td>AIC</td>
<td>-3009.5</td>
<td>-3009.5</td>
</tr>
<tr>
<td>BIC</td>
<td>-2952.4</td>
<td>-2952.4</td>
</tr>
<tr>
<td>RMSE</td>
<td>0.01</td>
<td>0.01</td>
</tr>
<tr>
<td>Std.Errors</td>
<td></td>
<td>Custom</td>
</tr>
</tbody><tfoot>
<tr>
<td colspan="3"><ul>
<li>p &lt; 0.1, * p &lt; 0.05, ** p &lt; 0.01, *** p &lt; 0.001</li>
</ul></td>
</tr>
</tfoot>
&#10;</table>

# Estimate PMG, MG and DFE with ARDL approach

Estimate MG with ARDL approach

``` r
mg_ardl <- plm::pmg(
    d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade + d_log_agri + d_log_ser + d_log_ind +
        lag(log_gdp_pc, 1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 1) +
        lag(log_agri, 1) + lag(log_ser, 1) + lag(log_ind, 1),
    data = pwdi,
    model = "mg"
)

summary(mg_ardl)
```

    Mean Groups model

    Call:
    plm::pmg(formula = d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + 
        d_log_trade + d_log_agri + d_log_ser + d_log_ind + lag(log_gdp_pc, 
        1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 
        1) + lag(log_agri, 1) + lag(log_ser, 1) + lag(log_ind, 1), 
        data = pwdi, model = "mg")

    Balanced Panel: n = 19, T = 23, N = 437

    Residuals:
             Min.       1st Qu.        Median       3rd Qu.          Max. 
    -1.493143e-02 -8.142293e-04 -1.171651e-05  8.164548e-04  1.208933e-02 

    Coefficients:
                          Estimate Std. Error z-value  Pr(>|z|)    
    (Intercept)          0.1256456  1.3170092  0.0954 0.9239953    
    d_log_gfcf_pc        0.0208987  0.0058028  3.6015 0.0003164 ***
    d_log_pop           -0.9334954  0.3326574 -2.8062 0.0050133 ** 
    d_log_trade          0.0191482  0.0147598  1.2973 0.1945224    
    d_log_agri           0.0168880  0.0065756  2.5683 0.0102203 *  
    d_log_ser            0.7166012  0.0310313 23.0928 < 2.2e-16 ***
    d_log_ind            0.2293600  0.0150424 15.2476 < 2.2e-16 ***
    lag(log_gdp_pc, 1)  -0.6095323  0.1232756 -4.9445 7.635e-07 ***
    lag(log_gfcf_pc, 1)  0.0155056  0.0083517  1.8566 0.0633717 .  
    lag(log_pop, 1)     -0.5341448  0.1678793 -3.1817 0.0014640 ** 
    lag(log_trade, 1)    0.0043643  0.0123834  0.3524 0.7245150    
    lag(log_agri, 1)     0.0083925  0.0069046  1.2155 0.2241804    
    lag(log_ser, 1)      0.4260041  0.0957153  4.4507 8.557e-06 ***
    lag(log_ind, 1)      0.1328690  0.0336444  3.9492 7.841e-05 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    Total Sum of Squares: 0.67553
    Residual Sum of Squares: 0.0026971
    Multiple R-squared: 0.99601

Estimate PMG with ARDL approach

``` r
pmg_ardl <- plm::pmg(
    d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade + d_log_agri + d_log_ser + d_log_ind +
        lag(log_gdp_pc, 1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 1) +
        lag(log_agri, 1) + lag(log_ser, 1) + lag(log_ind, 1),
    data = pwdi,
    model = "dmg"
)

summary(pmg_ardl)
```

    Demeaned Mean Groups model

    Call:
    plm::pmg(formula = d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + 
        d_log_trade + d_log_agri + d_log_ser + d_log_ind + lag(log_gdp_pc, 
        1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 
        1) + lag(log_agri, 1) + lag(log_ser, 1) + lag(log_ind, 1), 
        data = pwdi, model = "dmg")

    Balanced Panel: n = 19, T = 23, N = 437

    Residuals:
             Min.       1st Qu.        Median       3rd Qu.          Max. 
    -8.470837e-03 -1.231322e-03 -7.210542e-06  1.049648e-03  8.380866e-03 

    Coefficients:
                          Estimate Std. Error  z-value  Pr(>|z|)    
    (Intercept)         -0.0037750  0.0757517  -0.0498 0.9602542    
    d_log_gfcf_pc        0.0266821  0.0075770   3.5215 0.0004292 ***
    d_log_pop           -1.2016685  0.1539727  -7.8044 5.977e-15 ***
    d_log_trade         -0.0100350  0.0135431  -0.7410 0.4587123    
    d_log_agri           0.0103553  0.0072357   1.4311 0.1523890    
    d_log_ser            0.6552233  0.0371147  17.6540 < 2.2e-16 ***
    d_log_ind            0.2272087  0.0188632  12.0451 < 2.2e-16 ***
    lag(log_gdp_pc, 1)  -0.9802899  0.0940522 -10.4228 < 2.2e-16 ***
    lag(log_gfcf_pc, 1)  0.0266635  0.0111512   2.3911 0.0167986 *  
    lag(log_pop, 1)     -0.9614459  0.1088444  -8.8332 < 2.2e-16 ***
    lag(log_trade, 1)    0.0070833  0.0180010   0.3935 0.6939516    
    lag(log_agri, 1)     0.0056633  0.0097285   0.5821 0.5604740    
    lag(log_ser, 1)      0.6255138  0.0700713   8.9268 < 2.2e-16 ***
    lag(log_ind, 1)      0.2283754  0.0367908   6.2074 5.386e-10 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    Total Sum of Squares: 0.67553
    Residual Sum of Squares: 0.0022389
    Multiple R-squared: 0.99669

Compare `mg_ardl`, `pmg_ardl` and `dfe_model`

<div id="kaemuzmbdv" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#kaemuzmbdv table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#kaemuzmbdv thead, #kaemuzmbdv tbody, #kaemuzmbdv tfoot, #kaemuzmbdv tr, #kaemuzmbdv td, #kaemuzmbdv th {
  border-style: none;
}
&#10;#kaemuzmbdv p {
  margin: 0;
  padding: 0;
}
&#10;#kaemuzmbdv .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#kaemuzmbdv .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#kaemuzmbdv .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#kaemuzmbdv .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#kaemuzmbdv .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#kaemuzmbdv .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#kaemuzmbdv .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#kaemuzmbdv .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#kaemuzmbdv .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#kaemuzmbdv .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#kaemuzmbdv .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#kaemuzmbdv .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#kaemuzmbdv .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#kaemuzmbdv .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#kaemuzmbdv .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kaemuzmbdv .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#kaemuzmbdv .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#kaemuzmbdv .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#kaemuzmbdv .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kaemuzmbdv .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#kaemuzmbdv .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kaemuzmbdv .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#kaemuzmbdv .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kaemuzmbdv .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#kaemuzmbdv .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#kaemuzmbdv .gt_left {
  text-align: left;
}
&#10;#kaemuzmbdv .gt_center {
  text-align: center;
}
&#10;#kaemuzmbdv .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#kaemuzmbdv .gt_font_normal {
  font-weight: normal;
}
&#10;#kaemuzmbdv .gt_font_bold {
  font-weight: bold;
}
&#10;#kaemuzmbdv .gt_font_italic {
  font-style: italic;
}
&#10;#kaemuzmbdv .gt_super {
  font-size: 65%;
}
&#10;#kaemuzmbdv .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#kaemuzmbdv .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#kaemuzmbdv .gt_indent_1 {
  text-indent: 5px;
}
&#10;#kaemuzmbdv .gt_indent_2 {
  text-indent: 10px;
}
&#10;#kaemuzmbdv .gt_indent_3 {
  text-indent: 15px;
}
&#10;#kaemuzmbdv .gt_indent_4 {
  text-indent: 20px;
}
&#10;#kaemuzmbdv .gt_indent_5 {
  text-indent: 25px;
}
&#10;#kaemuzmbdv .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#kaemuzmbdv div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>

<table class="gt_table" style="width:100%;"
data-quarto-postprocess="true" data-quarto-disable-processing="false"
data-quarto-bootstrap="false">
<colgroup>
<col style="width: 10%" />
<col style="width: 10%" />
<col style="width: 10%" />
<col style="width: 10%" />
<col style="width: 10%" />
<col style="width: 10%" />
<col style="width: 10%" />
<col style="width: 10%" />
<col style="width: 10%" />
<col style="width: 10%" />
</colgroup>
<thead>
<tr class="gt_col_headings gt_spanner_row">
<th rowspan="2" id="label"
class="gt_col_heading gt_columns_bottom_border gt_left"
data-quarto-table-cell-role="th"
scope="col"><strong>Characteristic</strong></th>
<th colspan="3" id="level 1; estimate_1"
class="gt_center gt_columns_top_border gt_column_spanner_outer"
data-quarto-table-cell-role="th" scope="colgroup"><div
class="gt_column_spanner">
<strong>MG (ARDL)</strong>
</div></th>
<th colspan="3" id="level 1; estimate_2"
class="gt_center gt_columns_top_border gt_column_spanner_outer"
data-quarto-table-cell-role="th" scope="colgroup"><div
class="gt_column_spanner">
<strong>PMG (ARDL)</strong>
</div></th>
<th colspan="3" id="level 1; estimate_3"
class="gt_center gt_columns_top_border gt_column_spanner_outer"
data-quarto-table-cell-role="th" scope="colgroup"><div
class="gt_column_spanner">
<strong>DFE</strong>
</div></th>
</tr>
<tr class="gt_col_headings">
<th id="estimate_1"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th" scope="col"><strong>Beta</strong></th>
<th id="conf.low_1"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th" scope="col"><strong>95%
CI</strong></th>
<th id="p.value_1"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th"
scope="col"><strong>p-value</strong></th>
<th id="estimate_2"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th" scope="col"><strong>Beta</strong></th>
<th id="conf.low_2"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th" scope="col"><strong>95%
CI</strong></th>
<th id="p.value_2"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th"
scope="col"><strong>p-value</strong></th>
<th id="estimate_3"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th" scope="col"><strong>Beta</strong></th>
<th id="conf.low_3"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th" scope="col"><strong>95%
CI</strong></th>
<th id="p.value_3"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th"
scope="col"><strong>p-value</strong></th>
</tr>
</thead>
<tbody class="gt_table_body">
<tr>
<td class="gt_row gt_left" headers="label">d_log_gfcf_pc</td>
<td class="gt_row gt_center" headers="estimate_1">0.02</td>
<td class="gt_row gt_center" headers="conf.low_1">0.01, 0.03</td>
<td class="gt_row gt_center" headers="p.value_1">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_2">0.03</td>
<td class="gt_row gt_center" headers="conf.low_2">0.01, 0.04</td>
<td class="gt_row gt_center" headers="p.value_2">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_3">0.01</td>
<td class="gt_row gt_center" headers="conf.low_3">0.00, 0.02</td>
<td class="gt_row gt_center" headers="p.value_3">0.022</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">d_log_pop</td>
<td class="gt_row gt_center" headers="estimate_1">-0.93</td>
<td class="gt_row gt_center" headers="conf.low_1">-1.6, -0.28</td>
<td class="gt_row gt_center" headers="p.value_1">0.005</td>
<td class="gt_row gt_center" headers="estimate_2">-1.2</td>
<td class="gt_row gt_center" headers="conf.low_2">-1.5, -0.90</td>
<td class="gt_row gt_center" headers="p.value_2">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_3">-1.1</td>
<td class="gt_row gt_center" headers="conf.low_3">-1.2, -0.88</td>
<td class="gt_row gt_center" headers="p.value_3">&lt;0.001</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">d_log_trade</td>
<td class="gt_row gt_center" headers="estimate_1">0.02</td>
<td class="gt_row gt_center" headers="conf.low_1">-0.01, 0.05</td>
<td class="gt_row gt_center" headers="p.value_1">0.2</td>
<td class="gt_row gt_center" headers="estimate_2">-0.01</td>
<td class="gt_row gt_center" headers="conf.low_2">-0.04, 0.02</td>
<td class="gt_row gt_center" headers="p.value_2">0.5</td>
<td class="gt_row gt_center" headers="estimate_3">0.02</td>
<td class="gt_row gt_center" headers="conf.low_3">0.01, 0.03</td>
<td class="gt_row gt_center" headers="p.value_3">0.006</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">d_log_agri</td>
<td class="gt_row gt_center" headers="estimate_1">0.02</td>
<td class="gt_row gt_center" headers="conf.low_1">0.00, 0.03</td>
<td class="gt_row gt_center" headers="p.value_1">0.011</td>
<td class="gt_row gt_center" headers="estimate_2">0.01</td>
<td class="gt_row gt_center" headers="conf.low_2">0.00, 0.02</td>
<td class="gt_row gt_center" headers="p.value_2">0.2</td>
<td class="gt_row gt_center" headers="estimate_3">0.02</td>
<td class="gt_row gt_center" headers="conf.low_3">0.02, 0.03</td>
<td class="gt_row gt_center" headers="p.value_3">&lt;0.001</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">d_log_ser</td>
<td class="gt_row gt_center" headers="estimate_1">0.72</td>
<td class="gt_row gt_center" headers="conf.low_1">0.66, 0.78</td>
<td class="gt_row gt_center" headers="p.value_1">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_2">0.66</td>
<td class="gt_row gt_center" headers="conf.low_2">0.58, 0.73</td>
<td class="gt_row gt_center" headers="p.value_2">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_3">0.64</td>
<td class="gt_row gt_center" headers="conf.low_3">0.61, 0.67</td>
<td class="gt_row gt_center" headers="p.value_3">&lt;0.001</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">d_log_ind</td>
<td class="gt_row gt_center" headers="estimate_1">0.23</td>
<td class="gt_row gt_center" headers="conf.low_1">0.20, 0.26</td>
<td class="gt_row gt_center" headers="p.value_1">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_2">0.23</td>
<td class="gt_row gt_center" headers="conf.low_2">0.19, 0.26</td>
<td class="gt_row gt_center" headers="p.value_2">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_3">0.27</td>
<td class="gt_row gt_center" headers="conf.low_3">0.26, 0.29</td>
<td class="gt_row gt_center" headers="p.value_3">&lt;0.001</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">lag(log_gdp_pc, 1)</td>
<td class="gt_row gt_center" headers="estimate_1">-0.61</td>
<td class="gt_row gt_center" headers="conf.low_1">-0.85, -0.37</td>
<td class="gt_row gt_center" headers="p.value_1">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_2">-0.98</td>
<td class="gt_row gt_center" headers="conf.low_2">-1.2, -0.80</td>
<td class="gt_row gt_center" headers="p.value_2">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_3">-0.22</td>
<td class="gt_row gt_center" headers="conf.low_3">-0.28, -0.15</td>
<td class="gt_row gt_center" headers="p.value_3">&lt;0.001</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">lag(log_gfcf_pc, 1)</td>
<td class="gt_row gt_center" headers="estimate_1">0.02</td>
<td class="gt_row gt_center" headers="conf.low_1">0.00, 0.03</td>
<td class="gt_row gt_center" headers="p.value_1">0.064</td>
<td class="gt_row gt_center" headers="estimate_2">0.03</td>
<td class="gt_row gt_center" headers="conf.low_2">0.00, 0.05</td>
<td class="gt_row gt_center" headers="p.value_2">0.017</td>
<td class="gt_row gt_center" headers="estimate_3">0.01</td>
<td class="gt_row gt_center" headers="conf.low_3">0.00, 0.02</td>
<td class="gt_row gt_center" headers="p.value_3">0.027</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">lag(log_pop, 1)</td>
<td class="gt_row gt_center" headers="estimate_1">-0.53</td>
<td class="gt_row gt_center" headers="conf.low_1">-0.86, -0.20</td>
<td class="gt_row gt_center" headers="p.value_1">0.002</td>
<td class="gt_row gt_center" headers="estimate_2">-0.96</td>
<td class="gt_row gt_center" headers="conf.low_2">-1.2, -0.75</td>
<td class="gt_row gt_center" headers="p.value_2">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_3">-0.18</td>
<td class="gt_row gt_center" headers="conf.low_3">-0.24, -0.13</td>
<td class="gt_row gt_center" headers="p.value_3">&lt;0.001</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">lag(log_trade, 1)</td>
<td class="gt_row gt_center" headers="estimate_1">0.00</td>
<td class="gt_row gt_center" headers="conf.low_1">-0.02, 0.03</td>
<td class="gt_row gt_center" headers="p.value_1">0.7</td>
<td class="gt_row gt_center" headers="estimate_2">0.01</td>
<td class="gt_row gt_center" headers="conf.low_2">-0.03, 0.04</td>
<td class="gt_row gt_center" headers="p.value_2">0.7</td>
<td class="gt_row gt_center" headers="estimate_3">0.01</td>
<td class="gt_row gt_center" headers="conf.low_3">0.00, 0.01</td>
<td class="gt_row gt_center" headers="p.value_3">0.2</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">lag(log_agri, 1)</td>
<td class="gt_row gt_center" headers="estimate_1">0.01</td>
<td class="gt_row gt_center" headers="conf.low_1">-0.01, 0.02</td>
<td class="gt_row gt_center" headers="p.value_1">0.2</td>
<td class="gt_row gt_center" headers="estimate_2">0.01</td>
<td class="gt_row gt_center" headers="conf.low_2">-0.01, 0.02</td>
<td class="gt_row gt_center" headers="p.value_2">0.6</td>
<td class="gt_row gt_center" headers="estimate_3">0.00</td>
<td class="gt_row gt_center" headers="conf.low_3">-0.01, 0.01</td>
<td class="gt_row gt_center" headers="p.value_3">&gt;0.9</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">lag(log_ser, 1)</td>
<td class="gt_row gt_center" headers="estimate_1">0.43</td>
<td class="gt_row gt_center" headers="conf.low_1">0.24, 0.61</td>
<td class="gt_row gt_center" headers="p.value_1">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_2">0.63</td>
<td class="gt_row gt_center" headers="conf.low_2">0.49, 0.76</td>
<td class="gt_row gt_center" headers="p.value_2">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_3">0.14</td>
<td class="gt_row gt_center" headers="conf.low_3">0.10, 0.19</td>
<td class="gt_row gt_center" headers="p.value_3">&lt;0.001</td>
</tr>
<tr>
<td class="gt_row gt_left" headers="label">lag(log_ind, 1)</td>
<td class="gt_row gt_center" headers="estimate_1">0.13</td>
<td class="gt_row gt_center" headers="conf.low_1">0.07, 0.20</td>
<td class="gt_row gt_center" headers="p.value_1">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_2">0.23</td>
<td class="gt_row gt_center" headers="conf.low_2">0.16, 0.30</td>
<td class="gt_row gt_center" headers="p.value_2">&lt;0.001</td>
<td class="gt_row gt_center" headers="estimate_3">0.06</td>
<td class="gt_row gt_center" headers="conf.low_3">0.03, 0.08</td>
<td class="gt_row gt_center" headers="p.value_3">&lt;0.001</td>
</tr>
</tbody><tfoot>
<tr class="gt_sourcenotes">
<td colspan="10" class="gt_sourcenote">Abbreviation: CI = Confidence
Interval</td>
</tr>
</tfoot>
&#10;</table>

</div>

# Estimate CCEMG

``` r
library(plm)
ccemg_model <- plm::pcce(
    d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade + d_log_agri + d_log_ser + d_log_ind +
        lag(log_gdp_pc, 1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 1) +
        lag(log_agri, 1) + lag(log_ser, 1) + lag(log_ind, 1),
    data = pwdi,
    model = "mg"
)
summary(ccemg_model)
```

    Common Correlated Effects Mean Groups model

    Call:
    plm::pcce(formula = d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + 
        d_log_trade + d_log_agri + d_log_ser + d_log_ind + lag(log_gdp_pc, 
        1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 
        1) + lag(log_agri, 1) + lag(log_ser, 1) + lag(log_ind, 1), 
        data = pwdi, model = "mg")

    Balanced Panel: n = 19, T = 23, N = 437

    Residuals:
             Min.       1st Qu.        Median       3rd Qu.          Max. 
    -1.654773e-07 -1.040725e-09 -4.366273e-11  1.115807e-09  1.650625e-07 

    Coefficients:
                          Estimate Std. Error z-value Pr(>|z|)    
    d_log_gfcf_pc        0.0519977  0.0368404  1.4114  0.15812    
    d_log_pop           -0.0890807  0.0459488 -1.9387  0.05254 .  
    d_log_trade          0.0407041  0.0608645  0.6688  0.50365    
    d_log_agri           0.0227397  0.0226323  1.0047  0.31502    
    d_log_ser            0.3146588  0.0539436  5.8331 5.44e-09 ***
    d_log_ind            0.1265938  0.0568262  2.2277  0.02590 *  
    lag(log_gdp_pc, 1)  -0.0719698  0.0581253 -1.2382  0.21565    
    lag(log_gfcf_pc, 1)  0.0296938  0.0282924  1.0495  0.29393    
    lag(log_pop, 1)     -0.0532270  0.0380276 -1.3997  0.16160    
    lag(log_trade, 1)    0.0294482  0.0472847  0.6228  0.53343    
    lag(log_agri, 1)     0.0016603  0.0277478  0.0598  0.95229    
    lag(log_ser, 1)      0.0436173  0.0258451  1.6876  0.09148 .  
    lag(log_ind, 1)      0.0060668  0.0383625  0.1581  0.87434    
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    Total Sum of Squares: 0.67553
    Residual Sum of Squares: 1.0284e-13
    HPY R-squared: 1

# Estimate augmented Mean Group (AMG)

The AMG estimator is not directly available in plm. A common approach is
to estimate it manually: 1. Run a pooled first-difference regression
with time dummies to extract the common dynamic process. 2. Include this
common dynamic process in individual country regressions and average the
coefficients.

``` r
# Step 1: Estimate pooled first-difference regression with time dummies
time_dummies <- model.matrix(~ factor(pwdi$time) - 1)
pooled_fd <- plm(
    d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade + d_log_agri + d_log_ser + d_log_ind +
        time_dummies,
    data = pwdi,
    model = "pooling"
)

summary(pooled_fd)

# Extract common dynamic process (time effects)
# Get the time dummy coefficients
time_coefs <- coef(pooled_fd)[grep("time_dummies", names(coef(pooled_fd)))]

# Create a mapping from time to the corresponding coefficient
# First, get unique time periods
time_periods <- unique(pwdi$time)

# Create a named vector of time effects (first period is reference = 0)
time_effects <- c(0, time_coefs)
names(time_effects) <- time_periods[1:length(time_effects)]

# Map the common dynamic process to each observation based on its time period
pwdi$common_dynamic_process <- time_effects[as.character(pwdi$time)]

# Estimate individual country regressions including the common dynamic process
individual_models <- pwdi %>%
    group_by(country) %>%
    do(model = lm(
        d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade + d_log_agri + d_log_ser + d_log_ind +
            lag(log_gdp_pc, 1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 1) +
            lag(log_agri, 1) + lag(log_ser, 1) + lag(log_ind, 1) +
            common_dynamic_process,
        data = .
    ))
# Average the coefficients across countries to get AMG estimates
amg_coefficients <- Reduce("+", lapply(individual_models$model, coef)) / nrow(individual_models)
amg_coefficients

# Organize the coefficients into a data frame for better presentation
amg_results <- data.frame(
    Term = names(amg_coefficients),
    Estimate = as.numeric(amg_coefficients)
)
amg_results
```

``` r
# Step 1: Estimate pooled first-difference regression with time dummies
pooled_fd <- plm(
    d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade + d_log_agri + d_log_ser + d_log_ind + factor(time),
    data = pwdi,
    model = "pooling"
)

# Extract time effects (common dynamic process)
time_coefs <- coef(pooled_fd)[grepl("^factor\\(time\\)", names(coef(pooled_fd)))]
time_periods <- sort(unique(as.numeric(as.character(pwdi$time))))
time_effects <- setNames(c(0, time_coefs), time_periods)

# Add common dynamic process to data
pwdi$common_dynamic_process <- time_effects[as.character(pwdi$time)]

# Convert to regular data frame for split-apply
wdi_df <- as.data.frame(pwdi)

# Estimate individual country regressions and extract coefficients
country_coefs <- lapply(split(wdi_df, wdi_df$country), function(df) {
    tryCatch({
        coef(lm(
            d_log_gdp_pc ~ d_log_gfcf_pc + d_log_pop + d_log_trade + d_log_agri + d_log_ser + d_log_ind +
                lag(log_gdp_pc, 1) + lag(log_gfcf_pc, 1) + lag(log_pop, 1) + lag(log_trade, 1) +
                lag(log_agri, 1) + lag(log_ser, 1) + lag(log_ind, 1) + common_dynamic_process,
            data = df, na.action = na.omit
        ))
    }, error = function(e) NULL)
})

# Remove failed estimations and average coefficients
valid_coefs <- Filter(Negate(is.null), country_coefs)
amg_coefficients <- Reduce(`+`, valid_coefs) / length(valid_coefs)

# Present results
amg_results <- data.frame(
    Term = names(amg_coefficients),
    Estimate = as.numeric(amg_coefficients),
    row.names = NULL
)
amg_results
```
