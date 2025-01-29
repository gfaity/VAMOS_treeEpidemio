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
  
  # Conservez les nœuds internes dans l'ordre des facteurs
  #   !!! There is no alternative function in R that can read a Newick string and create an equivalent tree structure while preserving the node order as specified in the Newick string.
  #     Explanation:
  #     Newick Format Limitations: The Newick format is designed to represent tree structures where the order of branches (nodes) is not significant. It encodes the tree topology but does not enforce an ordering of nodes. Therefore, when parsing a Newick string, functions like read.tree focus on reconstructing the tree's connections (parent-child relationships) rather than preserving any specific order of nodes as they appear in the string.
  #     Phylo Object Structure: The phylo object in R, which is the standard structure for phylogenetic trees, does not store information about the order of nodes. It represents the tree using an edge matrix and labels, focusing on the connections between nodes rather than their sequence.
  #     Internal Reordering: When read.tree parses the Newick string, it often reorders nodes internally for computational efficiency and to standardize the tree structure. This reordering is inherent to how phylogenetic trees are handled in R.
  # TODO ??
  
  return(tree)
}
