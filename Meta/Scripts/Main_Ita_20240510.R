#

#
rm(list = ls()); cat("\014")

#
library(metafor)
library(ggplot2)
library(sf)

#
RootOverride <- "C:/Users/PC-LAB-03/Desktop/Metanalisi INVALSI/Analyses/Meta/"
Root <- RootOverride
OutputsFolder <- paste0(Root, "Outputs/")
DataFolder <- paste0(Root, "Data/")
shpFolder <- paste0(Root, "shp/")

#
unlink(OutputsFolder, recursive = T, force = T)
dir.create(OutputsFolder)

#
df <- data.frame(read.csv(paste0(DataFolder, "DataItaMods.csv")))
#df <- df[df$Coort %in% 1:1,]
#df$gamlssSE <- 2*df$gamlssSE
#df[which(!is.na(df$gamlssSE)), "SE"] <- df[which(!is.na(df$gamlssSE)), "gamlssSE"]
df$SE <- df$SE^2

#
shp <- st_read(paste0(shpFolder, "/ProvCM01012024"))
#shp[shp$SIGLA=="NA", "SIGLA"] <- "Na"

#
setwd(OutputsFolder)

####################################################################################

#
levels(factor(df$Cod_provincia_ISTAT))==levels(factor(shp$COD_PROV))

#
dd <- merge(shp, df, by.x = "COD_PROV", by.y = "Cod_provincia_ISTAT", all=T)

#
png("GraphProvinces_Ita_logvr.png", width = 1300, height = 1500)

ggplot(data = dd)+
  geom_sf(aes(fill=logvr))+
  labs(title = "Italy Provinces")+
  theme(plot.title = element_text(size=52, hjust = .5),
        panel.background = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        legend.position = "none"
  )

dev.off()

####################################################################################
gc()

setwd(Root)
shp <- read_sf(paste0(shpFolder, "/Reg01012024"))
setwd(OutputsFolder)

#
levels(factor(df$Regioni))==levels(factor(shp$DEN_REG))

#
dd <- merge(shp, df, by.x = "DEN_REG", by.y = "Regioni", all=T)

#
png("GraphRegions__Ita_logvr.png", width = 1300, height = 1500)

ggplot(data = dd)+
  geom_sf(aes(fill=logvr))+
  labs(title = "Italy Regions")+
  theme(plot.title = element_text(size=52, hjust = .5),
        panel.background = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        legend.position = "none"
  )

dev.off()

####################################################################################
gc()
####################################################################################

sink("Fit__Ita_Sesso.txt")
t1 <- Sys.time()
f <- rma.mv(yi = logvr, V = SE, mods=~sesso, random =~1|Regioni/Cod_provincia_ISTAT, data=df, sparse=T)
summary(f)
dt <- Sys.time() - t1
dt
sink()
closeAllConnections()

####################################################################################

#
Ests <- ranef(f)

RandEffR <- Ests$Regioni
RandEffP <- Ests$`Regioni/Cod_provincia_ISTAT`

RandEffP$Cod_provincia_ISTAT <- row.names(RandEffP)
RandEffP$Cod_provincia_ISTAT <- sapply(RandEffP$Cod_provincia_ISTAT, function(x) strsplit(x, "/")[[1]][2])
row.names(RandEffP) <- NULL

####################################################################################

#
setwd(Root)
shp <- st_read(paste0(shpFolder, "/ProvCM01012024"))
setwd(OutputsFolder)

#
levels(factor(as.double(RandEffP$Cod_provincia_ISTAT)))==levels(factor(shp$COD_PROV))

#
df <- merge(shp, RandEffP, by.x = "COD_PROV", by.y = "Cod_provincia_ISTAT", all=T)

#
png("GraphProvinces__Ita_RandEffP.png", width = 1300, height = 1500)

ggplot(data = df)+
  geom_sf(aes(fill=intrcpt))+
  labs(title = "Italy Provinces")+
  theme(plot.title = element_text(size=52, hjust = .5),
        panel.background = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        legend.position = "none"
  )

dev.off()

####################################################################################

#
setwd(Root)
shp <- read_sf(paste0(shpFolder, "/Reg01012024"))
setwd(OutputsFolder)

RandEffR$DEN_REG <- row.names(RandEffR)
row.names(RandEffR) <- NULL

#
levels(factor(RandEffR$DEN_REG))==levels(factor(shp$DEN_REG))

#
df <- merge(shp, RandEffR, by = "DEN_REG", all=T)

#
png("GraphRegions__Ita_RandEffR.png", width = 1300, height = 1500)

ggplot(data = df)+
  geom_sf(aes(fill=intrcpt))+
  labs(title = "Italy Regions")+
  theme(plot.title = element_text(size=52, hjust = .5),
        panel.background = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        legend.position = "none"
  )

dev.off()

####################################################################################

#
setwd(Root)

#
sink("SessionInfo.txt")
sessionInfo()
sink()
closeAllConnections()
