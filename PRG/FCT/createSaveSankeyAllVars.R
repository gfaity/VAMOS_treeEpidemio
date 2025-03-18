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
  library(colorspace)
  myColors <- lighten(desaturate(myColors, amount = 0), amount = 0.2)
  
  
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
  library(ggrepel)
  
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
      alpha      = 0.5, #si contour = 0.8 voir 0.6, sinon 0.5
      label.size = 0, #0.2 #0       # 0.2 = léger contour autour du label, sinon mettre à 0
      fontface   = "bold"  # Texte en gras
    ) +
    # Labels sur strates avec fond blanc
    # ggrepel place les labels de manière à éviter leur chevauchement
    # geom_label_repel( #used instead of geom_label pour admettre le décalage en cas de chevauchement
    #   stat = "stratum",
    #   aes(label = after_stat(stratum)),
    #   size       = 2.8,
    #   color      = "black",
    #   fill       = alpha("white", 0.8), # "white",
    #   max.overlaps = Inf, #for repel only
    #   max.iter = 10000, #for repel only: Augmente les itérations pour s'assurer que seuls les chevauchements évidents sont résolus
    #   segment.color = NA, #for repel only: if set to NA: Supprime les segments de liaison
    #   min.segment.length = 0,  #for repel only: Empêche d'afficher des petits segments inutiles
    #   force = 0.01, #0.3, #for repel only: Force de répulsion entre les labels
    #   box.padding = 0.05, #0.1, #for repel only: Espace minimal autour des labels
    #   direction = "y",       #for repel only: Permet uniquement le déplacement VERTICAL
    #   seed = 1234, #for repel only: reproductibility
    #   #alpha = 0.5, #si contour = 0.8, #on met en commentaire car on l'a passé dans l'argument fill (pour que le texte ne soit pas transparent, mais que le fond)
    #   label.size = 0.2 #0.2 #0       # 0.2 = léger contour autour du label, sinon mettre à 0
    # ) +
  
  
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
  
  # ADDED: modifier la position de quelques labels (chevauchements - non réglable facilement avec ggrepel)
  labelManual = TRUE #set to TRUE to modify the position of some labels
  if (labelManual & all(variable_order==c("Device", "StartYear", "Position", "EpochDuration", "DropTime", "BoutDuration", "StudyID"))){
    # Extraire les positions des labels
    df_label <- ggplot_build(p)$data[[3]]
    df_label$x_old <- df_label$x #save old x
    df_label$y_old <- df_label$y #save old y
    # Modification de certains labels problématiques
    df_label$my_hjust <- 0.5 #alignement au milieu de base
    df_label <- df_label %>%
      mutate(
        x = case_when(
          # deposit == 30 ~ x + 0.1,  #? dans Bout Duration à mettre un peu à droite
          # deposit == 31 ~ x + 0.1,  #1s dans Bout Duration à mettre un peu à droite
          x_old == 1 ~ x - 0.1, # décaler la colonne device vers la gauche
          x_old == 6 ~ x + 0.1, # décaler la colonne bout duration vers la droite
          TRUE ~ x
        ),
        y = case_when(
          deposit == 6 ~ y + 0.5, #Hookie dans Device à monter un peu
          deposit == 30 ~ y - 0.5,  #? dans Bout Duration à descendre un peu
          deposit == 31 ~ y + 0.5,  #1s dans Bout Duration à monter un peu
          TRUE ~ y
        ),
        my_hjust = case_when(
          x_old == 1 ~ my_hjust + 0.5,  #aligne à droite pour la colonne device
          x_old == 6 ~ my_hjust - 0.5,  #aligne à droite pour la colonne device
          TRUE ~ my_hjust
        )
      )
    # Supprimer la couche de label du plot
    p$layers <- p$layers[-3]
    # Ajouter les segments reliant les anciennes et nouvelles positions [avant les labels pour le recouvrement]
    # p <- p +
    #   geom_segment(
    #     data = df_label %>% filter(deposit==30),  # Ne tracer que si la position a changé #x != x_old
    #     aes(x = x_old, xend = x-(x-x_old)*0.4, y = y_old, yend = y-(y-y_old)*0.4),
    #     inherit.aes = FALSE,
    #     color = "black", size = 0.2#, linewidth = 0.5#, linetype = "dashed"
    #   )
    # p <- p +
    #   geom_segment(
    #     data = df_label %>% filter(deposit==31),  # Ne tracer que si la position a changé #x != x_old
    #     aes(x = x_old, xend = x-(x-x_old)*0.6, y = y_old, yend = y-(y-y_old)*0.6),
    #     inherit.aes = FALSE,
    #     color = "black", size = 0.2#, linewidth = 0.5#, linetype = "dashed"
    #   )
    p <- p +
      geom_segment(
        data = df_label %>% filter(x_old==6),  # Ne tracer que pour la colonne Device
        aes(x = x_old, xend = x-(x-x_old)*0, y = y_old, yend = y-(y-y_old)*0),
        inherit.aes = FALSE,
        color = "black", size = 0.2#, linewidth = 0.5#, linetype = "dashed"
      )
    p <- p +
      geom_segment(
        data = df_label %>% filter(x_old==1),  # Ne tracer que pour la colonne Device
        aes(x = x_old, xend = x-(x-x_old)*0, y = y_old, yend = y-(y-y_old)*0),
        inherit.aes = FALSE,
        color = "black", size = 0.2#, linewidth = 0.5#, linetype = "dashed"
      )
    # Réintégrer les labels modifiés dans le plot (en 2 fois car different label size)
    p <- p + geom_label(
      data = subset(df_label, x_old %in% c(1,6)),
      mapping = aes(x = x, y = y, label = label,
                    hjust = my_hjust #alignement sur la droite pour la colonne Device
                    ),
      inherit.aes = FALSE,     # important pour ne pas hériter des aes globaux
      size       = 2.8,
      color      = "black",
      fill       = "white",
      alpha      = 0, #si contour = 0.8 voir 0.6, sinon 0.5
      label.size = 0, #0 # léger contour autour du label = 0.2, sinon mettre à 0
      fontface   = "bold"   # Texte en gras
    )
    p <- p + geom_label(
      data = subset(df_label, !(x_old %in% c(1,6))),
      mapping = aes(x = x, y = y, label = label,
                    hjust = my_hjust #alignement sur la droite pour la colonne Device
      ),
      inherit.aes = FALSE,     # important pour ne pas hériter des aes globaux
      size       = 2.8,
      color      = "black",
      fill       = "white",
      alpha      = 0.6, #si contour = 0.8 voir 0.6, sinon 0.5
      label.size = 0, #0 # léger contour autour du label = 0.2, sinon mettre à 0
      fontface   = "bold"  # Texte en gras
    )
  }
  
    
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
