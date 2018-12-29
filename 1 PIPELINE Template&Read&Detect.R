
# Select: Data File & Working Directory 
filepath <- gsub  ( "\\\\",  "/",  normalizePath( choose.files() ))
wdir <- dirname(filepath)                                  # wdir <- gsub  ( "\\\\",  "/",  readClipboard ()  ) # copy path and run 
filename <- basename(filepath)
setwd(wdir)
suppressWarnings(shell(paste("explorer",  gsub('/', '\\\\', getwd() ))))   # opens the working directory in a new explorer window
require(tools)
templatename <- tools::file_path_sans_ext(filename)
templatepath <- file.path(wdir, templatename)
templatedatapath <- file.path(wdir, templatename, 'data')

# Create ProjectTemplate Directory (if necesary), Read Data
require('ProjectTemplate')
if(dir.exists(templatepath) || grepl(file.path(templatename, 'data'), filepath)){  
   cat("ProjectTemaplate directory already exists: ")                      # ProjectTemplate dir exists or Data is already inside data folder
   cat(file.path(wdir, templatename), "\n")
   templatepath <- file.path(wdir, templatename)
   try(setwd(templatepath), silent = TRUE)                                               # if Data is in same folder with ProjectTemplate
   try(setwd(strsplit(filepath, "/data")[[1]][1]), silent = TRUE)                         # if Data is in data within ProjectTemplate
   
   ProjectTemplate::load.project(list( munging = FALSE,                              # dont do munging at this step
                                       data_loading = FALSE,                         # now we read only cached Data, not the raw Data 
                                       data_loading_header = FALSE,                  # now we read only cached Data, not the raw Data 
                                       cache_loading = TRUE,
                                       logging = TRUE,
                                       data_tables = TRUE, 
                                       load_libraries = TRUE,
                                       libraries = sprintf('dplyr, Hmisc, data.table, ggplot2, caret, DataExplorer'), 
                                       as_factors = FALSE, 
                                       data_tables = TRUE,
                                       cache_loaded_data = FALSE                    # still better to cach manually
   ))
   
} else { ProjectTemplate::create.project(templatename, template = 'minimal')
   cat("ProjectTemaplate directory was created: ")
   cat(file.path(wdir, templatename), "\n")
   file.copy(from = filepath, to = templatedatapath)
   
   require(utils)
   deletedata <- utils::winDialog("yesno", "Data was moved to ProjectTemplate. Remove it from original directory?")
    if (deletedata == 'YES') {file.remove(filepath); cat('Data file removed.')} else {cat('Data file not removed.')}
    setwd(templatepath)
   
    userio <- utils::winDialog("yesno", "Read data with rio package? ('no' defaults to ProjectTemplate)")
    if (userio == 'YES') {
     ProjectTemplate::load.project(list( munging = FALSE,                              # dont do munging at this step
                                         data_loading = FALSE,                         # dont read with ProjectTemplate 
                                         data_loading_header = FALSE,                  # dont read with ProjectTemplate 
                                         cache_loading = FALSE,
                                         logging = TRUE,
                                         data_tables = TRUE, 
                                         load_libraries = TRUE,
                                         libraries = sprintf('dplyr, Hmisc, data.table, ggplot2, caret, DataExplorer'), 
                                         as_factors = FALSE, 
                                         data_tables = TRUE,
                                         cache_loaded_data = FALSE                    # still better to cach manually
     ))     
     require(rio)
     Data <- rio::import(file.path(templatedatapath, filename) )
     cat('Data was read with rio package. \n')    
   }  else {  
     ProjectTemplate::load.project(list( munging = FALSE,                              # dont do munging at this step
                                         data_loading = TRUE,
                                         data_loading_header = TRUE,
                                         cache_loading = TRUE,
                                         logging = TRUE,
                                         data_tables = TRUE, 
                                         load_libraries = TRUE,
                                         libraries = sprintf('dplyr, Hmisc, data.table, ggplot2, caret, DataExplorer'), 
                                         as_factors = FALSE,                           # hellno :)
                                         data_tables = TRUE,
                                         cache_loaded_data = FALSE                      # at first reading this should be FALSE 
     ))
     Data <- get0(project.info$data); eval(call("rm", project.info$data))     # change Data name and remove Data with file name
     cat('Data was read with ProjectTemplate package. \n')   
     }
     
     rm(deletedata, userio, filename, filepath, templatedatapath, templatename, templatepath, wdir)
     cache('Data')
}   






# add.config( munging = FALSE,                              # dont do munging at this step
#             data_loading = TRUE,
#             data_loading_header = TRUE,
#             logging = TRUE,
#             data_tables = TRUE, 
#             load_libraries = TRUE,
#             as_factors = FALSE, 
#             data_tables = TRUE,
#             apply.override = TRUE
# )
# project.config()

# library(data.table)
# tables()


