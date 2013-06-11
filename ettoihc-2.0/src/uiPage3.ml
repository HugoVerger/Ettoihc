                      (** Page Sound Effects **)

let page =
  let onglet = GPack.vbox
    ~homogeneous: false () in
  let name = GMisc.label
    ~text: "Effects" () in
  ignore(Ui.core#insert_page
    ~tab_label: name#coerce onglet#coerce);
  onglet

let line1 =
  GPack.hbox ~packing:page#add ()

(** Distorsion/Echo/Pan **)

let leftPart =
  let frame = GBin.frame
    ~width: 220
    ~height: 260
    ~border_width: 0
    ~packing: line1#add () in
  GPack.button_box `HORIZONTAL
    ~layout: `SPREAD
    ~packing: frame#add()

let distorsion =
  let adj= GData.adjustment 
    ~value: 0.
    ~lower: 0.
    ~upper: 110.
    ~step_incr: 1. () in
  let box = GPack.vbox
    ~height: 130
    ~homogeneous: false
    ~spacing: 0
    ~packing: (leftPart#pack ~expand:false) () in
  let scale = GRange.scale `VERTICAL
    ~draw_value: true
    ~value_pos: `BOTTOM
    ~show: true
    ~digits:  0
    ~inverted: true
    ~adjustment: adj
    ~packing: box#add () in
  ignore(GMisc.label
    ~height:10
    ~text:"Distorsion"
    ~packing:box#add ());
  scale

let echo =
  let adj= GData.adjustment
    ~value: 0.
    ~lower: 0.
    ~upper: 110.
    ~step_incr: 1. () in
  let box = GPack.vbox
    ~height: 130
    ~homogeneous: false
    ~spacing: 0
    ~packing: (leftPart#pack ~expand:false) () in
  let scale = GRange.scale `VERTICAL
    ~draw_value: true
    ~value_pos: `BOTTOM
    ~show: true
    ~digits: 0
    ~inverted: true
    ~adjustment: adj
    ~packing: box#add () in
  ignore(GMisc.label
    ~height:10
    ~text:"Echo"
    ~packing: box#add ());
  scale

let pan =
  let adj= GData.adjustment 
    ~value: 10.
    ~lower: 0.
    ~upper: 30.
    ~step_incr: 10. () in
  let box = GPack.vbox
    ~height: 130
    ~homogeneous: false
    ~spacing: 0
    ~packing: (leftPart#pack ~expand:false) () in
  let scale = GRange.scale `HORIZONTAL
    ~draw_value: false
    ~value_pos: `BOTTOM
    ~show: true
    ~adjustment: adj
    ~packing: box#add () in
  ignore(GMisc.label 
    ~height: 10
    ~text: "Pan"
    ~packing: box#add ());
  scale

(** Equalizer **)

let scaleRef = Array.create 10 (GData.adjustment ())
let frequence = [| "29Hz"; "59Hz" ; "119Hz"; "237Hz"; "474Hz"; 
                   "947Hz"; "2kHz"; "4kHz"; "8kHz"; "15kHz"|]
let frequences= [| 29.; 59.; 119.; 237.; 474.;
                   947.; 2000.; 4000.; 8000.; 15000.|]

let rightPart =
  let frame = GBin.frame
    ~height: 260
    ~width: 420
    ~border_width: 0
    ~packing: line1#add () in
 GPack.vbox
  ~homogeneous: false
  ~packing: frame#add()

let menu = GPack.hbox
  ~homogeneous: false
  ~height: 30
  ~border_width: 5
  ~packing: rightPart#add ()

let equalizerCombo =
  let box = GPack.hbox 
    ~packing: menu#add () in
  let combo = GEdit.combo
    ~packing:box#add() in
  combo#set_case_sensitive true;
  combo

let equalizerMenu = GButton.toolbar
  ~orientation: `HORIZONTAL 
  ~width: 250
  ~style: `ICONS
  ~packing: menu#add ()

let save = GButton.tool_button 
  ~stock: `ADD
  ~packing: equalizerMenu#insert ()

let delete = GButton.tool_button
  ~stock: `REMOVE
  ~packing: equalizerMenu#insert ()

let equalizer = GPack.hbox
  ~spacing: 5
  ~border_width: 30
  ~packing: rightPart#add()

let egaliseur =
  let egal_change f egal_b() =
    Wrap.egaliseur f (egal_b#adjustment#value) in
  for i = 0 to 9 do
    let adj = GData.adjustment
      ~value: 100.
      ~lower: 5.
      ~upper: 310.
      ~step_incr: 5. () in
    let box = GPack.vbox
      ~height: 130
      ~homogeneous: false
      ~spacing: 0
      ~packing: (equalizer#pack ~expand:false) () in
    let scale = GRange.scale `VERTICAL
      ~draw_value: true
      ~value_pos: `BOTTOM
      ~show: true
      ~digits: 0
      ~inverted: true
      ~adjustment: adj
      ~packing: box#add () in
    ignore(scale#connect#value_changed (egal_change frequences.(i) scale));
    ignore(GMisc.label ~height:10 ~text:(frequence.(i)) ~packing:box#add ());
    scaleRef.(i) <- adj;
  done

(** Filters/Flange/Chorus **)

let line2 =
  let mixFrame =GBin.frame
    ~width: 300
    ~height: 100
    ~border_width: 0
    ~packing: page#add () in
  let bb = GPack.button_box `HORIZONTAL
    ~layout: `SPREAD
    ~packing: mixFrame#add() in
  bb#set_homogeneous false;
  bb

let flange = GButton.toggle_button
  ~show: true
  ~label: "Flange"
  ~relief: `NORMAL
  ~packing: line2#add()

let chorus = GButton.toggle_button
  ~show: true
  ~label: "Chorus"
  ~relief: `NORMAL
  ~packing: line2#add()

let lowpass = GButton.toggle_button
  ~show: true
  ~label: "Low Pass"
  ~relief: `NORMAL
  ~packing: line2#add()

let highpass = GButton.toggle_button
  ~show: true
  ~label: "High Pass"
  ~relief: `NORMAL
  ~packing: line2#add()
