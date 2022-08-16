*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_FIELD_EXIT_SCAN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  search_field_exit
*&---------------------------------------------------------------------*
* Abap code imported from report SNIF
*----------------------------------------------------------------------*
FORM search_field_exit.

  DATA: l_funcname TYPE tftit-funcname.
*--------------------------------------------------------------------*
  PERFORM sapgui_progress_indicator USING 'Field Exit Scan...'.


  SELECT tddir~de tddirs~prog tddirs~dynnr tadir~devclass
   INTO gs_list
   FROM ( ( tddir AS tddir INNER JOIN tddirs AS tddirs
     ON tddir~de = tddirs~de )
     INNER JOIN tadir AS tadir
     ON tadir~obj_name = tddir~de )
   WHERE     tadir~object = 'DTEL'
   AND       tadir~pgmid = c_r3tr
   AND ( tddir~activ = 'S' OR tddir~activ = 'A' )
.
*'A' = Global Exit , 'S' means Selective on Dynpros ' ' means not active
    gs_list-object_type = c_fieldex.
    CONCATENATE 'FIELD_EXIT_' gs_list-name INTO gs_list-pack_name.
    APPEND gs_list TO gt_list.
  ENDSELECT  .

* if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    clear gs_list.
    gs_list-object_type = c_fieldex.
    gs_list-name = 'NO FIELD-EXIT FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
                                                 "
  ELSE.
    SELECT funcname stext FROM tftit INTO (l_funcname, gs_list-text)
     FOR ALL ENTRIES IN gt_list
     WHERE funcname = gt_list-pack_name.
      gs_list-pack_name = l_funcname.
      MODIFY gt_list FROM gs_list
       transporting text where pack_name = gs_list-pack_name.

    ENDSELECT.

  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " search_field_exit
