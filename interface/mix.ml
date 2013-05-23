let scaleRef = Array.create 10 (GData.adjustment ())
let frequence = [| "29Hz"; "59Hz" ; "119Hz"; "237Hz"; "474Hz"; 
                   "947Hz"; "2kHz"; "4kHz"; "8kHz"; "15kHz"|]
let frequences= [| 29.; 59.; 119.; 237.; 474.;
                   947.; 2000.; 4000.; 8000.; 15000.|]
let defaultEqualizer = ref []
let fonctionAdj = ref []

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

let addFoncAdj name (a,b,c,d,e,f,g,h,i,j) =
  let func = (fun () ->
    scaleRef.(0)#set_value a; scaleRef.(1)#set_value b;
    scaleRef.(2)#set_value c; scaleRef.(3)#set_value d;
    scaleRef.(4)#set_value e; scaleRef.(5)#set_value f;
    scaleRef.(6)#set_value g; scaleRef.(7)#set_value h;
    scaleRef.(8)#set_value i; scaleRef.(9)#set_value j;
    for i = 0 to 9 do
      Wrap.egaliseur frequences.(i) scaleRef.(i)#value;
    done) in
  fonctionAdj := (name, func, (a,b,c,d,e,f,g,h,i,j)) :: !fonctionAdj

let equalizerMenu =
  let box = GPack.hbox ~packing:Ettoihc.boxMenuMix#add () in
  let combo = GEdit.combo ~packing:box#add() in
  combo#set_popdown_strings !defaultEqualizer;
  combo#entry#set_text "Equalizer already created";
  combo#set_case_sensitive true;
  
  ignore(combo#list#connect#selection_changed ~callback:(fun()->
    let select = combo#entry#text in
    let existselect = function
      |(n,_,_) when n = select -> true
      |_ -> false in

    if (List.exists existselect !fonctionAdj) then
      begin
        let f = List.find existselect !fonctionAdj in
        match f with (n,func,_) -> func ()
      end));
  combo

let saveEgalizer () =
  let select = equalizerMenu#entry#text in
  if not (List.mem select !defaultEqualizer) then
    begin
      defaultEqualizer := select::!defaultEqualizer;
      equalizerMenu#set_popdown_strings !defaultEqualizer;
      addFoncAdj select
        (scaleRef.(0)#value, scaleRef.(1)#value, scaleRef.(2)#value, 
         scaleRef.(3)#value, scaleRef.(4)#value, scaleRef.(5)#value,
         scaleRef.(6)#value, scaleRef.(7)#value, scaleRef.(8)#value, 
         scaleRef.(9)#value)
    end;
  ()

let deleteEgalizer () =
  let select = equalizerMenu#entry#text in
  let rec place = function
    |[] -> 0
    |(n,_,_)::t when n = select -> 0
    |_::t -> 1 + place t in
  let n = place !fonctionAdj in
  equalizerMenu#list#clear_items (n) (n+1);
  let rec deleteE = function
    |[] -> []
    |(n,_,_)::t when n = select -> t
    |h::t -> h :: deleteE t in
  fonctionAdj := deleteE !fonctionAdj;
  equalizerMenu#entry#set_text "Default"

let menuBoxEgalizer = 
  let box = GButton.toolbar
    ~orientation:`HORIZONTAL ~width:300
    ~style:`ICONS
    ~packing:Ettoihc.boxMenuMix#add () in
  let btnsave = GButton.tool_button ~stock:`ADD ~packing:box#insert () in
  let btndelete = GButton.tool_button ~stock:`REMOVE ~packing:box#insert () in
  ignore(btnsave#connect#clicked ~callback: (fun () -> saveEgalizer ()));
  ignore(btndelete#connect#clicked ~callback: (fun () -> deleteEgalizer ()));
  box

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
    ignore(scale#connect#value_changed (egal_change frequences.(i) scale));
    ignore(GMisc.label ~height:10 ~text:(frequence.(i)) ~packing:box#add ());
    scaleRef.(i) <- adj;
  done

let printEqualizer () =
  let oc = open_out "bin/equalizer" in
  let rec printlist = function
    |[] -> ()
    |(n,f,(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10))::t -> 
      begin
        Printf.fprintf oc "%s\n" n;
        Printf.fprintf oc "%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n" 
                           a1 a2 a3 a4 a5 a6 a7 a8 a9 a10;
        printlist t
      end in
  printlist (List.rev !fonctionAdj);
  close_out oc

let startEqualizer () =
  let chan = open_in "bin/equalizer" in
  try
    while true; do
      let name = input_line chan in
      let a1 = float_of_string (input_line chan) in
      let a2 = float_of_string (input_line chan) in
      let a3 = float_of_string (input_line chan) in
      let a4 = float_of_string (input_line chan) in
      let a5 = float_of_string (input_line chan) in
      let a6 = float_of_string (input_line chan) in
      let a7 = float_of_string (input_line chan) in
      let a8 = float_of_string (input_line chan) in
      let a9 = float_of_string (input_line chan) in
      let a10 = float_of_string (input_line chan) in
      defaultEqualizer := name::!defaultEqualizer;
      addFoncAdj name (a1,a2,a3,a4,a5,a6,a7,a8,a9,a10);
    done;
  with End_of_file ->
    close_in chan;
  equalizerMenu#set_popdown_strings !defaultEqualizer;
  equalizerMenu#entry#set_text "Default"

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
