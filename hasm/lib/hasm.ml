open Stdint

let n = Uint16.of_int 7

let zero_pad16 s =
    let zeros = Str.first_chars "0000000000000000" (16 - (String.length s)) in
    zeros ^ s

let binstr16 n =
    n
    |> Uint16.to_string_bin
    |> Str.replace_first (Str.regexp "^0b") ""
    |> zero_pad16 ;;

