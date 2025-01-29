# ### 3. Ajouter des **statistiques descriptives** ou « post-hoc »
# 
# Pour **interpréter** le fait que (par exemple) “BoutDuration” et “DropTime” semblent associées, il est utile de voir **comment** se répartissent les niveaux.  
# - Ex.: “Lorsque `BoutDuration` = 10-32s, on trouve 70 % d’articles avec `DropTime = No`”.  
# - Ce sont des **pourcentages de contingence**.
# 
# Ci-dessous, on ajoute une **nouvelle fonction** `descStatsByPair()` qui **compile** pour chaque paire \((v1, v2)\) :
#   
#   1. Le **compte brut** \((n_{ij})\) pour chaque combinaison \((i, j)\).
# 2. Les **pourcentages ligne** (Row%), **pourcentages colonne** (Col%), et/ou **pourcentage global** (Total%).
# 
# Ensuite, on peut **exporter** ces stats dans un fichier CSV, pour en discuter dans ta section “Résultats/Discussion”.
#
# **Fonctionnement** :
#   
#   - Pour chaque paire \((v1, v2)\), on **décortique** la table de contingence :  
#   - `count` = nombre d’articles ayant `var1 = level1` et `var2 = level2`.  
#   - `rowPerc` = `% de la ligne` (par rapport à tous les articles de `level1`).
#   - `colPerc` = `% de la colonne` (par rapport à tous les articles de `level2`).
#   - `totPerc` = `% du total` (par rapport à la totalité des lignes + colonnes).
#   - On **empile** tout dans un data.frame final, qu’on peut **exporter** pour analyse.  
#
# Cela te permettra de voir, par exemple, qu’avec `BoutDuration = "10-32s"`, on a `X` articles en tout, dont un certain pourcentage ont `DropTime = "Yes"`, etc.  
# **Ce tableau** est très utile pour **conforter l’interprétation** des p-values.

descStatsByPair <- function(data, varList, outCSVdesc = NULL) {
  # data       : data.frame
  # varList    : vecteur de noms de variables
  # outCSVdesc : chemin d'export CSV
  
  # On stockera tout dans un data.frame long
  outDF <- data.frame(
    var1    = character(),
    var2    = character(),
    level1  = character(),
    level2  = character(),
    count   = numeric(),
    rowPerc = numeric(),
    colPerc = numeric(),
    totPerc = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (i in seq_len(length(varList) - 1)) {
    for (j in (i+1):length(varList)) {
      v1 <- varList[i]
      v2 <- varList[j]
      
      # Table brute
      tab <- table(data[[v1]], data[[v2]])
      
      # Calcule les pourcentages
      rowSum <- rowSums(tab)
      colSum <- colSums(tab)
      total  <- sum(tab)
      
      # Convertir en "long format"
      # On parcourt chaque combinaison (l, c)
      for (r in rownames(tab)) {
        for (c in colnames(tab)) {
          countRC <- tab[r, c]
          # rowPerc = proportion dans la ligne r
          rp <- ifelse(rowSum[r] == 0, 0, 100 * countRC / rowSum[r])
          # colPerc = proportion dans la colonne c
          cp <- ifelse(colSum[c] == 0, 0, 100 * countRC / colSum[c])
          # totPerc = proportion dans le total
          tp <- 100 * countRC / total
          
          # Ajouter une ligne
          outDF <- rbind(
            outDF,
            data.frame(
              var1    = v1,
              var2    = v2,
              level1  = r,
              level2  = c,
              count   = as.numeric(countRC),
              rowPerc = rp,
              colPerc = cp,
              totPerc = tp,
              stringsAsFactors = FALSE
            )
          )
        }
      }
    }
  }
  
  # Export CSV si demandé
  if (!is.null(outCSVdesc)) {
    write.csv2(outDF, file = outCSVdesc, row.names = FALSE)
  }
  
  return(outDF)
}
