let toolbar = GButton.toolbar  
	~orientation:`HORIZONTAL  
	~style:`BOTH
	~width:490
	~height:10
	~packing:(Ettoihc.menubox#pack ~expand:false) ()

let volbox = GPack.hbox
	~width: 90
	~packing:(Ettoihc.menubox#pack ~expand:false) ()
	
let infobar = GButton.toolbar  
  ~orientation:`HORIZONTAL  
  ~style:`BOTH
  ~width:60
  ~packing:(Ettoihc.menubox#pack ~expand:false) ()

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
