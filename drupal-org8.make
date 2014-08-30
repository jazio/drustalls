; This is a working makefile - use drush make file.make to run it! Any line starting with a `;` is a comment.
  
; Core version
; ------------
; Each makefile should begin by declaring the core version of Drupal that all
; projects should be compatible with.
  
core = 8.x
  
; API version
; ------------
; Every makefile needs to declare its Drush Make API version. This version of
; drush make uses API version `2`.
  
api = 2
  
; Core project
; ------------
; In order for your makefile to generate a full Drupal site, you must include
; a core project.

projects[drupal][download][type] = git
projects[drupal][download][url] = http://git.drupal.org/project/drupal.git
projects[drupal][download][branch] = 8.1.x

  
; Modules
; --------
; Development make file

; This file is just for development modules and theming helpers

projects[devel][version] = 1.x-dev
projects[devel][download][type] = git
projects[devel][download][url] = http://git.drupal.org/project/devel.git
projects[devel][download][branch] = 8.x-1.x
projects[devel][subdir] = development

projects[admin_menu][version] = 3.x-dev
projects[admin_menu][download][type] = git
projects[admin_menu][download][url] = http://git.drupal.org/project/admin_menu.git
projects[admin_menu][download][branch] = 8.x-3.x
projects[admin_menu][subdir] = development

projects[examples][version] = 1.x-dev
projects[examples][download][type] = git
projects[examples][download][url] = http://git.drupal.org/project/examples.git
projects[examples][download][branch] = 8.x-1.x
projects[examples][subdir] = development

projects[demo][version] = 1.x-dev
projects[demo][download][type] = git
projects[demo][download][url] = http://git.drupal.org/project/demo.git
projects[demo][download][branch] = 8.x-1.x
projects[demo][subdir] = development

; no release for coder module yet
;projects[coder][version] = 1.x-dev
;projects[coder][download][type] = git
;projects[coder][download][url] = http://git.drupal.org/project/coder.git
;projects[coder][download][branch] = 8.x-1.x
;projects[coder][subdir] = development

; Includes
; include other make files from local or remote destinations
; includes[modules] = "modules.make"
; includes[example_relative] = "../example_relative/example_relative.make"
; includes[remote] = "http://www.example.com/remote.make"
;includes[dev] = "https://raw.github.com/jazio/drupal-make-files/master/d8/dev.make"
;includes[modules] = "https://raw.github.com/jazio/drupal-make-files/master/d8/modules.make"
;includes[themes] = "https://raw.github.com/jazio/drupal-make-files/master/d8/themes.make"
;includes[features] = "https://raw.github.com/jazio/drupal-make-files/master/d8/features.make"
;includes[patches] = "https://raw.github.com/jazio/drupal-make-files/master/d8/patches.make"

; Themes
; --------
; @todo add bootstrap theme
  
  
; Libraries
; ---------
; No libraries were included



