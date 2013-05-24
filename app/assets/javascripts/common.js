var Common = {
    prepare_object_selection_container:function (object, paginate_callback, change_event_callback) {
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
    },

    reload_opening:  function(department_control, opening_control, opening_control_name) {
    $(department_control).attr('disabled', true);
    var url = '/openings/opening_options?selected_department_id=' + $(department_control).val();
    return $(opening_control).load(url, function() {
        $(department_control).attr('disabled', false);
        $(opening_control).find('select#opening_id').attr('name', opening_control_name);
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



