let scaleRef = Array.create 10 (GData.adjustment ())
let frequence = [| "29Hz"; "59Hz" ; "119Hz"; "237Hz"; "474Hz"; 
                   "947Hz"; "2kHz"; "4kHz"; "8kHz"; "15kHz"|]

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

let equalizerMenu =
  let combo = GEdit.combo ~packing:Ettoihc.boxMenuMix#add() in
  combo#set_popdown_strings ["Default"; "Classic"; "Rock"; "Techno"];
  combo#entry#set_text "Equalizer already created";
  combo#set_case_sensitive true;
  
  ignore(combo#list#connect#selection_changed ~callback:(fun()->
    let select = combo#entry#text in
    if select = "Default" then
      begin
        for i = 0 to 9 do
          scaleRef.(i)#set_value 100.;
        done;
        Wrap.egal_sound "default"
      end
    else if select = "Classic" then
      begin
        for i = 0 to 5 do
          scaleRef.(i)#set_value 100.;
        done;
        scaleRef.(6)#set_value 58.; scaleRef.(7)#set_value 58.;
        scaleRef.(8)#set_value 58.; scaleRef.(9)#set_value 48.;
        Wrap.egal_sound "classique"
      end
    else if select = "Rock" then
      begin
        scaleRef.(0)#set_value 200.; scaleRef.(1)#set_value 140.;
        scaleRef.(2)#set_value 62.5; scaleRef.(3)#set_value 55.;
        scaleRef.(4)#set_value 80.;  scaleRef.(5)#set_value 130.;
        scaleRef.(6)#set_value 230.;
        for i = 7 to 9 do
          scaleRef.(i)#set_value 250.;
        done;
        Wrap.egal_sound "rock"
      end
    else if select = "Techno" then
      begin
        scaleRef.(0)#set_value 200.; scaleRef.(1)#set_value 160.;
        scaleRef.(2)#set_value 95.;  scaleRef.(3)#set_value 62.5;
        scaleRef.(4)#set_value 70.;  scaleRef.(5)#set_value 95.;
        scaleRef.(6)#set_value 200.; scaleRef.(7)#set_value 240.;
        scaleRef.(8)#set_value 240.; scaleRef.(9)#set_value 220.;
        Wrap.egal_sound "techno"
      end));
  combo

let egaliseur =
  let egal_change f egal_b() =
    Wrap.egaliseur f (egal_b#adjustment#value) in
  for i = 0 to 9 do
    let adj = GData.adjustment
      ~value:100. ~lower:5. ~upper:310. ~step_incr:5. () in
    let box = GPack.vbox
      ~height: 130 ~homogeneous:false
      ~spacing:0 ~packing:(Ettoihc.boxEqualizerMix#pack ~expand:false) () in
    let scale = GRange.scale `VERTICAL
      ~draw_value:true ~value_pos:`BOTTOM ~show:true
      ~digits: 0 ~inverted:true ~adjustment:adj ~packing:box#add () in
    ignore(scale#connect#value_changed (egal_change 29. scale));
    ignore(GMisc.label ~height:10 ~text:(frequence.(i)) ~packing:box#add ());
    scaleRef.(i) <- adj;
  done

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
