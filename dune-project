(lang dune 3.12)
(using mdx 0.4)

(name atacama)

(generate_opam_files true)

(source
 (github suri-framework/atacama))

(authors "Leandro Ostera <leandro@abstractmachines.dev>")

(maintainers "Leandro Ostera <leandro@abstractmachines.dev>")

(license MIT)

(package
 (name atacama)
 (synopsis "Modern, pure OCaml socket pool for Riot")
 (description "Atacama is a modern, pure OCaml socket pool for Riot inspired by Thousand Island. It aims to be easy to understand and reason about, while also being at least as stable and performant as the alternatives.")
 (depends
   (mdx (and :with-test (>= "2.3.1")))
   (ocaml (>= "5.1"))
   (odoc (and :with-doc (>= "2.2.2")))
   (riot (>= "0.0.1"))
   (telemetry (>= "0.0.1")))
 (tags
  (socket "socket pool" tcp riot)))
