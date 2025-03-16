#Progetto modelli statistici per le scienze attuariali - Lolliri Giulia
library(ggplot2)
library(reshape2)
load('brevhins-B.RData')
#data(brvehins1b)
#write.csv(ds, file = "ds.csv", row.names = FALSE)
#Discretizzazione delle variabili e analisi descrittive
summary(ds$Gender)
summary(ds$DrivAge)
summary(ds$VehYear)
summary(ds$VehModel)
summary(ds$VehGroup)
ds$VehModel <- droplevels(ds$VehModel)  
summary(ds$Area)
summary(ds$State)
summary(ds$StateAb)
summary(ds$SumInsAvg)
summary(ds$ExposTotal)
ds <- ds[ds$ExposTotal > 0 & ds$Gender %in% c("Female", "Male"), ]
levels(ds$State)
levels(ds$StateAb)
levels(ds$StateAb) <- c('N', 'NE', 'N', 'N', 'NE', 'NE', 'CO', 'SE', 'CO', 'NE', 'CO', 'CO', 'SE', 'N', 'NE', 'S', 'NE', 'NE', 'SE', 'NE', 'S', 'N', 'N', 'S', 'SE', 'NE', 'N')
ds <- ds[!is.na(ds$StateAb), ]
summary(ds$StateAb)
ds <- ds[!is.na(ds$VehGroup), ]
ds$CatVeh <- ifelse(
  grepl("\\bVw Volkswagen Gol 1.0\\b|\\bVw Volkswagen Gol Acima De 1.0\\b|Palio|Corsa|Uno|206|207|Celta|Fiesta|Fit|\\bVolkswagen Polo\\b|Parati|C3|Siena|Fox|Ka|Sandero|Voyage|Fox|Idea|Punto|Prisma|\\bFiat 147\\b|\\bCross Lander\\b|Duna|Elba|Premio|Fusion|Ibiza|\\bFord Ka 1.0\\b|\\bFord Ka Acima De 1.0\\b|Vero|Cali|Wagon|Tigra|Track|Accent|Atos|Excel|Matrix|Picanto|Laika|106|205|Swift|\\bSuzuki Vitara\\b|Twingo|Baleno|Ignis|Corona|Apolo|\\bFord Eco Sport\\b", ds$VehGroup), "Cat A_B",
  ifelse(
    grepl("\\bVw Volkswagen Golf\\b|Corolla|307|Astra|Vectra|Focus|Civic|sara|Megane|Stilo|C4|Escort|Sentra|Logan|Santa|Bora|Tucson|Captiva|Classe|Monza|Kadett|Linea|Passat|Tiida|145|\\bAlfa Romeo 147\\b|155|156|164|2300|Spider|\\bAudi 100\\b|80|A3|A4|A5|Avant|Rs4|Rs6|S3|\\bAudi S4\\b|\\bVolvo S40\\b|\\bVolvo S60\\b|Bx|C5|C8|Xantia|Xm|Zx|Jou|Brav|Coupe|Marea|Tempra|Tipo|Belina|Corcel|Vitoria|Rey|Explo|Mondeo|Roy|Tau|Thunderbird|Vers|Windstar|Blaz|Bona|Cama|Opala|Caravan|Cava|Chevette|Ipa|Mara|Veraneio|40|Accord|Ody|Prelude|Elantra|Galloper|Sonata|terra|Trajet|Jeep|Carens|Carnival|Cerato|Cordoba|Korando|Clarus|Magnetis|Sephia|Shuma|Sorento|Niva|Lexus|Eclipse|Galant|Lancer|850|306|Grand|504|605|V40|807|\\bRenault 19\\b|21|Laguna|Forester|Impreza|Legacy|Camry|Defender|Beetle|Free|Rav4|V70|Xc60|Fusca|Logus|Pointer|Quantum|\\bKia Sportage\\b|Scenic|Pajero|Cr-v|Allroad", ds$VehGroup), "Cat C_D",
    ifelse(
      grepl("166|A6|\\bAudi S6\\b|C6|Azera|Omega|Suburban|Sup|Veracruz|Rexton|Opirus|Maxima|Pathfinder|607|S70|S80|Cayenne|Outback|Cruiser|Discovery|\\bLand Rover Range Rover\\b|\\bLand Rover New Ranger\\b|Xc90|Q7", ds$VehGroup), "Cat E",
      ifelse(
        grepl("A8|Cadillac|Thunderbird|Jaguar|Maserati|911", ds$VehGroup), "Cat F",
        ifelse(
          grepl("\\bAudi Tt\\b|Ferrari|Mustang|Corvette|Miura|Boxster", ds$VehGroup), "Cat S",
          ifelse(
            grepl("Caminhoes|Cargo|Agrale|Ciccobus|Dayun|190|Navistar|Hr|Porter|City|Chassi|Euro|Stralis|Bongo|Volare|Atego|Axor|bus", ds$VehGroup), "Camion",
            ifelse(
              grepl("Strada|Hilux|\\bFord Ranger\\b|Saveiro|Doblo|Frontier|Montana|250|1000|Dakota|\\bDodge Ram\\b|Effa|Troller|\\bFord F-100\\b|150|Pampa|A-10|A-20|C-10|C-20|Chey|D-|Silver|Ss10|Hafei|Musso|Ceres|Band|S-10", ds$VehGroup), "Pickup",
              ifelse(
                grepl("Motos|Amazonas|Dafra|Hao|Malaguti|Wuyang", ds$VehGroup), "Moto",
                ifelse(
                  grepl("Kombi|Zafira|Meriva|Sprinter|Fiorino|Kangoo|Courier|Ducato|Master|Chana|Berlingo|Evasion|Jumper|Panorama|Furg|Transit|Chevy|Spacevan|Trafic|H1|\\bIveco Daily Max Van\\b|Besta|Inca|806|Boxer|Partner", ds$VehGroup), "Van",
                  "Altro"
                )
              )
            )
          )
        )
      )
    )
  )
)

