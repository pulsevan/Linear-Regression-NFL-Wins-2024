#Evan Puls
library(tidyverse)

# The goal is to create a linear model to determine how the 
# variables in the datasets determine how many wins a team will end up with.

#Import datasets

afc <- read.csv("C:/YOUR/PATH/TO/pfrAFCScoring.csv") %>% mutate(Conference = "AFC")
nfc <- read.csv("C:/YOUR/PATH/TO/pfrNFCscoring.csv") %>% mutate(Conference = "NFC")
#Import teamOffense. Remove some variables here to make merging nicer.
teamOffense <- read.csv("C:/YOUR/PATH/TO/pfrTeamOffense.csv") %>% 
  select(-c(PF, G, Rk, EXP, FL))

#some of the rows in afc and nfc have a + or a * to indicate if they made the playoffs.
#I need to merge these dfs so I will be removing these.
afc$Tm <- gsub("[*+]+$", "", afc$Tm)
nfc$Tm <- gsub("[*+]+$", "", nfc$Tm)

#Merge afc and nfc
league_stats <- full_join(afc, nfc)
  
#Merge league stats and offense stats to have full stats for model.
#Move some variables around to make it easier to just select columns for model.
#Also, some variables should be removed (SRS is calculated post-season).
#We want to remove points scored because the othe metrics are simply predicting
#points scored, so it would be unfair to include both.
full_df <- inner_join(league_stats, teamOffense, by="Tm") %>% 
  relocate(Conference, W, .before=PF) %>% 
  select(-c(PD, SRS, OSRS, DSRS, PF))

#Create base model with all variables after the win/loss %. Starts at PF and goes to end.
base_lm <- lm(W ~ ., data=full_df[, 5:ncol(full_df)])

summary(base_lm)

#Lazily use stepwise regression to work our way down
stepwise_lm <- step(base_lm, direction="both", k = log(nrow(full_df)))

summary(stepwise_lm)

#Still needed some work because I only want significant predictors.
step2 <- lm(formula = W ~ Tot1stD + TO., data = full_df)

summary(step2)

#Model is prety much done with Tot1stD and TO., below is just creating
#extra stuff utilized in my project report for class.
df_sel <- full_df %>%
  select(W, Tot1stD, `TO.`)

# Basic summary of the Wins and top 4 predictors
summary(df_sel)

summary(full_df$W)

par(mfrow=c(1,2)) # Arrange plots side-by-side
plot(step2, which=1) # Residuals vs Fitted
plot(step2, which=2) # Normal Q-Q plot
par(mfrow=c(1,1)) # Reset plotting layout




library(ggplot2)
library(reshape2)

# Histogram for Wins (W)
ggplot(full_df, aes(x = W)) +
  geom_histogram(binwidth = 1, fill = "skyblue", color = "black") +
  labs(title = "Distribution of Wins", x = "Wins", y = "Frequency")


# Boxplot for Wins (W)
ggplot(full_df, aes(y = W)) +
  geom_boxplot(fill = "orange", color = "black") +
  labs(title = "Boxplot of Wins", y = "Wins")

# Assuming you have a categorical variable, such as 'Conference'
ggplot(full_df, aes(x = Conference, y = W)) +
  geom_boxplot(fill = "lightgreen", color = "black") +
  labs(title = "Wins by Conference",
       x = "Conference",
       y = "Wins")


# Configure the plotting space to display multiple diagnostic plots
par(mfrow = c(2,1))
plot(step2)


# Select numeric variables and compute the correlation matrix
numeric_vars <- full_df[, c("W", "PF", "SoS", "TotYds", "TotPly", "Tot1stD", 
                            "PaCmp", "PaAtt", "PaYds", "PaTD", "Int", "RuTD", 
                            "RuY.A", "Ru1stD", "Pen", "TO.")]
cor_matrix <- cor(numeric_vars)

# Adjust the outer margins to give extra space for the title
par(oma = c(0, 0, 4, 0))   # (bottom, left, top, right)

# Draw the correlation plot with your preferred settings
library(corrplot)
corrplot(cor_matrix,
         method = "color",
         addCoef.col = "black",  # add correlation coefficients
         tl.col = "black",       # color for variable labels
         number.cex = 0.7,
         mar = c(0, 0, 1, 0))     # inner margins

# Add a title in the outer margin area
mtext("Correlation Matrix of NFL Metrics", 
      side = 3,        # top of the plot
      line = 1,        # adjust the line position (increase if needed)
      outer = TRUE, 
      cex = 1.5)       # change cex to adjust the text size



#Graph time


# Create PF quartiles for grouping
full_df$PF_group <- cut(full_df$PF, 
                        breaks = quantile(full_df$PF, probs = seq(0, 1, 0.25), na.rm = TRUE), 
                        include.lowest = TRUE,
                        labels = c("Low", "Medium Low", "Medium High", "High"))

# Boxplot of Wins by PF groups using ggplot2
library(ggplot2)
ggplot(full_df, aes(x = PF_group, y = W)) +
  geom_boxplot(fill = "lightblue", color = "black") +
  labs(title = "Wins by PF Quartiles",
       x = "Points For Quartile",
       y = "Wins")
