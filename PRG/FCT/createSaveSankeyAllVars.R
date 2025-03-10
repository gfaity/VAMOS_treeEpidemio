createSaveSankeyAllVars <- function(
    data,
    variable_order,
    pathSavePlot = NULL,
    plotTitle = "Sankey Diagram - All Variables",
    doSavePlot = TRUE
){
  library(ggalluvial)
  library(dplyr)
  library(forcats)  # Pour forcats::fct_rev
  
  # Colorblind friendly 12-colors palette (rcartocolor)
  myColors <- c("#CC6677", "#88CCEE", "#DDCC77", "#117733", "#332288", "#AA4499", "#44AA99", "#999933", "#882255", "#661100", "#6699CC", "#888888")
  # Convertir en teintes pastel (augmenter la luminance et réduire la saturation)
  # library(colorspace)
  # myColors <- lighten(desaturate(myColors, amount = 0.2), amount = 0.1)
  
  ######################################################
  # OPTIONNEL: Weighting of width for Sankey diagram by nb of combinaison per study
  weightingRibbonWidthPerStudy = TRUE
  if(weightingRibbonWidthPerStudy){
    # Récupérer l'info de quelle article vient chaque ligne
    data <- data %>%
      mutate(StudyDetails = str_replace(StudyID, "_-_[0-9]+$", ""))
    
    #nbCombiMax = max(table(data$StudyDetails)) #pour avoir le nb de combinaison max par article (inutile au final)
    
    # Calcul du nombre d'occurrences pour chaque StudyDetails
    data <- data %>%
      group_by(StudyDetails) %>%
      mutate(RibbonWidth = 1 / n()) %>%
      ungroup()
    
    #Remove useless columns
    data$StudyDetails <- NULL
  }
  ######################################################
  
  # 1) Exclure StudyID
  varList <- setdiff(variable_order, "StudyID")
  
  # 2) Vérif nb de variables
  if (length(varList) > 9) {
    stop("ggalluvial gère jusqu'à 9 axes (axis1..axis9). Veuillez réduire le nombre de variables.")
  }
  if (length(varList) < 2) {
    stop("Besoin d'au moins 2 variables pour un Sankey.")
  }
  
  # -- Inverser l'ordre des levels pour chaque variable
  #    (Ex: si DropTime = c("Yes","No"), on la renverse)
  #    ATTENTION : si un variable n'est pas factor, on saute
  # for (v in varList) {
  #   if (is.factor(data[[v]])) {
  #     data[[v]] <- fct_rev(data[[v]])
  #   }
  # }
  # Pour chaque variable, si c'est un facteur, ajouter un préfixe invisible 
  # afin de rendre chaque niveau unique même si l'affichage reste identique.
  # On ajoute, par exemple, i copies du caractère espace de largeur zéro (\u200B)
  for (i in seq_along(varList)) {
    v <- varList[i]
    if (is.factor(data[[v]])) {
      current_levels <- levels(data[[v]])
      # On ajoute i copies du caractère invisible devant chaque niveau
      new_levels <- paste0(strrep("\u200B", i), current_levels)
      levels(data[[v]]) <- new_levels
      # On inverse ensuite l'ordre des niveaux, comme dans votre code original
      data[[v]] <- fct_rev(data[[v]])
    }
  }
  
  #3) Calcul de la largeur des rubans
  if(weightingRibbonWidthPerStudy){
    # Method B: Calcul des largeurs pondérées par article au lieu de la simple fréquence
    dfSankey <- data %>%
      group_by(across(all_of(varList))) %>%
      summarise(Freq = sum(RibbonWidth), .groups = "drop")  # Somme des largeurs de ruban
    #Remove useless columns
    data$RibbonWidth <- NULL
  } else {
    # Method A: Calculer la fréquence de chaque combinaison
    dfSankey <- data %>%
      group_by(across(all_of(varList))) %>%
      summarise(Freq = n(), .groups = "drop")
  }
  
  # 4) Construire le mapping pour ggalluvial dynamiquement
  axisMapping <- setNames(
    lapply(varList, rlang::sym), 
    paste0("axis", seq_along(varList))
  )
  aesthetic <- do.call(
    aes, 
    c(list(y = rlang::sym("Freq"), fill = rlang::sym(varList[1])),
      axisMapping)
  )
  
  # --- Pour renommer l'affichage sur l'axe X :
  #     ex: "EpochDuration" => "Epoch Duration"
  #     "DropTime" => "Drop Time" etc.
  #     (Les autres restent identiques)
  axisLabels <- varList
  axisLabels[axisLabels == "EpochDuration"] <- "Epoch Duration"
  axisLabels[axisLabels == "DropTime"]      <- "Drop Time"
  axisLabels[axisLabels == "BoutDuration"]  <- "Bout Duration"
  axisLabels[axisLabels == "StartYear"]  <- "Start Year"
  
  # 5) Créer le ggplot
  p <- ggplot(dfSankey, aesthetic) +
    # Flux alluvial, un peu de transparence
    geom_alluvium(alpha = 0.8, width = 1/12, color = NA) +
    # Strates (barres)
    geom_stratum(width = 1/12, fill = "grey95", color = "grey30", size = 0.2) +
    
    # Labels sur strates avec fond blanc
    geom_label(
      stat = "stratum",
      aes(label = after_stat(stratum)),
      size       = 2.8,
      color      = "black",
      fill       = "white",   
      alpha      = 0.8,
      label.size = 0.2 #0       # léger contour autour du label
    ) +
    
    scale_x_discrete(limits = varList, labels = axisLabels) +
    
    # Palette de couleurs #Dark2 works but not beautiful #Set2 is ok but white ?
    #scale_fill_brewer(palette = "Accent", name = "") +
    scale_fill_manual(values = myColors, name = "") +
    
    labs(title = plotTitle, y = "Number of Articles") +
    
    theme_minimal(base_size = 12) +
    theme(
      legend.position  = "top",
      panel.grid       = element_blank(),
      axis.title.x     = element_blank(),
      plot.title       = element_text(face = "bold", size = 14),
      axis.text.x      = element_text(face = "bold"),
      legend.text      = element_text(size = 10)
    )
  
  # 6) Sauvegarder si demandé
  if (doSavePlot && !is.null(pathSavePlot)) {
    ggsave(
      filename = pathSavePlot,
      plot = p,
      dpi = 300,
      width = 10,
      height = 6,
      units = "in",
      bg = "white"    # fond blanc
    )
  }
  
  return(p)
}
