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
  let adj10 = GData.adjustment
    ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
  let box10 = GPack.vbox
	  ~height: 130 ~homogeneous:false ~spacing:0 
	  ~packing:(Ettoihc.firstLineBox2#pack ~expand:false) () in
  let scale10 = GRange.scale `VERTICAL
    ~draw_value:true ~value_pos:`BOTTOM ~show:true
    ~digits: 0 ~inverted:true ~adjustment:adj10 ~packing:box10#add () in
  ignore(scale10#connect#value_changed (egal_change 15000. scale10));
  ignore(GMisc.label ~height:10 ~text:"15kHz" ~packing:box10#add ())
  

let rock =
  let abut = GButton.button
    ~show:true
    ~label:"Equalization Rock"
    ~relief:`NORMAL
    ~packing:Ettoihc.firstLineBox2Vbox#add() in
  ignore(abut#connect#clicked ~callback:Wrap.rock_sound);
  abut

let flange=
  let fbut = GButton.button
    ~show:true
    ~label:"Flange"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(fbut#connect#clicked ~callback:Wrap.flange_sound);
  fbut

let chorus =
  let cbut = GButton.button
    ~show:true
    ~label:"Chorus"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(cbut#connect#clicked ~callback:Wrap.chorus_sound);
  cbut

let lowpass=
  let lbut = GButton.button
    ~show:true
    ~label:"Low Pass"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(lbut#connect#clicked ~callback:Wrap.lpasse_sound);
  lbut

let highpass=
  let hbut = GButton.button
    ~show:true
    ~label:"High Pass"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(hbut#connect#clicked ~callback:Wrap.hpasse_sound);
  hbut
