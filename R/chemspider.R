#' Retrieve CSID from chemspider
#' 
#' Return ChemspiderId (CSID) for a search query, see \url{http://www.chemspider.com/}.
#' @import httr XML
#' 
#' @param query charachter; search query (e.g. CAS numbers).
#' @param token character; security token.
#' @param verbose logical; should a verbose output be printed on the console?
#' @param ask logical; ask for user input if multiple matches are found? 
#' If FALSE NA is returned in case of multiple matches.
#' @param ... currently not used.
#' @return a character vector of class 'csid' with CSID.
#' 
#' @note A security token is neeeded. Please register at RSC 
#' \url{https://www.rsc.org/rsc-id/register} 
#' for a security token.
#' 
#' If more then on match is found user is asked for input.
#' @author Eduard Szoecs, \email{eduardszoecs@@gmail.com}
#' @export
#' @examples
#' token <- '37bf5e57-9091-42f5-9274-650a64398aaf'
#' casnr <- c("107-06-2", "107-13-1", "319-86-8", "1031-07-8")
#' get_csid(casnr, token = token)
get_csid <- function(query, token, verbose = FALSE, ask = TRUE, ...){
  fnx <- function(x, token, ...){
    baseurl <- 'http://www.chemspider.com/Search.asmx/SimpleSearch?'
    qurl <- paste0(baseurl, 'query=', x, '&token=', token)
    if(verbose)
      message(qurl, '\n')
    tt <- GET(qurl)
    ttt <- xmlTreeParse(tt)
    csid <- xmlSApply(ttt$doc$children$ArrayOfInt, xmlValue)
    if(verbose)
      message(csid, '\n')
    if(length(csid) == 0){
      message("CSID '", x, " not found!\n Returning NA!")
      out <- NA
    }
    if(length(csid) > 1){
      if(ask){
        message("More then one hit found for ", x, " ! \n 
                Enter rownumber of CISD (other inputs will return 'NA'):\n")
        print(data.frame(csid))
        take <- scan(n = 1, quiet = TRUE, what = 'raw')
        if(length(take) == 0)
          csid <- NA
        if(take %in% seq_len(length(csid))){
          take <- as.numeric(take)
          message("Input accepted, took CSID '", as.character(csid[take]), "'.\n")
          csid <- as.character(csid[take])
        } else {
          csid <- NA
          message(verbose, "\nReturned 'NA'!\n\n")
        }
      } else {
        cid <- NA
        message("Multiple matches. Returned NA!")
      }
    }
    Sys.sleep(0.1)
    return(csid)
  }
  csid <- unlist(lapply(query, fnx, token, ...))
  names(csid) <- NULL
  class(csid) <- 'csid'
  return(csid)
}


#' Convert CSID to SMILES via chemspider
#' 
#' Convert ChemspiderId (CSID) to SMILES, see \url{http://www.chemspider.com/}
#' @import httr XML
#' @param csid character, CSID as returned by get_csid.
#' @param token character; security token.
#' @param verbose logical; should a verbose output be printed on the console?
#' @param ... currently not used.
#' @return a charater vector of class 'csid' with CSID.

#' @note A security token is neeeded. Please register at RSC 
#' \url{https://www.rsc.org/rsc-id/register} 
#' for a security token.
#' @author Eduard Szoecs, \email{eduardszoecs@@gmail.com}
#' @export
#' @examples
#' token <- '37bf5e57-9091-42f5-9274-650a64398aaf'
#' # convert CAS to CSID
#' casnr <- c("107-06-2", "107-13-1", "319-86-8", "1031-07-8")
#' csid <- get_csid(casnr, token = token)
#' # get SMILES from CSID
#' csid_to_smiles(csid, token)
csid_to_smiles <- function(csid, token, verbose = FALSE, ...){
  fnx <- function(x, token, ...){
    if(is.na(x))
      return(NA)
    baseurl <- 'http://www.chemspider.com/Search.asmx/GetCompoundInfo?'
    qurl <- paste0(baseurl, 'CSID=', x, '&token=', token)
    if(verbose)
      message(qurl)
    tt <- GET(qurl)
    ttt <- xmlTreeParse(tt)
    # better use xpath and xmlParse
    out <- xmlToList(ttt)
    smiles <- out$SMILES
    Sys.sleep(0.1)
    return(smiles)
  }
  smiles<- unlist(lapply(csid, fnx, token, ...))
  names(smiles) <- NULL
  return(smiles)
}


#' Get extended information from Chemspider
#' 
#' Get extended info from Chemspider, see \url{http://www.chemspider.com/}
#' @import httr XML
#' @param csid character, CSID as returned by get_csid.
#' @param token character; security token.
#' @param verbose logical; should a verbose output be printed on the console?
#' @param ... currently not used.
#' @return a charater vector of class 'csid' with CSID.

#' @note A security token is neeeded. Please register at RSC 
#' \url{https://www.rsc.org/rsc-id/register} 
#' for a security token.
#' @author Eduard Szoecs, \email{eduardszoecs@@gmail.com}
#' @export
#' @examples
#' token <- '37bf5e57-9091-42f5-9274-650a64398aaf'
#' # convert CAS to CSID
#' casnr <- c("107-06-2", "107-13-1", "319-86-8", "1031-07-8")
#' csid <- get_csid(casnr, token = token)
#' # get SMILES from CSID
#' csid_to_ext(csid, token)
csid_to_ext <- function(csid, token, verbose = FALSE, ...){
  fnx <- function(x, token, verbose, ...){
    if(is.na(x))
      return(NA)
    baseurl <- 'http://www.chemspider.com/MassSpecAPI.asmx/GetExtendedCompoundInfo?'
    qurl <- paste0(baseurl, 'CSID=', x, '&token=', token)
    if(verbose)
      message(qurl)
    tt <- GET(qurl)
    ttt <- xmlTreeParse(tt)
    # better use xpath and xmlParse
    out <- xmlSApply(ttt$doc$children$ExtendedCompoundInfo, xmlValue)
    Sys.sleep(0.1)
    return(out)
  }
  out <- ldply(csid, fnx, token, verbose)
  return(out)
}
