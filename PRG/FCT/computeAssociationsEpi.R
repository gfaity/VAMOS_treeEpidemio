computeAssociationsEpi <- function(data, varList, 
                                   correctionMethod = "BH", 
                                   outCSV = NULL) {
  
  # data   : data.frame contenant les variables catégorielles
  # varList: vecteur de noms de variables à tester deux à deux
  # outCSV : chemin (ou NULL) pour exporter le tableau de résultats en CSV
  # correctionMethod="bonferroni"   # ultra conservateur
  # correctionMethod="holm"        # Holm-Bonferroni
  # correctionMethod="BH"          # FDR (Benjamini-Hochberg) (bon comprimis)
  
  
  # On stocke d’abord tous les résultats en "liste" pour 
  # pouvoir ajuster les p-values après coup
  raw_results <- list()
  
  for (i in seq_len(length(varList) - 1)) {
    for (j in seq(i + 1, length(varList))) {
      
      v1 <- varList[i]
      v2 <- varList[j]
      
      # Construire la table de contingence
      tab <- table(data[[v1]], data[[v2]])
      n   <- sum(tab)
      
      # 1) Chi-2 "de base" pour calculer la statistique et potentiellement la taille d'effet
      suppressWarnings({
        chi2_res <- chisq.test(tab, correct = FALSE)
      })
      chi2_stat <- as.numeric(chi2_res$statistic)
      df        <- chi2_res$parameter
      # Si chi2_res$statistic = 0 (table degenerate), attention
      # On peut check if (nrow(tab) == 1 || ncol(tab) == 1) => skip
      
      # 2) Calcul de l'effet size (Cramér's V ou phi)
      #    -> si table 2x2, c'est phi = sqrt(chi2 / n)
      #    -> sinon V = sqrt((chi2 / n) / (k - 1))
      r <- nrow(tab)
      c <- ncol(tab)
      k <- min(r, c)
      
      effect_size <- NA_real_
      if (r == 2 && c == 2) {
        # phi
        effect_size <- if (chi2_stat > 0) sqrt(chi2_stat / n) else 0
      } else {
        # Cramér’s V
        if (k > 1 && chi2_stat > 0) {
          effect_size <- sqrt((chi2_stat / n) / (k - 1))
        }
      }
      
      # 3) Choix du test => la p-value "officielle"
      
      # Règle: si c'est 2x2 => Fisher standard
      # Sinon, si +20% cells <5 => FisherSim
      # Sinon Chi2
      expected  <- chi2_res$expected
      low_cells <- sum(expected < 5)
      perc_low  <- 100 * (low_cells / length(expected))
      
      test_used <- NA_character_
      p_val     <- NA_real_
      
      if (r == 2 && c == 2) {
        # 2x2 => Fisher standard
        #Cas 2x2 : on préfère Fisher (sauf si table énorme → simulation)
        # On fait un test de Fisher standard (2x2)
        # Si jamais message mémoire → on peut passer à simulate=TRUE
        f2 <- fisher.test(tab)
        p_val <- f2$p.value
        test_used <- "Fisher_2x2"
        
      } else {
        #Table > 2x2
        # On regarde si +20% des expected < 5 => basculer sur Fisher simulate
        # Cela signifie que, pour chaque paire de variables, plus de 20% des effectifs attendus dans la table de contingence étaient < 5. Dans le code actuel, cela déclenche un test exact de Fisher (avec simulation Monte-Carlo) au lieu du Chi-2
        # En clair, si perc_low > 20, les tables ont suffisamment de combinaisons « rares » pour que le Chi-2 soit considéré « non fiable » selon la règle “> 20% de cellules < 5”.
        # Autre stratégie plus “épidémio” :
        # Si tu as beaucoup de catégories (ex. Device = 9 niveaux, Position = 4 niveaux), tu peux regrouper certaines modalités pour réduire la taille du tableau et augmenter les fréquences par cellule. Ainsi, le test du Chi-2 devient plus approprié.
        if (perc_low > 20) {
          # => fisher simulate
          f2 <- fisher.test(tab, simulate.p.value = TRUE, B = 10000)
          p_val <- f2$p.value
          test_used <- "FisherSim"
        } else {
          p_val <- chi2_res$p.value
          test_used <- "Chi2"
        }
      }
      
      raw_results[[paste0(v1,"~",v2)]] <- list(
        var1    = v1,
        var2    = v2,
        testUsed= test_used,
        pValue  = p_val,
        effectSize = effect_size  # phi ou Cramér’s V
      )
    }
  }
  
  # --------- AJUSTEMENT DES P-VALUES ----------
  # 1) Extraire toutes les p-values
  allKeys <- names(raw_results)
  pvals <- sapply(raw_results, function(x) x$pValue)
  
  # 2) Appliquer p.adjust
  padj <- p.adjust(pvals, method = correctionMethod)
  
  # 3) Remettre dans la structure
  for (k in seq_along(allKeys)) {
    raw_results[[ allKeys[k] ]][["pValue_adj"]] <- padj[k]
  }
  
  # Convertir en data.frame
  df_out <- do.call(rbind, lapply(raw_results, as.data.frame))
  rownames(df_out) <- NULL
  
  # Optionnel: renommer effectSize en "CramerV_or_phi"
  names(df_out)[names(df_out)=="effectSize"] <- "effectSize(CramerV_or_phi)"
  
  # Export CSV si besoin
  if (!is.null(outCSV)) {
    write.csv2(df_out, file = outCSV, row.names = FALSE)
  }
  
  return(df_out)
}
