# animated map

require(data.table)
require(terra)
require(tidyterra)
require(viridis)
require(ggplot2)
require(gganimate)
require(gifski)

## load results ----
files <- list.files(path = file.path('outputs','simPDE'))
results <- data.table(files = files[files %like% 'pdeMap' & !(files %like% '.aux')])
results[,names := stringr::str_extract(files, "(?<=pdeMap_).*(?=.tif)")]

pdeMaps <- rast(file.path('outputs', 'simPDE', results$files))
names(pdeMaps) <- results$names



p.pdeMaps<- ggplot() +
  geom_spatraster(data = as.numeric(pdeMaps), show.legend = T) +
  scale_fill_gradientn(colours = mako(10),na.value = NA, limits = c(0,10)) +
  theme_bw() +
  theme(plot.title=element_text(size=12,hjust = 0.05),axis.title = element_blank()) +
  theme_void() +
  labs(fill = 'Intensity of selection') +
  coord_sf(crs = 3978) +
  transition_manual(lyr) +
  labs( title = "{current_frame}")

num_frames <- length(results$files)
# animates as gif
animate(p.pdeMaps, nframes = num_frames, fps = 1)
animsPath <- reproducible::checkPath(file.path('outputs', 'anims'), create = T)
anim_save(file.path(animsPath, "pdeMaps_nt.gif"))

