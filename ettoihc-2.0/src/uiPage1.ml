                      (** Page Playlist **)

let nbSong = ref 0

(** Actual playlist **)

let page =
  let onglet = GPack.hbox () in
  let name = GMisc.label
    ~text:"Now Playing" () in
  ignore(Ui.core#insert_page
    ~tab_label:name#coerce onglet#coerce);
  onglet

let cols = new GTree.column_list
let nmb = cols#add Gobject.Data.int
let random = cols#add Gobject.Data.int
let title = cols#add Gobject.Data.string
let artist = cols#add Gobject.Data.string
let path = cols#add Gobject.Data.string

let store = GTree.list_store cols

let playlistNmb =
  let col = GTree.view_column
    ~renderer:(GTree.cell_renderer_text [], ["text", nmb]) () in
  col#set_min_width 20;
  col

let playlistRandom =
  let col = GTree.view_column
    ~renderer:(GTree.cell_renderer_text [], ["text", random]) () in
  col#set_min_width 20;
  col

let playlistTitle =
  let col = GTree.view_column
    ~title:"Title"
    ~renderer:(GTree.cell_renderer_text [], ["text", title]) () in
  col#set_min_width 150;
  col

let playlistArtist =
  let col = GTree.view_column
    ~title:"Artist"
    ~renderer:(GTree.cell_renderer_text [], ["text", artist]) () in
  col#set_min_width 150;
  col

let playlistPath = GTree.view_column
  ~title:"Path"
  ~renderer:(GTree.cell_renderer_text [], ["text", path]) ()

let view =
  let scroll = GBin.scrolled_window
    ~hpolicy: `AUTOMATIC
    ~vpolicy: `ALWAYS
    ~packing: page#add () in
  let view = GTree.view 
    ~model: store
    ~height:350
    ~width:420
    ~packing: scroll#add () in
  playlistRandom#set_visible false;
  playlistPath#set_visible false;
  ignore (view#append_column playlistNmb);
  ignore (view#append_column playlistRandom);
  ignore (view#append_column playlistTitle);
  ignore (view#append_column playlistArtist);
  ignore (view#append_column playlistPath);
  view

(** Visual Effects **)

let colorBar = ref "#FFFFFF"
let colorBack = ref "#000000"

let drawing_area = GMisc.drawing_area
  ~width:512
  ~height:350
  ~packing: page#add ()
