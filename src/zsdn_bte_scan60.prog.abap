*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_BTE_SCAN
*&---------------------------------------------------------------------*
*& ABAP code imported from report SNIF and modified.
*& Only the implementations in the customer name range are selected
*&---------------------------------------------------------------------*
FORM search_bte_cross_reference TABLES lt_open_fi_strings
                                USING  l_process TYPE flag.

* type to be needed to create a table of lines
  TYPES: BEGIN OF line_type,
            line(255) TYPE c,
         END OF line_type.

  DATA:  ls_rsfind             TYPE rsfind,
         lt_rsfind             TYPE TABLE OF rsfind,
         l_stringtable         TYPE TABLE OF line_type,
         l_line                TYPE line_type,
         lt_founds             TYPE TABLE OF rsfindlst,
         l_funcname            type rs38l-name,
         l_include             type rs38l-include,
         l_rest                TYPE string.                 "#EC NEEDED

  FIELD-SYMBOLS: <fs_found> TYPE rsfindlst.

  REFRESH lt_rsfind.

  IF l_process = 'X'.                 "only find open FIs for processes
    ls_rsfind-object = 'PC_FUNCTION_FIND'.
    APPEND ls_rsfind TO lt_rsfind.
  ENDIF.
  IF l_process = 'O'. "only find open FIs for events
    ls_rsfind-object = 'BF_FUNCTION_CHOOSE'.
    APPEND ls_rsfind TO lt_rsfind.
  ENDIF.
  IF l_process = ' '.
    ls_rsfind-object = 'BF_FUNCTIONS_FIND'.
    APPEND ls_rsfind TO lt_rsfind.
  ENDIF.


*this function module returns the name of programs or includes that are
*using the objects i_findstrings
  CALL FUNCTION 'RS_EU_CROSSREF'
    EXPORTING
      i_find_obj_cls           = 'FUNC'
      no_dialog                = 'X'
    TABLES
      i_findstrings            = lt_rsfind
      o_founds                 = lt_founds
    EXCEPTIONS
      not_executed             = 1
      not_found                = 2
      illegal_object           = 3
      no_cross_for_this_object = 4
      batch                    = 5
      batchjob_error           = 6
      wrong_type               = 7
      object_not_exist         = 8
      OTHERS                   = 9.

  IF sy-subrc <> 0.
* if something should happen if an exception is raised code can be added
  ELSE.

    LOOP AT lt_founds ASSIGNING <fs_found>.
      l_include = <fs_found>-object.
      CLEAR l_funcname.

*this functions returns the name of the Function Module that is in an
*Include
      CALL FUNCTION 'FUNCTION_INCLUDE_INFO'
        CHANGING
          funcname            = l_funcname
          include             = l_include
        EXCEPTIONS
          function_not_exists = 1
          include_not_exists  = 2
          group_not_exists    = 3
          no_selections       = 4
          no_function_include = 5
          OTHERS              = 6.

*maybe in some cases the match function name to include name doesn't
*work. So read the reports and search them after function calls
*open_fi or outbound call
      IF sy-subrc <> 0.
        TRY.
          READ REPORT <fs_found>-object INTO l_stringtable.
          CATCH cx_root.
          IF sy-subrc <> 0.
* Do nothing
            check 1 = 1.
          ENDIF.
        ENDTRY.
        LOOP AT l_stringtable INTO l_line.
*     Look for function calls starting with:  call function 'O...'
          SEARCH l_line FOR 'Function ''O'.                 "#EC NOTEXT
          IF sy-subrc = 0 AND l_line(1) NE '*'. "Not search for Comments
            CONDENSE l_line.                      "Delete Spaces
            SHIFT l_line BY 15 PLACES.            "Delete Call Funtion '
