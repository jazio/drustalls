<?php
/**
 * Implements hook_drush_command.
 * @return array
 */
function publish_drush_command() {
  $items = array();
  $items['publish-content'] = array(
  'description' => 'Publish content',
  'aliases' => array('pc'),
  'arguments' => array(
  'type' => 'Nodes of this type will be published',
  ),
  );
  return $items;
}

/**
 *  Declare the Command Callback Function:
 *  Now you need to write the code that you want Drupal to perform when you run the custom command.
 *  The name of the function needs to be in the format: drush_command_name.
 *  (Note: dash in the command name becomes an underscore in the function name).
 * @param $type
 */
function drush_publish_content($type) {
  $nodes = node_load_multiple(array(), array('type' => $type));
  $count = 0;
  foreach ($nodes as $node) {
    if($node->status == 0) {
      $count++;
      $node->status = 1;
      node_save($node);
    }
  }
  if($count > 0) {
    drush_print($count . " nodes of the " . $type . " content type have been successfully published.");
  }

  else {
    drush_print("No nodes of the " . $type . " content type were published.");
  }
}


function drush_publish_content_validate($type) {
  if(node_type_load($type) === FALSE) {
    return drush_set_error('NON_EXISTENT', dt('There is no content type by that name'));
  }
}