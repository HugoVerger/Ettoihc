(*let pause = ref true
let random = ref false
let color1 = ref "#ffffff"
let color2 = ref "#000000"
let playListForSave = ref ""
let play = ref (fun () -> ())
let stop = ref (fun () -> ())

let str_op = function
  | Some x -> x
  | _ -> failwith "Need a file"


(* Fenêtre d'ouverture *)

let openDialog filepath signal = 
  let dlg = GWindow.file_chooser_dialog
    ~action:`OPEN
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title: "Select a music"
    ~destroy_with_parent:true () in
  dlg#set_filter music_filter;
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `MEDIA_PLAY `MEDIA_PLAY;
  dlg#add_button_stock (`STOCK "Add Biblio") (`STOCK "Add Biblio");
  let tmp = dlg#run () in
  if tmp = (`STOCK "Add Biblio") then
    begin
      filepath := str_op(dlg#filename);
      signal := "biblio"
    end
  else
    begin
      if tmp = `MEDIA_PLAY then
        begin
          filepath := str_op(dlg#filename);
          signal := "play";
        end
      else
        begin
          if tmp = `CANCEL then
            begin
              signal := "cancel"
            end;
        end;
    end;
  dlg#misc#hide ()*)

(* Fenêtre de sauvegarde *)

(*let saveDialog () = 
  let dlg =
  GWindow.file_chooser_dialog
    ~action:`SAVE
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title:"Save of the playlist"
    ~destroy_with_parent:true () in
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_select_button_stock `SAVE `SAVE;
  if  (dlg#run () = `SAVE) then
       Wrap.playlistSave (str_op(dlg#filename)) !playListForSave;
  dlg#misc#hide ()

(* Changement tag*)

let tagW file =
  let dlg = GWindow.dialog
    ~parent:window
    ~destroy_with_parent:true
    ~title:"Edit Tag"
    ~show:true
    ~width:200
    ~height:300
    ~position:`CENTER_ON_PARENT () in
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `SAVE `SAVE;*)
  
  let t = Meta.v1_of_v2 (Meta.read_both_as_v2 file) in
  
  (*let b = GPack.hbox
    ~homogeneous:false ~height:10 ~border_width:10
    ~packing:dlg#vbox#add () in
  ignore(GMisc.label ~width:80 ~height:10 ~text:"Number" ~packing:b#add ());
  let tracknum = GText.view
    ~width:110 ~editable: true ~cursor_visible: true ~packing:b#add () in*)
  tracknum#buffer#set_text (string_of_int(t.Meta.Id3v1.tracknum));
  
  (*let b = GPack.hbox
    ~homogeneous:false ~height:10 ~border_width:10
    ~packing:dlg#vbox#add () in
  ignore(GMisc.label ~width:80 ~height:10 ~text:"Title" ~packing:b#add ());
  let title = GText.view
    ~width:110 ~editable: true ~cursor_visible: true ~packing:b#add () in*)
  title#buffer#set_text t.Meta.Id3v1.title;
  
  (*let b = GPack.hbox
    ~homogeneous:false ~height:10 ~border_width:10
    ~packing:dlg#vbox#add () in
  ignore(GMisc.label ~width:80 ~height:10 ~text:"Artist" ~packing:b#add ());
  let artist = GText.view
    ~width:110 ~editable: true ~cursor_visible: true ~packing:b#add () in*)
  artist#buffer#set_text t.Meta.Id3v1.artist;
  
  (*let b = GPack.hbox
    ~homogeneous:false ~height:10 ~border_width:10
    ~packing:dlg#vbox#add () in
  ignore(GMisc.label ~width:80 ~height:10 ~text:"Album" ~packing:b#add ());
  let album = GText.view
    ~width:110 ~editable: true ~cursor_visible: true ~packing:b#add () in*)
  album#buffer#set_text t.Meta.Id3v1.album;
  
  (*let b = GPack.hbox
    ~homogeneous:false ~height:10 ~border_width:10
    ~packing:dlg#vbox#add () in
  ignore(GMisc.label ~width:80 ~height:10 ~text:"Year" ~packing:b#add ()); 
  let year = GText.view
    ~width:110 ~editable: true ~cursor_visible: true ~packing:b#add () in*)
  year#buffer#set_text t.Meta.Id3v1.year;
  
  (*let b = GPack.hbox
    ~homogeneous:false ~height:10 ~border_width:10
    ~packing:dlg#vbox#add () in
  ignore(GMisc.label ~width:80 ~height:10 ~text:"Comment" ~packing:b#add ());
  let comment = GText.view
    ~width:110 ~editable: true ~cursor_visible: true ~packing:b#add () in*)
  comment#buffer#set_text t.Meta.Id3v1.comment;
    
  if dlg#run () == `SAVE then
    begin
      Meta.Id3v1.writeFile file 
                           (title#buffer#get_text ())
                           (artist#buffer#get_text ())
                           (album#buffer#get_text ())
                           (year#buffer#get_text ())
                           (comment#buffer#get_text ())
                           (int_of_string (tracknum#buffer#get_text ()))
    end;
  dlg#destroy ()

(* Fenêtre de préférence *)

(*let convert_hexa n =
  let string_of_char = String.make 1 in
  let s1 = ref '0' and s2 = ref '0' in
  if n/256 > 15 then
    begin
      let tmp = (n /256 / 16) in
      if tmp > 9 then
        begin
          let tmp2 = tmp + 65 - 10 in
          s1 := Char.chr tmp2
        end
    end;
  let tmp = (n /256 mod 16) in
  if tmp > 9 then
    begin
      let tmp2 = tmp + 65 - 10 in
      s2 := Char.chr tmp2
    end;
  (string_of_char !s1) ^ string_of_char (!s2)

let pref () =
  let dlg = GWindow.dialog
    ~parent:window
    ~destroy_with_parent:true
    ~title:"Properties"
    ~show:true
    ~width:200
    ~height:350
    ~position:`CENTER_ON_PARENT () in
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `SAVE `SAVE;
  let frame_horz = GBin.frame ~label:"Library Columns"    
    ~packing:dlg#vbox#add () in
  let bbox = GPack.button_box `VERTICAL
    ~spacing:10
    ~border_width:5
    ~packing:frame_horz#add () in
  let titlebtn = GButton.check_button 
    ~active:colName#visible
    ~label:"Title"
    ~packing:bbox#add () in
  let artistbtn = GButton.check_button 
    ~active:colArtist#visible
    ~label:"Artist"
    ~packing:bbox#add () in
  let albumbtn = GButton.check_button
    ~active:colAlbum#visible
    ~label:"Album"
    ~packing:bbox#add () in
  let genrebtn = GButton.check_button 
    ~active:colGenre#visible
    ~label:"Genre"
    ~packing:bbox#add () in
  let pathbtn = GButton.check_button
    ~active:colPath#visible
    ~label:"Path"
    ~packing:bbox#add () in
  
  let frame = GBin.frame ~label:"Spectre colors"    
    ~packing:dlg#vbox#add () in
  let bbox = GPack.button_box `VERTICAL
    ~spacing:10
    ~border_width:5
    ~packing:frame#add () in  *)
    
(*  let d = GWindow.color_selection_dialog
    ~parent:window
    ~destroy_with_parent:true
    ~position:`CENTER_ON_PARENT () in
  ignore(d#ok_button#connect#clicked (fun () -> 
    let c = d#colorsel#color in
    let c1 = "#" ^ convert_hexa (Gdk.Color.red c) in
    let c2 = c1 ^ convert_hexa (Gdk.Color.green c) in
    color2 := c2 ^ convert_hexa(Gdk.Color.blue c)));
  let btn = GButton.button ~label:"Change Bars" ~packing:bbox#add () in
  ignore(GMisc.image ~stock:`COLOR_PICKER ~packing:btn#set_image ());
  ignore(btn#connect#clicked (fun () -> ignore (d#run ()); d#misc#hide ()));  
  
 let d = GWindow.color_selection_dialog
    ~parent:window
    ~destroy_with_parent:true
    ~position:`CENTER_ON_PARENT () in
  ignore(d#ok_button#connect#clicked (fun () -> 
    let c = d#colorsel#color in
    let c1 = "#" ^ convert_hexa (Gdk.Color.red c) in
    let c2 = c1 ^ convert_hexa (Gdk.Color.green c) in
    color1 := c2 ^ convert_hexa(Gdk.Color.blue c)));
  let btn = GButton.button ~label:"Change Background" ~packing:bbox#add () in
  ignore(GMisc.image ~stock:`COLOR_PICKER ~packing:btn#set_image ());
  ignore(btn#connect#clicked (fun () -> ignore (d#run ()); d#misc#hide ()));  
  
  let tmp = dlg#run () in
  if (tmp = `SAVE) then
    begin
      colName#set_visible (titlebtn#active);
      colArtist#set_visible (artistbtn#active);
      colAlbum#set_visible (albumbtn#active);
      colGenre#set_visible (genrebtn#active);
      colPath#set_visible (pathbtn#active);
    end;
    dlg#misc#hide ();
  ()

(* Fenêtre de confirmation de sortie *)

let confirm _ =
  let dlg = GWindow.message_dialog
    ~message:"<b><big>Do you really want to quit ?</big></b>\n"
    ~parent:window
    ~destroy_with_parent:true
    ~use_markup:true
    ~message_type:`QUESTION
    ~position:`CENTER_ON_PARENT
    ~buttons:GWindow.Buttons.yes_no () in
  let res = dlg#run () = `NO in
  dlg#destroy ();
  res*)

(* Fenêtre de problème biblio/playlist *)

(*let prob () =
  let dlg = GWindow.message_dialog
    ~title:"File Not Found"
    ~message:"<b><big>File Not Found</big>\nDo you want to search it ?</b>\n"
    ~parent:window
    ~destroy_with_parent:true
    ~use_markup:true
    ~message_type:`ERROR
    ~position:`CENTER_ON_PARENT
    ~buttons:GWindow.Buttons.ok_cancel () in
  let res = dlg#run () = `CANCEL in
  dlg#destroy ();
  res

(* Fenêtre de recherche *)

let searchDialog () = 
  let dlg = GWindow.file_chooser_dialog
    ~action:`OPEN
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title: "Select a music"
    ~destroy_with_parent:true () in
  dlg#set_filter music_filter;
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `OK `OK;
  let tmp = dlg#run () in
  dlg#misc#hide ();
  if tmp = `OK then
    ("ok", str_op(dlg#filename))
  else
    ("", "")


let get_extension s =
  let ext = String.sub s ((String.length s) - 4) 4 in
  match ext with
    |".mp3"-> true
    |_ -> false*)
