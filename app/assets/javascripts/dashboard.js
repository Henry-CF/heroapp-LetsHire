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

    // if the total size of items is less than 4, the prev and next controls should be hided
    // if the size is more than 4, the init prev control should not be displayed
    if($('.carousel').jcarousel('items').length <= 4){
        $('.carousel-control-next').hide();
        $('.carousel-control-prev').hide();
    }else{
        $('.carousel-control-prev').hide();
    }

    // next control click callback
    $('.carousel-control-next').on('click', function(){
        var items = $('.carousel').jcarousel('items');
        var current_target = $('.carousel').jcarousel('target')[0];
        if( items.length > 4 ){
            if(current_target == items[items.length - 4]){
                $('.carousel-control-next').hide();
            }
            $('.carousel-control-prev').show();
        }
    });

    // prev control click callback
    $('.carousel-control-prev').on('click', function(){
        var items = $('.carousel').jcarousel('items');
        var current_target = $('.carousel').jcarousel('target')[0];
        if( items.length > 4 ){
            if(current_target == items[0]){
                $('.carousel-control-prev').hide();
            }
            $('.carousel-control-next').show();
        }
    });

});


