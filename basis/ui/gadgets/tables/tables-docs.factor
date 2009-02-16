USING: help.markup help.syntax ui.commands ;
IN: ui.gadgets.tables

ARTICLE: "ui.gadgets.tables" "Table gadgets"
"The " { $vocab-link "ui.gadgets.tables" } " vocabulary implements table gadgets. Table gadgets display a grid of values, with each row's columns generated by a renderer object."
{ $command-map table "row" }
"The class of tables:"
{ $subsection table }
{ $subsection table? }
"Creating new tables:"
{ $subsection <table> } ;

ABOUT: "ui.gadgets.tables"