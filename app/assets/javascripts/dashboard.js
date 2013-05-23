// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
    $('[data-jcarousel]').each(function() {
        var el = $(this);
        el.jcarousel(el.data());
    });

    $('[data-jcarousel-control]').each(function() {
        var el = $(this);
        el.jcarouselControl(el.data());
    });

    if($('.stats-chart').length > 0) {
        for (var i = 0; i < $('.stats-chart').length; i ++) {
            $('.stats-chart')[i].style.marginLeft = 0;
        }
    }
});


