let scaleRef0 = ref (GData.adjustment ())
let scaleRef1 = ref (GData.adjustment ())
let scaleRef2 = ref (GData.adjustment ())
let scaleRef3 = ref (GData.adjustment ())
let scaleRef4 = ref (GData.adjustment ())
let scaleRef5 = ref (GData.adjustment ())
let scaleRef6 = ref (GData.adjustment ())
let scaleRef7 = ref (GData.adjustment ())
let scaleRef8 = ref (GData.adjustment ())
let scaleRef9 = ref (GData.adjustment ())

let distorsion =
  let file_dist = ref 0. in
  let dist_change dist_b() =
    file_dist := dist_b#adjustment#value;
    Wrap.dist_sound (!file_dist /. 100.) in
  let adj= GData.adjustment 
    ~value:0.
    ~lower:0.
    ~upper:110.
    ~step_incr:1. () in
  let box = GPack.vbox
    ~height: 130
    ~homogeneous:false
    ~spacing:0
    ~packing:(Ettoihc.firstLineBox1#pack ~expand:false) () in
  let dist_scale = GRange.scale `VERTICAL
    ~draw_value:true
    ~value_pos:`BOTTOM
    ~show:true
    ~digits: 0
    ~inverted:true
    ~adjustment:adj
    ~packing:box#add () in
  ignore(dist_scale#connect#value_changed (dist_change dist_scale));
  ignore(GMisc.label ~height:10 ~text:"Distorsion" ~packing:box#add ());
  dist_scale

let echo =
  let file_echo = ref 0. in
  let echo_change echo_b() =
    file_echo := echo_b#adjustment#value;
    Wrap.echo_sound (!file_echo) in
  let adj= GData.adjustment
    ~value:0.
    ~lower:0.
    ~upper:110.
    ~step_incr:1. () in
  let box = GPack.vbox
    ~height: 130
    ~homogeneous:false
    ~spacing:0
    ~packing:(Ettoihc.firstLineBox1#pack ~expand:false) () in
  let echo_scale = GRange.scale `VERTICAL
    ~draw_value:true
    ~value_pos:`BOTTOM
    ~show:true
    ~digits: 0
    ~inverted:true
    ~adjustment:adj
    ~packing:box#add () in
  ignore(echo_scale#connect#value_changed (echo_change echo_scale));
  ignore(GMisc.label ~height:10 ~text:"Echo" ~packing:box#add ());
  echo_scale

let egaliseur =
  let egal_change f egal_b() =
    Wrap.egaliseur f (egal_b#adjustment#value) in
  let adj1 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box1 = GPack.vbox
    ~height: 130 ~homogeneous:false
    ~spacing:0 ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale1 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj1 ~packing:box1#add () in
  ignore(scale1#connect#value_changed (egal_change 29. scale1));
  ignore(GMisc.label ~height:10 ~text:"29Hz" ~packing:box1#add ());
  scaleRef0 := adj1;
  let adj2 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:1. () in
  let box2 = GPack.vbox
    ~height: 130 ~homogeneous:false ~spacing:0
    ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale2 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj2 ~packing:box2#add () in
  ignore(scale2#connect#value_changed (egal_change 59. scale2));
  ignore(GMisc.label ~height:10 ~text:"59Hz" ~packing:box2#add ());
  scaleRef1 := adj2;
  let adj3 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box3 = GPack.vbox
    ~height: 130 ~homogeneous:false ~spacing:0
    ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale3 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj3 ~packing:box3#add () in
  ignore(scale3#connect#value_changed (egal_change 119. scale3));
  ignore(GMisc.label ~height:10 ~text:"119Hz" ~packing:box3#add ());
  scaleRef2 := adj3;
  let adj4 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box4 = GPack.vbox
    ~height: 130 ~homogeneous:false ~spacing:0
    ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale4 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj4 ~packing:box4#add () in
  ignore(scale4#connect#value_changed (egal_change 237. scale4));
  ignore(GMisc.label ~height:10 ~text:"237Hz" ~packing:box4#add ());
  scaleRef3 := adj4;
  let adj5 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box5 = GPack.vbox
    ~height: 130 ~homogeneous:false ~spacing:0
    ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale5 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj5 ~packing:box5#add () in
  ignore(scale5#connect#value_changed (egal_change 474. scale5));
  ignore(GMisc.label ~height:10 ~text:"474Hz" ~packing:box5#add ());
  scaleRef4 := adj5;
  let adj6 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box6 = GPack.vbox
    ~height: 130 ~homogeneous:false ~spacing:0
    ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale6 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj6 ~packing:box6#add () in
  ignore(scale6#connect#value_changed (egal_change 947. scale6));
  ignore(GMisc.label ~height:10 ~text:"947Hz" ~packing:box6#add ());
  scaleRef5 := adj6;
  let adj7 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box7 = GPack.vbox
    ~height: 130 ~homogeneous:false ~spacing:0
    ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale7 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj7 ~packing:box7#add () in
  ignore(scale7#connect#value_changed (egal_change 2000. scale7));
  ignore(GMisc.label ~height:10 ~text:"2kHz" ~packing:box7#add ());
  scaleRef6 := adj7;
  let adj8 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box8 = GPack.vbox
    ~height: 130 ~homogeneous:false ~spacing:0
    ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale8 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj8 ~packing:box8#add () in
  ignore(scale8#connect#value_changed (egal_change 4000. scale8));
  ignore(GMisc.label ~height:10 ~text:"4kHz" ~packing:box8#add ());
  scaleRef7 := adj8;
  let adj9 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box9 = GPack.vbox
    ~height: 130 ~homogeneous:false ~spacing:0
    ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale9 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj9 ~packing:box9#add () in
  ignore(scale9#connect#value_changed (egal_change 8000. scale9));
  ignore(GMisc.label ~height:10 ~text:"8kHz" ~packing:box9#add ());
  scaleRef8 := adj9;
  let adj10 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box10 = GPack.vbox
    ~height: 130 ~homogeneous:false ~spacing:0
    ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale10 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj10 ~packing:box10#add () in
  ignore(scale10#connect#value_changed (egal_change 15000. scale10));
  ignore(GMisc.label ~height:10 ~text:"15kHz" ~packing:box10#add ());
  scaleRef9 := adj10
  
let menuEqual =
  let menu_bar = GMenu.menu_bar ~packing:Ettoihc.firstLineBox2Vbox#add() in
  let file_menu = GMenu.menu () in
  let item = GMenu.menu_item
    ~label:"None"
    ~packing:file_menu#append () in
  ignore(item#connect#activate ~callback:(fun()->
    !scaleRef0#set_value 100.;
    !scaleRef1#set_value 100.;
    !scaleRef2#set_value 100.;
    !scaleRef3#set_value 100.;
    !scaleRef4#set_value 100.;
    !scaleRef5#set_value 100.;
    !scaleRef6#set_value 100.;
    !scaleRef7#set_value 100.;
    !scaleRef8#set_value 100.;
    !scaleRef9#set_value 100.;
    Wrap.egal_sound "default"));
  let item = GMenu.menu_item
    ~label:"Classic"
    ~packing:file_menu#append () in
  ignore(item#connect#activate ~callback:(fun()->
    !scaleRef0#set_value 100.;
    !scaleRef1#set_value 100.;
    !scaleRef2#set_value 100.;
    !scaleRef3#set_value 100.;
    !scaleRef4#set_value 100.;
    !scaleRef5#set_value 100.;
    !scaleRef6#set_value 58.;
    !scaleRef7#set_value 58.;
    !scaleRef8#set_value 58.;
    !scaleRef9#set_value 48.;
    Wrap.egal_sound "classique"));
  let item = GMenu.menu_item
    ~label:"Rock                          "
    ~packing:file_menu#append () in
  ignore(item#connect#activate ~callback:(fun () ->
    !scaleRef0#set_value 200.;
    !scaleRef1#set_value 140.;
    !scaleRef2#set_value 62.5;
    !scaleRef3#set_value 55.;
    !scaleRef4#set_value 80.;
    !scaleRef5#set_value 130.;
    !scaleRef6#set_value 230.;
    !scaleRef7#set_value 250.;
    !scaleRef8#set_value 250.;
    !scaleRef9#set_value 250.;
    Wrap.egal_sound "rock"));
  let item = GMenu.menu_item
    ~label:"Techno"
    ~packing:file_menu#append () in
  ignore(item#connect#activate ~callback:(fun () ->
    !scaleRef0#set_value 200.;
    !scaleRef1#set_value 160.;
    !scaleRef2#set_value 95.;
    !scaleRef3#set_value 62.5;
    !scaleRef4#set_value 70.;
    !scaleRef5#set_value 95.;
    !scaleRef6#set_value 200.;
    !scaleRef7#set_value 240.;
    !scaleRef8#set_value 240.;
    !scaleRef9#set_value 220.;
    Wrap.egal_sound "techno"));
  let file_item = GMenu.menu_item ~label:"Equalizer already created" () in
  file_item#set_submenu file_menu;
  menu_bar#append file_item

let flange=
  let fbut = GButton.toggle_button
    ~show:true
    ~label:"Flange"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(fbut#connect#clicked ~callback:Wrap.flange_sound);
  fbut

let chorus =
  let cbut = GButton.toggle_button
    ~show:true
    ~label:"Chorus"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(cbut#connect#clicked ~callback:Wrap.chorus_sound);
  cbut

let lowpass=
  let lbut = GButton.toggle_button
    ~show:true
    ~label:"Low Pass"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(lbut#connect#clicked ~callback:Wrap.lpasse_sound);
  lbut

let highpass=
  let hbut = GButton.toggle_button
    ~show:true
    ~label:"High Pass"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(hbut#connect#clicked ~callback:Wrap.hpasse_sound);
  hbut
