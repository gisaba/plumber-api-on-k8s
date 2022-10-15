alive <<- TRUE
auth <<- TRUE
key <- "$jv4)7N9MRgjC5f6gDSIaSatGE%fkBGVE^&YuAb^"
session_key_ext = "123456"

end_point_no_auth <- function(end_point){
  ris <- case_when(end_point =="/login"  ~ TRUE ,
                   end_point =="/health" ~ TRUE,
                   end_point =="/__docs__/" ~ TRUE,
                   end_point =="/openapi.json" ~ TRUE,
                   TRUE ~ FALSE)
  return(ris)
}

get_hostname <- function(){
  return(as.character(Sys.info()["nodename"]))
}

check_jwt <- function(pjwt) {
  if (jwt_decode_hmac(pjwt, secret = key)$session_key == session_key_ext)  {
    return(TRUE)
  } else {return(FALSE)}
}

#* @filter checkAuth
function(req, res){
  auth <- !end_point_no_auth(req$PATH_INFO)
  if (auth)
  {
    
    CHECK <- FALSE
    jwt_from_header <- as.character(gsub("Bearer ", "", req$HTTP_AUTHORIZATION))
    #strings <- strsplit(jwt_from_header, ".", fixed = TRUE)[[1]]
    #jwt_from_header <- strings[2]
    
    tryCatch(CHECK <- check_jwt(jwt_from_header),
             error = function(e)
               jwt_from_header <- "Bearer AAAAAAAAAAAAAAAAAAAAAAAA")
    
    if (!CHECK)  {
      res$status <- 401 # Unauthorized
      list(error="Authentication required")
    } else {
      plumber::forward()
    }
  }
  else {plumber::forward()}
}

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* Get JWT token
#* @get /login
login <- function(username="",password="") {
  # Your login logic here
  if(username=="giovanni" && password=="1234") {
    # Create a JSON Web Token
    expiratio_token <- as.numeric(Sys.time()) + 3600
    claim <- jwt_claim(username = username, session_key = session_key_ext,exp = expiratio_token)
    jwt <- jwt_encode_hmac(claim, secret = key)
    list(token=jwt)
  } else {
    # Failed log in logic here
    list(message="Failed to log in")
  }
}

#* Determine if an integer is odd or even
#* @serializer unboxedJSON
#* @param int Integer to test for parity
#* @get /parity
function(int,req, res) {
    if (as.integer(int) %% 2 == 0) list(parity="even") else list(parity = "odd")
}

#* Wait 5 seconds and then return the current time
#* @serializer unboxedJSON
#* @get /wait
function() {
    Sys.sleep(5)
    list(time = Sys.time())
}

#* Force the health check to fail
#* @serializer text
#* @post /fail
function() {
  alive <<- FALSE
  #as.character(Sys.info()["nodename"])
  get_hostname()
  #NULL
}

#* Try quitting
#* @post /quit
function() {
  quit()
}

#* Health check. Returns "OK".
#* @serializer unboxedJSON
#* @get /health
function(req, res) {
    if (!alive) stop() else list(result="OK",hostname=get_hostname(),time = Sys.time())
}

#* write iris to csv
#* @post /iris
function() {
  write.csv(x = iris,file = "./data/iris.csv")
}

#* Plot a histogram
#* @serializer png
#* @get /plot
function() {
    rand <- rnorm(100)
    hist(rand)
}
