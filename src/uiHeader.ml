                        (** Header **)

(** Menu **)

let menubox = GPack.hbox
  ~border_width: 0
  ~homogeneous: false
  ~height: 60
  ~packing:(Ui.header#pack ~expand:false) ()

let toolbar = GButton.toolbar
  ~orientation: `HORIZONTAL
  ~style: `BOTH
  ~width: 580
  ~height: 10
  ~packing: (menubox#pack ~expand:false) ()

(* Button d'ouverture du fichier *) 
let openB = GButton.tool_button
  ~stock:`OPEN
  ~packing: toolbar#insert ()

(* Button Save *)
let save = GButton.tool_button
  ~stock: `SAVE
  ~packing: toolbar#insert ()


let separator = GButton.separator_tool_item
  ~packing: toolbar#insert ()


(* Button Previous *)
let previous = GButton.tool_button
  ~stock:`MEDIA_PREVIOUS
  ~label:"Previous"
  ~packing:toolbar#insert ()

(* Button Play/Pause *)
let play = GButton.tool_button
    ~stock:`MEDIA_PLAY
    ~label:"Play"
    ~packing:toolbar#insert ()
let pause = GButton.tool_button
    ~stock:`MEDIA_PAUSE
    ~label:"Pause"
    ~packing:toolbar#insert ()

(* Button Stop *)
let stop = GButton.tool_button
  ~stock:`MEDIA_STOP
  ~label:"Stop"
  ~packing:toolbar#insert ()

(* Button Next *)
let next = GButton.tool_button
  ~stock:`MEDIA_NEXT
  ~label:"Next"
  ~packing:toolbar#insert ()

let boxLectureMode =
  let item = GButton.tool_item
    ~packing:toolbar#insert () in
  GPack.vbox
    ~packing:item#add ()

(* Button Random *)
let alea = GButton.toggle_button
  ~label:"Random"
  ~packing:boxLectureMode#add ()

(* Button Repeat *)
let repeat = GButton.toggle_button
  ~label:"Repeat"
  ~packing:boxLectureMode#add ()


(* Volume's Scale *)
let volume =
  let box = GPack.hbox
    ~width: 90
    ~packing:(menubox#pack ~expand:false) () in
  let adj= GData.adjustment
    ~value:50.
    ~lower:0.
    ~upper:110.
    ~step_incr:1. () in
  GRange.scale `HORIZONTAL
    ~draw_value:true
    ~show:true
    ~digits: 0
    ~adjustment:adj
    ~packing:box#add ()



let infobar = GButton.toolbar
  ~orientation:`HORIZONTAL
  ~style:`BOTH
  ~packing:(menubox#pack ~expand:true) ()

(* Button Properties *)
let pref = GButton.tool_button
  ~stock:`PROPERTIES
  ~packing:infobar#insert ()

(* Button About *)
let about = GButton.tool_button
  ~stock:`ABOUT
  ~packing:infobar#insert ()

(** Actual Song **)

let soundText =
  let box = GPack.hbox
    ~homogeneous: false
    ~height: 20
    ~packing: (Ui.header#pack ~expand:false) () in
  let scroll = GBin.scrolled_window
    ~hpolicy: `NEVER
    ~vpolicy: `NEVER
    ~shadow_type: `ETCHED_IN
    ~packing: box#add () in
  let txt = GText.view
    ~editable: false
    ~cursor_visible: false
    ~packing: scroll#add () in
  txt#misc#modify_font_by_name "Monospace 10";
  txt

(** Timeline **)

let timeLinebox = GPack.hbox
  ~homogeneous: false
  ~height: 15
  ~packing:(Ui.header#pack ~expand:false) ()

let timeCurrent = GMisc.label
  ~width:40
  ~text:"00:00:00"
  ~show:false
  ~packing:timeLinebox#add ()

let adjTime = GData.adjustment
  ~value:0.
  ~lower:0.
  ~upper:1010.
  ~step_incr:1. ()

let timeLine = 
  let b = GPack.hbox
    ~width:630
    ~packing:timeLinebox#add () in
  GRange.scale `HORIZONTAL
    ~adjustment:adjTime
    ~show:false
    ~packing:b#add ()

let timeTotal = GMisc.label
  ~width:40
  ~text:"00:00:00"
  ~show:false
  ~packing:timeLinebox#add ()
