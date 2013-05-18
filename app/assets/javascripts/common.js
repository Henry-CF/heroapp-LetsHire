$(function() {
    $(document).ajaxStart(function(){
        $(this).addClass('wait').bind('click',function(){
            return false;
        });
    }).ajaxStop(function(){
        $(this).removeClass('wait').unbind('click');
    });
});
