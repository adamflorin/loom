// 
// threads.js: weaving.
// 
// Copyright 2013 Adam Florin
// 

// DRAWING/ANIMATION/CONSTANTS
// 
var GRID_UNIT = 50;
var ROW_HEIGHT = GRID_UNIT * 2;
var CURVE_HANDLE_LENGTH = ROW_HEIGHT * 1.0;
var THREAD_PADDING = 10;
var PATH_STYLES = [
  // {strokeWidth: GRID_UNIT, strokeColor: 'black'},
  {strokeWidth: GRID_UNIT - 2 * THREAD_PADDING, strokeColor: 'white'}
];
var COLUMNS_AFIELD = 3;
var SWITCH_COLUMN_PROBABILITY = 0.4;
var SLIDE_SPEED = 10; // px/s

// THREAD DATA
// 
var threadCount = Math.ceil(view.size.width/GRID_UNIT);
var threads = [];
var threadPaths = [[], []];

// Calculate next row of thread positions, persist it in array, and draw it.
//
// If it's the zeroth row, just populate and return early.
// 
// Returns index of previous row.
// 
function calculateNextRow() {
  var row = threads.length;
  threads[row] = [];

  if (row == 0) {
    for (var i=0; i<threadCount; i++) threads[row][i] = i;
    return;
  }

  randomIterator(threadCount, function(threadIndex) {
    var toColumn = threads[row-1][threadIndex];

    // switch columns?
    // 
    if (randomBoolean(SWITCH_COLUMN_PROBABILITY)) {
      toColumn += Math.floor(Math.random()*(COLUMNS_AFIELD*2+1)) - COLUMNS_AFIELD;
      toColumn = Math.max(0, Math.min(threadCount-1, toColumn));
      var wanderDistance = 1;
      var wanderLeft = randomBoolean(0.5);

      // avoid switching to an occupied column (if possible)
      // 
      while (threads[row].indexOf(toColumn) > -1) {
        toColumn = toColumn + (wanderLeft ? -1 : 1) * wanderDistance;
        toColumn = Math.max(0, Math.min(threadCount-1, toColumn));
        wanderDistance += 1;
        wanderLeft = !wanderLeft;
        if (wanderDistance > COLUMNS_AFIELD) {
          toColumn = threads[row-1][threadIndex];
          break;
        }
      }
    }
    threads[row][threadIndex] = toColumn;
  });
  return row;
}

// Create thread paths, add segments as necessary.
// 
// `startRow` is starting row. Code depends on row+1 as well.
// 
function drawThreads(startRow) {
  randomIterator(threadCount, function(threadIndex) {
    for (var style=0; style<PATH_STYLES.length; style++) {
      var isNew = (threadPaths[style][threadIndex] == null);
      if (isNew) {
        threadPaths[style][threadIndex] = new Path();
        threadPaths[style][threadIndex].strokeColor = PATH_STYLES[style].strokeColor;
        threadPaths[style][threadIndex].strokeWidth = PATH_STYLES[style].strokeWidth;
      }

      // add path segments
      // 
      for (var row=isNew?0:1; row<=1; row++) {
        threadPaths[style][threadIndex].addSegments([[
          [ threads[startRow+row][threadIndex]*GRID_UNIT,
            ((startRow+row) * ROW_HEIGHT)],
          new Point({angle: -90, length: CURVE_HANDLE_LENGTH}),
          new Point({angle: 90, length: CURVE_HANDLE_LENGTH})
        ]]);
      }
    }
  });
}

// Calculate enough rows for visible frame, plus one more.
// 
function calculateVisibleRows() {
  while (visiblePixels() > preparedPixels() - ROW_HEIGHT) {
    var row = calculateNextRow();
    if (row) drawThreads(row-1);
  }
}

// Animate scroll
// 
function onFrame(event) {
  view.scrollBy([0, event.delta * SLIDE_SPEED]);
  calculateVisibleRows();
}

// Math probability helper
// 
function randomBoolean(chance) {
  return parseInt(Math.random() * (1/chance)) == 0;
}

// Do something N iterations, but in a random order.
// 
function randomIterator(iterations, callback) {
  var availableIterations = [];
  var doneIterations = [];
  for (var i=0; i<iterations; i++) availableIterations.push(i);
  while (doneIterations.length < iterations) {
    var index = Math.floor(Math.random() * availableIterations.length);
    var iteration = availableIterations.splice(index, 1)[0];
    if (callback) callback(iteration);
    doneIterations.push(iteration);
  }
  return doneIterations;
}

// Utility geometry syntax helpers
// 
function visiblePixels() { return view.center.y + view.size.height/2; }
function preparedPixels() { return (threads.length-1) * ROW_HEIGHT; }
