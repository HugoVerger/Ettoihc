module Id3v1 = struct 
  type tag = Mp3.Id3v1.tag =  { 
      mutable title: string; 
      mutable artist: string; 
      mutable album: string;
      mutable year:string; 
      mutable comment: string; 
      mutable tracknum: int; 
      mutable genre: int 
    }
	
  let has_tag = Mp3.Id3v1.has_tag
  let read = Mp3.Id3v1.read_file
  let write t f = Mp3.Id3v1.write_file f t
  let writeFile f t ar al y c n = Mp3.Id3v1.write f t ar al y c n
  let merge = Mp3.Id3v1.merge
  let no_tag = Mp3.Id3v1.no_tag

end

module Id3v2 = struct 
  type tag = (string * string) list

  let read = Mp3.Id3v2.read_file
  let write t ?src f = Mp3.Id3v2.write_file ?src f t
  let merge = Mp3.Id3v2.merge
  let no_tag = Mp3.Id3v2.no_tag

end

let read_both_as_v1 f = 
  let ic = open_in f in
  let i = Mp3.read_channel_both_v1 ic in
  close_in ic;
  i

let read_both_as_v2 f = 
  let ic = open_in f in
  let i = Mp3.read_channel_both_v2 ic in
  close_in ic ;
  i

let write_both_v1 t ?src f = Mp3.write_file_both_v1 ?src f t
let write_both_v2 t ?src f= Mp3.write_file_both_v2 ?src f t


let v2_of_v1 = Mp3.v1_to_v2
let v1_of_v2 = Mp3.v2_to_v1
