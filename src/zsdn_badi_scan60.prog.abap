*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_BADI_SCAN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  search_badi
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&    ABAP code imported from report SNIF and modified
*&---------------------------------------------------------------------*
FORM search_badi.

  TYPES: BEGIN OF t_badi_list,
            exit_name TYPE exit_def  ,
            devclass  TYPE devi_class ,
            dlvunit   TYPE dlvunit,
            imp_name  TYPE exit_imp ,
            packname  TYPE devclass ,
            dlvunit2  TYPE dlvunit,
            text      TYPE sxc_attrt-text,
            aname	    TYPE unam,
            adate	   	TYPE datum,
            uname     TYPE unam,
            udate     TYPE datum    ,
  END OF t_badi_list.

  DATA: lt_badi_list TYPE TABLE OF t_badi_list,
        ls_badi_list TYPE t_badi_list.

*--------------------------------------------------------------------*
  PERFORM sapgui_progress_indicator USING 'BAdI Implementations Scan...'.

* Select the Active BAdI Implementations from the tables sxc_exit and sxc_attr
  SELECT sx~exit_name t~devclass tc~dlvunit sx~imp_name sa~aname sa~adate sa~uname sa~udate
  INTO CORRESPONDING FIELDS OF TABLE lt_badi_list
  FROM  ( ( ( tadir AS t
               INNER JOIN tdevc AS tc ON t~devclass = tc~devclass )
               INNER JOIN sxc_attr AS sa ON sa~imp_name = t~obj_name )
               INNER JOIN sxc_exit AS sx ON sx~imp_name = t~obj_name )
         WHERE  t~pgmid  = 'R3TR'
         AND    t~object = 'SXCI'       "means BAdI Implementation
         AND   ( t~obj_name LIKE 'Z%' OR t~obj_name LIKE 'Y%' )
         AND   sa~active = 'X'    .     "search only for active


  SORT lt_badi_list.
  DELETE ADJACENT DUPLICATES FROM lt_badi_list.

* Get Implementation Text
  DATA: badi_imp_text TYPE TABLE OF sxc_attrt,
        wa_sxc_attrt TYPE sxc_attrt,
        badi_list_tabix TYPE sy-tabix.

  LOOP AT lt_badi_list INTO ls_badi_list.
    badi_list_tabix = sy-tabix.
    CLEAR wa_sxc_attrt.
    SELECT * FROM  sxc_attrt INTO TABLE badi_imp_text
           WHERE  imp_name  = ls_badi_list-imp_name.
    IF sy-subrc <> 0. CONTINUE. ENDIF.
    READ TABLE badi_imp_text INTO wa_sxc_attrt WITH KEY sprsl = sy-langu.
    IF sy-subrc <> 0.
      READ TABLE badi_imp_text INTO wa_sxc_attrt WITH KEY sprsl = 'E'.
      IF sy-subrc <> 0.
        READ TABLE badi_imp_text INTO wa_sxc_attrt INDEX 1.
      ENDIF.
    ENDIF.
    ls_badi_list-text = wa_sxc_attrt-text.
    MODIFY lt_badi_list FROM ls_badi_list INDEX badi_list_tabix TRANSPORTING text.
  ENDLOOP.

* create the list that should be outputted
  LOOP AT lt_badi_list INTO ls_badi_list .
    gs_list-object_type = c_badi.
    gs_list-name       = ls_badi_list-exit_name.
    gs_list-used_in    = ls_badi_list-devclass.
    gs_list-imp_name   = ls_badi_list-imp_name.
    gs_list-pack_name  = ls_badi_list-devclass.
    gs_list-text       = ls_badi_list-text.
    gs_list-cnam       = ls_badi_list-aname.
    gs_list-cdat       = ls_badi_list-adate.
    gs_list-unam       = ls_badi_list-uname.
    gs_list-udat       = ls_badi_list-udate.
    APPEND gs_list TO gt_list.
  ENDLOOP.

* if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_badi.
    gs_list-name = 'NO BADI FOUND' .
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

* start the list output form
  PERFORM output USING gt_list.
  REFRESH gt_list.
ENDFORM.                    " search_badi
