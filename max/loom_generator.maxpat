{
	"patcher" : 	{
		"fileversion" : 1,
		"appversion" : 		{
			"major" : 5,
			"minor" : 1,
			"revision" : 9
		}
,
		"rect" : [ 755.0, 230.0, 614.0, 480.0 ],
		"bglocked" : 0,
		"defrect" : [ 755.0, 230.0, 614.0, 480.0 ],
		"openrect" : [ 0.0, 0.0, 0.0, 0.0 ],
		"openinpresentation" : 1,
		"default_fontsize" : 12.0,
		"default_fontface" : 0,
		"default_fontname" : "Arial",
		"gridonopen" : 0,
		"gridsize" : [ 8.0, 8.0 ],
		"gridsnaponopen" : 0,
		"toolbarvisible" : 1,
		"boxanimatetime" : 200,
		"imprint" : 0,
		"enablehscroll" : 1,
		"enablevscroll" : 1,
		"devicewidth" : 0.0,
		"boxes" : [ 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-11",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 144.0, 112.0, 98.0, 20.0 ],
					"text" : "loadmess set #1"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial Bold",
					"fontsize" : 10.0,
					"id" : "obj-6",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 144.0, 168.0, 71.0, 18.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 4.0, 0.0, 59.0, 18.0 ],
					"text" : "#1"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-8",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 4,
					"outlettype" : [ "", "", "", "" ],
					"patching_rect" : [ 152.0, 264.0, 59.5, 20.0 ],
					"restore" : 					{
						"#1" : [ 4.0 ],
						"#1_deviation" : [ 0.0 ],
						"#1_inertia" : [ 0.0 ]
					}
,
					"text" : "autopattr",
					"varname" : "u494002677"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 10.0,
					"id" : "obj-5",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 186.0, 224.0, 19.0, 18.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 42.0, 58.0, 17.0, 18.0 ],
					"text" : "i"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 10.0,
					"id" : "obj-4",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 186.0, 208.0, 19.0, 18.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 40.0, 42.0, 19.0, 18.0 ],
					"text" : "d"
				}

			}
, 			{
				"box" : 				{
					"annotation" : "",
					"hint" : "Inertia",
					"id" : "obj-2",
					"maxclass" : "live.numbox",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "float" ],
					"parameter_enable" : 1,
					"patching_rect" : [ 152.0, 224.0, 36.0, 15.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 6.0, 58.0, 36.0, 15.0 ],
					"saved_attribute_attributes" : 					{
						"valueof" : 						{
							"parameter_mmin" : 0.0,
							"parameter_initial" : [ 0.0 ],
							"parameter_type" : 1,
							"parameter_initial_enable" : 1,
							"parameter_shortname" : "#1_inertia",
							"parameter_modmax" : 127.0,
							"parameter_longname" : "#1_inertia",
							"parameter_modmin" : 0.0,
							"parameter_linknames" : 1,
							"parameter_modmode" : 0,
							"parameter_info" : "",
							"parameter_units" : "",
							"parameter_order" : 0,
							"parameter_defer" : 0,
							"parameter_speedlim" : 1.0,
							"parameter_steps" : 0,
							"parameter_invisible" : 0,
							"parameter_exponent" : 1.0,
							"parameter_annotation_name" : "",
							"parameter_unitstyle" : 5,
							"parameter_mmax" : 100.0
						}

					}
,
					"varname" : "#1_inertia"
				}

			}
, 			{
				"box" : 				{
					"annotation" : "",
					"hint" : "Deviation",
					"id" : "obj-13",
					"maxclass" : "live.numbox",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "float" ],
					"parameter_enable" : 1,
					"patching_rect" : [ 152.0, 208.0, 36.0, 15.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 6.0, 42.0, 36.0, 15.0 ],
					"saved_attribute_attributes" : 					{
						"valueof" : 						{
							"parameter_mmin" : 0.0,
							"parameter_initial" : [ 0.0 ],
							"parameter_type" : 1,
							"parameter_initial_enable" : 1,
							"parameter_shortname" : "#1_deviation",
							"parameter_modmax" : 127.0,
							"parameter_longname" : "#1_deviation",
							"parameter_modmin" : 0.0,
							"parameter_linknames" : 1,
							"parameter_modmode" : 0,
							"parameter_info" : "",
							"parameter_units" : "",
							"parameter_order" : 0,
							"parameter_defer" : 0,
							"parameter_speedlim" : 1.0,
							"parameter_steps" : 0,
							"parameter_invisible" : 0,
							"parameter_exponent" : 1.0,
							"parameter_annotation_name" : "",
							"parameter_unitstyle" : 5,
							"parameter_mmax" : 100.0
						}

					}
,
					"varname" : "#1_deviation"
				}

			}
, 			{
				"box" : 				{
					"appearance" : 1,
					"id" : "obj-14",
					"maxclass" : "live.dial",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "float" ],
					"parameter_enable" : 1,
					"patching_rect" : [ 152.0, 184.0, 47.0, 23.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 7.0, 16.0, 47.0, 23.0 ],
					"saved_attribute_attributes" : 					{
						"valueof" : 						{
							"parameter_mmin" : 1.0,
							"parameter_initial" : [ 4 ],
							"parameter_type" : 1,
							"parameter_initial_enable" : 1,
							"parameter_shortname" : "#1",
							"parameter_modmax" : 127.0,
							"parameter_longname" : "#1",
							"parameter_modmin" : 0.0,
							"parameter_linknames" : 1,
							"parameter_modmode" : 0,
							"parameter_info" : "",
							"parameter_units" : "",
							"parameter_order" : 0,
							"parameter_defer" : 0,
							"parameter_speedlim" : 1.0,
							"parameter_steps" : 0,
							"parameter_invisible" : 0,
							"parameter_exponent" : 1.0,
							"parameter_annotation_name" : "",
							"parameter_unitstyle" : 0,
							"parameter_mmax" : 16.0
						}

					}
,
					"showname" : 0,
					"varname" : "#1"
				}

			}
, 			{
				"box" : 				{
					"bgcolor" : [ 0.858824, 0.858824, 0.858824, 1.0 ],
					"id" : "obj-1",
					"maxclass" : "panel",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 136.0, 160.0, 86.0, 93.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 0.0, 0.0, 57.0, 80.0 ],
					"rounded" : 12
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"destination" : [ "obj-6", 0 ],
					"hidden" : 0,
					"midpoints" : [  ],
					"source" : [ "obj-11", 0 ]
				}

			}
 ],
		"parameters" : 		{
			"obj-13" : [ "#1_deviation", "#1_deviation", 0 ],
			"obj-14" : [ "#1", "#1", 0 ],
			"obj-2" : [ "#1_inertia", "#1_inertia", 0 ]
		}

	}

}