table(ds$CatVeh)
categories <- unique(ds$CatVeh)

for (cat in categories) {
  cat("\nCategoria:", cat, "\n")
  print(unique(ds$VehGroup[ds$CatVeh == cat]))
}
ds$CatVeh <- as.factor(ds$CatVeh)
summary(ds$CatVeh)
ds$DrivAge <- factor(ds$DrivAge, levels = c("18-25", "26-35", "36-45", "46-55", ">55"))
ds$ClaimNb <- as.integer(ds$ClaimNb)
ds$ClaimAmount <- as.integer(ds$ClaimAmount)

hist(ds$ClaimAmount[ds$ClaimAmount > 0], 
     breaks = 20, 
     main = "Istogramma della variabile ClaimAmount", 
     xlab = "Claim Amount",
     ylab = "Frequenza",
     col = "lightgreen",   
     border = "black",     
     xaxt = "n")           


axis(1, at = seq(0, max(ds$ClaimAmount, na.rm = TRUE), by = 50000), 
     labels = format(seq(0, max(ds$ClaimAmount, na.rm = TRUE), by = 50000), big.mark = ","))

celle1 <- aggregate( cbind(ClaimNb, ExposTotal) ~  StateAb, data=ds, FUN=sum)
celle1
celle1$Freq <- celle1$ClaimNb / celle1$ExposTotal
celle1

celle2 <- aggregate( 
  cbind(ClaimNb, ClaimAmount) ~ CatVeh, data=ds, 
  FUN=sum)
celle2$Sev  = celle2$ClaimAmount/celle2$ClaimNb
celle2

ggplot(data = celle1, aes(x = StateAb, y = ClaimNb, fill = StateAb)) +
  geom_bar(stat = "identity") +
  labs(title = "Numero di sinistri per area geografica", x = "Area Geografica", y = "Numero di Sinistri") +
  theme_minimal()

ggplot(data = celle1, aes(x = reorder(StateAb, Freq), y = Freq, fill = StateAb)) +
  geom_bar(stat = "identity") +
  labs(title = "Frequenza dei sinistri per area geografica", x = "Area Geografica", y = "Frequenza") +
  theme_minimal() +
  coord_flip()  


ggplot(data = celle2, aes(x = reorder(CatVeh, Sev), y = Sev, fill = CatVeh)) +
  geom_bar(stat = "identity") +
  labs(title = "Severity per categoria del veicolo", x = "Categoria", y = "Severity") +
  theme_minimal() +
  coord_flip()  


celle_melted <- melt(celle2, id.vars = "CatVeh", measure.vars = c("ClaimNb", "Sev"))


