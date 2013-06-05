$(function () {
    $('table th a.asc').click(function(){
        window.location = Common.updateQueryStringParameter(document.location.href, 'direction', 'desc');
        return false;
    });

    $('table th a.desc').click(function(){
        window.location = Common.updateQueryStringParameter(document.location.href, 'direction', 'asc');
        return false;
    });

    $('table th a').not('a.current').click(function(){
        var url = Common.updateQueryStringParameter(document.location.href, 'direction', 'asc');
        window.location = Common.updateQueryStringParameter(url, 'sort', $(this).attr('field'));
        return false;
    });

});