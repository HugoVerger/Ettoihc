                      (** Page Library **)

let page =
  let onglet = GPack.vbox () in
  let name = GMisc.label
    ~text:"Library" () in
  ignore(Ui.core#insert_page
    ~tab_label:name#coerce onglet#coerce);
  onglet

let cols = new GTree.column_list
let song = cols#add Gobject.Data.string
let artist = cols#add Gobject.Data.string
let album = cols#add Gobject.Data.string
let genre = cols#add Gobject.Data.string
let path = cols#add Gobject.Data.string

let store = GTree.list_store cols

let colName =
  let col = GTree.view_column
    ~title:"Title"
    ~renderer:(GTree.cell_renderer_text [], ["text", song]) () in
  col#set_min_width 150;
  col#set_clickable true;
  col

let colArtist =
  let col = GTree.view_column
    ~title:"Artist"
    ~renderer:(GTree.cell_renderer_text [], ["text", artist]) () in
  col#set_min_width 150;
  col#set_clickable true;
  col

let colAlbum =
  let col = GTree.view_column
    ~title:"Album"
    ~renderer:(GTree.cell_renderer_text [], ["text", album]) () in
  col#set_min_width 150;
  col#set_clickable true;
  col

let colGenre =
  let col = GTree.view_column
    ~title:"Genre"
    ~renderer:(GTree.cell_renderer_text [], ["text", genre]) () in
  col#set_min_width 50;
  col#set_clickable true;
  col

let colPath =
  let col = GTree.view_column
    ~title:"Path"
    ~renderer:(GTree.cell_renderer_text [], ["text", path]) () in
  col#set_min_width 290;
  col#set_clickable true;
  col

let biblioView =
  let scroll = GBin.scrolled_window
    ~hpolicy: `AUTOMATIC
    ~vpolicy: `ALWAYS
    ~packing: page#add () in
  let view = GTree.view 
    ~model: store
    ~packing: scroll#add () in
  ignore (view#append_column colName);
  ignore (view#append_column colArtist);
  ignore (view#append_column colAlbum);
  ignore (view#append_column colGenre);
  ignore (view#append_column colPath);
  view
