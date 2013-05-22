var Common = {
    prepare_object_selection_container: function (object, paginate_callback, change_event_callback) {
        var parent_object = object.parent();
        parent_object.delegate('.pagination a', 'click', function () {
            $('.pagination').html('Page is loading...');
            object.load(this.href, function() {
                if (paginate_callback) {
                    paginate_callback($(this));
                }
            });
            return false;
        });

        parent_object.delegate('i.icon-arrow-down', 'click', function () {
            $(this).parent().parent().next().show();
            $(this).removeClass('icon-arrow-down').addClass('icon-arrow-up');
            return false;
        });

        parent_object.delegate('i.icon-arrow-up', 'click', function () {
            $(this).parent().parent().next().hide();
            $(this).removeClass('icon-arrow-up').addClass('icon-arrow-down');
            return false;
        });

        parent_object.delegate('input:checkbox', 'change', function() {
            if (change_event_callback) {
                change_event_callback($(this));
            }
        });


    }
};

$(function() {
    $(document).ajaxStart(function(){
        $(this).addClass('wait').bind('click',function(){
            return false;
        });
    }).ajaxStop(function(){
        $(this).removeClass('wait').unbind('click');
    });
});



