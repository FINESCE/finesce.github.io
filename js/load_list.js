(function loadList(){
	/* global $ */
	"use strict";
	var enabler_list = $(".enabler-list");
	var dataGlobal = [];

	/*
	Option 1: the specification of the DSE is made publically available, royalty free.
	Option 2: the specification of the DSE is made publically available, royalty free and the code is available Open Source.
	*/
	function getUrlParameter(sParam)
	{
	    var sPageURL = window.location.search.substring(1);
	    var sURLVariables = sPageURL.split('&');
	    for (var i = 0; i < sURLVariables.length; i++) 
	    {
	        var sParameterName = sURLVariables[i].split('=');
	        if (sParameterName[0] == sParam) 
	        {
	            return sParameterName[1];
	        }
	    }
	}    
	var option = getUrlParameter('option') || '1';

	if (option == '1') {
		$('.js-title').html('Other FINESCE results');
		$('.breadcrumb-text').text(' / Other results');
	}

	// This causse DSEs.json to be refreshed every hour
	var cacheBuster = Math.floor(new Date().getTime() / (1000 * 60 * 60));
	$.getJSON("js/json/DSEs.json?ts=" + cacheBuster, function(data){

		function filterSEs(dse) {
			if (option == '2' && option == dse.option) {
				return true;
			} else if (option == '1' && option == dse.option) {
				return true
			} else if (['1', '2'].indexOf(option) == -1 ) {
				console.error('This is not a valid option:', option)
				return false;
			}
			return false;
		}
		data.dse = data.dse.filter(filterSEs);

		data = data

		dataGlobal = data;

		showData("all");

		data = data.dse;
		var wp_list = [];
		for (var line in data){
			wp_list[data[line].site] = true;
		}
		//fill dropdown
		$(".dropdown-menu").empty();
		$(".dropdown-menu").append('<li role="presentation"><a role="menuitem" tabindex="-1" data-id="all" href="#">All</a></li>');
		$("#dropdownMenu1").html('All <span class="caret"></span>');

		for (var wp in wp_list){
			$(".dropdown-menu").append('<li role="presentation"><a role="menuitem" tabindex="-1" data-id="'+wp+'" href="#">'+wp+'</a></li>');
		}
	});

	$(".dropdown-menu").on("click", "li a", function(){
		var selText = $(this).text();
		$("#dropdownMenu1").html(selText+' <span class="caret"></span>');
		showData($(this).data('id'));
	});

	function showData (filter) {
		$(".enabler-row").remove();

		// enabler_list.html('');
		var row_html = "";
		var data = dataGlobal;
		var data = data.dse;

		if(filter && filter !== "all") {
			data = data.filter(function(dt){
				return dt.site === filter;
			});
		}

		for (var line in data) {
			row_html = '<div class="enabler-row"><h2 class="header"><a href="DSE.html?id='+ data[line].id + '">'+data[line].name+'</a></h2>'+data[line].description+'<div class="category">'+data[line].site+'</div></div>';
			enabler_list.append(row_html);
		}
	}
})();