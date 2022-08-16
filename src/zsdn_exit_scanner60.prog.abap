*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
* http://scn.sap.com/community/abap/blog/2009/05/22/how-many-exit-routines-are-active-in-your-sap-erp-system
*
* This report borns from the ashes of the report SNIF.
* It uses the SNIF "architecture", with the difference that extends
* the search to the following types of exit:
*
*    Includes Userexits (NEW)
*    Vofm Routines (NEW)
*    Exits for validations (NEW)
*    Exits for substitutions (NEW)
*    Screen Exit (NEW)
*    Menu Exit (NEW)
*    Changed Keywords (NEW)
*    Enhancement Implementations: Source Code PlugIn (NEW)
*    Enhancement Implementations: FUGR Enhancement   (NEW)
*    Enhancement Implementations: CLAS Enhancement   (NEW)
*    Enhancement Implementations: BAdI Enhancement   (NEW)
*&---------------------------------------------------------------------*
* Main features:
*&---------------------------------------------------------------------*
*    The program detects only the active implementations of existing
*     routines developed in the customer name range with the exception
*     of include userexits and Vofm routines
*    The section of the usage of BAPIs by custom programs has been
*     removed
*    The report was designed for the release Enterprise 4.7 but should
*     works without problems even in ECC
*    Navigation Enabled
*    Download of result in Excel
*    This version handles the new concept of enhancement introduced by
*     ECC
*&---------------------------------------------------------------------*

INCLUDE ZSDN_EXIT_SCANNER_TOP60.

INCLUDE ZSDN_EXIT_SCANNER_MAIN60.

INCLUDE ZSDN_APPEND_SCAN60.

INCLUDE ZSDN_BADI_SCAN60.

INCLUDE ZSDN_BTE_SCAN60.

INCLUDE ZSDN_CI_INCLUDE_SCAN60.

INCLUDE ZSDN_CUST_EXIT_SCAN60.

INCLUDE ZSDN_FIELD_EXIT_SCAN60.

INCLUDE ZSDN_EXIT_SCANNER_DYNPRO60.

INCLUDE ZSDN_USEREXIT_SCAN60.

INCLUDE ZSDN_VOFM_SCAN60.

INCLUDE ZSDN_SUBST_EXIT_SCAN60.

INCLUDE ZSDN_VALID_EXIT_SCAN60.

INCLUDE ZSDN_SCREEN_EXIT_SCAN60.

INCLUDE ZSDN_MENU_EXIT_SCAN60.

INCLUDE ZSDN_KEYWORDS_SCAN60.

INCLUDE ZSDN_HOOK_IMPL_SCAN60.

INCLUDE ZSDN_FUGRENH_SCAN60.

INCLUDE ZSDN_CLASENH_SCAN60.

INCLUDE ZSDN_BADI_IMPL_SCAN60.

INCLUDE ZSDN_EXIT_SCANNER_FORMS60.

INCLUDE ZSDN_EXIT_SCANNER_JUMP2CODE60.

INCLUDE ZSDN_EXIT_SCANNER_OUTPUTALV60.

INCLUDE ZSDN_EXIT_SCANNER_OUTPUT60.
