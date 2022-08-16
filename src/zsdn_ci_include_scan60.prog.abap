*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_CI_INCLUDE_SCAN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  search_ci_include
*&---------------------------------------------------------------------*
* Abap code imported from report SNIF;
*----------------------------------------------------------------------*
FORM search_ci_include.
  DATA: ls_ci_incl TYPE gs_table_type.
*--------------------------------------------------------------------*
  PERFORM sapgui_progress_indicator USING
        'DDIC Custom Includes (CI_*) Scan...'.


*  selects all active CI_INCLUDES and the Tables they are used in
*  AND the Development Classes
  SELECT dd02l~tabname dd03l~tabname tadir~devclass dd02t~ddtext
   INTO ls_ci_incl
   FROM  ( ( (  dd02l AS dd02l INNER JOIN dd03l AS dd03l
    ON dd02l~tabname = dd03l~precfield )
    INNER JOIN tadir AS tadir
    ON dd02l~tabname = tadir~obj_name )
    INNER JOIN dd02t AS dd02t
    ON dd02l~tabname = dd02t~tabname )
  WHERE dd02l~tabclass = 'INTTAB '
    AND  dd02l~as4local = 'A'
    AND  dd02l~tabname LIKE 'CI#_%' ESCAPE '#'
    AND  dd03l~as4local = 'A'
    AND  tadir~object = c_tabl
    AND  tadir~pgmid = c_r3tr
    AND dd02t~ddlanguage = sy-langu
    AND tadir~devclass LIKE 'Z%' OR tadir~devclass LIKE 'Y%'.

    gs_list-object_type = c_ci_incl.
    gs_list-name        = ls_ci_incl-tabname.
    gs_list-used_in     = ls_ci_incl-sqltab.
    gs_list-pack_name   = ls_ci_incl-devclass.
    gs_list-text        = ls_ci_incl-ddtext.
    APPEND gs_list TO gt_list.

  ENDSELECT.

*  if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_ci_incl.
    gs_list-name = 'NO CI_INCLUDE FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " search_ci_include
