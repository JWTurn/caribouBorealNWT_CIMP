# forecasting model
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
  modules = c(
    "PredictiveEcology/Biomass_borealDataPrep@development",
    "PredictiveEcology/Biomass_core@development",
    "PredictiveEcology/Biomass_regeneration@master",
    file.path("PredictiveEcology/scfm@development/modules",
              c("scfmDataPrep",
                "scfmIgnition", "scfmEscape", "scfmSpread",
                "scfmDiagnostics")),
    "JWTurn/caribou_SSUD@main"
  ),
  params = list(
    .globals = list(
      .plots = c("png"),
      .studyAreaName=  "NT",
      jurisdiction = c("NT"),
      outputFolderID = 'https://drive.google.com/drive/folders/18fAJOS4Q2pjKMaBPcBBR9N1sn0UOrBVf?usp=share_link',
      .useCache = c(".inputObjects"),
      modelScale = "jurisdictional",
      dataYear = 2020,
      sppEquivCol = "LandR",
      normalizePDE = TRUE

  ),
  scfmDataPrep = list(
    targetN = 3000,
    .useParallelFireRegimePolys = TRUE
  ),

  caribou_SSUD = list(
    simulationProcess = "dynamic",
    simulationScale = "jurisdictional"
  )
),

  packages = c('RCurl', 'XML', 'snow', 'googledrive', 'httr2', "terra", "gert", "remotes",
               "PredictiveEcology/reproducible@development", "PredictiveEcology/LandR@development",
               "PredictiveEcology/SpaDES.core@development"),

  studyArea = reproducible::prepInputs(url = 'https://drive.google.com/file/d/1YOsRhBImlNuoAU4Jkdkz9tMeTfPaF_jq/view?usp=share_link',
                                       fun = 'terra::vect',
                                       destinationPath = 'inputs'),
  times = list(start = 2020, end = 2050),

  studyAreaLarge = {
    terra::buffer(studyArea, 2000)
  },

  studyAreaCalibration = studyAreaLarge,

  rasterToMatchLarge = {
    rtml <- terra::rast(file.path('outputs', 'rtm_extendedLandscape.tif')) # saved from model output
    rtml[] <- 1
    terra::mask(rtml, studyAreaLarge)
  },

  rasterToMatch = {
    reproducible::postProcess(rasterToMatchLarge, cropTo = studyArea, maskTo = studyArea)
  },

  rasterToMatchCoarse = {
    terra::aggregate(rasterToMatch, 2)
  },

  rasterToMatchCalibration = rasterToMatchLarge,

  ## scfm workaround retained
  treedFirePixelTableSinceLastDisp = data.table::data.table(
    pixelIndex = integer(), pixelGroup = integer(), burnTime = numeric()
  ),

  sppEquiv = {
    speciesInStudy <- LandR::speciesInStudyArea(studyAreaLarge, dPath = paths$inputPath)
    species <- LandR::equivalentName(speciesInStudy$speciesList, df = LandR::sppEquivalencies_CA, "LandR")
    sppEquiv <- LandR::sppEquivalencies_CA[LandR %in% species]
    sppEquiv <- sppEquiv[KNN != "" & LANDIS_traits != ""]
    sppEquiv
  },

  iSSAmodels = list(reproducible::prepInputs(url = 'https://drive.google.com/file/d/13ag0CfPH6vRp8vboMTaFrDZK9JU7GhAp/view?usp=share_link',
                                             fun = 'load',
                                             destinationPath = 'outputs')) |>
      Cache(),

  modelLand = reproducible::prepInputs(url = 'https://drive.google.com/file/d/1RRZLvriQTtIEYl-ISiDqJaVA_LO7n95v/view?usp=share_link',
                                       fun = 'terra::rast',
                                       destinationPath = 'outputs'),

  studyAreaCaribou = studyArea
    ,

  studyArea_juris = rasterToMatch
    # reproducible::prepInputs(url = 'https://drive.google.com/file/d/1KcJ9oPTEsWYZAX4rHi2p84y0LjLhjtvJ/view?usp=share_link',
    #                                          fun = 'readRDS',
    #                                          destinationPath = 'outputs')

  # OUTPUTS TO SAVE -----------------------
  # outputs = {
  #   # save to disk 2 objects, every year
  #   #will add once works, ha
  #
  # }

)


results <- SpaDES.core::simInitAndSpades2(out)
results <- SpaDES.core::restartSpades()
