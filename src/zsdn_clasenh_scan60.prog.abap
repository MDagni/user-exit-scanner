*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.1  - 2010/07/20
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_CLASENH_SCAN60 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_CLASIMPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_clasimpl .

  IF tenhheader[] IS INITIAL.
    SELECT * FROM enhheader INTO TABLE tenhheader
       WHERE ( enhname       LIKE 'Z%' OR
               enhname       LIKE 'Y%'     )
       AND   version       = 'A' ORDER BY enhname version.
  ENDIF.

  LOOP AT tenhheader INTO lenhheader WHERE enhtooltype = 'CLASENH'.
    IF NOT lenhheader-shorttext_id  IS INITIAL.
      CLEAR: llangu, otr_context, otr_key, otr_text.
      otr_key-concept = lenhheader-shorttext_id .

      DO 2 TIMES.
        IF sy-index = 1.
          llangu = sy-langu.
        ELSE.
          llangu = 'E'.
        ENDIF.

        CALL FUNCTION 'SOTR_READ_TEXT_WITH_KEY'
          EXPORTING
            langu            = llangu
            context          = otr_context
            sotr_key         = otr_key
          IMPORTING
            entry            = otr_text
          EXCEPTIONS
            no_entry_found   = 0
            language_missing = 0
            OTHERS           = 0.
        IF otr_text-text IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.

    PERFORM get_clasenh   USING lenhheader.

  ENDLOOP.

  LOOP AT enhtab_clas INTO lenh_clas.
    MOVE-CORRESPONDING lenh_clas TO gs_list.
    gs_list-object_type = c_clas.
    gs_list-mod         = lenh_clas-enhtooltype.
    gs_list-imp_name    = lenh_clas-enhname  .
    gs_list-name        = lenh_clas-clsname.
    gs_list-text        = lenh_clas-text.
    gs_list-cnam        = lenh_clas-loguser.
    gs_list-cdat        = lenh_clas-logdate.
    gs_list-unam        = lenh_clas-activate_user.
    gs_list-udat        = lenh_clas-activate_date.
    APPEND gs_list TO gt_list.
  ENDLOOP.

*  if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_clas.
    gs_list-imp_name   = 'NO CLASS ENHANCEMENTs FOUND'.
    gs_list-text       = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " SEARCH_CLASIMPL
*&---------------------------------------------------------------------*
*&      Form  GET_CLASENH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_clasenh  USING    lenhheader TYPE enhheader.


  DATA: "lclass_enhancement TYPE REF TO cl_enh_tool_class,
        "lenhancement TYPE REF TO if_enh_tool,
        "lenh_err TYPE REF TO cx_enh_root,
        lcifkey TYPE seoclskey,
        max TYPE enhlogid,
        lenhlog TYPE enhlog.

  DATA: clif_enhparam          TYPE TABLE OF enhmethparam ,
        clif_enhclassattrib    TYPE TABLE OF enhclassattrib .
  DATA clif_enhnewmethods TYPE enhmeth_tabheader .
  DATA clif_enhevents TYPE enhclasstabevent .
  DATA clif_enhimplementings TYPE enhclasstabimplementing .
  DATA pre_methods TYPE enhmeth_tabkeys .
  DATA post_methods TYPE enhmeth_tabkeys .
  DATA owr_methods TYPE enhmeth_tabkeys .
*--*

  SELECT MAX( logid ) FROM enhlog INTO max WHERE enhname = lenhheader-enhname.
  SELECT  * FROM enhlog INTO lenhlog UP TO 1 ROWS  WHERE enhname = lenhheader-enhname
                                                   AND   version = 'A'
                                                   AND   logid = max.
  ENDSELECT.

  SELECT obj_name FROM  enhcross INTO lcifkey-clsname
         UP TO 1 ROWS
         WHERE  otype     = 'EI'
         AND    version   = 'A'
         AND    enhname   = lenhheader-enhname
         AND    obj_type  = 'CLAS'.
  ENDSELECT.

  if sy-subrc <> 0.                                               "Fix 20100720+
    SELECT obj_name FROM  enhobj INTO lcifkey-clsname             "Fix 20100720+
         UP TO 1 ROWS                                             "Fix 20100720+
         WHERE  enhname   = lenhheader-enhname                    "Fix 20100720+
         and    version   = 'A'                                   "Fix 20100720+
         AND    obj_type  = 'CLAS'.                               "Fix 20100720+
    ENDSELECT.                                                    "Fix 20100720+
  endif.

  IF NOT lcifkey IS INITIAL.
    cl_enh_tool_clif=>get_enhancement_metadata(
      EXPORTING
        cifkey            = lcifkey
        version           = 1
        enhancement_name  = lenhheader-enhname
      IMPORTING
        attributes_enh         = clif_enhclassattrib
        methods_enh            = clif_enhnewmethods
        enhancement_parameters = clif_enhparam
        events_enh             = clif_enhevents
        implementings_enh      = clif_enhimplementings
      EXCEPTIONS
        clif_not_existing = 1
        OTHERS            = 2 ).

    cl_enh_tool_class=>provide_pre_post_meths(
    EXPORTING
      cifkey            = lcifkey
      version           = 1
      enhancement_name  = lenhheader-enhname
    IMPORTING
      pre_meths         = pre_methods
      post_meths        = post_methods
      owr_meths         = owr_methods
    EXCEPTIONS
      clif_not_existing = 1
      OTHERS            = 2 ).
  ENDIF.

* Enhancement Parameters belonging to additional (custom) methods are excluded
  delete clif_enhparam where CMPNAME CP 'Z*' or CMPNAME CP 'Y*'. "Fix 20100720+

  MOVE-CORRESPONDING lenhheader TO lenh_clas.
  MOVE-CORRESPONDING lenhlog TO lenh_clas.
  lenh_clas-clsname = lcifkey-clsname.
  lenh_clas-text    = otr_text-text.

  IF NOT clif_enhclassattrib IS INITIAL.
    lenh_clas-attributes = icon_led_yellow.
  ENDIF.
  IF NOT clif_enhnewmethods IS INITIAL.
    lenh_clas-enh_meth = icon_led_yellow.
  ENDIF.
  IF NOT clif_enhparam IS INITIAL.
    lenh_clas-parameters = icon_led_yellow.
  ENDIF.
  IF NOT clif_enhevents IS INITIAL.
    lenh_clas-enh_evt = icon_led_yellow.
  ENDIF.
  IF NOT clif_enhimplementings IS INITIAL.
    lenh_clas-enh_intf = icon_led_yellow.
  ENDIF.

  IF NOT pre_methods IS INITIAL.
    lenh_clas-pre_meth = icon_led_yellow.
  ENDIF.
  IF NOT post_methods IS INITIAL.
    lenh_clas-post_meth = icon_led_yellow.
  ENDIF.
  IF NOT owr_methods IS INITIAL.
    lenh_clas-overwr_meth = icon_led_yellow.
  ENDIF.

  APPEND lenh_clas TO enhtab_clas.
  CLEAR lenh_clas.

ENDFORM.                    " GET_CLASENH
