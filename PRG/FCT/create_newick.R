# Fonction pour créer la chaîne Newick avec les StudyID comme feuilles
create_newick <- function(data, levels) {
  if (length(levels) == 1) {
    # Dernier niveau : utiliser les StudyID comme feuilles
    return(paste(data$StudyID, collapse = ","))
  } else {
    # Niveau intermédiaire : regrouper par le premier niveau
    grouped_data <- data %>%
      group_by(!!sym(levels[1])) %>%
      arrange(!!sym(levels[1])) %>%  # Assurez-vous que l'ordre des niveaux est respecté
      group_split()
    
    sub_trees <- lapply(grouped_data, function(group) {
      sub_tree <- create_newick(group, levels[-1])  # Appel récursif pour les niveaux suivants
      node_label <- unique(group[[levels[1]]])  # Récupérer le label pour ce niveau
      return(paste0("(", sub_tree, ")", node_label))  # Ajouter le label au nœud
    })
    
    return(paste(sub_trees, collapse = ","))
  }
}