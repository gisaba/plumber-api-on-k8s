alive <<- TRUE
key <- "$jv4)7N9MRgjC5f6gDSIaSatGE%fkBGVE^&YuAb^"
session_key_ext = "123456"

get_hostname <- function(){
  return(as.character(Sys.info()["nodename"]))
}

check_jwt <- function(pjwt) {
  if (jwt_decode_hmac(pjwt, secret = key)$session_key == session_key_ext)  {
    return(TRUE)
  } else {return(FALSE)}
}

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* @filter checkAuth
function(req, res){
  # need a function to get out all path from filter
  if ((req$PATH_INFO!="/login")
      &(req$PATH_INFO!="/health")
      &(req$PATH_INFO!="/__docs__/")
      &(req$PATH_INFO!="/openapi.json"))
  {
    # retrieve token from the request
    #postToken <- req$postBody["token"]
    #queryStringToken <- req$QUERY_STRING["token"]  # your authentication logic here
    #if (is.null(queryStringToken) && is.null(postToken)){

    CHECK <- FALSE
    jwt_from_header <- as.character(gsub("Bearer ", "", req$HTTP_AUTHORIZATION))
    #strings <- strsplit(jwt_from_header, ".", fixed = TRUE)[[1]]
    #jwt_from_header <- strings[2]

    tryCatch(CHECK <- check_jwt(jwt_from_header),
             error = function(e)
               jwt_from_header <- "Bearer AAAAAAAAAAAAAAAAAAAAAAAA")

    #jwt_from_header <- as.character(gsub("Bearer ", "", req$HTTP_AUTHORIZATION))

    if (!CHECK)  {
      res$status <- 401 # Unauthorized
      list(error="Authentication required")
    } else {
      plumber::forward()
    }
  }
  else {plumber::forward()}
}

#* view jwt_decode
#* @get /jwt_decode
function(req) {
  jwt_from_header <- as.character(gsub("Bearer ", "", req$HTTP_AUTHORIZATION))
  list(jwt_decode_hmac(jwt_from_header, secret = key))
}

#* Get JWT token
#* @get /login
login <- function(username="",password="") {

  # Your login logic here
  if(username=="giova" && password=="1234") {
    # Create a JSON Web Token
    expiratio_token <- as.numeric(Sys.time()) + 3600
    claim <- jwt_claim(username = username, session_key = session_key_ext,exp = expiratio_token)
    #key <- charToRaw("SuperSecret")
    jwt <- jwt_encode_hmac(claim, secret = key)
    list(token=jwt)
  } else {
    # Failed log in logic here
    list(message="Failed to log in")
  }
}

#* Determine if an integer is odd or even
#* @serializer text
#* @param int Integer to test for parity
#* @get /parity
function(int,req, res) {
  future({
    if (as.integer(int) %% 2 == 0) "even" else "odd"
  })
}

#* Wait 5 seconds and then return the current time
#* @serializer json
#* @get /wait
function() {
  future({
    Sys.sleep(5)
    list(time = Sys.time())
  })
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
#* @serializer text
#* @get /health
function(req, res) {
  future({
    if (!alive) stop() else paste0("OK-",get_hostname())
  })
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

#* Get a hostname
#* @serializer json
#* @get /host
function(){
  get_hostname()
}

#* @get /debug_req
function(req) {
  list(
    body = req$body,
    bodyRaw = req$bodyRaw,
    QUERY_STRING = req$QUERY_STRING,
    argsQuery = req$argsQuery,
    postBody = req$postBody,
    postBodyToken = req$postBody["token"],
    HEADERS = req$HEADERS,
    pathinfo = req$PATH_INFO,
    HTTP_AUTHORIZATION = req$HTTP_AUTHORIZATION
  )
}

#* Return the value of a custom header
#* @serializer json
#* @get /key
function(){
  list(key=key)
}

#* Return the value of req
#* @get /request
function(req){
  print(ls(req))
}

#* Return the value Sys.time()
#* @get /time
function(){
  paste(Sys.Date(),Sys.time())
}

#* Parse jwt
#* @serializer json
#* @get /jwt
function(req){
  jwt_from_header <- as.character(gsub("Bearer ", "", req$HTTP_AUTHORIZATION))
  strings <- strsplit(jwt_from_header, ".", fixed = TRUE)[[1]]
  list(jwt=strings)
}
