let ext wanted s =
  if String.length s > 4 then
    begin
      let ext = String.sub s ((String.length s) - 4) 4 in
      match ext with
        |s when s = wanted -> true
        |_ -> false
    end
  else
    false

let read file =
  if ext ".mp3" file then
    Mp3.read file
  else
    []

let write file data =
  if ext ".mp3" file then
    Mp3.write file data

let rec giveInfo tags list =
  match tags with
    [] -> ""
  | hd :: tl -> try List.assoc hd list with Not_found -> giveInfo tl list
