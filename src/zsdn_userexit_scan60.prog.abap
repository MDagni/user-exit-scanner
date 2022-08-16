*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_USEREXIT_SCAN .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_USEREXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_userexit .
  TYPE-POOLS: bamx.
  DATA  result        TYPE  bamx_source_analysis_table.
  DATA: source_lines  TYPE bamx_source_line OCCURS 0.       "#EC NEEDED
  DATA: resulth TYPE bamx_source_analysis.

  DATA  user_exits       LIKE sdrepids OCCURS 0.                    "470
  DATA  user_exith       LIKE baxxrepids.
  DATA  components       LIKE tfrc3      OCCURS 0 WITH HEADER LINE.
  DATA  lines            LIKE sdsrcline OCCURS 0 WITH HEADER LINE.  "470
  DATA  analysis         TYPE LINE OF bamx_source_analysis_table.
*  DATA  src_line         TYPE bamx_source_line.
  DATA  scanned_sources  TYPE bamx_program_table WITH HEADER LINE.
  DATA  modified_sources TYPE bamx_program_table.
  DATA  modified_sourceh TYPE LINE OF bamx_program_table.
  DATA top_component TYPE bamx_comp_node_id VALUE 'HLA0009999'. "470
  DATA ltrdir TYPE trdir.
  DATA ldevc  TYPE tadir-devclass.
*--------------------------------------------------------------------*

  PERFORM sapgui_progress_indicator USING 'Include Userexit Scan...'.

* Get user-exit names
  CALL FUNCTION 'SAPAM_XX_USEREXIT_NAMES_GET'
    EXPORTING
      ffctr_id = top_component
    TABLES
      ftfrc3   = components
      frepids  = user_exits
    EXCEPTIONS
      OTHERS   = 0.

  LOOP AT user_exits INTO user_exith.
    scanned_sources-program = user_exith-low.
    APPEND scanned_sources. CLEAR scanned_sources.
  ENDLOOP.

* Get modified objects
  CALL FUNCTION 'SAPAM_XX_MODIFICATION_TEST'
    TABLES
      candidates          = scanned_sources
      modified            = modified_sources
    EXCEPTIONS
      no_program_modified = 0
      OTHERS              = 0.

* Put everything together
  SORT: components       BY programm,
        modified_sources,
        user_exits BY  sign option low,
        lines            BY program linno.

* Arrange Modified Source...Only Userexit
  DATA save_index LIKE sy-tabix.
  DATA temp_prog LIKE modified_sourceh-program.

  LOOP AT modified_sources INTO modified_sourceh.
    save_index = sy-tabix.
    READ TABLE user_exits WITH KEY sign   = 'I'
                                   option = 'EQ'
                                   low    = modified_sourceh-program
                                   BINARY SEARCH
                                   TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
* Maybe a VOFM Routine?
      IF modified_sourceh-program+5(3) CO '1234567890'.
        CONCATENATE modified_sourceh-program(5) 'NNN'
                    INTO temp_prog.
        READ TABLE user_exits WITH KEY sign   = 'I'
                                       option = 'EQ'
                                       low    = temp_prog
                                       BINARY SEARCH
                                       TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          DELETE modified_sources INDEX save_index.
        ENDIF.
      ELSE.
        DELETE modified_sources INDEX save_index.
      ENDIF.
    ENDIF.
  ENDLOOP.


  LOOP AT scanned_sources.
    CLEAR analysis.
*   Program name
    analysis-program = scanned_sources-program.

*   Components
    READ TABLE components WITH KEY programm = scanned_sources-program
         BINARY SEARCH.
    IF sy-subrc = 0.
      analysis-comp_orig = components-comp_orig.
      LOOP AT components FROM  sy-tabix.
        IF components-programm NE scanned_sources-program.
          EXIT.
        ENDIF.
        APPEND components-comp_use TO analysis-comp_use.
      ENDLOOP.
      DESCRIBE TABLE analysis-comp_use LINES sy-tfill.
      IF sy-tfill = 0.
        APPEND top_component TO analysis-comp_use.
      ENDIF.
    ELSE.
      analysis-comp_orig = top_component.
      APPEND top_component TO analysis-comp_use.
    ENDIF.

*   Modification flag
    READ TABLE modified_sources WITH KEY program =
                                                scanned_sources-program
         BINARY SEARCH
         TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      analysis-modified = 'X'.
    ENDIF.
*   Append result to the return table
    APPEND analysis TO result.
  ENDLOOP.

  DELETE result WHERE modified = space.
  DELETE result WHERE program CP '+++++NNN'.
  DELETE result WHERE program CP '++++TENN'.           "470

  DATA ltsmodilog LIKE smodilog OCCURS 0 WITH HEADER LINE.

  LOOP AT result INTO resulth.
    REFRESH: source_lines, ltsmodilog.
    source_lines = resulth-src_lines.

    CLEAR ltrdir.
    SELECT SINGLE * FROM  trdir INTO ltrdir
           WHERE  name        = resulth-program.
    CHECK sy-subrc = 0.

    SELECT * FROM  smodilog INTO TABLE ltsmodilog
           WHERE  obj_type   = 'PROG'
           AND    obj_name   = resulth-program
           AND    int_type   = 'PU'
           AND    operation  = 'MOD'.
    CLEAR ldevc.
    SELECT SINGLE devclass FROM tadir INTO ldevc
                  WHERE pgmid  = 'R3TR'
                  AND   object = 'PROG'
                  AND   obj_name =  resulth-program.

    MOVE-CORRESPONDING ltrdir TO gs_list.

    gs_list-used_in   = resulth-program.
    gs_list-pack_name = ldevc.
    gs_list-object_type = c_userexit.

    PERFORM join_textp USING resulth-program CHANGING gs_list-text.

    IF NOT ltsmodilog[] IS INITIAL.
      LOOP AT ltsmodilog.
        gs_list-unam  = ltsmodilog-mod_user.
        gs_list-udat  = ltsmodilog-mod_date.
        gs_list-name =  ltsmodilog-int_name.
        APPEND gs_list TO gt_list.
      ENDLOOP.
      CLEAR gs_list.
    ELSE.
      APPEND gs_list TO gt_list. CLEAR gs_list.
    ENDIF.
  ENDLOOP.


* if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_userexit.
    gs_list-name = 'NO USEREXIT FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " SEARCH_USEREXIT
