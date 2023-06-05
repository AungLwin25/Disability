# Get Township database
library(haven)
TsDB128b <- read_dta("C:/Users/aklwin/OneDrive/UNICEF ME2/Database/States/Profile/Townships/Data/Work/TsDB128b.dta")
View(TsDB128b)

Ts<-TsDB128b
names(Ts)

library(tidyverse)
Ts %>% select(5,9,10,11,13,14) -> Loc

rename(Loc, SR=MyaState2,
       AreaCode = TsAreaCode) -> Loc2
head(Loc2)

dim(Loc2)

# Get Severe Disability database
library(readxl)
Cs14AnySevereDsbSex <- read_excel("Cs14AnySevereDsbSex.xlsx")

dim(Cs14AnySevereDsbSex)
Cs14AnySevereDsbSex[1:413,1:5] -> Sv
head(Sv)

# merging two data sets
inner_join(Loc2,Sv, by = "AreaCode") -> Sv2 ## only inner_join works here
head(Sv2)
write.csv(Sv2,"Cs14SvTs.csv")
