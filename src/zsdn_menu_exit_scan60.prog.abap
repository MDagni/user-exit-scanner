*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_MENU_EXIT_SCAN .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_MENU_EXIT
*&---------------------------------------------------------------------*
FORM search_menu_exit .

  TYPES: BEGIN OF cuaty,
          name   TYPE modact-name,
          member TYPE modact-member,
          cnam   TYPE modattr-cnam,
          cdat   TYPE modattr-cdat,
          unam   TYPE modattr-unam,
          udat   TYPE modattr-udat,
          extdname TYPE modo-extdname,
          cuaname  TYPE modo-name,
          stext     TYPE mod0-stext,
        END OF cuaty.
  DATA: cuas  TYPE TABLE OF cuaty,
        lcua  TYPE cuaty.
  DATA: cuapname    TYPE modo-name,
        cuaextdname TYPE modo-extdname.
*--------------------------------------------------------------------*

  PERFORM sapgui_progress_indicator USING 'Menu Exit Scan...'.

  IF xxmodsap[] IS INITIAL.
*   Gets Enhancements of Active Projetcs
    SELECT * FROM modact AS a
             INNER JOIN modattr AS b
             ON a~name EQ b~name
             INTO wamodif
             WHERE    b~status <> space.

      IF wamodif-modact-member <> space.
        lxmodsap-name = wamodif-modact-member.
        SELECT SINGLE devclass FROM modsapa INTO lxmodsap-devclass
                               WHERE name = wamodif-modact-member.
        INSERT lxmodsap INTO TABLE xxmodsap.
        APPEND wamodif TO modif.
      ENDIF.
    ENDSELECT.
  ENDIF.
  IF NOT xxmodsap[] IS INITIAL.
    SELECT * FROM  modsap FOR ALL ENTRIES IN xxmodsap
             WHERE  name        = xxmodsap-name
             AND    typ         = 'C'.             " C means CUA
      READ TABLE modif INTO wamodif WITH KEY modact-member = modsap-name.
      CHECK sy-subrc EQ 0.
      MOVE modsap-typ  TO wamodif-modact-typ .
      MODIFY modif FROM wamodif INDEX sy-tabix.
      MOVE-CORRESPONDING modsap TO lsmods.
      INSERT lsmods INTO TABLE smods.
    ENDSELECT.
  ENDIF.

  SORT modif BY modact-name modact-typ.

*CHECK NOT smods[] IS INITIAL.

  LOOP AT modif INTO wamodif.

    READ TABLE smods WITH KEY name =  wamodif-modact-member TRANSPORTING NO FIELDS. "#EC *
    IF sy-subrc <> 0. CONTINUE. ENDIF.

    LOOP AT smods INTO lsmods FROM sy-tabix.
      IF lsmods-name <> wamodif-modact-member.
        EXIT.
      ENDIF.

      IF lsmods-typ <> 'C'. CONTINUE. ENDIF.

      CALL FUNCTION 'MOD_SAP_MEMBER_PARTS'
        EXPORTING
          member    = lsmods-member
          typ       = 'C'
        IMPORTING
          gprogname = cuapname
          cuacode   = cuaextdname.

      MOVE-CORRESPONDING wamodif-modact TO lcua.
      MOVE-CORRESPONDING wamodif-modattr TO lcua.
      lcua-extdname = cuaextdname.
      lcua-cuaname  = cuapname.
      APPEND lcua TO cuas.
    ENDLOOP.
  ENDLOOP.

  LOOP AT cuas INTO lcua.
    gs_list-object_type = c_menuex.
    gs_list-projekt     = lcua-name.
    gs_list-mod         = lcua-member.
    gs_list-imp_name    = lcua-cuaname  .
    gs_list-cust_inc    = lcua-extdname .
    gs_list-cnam        = lcua-cnam.
    gs_list-cdat        = lcua-cdat.
    gs_list-unam        = lcua-unam.
    gs_list-udat        = lcua-udat.
    APPEND gs_list TO gt_list.
  ENDLOOP.

*  if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_menuex.
    gs_list-imp_name   = 'NO MENU-EXIT FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " SEARCH_MENU_EXIT
