*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP 4.7; SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_SUBST_EXIT_SCAN.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_SUBSTITUTIONS_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form search_substitutions_exit .

  data: tgb92  type table of gb92,
        lgb92   type gb92,
        tgb92t  type table of gb92t,
        lgb92t  type gb92t,
        tgb921t type table of gb921t,
        lgb921t type gb921t,
        tgb922  type table of gb922,
        lgb922  type gb922,
        lgb922i type gb922i,
        ltxt    type char64.

  types: begin of xgb92_ty,
          substid type gb92-substid,
         end of xgb92_ty.
  data: save_tabix type sy-tabix.
*--------------------------------------------------------------------*


  perform sapgui_progress_indicator using 'Substitutions Exits Scan...'.

*  fill_range xsubst 'I' 'CP' 'Z*' ' '.         "20101104-
*  fill_range xsubst 'I' 'CP' 'Y*' ' '.         "20101104-

  select * from gb92   into table tgb92
          where substid     in xsubst
          and   gbopchange  <> 'SAP'            "20101104+
          order by primary key.

  select * from gb922   into table tgb922
          where substid     in xsubst
          and   exitsubst  like 'U%'
          order by primary key.

  select * from gb921t   into table tgb921t
          where subsid     in xsubst
          order by primary key.

  select * from gb92t  into table tgb92t
          where subsid     in xsubst
          order by primary key.

  loop at tgb92 into lgb92.
    clear lgb92t.
    read table tgb92t into lgb92t with key mandt  = sy-mandt
                                           subsid = lgb92-substid
                                           langu  = sy-langu binary search.
    if sy-subrc <> 0.
      read table tgb92t into lgb92t with key mandt  = sy-mandt
                                             subsid = lgb92-substid
                                             langu  = 'E'.
      if sy-subrc <> 0.
        read table tgb92t into lgb92t with key mandt  = sy-mandt
                                               subsid = lgb92-substid.
      endif.
    endif.

    read table tgb922 with key mandt   = sy-mandt
                               substid = lgb92-substid
                               transporting no fields binary search.
    if sy-subrc <> 0. continue. endif.
    save_tabix = sy-tabix.
    loop at tgb922 into lgb922 from save_tabix.
      if lgb922-substid <> lgb92-substid. exit. endif.
      clear lgb921t.
      read table tgb921t into lgb921t with key  mandt     = sy-mandt
                                                langu     = sy-langu
                                                subsid    = lgb922-substid
                                                subseqnr  = lgb922-subseqnr.
      if sy-subrc <> 0.
        read table tgb921t into lgb921t with key  mandt     = sy-mandt
                                                  langu     = 'E'
                                                  subsid    = lgb922-substid
                                                  subseqnr  = lgb922-subseqnr.
        if sy-subrc <> 0.
          read table tgb921t into lgb921t with key  mandt     = sy-mandt
                                                    subsid    = lgb922-substid
                                                    subseqnr  = lgb922-subseqnr.

        endif.
      endif.

      data lformpool type sy-repid.

*     Get Formpool name
      lgb922i-subster = lgb922-exitsubst.

      perform get_formpool using  lgb922i-subster 'B'
                           changing lformpool .
*     Get Exit Title
      perform get_exit_title using    lgb922i-subster 'B'
                             changing ltxt .
      gs_list-object_type      = c_subst.
      gs_list-mod      = lgb922-substid.
      gs_list-name     = lgb92t-substext.
      gs_list-cust_inc = lgb922-subseqnr.
      gs_list-projekt  = lgb921t-substext.
      gs_list-text2    = lgb921t-substext.
      gs_list-imp_name = lgb922-exitsubst.
      gs_list-text3    = ltxt.
      gs_list-used_in  = lformpool.
      gs_list-cnam     = lgb92-gbopcreate.
      gs_list-cdat     = lgb92-gbdtcreate.
      gs_list-unam     = lgb92-gbopchange.
      gs_list-udat     = lgb92-gbdtchange.
      append gs_list to gt_list. clear gs_list.
    endloop.
  endloop.

* if nothing is found to create a minimum fieldcatalog
  if gt_list is initial.
    clear gs_list.
    gs_list-object_type = c_subst.
    gs_list-name = 'NO SUBSTITUTIONS FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    append gs_list to gt_list.
  endif.

  perform output using gt_list.
  refresh gt_list.

endform.                    " SEARCH_SUBSTITUTIONS_EXIT
