; This is a working makefile - use drush make file.make to run it! Any line starting with a `;` is a comment.
  
; Core version
; ------------
; Each makefile should begin by declaring the core version of Drupal that all
; projects should be compatible with.
  
core = 7.x
  
; API version
; ------------
; Every makefile needs to declare its Drush Make API version. This version of
; drush make uses API version `2`.
  
api = 2
  
; Core project
; ------------
; In order for your makefile to generate a full Drupal site, you must include
; a core project. This is usually Drupal core, but you can also specify
; alternative core projects like Pressflow. Note that makefiles included with
; install profiles *should not* include a core project.
  
; Drupal 7.x. Requires the `core` property to be set to 7.x.
projects[drupal][version] = 7

  
  
; Modules
; --------
projects[ctools][version] = 1.4
projects[ctools][type] = "module"

projects[context][version] = 3.2
projects[context][type] = "module"

projects[entity][version] = 1.5
projects[entity][type] = "module"

projects[views][version] = 3.7
projects[views][type] = "module"

projects[jquery_update][version] = 2.4
projects[jquery_update][type] = "module"

; Themes
; --------
; @todo add bootstrap theme
  
  
; Libraries
; ---------
; No libraries were included



