$(function () {
    $(".datetimepicker").datetimepicker().each(function (index, elem) {
        var isoTime = $("#interview_" + elem.name + "_iso").val();
        if (isoTime == "") {
            $(elem).datetimepicker("setDate", new Date());
            $("#interview_" + this.name + "_iso").val(new Date(elem.value).toISOString());
        } else {
            $(elem).datetimepicker("setDate", new Date(isoTime));
        }
    }).change(function () {
        $("#interview_" + this.name + "_iso").val(new Date(this.value).toISOString());
    });

    $(".iso-time").each(function (index, elem) {
        elem.innerHTML = new Date(elem.innerHTML).toLocaleString();
    });

    function toggleModality(modality) {
        if (typeof(modality) == "string") {
            if (modality.indexOf("phone") >= 0) {
                $(".toggle-location").hide();
                $(".toggle-phone").show();
            } else if (modality.indexOf("onsite") >= 0) {
                $(".toggle-location").show();
                $(".toggle-phone").hide();
            }
        }
    }

    toggleModality(
        $("#interview_modality").change(function () {
            toggleModality(this.value);
        }).val()
    );


    if ($("#interview_user_id").length > 0) {
        function reloadInterviewers() {
            var old_val = $("#interview_user_id").val();
            var opening_id = $('#opening_id')[0].value;
            if (opening_id != undefined)  {
                var url = "/openings/" + opening_id + "/interviewers_select"
                if (!$("#only_favorite_interviewers").is(':checked')) {
                    url = url + "?mode=all";
                }
                $("#interview_user_id").load(url, function(response, status) {
                    if (status == 'success') {
                        $("#interview_user_id").attr('id', 'interview_user_id')
                          .attr('name', 'interview[user_id]');
                        $("#interview_user_id").val(old_val);
                    }
                });
            }
        };

        $("#only_favorite_interviewers").change(function() {
            reloadInterviewers();
        });

        reloadInterviewers();
    }
});
