# Fonction principale pour créer l'arbre
create_tree <- function(data, variable_order = c("Position", "Device", "DropTime", "EpochDuration", "StudyID")) {
  
  # Vérifier que toutes les variables de l'ordre existent dans le dataframe
  if (!all(variable_order %in% names(data))) {
    stop("Les variables spécifiées dans 'variable_order' ne sont pas toutes présentes dans le dataframe.")
  }
  
  # Regrouper les données en fonction de l'ordre des variables
  hierarchical_data <- data %>%
    group_by(across(all_of(variable_order))) %>%
    arrange(across(all_of(variable_order))) %>%  # Maintenir l'ordre des niveaux
    summarise(Studies = paste(StudyID, collapse = ", "), .groups = "drop")
  
  # Générer la chaîne Newick
  newick_string <- paste0("(", create_newick(hierarchical_data, variable_order), ");")
  
  # Créer l'arbre avec ape
  tree <- read.tree(text = newick_string)
  
  return(tree)
}
