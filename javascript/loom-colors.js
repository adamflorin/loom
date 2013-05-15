/**
* loom-colors.js: Patcher utility for Live colors
*
* Copyright 2013 Adam Florin
*/

/**
* Given an RGBA color, set ALL parent patchers' bgcolor, going up the tree.
*/
function list() {
  var ancestorPatcher = patcher;
  while (ancestorPatcher) {
    ancestorPatcher.bgcolor(arrayfromargs(arguments));
    ancestorPatcher = ancestorPatcher.parentpatcher;
  }
}
