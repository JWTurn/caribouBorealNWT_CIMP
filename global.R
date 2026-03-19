repos <- c("https://predictiveecology.r-universe.dev", getOption("repos"))
source("https://raw.githubusercontent.com/PredictiveEcology/pemisc/refs/heads/development/R/getOrUpdatePkg.R")
getOrUpdatePkg(c("Require", "SpaDES.project"), c("1.0.1.9024", "1.0.1.9000")) # only install/update if required
#Require::Install("PredictiveEcology/SpaDES.core@development")

projPath = "~/git-local/caribouBorealNWT_CIMP"
reproducibleInputsPath = "'~/Library/CloudStorage/GoogleDrive-jwturner@ualberta.ca/Shared drives/JWTscratch/reproducibleInputs'"

out <- SpaDES.project::setupProject(
  Restart = TRUE,
  useGit = 'JWTurn',
  updateRprofile = TRUE,
  #overwrite = TRUE,
  paths = list(projectPath =  projPath
               #"packagePath" = file.path("packages", Require:::versionMajorMinor())
  ),
  options = options(spades.allowInitDuringSimInit = TRUE,
                    spades.allowSequentialCaching = TRUE,
                    spades.moduleCodeChecks = FALSE,
                    spades.recoveryMode = 1,
                    reproducible.inputPaths = reproducibleInputsPath,
                    reproducible.useMemoise = TRUE
                    ,reproducible.cloudFolderID = 'https://drive.google.com/drive/folders/1lDVP0G1FFft5WJgnKBLPPlkTXPsU04hr?usp=share_link'
  ),
  modules = c('gc-rmcinnes/caribouLocPrep@main',
              'gc-rmcinnes/prepTracks@main',
              'JWTurn/prepLandscape@main',
              'gc-rmcinnes/extractLand@main',
              'gc_rmcinnes/caribouiSSA@main'
              
  ),
  params = list(
    .globals = list(
      .plots = c("png"),
      .studyAreaName=  "NT",
      jurisdiction = c("NT"),
      .useCache = c(".inputObjects"),
      histLandYears = 2017:2022
    )
    
    
  ),
  
  packages = c('RCurl', 'XML', 'snow', 'googledrive', 'httr2', "terra", "gert", "remotes",
               "PredictiveEcology/reproducible@development", "PredictiveEcology/LandR@development",
               "PredictiveEcology/SpaDES.core@development", "distanceto")
  
  # OUTPUTS TO SAVE -----------------------
  # outputs = {
  #   # save to disk 2 objects, every year
  #   #will add once works, ha
  #
  # }
  
)


results <- SpaDES.core::simInitAndSpades2(out)
results <- SpaDES.core::restartSpades()