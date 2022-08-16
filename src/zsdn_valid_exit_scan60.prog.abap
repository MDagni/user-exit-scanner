*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP 4.7; SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_VALID_EXIT_SCAN .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_VALIDATIONS_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form search_validations_exit .

  data:  tgb93  type table of gb93,
         lgb93   type gb93,
         tgb93t  type table of gb93t,
         lgb93t  type gb93t,
         tgb931  type table of gb931,
         lgb931  type gb931,
         lgb922i type gb922i,
         ltxt    type char64.

  data: save_tabix type sy-tabix.

*--*
  data: tgb90t type table of gb90t.
  data: lgb90t type gb90t.

  data: exit_list  type table of gb922,
        lexit_list type gb922.

*--------------------------------------------------------------------*

  perform sapgui_progress_indicator using 'Validations Exits Scan...'.

*  fill_range xvalid 'I' 'CP' 'Z*' ' '.          "20101104-
*  fill_range xvalid 'I' 'CP' 'Y*' ' '.          "20101104-

  select * from gb93   into table tgb93
          where valid     in xvalid
          and   gbopchange  <> 'SAP'             "20101104+
          order by primary key.

  loop at tgb93 into lgb93.                      "20150617+
    fill_range xvalid 'I' 'EQ' lgb93-valid ' '.  "20150617+
  endloop.                                       "20150617+

  if not xvalid[] is INITIAL.                    "20150617+
    select * from gb931   into table tgb931
            where valid     in xvalid
*            and   checkid   like '%Z%'          "20150617-
*            or    checkid   like '%Y%'          "20150617-
            order by primary key.

    select * from gb93t  into table tgb93t
            where valid     in xvalid
            order by primary key.
  endif.                                         "20150617+

  loop at tgb93 into lgb93.
    clear lgb93t.
    read table tgb93t into lgb93t with key mandt = sy-mandt
                                           langu = sy-langu
                                           valid = lgb93-valid.
    if sy-subrc <> 0.
      read table tgb93t into lgb93t with key mandt = sy-mandt
                                             langu = 'E'
                                             valid = lgb93-valid.

      if sy-subrc <> 0.
        read table tgb93t into lgb93t with key mandt = sy-mandt
                                               valid = lgb93-valid.
      endif.
    endif.

    read table tgb931 with key mandt   = sy-mandt
                               valid = lgb93-valid
                               transporting no fields binary search.
    if sy-subrc <> 0. continue. endif.
    save_tabix = sy-tabix.
    loop at tgb931 into lgb931 from save_tabix.
      if lgb931-valid <> lgb93-valid. exit. endif.

      clear exit_list.
      call function 'G_RULE_ELEMENTS_GET'
        exporting
          rule         = lgb931-checkid
        tables
          all_exits    = exit_list
        exceptions
          check_failed = 0
          not_found    = 0
          others       = 0.

      delete  exit_list where exitsubst(1) <> 'U'.
      if exit_list[] is initial. continue. endif.

      clear lgb90t.
      select * from gb90t into table tgb90t
             where boolid = lgb931-condid.
      read table tgb90t into lgb90t with key langu = sy-langu.
      if sy-subrc <> 0.
        read table tgb90t into lgb90t with key langu = 'E'.
      endif.
      if sy-subrc <> 0.
        read table tgb90t into lgb90t index 1.
      endif.


      loop at exit_list into lexit_list.

        data lformpool type sy-repid.

*       Get Formpool name
        lgb922i-subster = lexit_list-exitsubst.

        perform get_formpool using  lgb922i-subster 'F'
                             changing lformpool .
*       Get Exit Title
        perform get_exit_title using    lgb922i-subster 'F'
                               changing ltxt .

        gs_list-object_type       = c_valid.
        gs_list-mod               = lgb93-valid.
        gs_list-name              = lgb93t-valtext.
        gs_list-cust_inc          = lgb931-valseqnr.
        gs_list-projekt           = lgb90t-booltext.
        gs_list-text2             = lgb90t-booltext.
        gs_list-imp_name          = lexit_list-exitsubst.
        gs_list-text3             = ltxt.
        gs_list-used_in           = lformpool.
        gs_list-cnam              = lgb93-gbopcreate.
        gs_list-cdat              = lgb93-gbdtcreate.
        gs_list-unam              = lgb93-gbopchange.
        gs_list-udat              = lgb93-gbdtchange.
        append gs_list to gt_list. clear gs_list.

      endloop.
    endloop.
  endloop.


* if nothing is found to create a minimum fieldcatalog
  if gt_list is initial.
    clear gs_list.
    gs_list-object_type = c_valid.
    gs_list-name = 'NO VALIDATIONS FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    append gs_list to gt_list.
  endif.

  perform output using gt_list.
  refresh gt_list.

endform.                    " SEARCH_VALIDATIONS_EXIT
