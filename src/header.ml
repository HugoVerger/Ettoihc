let filedisplay = ref ""

let toolbar = GButton.toolbar  
	~orientation:`HORIZONTAL  
	~style:`BOTH
	~width:520
	~height:10
	~packing:(Ettoihc.menubox#pack ~expand:false) ()

let volbox = GPack.hbox
	~width: 90
	~packing:(Ettoihc.menubox#pack ~expand:false) ()
	
let infobar = GButton.toolbar  
  ~orientation:`HORIZONTAL  
  ~style:`BOTH
  ~width:80
  ~packing:(Ettoihc.menubox#pack ~expand:false) ()


(* Barre de volume *)
let volume=
  let file_vol = ref 50. in
  let vol_change vol_b() =
    file_vol := vol_b#adjustment#value;
    Wrap.vol_sound (!file_vol /. 100.) in
  let adj= GData.adjustment 
    ~value:50.  
    ~lower:0.
    ~upper:110.  
    ~step_incr:1. () in
  let volume_scale = GRange.scale `HORIZONTAL
    ~draw_value:true
    ~show:true
    ~digits: 0
    ~adjustment:adj
    ~packing:volbox#add () in 
  ignore(volume_scale#connect#value_changed (vol_change volume_scale));
  volume_scale

(* Bouton "A propos" *)
let about_button =
  let dlg = GWindow.about_dialog
    ~authors:["Nablah"]
    ~version:"1.0"
    ~website:"http://ettoihc.wordpress.com/"
    ~website_label:"Ettoihc Website"
    ~position:`CENTER_ON_PARENT
    ~parent:Ettoihc.window
    ~width: 400
    ~height: 150
    ~destroy_with_parent:true () in
  let btn = GButton.tool_button 
    ~stock:`ABOUT 
    ~packing:infobar#insert () in
  ignore(btn#connect#clicked (fun () -> 
    ignore (dlg#run ()); dlg#misc#hide ()));
  btn


(* Fichier en cours de lecture *)
let soundText =
  let scroll = GBin.scrolled_window
    ~hpolicy:`NEVER
    ~vpolicy:`NEVER
    ~shadow_type:`ETCHED_IN
    ~packing:Ettoihc.soundbox#add () in
  let txt = GText.view 
    ~packing:scroll#add ()
    ~editable: false  
    ~cursor_visible: false in
  txt#misc#modify_font_by_name "Monospace 10";
  txt

let actDisplay filepath =
  if (filepath = "") then
    filedisplay := ""
  else
    (begin
      if Meta.Id3v1.has_tag filepath then
		    let t = Meta.Id3v1.read_file filepath in
		    filedisplay := Meta.Id3v1.getTitle t ^ " - " ^ Meta.Id3v1.getArtist t
	    else
		    filedisplay := filepath
    end);
  soundText#buffer#set_text (!filedisplay)
