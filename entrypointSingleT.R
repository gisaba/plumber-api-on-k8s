library(plumber)
library(promises)
library(openssl)
library(jose)
library(dplyr)
library(reticulate)

rm(list = ls())

#################################################
#source("miniconda.R")
#################################################

pr("plumberSingleT.R") %>% pr_run(host='0.0.0.0', port = 8000)
#pr("k8sAPI.R") %>% pr_run(host='0.0.0.0', port = 8000)
#pr("debug.R") %>% pr_run(host='0.0.0.0', port = 8001)
