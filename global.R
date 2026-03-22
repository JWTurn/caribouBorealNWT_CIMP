repos <- c("https://predictiveecology.r-universe.dev", getOption("repos"))
source("https://raw.githubusercontent.com/PredictiveEcology/pemisc/refs/heads/development/R/getOrUpdatePkg.R")
getOrUpdatePkg(c("Require", "SpaDES.project"), c("1.0.1.9024", "1.0.1.9000")) # only install/update if required
#Require::Install("PredictiveEcology/SpaDES.core@development")

projPath = "~/git-local/caribouBorealNWT_CIMP"
reproducibleInputsPath = "~/git-local/reproducibleInputs"

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
              'gc-rmcinnes/extractLand@main'
              ,'gc-rmcinnes/caribouiSSA@main'

  ),
  params = list(
    .globals = list(
      .plots = c("png"),
      .studyAreaName=  "NT",
      jurisdiction = c("NT"),
      MoveBankUser = 'jwturner',
      MoveBankPass = keyring::key_get("movebank", "jwturner"),
      outputFolderID = 'https://drive.google.com/drive/folders/18fAJOS4Q2pjKMaBPcBBR9N1sn0UOrBVf?usp=share_link',
      .useCache = c(".inputObjects"),
      # I don't know why the nfdb website isn't sharing earlier than 1972 right now March 2026
      nfdbURL = 'https://drive.google.com/file/d/1CUXHf_32ERn6uN_g8xJ65cqG4zQobc-U/view?usp=share_link',
      histLandYears = 2017:2022,
      modelScale = 'jurisdictional',
      iSSAformula = "case_ ~ -1 +
                              I(log(sl_ + 1)) +
                              I(cos(ta_)) +
                              I(log(sl_ + 1)) : I(cos(ta_)) +
                              prop_needleleaf_start : I(log(sl_ + 1)) +
                              prop_mixedforest_start : I(log(sl_ + 1)) +
                              prop_veg_start : I(log(sl_ + 1)) +
                              prop_wets_start : I(log(sl_ + 1)) +

                              prop_needleleaf_end +
                              prop_mixedforest_end +
                              prop_veg_end +
                              prop_wets_end +
                              I(log(timeSinceFire_end + 1)) +
                              I(log(timeSinceHarvest_end + 1)) +
                              I(log(distpaved_end + 1)) +
                              I(log(distunpaved_end + 1)) +
                              I(log(distpolys_end + 1)) +
                              (1 | indiv_step_id) +
                              (0 + I(log(sl_ + 1)) | id) +
                              (0 + I(cos(ta_)) | id) +
                              (0 + I(log(sl_ + 1)) : I(cos(ta_)) | id) +
                              (0 + prop_needleleaf_start : I(log(sl_ + 1)) | id) +
                              (0 + prop_mixedforest_start : I(log(sl_ + 1)) | id) +
                              (0 + prop_veg_start : I(log(sl_ + 1)) | id) +
                              (0 + prop_wets_start : I(log(sl_ + 1)) | id) +
                              (0 + prop_needleleaf_end | id) +
                              (0 + prop_mixedforest_end | id) +
                              (0 + prop_veg_end | id) +
                              (0 + prop_wets_end | id) +
                              (0 + I(log(timeSinceFire_end + 1)) | id) +

                              (0 + I(log(timeSinceHarvest_end + 1)) | id) +

                              (0 + I(log(distpaved_end + 1)) | id) +
                              (0 + I(log(distunpaved_end + 1)) | id) +
                              (0 + I(log(distpolys_end + 1)) | id) +

                              (1 | year)"
    )


  ),

  packages = c('RCurl', 'XML', 'snow', 'googledrive', 'httr2', "terra", "gert", "remotes",
               "PredictiveEcology/reproducible@development", "PredictiveEcology/LandR@development",
               "PredictiveEcology/SpaDES.core@development", "distanceto"),

  studyArea = reproducible::prepInputs(url = 'https://drive.google.com/file/d/1YOsRhBImlNuoAU4Jkdkz9tMeTfPaF_jq/view?usp=share_link',
                                       fun = 'terra::vect',
                                       destinationPath = 'inputs')

  # OUTPUTS TO SAVE -----------------------
  # outputs = {
  #   # save to disk 2 objects, every year
  #   #will add once works, ha
  #
  # }

)


results <- SpaDES.core::simInitAndSpades2(out)
results <- SpaDES.core::restartSpades()

writeRaster(results$rasterToMatch_extendedLandscape, file.path('outputs', 'rtm_extendedLandscape.tif'))


