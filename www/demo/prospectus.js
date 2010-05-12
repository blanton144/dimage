// to-do
// - add input parameters for limits
// - add input parameter for spectrum file name
// - add input parameter for spectrum location
// - change tool tip in image to toggle
// - make spectrum ploting separate func

function prospectus(limits, sra, sdec, sfile) {
	
	// options for image plotting
	var options = {
		series: { points:{ show: true,   
											 fill: false }},	
		grid: { show: false, backgroundColor: null, 
						hoverable: true},
		xaxis: { min: limits.ramin, max: limits.ramax},
		yaxis: { min: limits.decmin, max: limits.decmax},
		colors: [ "#00ff00", "#ffffff" ]
	};
	
	function showTooltipSpec(x, y, contents) {
		$('<div id="tooltipSpec">' + contents + '</div>').css( {
			position: 'absolute',
					display: 'none',
					top: y - 15,
					left: x + 5,
					border: '1px solid #fdd',
					padding: '0px',
					'background-color': '#fee',
					opacity: 0.30
					}).appendTo("body").fadeIn(200);
	}
	
	// run the event handler to show position
	var previousPoint = null;
	$("#image").bind("plothover", function (event, pos, item) {
										 $("#x").text(pos.x.toFixed(2));
										 $("#y").text(pos.y.toFixed(2));
									 });
	
	// function to read in and plot spectroscopic positions
	var data = [];
	series={data: [[sra , sdec] ]};
	data.push(series);
	var plot = $.plot($("#image"), data, options);
	
	// function to read in and plot spectrum
	var sdata = [];
	var ldata = [];
	function plot_spectrum(series) {

		sdata.push(series);

		darr= sdata[0].data;
		var ymin = darr[0][1];
		var ymax = darr[0][1];
		var llen = darr.length;
		for (var i = 0; i < llen; i++) if (darr[i][1] < ymin) ymin = darr[i][1];
		for (var i = 0; i < llen; i++) if (darr[i][1] > ymax) ymax = darr[i][1];

		// allow for selection
		var options = {
			legend: {show: false}, 
			selection: { mode: "xy" },
			yaxis: {min: ymin, max: ymax}, 
			colors: ["#ffff00", "#ff0000", "#00ffff"],
			grid: {hoverable: true, autoHighlight: false}
		};

		// add lines optionally
		var linelists = {
        "absorption lines": {
					wave: [4160., 4227., 4300., 4383., 4455., 4531., 4668., 5015., 5100., 5175., 5270., 
								 5335., 5406., 5709., 5782., 5895., 5970., 6230. ], 
					name: ["CN", "Ca4227", "G4300", "Fe4385", "Ca4455", "Fe4531", "Fe4668", "Fe5015", 
								 "Mg1", "Mg b", "Fe5270", "Fe5335", "Fe5406", "Fe5709", "Fe5782", "Na D", 
								 "TiO1", "TiO2"],
					yminval: new Array(18),
					ymaxval: new Array(18),
        },        
        "emission lines": {
					wave: [3722.0985, 3727.0898, 3729.7904, 3751.2159, 3771.7012, 3798.9783, 3836.4680,
								 3869.7867, 3890.1521, 3968.5224, 3971.1933, 4069.6489, 4077.4210, 4105.8884,
								 4341.6803, 4364.3762, 4568.0598, 4712.6180, 4741.4260, 4862.6778, 4932.5167,
								 4960.2140, 5008.1666, 5193.1958, 5199.2673, 5201.4480, 5201.6180, 5578.5486,
								 5578.8084, 5756.0961, 6301.9425, 6311.7948, 6331.7503, 6365.4293, 6549.7689,
								 6564.6127, 6585.1583, 6718.1642, 6732.5382, 7137.6370, 7321.6666, 7322.2570,
								 7332.1196, 7332.7198, 7753.0832, 8667.3995, 8752.8728, 8865.2235, 9017.3848,
								 9071.7794, 3889.0000, 4471.0000, 5876.0000, 6678.0000, 7065.0000, 7283.0000],
					name: ["SIII", "OII", "OII", "HI", "HI", "HI", "HI", "NeIII", "HI", 
									"NeIII", "HI", "SII", "SII", "HI", "HI", "OIII", "MgI", "ArIV", 
									"ArIV", "HI", "OIII", "OIII", "OIII", "ArIII", "NI", "NI", "NI", 
									"OI", "OI", "NII", "OI", "SIII", "OI", "OI", "NII", "HI", "NII", 
									"SII", "SII", "ArIII", "OII", "OII", "OII", "OII", "ArIII", "HI", 
									"HI", "HI", "HI", "SIII", "HeI", "HeI", "HeI", "HeI", "HeI", "HeI"],
					yminval: new Array(56),
					ymaxval: new Array(56),
        },
		}


		var len = linelists["emission lines"].wave.length;
		for (var i = 0; i < len; i++) {
			currw= linelists["emission lines"].wave[i];
			for (var j = 0; j < llen-1; j++) {
				if(currw > darr[j][0] && currw < darr[j+1][0]) {
					linelists["emission lines"].yminval[i]= darr[j][1]*1.15;
					linelists["emission lines"].ymaxval[i]= darr[j][1]*1.30;
				}
			}
		}

		var len = linelists["absorption lines"].wave.length;
		for (var i = 0; i < len; i++) {
			currw= linelists["absorption lines"].wave[i];
			for (var j = 0; j < llen-1; j++) {
				if(currw > darr[j][0] && currw < darr[j+1][0]) {
					linelists["absorption lines"].yminval[i]= darr[j][1]*0.62;
					linelists["absorption lines"].ymaxval[i]= darr[j][1]*0.78;
				}
			}
		}

    // hard-code color indices to prevent them from shifting as
    // countries are turned on/off
    var i = 1;
    $.each(linelists, function(key, val) {
        val.color = i;
        ++i;
    });
    
    // insert checkboxes 
    var choiceContainer = $("#choices");
    $.each(linelists, function(key, val) {
        choiceContainer.append('<br/><input type="checkbox" name="' + key +
                               '" checked="checked" id="id' + key + '">' +
                               '<label for="id' + key + '">'
                                + key + '</label>');
					 });
    choiceContainer.find("input").click(plotLines);
    
    function plotLines() {
			ldata=[];
			ldata.push(sdata[0]);
			
			choiceContainer.find("input:checked").each(function () {
																									 var key = $(this).attr("name");
																									 if (key && linelists[key]) {
																										 len = linelists[key].wave.length;
																										 for (var i = 0; i < len; i++) {
																											 if (key == "absorption lines") {
																												 color="#ff0000"; 
																											 } else {
																												 color="#00aaff";
																											 }
																											 cdata= { data: 
																																[[linelists[key].wave[i], 
																																	linelists[key].yminval[i]], 
																																 [linelists[key].wave[i], 
																																	linelists[key].ymaxval[i]]],
																																color: color,
																																lines: {lineWidth: 1}, 
																																label: linelists[key].name[i]}
																											 ldata.push(cdata);
																										 }
																									 }
																								 });

			if (ldata.length > 0)
				$.plot($("#spectrum"), ldata, options);
    }

    plotLines();

		var previousPointSpec = null;
		$("#spectrum").bind("plothover", function (event, pos, item) {
													$("#xspec").text(pos.x.toFixed(2));
													$("#yspec").text(pos.y.toFixed(2));
													
													if (item) {
														// first item in series is spectrum, so skip
														if(item.seriesIndex > 0) {
															if (previousPointSpec != item.datapoint) {
																previousPointSpec = item.datapoint;
																
																$("#tooltipSpec").remove();
																var x = item.series.label;
																if(x) showTooltipSpec(item.pageX, item.pageY, x )
																	}
														} else {
															$("#tooltipSpec").remove();
															previousPoint = null;            
														}
													} else {
														$("#tooltipSpec").remove();
														previousPoint = null;            
													}
												});
		
		// setup overview
		var overview = $.plot($("#overview"), sdata, {
			legend: { show: true, container: $("#overviewLegend") },
															series: {
														lines: { show: true, lineWidth: 1 },
																shadowSize: 0
																},
															xaxis: { ticks: 0 },
															yaxis: { ticks: 0, min: ymin, max: ymax},
															grid: { color: "#999" },
															selection: { mode: "xy" }
			});

		// bind together overview and plot
		$("#spectrum").bind("plotselected", function (event, ranges) {
															// clamp the zooming to prevent eternal zoom
															if (ranges.xaxis.to - ranges.xaxis.from < 0.00001)
																ranges.xaxis.to = ranges.xaxis.from + 0.00001;
															if (ranges.yaxis.to - ranges.yaxis.from < 0.00001)
																ranges.yaxis.to = ranges.yaxis.from + 0.00001;
			
															// do the zooming
															plot = $.plot($("#spectrum"), ldata,
																						$.extend(true, {}, options, {
																										 xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
																										 yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to }
																										 }));
			
															// don't fire event on the overview to prevent eternal loop
															overview.setSelection(ranges, true);
														});
		$("#overview").bind("plotselected", function (event, ranges) {
													plot.setSelection(ranges);
												});
	}

	$.ajax({
		url: sfile, 
				method: 'GET',
				dataType: 'json',
				success: plot_spectrum
				});

}
