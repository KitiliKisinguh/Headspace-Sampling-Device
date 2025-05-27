// Global variables to store data points and set maximum number of points
var dataPoints = [];
var maxPoints = 40;

// Get reference to the canvas and its context
var canvas = document.getElementById("graphCanvas");
var ctx = canvas.getContext("2d");

// Function to fetch sensor readings from the ESP32 /readings endpoint
function fetchData() {
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // Expecting a JSON object with the temperature reading under "sensor"
      var reading = JSON.parse(this.responseText);
      var temperature = parseFloat(reading.sensor);
      addDataPoint(temperature);
      drawGraph();
    }
  };
  xhr.open("GET", "/readings", true);
  xhr.send();
}

// Adds a new data point to the dataPoints array and removes the oldest if necessary
function addDataPoint(value) {
  dataPoints.push(value);
  if (dataPoints.length > maxPoints) {
    dataPoints.shift();
  }
}

// Draws a simple line graph on the canvas using the dataPoints array
function drawGraph() {
  // Clear the canvas
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Draw axes
  // y-axis from (30, 10) to (30, canvas.height - 10)
  // x-axis from (30, canvas.height - 10) to (canvas.width - 10, canvas.height - 10)
  ctx.beginPath();
  ctx.moveTo(30, 10);
  ctx.lineTo(30, canvas.height - 10);
  ctx.lineTo(canvas.width - 10, canvas.height - 10);
  ctx.strokeStyle = "#000";
  ctx.stroke();

  // compute min and max for scaling
  if (dataPoints.length > 0) {
    var maxVal = Math.max(...dataPoints);
    var minVal = Math.min(...dataPoints);
    if (maxVal === minVal) {
      maxVal = minVal + 1; // Avoid division by zero
    }
    
    // Draw temperature axis ticks and labels along the y-axis
    var tickCount = 5; // number of ticks
    ctx.font = "10px Arial";
    ctx.fillStyle = "#000";
    ctx.textAlign = "right";
    for (var i = 0; i <= tickCount; i++) {
      var tickValue = minVal + ((maxVal - minVal) * i / tickCount);
      // Map tickValue to y-coordinate (inverted axis)
      var tickY = canvas.height - 10 - ((tickValue - minVal) / (maxVal - minVal)) * (canvas.height - 20);
      // Draw a small tick mark from x=25 to x=30
      ctx.beginPath();
      ctx.moveTo(25, tickY);
      ctx.lineTo(30, tickY);
      ctx.stroke();
      // Draw the label just to the left of the tick mark
      ctx.fillText(tickValue.toFixed(1), 25, tickY + 3);
    }
    
    // Draw the data as a line graph
    if (dataPoints.length > 1) {
      var step = (canvas.width - 40) / (maxPoints - 1);
      ctx.beginPath();
      for (var i = 0; i < dataPoints.length; i++) {
        var x = 30 + i * step;
        // Map data point to canvas y coordinate
        var y = canvas.height - 10 - ((dataPoints[i] - minVal) / (maxVal - minVal)) * (canvas.height - 20);
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      ctx.strokeStyle = "#101D42";
      ctx.stroke();
    }
  }
}

// Fetch new data every 1 second
setInterval(fetchData, 1000);

// Optional: fetch initial reading immediately on load
fetchData();
