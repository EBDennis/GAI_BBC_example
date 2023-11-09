# Use fp from full season UKBMS to scale BBC data using modified GAI


library(data.table)
library(ggplot2)
library(plyr)
library(ggpubr)

# Species of interest
spp <- "Marbled White"
# Specificy minimum flight period coverage to include data
fpsumfilter <- 0.001

# Data preparation ----
# BBC official date periods per year
bbcdates <- fread("Data/BBC_sampling_period_dates.csv")

# Flight period values estimated from applying a daily GAI to UKBMS data
bms_fp <- fread(paste0("Data/", spp, "_flightperiods.csv"))

# Read in BBC data for particular species
bbc_data <- fread(paste0("Data/", spp, "_BBC_data_2011_to_2022.csv"))

# Phenology correction ----
# Add fp values to bbc data frame
bbc_data <- bms_fp[bbc_data, on = .(SPECIES,YEAR,DAYNO)]

# Apply the phenology correction approach to get estimates of N from BBC data
bbc_N <- bbc_data[!is.na(COUNT),
                       .(N = sum(COUNT)/sum(NM*kappa),
                         FPSUM = sum(NM)),
                       by = .(SPECIES, SITE, YEAR)]

# Calculate an index per year, G
bbc_G <- bbc_N[FPSUM >= fpsumfilter,
              .(G = mean(N),
               NSITES = uniqueN(SITE)), by = .(SPECIES, YEAR)]
# Scale to log10 for UKBMS index comparison
bbc_G[, TRMOBS := 2 + (log(G) - mean(log(G)))/log(10), by = SPECIES]

# Calculate a BBC index without phenology adjustment for comparison
bbc_S <- bbc_data[SPECIES == spp,
                         .(TOTALCOUNT = sum(COUNT)), by = .(SPECIES, YEAR, TOTALID)]
bbc_S[, MEANCOUNT := TOTALCOUNT/TOTALID]
bbc_S[, TRMOBS := 2+(log(MEANCOUNT) - mean(log(MEANCOUNT)))/log(10), by = SPECIES]



# Plotting ----
years <- 2011:2014

# Plot A
fp_curve_plot <- ggplot(bms_fp[YEAR %in% years], aes(DAYNO, NM))+
  geom_rect(aes(NULL, NULL,
                xmin = bbc_start_dayno,
                xmax = bbc_end_dayno, ymin = 0, ymax = Inf),
            data = bbcdates[YEAR %in% years], fill = "lightblue2")+
  geom_line(linewidth = 1)+
  theme_classic()+
  facet_wrap( ~ YEAR)+
  xlab("Day of year")+
  ylab("Flight period")+
  theme(text = element_text(size = 22),
        plot.margin=margin(.5,.5,.25,.5, "cm"))

# Plot B
# Filter to BBC official period
bms_fp <- bbcdates[,.(YEAR, bbc_start_dayno, bbc_end_dayno)][bms_fp, on = "YEAR"]
bms_fp <- bms_fp[DAYNO >= bbc_start_dayno & DAYNO <= bbc_end_dayno]
# Proportion of fp sampled by BBC sampling period each year
fp_prop <- bms_fp[DAYNO >= bbc_start_dayno & DAYNO <= bbc_end_dayno,
                   .(NMTOTAL = sum(NM)), by = .(SPECIES,YEAR)]

fp_prop_plot <- ggplot(fp_prop, aes(YEAR, NMTOTAL))+
  theme_classic()+
  geom_point(size = 3, col = "#48a464")+
  geom_line(col = "#48a464")+
  ylab("Proportion of flight period")+
  xlab("Year")+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        text = element_text(size = 22),
        plot.margin=margin(.5,.5,.25,.5, "cm"))+
  scale_x_continuous(breaks = seq(2012, 2025, 3))+
  ylim(c(0,.6))


# Plot C
# Compare to UKBMS index
bms_index <- fread(paste0("Data/", spp, "_UKBMS_GAI_abundance_index.csv"))
# Produce a single data frame for ploting
indices <- merge(rbind(bbc_G[,.(SPECIES, YEAR, TRMOBS)][, TYPE := "PHA"],
                 bbc_S[,.(SPECIES, YEAR, TRMOBS)][, TYPE := "S"]),
                 bms_index[,.(SPECIES, YEAR, TRMOBS_UKBMS)])

type.labs <- c("(i) without phenology adjustment",
               "(ii) with phenology adjustment")
names(type.labs) <- c("S","PHA")
indices$TYPE <- factor(indices$TYPE, levels = c("S","PHA"))

indices_plot <- ggplot(indices, aes(YEAR, TRMOBS_UKBMS))+
  theme_classic()+
  geom_hline(yintercept = 2, linetype="dashed", col="grey")+
  geom_line()+
  geom_point(size = 3)+
  facet_wrap( ~ TYPE,
             labeller = labeller(TYPE = type.labs))+
  geom_line(aes(y=TRMOBS, col=TYPE))+
  geom_point(aes(y=TRMOBS, col=TYPE, shape = TYPE), size = 3)+
  ylim(c(1,3))+
  scale_color_manual(breaks = c("S", "PHA"),
                     values = c("#0072B2", "#009E73"))+
  scale_shape_manual(breaks = c("S", "PHA"),
                     values = c(15,17))+
  theme(legend.position = "none")+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        text = element_text(size = 22),
        plot.margin=margin(.5,.5,.25,.5, "cm"))+
  scale_x_continuous(breaks = seq(2012, 2023, 3))+
  ylab("Abundance index")+
  xlab("Year")+
  ggtitle("")




(fig2 <- ggarrange(ggarrange(fp_curve_plot,
                                 fp_prop_plot,  nrow = 1,
                                 labels = c("A","B"),
                                 font.label = list(size = 26, color = "black", face = "bold", family = NULL)),
                       indices_plot,
                       labels = c("","C"),
                       font.label = list(size = 26, color = "black", face = "bold", family = NULL),
                       nrow = 2))

#ggsave(plot = fig2, paste0("Figures/",
#                           gsub(" ", "", spp),
#                           "_BBC_RSS_plot.png"),
#       width = 15, height = 15)


