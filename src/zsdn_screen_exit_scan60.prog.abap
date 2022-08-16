*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_SCREEN_EXIT_SCAN .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_SCREEN_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM search_screen_exit .

  TYPES: BEGIN OF subscrty,
          name   TYPE modact-name,
          member TYPE modact-member,
          cnam   TYPE modattr-cnam,
          cdat   TYPE modattr-cdat,
          unam   TYPE modattr-unam,
          udat   TYPE modattr-udat,
          gdynprog  TYPE mod0-gdynprog,
          gdynnr(4) TYPE n,
          bername   TYPE mod0-bername,
          cdynprog  TYPE mod0-cdynprog,
          cdynnr(4) TYPE n,
          stext     TYPE mod0-stext,
        END OF subscrty.
  TYPES: BEGIN OF s_screen,
           g_name  TYPE mod0-gdynprog,
           g_dynnr TYPE mod0-gdynnr,
           bername TYPE mod0-bername,
           c_name  TYPE mod0-cdynprog,
           c_dynnr TYPE mod0-cdynnr,
           text    TYPE mod0-stext,
           impl(1) TYPE c,
           active(1) TYPE c,
         END OF s_screen.
  DATA: subscreens  TYPE TABLE OF subscrty,
        lsubscreen  TYPE subscrty,
        screen      TYPE s_screen.
*--------------------------------------------------------------------*

  PERFORM sapgui_progress_indicator USING 'Screen Exit Scan...'.

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
             AND    typ         = 'S'.             " S means Screen
      READ TABLE modif INTO wamodif WITH KEY modact-member = modsap-name.
      CHECK sy-subrc EQ 0.
      MOVE modsap-typ  TO wamodif-modact-typ .
      MODIFY modif FROM wamodif INDEX sy-tabix.
      MOVE-CORRESPONDING modsap TO lsmods.
      INSERT lsmods INTO TABLE smods.
    ENDSELECT.
  ENDIF.

  SORT modif BY modact-name modact-typ.

*  CHECK NOT smods[] IS INITIAL.

  LOOP AT modif INTO wamodif.

    READ TABLE smods WITH KEY name =  wamodif-modact-member TRANSPORTING NO FIELDS. "#EC *
    IF sy-subrc <> 0. CONTINUE. ENDIF.

    LOOP AT smods INTO lsmods FROM sy-tabix.
      IF lsmods-name <> wamodif-modact-member.
        EXIT.
      ENDIF.
      IF lsmods-typ <> 'S'. CONTINUE. ENDIF.

      CALL FUNCTION 'MOD_SAP_MEMBER_PARTS'
        EXPORTING
          member    = lsmods-member
          typ       = 'S'
        IMPORTING
          gprogname = lsubscreen-gdynprog
          gdynnr    = lsubscreen-gdynnr
          bername   = lsubscreen-bername
          cprogname = lsubscreen-cdynprog
          cdynnr    = lsubscreen-cdynnr.

*   Append existing screen only
      screen-c_name  = lsubscreen-cdynprog.
      screen-c_dynnr = lsubscreen-cdynnr.
      CALL FUNCTION 'RPY_EXISTENCE_CHECK_DYNP'
        EXPORTING
          program = screen-c_name
          name    = screen-c_dynnr
        EXCEPTIONS
          OTHERS  = 2.

      CHECK sy-subrc = 0.

      MOVE-CORRESPONDING wamodif-modact TO lsubscreen.
      MOVE-CORRESPONDING wamodif-modattr TO lsubscreen.
      APPEND lsubscreen TO subscreens.
    ENDLOOP.
  ENDLOOP.

  LOOP AT subscreens INTO lsubscreen.

    gs_list-object_type = c_screxit.
    gs_list-projekt     = lsubscreen-name.
    gs_list-mod         = lsubscreen-member.
    gs_list-used_in     = lsubscreen-gdynprog.
    gs_list-name        = lsubscreen-gdynnr  .
    gs_list-pack_name   = lsubscreen-bername  .
    gs_list-imp_name    = lsubscreen-cdynprog  .
    gs_list-cust_inc    = lsubscreen-cdynnr .
    gs_list-cnam        = lsubscreen-cnam.
    gs_list-cdat        = lsubscreen-cdat.
    gs_list-unam        = lsubscreen-unam.
    gs_list-udat        = lsubscreen-udat.

    APPEND gs_list TO gt_list.

  ENDLOOP.

*  if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_screxit.
    gs_list-name = 'NO SCREEN-EXIT FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " SEARCH_SCREEN_EXIT
