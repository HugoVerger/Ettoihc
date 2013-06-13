let reset () =
  UiPage1.back#set_foreground (`NAME !UiPage1.colorBack);
  UiPage1.back#rectangle ~x:0 ~y:0 ~width:512 ~height:350 ~filled:true ();
  UiPage1.drawing#put_pixmap ~x:0 ~y:0 UiPage1.back#pixmap

let drawSpectre () =
  UiPage1.back#set_foreground (`NAME !UiPage1.colorBar);
  let n = ref 0 in
  let tab = Array.make 512 0. in
  Wrap.spectre_sound (tab);
  while (!n < 512) do
    let elt = min ((Array.get tab !n) *. 20. *. 350.) 350. in
    UiPage1.back#line ~x:(!n) ~y:350 ~x:(!n) ~y:(350 - int_of_float(elt));
    n := !n + 1
  done;
  UiPage1.drawing#put_pixmap ~x:0 ~y:0 UiPage1.back#pixmap
