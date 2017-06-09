function daysToGo () {
  var targetDate = new Date("May 5, 2022 00:00:00");
  var secsToGo = (targetDate - new Date()) / 1000;

  return Math.floor(secsToGo / (60 * 60 * 24)) + 1;
}

function setCounter () {
  $('#counter').html( daysToGo() + " Days to go" );
}

$( document ).ready(function() {
  setCounter();

  $(function(){
    $('#tablesorter').tablesorter();
  });
/*
  $('a[href^="#"]').on('click',function (e) {
    e.preventDefault();

    var target = this.hash;
    var $target = $(target);

    $('html, body').stop().animate({
        'scrollTop': $target.offset().top
    }, 900, 'swing', function () {
        window.location.hash = target;
    });
  });
*/
} );
