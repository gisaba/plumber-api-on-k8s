library(plumber)
library(promises)
library(future)
library(openssl)
library(jose)
library(dplyr)
library(reticulate)
future::plan("multisession")

rm(list = ls())

#################################################
#source("miniconda.R")
#################################################

pr("plumber.R") %>% pr_run(host='0.0.0.0', port = 8000)
#pr("k8sAPI.R") %>% pr_run(host='0.0.0.0', port = 8000)
#pr("debug.R") %>% pr_run(host='0.0.0.0', port = 8001)
