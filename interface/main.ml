(* Fenêtre principale *)

let window =
  ignore(GMain.init ());
  let wnd = GWindow.window
      ~title:"Ettoihc"
      ~position:`CENTER
      ~resizable:true
      ~width:420 
      ~height:256 () in
  ignore(wnd#connect#destroy GMain.quit);
  wnd

(* Fenêtre de confirmation de sortie *)

let confirm _ =
  let dlg = GWindow.message_dialog
    ~message:"<b><big>Voulez-vous vraiment quitter ?</big></b>\n"
    ~parent:window
    ~destroy_with_parent:true
    ~use_markup:true
    ~message_type:`QUESTION
    ~position:`CENTER_ON_PARENT
    ~buttons:GWindow.Buttons.yes_no () in
  let res = dlg#run () = `NO in
  dlg#destroy ();
  res


(* Boites de la fenêtre principale *)

let mainbox = GPack.vbox
  ~border_width:10
  ~packing:window#add ()

let toolbar = GButton.toolbar  
  ~orientation:`HORIZONTAL  
  ~style:`BOTH  
  ~packing:(mainbox#pack ~expand:false) ()

let centerbox = GPack.hbox 
  ~packing:mainbox#pack
  ~border_width:10 ()
 

(* Zone de texte *)

let text =
  let scroll = GBin.scrolled_window
    ~hpolicy:`ALWAYS
    ~vpolicy:`ALWAYS 
    ~shadow_type:`ETCHED_IN
    ~height: 160
    ~packing:centerbox#add () in
  let txt = GText.view 
    ~packing:scroll#add () in
  txt#misc#modify_font_by_name "Monospace 10";
  txt

(* Bouton d'ouvertuge du fichier *) 

let filepath = ref ""
  
let str_op = function
  | Some x -> x
  | _ -> failwith "Need a file"
      
let music_filter = GFile.filter
  ~name:"Music File"
  ~patterns:["*.mp3"]()
  
let open_button =
  let dlg = GWindow.file_chooser_dialog
    ~action:`OPEN
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title: "Chargement d'une musique"
    ~destroy_with_parent:true () in
    dlg#set_filter music_filter;
    dlg#add_button_stock `CANCEL `CANCEL;
    dlg#add_select_button_stock `OPEN `OPEN;
 let btn = GButton.tool_button 
    ~stock:`OPEN
    ~packing:toolbar#insert () in 
 ignore(btn#connect#clicked (fun () ->
    if dlg#run () = `OPEN then (filepath := (str_op(dlg#filename)));
    dlg#misc#hide ()));
 btn 

let separator1 = ignore (GButton.separator_tool_item ~packing:toolbar#insert ())

(* Bouton Previous *)

let previous_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PREVIOUS
    ~label:"Previous"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> ()));
  btn

(* Bouton Play *)

let play filename =
  if filename = "" then failwith "Need a file"
  else text#buffer#set_text (!filepath)
 
let play_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PLAY
    ~label:"Play"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> play !filepath));
  btn

(* Bouton Next *)

let next_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_NEXT
    ~label:"Next"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> ()));
  btn

let separator2 = ignore (GButton.separator_tool_item ~packing:toolbar#insert ())


(* Bouton "A propos" *)

let about_button =
  let dlg = GWindow.about_dialog
    ~authors:["Nablah"]
    ~version:"1.0"
    ~website:"http://ettoihc.wordpress.com/"
    ~website_label:"Ettoihc Website"
    ~position:`CENTER_ON_PARENT
    ~parent:window
    ~width: 400
    ~height: 150
    ~destroy_with_parent:true () in
  let btn = GButton.tool_button 
    ~stock:`ABOUT 
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> ignore (dlg#run ()); dlg#misc#hide ()));
  btn


(* Lancement de l'application *)

let _ = 
  ignore(window#event#connect#delete confirm);
  window#show ();
  GMain.main ()
