createSaveSankey_3var <- function(
    data,
    varList = c("EpochDuration", "DropTime", "BoutDuration"),
    pathSavePlot = NULL,
    plotTitle    = "Sankey Diagram of Studies",
    doSavePlot   = TRUE
) {
  # Charger les librairies
  library(ggalluvial)
  library(dplyr)
  library(forcats)      # pour fct_rev
  library(RColorBrewer) # pour palette "Accent"
  
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
  
  # 1) Vérifier l'existence et la taille de varList
  if (!all(varList %in% names(data))) {
    stop("Certaines variables de varList ne sont pas présentes dans le dataframe.")
  }
  if (length(varList) != 3) {
    stop("Cette fonction est conçue pour EXACTEMENT 3 variables (ex. Epoch->Drop->Bout).")
  }
  
  # 2) Inverser l'ordre des variables -> varList
  #    (par ex. si tu veux Bout en axis1, Drop en axis2, Epoch en axis3)
  #varList <- rev(varList)
  
  # 3) Inverser les levels de chaque variable factor (si besoin)
  #    pour que les catégories soient renversées en vertical
  for (v in varList) {
    if (is.factor(data[[v]])) {
      data[[v]] <- fct_rev(data[[v]])
    }
  }
  
  # 4) Calcul de la largeur des rubans
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
  
  # 5) Colorblind friendly 12-colors palette (rcartocolor)
  myColors <- c("#CC6677", "#88CCEE", "#DDCC77", "#117733", "#332288", "#AA4499", "#44AA99", "#999933", "#882255", "#661100", "#6699CC", "#888888")
  # Convertir en teintes pastel (augmenter la luminance et réduire la saturation)
  # library(colorspace)
  # myColors <- lighten(desaturate(myColors, amount = 0.2), amount = 0.1)
  
  # 6) Préparer les noms d'axes : "EpochDuration" => "Epoch Duration", etc.
  axisLabels <- varList
  axisLabels[axisLabels == "EpochDuration"] <- "Epoch Duration"
  axisLabels[axisLabels == "DropTime"]      <- "Drop Time"
  axisLabels[axisLabels == "BoutDuration"]  <- "Bout Duration"
  
  # 7) Construire le ggplot sankey (3 axes = axis1, axis2, axis3)
  #    ATTENTION : axis1 reçoit varList[1], etc.
  p <- ggplot(
    dfSankey,
    aes(
      axis1 = .data[[varList[1]]],
      axis2 = .data[[varList[2]]],
      axis3 = .data[[varList[3]]],
      y = Freq
    )
  ) +
    # flux
    geom_alluvium(
      aes(fill = .data[[varList[1]]]), # colorier selon la 1re variable reversed
      width = 1/12, alpha = 0.8, color = NA
    ) +
    # strates
    geom_stratum(
      width = 1/12, fill = "grey95", color = "grey30", size = 0.2
    ) +
    # labels sur strates (fond blanc)
    geom_label(
      stat = "stratum",
      aes(label = after_stat(stratum)),
      size       = 3,
      color      = "black",
      fill       = "white",
      alpha      = 0.8,
      label.size = 0.2
    ) +
    
    # Définir l'ordre des axes + labels
    scale_x_discrete(
      limits = varList,
      labels = axisLabels
    ) +
    
    # Palette manuelle
    scale_fill_manual(values = myColors, name = "") +
    
    # Thème minimal + retouche
    theme_minimal(base_size = 12) +
    labs(title = plotTitle, y = "Number of Articles") +
    theme(
      legend.position  = "top",
      panel.grid       = element_blank(),
      axis.title.x     = element_blank(),
      plot.title       = element_text(face = "bold", size = 14),
      axis.text.x      = element_text(face = "bold"),
      legend.text      = element_text(size = 10)
    )
  
  # 8) Sauvegarder si demandé
  if (doSavePlot && !is.null(pathSavePlot)) {
    ggsave(
      filename = pathSavePlot,
      plot = p,
      width = 8, height = 5, dpi = 300,
      bg = "white"
    )
  }
  
  return(p)
}
