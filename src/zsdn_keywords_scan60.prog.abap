*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_KEYWORDS_SCAN
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_CHANGED_KEYWORDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM search_changed_keywords .

  DATA: lmodwrd TYPE modwrd.

  SELECT * FROM modwrd INTO lmodwrd.
    gs_list-object_type = c_modwrd.
    gs_list-langu       = lmodwrd-SPRACHE.
    gs_list-name        = lmodwrd-de.
    gs_list-projekt     = lmodwrd-rel.

    IF lmodwrd-old_ktext <> lmodwrd-new_ktext.       "Short Field Label
      gs_list-mod = 'Short'.
      gs_list-text2 = lmodwrd-old_ktext.
      gs_list-text3 = lmodwrd-new_ktext.
      APPEND gs_list TO gt_list.
    ENDIF.
    IF lmodwrd-old_mtext <> lmodwrd-new_mtext.       "Medium Field Label
      gs_list-mod = 'Medium'.
      gs_list-text2 = lmodwrd-old_mtext.
      gs_list-text3 = lmodwrd-new_mtext.
      APPEND gs_list TO gt_list.
    ENDIF.
    IF lmodwrd-old_ltext <> lmodwrd-new_ltext.       "Long Field Label
      gs_list-mod = 'Long'.
      gs_list-text2 = lmodwrd-old_ltext.
      gs_list-text3 = lmodwrd-new_ltext.
      APPEND gs_list TO gt_list.
    ENDIF.
    IF lmodwrd-old_utext <> lmodwrd-new_utext.       "Heading
      gs_list-mod = 'Heading'.
      gs_list-text2 = lmodwrd-old_utext.
      gs_list-text3 = lmodwrd-new_utext.
      APPEND gs_list TO gt_list.
    ENDIF.
    IF lmodwrd-old_htext <> lmodwrd-new_htext.       "Short Description of Repository Objects
      gs_list-mod = 'Repository'.
      gs_list-text2 = lmodwrd-old_htext.
      gs_list-text3 = lmodwrd-new_htext.
      APPEND gs_list TO gt_list.
    ENDIF.

  ENDSELECT.

*  if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_menuex.
    gs_list-name   = 'NO CHANGED KEYWORDS FOUND'.
*    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " SEARCH_CHANGED_KEYWORDS
