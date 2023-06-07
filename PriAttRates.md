Analysis of Myanmar Census 2014
================
UNICEF Myanmar, SPCRM
2023-06-07

# Overview

This analysis is based on the *township level* information data of
Myanmar Census 2014.We are interested in examining the differece of
school attendance rates between the children with *no disability* and
their counterparts with *severe disability*.

Using the **REDATAM** that is designed to extract data from Census, we
constructed two data sets at township level, each representing the
primary school attendance rates of our groups of interest (normal
vs. severe) disability).

State/Region aggregates are calculated.The results are visualized for
comparing the situations of the groups.

All datasets produced in our analytical project can be found on the
Github repository.We also provided a couple of R-script documents that
we used during the process for data arrangement and analyses.
*<https://github.com/AungLwin25/Disability>*

Paritcular thanks to our colleagues, Bjorn Gelders for formulating the
framework of analysis, and Aung Lwin for kniting algorithms, wrangling
data, computing statistics, and producing visuals. — UNICEF Myanmar,
SPCRM

\`\`\`{r setup, include=FALSE, echo=FALSE} library(readxl)
library(haven) library(kableExtra) library(dplyr) library(tidyverse)
library(janitor) library(ggthemes) library(gridExtra) library(reshape2)

knitr::opts_chunk\$set(echo = TRUE)


    ```{r read, echo=FALSE, message=FALSE, results='hide',warning=FALSE}
    # Gather base township information (geomarkers, districts,states/regions)
    TsDB128b <- read_dta("C:/Users/aklwin/OneDrive/UNICEF ME2/Database/States/Profile/Townships/Data/Work/TsDB128b.dta")

    Ts<-TsDB128b

    library(tidyverse)
    Ts %>% select(5,9,10,11,13,14) -> Loc

    rename(Loc, SR=MyaState2,
                 AreaCode = TsAreaCode) -> Loc2

\`\`\`{r mutate_var, echo=FALSE,message=FALSE,
results=‘hide’,warning=FALSE} \# Gather disability data set and normal
data set \## Disability TsSex \<- function(name) { temp \<\<-
readxl::read_excel(file.path(directory = “C:/Users/aklwin/OneDrive/R
programming/Github/Disability”, paste0(name,“.xlsx”))) temp\[1:413,1:5\]
-\>\> temp2 write.csv(temp2, paste0(name,“\_cl”,“.csv”)) temp2 -\>temp3
}

TsSex(“Cs14AnySevereDsbPriSex”) -\> df
TsSex(“Cs14AnySevereDsbPriAttSex”) -\> df2

df\[1\] -\> a df2\[1\] -\> b sum(a==b)

rename(df, SevMale = Male, SevFemale= Female, SevTotal = Total) -\> d1

df2 %\>% select(3:5) %\>% rename_with( \~ paste0(“AttSv”, .x)) -\> d2

cbind(d1,d2) -\> d3 d3 %\>% mutate( pcAttSvMale = 100 \*
AttSvMale/SevMale, pcAttSvFemale = 100 \* AttSvFemale/SevFemale,
pcAttSvTotal = 100 \* AttSvTotal/SevTotal) -\> d4

## Normal

TsSex(“Cs14_NoDsbPriAge”) -\> n1 TsSex(“Cs14NoDsbPriAttSex”) -\> n2

n1 %\>% select(3:5) %\>% rename_with( \~ paste0(“Nm”, .x)) -\> n3 n2
%\>% select(3:5) %\>% rename_with( \~ paste0(“AttNm”, .x)) -\> n4

cbind(n1\[1:2\],n3,n4) -\> n5 head(n5,3)

n5 %\>% mutate( pcAttNmMale = 100 \* AttNmMale/NmMale, pcAttNmFemale =
100 \* AttNmFemale/NmFemale,  
pcAttNmTotal = 100 \* AttNmTotal/NmTotal) -\> n6

# Combine two data sets

cbind(d4,n6\[3:11\]) -\> PriAtt

rename(PriAtt,AreaCode = `Area code`)-\> p2 inner_join(Loc2,p2, by =
“AreaCode”) -\> p3


    # Average primary school attendances of townships 
    ## Tables

    ### Summary statistics
    ```{r sum, echo=FALSE}
    p3 %>% group_by(SR) %>%
    summarise(TsAvgNmPri= mean(pcAttNmTotal,na.rm=TRUE),
    TsAvgSvPri= mean(pcAttSvTotal,na.rm=TRUE)) -> pcSRts_pri

    rename(pcSRts_pri,Normal = TsAvgNmPri,
                     Severe = TsAvgSvPri) ->Pri3

    summary(Pri3)

### State/region aggregates

\`\`\`{r table, echo=FALSE} \# Summarize state/region aggregates

print(Pri3)


    ## Visuals
    ### Boxplot
    ```{r bp, echo=FALSE, message=FALSE, results='hide',warning=FALSE}
    melt(pcSRts_pri, id="SR") -> pcSRts_pri2

    pcSRts_pri2$v2 <-ifelse(pcSRts_pri2$variable=="TsAvgNmPri", "Normal","Severe")

`{r bp2, echo=FALSE} ggplot(pcSRts_pri2, aes(y=value, fill=v2)) +     geom_boxplot(width=0.5) +     labs(fill="Disability status") +     scale_x_discrete(labels = NULL, breaks = NULL) +     ylab("percent") +     theme_minimal() +     theme(legend.position = c(0.2, 0.5))`

### Group bar

`{r gb, echo=FALSE,message=FALSE, results='hide',warning=FALSE} melt(pcSRts_pri, id="SR") -> pcSRts_pri2 pcSRts_pri2 pcSRts_pri2$v2 <-ifelse(pcSRts_pri2$variable=="TsAvgNmPri", "Normal","Severe")`

`{r gb2, echo=FALSE} ggplot(pcSRts_pri2, aes(y=value, x=SR, fill = v2)) +     geom_bar(position="dodge", stat="identity") +     scale_fill_manual(name="",                       values=c("#99CCFF","#FF9999"),                       labels=c("No disability","Severe disability"))  +     xlab ("State and Region") + ylab ("Percent") +      theme_minimal()+     theme(legend.position = "top") +      theme(axis.text.x = element_text(angle=90)) +     ggtitle("Primary School Attendance")`

## Township data

### Data Table

`{r print_tb, echo=FALSE, results= 'asis', warning=FALSE, message=FALSE} p3 %>% select(1,4,contains("pc")) -> p4`
`{r print_tb2, echo=FALSE, results= 'asis', warning=FALSE, message=FALSE} options(digits = 3) kable(p4, caption= "<Heading 1> Primary School Attendance rates",format ="html") %>%       footnote(general = "", general_title = "N.B. The NA values are on the children with disaiblity side that might also mean their being neglected status.")`

# Conclusion

The analytical results from Myanmar Census 2014 show that the children
having *severe disability* were **hugely** laggging behind in their
primary school attendance compared to those of the children with *no
disability*.