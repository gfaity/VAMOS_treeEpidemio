createSavePlotTree <- function (data, variable_order, savePlot, pathSavePlot, plotTitle){
  
  # Pour la v2 = 1 seule feuille contenant toutes les études (du dernier embranchement)
  only1leave = FALSE #FALSE #TRUE #HUMAN CHOICE
  if (only1leave){
    #Create interaction so that 1 level of "interaction" will be 1 leaf (and could contain 1 or multiple studies) 
    data$interact <- interaction(data$Position, data$Device, data$EpochDuration, data$DropTime, data$BoutDuration, sep="+")
    #Get a number per study
    data <- data %>%  mutate(StudyIDNb = row_number())
    
    #Export and print this number (for human reading)
    indexArticles <- interaction(data$StudyIDNb, data$StudyID, sep=" : ")
    indexArticles <- gsub("_", " ", indexArticles)
    indexArticles <- gsub("@", ",", indexArticles)
    cat(paste("\n\n Correspondance between indexes and articles:\n\n", paste(indexArticles, collapse = "\n"), "\n\n", sep=""))
    
    # Création du nouveau dataframe en conservant les autres colonnes
    data <- data %>%
      group_by(interact) %>%  # Regroupement par les niveaux de interact
      summarise(
        StudyID = paste(StudyID, collapse = "+"),  # Concaténation de StudyID 
        StudyIDNb = paste(StudyIDNb, collapse = ", "), # Concaténation de StudyIDNb
        across(-c(StudyID, StudyIDNb), first)  # Conserver les autres colonnes
      ) %>%
      ungroup()  # Retirer le regroupement
    data$interact <- NULL
    
    # Compter le nombre d'article pour chaque leaf
    nb_articles <- nchar(gsub("[^+]", "", data$StudyID))+1
    
    # Add this number to the leaf
    #data$StudyID <- paste(nb_articles, " article(s) (", data$StudyID, ")" ,sep="") #possibility 1 (but too long)
    #data$StudyID <- paste(nb_articles, " article(s)", sep="") #possibility 2 (but no detailed info)
    data$StudyID <- paste(nb_articles, " article(s) (", data$StudyIDNb, ")" ,sep="") #possibility 1 (but too long)
    data$StudyIDNb <- NULL
    
    #We need to change before construction tree (because prbl with newick)
    data$StudyID <- gsub(" ", "_", data$StudyID)
    data$StudyID <- gsub(",", "@", data$StudyID)
    data$StudyID <- gsub("\\(", "parOpen", data$StudyID)
    data$StudyID <- gsub("\\)", "parClose", data$StudyID)
  }
  
  # Génère un arbre fictif
  #tree <- create_tree(data) # Appeler la fonction avec l'ordre par défaut
  tree <- create_tree(data, variable_order) # Appeler la fonction avec un ordre personnalisé
  tree$tip.label <- gsub("_", " ", tree$tip.label) #to re-change after constructing tree
  tree$tip.label <- gsub("@", ",", tree$tip.label) #to re-change after constructing tree
  tree$tip.label <- gsub("parOpen", "\\(", tree$tip.label)
  tree$tip.label <- gsub("parClose", "\\)", tree$tip.label)
  
  # Générer les annotations pour les noms des variables
  variable_labels <- add_variable_labels(tree, variable_order)
  
  # Créer un plot
  p <- getPlotTree(tree, variable_labels, plotTitle, only1leave)
  
  # Print plot
  print(p)
  
  # Save plot
  if (savePlot){
    adjustDynamically = T
    
    if(adjustDynamically){
      #tip height  # on ajuste le « 4 » selon le rendu souhaité
      tipH <- 6 #6 is nice if color fill #4.8 #4.8 is nice if not fill #4.2 is old
      
      # On calcule la hauteur en se basant sur le nombre de tips
      nTips        <- length(tree$tip.label)
      #dynamicWidth <- 800 #1000                    # ou un autre chiffre de base
      dynamicWidth <- 350 #300 #nouvelle version condensée
      dynamicHeight <- tipH * nTips         
      
      #save
      ggsave(
        filename = pathSavePlot, 
        plot     = p, 
        dpi      = 300,
        units    = "mm",         # en mm
        width    = dynamicWidth,
        height   = dynamicHeight,
        limitsize = FALSE
      )
      
    } else {
      #ggsave(filename = file.path(RES_PATH, "Arbre_Descriptif_Publication.png"), plot = p, width = 12, height = 8, dpi = 300)
      ggsave(filename = pathSavePlot, plot = p, dpi = 300)
    }
  }
  
  # *** Analyse statistique sur les associations entre variables ***
  #    On peut définir un vecteur "varList" pour la liste de variables qualitatives
  myVars <- variable_order[which(variable_order != "StudyID")] #all variables except StudyID
  # 1) Associations: Appel de la fonction + export CSV
  statsResults <- computeAssociationsEpi(
    data    = data,
    varList = myVars,
    outCSV  = file.path(dirname(pathSavePlot), "Associations_Epi.csv")  # ex. même dossier que le plot
  )
  # 2) Descriptifs: statistiques descriptives par pairs (table de contingence)
  descResults <- descStatsByPair(
    data        = data,
    varList     = myVars,
    outCSVdesc  = file.path(dirname(pathSavePlot), "Descriptive_ByPair.csv")
  )
  
  # =============== Exporter ces tables en PDF/PNG ===============
  
  doExportTablesPNG = FALSE #FALSE #TRUE #TRUE to export tables in png (caution big tables take time to be exported) #HUMAN CHOICE
  
  if (doExportTablesPNG) {
    # for white background in png (comment to remove background)
    set_flextable_defaults(background.color = "white") 
    
    ### -- 1) statsResults
    if (!is.null(statsResults) && nrow(statsResults) > 0) {
      # Arrondir
      statsResults$pValue <- round(statsResults$pValue, 4)
      statsResults$pValue_adj <- round(statsResults$pValue_adj, 4)
      if ("effectSize(CramerV_or_phi)" %in% names(statsResults)) {
        statsResults[["effectSize(CramerV_or_phi)"]] <- round(statsResults[["effectSize(CramerV_or_phi)"]], 3)
      }
      
      ftStats <- flextable(statsResults) |> autofit()
      
      # Sauvegarde PNG
      stats_png <- file.path(dirname(pathSavePlot), "Associations_Epi.png")
      save_as_image(ftStats, path = stats_png)
      
      # Sauvegarde PDF
      # stats_pdf <- file.path(dirname(pathSavePlot), "Associations_Epi.pdf")
      # save_as_pdf(ftStats, path = stats_pdf)
    }
    
    ### -- 2) descResults
    if (!is.null(descResults) && nrow(descResults) > 0) {
      # Arrondir
      descResults$count   <- round(descResults$count, 2)
      descResults$rowPerc <- round(descResults$rowPerc, 2)
      descResults$colPerc <- round(descResults$colPerc, 2)
      descResults$totPerc <- round(descResults$totPerc, 2)
      
      ftDesc <- flextable(descResults) |> autofit()
      
      # Sauvegarde PNG
      desc_png <- file.path(dirname(pathSavePlot), "Descriptive_ByPair.png")
      save_as_image(ftDesc, path = desc_png)
      
      # Sauvegarde PDF
      # desc_pdf <- file.path(dirname(pathSavePlot), "Descriptive_ByPair.pdf")
      # save_as_pdf(ftDesc, path = desc_pdf)
    }
  }
  
  
  # =============== SANKEY DIAGRAM ===============
  
  # Supposez qu'on a déjà 'data' et un 'variable_order'
  # par exemple : variable_order = c("Position","Device","EpochDuration","DropTime","BoutDuration","StudyID")
  
  pathSankey <- gsub("Arbre_Descriptif", "SankeyDiagram", pathSavePlot)
  mySankey <- createSaveSankeyAllVars(
    data            = data,
    variable_order  = variable_order,       # On transmet l'ordre, StudyID sera exclu
    pathSavePlot    = pathSankey,
    plotTitle       = "Sankey Diagram - All Variables",
    doSavePlot      = TRUE
  )
  #print(mySankey)  # Affiche le plot
  
}