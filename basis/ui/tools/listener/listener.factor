! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inspector help help.markup io io.styles kernel models strings
namespaces parser quotations sequences vocabs words prettyprint
listener debugger threads boxes concurrency.flags math arrays
generic accessors combinators assocs fry generic.standard.engines.tuple
ui.commands ui.gadgets ui.gadgets.editors ui.gadgets.labelled
ui.gadgets.panes ui.gadgets.buttons ui.gadgets.scrollers ui.gadgets.packs
ui.gadgets.tracks ui.gadgets.borders ui.gadgets.frames
ui.gadgets.grids ui.gestures ui.operations ui.tools.browser
ui.tools.interactor ui.tools.inspector ui.tools.workspace
ui.tools.common ;
IN: ui.tools.listener

TUPLE: listener-gadget < track input output scroller ;

: listener-streams ( listener -- input output )
    [ input>> ] [ output>> ] bi <pane-stream> ;

: <listener-input> ( listener -- gadget )
    output>> <pane-stream> <interactor> ;

: welcome. ( -- )
    "If this is your first time with Factor, please read the " print
    "handbook" ($link) ". To see a list of keyboard shortcuts," print
    "press F1." print nl ;

M: listener-gadget focusable-child*
    input>> ;

: wait-for-listener ( listener -- )
    #! Wait for the listener to start.
    input>> flag>> wait-for-flag ;

: workspace-busy? ( workspace -- ? )
    listener>> input>> interactor-busy? ;

GENERIC: listener-input ( obj -- )

M: input listener-input string>> listener-input ;

M: string listener-input
    get-workspace listener>> input>>
    [ set-editor-string ] [ request-focus ] bi ;

: (call-listener) ( quot listener -- )
    input>> interactor-call ;

: call-listener ( quot -- )
    [ workspace-busy? not ] get-workspace* listener>>
    '[ _ _ dup wait-for-listener (call-listener) ]
    "Listener call" spawn drop ;

M: listener-command invoke-command ( target command -- )
    command-quot call-listener ;

M: listener-operation invoke-command ( target command -- )
    [ hook>> call ] keep operation-quot call-listener ;

: eval-listener ( string -- )
    get-workspace
    listener>> input>> [ set-editor-string ] keep
    evaluate-input ;

: listener-run-files ( seq -- )
    [
        '[ _ [ run-file ] each ] call-listener
    ] unless-empty ;

: com-end ( listener -- )
    input>> interactor-eof ;

: clear-output ( listener -- )
    output>> pane-clear ;

\ clear-output H{ { +listener+ t } } define-command

: clear-stack ( listener -- )
    [ clear ] swap (call-listener) ;

GENERIC: word-completion-string ( word -- string )

M: word word-completion-string name>> ;

: method-completion-string ( word -- string )
    "method-generic" word-prop word-completion-string ;

M: method-body word-completion-string method-completion-string ;

M: engine-word word-completion-string method-completion-string ;

: use-if-necessary ( word seq -- )
    over vocabulary>> over and [
        2dup [ assoc-stack ] keep = [ 2drop ] [
            [ vocabulary>> vocab-words ] dip push
        ] if
    ] [ 2drop ] if ;

: insert-word ( word -- )
    get-workspace listener>> input>>
    [ [ word-completion-string ] dip user-input* drop ]
    [ interactor-use use-if-necessary ]
    2bi ;

: quot-action ( interactor -- lines )
    [ control-value ] keep
    [ [ "\n" join ] dip add-interactor-history ]
    [ select-all ]
    2bi ;

: ui-error-hook ( error listener -- )
    find-workspace debugger-popup ;

: listener-thread ( listener -- )
    dup listener-streams [
        [ com-follow ] help-hook set
        '[ _ ui-error-hook ] error-hook set
        welcome.
        listener
    ] with-streams* ;

: start-listener-thread ( listener -- )
    '[
        _
        [ input>> register-self ]
        [ listener-thread ]
        bi
    ] "Listener" spawn drop ;

: restart-listener ( listener -- )
    #! Returns when listener is ready to receive input.
    {
        [ com-end ]
        [ clear-output ]
        [ input>> clear-editor ]
        [ start-listener-thread ]
        [ wait-for-listener ]
    } cleave ;

: init-listener ( listener -- listener )
    <scrolling-pane> >>output
    dup <listener-input> >>input ;

: <listener-scroller> ( listener -- scroller )
    <frame>
        over output>> @top grid-add
        swap input>> @center grid-add
    <scroller> ;

: <listener-gadget> ( -- gadget )
    { 0 1 } listener-gadget new-track
        add-toolbar
        init-listener
        dup <listener-scroller> >>scroller
        dup scroller>> 1 track-add ;

: listener-help ( -- ) "ui-listener" com-follow ;

\ listener-help H{ { +nullary+ t } } define-command

: com-auto-use ( -- )
    auto-use? [ not ] change ;

\ com-auto-use H{ { +nullary+ t } { +listener+ t } } define-command

listener-gadget "misc" "Miscellaneous commands" {
    { T{ key-down f f "F1" } listener-help }
} define-command-map

listener-gadget "toolbar" f {
    { f restart-listener }
    { T{ key-down f { A+ } "u" } com-auto-use }
    { T{ key-down f { A+ } "k" } clear-output }
    { T{ key-down f { A+ } "K" } clear-stack }
    { T{ key-down f { C+ } "d" } com-end }
} define-command-map

listener-gadget "scrolling"
"The listener's scroller can be scrolled from the keyboard."
{
    { T{ key-down f { A+ } "UP" } com-scroll-up }
    { T{ key-down f { A+ } "DOWN" } com-scroll-down }
    { T{ key-down f { A+ } "PAGE_UP" } com-page-up }
    { T{ key-down f { A+ } "PAGE_DOWN" } com-page-down }
} define-command-map

M: listener-gadget graft*
    [ call-next-method ] [ restart-listener ] bi ;

M: listener-gadget ungraft*
    [ com-end ] [ call-next-method ] bi ;
