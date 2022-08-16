*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_EXIT_SCANNER_MAIN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*--- Select All
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_select_all
    IMPORTING
      RESULT = allbtn.

*--- De-select All
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_deselect_all
    IMPORTING
      RESULT = dallbtn.

  CASE ss_ok_code.

*---- Deselect Exit checkboxes
    WHEN 'DSEL_ALL'.
      CLEAR:
            userexit, vofm, subst, valid, custexit, fieldext,
            screxit, bte, badi, modcua, modwrd, append, ci_incl,
            hookimpl, clasimpl, fugrimpl, badiimpl.

*---- Select Exit checkboxes
    WHEN 'SEL_ALL'.
      MOVE c_marked TO:
            userexit, vofm, subst, valid, custexit, fieldext,
            screxit, bte, badi, modcua, modwrd, append, ci_incl,
            hookimpl, clasimpl, fugrimpl, badiimpl.
  ENDCASE.

AT SELECTION-SCREEN ON EXIT-COMMAND.
  IF sy-ucomm = 'CEND' OR sy-ucomm = 'CBAC' OR sy-ucomm = 'CCAN'.
    LEAVE PROGRAM.
  ENDIF.

AT SELECTION-SCREEN.

  IF  sscrfields-ucomm = 'DSEL_ALL'.
    ss_ok_code = 'DSEL_ALL'.
  ELSEIF sscrfields-ucomm = 'SEL_ALL'.
    ss_ok_code = 'SEL_ALL'.
  ENDIF.

START-OF-SELECTION.

*maybe no field is marked so call the selection screen again
  WHILE ( custexit NE c_marked ) AND
        ( fieldext NE c_marked ) AND
        ( badi     NE c_marked ) AND
        ( bte      NE c_marked ) AND
        ( userexit NE c_marked ) AND
        ( vofm     NE c_marked ) AND
        ( subst    NE c_marked ) AND
        ( valid    NE c_marked ) AND
        ( screxit  ne c_marked ) and
        ( append   NE c_marked ) AND
        ( modcua   NE c_marked ) and
        ( modwrd   NE c_marked ) and
        ( ci_incl  NE c_marked ) and
        ( hookimpl  NE c_marked ) and
        ( fugrimpl  NE c_marked ) and
        ( clasimpl  NE c_marked ) and
        ( badiimpl  NE c_marked ) .

    MESSAGE i095(00).

    CALL SELECTION-SCREEN 1000.

  ENDWHILE.

  IF userexit = c_marked.
    PERFORM search_userexit.
  ENDIF.

  IF vofm = c_marked.
    PERFORM search_vofm_exit.
  ENDIF.

  IF subst = c_marked.
    PERFORM search_substitutions_exit.
  ENDIF.

  IF valid = c_marked.
    PERFORM search_validations_exit.
  ENDIF.

  IF screxit = c_marked.
    PERFORM search_screen_exit.
  ENDIF.

  IF modcua = c_marked.
    PERFORM search_menu_exit.
  ENDIF.

  IF modwrd = c_marked.
    PERFORM search_changed_keywords.
  ENDIF.

  IF custexit = c_marked.
    PERFORM search_cust_exit.
  ENDIF.

  IF  fieldext = c_marked.
    PERFORM search_field_exit.
  ENDIF.

  IF bte = c_marked .
    PERFORM search_bte.
  ENDIF.

  IF badi = c_marked.
    PERFORM search_badi.
  ENDIF.
*-- New ENHs objects
  if hookimpl is NOT INITIAL.
    perform search_hookimpl.
  endif.
  if fugrimpl is NOT INITIAL.
    perform search_fugrimpl.
  endif.
  if clasimpl is NOT INITIAL.
    perform search_clasimpl.
  endif.
  if badiimpl is NOT INITIAL.
    perform search_badiimpl.
  endif.
*-- DDIC Objects
  IF append = c_marked .
    PERFORM search_append_structure.
  ENDIF.

  IF ci_incl = c_marked .
    PERFORM search_ci_include.
  ENDIF.


END-OF-SELECTION.

  CALL SCREEN 100.
