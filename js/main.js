function daysToGo () {
  var targetDate = new Date("May 7, 2015 00:00:00");
  var secsToGo = (targetDate - new Date()) / 1000;

  return Math.floor(secsToGo / (60 * 60 * 24)) + 1;
}

function setCounter () {
  var counter = document.getElementById("counter");
  counter.innerHTML = daysToGo() + " Days to go";
}

window.onload = setCounter;