ggplot(celle_melted, aes(x = CatVeh, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Confronto tra numero di sinistri e severity",
       x = "Categoria del veicolo",
       fill = "Variabile") +
  scale_fill_manual(values = c("lightgreen", "orange"), labels = c("Numero di sinistri", "Severity")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  

#Creazione delle celle
#Modello GLM
celle <- aggregate(
  cbind(ClaimNb, ExposTotal, ClaimAmount ) ~ Gender + DrivAge + StateAb + CatVeh,
  data=ds,
  FUN=sum
)
head(celle)
summary(celle)
celle$Freq <- celle$ClaimNb / celle$ExposTotal 
head(celle)

mod1 <- glm(
  ClaimNb ~ Gender + DrivAge + StateAb  + offset(log(ExposTotal)),
  family=poisson(link="log"),            
  data=ds
)
summary(mod1)
coefficients(mod1)
coefficients_df <- data.frame(
  Variable = names(coefficients(mod1)),
  y = (coefficients(mod1)))

ggplot(coefficients_df, aes(x = Variable, y = y )) +
  geom_point(size = 3, color = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red", size = 1) +  
  labs(title = "Coefficienti del modello",
       x = "Variabili",
       y = "") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 40, hjust = 1, vjust = 1))

mod2 <- glm(
  ClaimNb ~ Gender + DrivAge + StateAb + offset(log(ExposTotal)),
  family=quasipoisson(link='log'),
  data=ds
)
summary(mod2)

modSev1 <- glm( 
  ClaimAmount ~ Gender + CatVeh + offset(log(ClaimNb)),
  family=Gamma(link="log"),
  data=ds,
  subset=ClaimNb>0 
)
summary(modSev1)
exp(coefficients(modSev1))


plot(modSev1, which = 1, pch = 21, col = "blue")  
abline(h = 0, col = "red", lwd = 2, lty = 2)  
plot(modSev1, which = 2, pch = 21, col = "blue")  

# Controllo Outliers
residuals_df <- data.frame(
  Fitted = fitted(modSev1),
  Residuals = residuals(modSev1, type = "pearson"),
  Observation = 1:length(residuals(modSev1))
)

outliers <- residuals_df[abs(residuals_df$Residuals) > 25, ]  
print(outliers) 
ds[15636,]
ds[26747,]
ds[31687,]

no_outliers <- residuals_df[abs(residuals_df$Residuals) <= 25, ]  

ds_no_outliers <- ds[no_outliers$Observation, ]

modSev1_no_outliers <- glm(
  formula = ClaimAmount ~ Gender + CatVeh + offset(log(ClaimNb)),
  family = Gamma(link = "log"),
  data = ds_no_outliers,
  subset = ClaimNb > 0
)

summary(modSev1)
summary(modSev1_no_outliers)
anova(modSev1)
anova(modSev1_no_outliers)

#celle1 <- celle
#celle1$Exposure <- 1.
#head(celle1)

#predict(mod1, newdata=celle1, type='link')
#predict(mod1, newdata=celle1, type='response')
#celle1$FreqMod <- predict(mod1, newdata=celle1, type='response') 
#celle1
#celle2 <- celle
#celle2$ClaimNb <- 1
#celle2$SevMod <- predict(modSev1, newdata=celle2, type='response')
#celle2

#Tariffazione
celle$Sev <- celle$ClaimAmount / celle$ClaimNb

celle1 <- celle
celle1$ExposTotal <- 1
celle$FreqMod <- predict(mod1, newdata=celle1, type='response')

celle2 <- celle
celle2$ClaimNb <- 1
celle$SevMod <- predict(modSev1, newdata=celle2, type='response')
head(celle)

celle$PremioPuro <- celle$Freq * celle$Sev
celle$PremioPuroMod <- celle$FreqMod * celle$SevMod

head(celle) 
celle$PremioTotaleMod <- celle$PremioPuroMod * celle$ExposTotal
celle$balance <- celle$PremioTotaleMod - celle$ClaimAmount

head(celle) 
print(sum(celle$balance))
print(sum(celle$balance)/sum(celle$ClaimAmount))
print(sum(celle$ClaimAmount))
print(sum(celle$PremioTotaleMod))      

#Ridistribuzione del bilancio positivo
library(dplyr)
#Calcolo del fattore di aggiustamento iniziale
fattore_aggiustamento <- sum(celle$ClaimAmount) / sum(celle$PremioTotaleMod)

#Applicazione di una riduzione più forte a chi ha storicamente meno sinistri
celle$PremioTotaleMod_Adj <- celle$PremioTotaleMod * fattore_aggiustamento

#Definizione di un massimo del +20% di incremento per le categorie meno rischiose
limite_aumento <- 1.2  

#Identificazione delle categorie meno rischiose (esempio: categorie con bassa sinistrosità)
categorie_basso_rischio <- celle$Freq < median(celle$Freq)

#Applicazione del limite massimo del 20% solo alle categorie a basso rischio
celle$PremioTotaleMod_Adj[categorie_basso_rischio] <- pmin(
  celle$PremioTotaleMod_Adj[categorie_basso_rischio],
  celle$PremioTotaleMod[categorie_basso_rischio] * limite_aumento
) #Per le categorie identificate come meno rischiose, controlla se il loro premio supera il 120% del premio originale. Se supera questa soglia, lo riduce al massimo consentito.

nuovo_totale_premi <- sum(celle$PremioTotaleMod_Adj) #Dopo aver limitato gli aumenti per le categorie meno rischiose, il totale dei premi non coincide più con i sinistri effettivi. Per compensare questa differenza, calcolo un nuovo fattore di aggiustamento per riportare il bilancio in pareggio.

#Ricalcolo del nuovo fattore per redistribuire equamente il resto
nuovo_fattore <- sum(celle$ClaimAmount) / nuovo_totale_premi

#Applicazione della correzione solo alle categorie rimanenti
celle$PremioTotaleMod_Adj <- celle$PremioTotaleMod_Adj * nuovo_fattore

#Nuovo balance
celle$balance_adj <- celle$PremioTotaleMod_Adj - celle$ClaimAmount

#Controlli
print(sum(celle$balance_adj))  
print(sum(celle$PremioTotaleMod_Adj))  
sum(celle$PremioTotaleMod_Adj-celle$ClaimAmount)

