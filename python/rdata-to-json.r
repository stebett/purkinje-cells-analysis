library(jsonlite)
load("pathtodata")

write_json(lcasegrasp3, "pathtotarget", pretty=TRUE, na="null", auto_unbox=FALSE)
