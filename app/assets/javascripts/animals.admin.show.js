var animal_uuid = $('#animal_holder').data('animal_uuid');
var animal_id = $('#animal_holder').data('animal_id');
//setup juggernaut to handle real time updating page changes
//this one handles changes made with best in place
var jug = new Juggernaut({
	secure: false,
	host: 'juggernaut-hospitium2.herokuapp.com',
	port: 80,
	transports: ['xhr-polling','jsonp-polling']
});

jug.subscribe("/observer/"+animal_uuid, function(data){
	"use strict";
	var updated_text = "There was an update, but a problem displaying. Please refresh.";
	jQuery.each(data.record, function(i, val) {
		if (i !== "updated_at"){
			updated_text = val[1];
			if ($("#best_in_place_animal_"+animal_id+"_"+i).attr("data-collection") !== undefined) {
				var brand = $('#best_in_place_animal_'+animal_id+'_'+i).attr("data-collection");
				var test = $.parseJSON(brand);
				$.each(test, function(index, value) {
					if(value[0] === val[1]){
						updated_text = value[1];
					}
				});
			}
			$('#best_in_place_animal_'+animal_id+'_'+i).css("background-color","#c7f464");
			$('#best_in_place_animal_'+animal_id+'_'+i).html(updated_text);
			$('#best_in_place_animal_'+animal_id+'_'+i).delay(1500).animate({backgroundColor: "#f5f5f5"}, 1000 );
		}
	});
});

jug.subscribe("/observer/note/"+animal_id, function(data){
	"use strict";
	var bg_color = "";
	var updated_text = "There was an update, but a problem displaying. Please refresh.";
	jQuery.each(data.record, function(i, val) {
		$("#animal_notes_list").append('<li id="note_'+val.id+'"><strong>'+data.user+'</strong> '+data.created_at+' <br />'+val.note+'</li>');
		$("#animal_notes_list").scrollTop($("#animal_notes_list")[0].scrollHeight);
		// /* Highlight the new comment */
		$('#note_'+val.id).css("background-color","#c7f464");
		if ($('#note_'+val.id).prev("li").css("background-color") === "rgb(255, 255, 255)"){
			bg_color = "#f5f5f5";
		}else{
			bg_color = "#ffffff";
		}
		$('#note_'+val.id).delay(1500).animate({backgroundColor: bg_color}, 1000 );
	});
});
//create the date picker for adding an animal weight
$( "#animal_weight_date_of_weight" ).datepicker();
$.datepicker.setDefaults({
	dateFormat: 'D, dd M yy' 
});

//handle modal form submit buttons.
$('.submit-button').click(function() {
	"use strict";
	var form_id = $(this).attr("data-form-id");
	$("#"+form_id).submit();
	if ($(".field_with_errors")[0]){
		// Do something here if class exists
	}else{
		$("#"+form_id).fadeOut("slow", function() {
			$("."+form_id+"_bar").fadeIn("slow");
		});
	}
});

$('a[data-toggle="tab"]').on('shown', function (e) {
	"use strict";
	if ($('canvas').length) { // implies *not* zero
		//do nothing
	} else {
		var line1 = $('#animal_weights_holder').data('animal_weights');
		var plot1 = $.jqplot('chart1', [line1], {
			title:'Animal Weight',
			grid: {
				background: '#FCF8E3',
				gridLineColor: '#FBEED5',    // *Color of the grid lines.
				borderColor: '#DDD',     // CSS color spec for border around grid.
				shadow:false
			},
			seriesDefaults: {
				color: '#49AFCD'      // CSS color spec to use for the line.  Determined automatically.
			},
			axes:{
				xaxis:{
					renderer:$.jqplot.DateAxisRenderer,
					tickOptions:{
						formatString:'%b&nbsp;%#d'
					} 
				},
				yaxis:{
				}
			},
			highlighter: {
				show: true,
				sizeAdjust: 7.5
			},
			cursor: {
				show: false
			}
		});
	}
});