*     keep the function name and move the rest to l_rest
            SPLIT l_line AT '''' INTO l_line l_rest.
            APPEND l_line TO lt_open_fi_strings.
          ENDIF.
        ENDLOOP.
* in case (should be common) that it works simply append it to the table
      ELSE.
        APPEND l_funcname TO lt_open_fi_strings.
      ENDIF.

    ENDLOOP.
  ENDIF.
  SORT lt_open_fi_strings.
  DELETE ADJACENT DUPLICATES FROM lt_open_fi_strings.

ENDFORM.                    " Search_bte_cross_reference

*&---------------------------------------------------------------------*
*&      Form  search_bte
*&---------------------------------------------------------------------*
*  to garantee no syntax errors even in non R/3 Systems the BTE Search
*  must be 100 Percent Dynamic so the DIRECT use of tables like TBE or
*  fields liek TBE-EVENT is not possible
*----------------------------------------------------------------------*
* ABAP code imported from report SNIF and modified.
* Only the implementations in the customer name range are selected
*----------------------------------------------------------------------*
FORM search_bte.

**** BEGIN of Type Definition ****
  TYPES: BEGIN OF l_bte_type,
            event type dd03l-fieldname,
            interface type dd03l-fieldname,
         END OF l_bte_type,

         BEGIN OF l_tbe3x_type,
            funct type dd03l-fieldname,
            applk type dd03l-fieldname,
         END OF l_tbe3x_type.
**** END of Type Definition ****

  DATA: lt_bte TYPE TABLE OF l_bte_type,
        l_table_tbe01   TYPE dd02l-tabname VALUE 'TBE01',
        l_table_tbe31   TYPE dd02l-tabname VALUE 'TBE31',
        l_table_tbe32   TYPE dd02l-tabname VALUE 'TBE32',
        l_table_tbe34   TYPE dd02l-tabname VALUE 'TBE34',
        l_table_tps01   TYPE dd02l-tabname VALUE 'TPS01',
        l_table_tps31   TYPE dd02l-tabname VALUE 'TPS31',
        l_table_tps32   TYPE dd02l-tabname VALUE 'TPS32',
        l_table_tps34   TYPE dd02l-tabname VALUE 'TPS34',


        lt_tbe31 TYPE TABLE OF l_tbe3x_type,
        lt_tbe32 TYPE TABLE OF l_tbe3x_type,
        lt_tbe34 TYPE TABLE OF l_tbe3x_type,

        ls_tbe31 TYPE l_tbe3x_type,
        ls_tbe32 TYPE l_tbe3x_type,
        ls_tbe34 TYPE l_tbe3x_type,

        ls_tps31 TYPE l_tbe3x_type,
        ls_tps32 TYPE l_tbe3x_type,
        ls_tps34 TYPE l_tbe3x_type,

        lt_open_fi_strings TYPE TABLE OF string,
        lt_open_fi_strings_temp TYPE TABLE OF string,
        l_line             TYPE          string,
        ls_tadir TYPE tadir.

  DATA: ls_text TYPE gt_list_type-text.                     "note 887475

  FIELD-SYMBOLS: <fs_bte>  TYPE l_bte_type.
*--------------------------------------------------------------------*

  PERFORM sapgui_progress_indicator USING 'BTEs Scan...'.


*to check if the report is running in an R3 system, check if there are
*TBE tables
  SELECT SINGLE * FROM tadir INTO ls_tadir                  "#EC NEEDED
                             WHERE  pgmid    = c_r3tr
                             AND    object   = c_tabl
                             AND    obj_name = 'TBE01'.


  IF sy-subrc = 0.
    CLEAR gs_list.

*  search all funtion modules that uses the funtion
*  BF_FUNCTIONS_FIND
    REFRESH lt_open_fi_strings.
    PERFORM search_bte_cross_reference TABLES  lt_open_fi_strings
                                         USING   ' '. "EVENT

    PERFORM search_bte_cross_reference TABLES  lt_open_fi_strings_temp
                                         USING   'O'. "Old EVENT

    APPEND LINES OF lt_open_fi_strings_temp TO lt_open_fi_strings.

    SELECT event interface INTO TABLE lt_bte
          FROM (l_table_tbe01). "dynamic Select

    LOOP AT lt_bte ASSIGNING <fs_bte>.

*   search for an customer function module (more than one for same event
*   possible in this table)
      SELECT funct applk FROM (l_table_tbe34) INTO TABLE lt_tbe34
       WHERE event = <fs_bte>-event.

*     maybe there is a partner function module (more than one for same
*     event possible in this table)

      SELECT funct applk FROM (l_table_tbe32) INTO TABLE lt_tbe32
       WHERE event = <fs_bte>-event
          .

*  not really necessary maybe there is a SAP alternative function module
*  (more than one for same event possible in this table)

      SELECT funct applk FROM (l_table_tbe31) INTO TABLE lt_tbe31
        WHERE event = <fs_bte>-event.

************check lt_tbe34******************
      LOOP AT lt_tbe34 INTO ls_tbe34.

        PERFORM search_bte_get_devcl USING ls_tbe34-funct gs_list-used_in.
        gs_list-name = <fs_bte>-event.    "name of the interface*
        IF ls_tbe34-funct(1) <> 'Z' AND ls_tbe34-funct(1) <> 'Y'. CONTINUE. ENDIF.

        gs_list-pack_name = ls_tbe34-funct. "name of implemented FUNCTION
        gs_list-object_type = c_bte_pas.

*       if the global structure gs_list is not empty look after that
*       suitable Funtion Module in the lt_open_fi_strings table
        IF NOT gs_list IS INITIAL.

          SEARCH lt_open_fi_strings FOR <fs_bte>-event.
          IF sy-subrc = 0.
            READ TABLE lt_open_fi_strings INTO l_line  INDEX sy-tabix.
            gs_list-imp_name =  l_line.          "Open FI Function Module

          ENDIF.
          IF gs_list-used_in IN so_devcl.
            APPEND gs_list TO gt_list.
          ENDIF.
          CLEAR gs_list.
        ENDIF.
      ENDLOOP.
      REFRESH lt_tbe34.
      CLEAR ls_tbe34.
************check lt_tbe32******************
      LOOP AT lt_tbe32 INTO ls_tbe32.

        PERFORM search_bte_get_devcl USING ls_tbe32-funct gs_list-used_in.
        gs_list-name = <fs_bte>-event.    "name of the interface
        IF ls_tbe32-funct(1) <> 'Z' AND ls_tbe32-funct(1) <> 'Y'. CONTINUE. ENDIF.

        gs_list-pack_name = ls_tbe32-funct. "name of implemented function
        gs_list-object_type = c_bte_pas.

        IF NOT gs_list IS INITIAL.

          SEARCH lt_open_fi_strings FOR <fs_bte>-event.
          IF sy-subrc = 0.
            READ TABLE lt_open_fi_strings INTO l_line  INDEX sy-tabix.
            gs_list-imp_name =  l_line.          "Open FI Function Module

          ENDIF.
          IF gs_list-used_in IN so_devcl.
            APPEND gs_list TO gt_list.
          ENDIF.
          CLEAR gs_list.
        ENDIF.
      ENDLOOP.
      REFRESH lt_tbe32.
      CLEAR ls_tbe32.
************check lt_tbe31******************
      LOOP AT lt_tbe31 INTO ls_tbe31.
        PERFORM search_bte_get_devcl USING ls_tbe31-funct gs_list-used_in.
        gs_list-name = <fs_bte>-event.     "name of the interface
        IF ls_tbe31-funct(1) <> 'Z' AND ls_tbe31-funct(1) <> 'Y'. CONTINUE. ENDIF.

        gs_list-pack_name = ls_tbe31-funct.  "name of implemented function
        gs_list-object_type = c_bte_pas.
        IF NOT gs_list IS INITIAL.

          SEARCH lt_open_fi_strings FOR <fs_bte>-event.
          IF sy-subrc = 0.
            READ TABLE lt_open_fi_strings INTO l_line  INDEX sy-tabix.
            gs_list-imp_name =  l_line.          "Open FI Function Module

          ENDIF.
          IF gs_list-used_in IN so_devcl.
            APPEND gs_list TO gt_list.
          ENDIF.
          CLEAR gs_list.
        ENDIF.
      ENDLOOP.
      REFRESH lt_tbe31.
      CLEAR ls_tbe31.
    ENDLOOP.


    REFRESH lt_bte.
    REFRESH lt_open_fi_strings.

*    search all funtion modules that uses the funtion
*    PC_FUNCTION_FIND
    PERFORM search_bte_cross_reference TABLES  lt_open_fi_strings
                                       USING   'X'. "process
    SELECT procs interface INTO TABLE lt_bte
       FROM (l_table_tps01).

    LOOP AT lt_bte ASSIGNING <fs_bte>.
*   first look in the Customer Table (TPS34) ,only one entriy per event
*   allowed
      SELECT SINGLE funct applk FROM (l_table_tps34) INTO ls_tps34 WHERE
                                                                 procs =
                                                          <fs_bte>-event.
      IF sy-subrc EQ 0.

        PERFORM search_bte_get_devcl USING ls_tps34-funct gs_list-used_in.

        gs_list-name = <fs_bte>-event.    "name of the interface
        IF ls_tps34-funct(1) <> 'Z' AND ls_tps34-funct(1) <> 'Y'. CONTINUE. ENDIF.

        gs_list-pack_name = ls_tps34-funct. "name of implemented FUNCTION
        gs_list-object_type = c_bte_pro.

      ELSE.
*    if nothing is found maybe a partner implementations is avaiable
*    only one entriy per event allowed

        SELECT SINGLE funct applk  FROM (l_table_tps32) INTO ls_tps32
            WHERE procs = <fs_bte>-event
                    .
        IF sy-subrc EQ 0.

          PERFORM search_bte_get_devcl USING ls_tps32-funct gs_list-used_in.
          gs_list-name = <fs_bte>-event.    "name of the interface
          IF ls_tps32-funct(1) <> 'Z' AND ls_tps32-funct(1) <> 'Y'. CONTINUE. ENDIF.
          gs_list-pack_name = ls_tps32-funct. "name of implemented function
          gs_list-object_type = c_bte_pro.

        ELSE.
*      maybe a SAP alternative is avaiable
*      only one entriy per event allowed
          SELECT SINGLE funct applk  FROM (l_table_tps31) INTO ls_tps31
                WHERE procs =  <fs_bte>-event
          .
          IF sy-subrc EQ 0.

            PERFORM search_bte_get_devcl USING ls_tps31-funct gs_list-used_in.
            gs_list-name = <fs_bte>-event.     "name of the interface
            IF ls_tps31-funct(1) <> 'Z' AND ls_tps31-funct(1) <> 'Y'. CONTINUE. ENDIF.
            gs_list-pack_name = ls_tps31-funct.  "name of implemented function

            gs_list-object_type = c_bte_pro.
          ENDIF.
        ENDIF.
      ENDIF.

*     if one active Event is found look after the corresponding open fi
      IF NOT gs_list IS INITIAL.
        SEARCH lt_open_fi_strings FOR <fs_bte>-event.
        IF sy-subrc = 0.
          READ TABLE lt_open_fi_strings INTO l_line  INDEX sy-tabix.
          gs_list-imp_name =  l_line.          "Open FI Function Module

          IF gs_list-used_in IN so_devcl.
            APPEND gs_list TO gt_list.
          ENDIF.


        ENDIF.
        CLEAR gs_list.

      ENDIF.
    ENDLOOP.
  ELSE.
* Do nothing
    check 1 = 1.
  ENDIF.

  DELETE gt_list WHERE pack_name IS INITIAL.

* if nothing is found create that entry
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_bte_pro.
    gs_list-pack_name = 'NO BTE FOUND'.
    gs_list-imp_name    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ELSE.
    SELECT stext FROM tftit INTO ls_text
       FOR ALL ENTRIES IN gt_list
       WHERE funcname = gt_list-used_in.
      gs_list-text = ls_text.
    ENDSELECT.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.
ENDFORM.                    " search_bte
*&---------------------------------------------------------------------*
*&      Form  search_bte_get_devcl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TPS34_FUNCT  text
*----------------------------------------------------------------------*
FORM search_bte_get_devcl USING ls_funct type any used_in type any.

  DATA: l_progname(30)        TYPE c.

*geht the program name where the Function module belongs to
  SELECT SINGLE pname FROM tfdir INTO l_progname
    WHERE funcname = ls_funct.

* delete the SAPL from the name Progname ---> Funtiongoupname
  SHIFT l_progname BY 4 PLACES.

*get the package name of the Funtion Group where the funtion module
*belongs to
  SELECT SINGLE devclass FROM tadir INTO used_in
   WHERE object = 'FUGR'
     AND  pgmid  = c_r3tr
     AND  obj_name = l_progname.
  IF sy-subrc NE 0.
    used_in = space.
  ENDIF.

ENDFORM.                    " search_bte_get_devcl
