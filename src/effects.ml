(** Equalizer **)

let fonctionAdj = ref []
let equalizerNames = ref []

let addFoncAdj name (a,b,c,d,e,f,g,h,i,j) =
  let refScale = UiPage3.scaleRef in
  let func = (fun () ->
    refScale.(0)#set_value a; refScale.(1)#set_value b;
    refScale.(2)#set_value c; refScale.(3)#set_value d;
    refScale.(4)#set_value e; refScale.(5)#set_value f;
    refScale.(6)#set_value g; refScale.(7)#set_value h;
    refScale.(8)#set_value i; refScale.(9)#set_value j;
    for i = 0 to 9 do
      Wrap.egaliseur UiPage3.frequences.(i) refScale.(i)#value;
    done) in
  fonctionAdj := (name, func, (a,b,c,d,e,f,g,h,i,j)) :: !fonctionAdj

let startEqualizer () =
  let chan = open_in "bin/equalizer" in
  try
    while true; do
      let name = input_line chan in
      let a1 = float_of_string (input_line chan) in
      let a2 = float_of_string (input_line chan) in
      let a3 = float_of_string (input_line chan) in
      let a4 = float_of_string (input_line chan) in
      let a5 = float_of_string (input_line chan) in
      let a6 = float_of_string (input_line chan) in
      let a7 = float_of_string (input_line chan) in
      let a8 = float_of_string (input_line chan) in
      let a9 = float_of_string (input_line chan) in
      let a10 = float_of_string (input_line chan) in
      equalizerNames := name :: !equalizerNames;
      addFoncAdj name (a1,a2,a3,a4,a5,a6,a7,a8,a9,a10);
    done;
  with End_of_file ->
    close_in chan;
  UiPage3.equalizerCombo#set_popdown_strings !equalizerNames;
  UiPage3.equalizerCombo#entry#set_text "Equalizer already created"

let printEqualizer () =
  let oc = open_out "bin/equalizer" in
  let rec printlist = function
    |[] -> ()
    |(n,f,(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10))::t -> 
      begin
        Printf.fprintf oc "%s\n" n;
        Printf.fprintf oc "%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n" 
                           a1 a2 a3 a4 a5 a6 a7 a8 a9 a10;
        printlist t
      end in
  printlist (List.rev !fonctionAdj);
  close_out oc

(** Connecting UI/functions **)

let dist scale () =
    Wrap.dist_sound (scale#adjustment#value /. 100.)

let echo scale () =
    Wrap.echo_sound (scale#adjustment#value /. 100.)

let pan_changed scale () =
  if (scale#adjustment#value = 0.) then
    Wrap.soundPan (-1.)
  else if (scale#adjustment#value = 20.) then
    Wrap.soundPan 255.
  else 
    Wrap.soundPan 0.

let saveEgalizer () =
  let select = UiPage3.equalizerCombo#entry#text in
  if not (List.mem select !equalizerNames) then
    begin
      let scaleRef = UiPage3.scaleRef in
      equalizerNames := select :: !equalizerNames;
      UiPage3.equalizerCombo#set_popdown_strings !equalizerNames;
      addFoncAdj select
        (scaleRef.(0)#value, scaleRef.(1)#value, scaleRef.(2)#value, 
         scaleRef.(3)#value, scaleRef.(4)#value, scaleRef.(5)#value,
         scaleRef.(6)#value, scaleRef.(7)#value, scaleRef.(8)#value, 
         scaleRef.(9)#value)
    end;
  ()

let deleteEgalizer () =
  let select = UiPage3.equalizerCombo#entry#text in
  let rec place = function
    |[] -> 0
    |(n,_,_)::t when n = select -> 0
    |_::t -> 1 + place t in
  let n = place !fonctionAdj in
  UiPage3.equalizerCombo#list#clear_items (n) (n+1);
  let rec deleteE = function
    |[] -> []
    |(n,_,_)::t when n = select -> t
    |h::t -> h :: deleteE t in
  fonctionAdj := deleteE !fonctionAdj;
  UiPage3.equalizerCombo#entry#set_text "Default"

let change_egal () =
  let select = UiPage3.equalizerCombo#entry#text in

  let existselect = function
    |(n,_,_) when n = select -> true
    |_ -> false in

  if (List.exists existselect !fonctionAdj) then
    begin
      let f = List.find existselect !fonctionAdj in
      match f with 
        |(n,func,_) -> func ()
    end

let connectUI () =
  ignore(UiPage3.distorsion#connect#value_changed 
    (dist UiPage3.distorsion));
  ignore(UiPage3.echo#connect#value_changed 
    (echo UiPage3.echo));
  ignore(UiPage3.pan#connect#value_changed
    (pan_changed UiPage3.pan));

  ignore(UiPage3.equalizerCombo#list#connect#selection_changed
    ~callback: change_egal);
  ignore(UiPage3.save#connect#clicked 
    ~callback: saveEgalizer);
  ignore(UiPage3.delete#connect#clicked 
    ~callback: deleteEgalizer);

  ignore(UiPage3.highpass#connect#clicked 
    ~callback: Wrap.hpasse_sound);
  ignore(UiPage3.lowpass#connect#clicked 
    ~callback: Wrap.lpasse_sound);
  ignore(UiPage3.chorus#connect#clicked
    ~callback: Wrap.chorus_sound);
  ignore(UiPage3.flange#connect#clicked
    ~callback: Wrap.flange_sound);
