getPlotTree <- function(tree, variable_labels, plotTitle, only1leave){
  
  # (1) Transformations "cosmétiques" sur variable_labels
  # remove StudyID from variable_labels
  variable_labels <- subset(variable_labels, label!="StudyID")
  if ("DropTime"%in%variable_labels$label) {
    variable_labels$label[variable_labels$label=="DropTime"] <- "Drop Time"
  }
  if ("EpochDuration"%in%variable_labels$label) {
    variable_labels$label[variable_labels$label=="EpochDuration"] <- "Epoch Duration"
  }
  
  # =============== 2) Définir toutes tes palettes  ===============
  
  dropTimeColors <- c(
    "No"   = "#E74C3C",
    "Yes"  = "#2ECC71"
  )
  
  boutDurationColors <- c(
    "10-32s"    = "#c6dbef", # plus clair
    "1min"      = "#9ecae1",
    "2-5min"    = "#6baed6",
    "10min"     = "#3182bd",
    "15-60min"  = "#08519c", # plus foncé
    "?"         = "#cccccc"  # gris pour l’incertitude
  )
  
  epochColors <- c(
    "4-6s" = "#dadaeb", # plus clair
    "10s"  = "#bcbddc", # plus foncé
    "30s"  = "#9e9ac8",
    "60s"  = "#6a51a3",
    "?"    = "#cccccc"  # gris pour l’incertitude
  )
  
  deviceColors <- c(
    "SenseWear"    = "#1b9e77",  # Vert foncé
    "Lifecorder"   = "#d95f02",  # Orange
    "Hookie"       = "#7570b3",  # Bleu violet
    "GENEActiv"    = "#e7298a",  # Rose
    "Axivity"      = "#66a61e",  # Vert clair
    "ActivPAL"     = "#e6ab02",  # Jaune moutarde
    "Activestyle" = "#a6761d",  # Brun foncé #space
    "Actigraph"    = "#666666",  # Gris neutre
    "Actical"      = "#1f78b4"   # Bleu profond
  )
  
  positionColors <- c(
    "Wrist"       = "#fb8072",
    "Hip/Waist" = "#80b1d3", #space
    "Thigh"       = "#fdb462",
    "Upperarm"   = "#faaab3", #space
    "Other"       = "#cccccc"
  )
  
  # Fusion de toutes les couleurs (un seul vecteur nommé)
  myColorMapping <- c(
    dropTimeColors,
    boutDurationColors,
    epochColors,
    deviceColors,
    positionColors
  )
  
  # =============== 3) Plot standard ggtree ===============
  
  #option
  plotRectEnhance <- FALSE #TRUE #if True, plot rectangular enhancement with annotate  #HUMAN CHOICE
  if (plotRectEnhance){
    xlimCt <- 1.5
  } else {
    xlimCt <- 1
  }
  if (only1leave){
    xlimCt <- xlimCt + 0.5
  }
  
  
  # Visualisation avec ggtree 
  p <- ggtree(tree, layout = "rectangular", ladderize = FALSE) +
    # Alignement et style des labels des feuilles
    geom_tiplab(
      size = 4, align = TRUE, linetype = "dotted", color = "gray20"
    )
  
  
  # Labels des nœuds internes en gras (+ colorés selon le label if doFillColor)
  doFillColor <- TRUE #CAUTION: we cannot have TRUE here if doSimpleLeaves is FALSE  #HUMAN CHOICE
  
  if (doFillColor){
    p <- p + geom_label2(
      aes(
        subset = !isTip,
        label = label,
        fill = label # added: on map le fill sur le label
      ),
      nudge_x = -0.05,
      hjust = 1,
      nudge_y = 0.05,
      #vjust = 1.2,
      size = 4,
      color = "white", #"darkblue", # texte en blanc si fill en couleur actif dans aes, sinon en bleu
      fontface = "bold.italic",
      #fill="white", # to uncomment si fill en couleur n'est pas actif dans aes(fill=label)
      alpha = 1,
      label.size = 0
    )
  } else {
    # ne pas colorer selon le level
    p <- p + geom_label2(
      aes(
        subset = !isTip,
        label = label
      ),
      nudge_x = -0.05,
      hjust = 1,
      nudge_y = 0.05,
      #vjust = 1.2,
      size = 4,
      color = "darkblue", # texte en blanc si fill en couleur actif dans aes, sinon en bleu
      fontface = "bold.italic",
      fill="white", # to uncomment si fill en couleur n'est pas actif dans aes(fill=label)
      alpha = 1,
      label.size = 0
    )
  }
  
  # Thème / titre
  p <- p +
    theme_tree2(base_size = 12) +  # Base des tailles optimisée pour publication
    ggtitle(plotTitle) +  # Titre
    theme(
      plot.title = element_text(size = 20, face = "bold", hjust = 0.5),  # Titre centré et agrandi
      axis.text.x = element_blank(),  # Texte de l'axe X supprimé
      axis.line.x = element_blank(), # Supprimer l'axe X #element_line(color = "gray"),  # Ligne de l'axe X ajoutée
      axis.line.y = element_blank(),  # Supprimer l'axe Y
      axis.ticks.x = element_blank(), # Supprimer les ticks sur l'axe X
      panel.background = element_rect(fill = "white"),  # Fond blanc
      panel.grid = element_blank(),  # Supprimer les grilles
      plot.margin = margin(t = 10, r = 10, b = 10, l = 0)  # Ajuster les marges
    ) +
    # Ajouter les labels des variables sur l'axe X
    geom_text(
      data = variable_labels,
      aes(x = x, y = y, label = label),
      nudge_x = -0.25, #-0.05
      #vjust = 4,
      nudge_y = length(tree$tip.label)+2,
      inherit.aes = FALSE,
      size = 5,
      color = "gray20",
      fontface = "bold"
    ) +
    #nudge_y = length(tree$tip.label)+1.4
    xlim(NA, length(variable_order) + xlimCt) +#1.0) + #+0.2 # Étendre l'axe X
    coord_cartesian(clip = "off") + # Permet d'afficher les éléments plot limits +
    geom_hline(yintercept = length(tree$tip.label)+0.8) #0.4
  
  if (doFillColor){
    # La palette manuelle: on "verrouille" le fill = label
    p <- p +
      scale_fill_manual(
        values = myColorMapping,
        na.value = "white" #"grey80" # si un label échappe à la liste on ne l'affiche pas
      ) +
      guides(fill = "none")  # **Supprime la légende des couleurs de fill**
  }
  
  # Ajoutez des annotations pour marquer des groupes spécifiques ou des clusters dans l'arbre. Vous pouvez utiliser geom_highlight de la librairie ggtree.
  #   Potentiellement utile pour mettre en valeur le groupe principal ?
  #p <- p + geom_hilight(node = 8, fill = "lightblue", alpha = 0.3)  # Exemple pour surligner un cluster
  
  # Plus simple d'ajouter directement un rectangle manuellement
  # Spécifiez vos coordonnées ici
  if(plotRectEnhance){
    xmin <- 0.5#0.5  # À ajuster selon vos besoins
    xmax <- 7.5 #6 #7.5 #5  # À ajuster selon vos besoins
    ymin <- 19.5#0.5  # À ajuster selon vos besoins
    ymax <- 39.5#8.5 # À ajuster selon vos besoins
    p <- p + annotate("rect", xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                      fill = "lightblue", alpha = 0.3)
  }
  
  return(p)
}