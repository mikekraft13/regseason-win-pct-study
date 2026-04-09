# modeling libraries 
library(MASS)
library(ISLR)
library(boot)
library(tidyverse)
library(FNN)
library(class)
#library(rstanarm)
library(leaps)
library(glmnet)
library(gam)
library(tree)
library(randomForest)
#library(gbm)

set.seed(123)
# First Model - Linear Regression ####
lin_reg_model <- lm(win.pct ~ (.-Id),data=training_data)

## summary statistics ####
summary(lin_reg_model)

## residual diagnostics ####
par(mfrow=c(2,2))
plot(lin_reg_model)

### function for pointing out the exact high leverage points ####
leverages <- hatvalues(lin_reg_model)
x <- cooks.distance(lin_reg_model)
# high leverage -> extreme x-value
# outlier -> extreme y-value (residual)
# influential point -> pretty extreme x and y-value - if removed, significantly changes the reg. model

### LOOK UP HIGH LEVERAGE POINTS AND HOW TO DEAL WITH THEM (PERHAPS THE TRANSFORMATION AFTER THE BOXCOX EVALUATION WILL RESOLVE THIS??)

## normality assumption check ####
boxcox(lin_reg_model)
cor(training_data)
### LOOK UP HIGH LEVERAGE POTENTIAL BOXCOX TRANSFORMATIONS


## refine model (possibly cut out predictors, etc)

## make predictions on test data

## cross validate linear model

## compute and speak on Cross Validation Mean Squared Error, as well as model and predictions in baseball context



# Second Model - ####
set.seed(123)
decision_tree <- tree(win.pct ~ (.-Id), data=training_data)
summary(decision_tree)




# Third Model - ####
