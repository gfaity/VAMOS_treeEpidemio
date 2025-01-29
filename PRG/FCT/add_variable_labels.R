# Fonction pour ajouter les labels des variables sur l'axe X
add_variable_labels <- function(tree, variable_order) {
  # Obtenir le nombre de niveaux
  num_levels <- length(variable_order)
  
  # Créer un dataframe pour les annotations
  annotation_data <- data.frame(
    x = seq(1, num_levels),  # Position en X correspondant aux niveaux
    y = -0.5,  # Position Y en dessous de l'arbre (arbitraire)
    label = variable_order  # Noms des variables
  )
  
  return(annotation_data)
}