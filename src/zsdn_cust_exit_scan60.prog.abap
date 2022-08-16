*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_CUST_EXIT_SCAN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cust_exit_search
*&---------------------------------------------------------------------*
FORM search_cust_exit.

*     Exit Functions
  DATA: BEGIN OF iname,
          z VALUE 'Z',
          fugr TYPE tlibg-area,
          u VALUE 'U',
          inclnr(2),
        END OF iname,
        iname2 TYPE sy-repid.

  TYPES: BEGIN OF extty,
          funcname  TYPE tfdir-funcname,
          name      TYPE modact-name,
          devc      TYPE modsapa-devclass,
          member    TYPE modact-member,
          cnam      TYPE modattr-cnam,
          cdat      TYPE modattr-cdat,
          unam      TYPE modattr-unam,
          udat      TYPE modattr-udat,
          inclname  TYPE modo-name,       "Z Include Name
          stext     TYPE tftit-stext,      "Exit Function Description
        END OF extty.
  DATA: exts  TYPE TABLE OF extty,
        lext  TYPE extty.
*--------------------------------------------------------------------*

  PERFORM sapgui_progress_indicator USING 'Customer Exits Scan...'.


  IF xxmodsap[] IS INITIAL.
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

  IF xxmodsap[] IS NOT INITIAL.
    SELECT * FROM  modsap FOR ALL ENTRIES IN xxmodsap
             WHERE  name        = xxmodsap-name
             AND    typ         = 'E'.             " C means Exit Functions
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

  DATA: "cuapname    TYPE modo-name,
        "cuaextdname TYPE modo-extdname,
        ltrdir      TYPE trdir,
        ltfdir      TYPE tfdir,
        ltftit       TYPE tftit.


  LOOP AT modif INTO wamodif.

    READ TABLE smods WITH KEY name =  wamodif-modact-member TRANSPORTING NO FIELDS. "#EC *
    IF sy-subrc <> 0. CONTINUE. ENDIF.

    LOOP AT smods INTO lsmods FROM sy-tabix.
      IF lsmods-name <> wamodif-modact-member.
        EXIT.
      ENDIF.

      CLEAR ltfdir.
* Lsmods-member (Function)
      SELECT SINGLE * FROM tfdir INTO ltfdir
             WHERE funcname = lsmods-member.
      CHECK sy-subrc = 0.
*      Compound  Z-Include name
      iname-fugr   = ltfdir-pname+4.
      iname-inclnr = ltfdir-include.
      iname2 = iname.
      CONDENSE iname2 NO-GAPS.
* Check if exist custom Include
      SELECT SINGLE * FROM trdir INTO ltrdir WHERE name = iname2.
      CHECK sy-subrc = 0.

      MOVE-CORRESPONDING wamodif-modact  TO lext.
      MOVE-CORRESPONDING wamodif-modattr TO lext.

      lext-funcname     = ltfdir-funcname.
      lext-inclname      = iname2.
      READ TABLE xxmodsap INTO lxmodsap WITH KEY name = lext-member.   "#EC *
      IF sy-subrc = 0.
        lext-devc = lxmodsap-devclass.
      ENDIF.      " Z Include

      CLEAR lext-stext.
      SELECT SINGLE stext FROM tftit INTO ltftit-stext
         WHERE funcname = lext-funcname
           AND spras    = sy-langu.

      IF sy-subrc = 0.
        lext-stext = ltftit-stext.
      ELSE.
        SELECT SINGLE stext FROM tftit INTO  ltftit-stext
           WHERE funcname = lext-funcname
             AND spras    = 'E'.
        IF sy-subrc = 0.
          lext-stext = ltftit-stext.
        ELSE.
          SELECT stext FROM tftit INTO  ltftit-stext UP TO 1 ROWS
             WHERE funcname = lext-funcname.
          ENDSELECT.
        ENDIF.
      ENDIF.

      APPEND lext TO exts. CLEAR lext.
    ENDLOOP.
  ENDLOOP.

  LOOP AT exts INTO lext.
    gs_list-object_type = c_custex.
    gs_list-name        = lext-funcname.
    gs_list-used_in     = lext-devc.
    gs_list-mod         = lext-member.
    gs_list-projekt     = lext-name.
    gs_list-cust_inc    = lext-inclname.
    gs_list-text        = lext-stext.
    gs_list-cnam        = lext-cnam.
    gs_list-cdat        = lext-cdat.
    gs_list-unam        = lext-unam.
    gs_list-udat        = lext-udat.
    APPEND gs_list TO gt_list.
  ENDLOOP.

*  if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_custex.
    gs_list-name = 'NO CUSTOMER-EXIT FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " search_cust_exit
