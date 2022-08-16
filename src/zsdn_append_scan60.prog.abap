*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_APPEND_SEARCH
*&---------------------------------------------------------------------*
*&      Form  search_append_structure
*&---------------------------------------------------------------------*
*& Abap code imported from report SNIF.
*& Deleted the package selection from TADIR
*&---------------------------------------------------------------------*
FORM search_append_structure.

  DATA: ls_append TYPE gs_table_type.
*--------------------------------------------------------------------*
    PERFORM sapgui_progress_indicator USING 'DDIC Appends Scan...'.

* first select all Appends starting with Z oder Y from the DD02l and
* select  the devclass from the TADIR
  SELECT dd02l~sqltab dd02l~tabname tadir~devclass dd02t~ddtext
   INTO CORRESPONDING FIELDS OF ls_append
   FROM  ( ( dd02l AS dd02l INNER JOIN tadir AS tadir
   ON dd02l~tabname = tadir~obj_name )
    INNER JOIN dd02t AS dd02t
    ON dd02l~tabname = dd02t~tabname )
   WHERE  dd02l~tabclass = c_append
    AND dd02l~as4local = 'A'                        " 'A' means active
    AND ( dd02l~tabname LIKE 'Z%' OR dd02l~tabname LIKE 'Y%' )
*    AND tadir~devclass IN so_devcl
    AND dd02t~ddlanguage = sy-langu
    AND  tadir~object = c_tabl
    AND  tadir~pgmid =  c_r3tr.

    gs_list-object_type = c_append.
    gs_list-name        = ls_append-tabname.
    gs_list-used_in     = ls_append-sqltab.
*   pack_name is used for development class in that case
    gs_list-pack_name   = ls_append-devclass.
    gs_list-text = ls_append-ddtext.
    APPEND gs_list TO gt_list.
  ENDSELECT.

*second select all APPENDS from the SMODILOG that have an entry in the
*dd02l
  SELECT dd02l~tabname dd02l~sqltab tadir~devclass dd02t~ddtext
   INTO CORRESPONDING FIELDS OF  ls_append
   FROM ( ( ( dd02l AS dd02l INNER JOIN smodilog AS smodilog
    ON  dd02l~tabname = smodilog~int_name )
    INNER JOIN tadir AS tadir
    ON tadir~obj_name = dd02l~tabname )
    INNER JOIN dd02t AS dd02t
    ON dd02l~tabname = dd02t~tabname )
   WHERE smodilog~int_type = 'APPD'
    AND dd02l~as4local = 'A'
    AND ( dd02l~tabname LIKE 'Z%' OR dd02l~tabname LIKE 'Y%' )
*    AND tadir~devclass IN so_devcl
    AND dd02t~ddlanguage = sy-langu
    AND  tadir~object = c_tabl
    AND  tadir~pgmid = c_r3tr.

    gs_list-object_type = c_append.
    gs_list-name        = ls_append-tabname.
    gs_list-used_in     = ls_append-sqltab.
*   pack_name is used for development class in that case
    gs_list-pack_name   = ls_append-devclass.
    gs_list-text = ls_append-ddtext.
    APPEND gs_list TO gt_list.

  ENDSELECT.

* if nothing is found create that entry
  IF gt_list IS INITIAL.
    clear gs_list.
    gs_list-object_type = c_append.
    gs_list-name = 'NO APPEND FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " search_append_structure
