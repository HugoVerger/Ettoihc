let chop_whitespace str from =
  let i = ref (String.length str) in
  while !i > from &&
        (let c = str.[!i-1] in c = '\000' || c = ' ' || c = '\t')
  do decr i done;
  String.sub str from (!i - from)


module Id3v1 = struct

  type tag = { 
      mutable title: string; 
      mutable artist: string; 
      mutable album: string;
      mutable year:string; 
      mutable comment: string; 
      mutable tracknum: int; 
      mutable genre: int }

  let read_channel ic =
    let len = in_channel_length ic in
    if len < 128 then raise Not_found;
    seek_in ic (len - 128);
    let readstring len =
      let buf = String.create len in
      really_input ic buf 0 len;
      chop_whitespace buf 0 in
    if readstring 3 <> "TAG" then raise Not_found;
    let title = readstring 30 in
    let artist = readstring 30 in
    let album = readstring 30 in
    let year = readstring 4 in
    let comment = readstring 29 in
    let tracknum = input_byte ic in
    let genre = input_byte ic in
    { title = title; artist = artist; album = album; year = year;
      comment = comment; tracknum = tracknum; genre = genre }

let getTitle t = t.title
let getArtist t = t.artist
let getAlbum t = t.album
let getYear t = t.year
let getComment t = t.comment
let getNum t = string_of_int t.tracknum
let getGenre t = t.genre

let read_file filename =
    let ic = open_in_bin filename in
      let res = read_channel ic in
      close_in ic; res

      
  let has_tag filename =
    let ic = open_in_bin filename in
    let len = in_channel_length ic in
    let res =
      if len < 128 then false else begin
        seek_in ic (len - 128);
        let buffer = String.create 3 in
        really_input ic buffer 0 3;
        buffer = "TAG"
      end in
    close_in ic;
    res
end
