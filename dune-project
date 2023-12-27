(lang dune 3.11)

(name atacama)

(generate_opam_files true)

(source
 (github leostera/atacama))

(authors "Leandro Ostera <leandro@abstractmachines.dev>")

(maintainers "Leandro Ostera <leandro@abstractmachines.dev>")

(license MIT)

(package
 (name atacama)
 (synopsis "Modern, pure OCaml socket pool for Riot")
 (description "Atacama is a modern, pure OCaml socket pool for Riot inspired by Thousand Island. It aims to be easy to understand and reason about, while also being at least as stable and performant as the alternatives.")
 (depends
   (ocaml (>= "5.1"))
   (riot (>= "0.0.7"))
   (telemetry (>= "0.0.1")))
 (tags
  (socket "socket pool" tcp riot)))
