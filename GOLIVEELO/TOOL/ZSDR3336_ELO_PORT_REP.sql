*&---------------------------------------------------------------------*
*& Report  ZSDR3336_ELO_PORT_REP                                       *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Author                 : Naresh Kumar Kolisetty                     *
*& Date	                  : 05 OCT 2017                                *
*& Functional analyst     : Hauers, Ronie                              *
*& Technical Analyst      : Naresh Kumar Kolisetty                     *
*& Program Name	          : ZSDR3336_ELO_PORT_REP                      *
*& Transaction Code	      : ZSDR3336                                   *
*& Transport Request      : ET2K900130/ED2K921182                      *
*& Change Request         : CHG157751                                  *
*& Description            : The idea is to create a new report, copy of*
*&                          the ZSDR3002_GENERAL_PORTFOLOI_REP, to be  *
*&                          used by ELO only, so we can guarantee the  *
*&                          data ELO needs during the process. Due to  *
*&                          it we will keep required data already      *
*&                          available at current report and also       *
*&                          include few additional columns to extracted*
*----------------------------------------------------------------------*
*                      MODIFICATION HISTORY                            *
*----------------------------------------------------------------------*
*Date        Name        Transport   Description                       *
*----------------------------------------------------------------------*
*09/29/2017  VCHAVAN     ET2K900130 Program to transfer data to ELO    *
*10/10/2017  NKOLISHE    ED2K919638 Program changes as per Mosaic Std. *
*03/14/2018  VCHAVAN     ED2K922218 Add payer details                  *                           "CHG160438
*                        ED2K922230/ED2K922369/ED2K922417              *                           "CHG160438
*04/09/2018  VCHAVAN     ED2K922522/ED2K922530 Delete duplicate        *                           "CHG160438
*04/11/2018  NKOLISHE    ED2K922557 Removing dump cauing in the JOB for*                           "CHG160438
*                        ED2K922625 conversion of Number               *                           "CHG160438
*04/19/2018  VCHAVAN     ED2K922612 DATE and time change               *                           "CHG160842
*----------------------------------------------------------------------*
REPORT  zsdr3336_elo_port_rep
        LINE-SIZE 250 LINE-COUNT 200
       NO STANDARD PAGE HEADING.
TABLES: vbak, vbap, vbep, vbbe, vbkd, marc, vbpa,vbuk, mara, cdpos,
        kna1, makt, tvlst, t001w, knvv,lips, v023,tvm4t, adr6.

TYPES : BEGIN OF ty_kna1,
         kunnr TYPE kunnr,
         name1 TYPE name1_gp,
         stras TYPE stras_gp,
        END OF ty_kna1,

        BEGIN OF ty_ausp,
          objek TYPE objnum,
          atwrt TYPE atwrt,
        END OF ty_ausp,

        BEGIN OF ty_zvarb,
          var1          TYPE zd_var1,
          description   TYPE zd_description,
          var2          TYPE zd_var2,
          var3          TYPE zd_var3,
          var4          TYPE zd_var4,
        END OF ty_zvarb.


DATA : itab_kna1  TYPE TABLE OF ty_kna1,
       itab_ausp  TYPE TABLE OF ty_ausp,
       itab_texto TYPE TABLE OF tline,
       itab_zvarb TYPE TABLE OF ty_zvarb,
       itab_zvarc TYPE TABLE OF ty_zvarb,
       wa_zvarb   TYPE ty_zvarb,
       wa_texto   TYPE tline,
       wa_kna1    TYPE ty_kna1,
       wa_ausp    TYPE ty_ausp,
       lv_kbetr   TYPE kbetr,
       lv_roteiro TYPE string,                              "char4000,
       lv_name    TYPE tdobname,
       lv_objek   TYPE objnum.

DATA w_taxa  LIKE konv-kbetr. " Taxa do Dolar

RANGES: r_condicao FOR vbkd-zterm.

DATA: v_bezei TYPE char44.
DATA : lv_t1 , lv_t2.
DATA: BEGIN OF t_vbak OCCURS 0,
         vbeln LIKE vbak-vbeln,   " Ordem de prod
         erdat LIKE vbak-erdat,   " Data Criação"
         ernam LIKE vbak-ernam,   " Criado por
         vbtyp LIKE vbak-vbtyp,
         auart LIKE vbak-auart,
         lifsk LIKE vbak-lifsk,   " Bloqueio remessa
         faksk LIKE vbak-faksk,   " Bloqueio Pagamento
         waerk TYPE waerk,        " SD Document Currency
         vkorg LIKE vbak-vkorg,   " Organização de Vendas
         spart LIKE vbak-spart,   " Setor de atividade
         vkgrp LIKE vbak-vkgrp,   " Supervisor
         vkbur LIKE vbak-vkbur,   " Filial
         guebg LIKE vbak-guebg,
         gueen LIKE vbak-gueen,
         knumv LIKE vbak-knumv,
         vdatu LIKE vbak-vdatu,   " Inicio/Fim
         mahdt LIKE vbak-mahdt,   " Inicio/Fim
         kunnr LIKE vbak-kunnr,   " Cliente
         vgbel LIKE vbak-vgbel,
         vgtyp LIKE vbak-vgtyp,
         bzirk LIKE vbkd-bzirk,
         inco1 LIKE vbkd-inco1,   " Modalidade
         valdt LIKE vbkd-valdt,   " Data de vencimento
         zterm LIKE vbkd-zterm,   " Condições de Pagto.
         mschl LIKE vbkd-mschl,
         empst LIKE vbkd-empst,
         bstkd LIKE vbkd-bstkd,
         kdkg5 LIKE vbkd-kdkg5,
         cmgst LIKE vbuk-cmgst,   " Bloqueio credito
         pedido LIKE cdhdr-objectid,
       END OF t_vbak,
    BEGIN OF t_vbap OCCURS 0,
         vbeln    LIKE vbap-vbeln,
         posnr    LIKE vbap-posnr,
         matnr    LIKE vbap-matnr,
         arktx    LIKE vbap-arktx,
         abgru    LIKE vbap-abgru,
         zmeng    LIKE vbap-zmeng,
         faksp    LIKE vbap-faksp,
         kwmeng   LIKE vbap-kwmeng,
         werks    LIKE vbap-werks,
         mvgr1    LIKE vbap-mvgr1,
         mvgr3    LIKE vbap-mvgr3,
         mvgr4    LIKE vbap-mvgr4,
         mstav    LIKE mara-mstav,
         matkl    LIKE mara-matkl,
         zzrepcc  LIKE vbap-zzrepcc,
         zzpaidd  LIKE vbap-zzpaidd,
         objek    TYPE objnum,
      END OF t_vbap,

      BEGIN OF it_desc OCCURS 0,
        mvgr4 LIKE tvm4t-mvgr4,
        bezei TYPE tvm4t-bezei,
     END OF it_desc,

     BEGIN OF it_desc_emb OCCURS 0,
        mvgr3 LIKE tvm3t-mvgr3,
        bezei TYPE tvm3t-bezei,
     END OF it_desc_emb.

DATA: BEGIN OF t_kna1 OCCURS 0,
        kunnr LIKE kna1-kunnr,
        name1 LIKE kna1-name1,
        ort01 LIKE kna1-ort01,
        pstlz LIKE kna1-pstlz,
        regio LIKE kna1-regio,
        stras LIKE kna1-stras,
        ort02 LIKE kna1-ort02,
        stcd1 LIKE kna1-stcd1,
        stcd2 LIKE kna1-stcd2,
        stcd3 LIKE kna1-stcd3,
        stcd4 LIKE kna1-stcd4,
      END OF t_kna1.

DATA: BEGIN OF t_kna3 OCCURS 0,
        kunnr LIKE kna1-kunnr,
        name1 LIKE kna1-name1,
        ort01 LIKE kna1-ort01,
        pstlz LIKE kna1-pstlz,
        regio LIKE kna1-regio,
        stras LIKE kna1-stras,
        ort02 LIKE kna1-ort02,
        stcd1 LIKE kna1-stcd1,
        stcd2 LIKE kna1-stcd2,
        stcd3 LIKE kna1-stcd3,
        stcd4 LIKE kna1-stcd4,
        END OF t_kna3.
DATA: BEGIN OF t_kna2 OCCURS 0,
        kunnr LIKE kna1-kunnr,
        agent LIKE kna1-name1,
      END OF t_kna2.
DATA: BEGIN OF t_kna5 OCCURS 0,                                                                    "CHG160438
        kunnr LIKE kna1-kunnr,                                                                     "CHG160438
        agent LIKE kna1-name1,                                                                     "CHG160438
      END OF t_kna5.                                                                               "CHG160438
DATA: BEGIN OF t_tvm1t OCCURS 0,
        mvgr1  LIKE tvm1t-mvgr1,
        bezei  LIKE tvm1t-bezei,
      END OF t_tvm1t.

DATA: BEGIN OF t_konv OCCURS 0,
        knumv LIKE konv-knumv,
        kposn LIKE konv-kposn,
        kschl LIKE konv-kschl,
        kbetr LIKE konv-kbetr,
      END OF t_konv.

DATA: BEGIN OF t_vbkd OCCURS 0,
        vbeln LIKE vbkd-vbeln,
        posnr LIKE vbkd-posnr,
        inco1 LIKE vbkd-inco1,
        valdt LIKE vbkd-valdt,
        zterm LIKE vbkd-zterm,
        kdkg5 LIKE vbkd-kdkg5,
   END OF t_vbkd.

DATA: BEGIN OF t_vbuk OCCURS 0,
        vbeln LIKE vbuk-vbeln,
        cmgst LIKE vbuk-cmgst,
      END OF t_vbuk.

DATA: BEGIN OF t_vbpa OCCURS 0,
        vbeln LIKE vbpa-vbeln,
        kunnr LIKE vbpa-kunnr,
        parvw LIKE vbpa-parvw,
      END OF t_vbpa.

DATA: BEGIN OF t_vbpa1 OCCURS 0,
        vbeln LIKE vbpa-vbeln,
        kunnr LIKE vbpa-kunnr,
      END OF t_vbpa1.
DATA: BEGIN OF t_marc OCCURS 0,
        matnr LIKE marc-matnr,
        werks LIKE marc-werks,
      END OF t_marc.

DATA: BEGIN OF t_vbbe OCCURS 0,
        vbeln LIKE vbbe-vbeln,
        posnr LIKE vbbe-posnr,
        etenr LIKE vbbe-etenr,
        matnr LIKE vbbe-matnr,
        werks LIKE vbbe-werks,
        omeng LIKE vbbe-omeng,
      END OF t_vbbe .

DATA: BEGIN OF t_vbep OCCURS 0,
        vbeln LIKE vbep-vbeln,
        posnr LIKE vbep-posnr,
        etenr LIKE vbep-etenr,
        edatu LIKE vbep-edatu,
        wmeng LIKE vbep-wmeng,
        bmeng LIKE vbep-bmeng,
        lifsp LIKE vbep-lifsp,
      END OF t_vbep.

DATA: BEGIN OF t_saida OCCURS 0,
        werks LIKE vbap-werks,
        vbelv LIKE vbfa-vbelv,
        posnv TYPE vbfa-posnv,                                                                     "   New
        vbeln LIKE vbak-vbeln,
        posnr LIKE vbap-posnr,
        kunnr LIKE kna1-kunnr,
        inco1 LIKE vbkd-inco1,
        vkbur  LIKE vbak-vkbur,
        vkburt LIKE tvkbt-bezei,
        vkgrp  LIKE  vbak-vkgrp,
        vkgrpt LIKE  tvgrt-bezei,
        kunnr2 LIKE vbpa-kunnr,
        agent  LIKE kna1-name1,
        valdt LIKE vbkd-valdt,
        vdatu LIKE vbak-vdatu,
        mahdt LIKE vbak-mahdt,
        erdat LIKE vbak-erdat,
        waerk TYPE waerk,        " SD Document Currency
        ort01 LIKE kna1-ort01,
        regio LIKE kna1-regio,
        name1 LIKE kna1-name1,
        ort02 LIKE kna1-ort02,
        stcd1 LIKE kna1-stcd1,
        stcd2 LIKE kna1-stcd2,
        stcd3 LIKE kna1-stcd3,
        stcd4 LIKE kna1-stcd4,
        pstlz LIKE kna1-pstlz,
        stras LIKE kna1-stras,
        matnr LIKE vbap-matnr,
        arktx LIKE vbap-arktx,
        kwmeng LIKE vbap-kwmeng,
        vlrrem LIKE vbap-kwmeng,
        mvgr3  LIKE vbap-mvgr3,
        bezei3 TYPE char44,
        saldo LIKE vbbe-omeng,
        lifsk LIKE vbak-lifsk,
        faksk LIKE vbak-faksk,
        cmgst LIKE vbuk-cmgst,
        abgru LIKE vbap-abgru,
        bezei TYPE char44,
        kbetr LIKE konv-kbetr,
        udate LIKE cdhdr-udate,
        bmeng LIKE vbep-bmeng,
        ernam LIKE vbak-ernam,
        klabc LIKE knvv-klabc,
        ddtext LIKE dd07v-ddtext,
        eikto LIKE knvv-eikto,
        taxa  LIKE konv-kbetr, " Taxa do Dolar.
        valor_dolar LIKE konv-kawrt, " Valor do Item em Dolar.
        valor_real  LIKE konv-kawrt, "konv-kbetr, " Valor do Item em Real
        mstav LIKE mara-mstav, " Bloqueio de Entrada
        zra0  TYPE p LENGTH 7 DECIMALS 3, " condição ZRA0
        matkl LIKE mara-matkl,
        wgbez60  LIKE v023-wgbez60,
        olfmng LIKE vbepvb-olfmng,
        auart LIKE vbak-auart,
        guebg LIKE vbak-guebg,
        gueen LIKE vbak-gueen,
        vgbel LIKE vbak-vgbel,
        kdkg5 LIKE vbkd-kdkg5,
        empst LIKE vbkd-empst,
        omeng LIKE vbbe-omeng,
        tdtext(132) TYPE c,
        zterm  TYPE vbkd-zterm,
        bzirk LIKE vbkd-bzirk,
        bzirk1 LIKE t171t-bztxt,                      " Name of the Sales District
        mschl LIKE vbkd-mschl,
        bstkd LIKE vbkd-bstkd,
        text1 LIKE t040a-text1,
        v_so  TYPE c,
        ktext TYPE ktext,
        kdgrp LIKE knvv-kdgrp,
        vkorg LIKE vbak-vkorg,   " Organização de Vendas
        kunnr3 TYPE kunnr,
        custs TYPE zvar-description,
        zzrepcc TYPE vbap-zzrepcc,
        zzpaidd TYPE vbap-zzpaidd,
        name2   TYPE t001w-name1,                       "Plant description
        rel     TYPE char15,                            "released
        salgrp  TYPE char15,                            "Sales group
        saltyp  TYPE char20,                            "Sales Type
        zzcre_blk  TYPE bezei40,                        "Credit block reason
        zzdate_blk TYPE vbak-zzdate_blk,                "Credit block date
        zexrate    TYPE bkpf-kursf,                     "Fixed USD Rate
        zzcust_po  TYPE zd_cust_po,                     "Customer Purchase order number
        zzcust_po_item TYPE zd_cust_po_item,            "Customer PO line item number
        zvalorunit TYPE konv-kbetr,                     "VLR
        ztaxzur TYPE kna1-txjcd,                        "Tax Jurisdiction Code
        lifsp(2)    TYPE c,                                 "
        faksp(2)    TYPE c,                                 "
        kunnr4(10)    TYPE c,                            " Payer                                   "   New
        parvwt(40)    TYPE c,                            " Payer Name                              "   New
        kunnr4_ad(35) TYPE c,                            " Address                                 "
        freight_br  TYPE kbetr,                          " Freight BR                              "
        pgrp(15)    TYPE c,                              " packing Group                           "
        roteiro     TYPE char4000,                       " roteiro                                 "
  END OF t_saida.


DATA: BEGIN OF it_temp OCCURS 0,
       werks LIKE vbap-werks,
        vbelv LIKE vbfa-vbelv,
        vbeln LIKE vbak-vbeln,
        posnr LIKE vbap-posnr,
        kunnr LIKE kna1-kunnr,
        inco1 LIKE vbkd-inco1,
        vkbur  LIKE vbak-vkbur,
        vkburt LIKE tvkbt-bezei,
        vkgrp  LIKE  vbak-vkgrp,
        vkgrpt LIKE  tvgrt-bezei,
        kunnr2 LIKE vbpa-kunnr,
        agent  LIKE kna1-name1,
        valdt LIKE vbkd-valdt,
        vdatu LIKE vbak-vdatu,
        mahdt LIKE vbak-mahdt,
        erdat LIKE vbak-erdat,
        ort01 LIKE kna1-ort01,
        regio LIKE kna1-regio,
        name1 LIKE kna1-name1,
        matnr LIKE vbap-matnr,
        arktx LIKE vbap-arktx,
        kwmeng LIKE vbap-kwmeng,
        vlrrem LIKE vbap-kwmeng,
        mvgr3  LIKE vbap-mvgr3,
        bezei3 TYPE char44,
        saldo LIKE vbbe-omeng,
        lifsk LIKE vbak-lifsk,
        faksk LIKE vbak-faksk,
        cmgst LIKE vbuk-cmgst,
        abgru LIKE vbap-abgru,
        bezei TYPE char44,
        kbetr LIKE konv-kbetr,
        udate LIKE cdhdr-udate,
        bmeng LIKE vbep-bmeng,
        ernam LIKE vbak-ernam,
        klabc LIKE knvv-klabc,
        ddtext LIKE dd07v-ddtext,
        eikto LIKE knvv-eikto,
        taxa  LIKE konv-kbetr, " Taxa do Dolar.
        valor_dolar LIKE konv-kawrt, " Valor do Item em Dolar.
        valor_real  LIKE konv-kawrt, "konv-kbetr, " Valor do Item em Real
        mstav LIKE mara-mstav, " Bloqueio de Entrada
        zra0  TYPE p LENGTH 7 DECIMALS 3, " condição ZRA0
        matkl LIKE mara-matkl,
        wgbez60  LIKE v023-wgbez60,
        olfmng LIKE vbepvb-olfmng,
        auart LIKE vbak-auart,
        guebg LIKE vbak-guebg,
        gueen LIKE vbak-gueen,
        vgbel LIKE vbak-vgbel,
        kdkg5 LIKE vbkd-kdkg5,
        empst LIKE vbkd-empst,
        omeng LIKE vbbe-omeng,
        tdtext(132) TYPE c,
        zterm  TYPE vbkd-zterm,
        bzirk LIKE vbkd-bzirk,
        mschl LIKE vbkd-mschl,
        bstkd LIKE vbkd-bstkd,
        text1 LIKE t040a-text1,
        v_so  TYPE c,
        ktext TYPE ktext,
        kdgrp LIKE knvv-kdgrp,
        vkorg LIKE vbak-vkorg,   " Organização de Vendas
        zzrepcc LIKE vbap-zzrepcc,
        zzpaidd LIKE vbap-zzpaidd,
        name2   TYPE t001w-name1,                       "Plant description
        rel     TYPE char15,                            "released
        salgrp  TYPE char15,                            "Sales group
        saltyp  TYPE char20,                            "Sales Type
  END OF it_temp.

DATA: e_saida LIKE t_saida,
      wa_vbak LIKE t_vbak.

TYPES: BEGIN OF ty_final,
        werks LIKE vbap-werks,
        kwmeng LIKE vbap-kwmeng,
        vlrrem LIKE vbap-kwmeng,
        saldo LIKE vbbe-omeng,
        valor_real  LIKE konv-kawrt,
        valor_dolar LIKE konv-kawrt,
        bmeng LIKE vbep-bmeng,
      END OF ty_final.

DATA: it_final TYPE STANDARD TABLE OF ty_final,
      wa_final TYPE ty_final.

DATA: BEGIN OF t_agente OCCURS 0,
        kunnr2      LIKE vbpa-kunnr,
        kwmeng      LIKE vbap-kwmeng,
        vlrrem      LIKE vbap-kwmeng,
        saldo       LIKE vbbe-omeng,
        valor_real  LIKE konv-kawrt, "konv-kbetr, " Valor do Item em Real
        valor_dolar LIKE konv-kawrt, " Valor em Dolar.
        bmeng       LIKE vbep-bmeng,
      END OF t_agente.

DATA: BEGIN OF t_filial OCCURS 0,
        vkbur       LIKE vbak-vkbur,
        vkburt      LIKE tvkbt-bezei,
        kwmeng      LIKE vbap-kwmeng,
        vlrrem      LIKE vbap-kwmeng,
        saldo       LIKE vbbe-omeng,
        valor_real  LIKE konv-kawrt, "konv-kbetr, " Valor do Item em Real
        valor_dolar LIKE konv-kawrt, " Valor em Dolar.
        bmeng       LIKE vbep-bmeng,
      END OF t_filial.


DATA: BEGIN OF t_superv OCCURS 0,
        vkgrp       LIKE vbak-vkgrp,
        kwmeng      LIKE vbap-kwmeng,
        vlrrem      LIKE vbap-kwmeng,
        saldo       LIKE vbbe-omeng,
        valor_real  LIKE konv-kawrt, "konv-kbetr, " Valor do Item em Real
        valor_dolar LIKE konv-kawrt, " Valor em Dolar.
        bmeng       LIKE vbep-bmeng,
      END OF t_superv.

DATA t_tvgrt TYPE STANDARD TABLE OF tvgrt WITH HEADER LINE.
DATA t_t040a  TYPE STANDARD TABLE OF t040a  WITH HEADER LINE.


DATA: BEGIN OF t_excel OCCURS 0,
         version(14) TYPE c,
         centro(5) TYPE c,
         name2     TYPE char30,                            "Plant description " Position changed
         data(19) TYPE c,
*         hora(10) TYPE c,
         vkorg(21) TYPE c,
         contract_no(20) TYPE c,
         contract_type(25) TYPE c,
         zzrepcc(20) TYPE c,
         zzpaidd(16) TYPE c,
         bstkd(35) TYPE c,
         ordem(10) TYPE c,
         cont_status TYPE vtext,
         numcli(10) TYPE c,
         nomcli(35) TYPE c,
         modali(10) TYPE c,
         bzirk(20) TYPE c,
         bzirk1(20) TYPE c,                                 " Name of the Sales District
         vkbur(04) TYPE c,                                  "
         vkburt(20) TYPE c,                                 "
         vkgrp(03) TYPE c,                                  "
         vkgrpt(20) TYPE c,                                 "
         kunnr(10) TYPE c,                                  "
         name1(40) TYPE c,                                  "
         dvenc(16) TYPE c,
         dcred(16) TYPE c,
         dini(16) TYPE c,
         dfim(16) TYPE c,
         dcria(16) TYPE c,
         edatu(16) TYPE c,
         dest(6) TYPE c,
         dest2(35) TYPE c,
         ort02(35) TYPE c,
         produto(18) TYPE c,
         descri(40) TYPE c,
         qprog(18) TYPE c,
         qremet(18) TYPE c,
         qpend(18) TYPE c,
         vlruni(18) TYPE c,
         waerk       TYPE char10,
         real_value(20) TYPE c,
         usd_rate(20) TYPE c,
         usd_value(20) TYPE c,
         zra0(20) TYPE c,
         mvgr3(03) TYPE c,                                  "
         mvgr3t(40) TYPE c,                                 "
         mvgr4(03) TYPE c,                                  "
         mvgr4t(20) TYPE c,                                 "
         blrem(8) TYPE c,
         blpgto(7) TYPE c,
         blcred(7) TYPE c,
         lifsp(2) TYPE c,                                                                          "   New
         faksp(2) TYPE c,                                                                          "   New
         motrec(17) TYPE c,
         ernam     LIKE vbak-ernam,
*         klabc(18)  TYPE c,                                                                        "   below 2 fields
         klabc1(18) TYPE c,                                 "
         klabc1t(60) TYPE c,                                "
         kdgrp(60) TYPE c,
         zterm(4) TYPE c,
*         mschl(50) TYPE c,  "   below 2 fields
         mschl1(1) TYPE c,
         mschl1t(50) TYPE c,
         eikto     LIKE knvv-eikto,
         mstav(02) TYPE c,
         stcd1(16) TYPE c,
         stcd2(12) TYPE c,
         stcd3(18) TYPE c,
         stcd4(18) TYPE c,
         pstlz(11) TYPE c,
         stras(35) TYPE c,
*         receb(10) TYPE c,   " Need to remove
         receb1(10) TYPE c,  "   new
         receb1t(40) TYPE c, "   new
*         custs     TYPE zvar-description,
         salgrp    TYPE char15,                            "Sales group
         saltyp    TYPE char20,                            "Sales Type
         rel       TYPE char15,                            "Released
         zitemno   TYPE char14,                            "Item Number                 " Position Change
         zitemno1  TYPE char14,                            "Item Number                 "   New
         zzcre_blk  TYPE bezei40,                          "Credit block reason
         zzdate_blk TYPE char16,                           "Credit block date
         kunnr4(10)    TYPE c,                                                                     "   New
         parvwt(40)    TYPE c,                                                                     "   New
         kunnr4_ad(35) TYPE c,                            " Address                                 "
         freight(15)   TYPE c,                                                                     "   New
         pgrp(15)      TYPE c,                                                                     "   New
         troto(4000)   TYPE c,                                                                     "   New
      END OF t_excel.


DATA: BEGIN OF t_cdpos OCCURS 0,
        objectclas  LIKE cdpos-objectclas,
        objectid    LIKE cdpos-objectid,
        changenr    LIKE cdpos-changenr,
      END OF t_cdpos,

      BEGIN OF t_cdhdr OCCURS 0,
        objectclas  LIKE cdpos-objectclas,
        objectid    LIKE cdpos-objectid,
        changenr    LIKE cdpos-changenr,
        udate       LIKE cdhdr-udate,
      END OF t_cdhdr.

DATA: BEGIN OF t_knvv OCCURS 0,
        kunnr LIKE knvv-kunnr,
        vkorg LIKE knvv-vkorg,
        spart LIKE knvv-spart,
        kdgrp LIKE knvv-kdgrp,
        eikto LIKE knvv-eikto,
        klabc LIKE knvv-klabc,
      END OF t_knvv.

DATA: BEGIN OF t_023t OCCURS 0,
        matkl    LIKE mara-matkl,
        wgbez60  LIKE t023t-wgbez60,
      END OF t_023t.

DATA: v_file TYPE string,
       v_cont(3) TYPE c,
       v_inicio(3) TYPE c,
       v_arquivo(128) TYPE c,
       v_campo(15) TYPE c.

DATA: BEGIN OF t_lips OCCURS 0,
        vgbel LIKE lips-vgbel,
        vgpos LIKE lips-vgpos,
        matnr LIKE lips-matnr,
        lfimg LIKE lips-lfimg,
        vbeln LIKE lips-vbeln,
      END OF t_lips.

DATA: BEGIN OF t_vbfa OCCURS 0,
      vbelv     LIKE vbfa-vbelv,
      posnv     LIKE vbfa-posnv,
      vbeln     LIKE vbfa-vbeln,
      posnn     LIKE vbfa-posnn,
      vbtyp_n   LIKE vbfa-vbtyp_n,
      rfmng     LIKE vbfa-rfmng,
      END OF t_vbfa.

TYPES : BEGIN OF ty_vbfa,
        vbelv TYPE vbfa-vbelv,
        vbeln TYPE vbfa-vbeln,
        posnn TYPE vbfa-posnn,
        vbtyp_n TYPE vbfa-vbtyp_n,
       END OF ty_vbfa.
DATA : i_vbfa TYPE TABLE OF ty_vbfa, wa_vbfa TYPE ty_vbfa.
DATA : v_name(70) TYPE c.
DATA: vl_cont TYPE i,
      vl_flag(1),
      vl_tabix LIKE sy-tabix.

DATA: t_vbfa_new TYPE STANDARD TABLE OF vbfa,
      lvbfa TYPE vbfa,
      t_vbup TYPE STANDARD TABLE OF vbup,
      t_vbep_new TYPE STANDARD TABLE OF vbepvb,
      t_vbap_new TYPE TABLE OF vbapvb,
      t_vbap_new1 LIKE TABLE OF t_vbap,                     "
      lvbep TYPE vbepvb,
      lvbap TYPE vbapvb.

FIELD-SYMBOLS <fs_vbap_new1> LIKE LINE OF t_vbap.
*************************
TYPES: BEGIN OF vbep_ty,
        werks TYPE vbap-werks,
        vbeln TYPE vbepvb-vbeln,
        posnr TYPE vbepvb-posnr,
        etenr TYPE vbepvb-etenr,
        ettyp TYPE vbepvb-ettyp,
        edatu TYPE vbepvb-edatu,
        mbdat TYPE vbepvb-mbdat,
        olfmng TYPE vbepvb-olfmng,
        vsmng TYPE vbepvb-vsmng,
        vrkme TYPE vbepvb-vrkme,
        bmeng TYPE vbepvb-bmeng,

        inco1 TYPE vbkd-inco1,
        lifsk TYPE vbak-lifsk,
        abgru TYPE vbap-abgru,
        lifsp TYPE vbep-lifsp,
        vkgrp TYPE vbak-vkgrp,
        matkl TYPE vbap-matkl,
        kunnr TYPE vbak-kunnr,
       END OF vbep_ty,
       BEGIN OF st_vbbe,
        vbeln LIKE vbbe-vbeln,
        posnr LIKE vbbe-posnr,
        omeng LIKE vbbe-omeng,
       END OF st_vbbe,
       BEGIN OF st_mara,
        matnr LIKE mara-matnr,
        mstav LIKE mara-mstav,
       END OF st_mara.

DATA: vbep_out  TYPE STANDARD TABLE OF vbep_ty,
      lvbep_out TYPE vbep_ty,
      taux_saida LIKE TABLE OF t_saida WITH HEADER LINE,
      taux_vbfa  LIKE TABLE OF t_vbfa WITH HEADER LINE.

DATA: xvbak TYPE STANDARD TABLE OF vbak.
DATA: xvbap TYPE STANDARD TABLE OF vbapvb.
DATA: xvbep TYPE STANDARD TABLE OF vbepvb.
DATA: xvbkd TYPE STANDARD TABLE OF vbkd.
DATA: xvbup TYPE STANDARD TABLE OF vbup.
DATA: xvbfa TYPE STANDARD TABLE OF vbfa.
*************
DATA: xxvbep TYPE STANDARD TABLE OF vbepvb.

DATA: xxvbup TYPE STANDARD TABLE OF vbup.
DATA: xxvbfa TYPE STANDARD TABLE OF vbfa.
DATA: conqty LIKE vbap-kwmeng.
DATA: it_data_elements TYPE STANDARD TABLE OF dd07v,
      wa_data_elements LIKE LINE OF it_data_elements.
DATA : itab_vbbe TYPE STANDARD TABLE OF st_vbbe,
       itab_mara TYPE STANDARD TABLE OF st_mara,
       wa_vbbe   TYPE st_vbbe,
       wa_mara   TYPE st_mara.
DATA : itab_vbpa1 LIKE TABLE OF t_vbpa WITH HEADER LINE.                                             "CHG160438
TYPES: BEGIN OF xxvbkd_ty,
       vbeln TYPE vbepvb-vbeln,
       posnr TYPE vbepvb-posnr,
       inco1 TYPE vbkd-inco1,
        END OF xxvbkd_ty.
DATA: xxvbkd TYPE STANDARD TABLE OF xxvbkd_ty.

DATA: llvbkd TYPE xxvbkd_ty.
***********

DATA: lvbak TYPE vbak.
DATA: lvbup TYPE vbup.
DATA: lvbkd TYPE vbkd.
DATA text_bq TYPE TABLE OF tline WITH HEADER LINE.
DATA: BEGIN OF z_lines1 OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA: END OF z_lines1.
DATA pvbeln LIKE vbak-vbeln.
DATA s_no TYPE vbeln_va.
DATA c_no TYPE vbeln_von.
DATA v_vtext TYPE vtext.
CLEAR: s_no, c_no .
DATA : remqty TYPE vbep-wmeng,
       vbepqty TYPE vbep-wmeng,
       lipsqty TYPE lips-lfimg.
******* removal of hard coding
DATA: t_const TYPE STANDARD TABLE OF ztut_valu WITH HEADER LINE.
CONSTANTS:c_const1 TYPE char50 VALUE '001_INS',
          c_const2 TYPE char50 VALUE '002_INS',
          c_const3 TYPE char50 VALUE '003_INS',
          c_const4 TYPE char50 VALUE '004_INS',
          c_const5 TYPE char50 VALUE '005_INS',
          c_const6 TYPE char50 VALUE '006_INS',
          c_const49 TYPE char50 VALUE '049_INS',                                                   "   new
          c_const7 TYPE char50 VALUE '007_INS',
          c_const8 TYPE char50 VALUE '008_INS',
          c_const9 TYPE char50 VALUE '009_INS',
          c_const10 TYPE char50 VALUE '010_INS',
          c_const11 TYPE char50 VALUE '011_INS',
          c_const12 TYPE char50 VALUE '012_INS',
          c_const50 TYPE char50 VALUE '050_INS',                                                   "   new
          c_const13 TYPE char50 VALUE '013_INS',
          c_const14 TYPE char50 VALUE '014_INS',
          c_const15 TYPE char50 VALUE '015_INS',
          c_const16 TYPE char50 VALUE '016_INS',
          c_const17 TYPE char50 VALUE '017_INS',
          c_const18 TYPE char50 VALUE '018_INS',
          c_const19 TYPE char50 VALUE '019_INS',
          c_const20 TYPE char50 VALUE '020_INS',
          c_const21 TYPE char50 VALUE '021_INS',
          c_const22 TYPE char50 VALUE '022_INS',
          c_const23 TYPE char50 VALUE '023_INS',
          c_const24 TYPE char50 VALUE '024_INS',
          c_const25 TYPE char50 VALUE '025_INS',
          c_const26 TYPE char50 VALUE '026_INS',
          c_const27 TYPE char50 VALUE '027_INS',
          c_const28 TYPE char50 VALUE '028_INS',
          c_const29 TYPE char50 VALUE '029_INS',
          c_const30 TYPE char50 VALUE '030_INS',
          c_const31 TYPE char50 VALUE '031_INS',
          c_6000    TYPE char4  VALUE '6000',
          c_adm_cap TYPE char3  VALUE 'ADM',
          c_adm_sml TYPE char3  VALUE 'adm',
          c_5926    TYPE char4  VALUE '5926',
          c_890     TYPE char3  VALUE '890',
          c_846     TYPE char3  VALUE '846',
          c_supply  TYPE sy-repid VALUE 'ZSDBR_SA_SUPPLY',
          c_zsdr3002 TYPE char10 VALUE 'ZSDR3002',
          c_x       TYPE char1  VALUE 'X',
          c_brl     TYPE char3  VALUE 'BRL',
          c_rfstk   TYPE char5  VALUE 'RFSTK',
          c_c       TYPE char1  VALUE 'C',
          c_usd     TYPE char3  VALUE 'USD',
          c_atwrt1  TYPE atwrt  VALUE 'BIGBAG',             "
          c_value1  TYPE char15 VALUE 'B – Big bag',        "
          c_atwrt2  TYPE atwrt  VALUE 'SACO',               "
          c_value2  TYPE char15 VALUE 'S – Ensacado',       "
          c_value3  TYPE char15 VALUE 'G – Granel',         "
          c_chg1    TYPE zd_var1 VALUE 'CHG157751'.         "

CONSTANTS : c_faksk TYPE zd_var2 VALUE 'FAKSK',             "
            c_lifsk TYPE zd_var2 VALUE 'LIFSK',             "
            c_faksp TYPE zd_var2 VALUE 'FAKSP',             "
            c_lifsp TYPE zd_var2 VALUE 'LIFSP',             "
            c_g     TYPE vbtyp   VALUE 'G'.                 "

DATA:  l_const1 TYPE char50, l_const2 TYPE char50, l_const3 TYPE char50,
       l_const4 TYPE char50, l_const5 TYPE char50,l_const6 TYPE char50,
       l_const7 TYPE char50, l_const8 TYPE char50,l_const9 TYPE char50,
       l_const49 TYPE char50, l_const50 TYPE char50,        "
       l_const10 TYPE char50, l_const11 TYPE char50, l_const12 TYPE char50,
       l_const13 TYPE char50, l_const14 TYPE char50, l_const15 TYPE char50,l_const16 TYPE char50,
       l_const17 TYPE char50, l_const18 TYPE char50, l_const19 TYPE char50 , l_const20 TYPE char50,
       l_const21 TYPE char50, l_const22 TYPE char50, l_const23 TYPE char50 , l_const24 TYPE char50,
       lv_const25 TYPE char50,lv_const26 TYPE char50,lv_const27 TYPE char50 ,lv_const28 TYPE char50,
       lv_const29 TYPE char50,lv_const30 TYPE char50,lv_const31 TYPE char50 ,lv_auart   TYPE char1.

DATA: itab_supply_const  TYPE TABLE OF ztut_valu,
      wa_const           TYPE ztut_valu.
TYPES: BEGIN OF st_vbak1,
       vbeln TYPE vbak-vbeln,
       vbtyp TYPE vbak-vbtyp,
       guebg TYPE vbak-guebg,
       gueen TYPE vbak-gueen,
       END OF st_vbak1.

DATA:  itab_vbak1 TYPE TABLE OF st_vbak1,
       wa_vbak1 LIKE LINE OF itab_vbak1.
*--------------------------------------------------------------------*
DATA: wa_vbfa_q LIKE LINE OF t_vbfa,
      wa_vbap_q LIKE LINE OF t_vbap,
      wa_vbep_q LIKE LINE OF t_vbep,
      wa_vbpa_q LIKE LINE OF t_vbpa .
*--------------------------------------------------------------------*

*data declaration for send email logic
DATA:  v_send_request     TYPE REF TO cl_bcs,
       v_sender           TYPE REF TO cl_sapuser_bcs,
       v_document         TYPE REF TO cl_document_bcs,
       v_recipient        TYPE REF TO if_recipient_bcs,
       v_bcs_exception    TYPE REF TO cx_bcs,
       v_send             TYPE os_boolean,
       v_subject          TYPE so_obj_des,
       v_size             TYPE so_obj_len,
       v_solix            TYPE solix_tab,
       v_string           TYPE string,
       itab_text          TYPE bcsy_text.

CONSTANTS: c_tab          TYPE c VALUE cl_bcs_convert=>gc_tab,
           c_crlf         TYPE c VALUE cl_bcs_convert=>gc_crlf,
           c_palantir     TYPE c LENGTH 8 VALUE 'PALANTIR'.

TYPES: BEGIN OF v_ty_zvar,
        var1  TYPE zvar-var1,
        descr TYPE zvar-description,
        var2  TYPE zvar-var2,
        var3  TYPE zvar-var3,
       END OF v_ty_zvar.

TYPES: BEGIN OF v_ty_zvars,
        descr TYPE zvar-description,
       END OF v_ty_zvars.

DATA: wa_zvar    TYPE v_ty_zvar,
      itab_zvar  TYPE TABLE OF v_ty_zvar,
      itab_zvars TYPE TABLE OF v_ty_zvars,
      itab_zvart TYPE TABLE OF v_ty_zvar,
      itab_zvaru TYPE TABLE OF v_ty_zvar,
      itab_zvari TYPE TABLE OF v_ty_zvar,
      itab_zvarf TYPE TABLE OF v_ty_zvar,
      wa_zvari   TYPE v_ty_zvar,
      wa_zvarf   TYPE v_ty_zvar,
      v_path     TYPE string.

DATA: out_zzrepcc TYPE vbap-zzrepcc,
      out_zzpaidd TYPE vbap-zzpaidd,
      zzrepcc_filled TYPE char1,
      zzpaidd_filled TYPE char1.


DATA: itab_delvblk TYPE TABLE OF tvlst,
      wa_delvblk   TYPE tvlst.
DATA: lv_contract_line TYPE char1,
      lv_pending       TYPE vbap-kwmeng,
      t_excel_temp     LIKE t_excel OCCURS 0.

TYPES : BEGIN OF ty_insert,
          cd_elo_carteira_sap(9) TYPE n,
          nu_carteira_version TYPE string,
          cd_centro_expedidor(4),
          ds_centro_expedidor(31),
          dh_carteira(19),
          cd_sales_org(4),
          nu_contrato_sap(10),
          cd_tipo_contrato(4),
          nu_contrato_substitui(10),
          dt_pago(10),
          nu_contrato(10) TYPE n,
          nu_ordem_venda(10),
          ds_status_contrato_sap(20),
          cd_cliente(11),
          no_cliente(140),
          cd_incoterms(3),
          cd_sales_district(6),
          cd_sales_office(4),
          no_sales_office(140),
          cd_sales_group(3),
          no_sales_group(140),
          cd_agente_venda(10),
          no_agente(160),
          dh_vencimento_pedido(10),
          dt_credito(10),
          dt_inicio(10),
          dt_fim(10),
          dh_inclusao(10),
          dh_entrega(10),
          sg_estado(6),
          no_municipio(60),
          ds_bairro(35),
          cd_produto_sap(18),
          no_produto_sap(44),
          qt_programada TYPE vbap-kwmeng,
          qt_entregue TYPE vbap-kwmeng,
          qt_saldo TYPE vbbe-omeng,
          vl_unitario TYPE konv-kwert,
          vl_brl TYPE konv-kwert,
          vl_taxa_dolar TYPE konv-kwert,
          vl_usd TYPE konv-kwert,
          pc_comissao TYPE konv-kwert,
          cd_sacaria(3),
          ds_sacaria(40),
          cd_cultura_sap(3),
          ds_cultura_sap(40),
          cd_bloqueio_remessa(2),
          cd_bloqueio_faturamento(2),
          cd_bloqueio_credito(1),
          cd_bloqueio_remessa_item(2),
          cd_bloqueio_faturamento_item(2),
          cd_motivo_recusa(2),
          cd_login(12),
          cd_segmentacao_cliente(2),
          ds_segmentacao_cliente(60),
          ds_segmento_cliente_sap(2),
          cd_forma_pagamento(4),
          cd_tipo_pagamento(1),
          ds_tipo_pagamento(50),
          cd_agrupamento(12),
          cd_bloqueio_entrega(2),
          nu_cnpj(16),
          nu_cpf(11),
          nu_inscricao_estadual(18),
          nu_inscricao_municipal(18),
          nu_cep(10),
          ds_endereco(100),
          cd_cliente_recebedor(11),
          no_cliente_recebedor(140),
          cd_moeda(5),
          cd_supply_group(15),
          ds_venda_compartilhada(20),
          cd_status_liberacao(1),
          cd_item_pedido(6) TYPE n,
          cd_cliente_pagador(11),
          no_cliente_pagador(140),
          vl_frete_distribuicao  TYPE konv-kwert,
          cd_grupo_embalagem(1),
          ds_credit_block_reason(30),
          dh_credit_block(10),
          cd_item_contrato(6) TYPE n,
          ds_endereco_pagador(35),
          no_sales_district(20),
          ds_roteiro_entrega(4000),
        END OF ty_insert.

DATA : itab_insert TYPE TABLE OF ty_insert,
       w           TYPE ty_insert,
       gv_number(9)   TYPE n.

DATA : itab_vbak_temp LIKE TABLE OF t_vbak.
DATA : t_excel1 LIKE TABLE OF t_excel WITH HEADER LINE.                                            "CHG160438
DATA : lv_pac TYPE p DECIMALS 2.                                                                   "CHG160438
TYPES : BEGIN OF ty_t171t,
          spras TYPE spras,
          bzirk TYPE bzirk,
          bztxt TYPE bztxt,
        END OF ty_t171t.

DATA : itab_t171t TYPE TABLE OF ty_t171t,
       wa_t171t   TYPE ty_t171t.


FIELD-SYMBOLS: <campo>    TYPE any,
               <wa_excel> LIKE LINE OF t_excel.
SELECTION-SCREEN BEGIN OF BLOCK bloco3 WITH FRAME TITLE text-143.
SELECT-OPTIONS: s_vkorg FOR vbak-vkorg OBLIGATORY,    " BR01/BR02/BR03/BR04
                s_vtweg FOR vbak-vtweg OBLIGATORY,
                s_werks FOR vbap-werks OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bloco3.

SELECTION-SCREEN BEGIN OF BLOCK bloco1 WITH FRAME TITLE text-005.
SELECT-OPTIONS:  s_erdat FOR vbak-erdat OBLIGATORY,  " Contract creation date
                 s_guebg FOR vbak-guebg,             " Contract valid from
                 s_gueen FOR vbak-gueen,             " Contract valid to
                 s_kdkg5 FOR vbkd-kdkg5,             " Contract Status
                 s_mahdt FOR vbak-mahdt.   " Fim Remessa
SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 10(2) text-006.
SELECTION-SCREEN END OF LINE.

SELECT-OPTIONS: s_edatu FOR vbep-edatu,   " Planned Delivery date
                s_lifsp FOR vbep-lifsp,   " Delilvery block
                s_vdatu FOR vbak-vdatu.   " Requested delivery date

SELECTION-SCREEN END OF BLOCK bloco1.

SELECTION-SCREEN BEGIN OF BLOCK bloco2 WITH FRAME TITLE text-001.

SELECT-OPTIONS: s_auart FOR vbak-auart,
                s_vbeln FOR vbak-vbeln,
                s_erdat2 FOR vbak-erdat,
                s_vldat FOR vbkd-valdt,
                s_kunnr FOR vbak-kunnr,
                s_vkbur FOR vbak-vkbur,
                s_vkgrp FOR vbak-vkgrp,
                s_kunnr2 FOR vbak-kunnr,
                s_zterm FOR vbkd-zterm,
                s_inco1 FOR vbkd-inco1,
                s_cmgst FOR vbuk-cmgst,
                s_faksk FOR vbak-faksk,
                s_matnr FOR vbap-matnr,
                s_magrv FOR mara-magrv,
                s_matkl FOR mara-matkl,
                s_disgr FOR marc-disgr,
                s_kwmeng FOR vbap-kwmeng,
                s_abgru FOR vbap-abgru,
                s_eikto FOR knvv-eikto,
                s_ernam FOR vbak-ernam,
                s_mstav FOR mara-mstav,
                s_spart FOR vbak-spart,   " Setor de atividade
                s_saldo  FOR vbbe-omeng,   " Saldo
                s_mvgr3 FOR vbap-mvgr3,
                s_bstkd FOR vbkd-bstkd,
                s_bzirk FOR vbkd-bzirk,
                s_mschl FOR vbkd-mschl,
                s_klabc FOR knvv-klabc MODIF ID kla,
                s_kdgrp FOR knvv-kdgrp MODIF ID kla,
                s_custs FOR wa_zvar-descr.


DATA:  itab_dyfields TYPE TABLE OF dynpread,
       wa_dyfields   TYPE dynpread.

TYPES: BEGIN OF ty_vbfa1,
         vbelv          TYPE          vbeln_von,
         posnv          TYPE          posnr_von,
         vbeln          TYPE          vbeln_nach,
         posnr          TYPE          posnr_nach,
         vbtyp          TYPE          vbtyp_n,
         rfmng          TYPE          rfmng,
         read           TYPE          char1,
       END OF ty_vbfa1,
       BEGIN OF ty_vbap,
         vbeln          TYPE          vbeln_nach,
         zmeng          TYPE          dzmeng,
       END OF ty_vbap,
       BEGIN OF ty_vbap1,
         vbeln          TYPE          vbeln_nach,
         kwmeng         TYPE          kwmeng,
       END OF ty_vbap1,
       BEGIN OF ty_vbak2,
         vbeln          TYPE          vbak-vbeln,
         erdat          TYPE          vbak-erdat,
         vbtyp          TYPE          vbak-vbtyp,
       END OF ty_vbak2.
DATA: itab_vbfa1        TYPE TABLE OF ty_vbfa1,
      wa_vbfa1          TYPE          ty_vbfa1,
      wa_vbfa2          TYPE          ty_vbfa1,
      gv_zmeng          TYPE          rfmng,
      gv_kwmeng         TYPE          kwmeng,
      gv_quantity       TYPE          dzmeng,
      gv_vbelv1         TYPE          vbeln_von,
      gv_index          TYPE          sy-index,
      itab_vbap         TYPE TABLE OF ty_vbap,
      wa_vbap           TYPE          ty_vbap,
      itab_vbap1        TYPE TABLE OF ty_vbap1,
      wa_vbap1          TYPE          ty_vbap1,
      itab_vbak2        TYPE TABLE OF ty_vbak2,
      wa_vbak2          TYPE          ty_vbak2,
      wa_vbak3          LIKE          t_vbak.
CONSTANTS:  c_contract  TYPE          char1         VALUE 'G',
            c_order     TYPE          char1         VALUE 'C'.

DATA: lv_sorder TYPE vbfa-vbeln,
      lv_soitem TYPE vbfa-posnn,
      lv_soqty  TYPE vbep-wmeng.
TYPES : BEGIN OF ty_cre_blk,
          vbeln         TYPE          vbak-vbeln,
          zzcre_blk     TYPE          bezei40,
          zzdate_blk    TYPE          vbak-zzdate_blk,
        END OF ty_cre_blk.
DATA  : itab_cre_blk    TYPE TABLE OF ty_cre_blk,
        wa_cre_blk      TYPE          ty_cre_blk.
DATA: l_exc_ref TYPE REF TO cx_sy_native_sql_error,
      l_error   TYPE string,
      l_key     TYPE string,
      l_instr   TYPE string.
DATA : t_vbap_c TYPE TABLE OF vbap WITH HEADER LINE,                                               "CHG160438
       v_temp TYPE vbap-zmeng,                                                                     "CHG160438
       t_vbak_c TYPE TABLE OF vbak WITH HEADER LINE.                                               "CHG160438
DATA : lv_time  TYPE char8,                                                                        "CHG160842
       lv_time1 TYPE char6,                                                                        "CHG160842
       lv_date  TYPE char8.                                                                        "CHG160842
SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS p_rad1 RADIOBUTTON GROUP grp1 USER-COMMAND opt DEFAULT 'X' .
SELECTION-SCREEN COMMENT 4(25) text-s01 FOR FIELD p_rad1.
SELECTION-SCREEN END OF LINE .
SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS p_rad2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 4(25) text-s02 FOR FIELD p_rad2.
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN END OF BLOCK bloco2.


SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME TITLE text-002.
PARAMETERS: p_agente AS CHECKBOX,
            p_filial AS CHECKBOX,
            p_superv AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK a2.
SELECTION-SCREEN BEGIN OF BLOCK a3 WITH FRAME TITLE text-003.
PARAMETER:  p_sele   AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK a3.

SELECTION-SCREEN BEGIN OF BLOCK a4 WITH FRAME TITLE text-004.
PARAMETERS p_path LIKE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK a4.

SELECTION-SCREEN BEGIN OF BLOCK a5 WITH FRAME TITLE text-155.
SELECTION-SCREEN COMMENT /1(30) text-164.
PARAMETERS  p_email TYPE adr6-smtp_addr.
SELECTION-SCREEN END OF BLOCK a5.

SELECTION-SCREEN BEGIN OF BLOCK a6 WITH FRAME TITLE text-248.
PARAMETERS p_update TYPE char01 AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK a6.

* Função para digitar nome do arquivo a ser feito batch input
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      mask      = '*.txt'
      static    = 'X'
    CHANGING
      file_name = p_path.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR: s_custs-low.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'DESCR'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'S_CUSTT'
      value_org   = 'S'
    TABLES
      value_tab   = itab_zvars.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR: s_custs-high.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'DESCR'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'S_CUSTT'
      value_org   = 'S'
    TABLES
      value_tab   = itab_zvars.


AT SELECTION-SCREEN OUTPUT.

  PERFORM check_customer_structure.

AT SELECTION-SCREEN.
  PERFORM dat_tim.                                                                                 "CHG160842
  PERFORM f_authroity_check.
  PERFORM f_consiste_data.
  PERFORM validate_email_addr.

TOP-OF-PAGE.
  FORMAT COLOR COL_KEY.
  WRITE: /001 sy-uline.
  WRITE: /001 sy-vline,
          002 'Mosaic Fertilizantes'(034),
          190 'Página:'(053), sy-pagno,
          254 sy-vline,
         /001 sy-vline,
          075 'Relatório Geral da Carteira de Vendas'(033),
          190 'Data  : '(035),
          198 sy-datum,
          254 sy-vline,
         /001 sy-vline,
          002 sy-cprog,
          190 'Hora  : '(036),
          198 sy-uzeit,
          254 sy-vline,
         /001 sy-uline.

  FORMAT COLOR  OFF.

AT LINE-SELECTION.


  IF sy-lisel(6) EQ 'Ordem:'(052) OR sy-lisel(6) EQ 'Order '.
    MOVE sy-lisel+7(10) TO s_no ."t_saida-vbeln.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = s_no
      IMPORTING
        output = s_no.


    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        tcode  = 'VA03'
      EXCEPTIONS
        ok     = 0
        not_ok = 2
        OTHERS = 3.

    IF sy-subrc = 0.

      SET PARAMETER ID 'AUN' FIELD s_no . "t_saida-vbeln.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

    ENDIF.


  ELSEIF sy-lisel(18)   = 'Numero do Contrato'(t16) OR
         sy-lisel(12)   = 'Contract No:'(t15).

    MOVE sy-lisel+23(10) TO c_no .

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = c_no
      IMPORTING
        output = c_no.


    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        tcode  = 'VA43'
      EXCEPTIONS
        ok     = 0
        not_ok = 2
        OTHERS = 3.

    IF sy-subrc = 0.

      SET PARAMETER ID 'KTN' FIELD c_no .
      CALL TRANSACTION 'VA43' AND SKIP FIRST SCREEN.

    ENDIF.
  ELSE.

    MOVE sy-lisel(10) TO s_no ."t_saida-vbeln.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = s_no
      IMPORTING
        output = s_no.



    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        tcode  = 'VA03'
      EXCEPTIONS
        ok     = 0
        not_ok = 2
        OTHERS = 3.

    IF sy-subrc = 0.


      SET PARAMETER ID 'AUN' FIELD s_no . "t_saida-vbeln.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    ENDIF.

  ENDIF.


INITIALIZATION.
  PERFORM change_const.
  PERFORM fill_zvar.

* Início do programa
START-OF-SELECTION.
  PERFORM f_monta_range.
  PERFORM f_busca_dados.
  PERFORM f_trata_dados.
  PERFORM f_imprime.
  PERFORM upd_delv_block.
  PERFORM f_getcontdata.                                                                           "CHG160438
  IF p_path NE space.
    PERFORM arq_excel.
    CLEAR : t_saida, t_vbfa. "t_excel.
  ENDIF.

*Email functionality is applicable only in background
  IF p_email IS NOT INITIAL.
    IF sy-batch = 'X'.
      PERFORM send_email.
    ENDIF.
  ENDIF.

DELETE t_excel INDEX 1.                                                                            "CHG160438
SORT t_excel by centro name2 vkorg contract_no contract_type zzrepcc zzpaidd bstkd ordem           "CHG160438
cont_status numcli nomcli modali bzirk  bzirk1 vkbur vkburt vkgrp vkgrpt kunnr name1 dvenc         "CHG160438
dcred dini dfim dcria edatu dest dest2 ort02 produto descri  qprog  qremet qpend vlruni waerk      "CHG160438
real_value usd_rate usd_value zra0 mvgr3 mvgr3t mvgr4 mvgr4t blrem blpgto blcred lifsp faksp       "CHG160438
motrec ernam klabc1 klabc1t kdgrp zterm mschl1 mschl1t eikto mstav stcd1 stcd2 stcd3 stcd4         "CHG160438
pstlz stras receb1 receb1t salgrp saltyp rel zitemno zitemno1 zzcre_blk zzdate_blk kunnr4 parvwt   "CHG160438
kunnr4_ad freight pgrp troto.                                                                      "CHG160438

DELETE ADJACENT DUPLICATES FROM t_excel COMPARING                                                  "CHG160438
centro name2 vkorg contract_no contract_type zzrepcc zzpaidd bstkd ordem cont_status numcli        "CHG160438
nomcli modali bzirk  bzirk1 vkbur vkburt vkgrp vkgrpt kunnr name1 dvenc dcred dini dfim dcria      "CHG160438
edatu dest dest2 ort02 produto descri  qprog  qremet qpend vlruni waerk real_value usd_rate        "CHG160438
usd_value zra0 mvgr3 mvgr3t mvgr4 mvgr4t blrem blpgto blcred lifsp faksp motrec ernam klabc1       "CHG160438
klabc1t kdgrp zterm mschl1 mschl1t eikto mstav stcd1 stcd2 stcd3 stcd4 pstlz stras receb1          "CHG160438
receb1t salgrp saltyp rel zitemno zitemno1 zzcre_blk zzdate_blk kunnr4 parvwt kunnr4_ad            "CHG160438
freight pgrp troto.                                                                                "CHG160438


*Insert values into MOL
  IF NOT t_excel[] IS INITIAL.
    TRY.
      EXEC SQL.
        connect to 'NETVENDAS' as 'ZNVPEN'
      ENDEXEC.

* Conectando com o Banco
      EXEC SQL.
        SET CONNECTION 'ZNVPEN'
      ENDEXEC.

      IF sy-subrc <> 0.
*   Erro ao Conectar com o Banco de dados usuário PIC.WORLD

        STOP.
      ENDIF.
    ENDTRY.

    CLEAR gv_number.
    EXEC SQL.
      SELECT MAX (CD_ELO_CARTEIRA_SAP)
             FROM VND.ELO_CARTEIRA_SAP
             INTO :gv_number
    ENDEXEC.

    IF p_update IS NOT INITIAL.

      LOOP AT t_excel.

        gv_number = gv_number + 1.
        w-cd_elo_carteira_sap                  = gv_number.
        w-nu_carteira_version                  = t_excel-version.
        w-cd_centro_expedidor                  = t_excel-centro.
        w-ds_centro_expedidor                  = t_excel-name2.
        w-dh_carteira                          = t_excel-data.
        w-cd_sales_org                         = t_excel-vkorg.
        w-nu_contrato_sap                      = t_excel-contract_no.
        w-cd_tipo_contrato                     = t_excel-contract_type.
        w-nu_contrato_substitui                = t_excel-zzrepcc.
        IF t_excel-zzpaidd+0(2) NE '00'.
          w-dt_pago                              = t_excel-zzpaidd.
        ELSE.
          w-dt_pago                              = ''.
        ENDIF.
        w-nu_contrato                          = t_excel-bstkd.
        w-nu_ordem_venda                       = t_excel-ordem.
        w-ds_status_contrato_sap               = t_excel-cont_status.
        w-cd_cliente                           = t_excel-numcli.
        w-no_cliente                           = t_excel-nomcli.
        w-cd_incoterms                         = t_excel-modali.
        w-cd_sales_district                    = t_excel-bzirk.
        w-no_sales_district                    = t_excel-bzirk1.
        w-cd_sales_office                      = t_excel-vkbur.
        w-no_sales_office                      = t_excel-vkburt.
        w-cd_sales_group                       = t_excel-vkgrp.
        w-no_sales_group                       = t_excel-vkgrpt.
        w-cd_agente_venda                      = t_excel-kunnr.
        w-no_agente                            = t_excel-name1.
        IF t_excel-dvenc+0(2) NE '00'.
          w-dh_vencimento_pedido                 = t_excel-dvenc.
        ELSE.
          w-dh_vencimento_pedido                 = ''.
        ENDIF.

*      PERFORM date_format USING t_excel-dvenc
*                          CHANGING w-dh_vencimento_pedido.
        IF t_excel-dcred+0(2) NE '00'.
          w-dt_credito                           = t_excel-dcred.
        ELSE.
          w-dt_credito                           = ''.
        ENDIF.
*      PERFORM date_format USING t_excel-dcred
*                          CHANGING w-dt_credito.
        IF t_excel-dini+0(2) NE '00'.
          w-dt_inicio                            = t_excel-dini.
        ELSE.
          w-dt_inicio                            = ''.
        ENDIF.
*      PERFORM date_format USING t_excel-dini
*                          CHANGING w-dt_inicio.

        IF t_excel-dfim+0(2) NE '00'.
          w-dt_fim                               = t_excel-dfim.
        ELSE.
          w-dt_fim                               = ''.
        ENDIF.
*      PERFORM date_format USING t_excel-dfim
*                          CHANGING w-dt_fim.
        IF t_excel-dcria+0(2) NE '00'.
          w-dh_inclusao                          = t_excel-dcria.
        ELSE.
          w-dh_inclusao                          = ''.
        ENDIF.
*      PERFORM date_format USING t_excel-dcria
*                          CHANGING w-dh_inclusao.
        IF t_excel-edatu+0(2) NE '00'.
          w-dh_entrega                           = t_excel-edatu.
        ELSE.
          w-dh_entrega                           = ''.
        ENDIF.
*      PERFORM date_format USING t_excel-edatu
*                          CHANGING w-dh_entrega.
        w-sg_estado                            = t_excel-dest.
        w-no_municipio                         = t_excel-dest2.
        w-ds_bairro                            = t_excel-ort02.
        w-cd_produto_sap                       = t_excel-produto.
        w-no_produto_sap                       = t_excel-descri.
        w-qt_programada                        = t_excel-qprog.
        w-qt_entregue                          = t_excel-qremet.
        w-qt_saldo                             = t_excel-qpend.
        w-vl_unitario                          = t_excel-vlruni.
        w-vl_brl                               = t_excel-real_value.
        w-vl_taxa_dolar                        = t_excel-usd_rate.
        w-vl_usd                               = t_excel-usd_value.
        w-pc_comissao                          = t_excel-zra0.
        w-cd_sacaria                           = t_excel-mvgr3.
        w-ds_sacaria                           = t_excel-mvgr3t.
        w-cd_cultura_sap                       = t_excel-mvgr4.
        w-ds_cultura_sap                       = t_excel-mvgr4t.
        w-cd_bloqueio_remessa                  = t_excel-blrem.
        w-cd_bloqueio_faturamento              = t_excel-blpgto.
        w-cd_bloqueio_credito                  = t_excel-blcred.
        w-cd_bloqueio_remessa_item             = t_excel-lifsp.
        w-cd_bloqueio_faturamento_item         = t_excel-faksp.
        w-cd_motivo_recusa                     = t_excel-motrec.
        w-cd_login                             = t_excel-ernam.
        w-cd_segmentacao_cliente               = t_excel-klabc1.
        w-ds_segmentacao_cliente               = t_excel-klabc1t.
        w-ds_segmento_cliente_sap              = t_excel-kdgrp.
        w-cd_forma_pagamento                   = t_excel-zterm.
        w-cd_tipo_pagamento                    = t_excel-mschl1.
        w-ds_tipo_pagamento                    = t_excel-mschl1t.
        w-cd_agrupamento                       = t_excel-eikto.
        w-cd_bloqueio_entrega                  = t_excel-mstav.
        w-nu_cnpj                              = t_excel-stcd1.
        w-nu_cpf                               = t_excel-stcd2.
        w-nu_inscricao_estadual                = t_excel-stcd3.
        w-nu_inscricao_municipal               = t_excel-stcd4.
        w-nu_cep                               = t_excel-pstlz.
        w-ds_endereco                          = t_excel-stras.
        w-cd_cliente_recebedor                 = t_excel-receb1.
        w-no_cliente_recebedor                 = t_excel-receb1t.
        w-cd_moeda                             = t_excel-waerk.
        w-cd_supply_group                      = t_excel-salgrp.
        w-ds_venda_compartilhada               = t_excel-saltyp.
        w-cd_status_liberacao                  = t_excel-rel.
        w-cd_item_pedido                       = t_excel-zitemno.
        w-cd_cliente_pagador                   = t_excel-kunnr4.
        w-no_cliente_pagador                   = t_excel-parvwt.
        w-ds_endereco_pagador                  = t_excel-kunnr4_ad.
        w-vl_frete_distribuicao                = t_excel-freight.
        w-cd_grupo_embalagem                   = t_excel-pgrp.
        w-ds_credit_block_reason               = t_excel-zzcre_blk.
        IF t_excel-zzdate_blk+0(2) NE '00'.
          w-dh_credit_block                      = t_excel-zzdate_blk.
        ELSE.
          w-dh_credit_block                      = ''.
        ENDIF.

        w-cd_item_contrato                     = t_excel-zitemno1.
        w-ds_roteiro_entrega                   = t_excel-troto.
        APPEND w TO itab_insert.



        TRY.
            EXEC SQL.
              execute procedure vnd.gx_elo_carteira_sap.pi_elo_carteira_sap (
                 in :w-nu_carteira_version,
                 in :w-cd_centro_expedidor,
                 in :w-ds_centro_expedidor,
                 in :w-dh_carteira,
                 in :w-cd_sales_org,
                 in :w-nu_contrato_sap,
                 in :w-cd_tipo_contrato,
                 in :w-nu_contrato_substitui,
                 in :w-dt_pago,
                 in :w-nu_contrato,
                 in :w-nu_ordem_venda,
                 in :w-ds_status_contrato_sap,
                 in :w-cd_cliente,
                 in :w-no_cliente,
                 in :w-cd_incoterms,
                 in :w-cd_sales_district,
                 in :w-cd_sales_office,
                 in :w-no_sales_office,
                 in :w-cd_sales_group,
                 in :w-no_sales_group,
                 in :w-cd_agente_venda,
                 in :w-no_agente,
                 in :w-dh_vencimento_pedido,
                 in :w-dt_credito,
                 in :w-dt_inicio,
                 in :w-dt_fim,
                 in :w-dh_inclusao,
                 in :w-dh_entrega,
                 in :w-sg_estado,
                 in :w-no_municipio,
                 in :w-ds_bairro,
                 in :w-cd_produto_sap,
                 in :w-no_produto_sap,
                 in :w-qt_programada,
                 in :w-qt_entregue,
                 in :w-qt_saldo,
                 in :w-vl_unitario,
                 in :w-vl_brl,
                 in :w-vl_taxa_dolar,
                 in :w-vl_usd,
                 in :w-pc_comissao,
                 in :w-cd_sacaria,
                 in :w-ds_sacaria,
                 in :w-cd_cultura_sap,
                 in :w-ds_cultura_sap,
                 in :w-cd_bloqueio_remessa,
                 in :w-cd_bloqueio_faturamento,
                 in :w-cd_bloqueio_credito,
                 in :w-cd_bloqueio_remessa_item,
                 in :w-cd_bloqueio_faturamento_item,
                 in :w-cd_motivo_recusa,
                 in :w-cd_login,
                 in :w-cd_segmentacao_cliente,
                 in :w-ds_segmentacao_cliente,
                 in :w-ds_segmento_cliente_sap,
                 in :w-cd_forma_pagamento,
                 in :w-cd_tipo_pagamento,
                 in :w-ds_tipo_pagamento,
                 in :w-cd_agrupamento,
                 in :w-cd_bloqueio_entrega,
                 in :w-nu_cnpj,
                 in :w-nu_cpf,
                 in :w-nu_inscricao_estadual,
                 in :w-nu_inscricao_municipal,
                 in :w-nu_cep,
                 in :w-ds_endereco,
                 in :w-cd_cliente_recebedor,
                 in :w-no_cliente_recebedor,
                 in :w-cd_moeda,
                 in :w-cd_supply_group,
                 in :w-ds_venda_compartilhada,
                 in :w-cd_status_liberacao,
                 in :w-cd_item_pedido,
                 in :w-cd_cliente_pagador,
                 in :w-no_cliente_pagador,
                 in :w-vl_frete_distribuicao,
                 in :w-cd_grupo_embalagem,
                 in :w-ds_credit_block_reason,
                 in :w-dh_credit_block,
                 in :w-cd_item_contrato,
                 in :w-ds_endereco_pagador,
                 in :w-no_sales_district,
                 in :w-ds_roteiro_entrega
                )
            ENDEXEC.

          CATCH cx_sy_native_sql_error INTO l_exc_ref.
            l_error = l_exc_ref->get_text( ).
            WRITE :/ text-001, space , l_error .

        ENDTRY.

        CLEAR w.

      ENDLOOP.

    ENDIF.


  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  f_busca_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_busca_dados.
  DATA: vl_tabix LIKE sy-tabix,
        vl_cont TYPE i.
  DATA:l_contract TYPE vbak-vbeln,
       l_sales TYPE vbak-vbeln,
       lv_atinn TYPE atinn.
  IF NOT s_erdat IS INITIAL.
    IF s_vbeln IS INITIAL.
      SELECT v~vbeln
             v~erdat
             v~ernam
             v~vbtyp
             v~auart
             v~lifsk
             v~faksk
             v~waerk
             v~vkorg
             v~spart
             v~vkgrp
             v~vkbur
             v~guebg
             v~gueen
             v~knumv
             v~vdatu
             v~mahdt
             v~kunnr
             v~vgbel
             v~vgtyp
             b~bzirk b~inco1 b~valdt  b~zterm b~mschl b~empst b~bstkd b~kdkg5
             k~cmgst
             INTO TABLE t_vbak
                                FROM vbak AS v
                                     INNER JOIN vbkd AS b
                                     ON v~vbeln EQ b~vbeln
                                     INNER JOIN vbuk AS k
                                     ON v~vbeln EQ k~vbeln
                                WHERE
                                      v~vbeln IN s_vbeln AND
                                      v~erdat IN s_erdat AND
                                      v~ernam IN s_ernam AND
                                      v~vbtyp IN ('C', 'G') AND
                                      v~auart IN s_auart AND
                                      v~faksk IN s_faksk AND
                                      v~vkorg IN s_vkorg AND
                                      v~vtweg IN s_vtweg AND
                                      v~spart IN s_spart AND
                                      v~vkgrp IN s_vkgrp AND
                                      v~vkbur IN s_vkbur AND
                                      v~guebg IN s_guebg AND
                                      v~gueen IN s_gueen AND
                                      v~vdatu IN s_vdatu AND
                                      v~mahdt IN s_mahdt AND
                                      v~kunnr IN s_kunnr AND
                                      b~bzirk IN s_bzirk AND
                                      b~inco1 IN s_inco1 AND
                                      b~zterm IN s_zterm AND
                                      b~mschl IN s_mschl AND
                                      b~bstkd IN s_bstkd AND
                                      b~kdkg5 IN s_kdkg5 AND
                                      k~cmgst IN s_cmgst.
    ELSE.
      SELECT v~vbeln
             v~erdat
             v~ernam
             v~vbtyp
             v~auart
             v~lifsk
             v~faksk
             v~waerk
             v~vkorg
             v~spart
             v~vkgrp
             v~vkbur
             v~guebg
             v~gueen
             v~knumv
             v~vdatu
             v~mahdt
             v~kunnr
             v~vgbel
             v~vgtyp
             b~bzirk b~inco1 b~valdt  b~zterm b~mschl b~empst b~bstkd b~kdkg5
             k~cmgst
             INTO TABLE t_vbak
                                FROM vbak AS v
                                     INNER JOIN vbkd AS b
                                     ON v~vbeln EQ b~vbeln
                                     INNER JOIN vbuk AS k
                                     ON v~vbeln EQ k~vbeln
                                WHERE
                                      ( v~vbeln IN s_vbeln
                                      OR  v~vgbel IN s_vbeln ) AND
                                      v~erdat IN s_erdat AND
                                      v~ernam IN s_ernam AND
                                      v~vbtyp IN ('C', 'G') AND
                                      v~auart IN s_auart AND
                                      v~faksk IN s_faksk AND
                                      v~vkorg IN s_vkorg AND
                                      v~vtweg IN s_vtweg AND
                                      v~spart IN s_spart AND
                                      v~vkgrp IN s_vkgrp AND
                                      v~vkbur IN s_vkbur AND
                                      v~guebg IN s_guebg AND
                                      v~gueen IN s_gueen AND
                                      v~vdatu IN s_vdatu AND
                                      v~mahdt IN s_mahdt AND
                                      v~kunnr IN s_kunnr AND
                                      b~bzirk IN s_bzirk AND
                                      b~inco1 IN s_inco1 AND
                                      b~zterm IN s_zterm AND
                                      b~mschl IN s_mschl AND
                                      b~bstkd IN s_bstkd AND
                                      b~kdkg5 IN s_kdkg5 AND
                                      k~cmgst IN s_cmgst.
    ENDIF.
    IF t_vbak[] IS NOT INITIAL.
      SORT t_vbak BY vbeln ASCENDING .
      DELETE ADJACENT DUPLICATES FROM t_vbak COMPARING vbeln.
      CLEAR wa_zvarb.
      LOOP AT itab_zvarb INTO wa_zvarb WHERE var2 = c_lifsk.
        DELETE t_vbak WHERE ( vbtyp = 'C' OR vbtyp = 'G' ) AND lifsk = wa_zvarb-var3. "
      ENDLOOP.

      CLEAR wa_zvarb.
      LOOP AT itab_zvarb INTO wa_zvarb WHERE var2 = c_faksk.
        DELETE t_vbak WHERE ( vbtyp = 'G' OR vbtyp = 'C' ) AND faksk = wa_zvarb-var3. "
      ENDLOOP.

      IF t_vbak[] IS NOT INITIAL.
        itab_vbak_temp[] = t_vbak[].
        SORT itab_vbak_temp[] BY bzirk.
        DELETE ADJACENT DUPLICATES FROM itab_vbak_temp[] COMPARING bzirk.
        SELECT spras
               bzirk
               bztxt
          FROM t171t
          INTO TABLE itab_t171t
          FOR ALL ENTRIES IN itab_vbak_temp
          WHERE spras = sy-langu
            AND bzirk = itab_vbak_temp-bzirk.
        IF sy-subrc = 0.
          SORT itab_t171t BY bzirk.
        ENDIF.

      ENDIF.

      IF t_vbak[] IS NOT INITIAL.
* Fetching Contract Credit block reason and date
        CLEAR itab_cre_blk[].
        SELECT  vbeln
                zzcre_blk
                zzdate_blk
          FROM  vbak
          INTO TABLE itab_cre_blk
          FOR ALL ENTRIES IN t_vbak
          WHERE ( vbeln = t_vbak-vbeln OR vbeln = t_vbak-vgbel )
            AND vbtyp = c_contract.     " c_contract = G
        IF sy-subrc <> 0.
          CLEAR itab_cre_blk[].
        ENDIF.

        SELECT  vbelv
                  posnv
                  vbeln
                  posnn
                  vbtyp_n
                  rfmng
            FROM vbfa INTO TABLE t_vbfa
             FOR ALL ENTRIES IN t_vbak
           WHERE vbelv = t_vbak-vgbel
                 AND vbtyp_v = t_vbak-vgtyp .

        IF t_vbfa[] IS NOT INITIAL.
          REFRESH itab_vbak1.
          CLEAR wa_vbak1.
          SELECT vbeln
                 vbtyp
                 guebg
                 gueen
                 FROM vbak
                 INTO TABLE itab_vbak1
                 FOR ALL ENTRIES IN t_vbfa
                 WHERE vbeln = t_vbfa-vbelv
                   AND vbtyp = 'G'.
        ENDIF.

        SELECT vbeln kunnr parvw INTO TABLE t_vbpa
                     FROM vbpa
                     FOR ALL ENTRIES IN t_vbak
                     WHERE vbeln EQ t_vbak-vbeln
                       AND kunnr IN s_kunnr2
*                     AND parvw EQ l_const12.                             " Commented
                       AND parvw IN (l_const12, l_const50) . "
        IF sy-subrc NE 0.
          CLEAR t_vbpa.
        ELSE.
          SELECT kunnr name1 stras FROM kna1 INTO TABLE itab_kna1
            FOR ALL ENTRIES IN t_vbpa
            WHERE kunnr = t_vbpa-kunnr.
        ENDIF.
        SELECT vbeln kunnr INTO TABLE t_vbpa1
                     FROM vbpa
                     FOR ALL ENTRIES IN t_vbak
                     WHERE vbeln EQ t_vbak-vbeln
                       AND kunnr IN s_kunnr2
                       AND parvw EQ 'ZA'.
        IF sy-subrc = 0.
          SORT t_vbpa1 BY vbeln.
          SELECT kunnr name1 INTO TABLE  t_kna2
            FROM kna1
            FOR ALL ENTRIES IN t_vbpa1
            WHERE kunnr = t_vbpa1-kunnr.
          IF sy-subrc = 0.
            SORT t_kna2 BY kunnr.
          ENDIF.
        ENDIF.

        IF  t_vbak[] IS NOT INITIAL.
          SELECT kunnr vkorg spart kdgrp eikto klabc
            FROM knvv
            INTO TABLE t_knvv
             FOR ALL ENTRIES IN t_vbak
           WHERE   kunnr EQ t_vbak-kunnr
             AND   vkorg EQ t_vbak-vkorg
             AND ( spart EQ t_vbak-spart OR
                   spart EQ l_const1 )
             AND   kdgrp IN s_kdgrp
             AND   eikto IN s_eikto
             AND   klabc IN s_klabc.
        ENDIF.


        SORT t_knvv BY kunnr ASCENDING
                       vkorg ASCENDING
                       spart ASCENDING.

        IF ( NOT s_eikto[] IS INITIAL ) OR
           ( NOT s_kdgrp[] IS INITIAL ) OR
           ( NOT s_klabc[] IS INITIAL ).

          LOOP AT t_vbak.
            READ TABLE t_knvv WITH KEY kunnr = t_vbak-kunnr
                                       vkorg = t_vbak-vkorg
                                       spart = t_vbak-spart
                                       BINARY SEARCH.
            IF sy-subrc NE 0.

              READ TABLE t_knvv WITH KEY kunnr = t_vbak-kunnr
                                         vkorg = t_vbak-vkorg
                                         spart = l_const1
                                         BINARY SEARCH.
              IF sy-subrc NE 0.
                DELETE t_vbak WHERE vbeln EQ t_vbak-vbeln.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF t_vbak[] IS INITIAL.
          MESSAGE e291(zxunity).
        ENDIF.

        IF t_vbfa[] IS NOT INITIAL.
          SELECT vgbel vgpos matnr lfimg vbeln
            FROM lips INTO TABLE t_lips
             FOR ALL ENTRIES IN t_vbfa
           WHERE vgbel = t_vbfa-vbeln.
        ENDIF.

        IF t_vbak[] IS NOT INITIAL.
          SELECT vbap~vbeln vbap~posnr vbap~matnr vbap~arktx vbap~abgru
              vbap~zmeng vbap~faksp vbap~kwmeng vbap~werks
               vbap~mvgr1 vbap~mvgr3 vbap~mvgr4 vbap~zzrepcc vbap~zzpaidd
            mara~mstav
            mara~matkl
            FROM vbap INNER JOIN mara
            ON vbap~matnr = mara~matnr
            INTO CORRESPONDING FIELDS OF TABLE t_vbap
            FOR ALL ENTRIES IN t_vbak
            WHERE vbap~vbeln  EQ t_vbak-vbeln
              AND vbap~matnr  IN s_matnr
              AND vbap~matkl  IN s_matkl
              AND vbap~kwmeng IN s_kwmeng
              AND vbap~werks  IN s_werks
              AND vbap~abgru  IN s_abgru
              AND vbap~pstyv  NE l_const2
              AND vbap~mvgr3  IN s_mvgr3
              AND mara~magrv  IN s_magrv
              AND mara~mstav  IN s_mstav.
          IF sy-subrc EQ 0.
            SORT t_vbap BY vbeln posnr.
            DELETE ADJACENT DUPLICATES FROM t_vbap COMPARING ALL FIELDS.

            CLEAR wa_zvarb.
            LOOP AT itab_zvarb INTO wa_zvarb WHERE var2 = c_faksp.
              DELETE t_vbap[] WHERE faksp  = wa_zvarb-var3."'98'.            "
            ENDLOOP.
          ENDIF.
        ENDIF.

        IF t_vbap[] IS NOT INITIAL.
          SELECT mvgr4
                 bezei
                 FROM tvm4t
                 INTO TABLE it_desc
                 FOR ALL ENTRIES IN t_vbap
                 WHERE mvgr4 = t_vbap-mvgr4
                 AND spras = sy-langu.

          SORT it_desc BY mvgr4.
        ENDIF.

        IF t_vbap[] IS NOT INITIAL.
          SELECT mvgr3
                 bezei
                 FROM tvm3t
                 INTO TABLE it_desc_emb
                 FOR ALL ENTRIES IN t_vbap
                 WHERE mvgr3 = t_vbap-mvgr3
                   AND spras = sy-langu
            .
          SORT it_desc_emb BY mvgr3.
        ENDIF.



        IF t_vbap[] IS NOT INITIAL.
          SELECT matnr werks FROM marc INTO TABLE t_marc
                             FOR ALL ENTRIES IN t_vbap
                             WHERE matnr = t_vbap-matnr AND
                                   werks = t_vbap-werks AND
                                   disgr IN s_disgr.
        ENDIF.

        IF NOT t_vbap[] IS INITIAL.

          CLEAR wa_zvarb.
*          READ TABLE itab_zvarb INTO wa_zvarb WITH KEY var2 = c_lifsp.
*          IF sy-subrc EQ 0.
*            SELECT vbeln posnr etenr
*            edatu wmeng bmeng lifsp FROM vbep INTO TABLE t_vbep
*                                         FOR ALL ENTRIES IN t_vbap
*                                         WHERE vbeln = t_vbap-vbeln
*                                         AND   posnr = t_vbap-posnr
*                                         AND   lifsp <> wa_zvarb-var3."'90'.
*          ELSE.
          SELECT vbeln posnr etenr
          edatu wmeng bmeng lifsp FROM vbep INTO TABLE t_vbep
                                       FOR ALL ENTRIES IN t_vbap
                                       WHERE vbeln = t_vbap-vbeln
                                       AND   posnr = t_vbap-posnr.
*        ENDIF.

*        ENDIF.

          LOOP AT itab_zvarb INTO wa_zvarb WHERE var2 = c_lifsp.
            DELETE  t_vbep WHERE lifsp = wa_zvarb-var3.
          ENDLOOP.
        ENDIF.


        CALL FUNCTION 'RM_DOMAIN_VALUES_GET'
          EXPORTING
            i_name          = 'KLABC'
            i_langu         = sy-langu
            i_read_texts    = 'X'
          IMPORTING
            e_domain_values = it_data_elements
          EXCEPTIONS
            illegal_input   = 1
            OTHERS          = 2.
        IF sy-subrc <> 0.

        ELSE.
          SORT: it_data_elements  BY domvalue_l.
        ENDIF.


        SELECT * INTO CORRESPONDING FIELDS OF TABLE t_tvgrt
          FROM tvgrt
          FOR ALL ENTRIES IN t_vbak
         WHERE vkgrp =  t_vbak-vkgrp
           AND spras = sy-langu.

        SELECT * INTO CORRESPONDING FIELDS OF TABLE t_t040a
          FROM t040a
          FOR ALL ENTRIES IN t_vbak
          WHERE mschl =  t_vbak-mschl
          AND spras = sy-langu.
      ELSE.
        MESSAGE s100(zxunity).
        LEAVE LIST-PROCESSING.
      ENDIF.
    ELSE.
      MESSAGE s100(zxunity).
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_busca_dados
*&---------------------------------------------------------------------*
*&      Form  F_trata_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_trata_dados.
  DATA: v_so.
  DATA: lv_vbeln TYPE vbak-vbeln.
  DATA: lv_bezei TYPE string.
  IF t_vbak[] IS NOT INITIAL.
    SELECT  objectclas  objectid changenr
               INTO TABLE t_cdpos
               FROM cdpos
               FOR ALL ENTRIES IN t_vbak
               WHERE objectclas EQ 'VERKBELEG'    AND
                     objectid   EQ t_vbak-pedido  AND
                     tabname    EQ 'VBUK'         AND
                     fname      EQ 'CMGST'        AND
                     chngind    EQ 'U'            AND
                     value_new  IN ('A', 'D').
    IF sy-subrc EQ 0.
      SORT t_cdpos BY objectclas objectid ASCENDING.
      DELETE ADJACENT DUPLICATES
              FROM t_cdpos COMPARING objectclas objectid.

      SORT t_cdpos BY changenr DESCENDING
                    objectclas objectid ASCENDING.
      IF t_cdpos[] IS NOT INITIAL.
        SELECT objectclas objectid changenr udate
                       FROM cdhdr INTO TABLE t_cdhdr
                       FOR ALL ENTRIES IN t_cdpos
                       WHERE objectclas EQ t_cdpos-objectclas AND
                             objectid   EQ t_cdpos-objectid   AND
                             changenr   EQ t_cdpos-changenr.
      ENDIF.
      SORT: t_cdhdr BY objectid .
    ENDIF.
  ENDIF.

  IF t_vbak[] IS NOT INITIAL.
    SELECT kunnr name1 ort01  pstlz regio  stras  ort02
            stcd1 stcd2 stcd3 stcd4
              FROM kna1
              INTO TABLE t_kna1
               FOR ALL ENTRIES IN t_vbak
              WHERE kunnr = t_vbak-kunnr.
  ENDIF.
  IF t_vbpa[] IS NOT INITIAL.
    SELECT kunnr name1 ort01 pstlz regio stras  ort02
            stcd1 stcd2 stcd3 stcd4
              FROM kna1
              INTO TABLE t_kna3
              FOR ALL ENTRIES IN t_vbpa
              WHERE kunnr = t_vbpa-kunnr.
  ENDIF.
  SORT t_kna3 BY kunnr.
  SORT t_kna1 BY kunnr.

  SORT: t_vbpa BY vbeln parvw,
        t_marc BY matnr werks.

  SORT: t_vbak BY vbeln,
        t_vbap BY vbeln.

  SORT t_lips BY vgbel vgpos matnr ASCENDING.
  SORT t_vbfa BY vbelv posnv vbtyp_n ASCENDING.
  SORT itab_cre_blk BY vbeln ASCENDING.

  itab_vbfa1[] = t_vbfa[].
  DELETE itab_vbfa1[] WHERE vbtyp <> c_order.
  SORT itab_vbfa1 BY vbelv vbeln.
* fetch all contracts and contract quantity from VBAP
  SELECT vbeln zmeng                                                                               "CHG160438
    FROM vbap
    INTO TABLE itab_vbap
    FOR ALL ENTRIES IN itab_vbfa1
    WHERE vbeln = itab_vbfa1-vbelv.
  IF sy-subrc = 0.
    SORT itab_vbap BY vbeln.
  ENDIF.

* fetch all order types and order quantity from VBAP
  SELECT vbeln kwmeng
    FROM vbap
    INTO TABLE itab_vbap1
    FOR ALL ENTRIES IN itab_vbfa1
    WHERE vbeln = itab_vbfa1-vbeln.
  IF sy-subrc = 0.
    SORT itab_vbap1 BY vbeln.
  ENDIF.

* fetch contracts and their creation date
  SELECT vbeln erdat vbtyp
    FROM vbak
    INTO TABLE itab_vbak2
    FOR ALL ENTRIES IN t_vbak
    WHERE vbeln = t_vbak-vbeln
       OR vbeln = t_vbak-vgbel.
  IF sy-subrc = 0.
    DELETE itab_vbak2[] WHERE vbtyp <> c_contract.
    SORT itab_vbak2 BY vbeln.
  ENDIF.

  LOOP AT t_vbak.

    CLEAR: t_saida, t_vbfa, v_so.
    IF NOT t_vbak-vbeln IS INITIAL.
      CLEAR : lv_name, lv_roteiro.
      lv_name = t_vbak-vbeln.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = 'Z009'
          language                = 'P'
          name                    = lv_name
          object                  = 'VBBK'
          archive_handle          = 0
        TABLES
          lines                   = itab_texto
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.

      IF sy-subrc = 0.
        CLEAR wa_texto.
        LOOP AT itab_texto INTO wa_texto.

          IF sy-tabix > 1.
            CONCATENATE lv_roteiro wa_texto-tdline INTO lv_roteiro SEPARATED BY space.
            REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_roteiro WITH space.
          ELSE.
            lv_roteiro = wa_texto-tdline.
            REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_roteiro WITH space.
          ENDIF.
          CLEAR wa_texto.

        ENDLOOP.
      ENDIF.
    ENDIF.

    READ TABLE t_vbfa WITH KEY vbeln = t_vbak-vbeln.

    IF sy-subrc = 0.

      SELECT SINGLE auart FROM vbak
             INTO t_vbak-auart
               WHERE vbeln = t_vbfa-vbelv.
      IF sy-subrc = 0.
        lv_t1 = lv_t2.
      ENDIF.

      IF t_vbak-auart = l_const13  OR " 'ZCCA' OR
       t_vbak-auart = l_const14 OR" 'ZCCB' OR
       t_vbak-auart = l_const15 OR" 'ZCKB' OR
       t_vbak-auart = l_const16 OR " 'ZCQB' OR
       t_vbak-auart = l_const17 OR" 'ZCQN' OR
       t_vbak-auart = l_const18 OR " 'ZEQB'
       t_vbak-auart = l_const19 OR " 'ZMCO'
       t_vbak-auart = l_const20 OR " 'ZMFA'
       t_vbak-auart = l_const21 OR " 'ZMEX'
       t_vbak-auart = l_const22 OR "  Vago
       t_vbak-auart = l_const23 OR " 'ZCDB'
       t_vbak-auart = l_const24 OR " 'ZCDN'
*Consider new contract type to set doc number
       t_vbak-auart = lv_const25 OR " 'ZUQB'
       t_vbak-auart = lv_const26 OR " 'ZUQN'
       t_vbak-auart = lv_const27 OR "  ZUCA
       t_vbak-auart = lv_const28 OR " 'ZUCB'
       t_vbak-auart = lv_const29 OR " 'ZEUB'
       t_vbak-auart = lv_const30 OR " 'ZUDB'
       t_vbak-auart = lv_const31.   " 'ZUDN'

        t_saida-vbelv = t_vbfa-vbelv.
        t_saida-posnv = t_vbfa-posnv.                                                              "   New
        t_saida-vbeln = t_vbfa-vbeln.

      ENDIF.
      READ TABLE t_vbpa WITH KEY vbeln = t_vbak-vbeln parvw = 'WE' BINARY SEARCH.
      t_saida-kunnr2 = t_vbpa-kunnr.
      READ TABLE t_vbpa1 WITH KEY vbeln = t_vbfa-vbeln BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_saida-kunnr3 = t_vbpa1-kunnr.
        READ TABLE t_kna2 WITH KEY kunnr = t_vbpa1-kunnr BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_saida-agent = t_kna2-agent.
        ENDIF.
      ENDIF.
    ELSE.
      t_saida-v_so = 'X'.
      SELECT SINGLE auart FROM vbak
           INTO t_vbak-auart
             WHERE vbeln = t_vbak-vbeln.
      IF sy-subrc = 0.
        lv_t1 = lv_t2.
      ENDIF.

      IF t_vbak-auart = l_const13  OR " 'ZCCA' OR
       t_vbak-auart = l_const14 OR" 'ZCCB' OR
       t_vbak-auart = l_const15 OR" 'ZCKB' OR
       t_vbak-auart = l_const16 OR " 'ZCQB' OR
       t_vbak-auart = l_const17 OR" 'ZCQN' OR
       t_vbak-auart = l_const18 OR " 'ZEQB'
       t_vbak-auart = l_const19 OR " 'ZMCO'
       t_vbak-auart = l_const20 OR " 'ZMFA'
       t_vbak-auart = l_const21 OR " 'ZMEX'
       t_vbak-auart = l_const22 OR "  Vago
       t_vbak-auart = l_const23 OR " 'ZCDB'
       t_vbak-auart = l_const24 OR " 'ZCDN'
*Consider new contract type to set doc number
       t_vbak-auart = lv_const25 OR " 'ZUQB'
       t_vbak-auart = lv_const26 OR " 'ZUQN'
       t_vbak-auart = lv_const27 OR "  ZUCA
       t_vbak-auart = lv_const28 OR " 'ZUCB'
       t_vbak-auart = lv_const29 OR " 'ZEUB'
       t_vbak-auart = lv_const30 OR " 'ZUDB'
       t_vbak-auart = lv_const31.   " 'ZUDN'

        t_saida-vbelv = t_vbak-vbeln.
        t_saida-vbeln = t_vbak-vbeln.

      ENDIF.
      READ TABLE t_vbpa WITH KEY vbeln = t_vbak-vbeln parvw = 'WE' BINARY SEARCH.
      t_saida-kunnr2 = t_vbpa-kunnr.
      READ TABLE t_vbpa1 WITH KEY vbeln = t_vbak-vbeln BINARY SEARCH.
      IF sy-subrc EQ 0.
        t_saida-kunnr3 = t_vbpa1-kunnr.
        READ TABLE t_kna2 WITH KEY kunnr = t_vbpa1-kunnr BINARY SEARCH.
        IF sy-subrc EQ 0.
          t_saida-agent = t_kna2-agent.
        ENDIF.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING t_vbak TO t_saida.

* To fetch Credit block reason and credit block date
    CLEAR: wa_cre_blk, lv_bezei.
    READ TABLE itab_cre_blk
      INTO wa_cre_blk
      WITH KEY vbeln = t_saida-vbelv
      BINARY SEARCH
      TRANSPORTING  zzcre_blk
                    zzdate_blk.
    IF sy-subrc = 0.
      SELECT SINGLE bezei
        FROM  ztsd_credit_blk
        INTO  lv_bezei
        WHERE spras = sy-langu
          AND abgru = wa_cre_blk-zzcre_blk.
      IF sy-subrc = 0.
        t_saida-zzcre_blk  = lv_bezei.
        t_saida-zzdate_blk = wa_cre_blk-zzdate_blk.
      ENDIF.
    ENDIF.

* To fetch contract creation date
    CLEAR : wa_vbak2.
    READ TABLE itab_vbak2 INTO wa_vbak2 WITH KEY vbeln = t_saida-vbelv.
    IF sy-subrc = 0.
      t_saida-erdat = wa_vbak2-erdat.
    ENDIF.

    MOVE t_vbak-faksk TO t_saida-faksk.
* Get the release status
    IF t_vbak-lifsk = space.
      t_saida-rel = text-t10.
    ELSE.
      t_saida-rel = text-t09.
    ENDIF.

    CLEAR t_knvv.
    READ TABLE t_knvv WITH KEY kunnr = t_vbak-kunnr
                               vkorg = t_vbak-vkorg
                               spart = t_vbak-spart.
    IF sy-subrc NE 0.
      READ TABLE t_knvv WITH KEY kunnr = t_vbak-kunnr
                                 vkorg = t_vbak-vkorg
                                 spart = l_const1
                                 BINARY SEARCH.
    ENDIF.
    CLEAR wa_data_elements.
    READ TABLE  it_data_elements INTO wa_data_elements WITH KEY domvalue_l = t_knvv-klabc.
    IF sy-subrc EQ 0 .
      MOVE: t_knvv-klabc TO t_saida-klabc,
            t_knvv-eikto TO t_saida-eikto,
            t_knvv-kdgrp TO t_saida-kdgrp,
            wa_data_elements-ddtext TO t_saida-ddtext.
    ENDIF .
    READ TABLE t_kna1 WITH KEY kunnr = t_vbak-kunnr.
    IF sy-subrc EQ 0.
      t_saida-name1  = t_kna1-name1.
    ENDIF.
* Get the sales type
    IF t_vbak-vkbur = c_6000 OR t_vbak-vkbur =  c_5926.
      IF t_vbak-vkgrp = c_890 OR t_vbak-vkgrp = c_846.
        t_saida-saltyp = text-t11.
      ELSE.
        IF ( t_saida-name1 CS c_adm_cap  OR  t_saida-name1 CS c_adm_sml ).
          t_saida-saltyp = text-t12.
        ELSE.
          t_saida-saltyp = text-t17.
        ENDIF.
      ENDIF.
    ELSE.
      IF ( t_saida-name1 CS c_adm_cap  OR  t_saida-name1 CS c_adm_sml ).
        t_saida-saltyp = text-t12.
      ELSE.
        t_saida-saltyp = text-t17.
      ENDIF.
    ENDIF.
    READ TABLE t_kna3 WITH KEY kunnr = t_vbpa-kunnr.
    IF sy-subrc = 0.
      t_saida-ort01  = t_kna3-ort01.
      t_saida-regio  = t_kna3-regio.
      t_saida-ort02  = t_kna3-ort02.
      t_saida-stcd1  = t_kna3-stcd1.
      t_saida-stcd2  = t_kna3-stcd2.
      t_saida-stcd3  = t_kna3-stcd3.
      t_saida-stcd4  = t_kna3-stcd4.
      t_saida-pstlz  = t_kna3-pstlz.
      t_saida-stras  = t_kna3-stras.
    ENDIF.
    SELECT SINGLE bezei INTO t_saida-vkburt
     FROM tvkbt
    WHERE vkbur EQ t_saida-vkbur
      AND spras EQ sy-langu.
    IF sy-subrc = 0.
      lv_t1 = lv_t2.
    ENDIF.

    READ TABLE t_tvgrt WITH KEY vkgrp = t_vbak-vkgrp.
    IF sy-subrc = 0.
      MOVE t_tvgrt-vkgrp TO t_saida-vkgrp.
      MOVE t_tvgrt-bezei TO t_saida-vkgrpt.
    ENDIF.

    READ TABLE t_t040a WITH KEY mschl = t_vbak-mschl.
    IF sy-subrc = 0.
      MOVE t_t040a-mschl TO t_saida-mschl.
      MOVE t_t040a-text1 TO t_saida-text1.
    ENDIF.

* Busca a cultura
    READ TABLE t_vbap WITH KEY vbeln = t_vbak-vbeln.
    IF sy-subrc EQ 0.
      IF  t_saida-v_so IS INITIAL.
        LOOP AT t_vbap WHERE vbeln = t_vbfa-vbeln.

          IF NOT s_disgr[] IS INITIAL.

            READ TABLE t_marc WITH KEY matnr = t_vbap-matnr
                                       werks = t_vbap-werks BINARY SEARCH.
            IF sy-subrc NE 0.
              CONTINUE.
            ENDIF.

          ENDIF.

          READ TABLE t_vbep WITH KEY vbeln = t_vbap-vbeln posnr = t_vbap-posnr.
          IF sy-subrc NE 0.
            CONTINUE.
          ENDIF.

          MOVE t_vbap-werks TO t_saida-werks .
          MOVE t_vbap-vbeln TO t_saida-vbeln .
          MOVE t_vbap-posnr TO t_saida-posnr .
          MOVE t_vbap-matnr TO t_saida-matnr .
          MOVE t_vbap-arktx TO t_saida-arktx .
          MOVE t_vbap-faksp TO t_saida-faksp.               "
          MOVE t_vbap-kwmeng TO t_saida-kwmeng .
          MOVE t_vbap-abgru TO t_saida-abgru .
          MOVE t_vbap-mvgr3 TO t_saida-mvgr3.
          MOVE t_vbak-zterm TO t_saida-zterm.
          MOVE t_vbak-bzirk TO t_saida-bzirk.
          CLEAR wa_t171t.
          READ TABLE itab_t171t INTO wa_t171t WITH KEY bzirk = t_saida-bzirk BINARY SEARCH.
          IF sy-subrc = 0.
            t_saida-bzirk1 =  wa_t171t-bztxt.
          ENDIF.
          CLEAR wa_t171t.
          MOVE t_vbak-mschl TO t_saida-mschl.
          MOVE t_vbak-bstkd TO t_saida-bstkd.
          MOVE t_vbap-zzrepcc TO t_saida-zzrepcc.
          MOVE t_vbap-zzpaidd TO t_saida-zzpaidd.
*Get the plant description
          SELECT SINGLE name1
                 FROM   t001w
                 INTO   t_saida-name2
                 WHERE  werks = t_saida-werks.
          IF sy-subrc <> 0.
            CLEAR t_saida-name2 .
          ENDIF.
*Get the sales group
          LOOP AT itab_supply_const INTO wa_const.
            IF wa_const-value CS t_saida-werks.
              t_saida-salgrp = wa_const-field.
              EXIT.
            ENDIF.
          ENDLOOP.

          CLEAR: v_bezei, it_desc.
          READ TABLE it_desc WITH KEY mvgr4 = t_vbap-mvgr4 BINARY SEARCH.
          IF sy-subrc EQ 0.
            CONCATENATE it_desc-mvgr4 '-' it_desc-bezei INTO v_bezei.
            t_saida-bezei = v_bezei.
          ENDIF.

          READ TABLE it_desc_emb WITH KEY mvgr3 = t_vbap-mvgr3 BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_saida-bezei3 = it_desc_emb-bezei.
          ENDIF.

* Busca valor unitário
          SELECT SINGLE kbetr INTO t_saida-kbetr
                          FROM  konv
                          WHERE knumv EQ t_vbak-knumv
                          AND   kposn EQ t_vbap-posnr
            AND   kschl EQ l_const3
            AND   kbetr NE 0.
          IF sy-subrc NE 0.
            SELECT kbetr INTO t_saida-kbetr
                            FROM  konv UP TO 1 ROWS
                            WHERE knumv EQ t_vbak-knumv
                            AND   kposn EQ t_vbap-posnr
              AND   kschl EQ l_const4
              AND   kbetr NE 0.
            ENDSELECT.
          ENDIF.

          CLEAR t_saida-zra0.
          SELECT SINGLE kbetr INTO t_saida-zra0
                          FROM  konv
                          WHERE knumv EQ t_vbak-knumv
                          AND   kposn EQ t_vbap-posnr
            AND   kschl EQ l_const5
            AND   kbetr NE 0.

          IF sy-subrc = 0.

            t_saida-zra0 = t_saida-zra0 / 10.
          ENDIF.

          CLEAR: w_taxa.

*         Busca a taxa do dolar
          SELECT SINGLE kbetr INTO w_taxa
                       FROM konv
                      WHERE knumv EQ t_vbak-knumv
                        AND kposn EQ t_vbap-posnr
                        AND kschl EQ l_const6
                        AND kbetr NE 0.
          IF sy-subrc = 0.
*         Armazena o valor do Dolar.
            t_saida-taxa        = w_taxa.
          ENDIF.
*        Get the  ZFRT value
          CLEAR lv_kbetr.
          SELECT SINGLE kbetr INTO lv_kbetr
                       FROM konv
                      WHERE knumv EQ t_vbak-knumv
                        AND kposn EQ t_vbap-posnr
                        AND kschl EQ l_const49
                        AND kbetr NE 0.
          IF sy-subrc = 0.
            t_saida-freight_br        = lv_kbetr.
          ENDIF.

          IF t_vbak-auart <> l_const7 .
            CLEAR t_vbfa.
            CLEAR t_lips.
            LOOP AT t_lips
              WHERE vgbel = t_vbap-vbeln
                AND vgpos = t_vbap-posnr.
              t_saida-saldo = t_saida-saldo + t_lips-lfimg.
              lv_pending    = t_saida-saldo.
            ENDLOOP.
            IF sy-subrc NE 0.
              LOOP AT t_vbfa
                WHERE vbelv = t_vbap-vbeln
                  AND posnv = t_vbap-posnr.
                IF ( t_vbfa-vbtyp_n NE l_const8 AND t_vbfa-vbtyp_n NE l_const8 ).
                  t_saida-saldo = t_saida-saldo + t_vbfa-rfmng.
                  lv_pending    = t_saida-saldo.
                ENDIF.
                IF ( t_vbfa-vbtyp_n = l_const8 OR t_vbfa-vbtyp_n = l_const8 ).
                  t_saida-saldo = t_saida-saldo - t_vbfa-rfmng.
                  lv_pending    = t_saida-saldo.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ELSE.
            t_saida-saldo  = 0.
          ENDIF.

          t_saida-vlrrem = t_saida-kwmeng - t_saida-saldo.
          lv_pending     = t_saida-vlrrem.
          IF t_saida-saldo < 0.
            t_saida-vlrrem = 0.
            lv_pending = 0.
          ENDIF.
          IF t_vbap-abgru NE ' '.
            CLEAR t_saida-vlrrem.
            lv_pending = 0.
          ENDIF.

          READ TABLE t_cdhdr WITH KEY
                     objectid   = t_vbap-vbeln BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_saida-udate = t_cdhdr-udate.
          ENDIF.
*For new contract set lv_auart field value as X and calcualte real BRL & USD
          CLEAR lv_auart.
          IF t_vbak-auart = lv_const25 OR " 'ZUQB'
             t_vbak-auart = lv_const26 OR " 'ZUQN'
             t_vbak-auart = lv_const27 OR "  ZUCA
             t_vbak-auart = lv_const28 OR " 'ZUCB'
             t_vbak-auart = lv_const29 OR " 'ZEUB'
             t_vbak-auart = lv_const30 OR " 'ZUDB'
             t_vbak-auart = lv_const31.   " 'ZUDN'
            lv_auart = c_x.
          ELSE.
            CLEAR lv_auart.
          ENDIF.
*Only for new contract calculate  real value in BRL and USD with below logic
          IF lv_auart = c_x.
            IF t_vbak-waerk = c_usd.
**  If Documant currency is USD.
              t_saida-valor_dolar = lv_pending * t_saida-kbetr.
              t_saida-valor_real  = t_saida-valor_dolar * t_saida-taxa.
            ELSEIF t_vbak-waerk = 'BRL'.
**  If Documant currency is BRL.
              t_saida-valor_real  = lv_pending * t_saida-kbetr.
              IF t_saida-taxa LE 0.
                t_saida-valor_dolar = 0.
              ELSE.
                t_saida-valor_dolar = t_saida-valor_real / t_saida-taxa.
              ENDIF.
            ENDIF.
          ELSE.
            IF t_vbak-waerk = c_usd.
**  If Documant currency is USD.
              t_saida-valor_real  = t_saida-valor_dolar * t_saida-taxa.
            ELSEIF t_vbak-waerk = 'BRL'.
**  If Documant currency is BRL.
              t_saida-valor_real  = lv_pending * t_saida-kbetr.
              IF t_saida-taxa LE 0.
                t_saida-valor_dolar = 0.
              ELSE.
                t_saida-valor_dolar = t_saida-valor_real / t_saida-taxa.
              ENDIF.
            ENDIF.
          ENDIF.
          "Customer structure
          CLEAR wa_zvar.
          READ TABLE itab_zvar INTO wa_zvar WITH KEY var1 = c_palantir
                                                     var2 = t_saida-kdgrp
                                                     var3 = t_saida-klabc.
          IF sy-subrc EQ 0.
            t_saida-custs = wa_zvar-descr.
          ELSE.
            t_saida-custs = 'Não foco'(213).
          ENDIF.
          t_saida-roteiro = lv_roteiro.                     "
          CLEAR : lv_objek, wa_ausp.                        "
          CLEAR wa_zvar.
          READ TABLE itab_zvarc INTO wa_zvar WITH KEY var1 = c_chg1 description = 'ELO_MVGR3' var2 = t_saida-mvgr3.
          IF sy-subrc = 0.
            IF wa_zvar-var3 = c_atwrt1.                    "
              t_saida-pgrp = c_value1.                      "
            ELSEIF wa_zvar-var3 = c_atwrt2.                "
              t_saida-pgrp = c_value2.                      "
            ELSE.                                           "
              t_saida-pgrp = c_value3.                      "
            ENDIF.                                          "
          ENDIF.
*          lv_objek = t_saida-matnr.                         "
*          READ TABLE itab_ausp INTO wa_ausp WITH KEY objek = lv_objek. "
*          IF sy-subrc = 0.                                  "
*            IF wa_ausp-atwrt = c_atwrt1.                    "
*              t_saida-pgrp = c_value1.                      "
*            ELSEIF wa_ausp-atwrt = c_atwrt2.                "
*              t_saida-pgrp = c_value2.                      "
*            ELSE.                                           "
*              t_saida-pgrp = c_value3.                      "
*            ENDIF.                                          "
*          ENDIF.                                            "
          IF t_vbak-vbtyp = 'G'.                            "
            t_saida-posnv = t_vbap-posnr.                   "
          ELSEIF t_vbak-vbtyp = 'C'.                        "
            t_saida-posnr = t_vbap-posnr.                   "
          ENDIF.                                            "
          APPEND t_saida.
          CLEAR: t_saida-vlrrem, t_saida-saldo,
                 lv_pending.
        ENDLOOP.
      ELSE.
        MOVE t_vbfa[] TO taux_vbfa[].
        DELETE taux_vbfa WHERE  vbtyp_n NE 'C'.
        DELETE taux_vbfa WHERE  rfmng LT 1.
        LOOP AT t_vbap WHERE vbeln = t_vbak-vbeln.

*          READ TABLE t_vbep WITH KEY vbeln = t_vbap-vbeln posnr = t_vbap-posnr.
*          IF sy-subrc NE 0.
*            CONTINUE.
*          ENDIF.

          READ TABLE taux_vbfa WITH KEY vbelv = t_vbak-vbeln posnv = t_vbap-posnr.
          IF sy-subrc IS NOT INITIAL.
            lv_vbeln = t_vbak-vbeln.
            " Check if the Contract has orders created
            READ TABLE t_vbak INTO wa_vbak3
              WITH KEY vgbel = lv_vbeln.
            IF sy-subrc = 0.
              CLEAR wa_vbak3.
            ELSE.
              " If orders are not created, then display the line item with blank order number.
              IF NOT s_disgr[] IS INITIAL.

                READ TABLE t_marc WITH KEY matnr = t_vbap-matnr
                                           werks = t_vbap-werks BINARY SEARCH.
                IF sy-subrc NE 0.
                  CONTINUE.
                ENDIF.

              ENDIF.

              MOVE t_vbap-werks TO t_saida-werks .
              MOVE t_vbap-vbeln TO t_saida-vbeln .
              MOVE t_vbap-posnr TO t_saida-posnr .
              MOVE t_vbap-matnr TO t_saida-matnr .
              MOVE t_vbap-arktx TO t_saida-arktx .
              MOVE t_vbap-faksp TO t_saida-faksp.           "
              MOVE  t_vbap-zmeng TO t_saida-kwmeng.
              MOVE t_vbap-abgru TO t_saida-abgru .
              MOVE t_vbap-mvgr3 TO t_saida-mvgr3.
              MOVE t_vbak-zterm TO t_saida-zterm.
              MOVE t_vbak-bzirk TO t_saida-bzirk.
              CLEAR wa_t171t.
              READ TABLE itab_t171t INTO wa_t171t WITH KEY bzirk = t_saida-bzirk BINARY SEARCH.
              IF sy-subrc = 0.
                t_saida-bzirk1 =  wa_t171t-bztxt.
              ENDIF.
              CLEAR wa_t171t.
              MOVE t_vbak-mschl TO t_saida-mschl.
              MOVE t_vbak-bstkd TO t_saida-bstkd.
              MOVE t_vbap-zzrepcc TO t_saida-zzrepcc.
              MOVE t_vbap-zzpaidd TO t_saida-zzpaidd.
* Get the plant description
              SELECT SINGLE name1
                     FROM   t001w
                     INTO   t_saida-name2
                     WHERE  werks = t_saida-werks.
              IF sy-subrc <> 0.
                CLEAR t_saida-name2 .
              ENDIF.
* Get the sales group
              LOOP AT itab_supply_const INTO wa_const.
                IF wa_const-value CS t_saida-werks.
                  t_saida-salgrp = wa_const-field.
                  EXIT.
                ENDIF.
              ENDLOOP.
              CLEAR: v_bezei, it_desc.
              READ TABLE it_desc WITH KEY mvgr4 = t_vbap-mvgr4 BINARY SEARCH.
              IF sy-subrc EQ 0.
                CONCATENATE it_desc-mvgr4 '-' it_desc-bezei INTO v_bezei.
                t_saida-bezei = v_bezei.
              ENDIF.

              READ TABLE it_desc_emb WITH KEY mvgr3 = t_vbap-mvgr3 BINARY SEARCH.
              IF sy-subrc EQ 0.
                t_saida-bezei3 = it_desc_emb-bezei.
              ENDIF.

* Busca valor unitário
              SELECT SINGLE kbetr INTO t_saida-kbetr
                              FROM  konv
                              WHERE knumv EQ t_vbak-knumv
                              AND   kposn EQ t_vbap-posnr
                AND   kschl EQ l_const3
                AND   kbetr NE 0.
              IF sy-subrc NE 0.
                SELECT kbetr INTO t_saida-kbetr
                                FROM  konv UP TO 1 ROWS
                                WHERE knumv EQ t_vbak-knumv
                                AND   kposn EQ t_vbap-posnr
                  AND   kschl EQ l_const4
                  AND   kbetr NE 0.
                ENDSELECT.
              ENDIF.

              CLEAR t_saida-zra0.
              SELECT SINGLE kbetr INTO t_saida-zra0
                              FROM  konv
                              WHERE knumv EQ t_vbak-knumv
                              AND   kposn EQ t_vbap-posnr
                AND   kschl EQ l_const5
                AND   kbetr NE 0.
              IF sy-subrc = 0.
                t_saida-zra0 = t_saida-zra0 / 10.
              ENDIF.
              CLEAR: w_taxa.

*         Busca a taxa do dolar
              SELECT SINGLE kbetr INTO w_taxa
                           FROM konv
                          WHERE knumv EQ t_vbak-knumv
                            AND kposn EQ t_vbap-posnr
                            AND kschl EQ l_const6
                            AND kbetr NE 0.

              IF sy-subrc = 0.
*         Armazena o valor do Dolar.
                t_saida-taxa        = w_taxa.
              ENDIF.
              t_saida-saldo = t_saida-kwmeng - t_saida-vlrrem.
              IF t_saida-saldo < 0.
                t_saida-saldo = 0.
              ENDIF.
              IF t_vbap-abgru NE ' '.
                CLEAR t_saida-saldo.
              ENDIF.

              READ TABLE t_cdhdr WITH KEY
                         objectid   = t_vbap-vbeln BINARY SEARCH.
              IF sy-subrc EQ 0.
                t_saida-udate = t_cdhdr-udate.
              ENDIF.
*For new contract set lv_auart field value as X and calcualte real BRL & USD
              CLEAR lv_auart.
              IF t_vbak-auart = lv_const25 OR " 'ZUQB'
                 t_vbak-auart = lv_const26 OR " 'ZUQN'
                 t_vbak-auart = lv_const27 OR "  ZUCA
                 t_vbak-auart = lv_const28 OR " 'ZUCB'
                 t_vbak-auart = lv_const29 OR " 'ZEUB'
                 t_vbak-auart = lv_const30 OR " 'ZUDB'
                 t_vbak-auart = lv_const31.   " 'ZUDN'
                lv_auart = c_x.
              ELSE.
                CLEAR lv_auart.
              ENDIF.

              t_saida-valor_real = t_saida-saldo * t_saida-kbetr.
              IF lv_auart = c_x. "For new contract change real & USD logic
*IF currency type is USD mutliply real value with taxa
                IF t_vbak-waerk = c_usd.
                  t_saida-valor_real = t_saida-valor_real * t_saida-taxa.
                ENDIF.
                t_saida-valor_dolar = t_saida-saldo * t_saida-kbetr.
**IF currency type is BRL  divide dolar value with taxa
                IF t_vbak-waerk = c_brl.
                  CATCH SYSTEM-EXCEPTIONS arithmetic_errors = 4.
                    t_saida-valor_dolar = t_saida-valor_dolar / t_saida-taxa.
                  ENDCATCH.
                ENDIF.
              ELSE."For old contract keep the old logic as same
                t_saida-valor_dolar = t_saida-saldo * t_saida-kbetr.
**IF currency type is BRL  divide dolar value with taxa
                IF t_vbak-waerk = c_brl.
                  CATCH SYSTEM-EXCEPTIONS arithmetic_errors = 4.
                    t_saida-valor_dolar = t_saida-valor_dolar / t_saida-taxa.
                  ENDCATCH.
                ENDIF.
              ENDIF.
              "Customer structure
              READ TABLE itab_zvar INTO wa_zvar WITH KEY var1 = c_palantir
                                                         var2 = t_saida-kdgrp
                                                         var3 = t_saida-klabc.
              IF sy-subrc EQ 0.
                t_saida-custs = wa_zvar-descr.
              ELSE.
                t_saida-custs = 'Não foco'(213).
              ENDIF.

*        Get the  ZFRT value
              CLEAR lv_kbetr.
              SELECT SINGLE kbetr INTO lv_kbetr
                           FROM konv
                          WHERE knumv EQ t_vbak-knumv
                            AND kposn EQ t_vbap-posnr
                            AND kschl EQ l_const49
                            AND kbetr NE 0.
              IF sy-subrc = 0.
                t_saida-freight_br        = lv_kbetr.
              ENDIF.

              t_saida-roteiro = lv_roteiro.                 "
              CLEAR : lv_objek, wa_ausp.                    "
              CLEAR wa_zvar.
              READ TABLE itab_zvarc INTO wa_zvar WITH KEY var1 = c_chg1 description = 'ELO_MVGR3' var2 = t_saida-mvgr3.
              IF sy-subrc = 0.
                IF wa_zvar-var3 = c_atwrt1.                    "
                  t_saida-pgrp = c_value1.                      "
                ELSEIF wa_zvar-var3 = c_atwrt2.                "
                  t_saida-pgrp = c_value2.                      "
                ELSE.                                           "
                  t_saida-pgrp = c_value3.                      "
                ENDIF.                                          "
              ENDIF.
*              lv_objek = t_saida-matnr.                     "
*              READ TABLE itab_ausp INTO wa_ausp WITH KEY objek = lv_objek. "
*              IF sy-subrc = 0.                              "
*                IF wa_ausp-atwrt = c_atwrt1.                "
*                  t_saida-pgrp = c_value1.                  "
*                ELSEIF wa_ausp-atwrt = c_atwrt2.            "
*                  t_saida-pgrp = c_value2.                  "
*                ELSE.                                       "
*                  t_saida-pgrp = c_value3.                  "
*                ENDIF.                                      "
*              ENDIF.                                        "
              IF t_vbak-vbtyp = 'G'.                        "
                t_saida-posnv = t_vbap-posnr.               "
              ELSEIF t_vbak-vbtyp = 'C'.                    "
                t_saida-posnr = t_vbap-posnr.               "
              ENDIF.                                        "
              IF t_saida-posnv IS INITIAL.
                IF NOT t_saida-posnr IS INITIAL  .
                  IF NOT t_saida-vbeln  IS  INITIAL.
                    READ TABLE t_vbfa WITH KEY vbeln = t_saida-vbeln posnn = t_saida-posnr.
                    IF sy-subrc = 0.
                      t_saida-posnv = t_vbfa-posnv.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.

              APPEND t_saida.
              CLEAR: t_saida-vlrrem, t_saida-saldo.
            ENDIF.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDIF.                                                                                         "CHG160438
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM t_saida.
ENDFORM.                    " F_trata_dados
*&---------------------------------------------------------------------*
*&      Form  f_imprime
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_imprime.


  DATA: lv_quan TYPE vbap-kwmeng.
  DATA : lv_rfstk TYPE rfstk.
  LOOP AT t_vbfa.
    MOVE-CORRESPONDING t_vbfa TO lvbfa.
    APPEND lvbfa TO t_vbfa_new.
  ENDLOOP.
  IF t_vbap[] IS NOT INITIAL.
    SELECT * FROM vbup INTO TABLE t_vbup
      FOR ALL ENTRIES IN t_vbap
      WHERE vbeln = t_vbap-vbeln
      AND posnr = t_vbap-posnr.
    IF sy-subrc EQ 0.
      SORT t_vbup BY vbeln posnr.
      DELETE ADJACENT DUPLICATES FROM t_vbup COMPARING vbeln.
    ENDIF.
  ENDIF.

  LOOP AT t_vbap.
    MOVE-CORRESPONDING t_vbap TO lvbap.
    APPEND lvbap TO t_vbap_new.
  ENDLOOP.

  LOOP AT t_vbep.
    MOVE-CORRESPONDING t_vbap TO lvbep.
    APPEND lvbep TO t_vbep_new.
  ENDLOOP.

  IF p_path NE space OR p_email NE space.
** Cabeçalho do Arquivo excel.
    PERFORM cabec_excel.
  ENDIF.

  SORT t_saida BY werks vbelv vbeln kunnr inco1 vkbur vkgrp kunnr2.
  SORT t_vbep BY vbeln posnr.
  IF t_saida[] IS NOT INITIAL.
    SELECT * FROM vbak
                 INTO TABLE xvbak
                 FOR ALL ENTRIES IN t_saida
                             WHERE  vbeln  EQ t_saida-vbeln
                               AND   vkorg IN s_vkorg .
    IF sy-subrc = 0.

      SELECT DISTINCT mandt vbeln posnr kwmeng kbmeng matnr arktx netwr
                                      lprio vstel route FROM  vbap
         INTO CORRESPONDING FIELDS OF TABLE xvbap
        FOR ALL ENTRIES IN xvbak
              WHERE  vbeln  EQ xvbak-vbeln.

      IF xvbap[] IS NOT INITIAL.

        SELECT * FROM  vbup INTO TABLE xxvbup
                    FOR ALL ENTRIES IN xvbap
                    WHERE  vbeln  = xvbap-vbeln
                    AND    posnr  = xvbap-posnr.

        SELECT * FROM  vbfa INTO TABLE xxvbfa
                    FOR ALL ENTRIES IN xvbap
                    WHERE  vbelv    = xvbap-vbeln
                    AND    posnv    = xvbap-posnr
                    AND    vbtyp_n  = l_const10 .

        SELECT vbeln posnr inco1 FROM  vbkd INTO TABLE xxvbkd
                    FOR ALL ENTRIES IN xvbap
                    WHERE  vbeln  =  xvbap-vbeln
                    AND    posnr  =  xvbap-posnr.

        SELECT * FROM  vbep INTO TABLE xxvbep
                    FOR ALL ENTRIES IN xvbap
                    WHERE  vbeln  =  xvbap-vbeln
                    AND    posnr  =  xvbap-posnr
                    AND    bmeng  > 0.
      ENDIF.
    ENDIF.
  ENDIF.
********************************
  DELETE t_saida WHERE kunnr2 IS INITIAL.
  IF p_rad1 EQ 'X'.
    SORT t_saida BY werks vbelv vbeln posnr  vkbur.
  ELSEIF p_rad2 EQ 'X'.
    SORT t_saida BY vkbur vbelv vbeln posnr  werks.
  ENDIF.
  SORT t_vbep BY vbeln posnr etenr.
  DATA: v_vbelv TYPE vbelv,
        v_werks TYPE werks,
        v_vkbur TYPE vkbur,
        v_vbeln TYPE vbeln,
        v_kwmeng TYPE kwmeng,
        v_vlrrem TYPE kwmeng,
        v_saldo TYPE saldo,
        v_valor_real TYPE kawrt.

  DATA: lv_bukrs TYPE bkpf-bukrs,
        lv_bukrs_t TYPE bukrs,
        lv_bschl_t TYPE bschl,
        lv_waers_t TYPE waers,
        lv_auart_t TYPE auart,
        lv_belnr TYPE belnr_d,
        lv_kursf TYPE kursf,
        lv_vbelv TYPE vbelv,
        lv_vbeln TYPE vbeln,
        lv_auart TYPE auart,
        lv_kurrf TYPE kurrf,
        lv_zzcust_po TYPE zd_cust_po,
        lv_zzcust_po_item TYPE zd_cust_po_item,
        lv_kunnr TYPE kunnr,
        lv_txjcd TYPE txjcd.

  CONSTANTS: c_bukrs TYPE char5 VALUE 'BUKRS',
             c_bschl TYPE char5 VALUE 'BSCHL',
             c_waers TYPE char5 VALUE 'WAERS',
             c_auart TYPE char5 VALUE 'ZEUB',
             c_10    TYPE char2 VALUE '10'.

  FIELD-SYMBOLS: <fs_saida> LIKE t_saida,
                 <wa_excel> LIKE LINE OF t_excel.

  REFRESH taux_saida.
  CLEAR taux_saida.
  MOVE t_saida[] TO taux_saida[].
  SELECT SINGLE mstav
           FROM mara
           INTO e_saida-mstav
           WHERE matnr = e_saida-matnr.
  IF sy-subrc = 0.
    lv_t1 = lv_t2.
  ENDIF.
  IF t_saida[] IS NOT INITIAL.
    SELECT  vbeln posnr omeng
      FROM vbbe
      INTO TABLE itab_vbbe
      FOR ALL ENTRIES IN t_saida
      WHERE vbeln = t_saida-vbeln
      AND   posnr = t_saida-posnr.
    IF sy-subrc EQ 0.
      SORT itab_vbbe BY vbeln.
      DELETE ADJACENT DUPLICATES FROM itab_vbbe COMPARING vbeln.
    ENDIF.
    SELECT matnr mstav
      FROM mara
      INTO TABLE itab_mara
      FOR ALL ENTRIES IN t_saida
      WHERE matnr = t_saida-matnr.
    IF sy-subrc EQ 0.
      SORT itab_mara BY matnr.
      DELETE ADJACENT DUPLICATES FROM itab_mara COMPARING matnr.
    ENDIF.
  ENDIF.

  SORT t_vbep ASCENDING BY vbeln posnr.

* Fetching ZVAR entries:
  CLEAR: itab_zvari, lv_bukrs_t, lv_bschl_t, lv_waers_t.
  SELECT DISTINCT var1 description var2 var3
    FROM zvar
    INTO TABLE itab_zvari
    WHERE var1 = c_zsdr3002.
  IF sy-subrc = 0.
    CLEAR wa_zvari.
*     Fetching BUKRS.
    READ TABLE itab_zvari INTO wa_zvari
      WITH KEY var1 = c_zsdr3002
               var2 = c_bukrs.
    IF sy-subrc   = 0.
      lv_bukrs_t  = wa_zvari-var3.
    ENDIF.
    CLEAR wa_zvari.
*     Fetching BSCHL.
    READ TABLE itab_zvari INTO wa_zvari
      WITH KEY var1 = c_zsdr3002
               var2 = c_bschl.
    IF sy-subrc   = 0.
      lv_bschl_t  = wa_zvari-var3.
    ENDIF.
    CLEAR wa_zvari.
*     Fetching WAERS.
    READ TABLE itab_zvari INTO wa_zvari
      WITH KEY var1 = c_zsdr3002
               var2 = c_waers.
    IF sy-subrc   = 0.
      lv_waers_t  = wa_zvari-var3.
    ENDIF.
    CLEAR wa_zvari.
*     Fetching AUART.
    READ TABLE itab_zvari INTO wa_zvari
      WITH KEY var1 = c_zsdr3002
               var2 = c_auart.
    IF sy-subrc   = 0.
      lv_auart_t  = wa_zvari-var3.
    ENDIF.
  ENDIF.
  CLEAR: wa_zvari.
  LOOP AT t_saida ASSIGNING <fs_saida>.
*    Getting Fixed USD Rate
    IF NOT <fs_saida>-vbelv IS INITIAL.
      SELECT SINGLE bukrs belnr
        FROM bsid
        INTO (lv_bukrs,lv_belnr)
        WHERE bukrs = lv_bukrs_t
          AND zuonr = <fs_saida>-vbelv
          AND bschl = lv_bschl_t
          AND waers = lv_waers_t.
      IF sy-subrc = 0.
        SELECT SINGLE bukrs kursf       "exchange rate
          FROM bkpf
          INTO (lv_bukrs,lv_kursf)
          WHERE bukrs = lv_bukrs_t
            AND belnr = lv_belnr.
        IF sy-subrc = 0.
          <fs_saida>-zexrate = lv_kursf.
        ELSE.
*             Check for Document Type
          CLEAR <fs_saida>-zexrate.
        ENDIF.
      ELSE.
        CLEAR <fs_saida>-zexrate.
        SELECT SINGLE vbeln auart
        FROM vbak
        INTO (lv_vbeln,lv_auart)
        WHERE vbeln = <fs_saida>-vbelv.
        IF sy-subrc = 0.
*              Fetch data from VBKD
          CLEAR: lv_vbeln, lv_kurrf.
          SELECT SINGLE vbeln kurrf       "exchange rate
            FROM vbkd
            INTO (lv_vbeln,lv_kurrf)
            WHERE vbeln = <fs_saida>-vbelv
              AND posnr = c_10.
          IF sy-subrc = 0.
            <fs_saida>-zexrate = lv_kurrf.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR: lv_bukrs,
           lv_belnr,
           lv_kursf.
*   Calculating VLR based on above rate.
    <fs_saida>-zvalorunit = <fs_saida>-kbetr * <fs_saida>-zexrate.

*   Getting Tax Jurisdiction Code
    SELECT SINGLE kunnr txjcd
      FROM kna1
      INTO (lv_kunnr,lv_txjcd)
      WHERE kunnr = <fs_saida>-kunnr2.
    IF sy-subrc = 0.
      <fs_saida>-ztaxzur = lv_txjcd.
    ELSE.
      CLEAR <fs_saida>-ztaxzur.
    ENDIF.

*   Getting PO Number
    SELECT SINGLE vbeln zzcust_po
      FROM vbak
      INTO (lv_vbeln,lv_zzcust_po)
      WHERE vbeln = <fs_saida>-vbelv.
    IF sy-subrc = 0.
      <fs_saida>-zzcust_po = lv_zzcust_po.
    ELSE.
      CLEAR <fs_saida>-zzcust_po.
    ENDIF.

*   Getting PO Item
    SELECT SINGLE vbeln zzcust_po_item
      FROM vbap
      INTO (lv_vbeln,lv_zzcust_po_item)
      WHERE vbeln = <fs_saida>-vbelv.
    IF sy-subrc = 0.
      <fs_saida>-zzcust_po_item = lv_zzcust_po_item.
    ELSE.
      CLEAR <fs_saida>-zzcust_po_item.
    ENDIF.

  ENDLOOP.


  LOOP AT t_saida.
    CLEAR : remqty, lipsqty, vbepqty, v_vlrrem.
    vl_tabix = sy-tabix.
    e_saida  = t_saida.
    SELECT SINGLE rfstk INTO lv_rfstk FROM vbuk WHERE vbeln = e_saida-vbeln.
    IF sy-subrc = 0.
      READ TABLE itab_zvarf INTO wa_zvarf WITH KEY var3 = lv_rfstk.
      IF sy-subrc = 0.
        remqty = e_saida-kwmeng.
      ENDIF.
    ENDIF.
    IF remqty IS INITIAL.
      remqty =  e_saida-kwmeng - e_saida-saldo.
    ENDIF.
    IF remqty GT 0.
      IF e_saida-vbelv IS NOT INITIAL OR e_saida-v_so IS NOT INITIAL .
        CLEAR : wa_vbbe.
        READ TABLE itab_vbbe INTO wa_vbbe WITH KEY
                          vbeln = e_saida-vbeln
                          posnr = e_saida-posnr.
        IF sy-subrc EQ 0.
          e_saida-omeng = wa_vbbe-omeng.
        ENDIF.
        CLEAR : wa_mara.
        READ TABLE itab_mara INTO wa_mara
                          WITH KEY matnr = e_saida-matnr BINARY SEARCH.
        IF sy-subrc EQ 0.
          e_saida-mstav = wa_mara-mstav.
        ENDIF.

        e_saida-zzpaidd = t_saida-zzpaidd.
        e_saida-zzrepcc = t_saida-zzrepcc.


        SELECT SINGLE vtext FROM tvkggt
             INTO v_vtext
              WHERE kdkgr = e_saida-kdkg5
            AND spras = sy-langu.
        IF sy-subrc = 0.
          MOVE v_vtext TO t_excel-cont_status.
        ENDIF.
        MOVE e_saida-vbeln TO t_excel-ordem.
        MOVE e_saida-vbelv TO t_excel-contract_no.
        MOVE e_saida-posnv TO t_excel-zitemno1.
        IF  t_excel-zitemno1 = 0.
          READ TABLE t_vbfa WITH KEY vbeln = e_saida-vbeln posnn = e_saida-posnr.
          IF sy-subrc = 0.
            t_excel-zitemno1 = t_vbfa-posnv.
          ENDIF.
        ENDIF.                    "   New
        MOVE e_saida-auart TO t_excel-contract_type.
        MOVE e_saida-mstav TO t_excel-mstav.
        MOVE: e_saida-faksk    TO t_excel-blpgto,
              e_saida-cmgst    TO t_excel-blcred,
              e_saida-eikto    TO t_excel-eikto,
              e_saida-kdgrp    TO t_excel-kdgrp,
              e_saida-bstkd    TO t_excel-bstkd,
              e_saida-bzirk    TO t_excel-bzirk,
              e_saida-bzirk1   TO t_excel-bzirk1,
              e_saida-zterm    TO t_excel-zterm,
              e_saida-vkorg    TO t_excel-vkorg.
*              e_saida-custs    TO t_excel-custs.

        MOVE: e_saida-zzrepcc TO t_excel-zzrepcc,
              e_saida-zzpaidd TO t_excel-zzpaidd,
              e_saida-waerk   TO t_excel-waerk.
        CONCATENATE t_excel-zzpaidd+6(2) '/' t_excel-zzpaidd+4(2) '/'  t_excel-zzpaidd(4) INTO t_excel-zzpaidd.
* Add plant desc,release,sales type and sales group
        t_excel-name2   =  e_saida-name2 .
        t_excel-rel     =  e_saida-rel   .
        t_excel-saltyp  =  e_saida-saltyp.
        t_excel-salgrp  =  e_saida-salgrp.
        "   New
*     Moving values to new fields as well                                       "   New
        MOVE : e_saida-vkbur   TO t_excel-vkbur,                                  "   New
               e_saida-vkburt  TO t_excel-vkburt,                                 "   New
               e_saida-vkgrp   TO t_excel-vkgrp,                                  "   New
               e_saida-vkgrpt  TO t_excel-vkgrpt,                                 "   New
               e_saida-kunnr2  TO t_excel-kunnr,                                  "   New
               e_saida-agent   TO t_excel-name1,                                  "   New
               e_saida-mvgr3   TO t_excel-mvgr3,                                  "   New
               e_saida-bezei3  TO t_excel-mvgr3t,                                 "   New
               e_saida-klabc   TO t_excel-klabc1,                                 "   New
               e_saida-ddtext  TO t_excel-klabc1t,                                "   New
               e_saida-mschl   TO t_excel-mschl1,                                 "   New
               e_saida-text1   TO t_excel-mschl1t,                                "   New
               e_saida-lifsp   TO t_excel-lifsp,                                  "   New
               e_saida-faksp   TO t_excel-faksp,                                  "   New
               e_saida-freight_br TO t_excel-freight,                             "   New
               e_saida-pgrp       TO t_excel-pgrp,                                "   New
               e_saida-roteiro TO t_excel-troto.                                  "   New
        REPLACE ALL OCCURENCES OF '#' IN t_excel-troto WITH ` `.
        SPLIT e_saida-bezei  AT '-' INTO t_excel-mvgr4  t_excel-mvgr4t.    "   New
        "   New
        READ TABLE t_vbpa WITH KEY vbeln = t_excel-ordem parvw = 'RG' BINARY SEARCH.     "   New
        IF sy-subrc = 0.                                                   "   New
          t_excel-kunnr4 = t_vbpa-kunnr.                                   "   New
          CLEAR wa_kna1.                                                   "   New
          READ TABLE itab_kna1 INTO wa_kna1 WITH KEY kunnr = t_vbpa-kunnr. "   New
          IF sy-subrc = 0 .                                                "   New
            t_excel-parvwt = wa_kna1-name1.                                "   New
            t_excel-kunnr4_ad = wa_kna1-stras.                             "   New
          ENDIF.                                                           "   New
        ENDIF.                                                             "   New
                        "
        CONCATENATE t_excel-data lv_time INTO t_excel-data." SEPARATED BY space. "
                              "
        CONCATENATE lv_date lv_time1 INTO t_excel-version." SEPARATED BY ''.  "  .
        "   New

        CLEAR wa_vbak.
        READ TABLE t_vbak INTO wa_vbak WITH KEY vbeln = e_saida-vbelv
                                               vbtyp = 'G'.
        IF sy-subrc = 0.
          e_saida-guebg = wa_vbak-guebg.
          e_saida-gueen = wa_vbak-gueen.
        ELSE.
          CLEAR wa_vbak1.
          READ TABLE itab_vbak1 INTO wa_vbak1 WITH KEY vbeln = e_saida-vbelv
                                                       vbtyp = 'G'.
          IF sy-subrc = 0.
            e_saida-guebg = wa_vbak1-guebg.
            e_saida-gueen = wa_vbak1-gueen.
          ENDIF.
        ENDIF.
        IF e_saida-guebg IS NOT INITIAL.
          CONCATENATE e_saida-guebg+6(2) '/' e_saida-guebg+4(2) '/'  e_saida-guebg(4) INTO t_excel-dini.
        ENDIF.
        IF e_saida-gueen IS NOT INITIAL.
          CONCATENATE e_saida-gueen+6(2) '/' e_saida-gueen+4(2) '/'  e_saida-gueen(4) INTO t_excel-dfim.
        ENDIF.

        IF p_rad1 EQ 'X'.
          IF  v_werks NE e_saida-werks .
            SELECT SINGLE name1 FROM t001w INTO t001w-name1
                                   WHERE werks = e_saida-werks.
            IF sy-subrc = 0.
              lv_t1 = lv_t2.
            ENDIF.
            WRITE: /01 'Centro:'(107), e_saida-werks, ' - ', t001w-name1.  " PLant
            SKIP.
            v_werks =  e_saida-werks.
            v_vbelv = ''.
            v_vbeln = ''.
          ENDIF.
        ELSEIF p_rad2 EQ 'X'.
          IF  v_vkbur NE e_saida-vkbur .
            WRITE: /01 'Filial:'(111),  e_saida-vkbur, '-',e_saida-vkburt.  " PLant
            SKIP.
            v_vkbur =  e_saida-vkbur.
          ENDIF.
        ENDIF.
        IF v_vbelv NE e_saida-vbelv.
          v_vbelv = e_saida-vbelv.


          CLEAR: out_zzrepcc, zzrepcc_filled, out_zzpaidd, zzpaidd_filled.
          LOOP AT t_vbap WHERE vbeln = e_saida-vbelv.
            IF e_saida-zzrepcc IS INITIAL.
              IF zzrepcc_filled IS INITIAL AND t_vbap-zzrepcc IS NOT INITIAL.
                out_zzrepcc = t_vbap-zzrepcc.
                zzrepcc_filled = 'X'.
              ENDIF.
            ELSE.
              IF zzrepcc_filled IS INITIAL.
                out_zzrepcc = e_saida-zzrepcc.
                zzrepcc_filled = 'X'.
              ENDIF.
            ENDIF.

            IF e_saida-zzpaidd IS INITIAL.
              IF zzpaidd_filled IS INITIAL AND t_vbap-zzpaidd IS NOT INITIAL.
                out_zzpaidd = t_vbap-zzpaidd.
                zzpaidd_filled = 'X'.
              ENDIF.
            ELSE.
              IF zzpaidd_filled IS INITIAL.
                out_zzpaidd = e_saida-zzpaidd.
                zzpaidd_filled = 'X'.
              ENDIF.
            ENDIF.
          ENDLOOP.

          FORMAT COLOR 1 INTENSIFIED ON.
          WRITE: /01 'Numero do Contrato:'(098), e_saida-vbelv HOTSPOT,
                 60 'Número PO:'(150), e_saida-bstkd,
                 95 'Tipo de Contrato:'(097), e_saida-auart, "65
                 155 'Status do Contrato:'(100), t_excel-cont_status, "old position , 95
                 200 'Criado por:'(122), e_saida-ernam,
                 254 space.
          WRITE: /01 'Cliente:'(109), e_saida-kunnr,'-', e_saida-name1,
                 60 'Modalidade:'(110), e_saida-inco1,
                 95 'Filial:'(111), e_saida-vkbur, '-',e_saida-vkburt,
                 155 'Supervisor:'(112), e_saida-vkgrp, '-',e_saida-vkgrpt,
                 200 'Agente:'(113), e_saida-kunnr3, '-', e_saida-agent(30),
                 254 space.

          WRITE: /01 'Datas:'(114), 'Vencto:'(115), e_saida-valdt,
                  60 'Crédito:'(116), e_saida-udate,
                 95 'Início/Fim:'(117), e_saida-guebg, ' a ', e_saida-gueen,
                 155 'Criação:'(118), e_saida-erdat,
                200 'Destino:'(119), e_saida-regio,'-', e_saida-ort01(25),
                254 space.

          WRITE:/01'Condição de Pagamento:'(147), e_saida-zterm,
                 60 'Distrito de Vendas:'(148), e_saida-bzirk,
                 95 'Tipo de Recurso:'(149), e_saida-mschl,'-',e_saida-text1(50),
                 155 'Segmentação:'(151),e_saida-klabc,'-',e_saida-ddtext, "t_excel-klabc, " 200
                 200 'Grupo de Clientes:'(152), t_excel-kdgrp(20), "220
                 254 space.

          WRITE:/60 'Pago Data:'(214), out_zzpaidd,
                 95 'Contrato Cancela Sub:'(215), out_zzrepcc,
                 155'Estrutura de Clientes:'(212), e_saida-custs,
                 200 text-216 ,e_saida-waerk,
                 254 space.

          WRITE:/60  'Fixed USD Rate:'(170), e_saida-zexrate,
                 105 'Customer PO Header:'(171), e_saida-zzcust_po,
                 254 space.

          IF e_saida-zzdate_blk IS NOT INITIAL.
            CONCATENATE e_saida-zzdate_blk+6(2) '/'
                        e_saida-zzdate_blk+4(2) '/'
                        e_saida-zzdate_blk(4)
              INTO t_excel-zzdate_blk.
          ENDIF.
          WRITE: /01 'Credit blk reason:'(218),e_saida-zzcre_blk,
                  95 'Block date:'(219), e_saida-zzdate_blk,
                 254 space.

          FORMAT RESET.

        ENDIF.

        DATA: v_tx_usd(8),
            v_comis(6).
        WRITE: e_saida-taxa TO v_tx_usd CURRENCY 'BRL',
               e_saida-zra0 TO v_comis.
        SHIFT:  v_tx_usd RIGHT DELETING TRAILING space,
                v_comis  RIGHT DELETING TRAILING space.


        IF v_vbeln NE e_saida-vbeln.
          v_vbeln = e_saida-vbeln.
          IF e_saida-v_so IS NOT INITIAL.
            v_vbeln = e_saida-posnr.
          ENDIF.

          CLEAR:  v_kwmeng,v_vlrrem,v_saldo,v_valor_real.

          FORMAT COLOR COL_KEY.
          WRITE: /01 'Ordem:'(052),
                  18   'Centro'(153),
                  35   'Produto'(059),
                  55 'Descrição'(060),
                  90 'Qtd.Programada'(123),
                  110 'Qtd.Remetida'(126),                    " 155
                  130 'Qtd.Pendente'(127),                    " 175
                  150 'Vlr.Unitário'(064),                    " 195
                  170 'Vlr.Reais'(128),                       " 212
                  190 'Tx.Dolar'(129),                        " 231
                  205 'Tipo de embalagem:'(146),
                  254 space.
          FORMAT RESET.

          IF p_rad1 EQ 'X'.
            IF e_saida-v_so IS INITIAL.
              LOOP AT taux_saida WHERE werks = e_saida-werks
                                 AND vbelv = e_saida-vbelv
                                 AND vbeln = e_saida-vbeln.

                v_kwmeng = v_kwmeng + e_saida-kwmeng.
                v_vlrrem = v_vlrrem + e_saida-vlrrem.
                v_saldo  = v_saldo + e_saida-saldo.
                v_valor_real = v_valor_real + e_saida-valor_real.
              ENDLOOP.
            ELSE.
              LOOP AT taux_saida WHERE werks = e_saida-werks
                                 AND vbelv = e_saida-vbelv
                                 AND vbeln = e_saida-vbeln
                                 AND posnr = e_saida-posnr.

                v_kwmeng = v_kwmeng + e_saida-kwmeng.
                v_vlrrem = v_vlrrem + e_saida-vlrrem.
                v_saldo  = v_saldo + e_saida-saldo.
                v_valor_real = v_valor_real + e_saida-valor_real.
              ENDLOOP.
            ENDIF.

          ELSEIF p_rad2 EQ 'X'.
            IF e_saida-v_so IS INITIAL.
              LOOP AT taux_saida WHERE vbelv = e_saida-vbelv
                                   AND vbeln = e_saida-vbeln.

                v_kwmeng = v_kwmeng + e_saida-kwmeng.
                v_vlrrem = v_vlrrem + e_saida-vlrrem.
                v_saldo  = v_saldo + e_saida-saldo.
                v_valor_real = v_valor_real + e_saida-valor_real.
              ENDLOOP.
            ELSE.
              LOOP AT taux_saida WHERE vbelv = e_saida-vbelv
                                  AND vbeln = e_saida-vbeln
                                  AND posnr = e_saida-posnr.

                v_kwmeng = v_kwmeng + e_saida-kwmeng.
                v_vlrrem = v_vlrrem + e_saida-vlrrem.
                v_saldo  = v_saldo + e_saida-saldo.
                v_valor_real = v_valor_real + e_saida-valor_real.
              ENDLOOP.
            ENDIF.
          ENDIF.
          FORMAT COLOR 3 INTENSIFIED ON.
          IF  e_saida-v_so IS NOT INITIAL.
            e_saida-vbeln = ''.
          ENDIF.
          IF e_saida-v_so = 'X'.
            WRITE: /01 e_saida-vbeln HOTSPOT,
                    18   e_saida-werks,
                    35   e_saida-matnr,
                    55 e_saida-arktx,
                    90 v_kwmeng UNIT 'TO',
                   110  v_vlrrem UNIT 'TO',                     " 155
                   130  v_saldo CURRENCY 'BRL',                 " 175
                   150 e_saida-kbetr CURRENCY 'BRL',            " 195
                   170 v_valor_real CURRENCY 'BRL',             " 212
                   190 v_tx_usd,                                " 231
                   205 e_saida-mvgr3, '-', e_saida-bezei3(40),
                   254 space.
* The logic for settlement and pending quantity will run only if contract type is equal to ZCDB or ZCDN
            IF e_saida-auart = l_const23 OR e_saida-auart = l_const24.
              CLEAR: wa_vbfa1, gv_quantity, wa_vbap1.

              READ TABLE itab_vbfa1 INTO wa_vbfa1
              WITH KEY vbelv = e_saida-vbelv
              vbeln = e_saida-vbeln
              BINARY SEARCH.
              IF sy-subrc = 0.

* Variable gv_vbelv1 stores current contract number
* It is used to compare contract number in subsequent iteration
                IF gv_vbelv1 <> e_saida-vbelv.
                  CLEAR: gv_kwmeng, gv_zmeng, gv_index, wa_vbfa2, wa_vbap1, wa_vbap.

                  READ TABLE itab_vbap INTO wa_vbap
                  WITH KEY vbeln = wa_vbfa1-vbelv
                  BINARY SEARCH.
                  IF sy-subrc = 0.

* Fetch contract line item quantity in gv_zmeng
                    gv_zmeng = wa_vbap-zmeng.

                    READ TABLE itab_vbfa1 INTO wa_vbfa2
                      WITH KEY vbelv = e_saida-vbelv
                               vbeln = e_saida-vbeln
                               posnr = e_saida-posnr
                      TRANSPORTING NO FIELDS.
                    IF sy-subrc = 0.
* If data for item number is updated in table VBFA, then calculate order quantity from VBFA in gv_kwmeng
                      CLEAR wa_vbfa2.
                      LOOP AT itab_vbfa1 INTO wa_vbfa2
                        WHERE vbelv = e_saida-vbelv.
                        gv_kwmeng = gv_kwmeng + wa_vbfa2-rfmng.
                      ENDLOOP.
                    ELSE.
* Else, do summation of order quantaties from VBAP in gv_kwmeng
                      DO.
                        CLEAR : wa_vbfa2.
                        READ TABLE itab_vbfa1 INTO wa_vbfa2
                          WITH KEY vbelv = e_saida-vbelv
                                   read = space.
                        IF sy-subrc = 0.
                          gv_index = sy-tabix.
                          LOOP AT itab_vbap1 INTO wa_vbap1 WHERE vbeln = wa_vbfa2-vbeln.
                            gv_kwmeng = gv_kwmeng + wa_vbap1-kwmeng.
                          ENDLOOP.
                          wa_vbfa2-read = c_x.
                          MODIFY itab_vbfa1 FROM wa_vbfa2 INDEX gv_index TRANSPORTING read.
                        ELSE.
                          EXIT.
                        ENDIF.
                      ENDDO.

                    ENDIF.

                    gv_vbelv1 = e_saida-vbelv.

                  ENDIF.
                ENDIF.

                gv_quantity = gv_zmeng - gv_kwmeng.

                NEW-LINE.
                WRITE:18  e_saida-werks,
                      35  e_saida-matnr,
                      55  e_saida-arktx,
                      92  gv_quantity UNIT 'TO',
                      133 gv_quantity UNIT 'TO',
                      150 e_saida-kbetr CURRENCY 'BRL',
                      170 v_valor_real CURRENCY 'BRL',
                      190 v_tx_usd,
                      205 e_saida-mvgr3, '-', e_saida-bezei3(40),
                      254 space.
              ENDIF.
            ENDIF.
          ELSE.
            WRITE: /01 e_saida-vbeln HOTSPOT,
                    18   e_saida-werks,
                    35   e_saida-matnr,
                    55 e_saida-arktx,
                    90 v_kwmeng UNIT 'TO',
                   110  v_saldo CURRENCY 'BRL',                 " 175
                   130  v_vlrrem UNIT 'TO',                     " 155
                   150 e_saida-kbetr CURRENCY 'BRL',            " 195
                   170 v_valor_real CURRENCY 'BRL',             " 212
                   190 v_tx_usd,                                " 231
                   205 e_saida-mvgr3, '-', e_saida-bezei3(40),
                   254 space.
* The logic for settlement and pending quantity will run only if contract type is equal to ZCDB or ZCDN
            IF e_saida-auart = l_const23 OR e_saida-auart = l_const24.
              CLEAR: wa_vbfa1, gv_quantity, wa_vbap1.

              READ TABLE itab_vbfa1 INTO wa_vbfa1
              WITH KEY vbelv = e_saida-vbelv
              vbeln = e_saida-vbeln
              BINARY SEARCH.
              IF sy-subrc = 0.

* Variable gv_vbelv1 stores current contract number
* It is used to compare contract number in subsequent iteration
                IF gv_vbelv1 <> e_saida-vbelv.
                  CLEAR: gv_kwmeng, gv_zmeng, gv_index, wa_vbfa2, wa_vbap1, wa_vbap.

                  READ TABLE itab_vbap INTO wa_vbap
                  WITH KEY vbeln = wa_vbfa1-vbelv
                  BINARY SEARCH.
                  IF sy-subrc = 0.

* Fetch contract line item quantity in gv_zmeng
                    gv_zmeng = wa_vbap-zmeng.

                    READ TABLE itab_vbfa1 INTO wa_vbfa2
                      WITH KEY vbelv = e_saida-vbelv
                               vbeln = e_saida-vbeln
                               posnr = e_saida-posnr
                      TRANSPORTING NO FIELDS.
                    IF sy-subrc = 0.
* If data for item number is updated in table VBFA, then calculate order quantity from VBFA in gv_kwmeng
                      CLEAR wa_vbfa2.
                      LOOP AT itab_vbfa1 INTO wa_vbfa2
                        WHERE vbelv = e_saida-vbelv.
                        gv_kwmeng = gv_kwmeng + wa_vbfa2-rfmng.
                      ENDLOOP.
                    ELSE.
* Else, do summation of order quantaties from VBAP in gv_kwmeng
                      DO.
                        READ TABLE itab_vbfa1 INTO wa_vbfa2
                          WITH KEY vbelv = e_saida-vbelv
                                   read = space.
                        gv_index = sy-tabix.
                        IF sy-subrc = 0.
                          LOOP AT itab_vbap1 INTO wa_vbap1 WHERE vbeln = wa_vbfa2-vbeln.
                            gv_kwmeng = gv_kwmeng + wa_vbap1-kwmeng.
                          ENDLOOP.
                          wa_vbfa2-read = c_x.
                          MODIFY itab_vbfa1 FROM wa_vbfa2 INDEX gv_index TRANSPORTING read.
                        ELSE.
                          EXIT.
                        ENDIF.
                      ENDDO.
                    ENDIF.

                    gv_vbelv1 = e_saida-vbelv.

                  ENDIF.
                ENDIF.

                gv_quantity = gv_zmeng - gv_kwmeng.

                NEW-LINE.
                WRITE:18  e_saida-werks,
                      35  e_saida-matnr,
                      55  e_saida-arktx,
                      92  gv_quantity UNIT 'TO',
                      133 gv_quantity UNIT 'TO',
                      150 e_saida-kbetr CURRENCY 'BRL',
                      170 v_valor_real CURRENCY 'BRL',
                      190 v_tx_usd,
                      205 e_saida-mvgr3, '-', e_saida-bezei3(40),
                      254 space.
              ENDIF.
            ENDIF.
          ENDIF.
          FORMAT RESET.

          FORMAT COLOR COL_KEY.
* column position changed by 5.
          WRITE: /01  'Vlr.Dolar'(130),
                 21 'Comissão'(074),
                 35 'Cultura'(065),
                 65 'Bl.Rem'(131),
                 75 'Bl.Pgto'(132),
                 85 'Bl.Cred'(133),
                 95 'Recusa'(134),
                 105 'Bl.Entr'(135),
                 120 'Bloqueio'(082),
                 134 'Cidade'(207),
                 171 'Estado'(208),
                 183 'Bairro'(209),
                 259 space.
          FORMAT RESET.

          FORMAT COLOR 3 INTENSIFIED ON.
          WRITE: /01 e_saida-valor_dolar CURRENCY 'USD',
                  21   v_comis,
                  35 e_saida-bezei,
                  65 e_saida-lifsk,
                  75 e_saida-faksk,
                  85 e_saida-cmgst,
                  95 e_saida-abgru,
                 105 e_saida-mstav,
                 120 e_saida-eikto,
                 134 e_saida-ort01,
                 171 e_saida-regio,
                 183 e_saida-ort02,
                 259 space.
          FORMAT RESET.

          FORMAT COLOR COL_KEY.
          WRITE: /01 'CNPJ'(201),
           19  'CPF'(202),
           33  'Inscrição Estadual'(203),
           54  'Inscrição Munipal'(204),
           74  'Cód. Postal'(205),
           87  'Endereço'(206),
           125 'Recebedor'(210),
           138 'Unit Value R$'(176),
           172 'Tax Jurisdiction code'(177),
           196 'Customer PO Item'(174),
           254 space.
          FORMAT RESET.

          FORMAT COLOR 3 INTENSIFIED ON.
          WRITE: /01 e_saida-stcd1,
                 19 e_saida-stcd2,
                 33 e_saida-stcd3,
                 54 e_saida-stcd4,
                 74 e_saida-pstlz,
                 87 e_saida-stras,
                 125 e_saida-kunnr2,
                 138 e_saida-zvalorunit,
                 172 e_saida-ztaxzur,
                 196 e_saida-zzcust_po_item,
                 254 space.
* Removed skip statement to display next row
          FORMAT RESET.
* Display column in Report
          FORMAT COLOR COL_KEY.
          WRITE: /01   text-t01,
                  19   text-t02,
                  54   text-t04,
                  74   text-t03,
                  254  space.
          FORMAT RESET.
          FORMAT COLOR 3 INTENSIFIED ON.
          WRITE: /01   e_saida-salgrp,
                  19   e_saida-saltyp,
                  54   e_saida-rel,
                  74   e_saida-name2,
                  254  space.
          FORMAT RESET.

        ENDIF.


        IF p_path NE space OR p_email NE space OR p_update NE space.
* Tabela Arquivo excel.
          PERFORM excel.
        ENDIF.


        IF NOT s_edatu[] IS INITIAL.

          READ TABLE t_vbep WITH KEY vbeln = e_saida-vbeln
                                     posnr = e_saida-posnr BINARY SEARCH.
          IF sy-subrc EQ 0.
            LOOP AT t_vbep FROM sy-tabix.
              IF t_vbep-vbeln NE e_saida-vbeln OR
                 t_vbep-posnr NE e_saida-posnr.
                EXIT.
              ENDIF.

              IF vl_flag = ' '.

                FORMAT COLOR 4 INVERSE ON.
                SKIP.
                WRITE: /70 'Programação de remessa'(084).
                WRITE: /55 'Dt.Prog.Remessa'(085),
                        77 'Vol.Programado'(086),
                        97 'Bloqueio'(082),
                       107 'Descrição'(060).
                FORMAT RESET.
                vl_flag = 'X'.
              ENDIF.
              CLEAR tvlst.
              SELECT SINGLE vtext FROM tvlst INTO tvlst-vtext
                                  WHERE spras = sy-langu AND
                                        lifsp = t_vbep-lifsp.
              IF sy-subrc <> 0.
                CLEAR tvlst-vtext.
              ENDIF.
              WRITE: /55 t_vbep-edatu,
                      75 t_vbep-bmeng,
                      99 t_vbep-lifsp,
                     107 tvlst-vtext.
              SKIP.

              IF t_vbep-lifsp IS INITIAL.

                e_saida-bmeng = t_vbep-bmeng.
                MODIFY t_saida FROM e_saida  INDEX vl_tabix.
              ELSE.                                         "
                e_saida-lifsp = t_vbep-lifsp.               "
                MODIFY t_saida FROM e_saida  INDEX vl_tabix. "

              ENDIF.
            ENDLOOP.
          ENDIF.

          CLEAR vl_flag .

        ENDIF.

        AT END OF vbelv.
          SKIP.
        ENDAT.
      ENDIF.
    ENDIF.
  ENDLOOP.

* To display contract line as first line and then order lines.
  t_excel_temp[] = t_excel[].
* Reading first line of internal table, this line has column names.
  READ TABLE t_excel INDEX 1.
  CLEAR t_excel[].
* Appending first line of internal table, this line has column names.
  APPEND t_excel.
  DELETE t_excel_temp[] INDEX 1.
* Sorting value copied in temprory internal table on basis of contract and order number.
  SORT t_excel_temp BY contract_no ordem.
* Moving values from temprory table to internal table t_excel, which is exported to excel.
  APPEND LINES OF t_excel_temp  TO t_excel.
* Imprime a totalização por agente
  IF p_agente = 'X'.
    LOOP AT t_saida.

      MOVE-CORRESPONDING t_saida TO t_agente.
      APPEND t_agente.

    ENDLOOP.

    SORT t_agente BY kunnr2.

    LOOP AT t_agente.
      AT FIRST.
        FORMAT COLOR 1 INTENSIFIED ON.
        WRITE: /01 'TOTAL AGENTE'(087),
               /01 'Agente'(049),
                11 '   Qtd.Programada'(088),
                33 '   Qtd.Remetida'(089),
                53 '   Qtd.Pendente'(090),
                77 'Valor em Reais'(091),
                95 '   Total Dolar'(092),
               115 'Divisão Liberada'(093).
        FORMAT RESET.
      ENDAT.

      AT END OF kunnr2.
        SUM.
        WRITE: /01 t_agente-kunnr2,
                10 t_agente-kwmeng UNIT 'TO',
                30 t_agente-saldo,
                50 t_agente-vlrrem UNIT 'TO',
                76 t_agente-valor_real,
                94 t_agente-valor_dolar CURRENCY 'USD',
               115 t_agente-bmeng.

      ENDAT.
    ENDLOOP.

    SKIP.
  ENDIF.

* Imprime a totalização por filial
  IF p_filial = 'X'.

    LOOP AT t_saida.

      MOVE-CORRESPONDING t_saida TO t_filial.
      APPEND t_filial.

    ENDLOOP.

    SORT t_filial BY vkbur.

    LOOP AT t_filial.
      AT FIRST.
        FORMAT COLOR 1 INTENSIFIED ON.
        WRITE: /01 'TOTAL FILIAL'(139),
               /01 'Filial'(047),
                31 '   Qtd.Programada'(088),
                53 '   Qtd.Remetida'(089),
                73 '   Qtd.Pendente'(090),
                97 'Valor em Reais'(091),
               115 '   Total Dolar'(092),
               135 'Divisão Liberada'(093).
        FORMAT RESET.
      ENDAT.
      AT END OF vkbur.
        SUM.
        WRITE: /01 t_filial-vkbur,
                30 t_filial-kwmeng UNIT 'TO',
                50 t_filial-saldo,
                70 t_filial-vlrrem UNIT 'TO',
                96 t_filial-valor_real,
               114 t_filial-valor_dolar CURRENCY 'USD',
               135 t_filial-bmeng.
      ENDAT.
    ENDLOOP.

    SKIP.
  ENDIF.

* Imprime a totalização por supervisor
  IF p_superv = 'X'.

    LOOP AT t_saida.

      MOVE-CORRESPONDING t_saida TO t_superv.
      APPEND t_superv.

    ENDLOOP.


    SORT t_superv BY vkgrp.
    LOOP AT t_superv.
      AT FIRST.
        FORMAT COLOR 1 INTENSIFIED ON.
        WRITE: /01 'TOTAL SUPERVISOR'(094),
               /01 'Supervisor'(048),
                12 '   Qtd.Programada'(088),
                33 '   Qtd.Remetida'(089),
                53 '   Qtd.Pendente'(090),
                77 'Valor em Reais'(091),
                95 '   Total Dolar'(092),
               115 'Divisão Liberada'(093).
        FORMAT RESET.
      ENDAT.
      AT END OF vkgrp.
        SUM.
        WRITE: /01 t_superv-vkgrp,
                10 t_superv-kwmeng UNIT 'TO',
                30 t_superv-saldo,
                50 t_superv-vlrrem UNIT 'TO',
                76 t_superv-valor_real,
                94 t_superv-valor_dolar CURRENCY 'USD',
               115 t_superv-bmeng.
      ENDAT.
    ENDLOOP.
    SKIP.
  ENDIF.
  ULINE.
  CLEAR wa_zvarf.
  LOOP AT t_saida.
    CLEAR lv_rfstk.
    IF t_saida-v_so = 'X'.
      SELECT SINGLE rfstk INTO lv_rfstk FROM vbuk WHERE vbeln = t_saida-vbeln.
      IF sy-subrc = 0.
        READ TABLE itab_zvarf INTO wa_zvarf WITH KEY var3 = lv_rfstk.
        IF sy-subrc = 0.
          t_saida-vlrrem = t_saida-saldo - lv_soqty.
          t_saida-saldo = lv_soqty.
          MODIFY t_saida TRANSPORTING vlrrem saldo.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
* Imprime a totalização por centro
  LOOP AT t_saida.
    MOVE-CORRESPONDING t_saida TO it_temp.
    APPEND it_temp.
    CLEAR it_temp.
  ENDLOOP.

  SORT it_temp BY werks.

  LOOP AT it_temp.
    AT END OF werks.
      SUM.
      wa_final-werks = it_temp-werks.
      wa_final-kwmeng = it_temp-kwmeng.
      wa_final-vlrrem = it_temp-vlrrem.
      wa_final-saldo = it_temp-saldo.
      wa_final-valor_real = it_temp-valor_real.
      wa_final-valor_dolar = it_temp-valor_dolar.
      wa_final-bmeng = it_temp-bmeng.
      APPEND wa_final TO it_final.
      CLEAR wa_final.
    ENDAT.
  ENDLOOP.

  LOOP AT it_temp.
    AT FIRST.
      FORMAT COLOR 1 INTENSIFIED ON.
      WRITE: /01 'TOTAL CENTRO'(095),
             /01 'Centro'(029),
              11 '   Qtd.Programada'(088),
              33 '   Qtd.Remetida'(089),
              53 '   Qtd.Pendente'(090),
              87 'Valor em Reais'(091),
             100 '   Total Dolar'(092),
             117 'Divisão Liberada'(093).
      FORMAT RESET.
    ENDAT.

    AT END OF werks.
      CLEAR wa_final.
      SORT it_final BY werks .
      READ TABLE it_final INTO wa_final WITH KEY werks = it_temp-werks.
      IF sy-subrc = 0.
        WRITE: /01 wa_final-werks,
              10 wa_final-kwmeng UNIT 'TO',
              30 wa_final-saldo,
              50 wa_final-vlrrem UNIT 'TO',
              76 wa_final-valor_real,
              96 wa_final-valor_dolar CURRENCY 'USD',
             117 wa_final-bmeng.
      ENDIF.

    ENDAT.

    AT LAST.
      SUM.
      ULINE.
      FORMAT COLOR 3 INTENSIFIED ON.
      WRITE: /01 'Total:'(096),
              10 it_temp-kwmeng UNIT 'TO',
              30 it_temp-saldo,
              50 it_temp-vlrrem UNIT 'TO',
              76 it_temp-valor_real,
              96 it_temp-valor_dolar CURRENCY 'USD',
             117 it_temp-bmeng.
      FORMAT RESET.
    ENDAT.
  ENDLOOP.


  IF p_sele = 'X'.
    NEW-PAGE.
    FORMAT COLOR OFF.
    WRITE: /001 'Tipo de documento de venda'(008).
    LOOP AT s_auart.
      WRITE: /020 s_auart-low,
              035 s_auart-high.
    ENDLOOP.
    WRITE: /001 'Ordem de venda'(009).
    LOOP AT s_vbeln.
      WRITE: /020 s_vbeln-low,
              035 s_vbeln-high.
    ENDLOOP.
    IF NOT s_edatu[] IS INITIAL.
      WRITE: /001 'Data divisão remessa'(010).
      LOOP AT s_edatu.
        WRITE: /020 s_edatu-low,
                035 s_edatu-high.
      ENDLOOP.

      WRITE: /001 'Bloqueio divisão remessa'(011).
      LOOP AT s_lifsp.
        WRITE: /020 s_lifsp-low,
                035 s_lifsp-high.
      ENDLOOP.
    ELSE.
      WRITE: /001 'Data de criação'(012).
      LOOP AT s_erdat.
        WRITE: /020 s_erdat-low,
                035 s_erdat-high.
      ENDLOOP.
    ENDIF.

    WRITE: /001 'Início data remessa'(013).
    LOOP AT s_vdatu.
      WRITE: /020 s_vdatu-low,
              035 s_vdatu-high.
    ENDLOOP.
    WRITE: /001 'Fim de remessa'(014).
    LOOP AT s_mahdt.
      WRITE: /020 s_mahdt-low,
              035 s_mahdt-high.
    ENDLOOP.
    WRITE: /001 'Data vencimento'(015).

    WRITE: /001 'Código do Cliente'(016).
    LOOP AT s_kunnr.
      WRITE: /020 s_kunnr-low,
              035 s_kunnr-high.
    ENDLOOP.
    WRITE: /001 'Canal de distribuição'(017).
    LOOP AT s_vtweg.
      WRITE: /020 s_vtweg-low,
              035 s_vtweg-high.
    ENDLOOP.
    WRITE: /001 'Setor de atividade'(018).
    LOOP AT s_spart.
      WRITE: /020 s_spart-low,
              035 s_spart-high.
    ENDLOOP.
    WRITE: /001 'Escritório de vendas'(019).
    LOOP AT s_vkbur.
      WRITE: /020 s_vkbur-low,
              035 s_vkbur-high.
    ENDLOOP.
    WRITE: /001 'Supervisor de vendas'(020).
    LOOP AT s_vkgrp.
      WRITE: /020 s_vkgrp-low,
              035 s_vkgrp-high.
    ENDLOOP.
    WRITE: /001 'Agente de vendas'(021).
    LOOP AT s_kunnr2.
      WRITE: /020 s_kunnr2-low,
              035 s_kunnr2-high.
    ENDLOOP.
    WRITE: /001 'Condição de pagamento'(022).
    LOOP AT s_zterm.
      WRITE: /020 s_zterm-low,
              035 s_zterm-high.
    ENDLOOP.
    WRITE: /001 'CIF/FOB'(023).
    LOOP AT s_inco1.
      WRITE: /020 s_inco1-low,
              035 s_inco1-high.
    ENDLOOP.
    WRITE: /001 'Bloqueio remessa'(024).
    WRITE: /001 'Status Crédito'(025).
    LOOP AT s_cmgst.
      WRITE: /020 s_cmgst-low,
              035 s_cmgst-high.
    ENDLOOP.
    WRITE: /001 'Bloqueio faturamento'(026).
    LOOP AT s_faksk.
      WRITE: /020 s_faksk-low,
              035 s_faksk-high.
    ENDLOOP.
    WRITE: /001 'Código do material'(027).
    LOOP AT s_matnr.
      WRITE: /020 s_matnr-low,
              035 s_matnr-high.
    ENDLOOP.
    WRITE: /001 'Grupo mercadoria'(028).
    LOOP AT s_matkl.
      WRITE: /020 s_matkl-low,
              035 s_matkl-high.
    ENDLOOP.
    WRITE: /001 'Grupo MRP'(t13).
    LOOP AT s_disgr.
      WRITE: /020 s_disgr-low,
              035 s_disgr-high.
    ENDLOOP.
    WRITE: /001 'Centro'(029).
    LOOP AT s_werks.
      WRITE: /020 s_werks-low,
              035 s_werks-high.
    ENDLOOP.
    WRITE: /001 'Quantidade da ordem'(030).
    LOOP AT s_kwmeng.
      WRITE: /020 s_kwmeng-low UNIT 'TO',
              035 s_kwmeng-high UNIT 'TO'.
    ENDLOOP.
    WRITE: /001 'Saldo'(031).
    LOOP AT s_saldo.
      WRITE: /020 s_saldo-low,
              035 s_saldo-high.
    ENDLOOP.
    WRITE: /001 'Motivo de recusa'(032).
    LOOP AT s_abgru.
      WRITE: /020 s_abgru-low,
              035 s_abgru-high.
    ENDLOOP.
  ENDIF.



ENDFORM.                    " f_imprime
*&---------------------------------------------------------------------*
*&      Form  arq_excel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM arq_excel.
  IF sy-batch NE space.
    v_cont = l_const11 .
    CLEAR v_inicio.
    DO.
      IF p_path+v_cont(1) <> ' ' AND v_inicio IS INITIAL.
        v_inicio = v_cont + 1.
      ENDIF.
      v_cont = v_cont - 1.
      IF  p_path+v_cont(1) = '/' OR p_path+v_cont(1) = '\' .
        v_cont = v_cont + 1.
        v_inicio = ( v_inicio - v_cont ).
        v_arquivo = p_path+v_cont(v_inicio).
        EXIT.
      ENDIF.
    ENDDO.
    CONCATENATE '/usr/sap/trans/basis/' sy-datum sy-uzeit v_arquivo INTO v_file.
    OPEN DATASET v_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc = 0.
      LOOP AT t_excel.
        TRANSFER t_excel TO v_file.
      ENDLOOP.
      CLOSE DATASET v_file.
      FREE t_excel.
    ENDIF.
  ELSE.

*    LOOP AT t_excel.
*        APPEND t_excel TO t_excel1.
*    ENDLOOP.


    v_path = p_path.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = v_path
        filetype              = 'DAT'
*       append                = 'X'
*       write_field_separator = 'X'
*       CONFIRM_OVERWRITE     = 'X'
      TABLES
        data_tab              = t_excel.

*    CALL METHOD cl_gui_frontend_services=>gui_download
*      EXPORTING
*        filename              = v_path
*        write_field_separator = 'X'
*      CHANGING
*        data_tab              = t_excel[].


  ENDIF.
ENDFORM.                    " arq_excel
*&---------------------------------------------------------------------*
*&      Form  excel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM excel.
  DATA: vl_data(10).
  IF NOT s_edatu[] IS INITIAL.

    LOOP AT t_vbep WHERE vbeln = t_saida-vbeln AND
                            posnr = t_saida-posnr.
      CONCATENATE
      t_vbep-edatu+6(2) '/' t_vbep-edatu+4(2) '/' t_vbep-edatu(4) INTO
      vl_data.

      MOVE: vl_data      TO t_excel-edatu.
      CONCATENATE
      t_saida-valdt+6(2) '/' t_saida-valdt+4(2) '/' t_saida-valdt(4) INTO
      vl_data.
      MOVE: t_saida-werks    TO t_excel-centro.
      CONCATENATE
      lv_date+6(2) '/' lv_date+4(2) '/' lv_date(4) INTO vl_data.                                   "CHG160842

      MOVE: vl_data         TO t_excel-data,
            t_saida-vbeln    TO t_excel-ordem,
            t_saida-kunnr    TO t_excel-numcli,
            t_saida-name1      TO t_excel-nomcli,
            t_saida-inco1    TO t_excel-modali,
            vl_data          TO t_excel-dvenc.

      CONCATENATE t_excel-data lv_time INTO t_excel-data SEPARATED BY space. "
      CONCATENATE lv_date lv_time1 INTO t_excel-version SEPARATED BY ''.       "  .
      CONCATENATE t_saida-udate+6(2) '/' t_saida-udate+4(2) '/' t_saida-udate(4) INTO
      vl_data.
      MOVE vl_data    TO t_excel-dcred.

      CONCATENATE
      t_saida-erdat+6(2) '/' t_saida-erdat+4(2) '/' t_saida-erdat(4) INTO
      vl_data.
      IF t_saida-v_so = 'X'.
        MOVE t_saida-vlrrem    TO t_excel-qremet.
        MOVE t_saida-saldo     TO t_excel-qpend.
      ELSE.
        MOVE t_saida-saldo    TO t_excel-qremet.
        MOVE t_saida-vlrrem     TO t_excel-qpend.
      ENDIF.
      MOVE: vl_data           TO t_excel-dcria,
            t_saida-regio     TO t_excel-dest,
            t_saida-ort01     TO t_excel-dest2,
            t_saida-matnr     TO t_excel-produto,
            t_saida-arktx     TO t_excel-descri,
            t_saida-kwmeng    TO t_excel-qprog,
            t_saida-lifsk     TO t_excel-blrem,
            t_saida-faksk     TO t_excel-blpgto,
            t_saida-cmgst     TO t_excel-blcred,
            t_saida-abgru     TO t_excel-motrec,
            t_saida-kbetr     TO t_excel-vlruni,
            t_saida-valor_real TO t_excel-real_value,
            t_saida-taxa      TO t_excel-usd_rate,
            t_saida-valor_dolar TO t_excel-usd_value,
*            t_saida-bezei(20) TO t_excel-cult,
            t_saida-ernam     TO t_excel-ernam,
            t_saida-zra0      TO t_excel-zra0,
            t_saida-eikto     TO t_excel-eikto,
            t_saida-mstav     TO t_excel-mstav,
            t_saida-bstkd     TO t_excel-bstkd,
            t_saida-bzirk     TO t_excel-bzirk,
            t_saida-bzirk1    TO t_excel-bzirk1,
            t_saida-zterm     TO t_excel-zterm,
            t_saida-stcd1     TO t_excel-stcd1,
            t_saida-stcd2     TO t_excel-stcd2,
            t_saida-stcd3     TO t_excel-stcd3,
            t_saida-stcd4     TO t_excel-stcd4,
            t_saida-pstlz     TO t_excel-pstlz,
            t_saida-stras     TO t_excel-stras,
            t_saida-ort02     TO t_excel-ort02,
            t_saida-kunnr2    TO t_excel-receb1,
*            t_saida-custs     TO t_excel-custs,
            t_saida-waerk     TO t_excel-waerk.
* Display field in excel file
      t_excel-name2   =  t_saida-name2 .
      t_excel-rel     =  t_saida-rel   .
      t_excel-salgrp  =  t_saida-salgrp.
      t_excel-saltyp  =  t_saida-saltyp.

*      CLEAR wa_t171t.
*      READ TABLE itab_t171t INTO wa_t171t WITH KEY bzirk = t_excel-bzirk BINARY SEARCH.
*      IF sy-subrc = 0.
*        t_excel-bzirk1 =  wa_t171t-bztxt.
*      ENDIF.
*      CLEAR wa_t171t.


      CLEAR: out_zzrepcc, zzrepcc_filled, out_zzpaidd, zzpaidd_filled.
      LOOP AT t_vbap WHERE vbeln = t_saida-vbelv.
        IF t_saida-zzrepcc IS INITIAL.
          IF zzrepcc_filled IS INITIAL AND t_vbap-zzrepcc IS NOT INITIAL.
            out_zzrepcc = t_vbap-zzrepcc.
            zzrepcc_filled = 'X'.
          ENDIF.
        ELSE.
          IF zzrepcc_filled IS INITIAL.
            out_zzrepcc = t_saida-zzrepcc.
            zzrepcc_filled = 'X'.
          ENDIF.
        ENDIF.

        IF t_saida-zzpaidd IS INITIAL.
          IF zzpaidd_filled IS INITIAL AND t_vbap-zzpaidd IS NOT INITIAL.
            out_zzpaidd = t_vbap-zzpaidd.
            zzpaidd_filled = 'X'.
          ENDIF.
        ELSE.
          IF zzpaidd_filled IS INITIAL.
            out_zzpaidd = t_saida-zzpaidd.
            zzpaidd_filled = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      t_excel-zzrepcc = out_zzrepcc.
      t_excel-zzpaidd = out_zzpaidd.
      CONCATENATE t_excel-zzpaidd+6(2) '/' t_excel-zzpaidd+4(2) '/'  t_excel-zzpaidd(4) INTO t_excel-zzpaidd.

      "   New
*     Moving values to new fields as well                                       "   New
      MOVE : t_saida-vkbur   TO t_excel-vkbur,                                  "   New
             t_saida-vkburt  TO t_excel-vkburt,                                 "   New
             t_saida-vkgrp   TO t_excel-vkgrp,                                  "   New
             t_saida-vkgrpt  TO t_excel-vkgrpt,                                 "   New
             t_saida-kunnr2  TO t_excel-kunnr,                                  "   New
             t_saida-agent   TO t_excel-name1,                                  "   New
             t_saida-mvgr3   TO t_excel-mvgr3,                                  "   New
             t_saida-bezei3  TO t_excel-mvgr3t,                                 "   New
             t_saida-klabc   TO t_excel-klabc1,                                 "   New
             t_saida-ddtext  TO t_excel-klabc1t,                                "   New
             t_saida-mschl   TO t_excel-mschl1,                                 "   New
             t_saida-text1   TO t_excel-mschl1t,                                "   New
             t_saida-lifsp   TO t_excel-lifsp,                                  "   New
             t_saida-faksp   TO t_excel-faksp,                                  "   New
             t_saida-freight_br TO t_excel-freight,                             "   New
             t_saida-pgrp       TO t_excel-pgrp,                                "   New
             t_saida-roteiro TO t_excel-troto.                                  "   New
      REPLACE ALL OCCURENCES OF '#' IN t_excel-troto WITH ` `.
      SPLIT t_saida-bezei  AT '-' INTO t_excel-mvgr4  t_excel-mvgr4t.    "   New
      "   New
      t_excel-receb1 = t_saida-kunnr2.                                          "   New
      SELECT SINGLE name1 FROM kna1 INTO t_excel-receb1t                        "   New
                                                  WHERE kunnr = t_saida-kunnr2. "   New
      IF sy-subrc = 0.
        lv_t1 = lv_t2.
      ENDIF.
      READ TABLE t_vbpa WITH KEY vbeln = t_excel-ordem parvw = 'RG' BINARY SEARCH.     "   New
      IF sy-subrc = 0.                                                   "   New
        t_excel-kunnr4 = t_vbpa-kunnr.                                   "   New
        CLEAR wa_kna1.                                                   "   New
        READ TABLE itab_kna1 INTO wa_kna1 WITH KEY kunnr = t_vbpa-kunnr. "   New
        IF sy-subrc = 0 .                                                "   New
          t_excel-parvwt = wa_kna1-name1.                                "   New
          t_excel-kunnr4_ad = wa_kna1-stras.                             "   New
        ENDIF.                                                           "   New
      ENDIF.                                                             "   New
      "   New
      IF  t_saida-v_so IS NOT INITIAL.
        t_excel-ordem = ''.
      ENDIF.
      t_excel-zzcre_blk  = e_saida-zzcre_blk.
      CONCATENATE e_saida-zzdate_blk+6(2) '/'
                  e_saida-zzdate_blk+4(2) '/'
                  e_saida-zzdate_blk+0(4) INTO t_excel-zzdate_blk.



      APPEND t_excel.
      IF e_saida-auart = l_const23 OR e_saida-auart = l_const24
      OR e_saida-auart = lv_const30 OR e_saida-auart = lv_const31.
*--------------------------------------------------------------------*


        MOVE-CORRESPONDING  e_saida TO t_excel.
        MOVE-CORRESPONDING  t_saida TO t_excel.

        READ TABLE t_vbpa WITH KEY vbeln = t_excel-contract_no parvw = 'RG' .
        IF sy-subrc = 0.
          t_excel-kunnr4 = t_vbpa-kunnr.
          CLEAR wa_kna1.
          READ TABLE itab_kna1 INTO wa_kna1 WITH KEY kunnr = t_vbpa-kunnr.
          IF sy-subrc = 0 .
            t_excel-parvwt = wa_kna1-name1.
            t_excel-kunnr4_ad = wa_kna1-stras.
          ENDIF.
        ENDIF.



        CLEAR lv_contract_line.
        CLEAR t_excel-ordem.
*--------------------------------------------------------------------*
        MOVE: t_saida-werks      TO t_excel-centro,
              t_saida-matnr      TO t_excel-produto,
              t_saida-arktx      TO t_excel-descri,
              gv_quantity        TO t_excel-qprog,
              gv_quantity        TO t_excel-qpend,
              t_saida-kbetr      TO t_excel-vlruni,
              t_saida-valor_real TO t_excel-real_value,
              t_saida-taxa       TO t_excel-usd_rate.
*        CONCATENATE  t_saida-mvgr3 '-' t_saida-bezei3(40) INTO t_excel-bag.
        MOVE : t_saida-mvgr3   TO t_excel-mvgr3,                                  "   New
               t_saida-bezei3  TO t_excel-mvgr3t.                                 "   New

        READ TABLE t_vbpa WITH KEY vbeln = t_excel-contract_no parvw = 'RG' .     "   New
        IF sy-subrc = 0.                                                   "   New
          t_excel-kunnr4 = t_vbpa-kunnr.                                   "   New
          CLEAR wa_kna1.                                                   "   New
          READ TABLE itab_kna1 INTO wa_kna1 WITH KEY kunnr = t_vbpa-kunnr. "   New
          IF sy-subrc = 0 .                                                "   New
            t_excel-parvwt = wa_kna1-name1.                                "   New
            t_excel-kunnr4_ad = wa_kna1-stras.
          ENDIF.                                                           "   New
        ENDIF.


        READ TABLE t_excel WITH KEY contract_no = t_excel-contract_no
                                    ordem = space TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
* Flag is set to display only one line of contract
          lv_contract_line = 1.
        ENDIF.
      ENDIF.
* If Flag is set display line for contract
      IF lv_contract_line IS NOT INITIAL.
        APPEND t_excel.
      ENDIF.
      CLEAR t_excel.
    ENDLOOP.

  ELSE.
    CLEAR t_vbep.
    READ TABLE t_vbep WITH KEY vbeln = t_saida-vbeln
                               posnr = t_saida-posnr.
    IF sy-subrc <> 0.
      CLEAR t_vbep.
    ENDIF.
    t_saida-mstav = t_vbep-lifsp.
    t_saida-lifsp = t_vbep-lifsp.
    CONCATENATE
     t_vbep-edatu+6(2) '/' t_vbep-edatu+4(2) '/' t_vbep-edatu(4) INTO
     vl_data.

    MOVE: vl_data      TO t_excel-edatu.

    MOVE: t_saida-werks    TO t_excel-centro.

    CONCATENATE
      sy-datum+6(2) '/' sy-datum+4(2) '/' sy-datum(4) INTO vl_data.

    MOVE: vl_data         TO t_excel-data,
         t_saida-vbeln    TO t_excel-ordem,
         t_saida-kunnr    TO t_excel-numcli,
         t_saida-name1    TO t_excel-nomcli,
         t_saida-inco1    TO t_excel-modali.



    CONCATENATE t_excel-data lv_time INTO t_excel-data SEPARATED BY space. "

    CONCATENATE lv_date lv_time1 INTO t_excel-version." SEPARATED BY ''.                    "  .

    CONCATENATE
    t_saida-valdt+6(2) '/' t_saida-valdt+4(2) '/' t_saida-valdt(4) INTO
    vl_data.
    MOVE:
        vl_data          TO t_excel-dvenc.
    CONCATENATE
    t_saida-udate+6(2) '/' t_saida-udate+4(2) '/' t_saida-udate(4) INTO
    vl_data.
    MOVE vl_data          TO t_excel-dcred.


    CONCATENATE
    t_saida-erdat+6(2) '/' t_saida-erdat+4(2) '/' t_saida-erdat(4) INTO
    vl_data.
    IF t_saida-v_so = 'X'.
      MOVE t_saida-vlrrem    TO t_excel-qremet.
      MOVE t_saida-saldo     TO t_excel-qpend.
    ELSE.
      MOVE t_saida-saldo    TO t_excel-qremet.
      MOVE t_saida-vlrrem     TO t_excel-qpend.
    ENDIF.
    MOVE: vl_data           TO t_excel-dcria,
          t_saida-regio     TO t_excel-dest,
          t_saida-ort01     TO t_excel-dest2,
          t_saida-matnr     TO t_excel-produto,
          t_saida-arktx     TO t_excel-descri,
          t_saida-kwmeng    TO t_excel-qprog,
          t_saida-lifsk     TO t_excel-blrem,
          t_saida-faksk     TO t_excel-blpgto,
          t_saida-cmgst     TO t_excel-blcred,
          t_saida-abgru     TO t_excel-motrec,
          t_saida-kbetr     TO t_excel-vlruni,
          t_saida-valor_real TO t_excel-real_value,
          t_saida-taxa      TO t_excel-usd_rate,
          t_saida-valor_dolar TO t_excel-usd_value,
*          t_saida-bezei(20) TO t_excel-cult,
          t_saida-ernam     TO t_excel-ernam,
          t_saida-zra0      TO t_excel-zra0,
          t_saida-eikto     TO t_excel-eikto,
          t_saida-mstav     TO t_excel-mstav,
          t_saida-bstkd     TO t_excel-bstkd,
          t_saida-bzirk     TO t_excel-bzirk,
          t_saida-bzirk1    TO t_excel-bzirk1,
          t_saida-zterm     TO t_excel-zterm,
          t_saida-stcd1     TO t_excel-stcd1,
          t_saida-stcd2     TO t_excel-stcd2,
          t_saida-stcd3     TO t_excel-stcd3,
          t_saida-stcd4     TO t_excel-stcd4,
          t_saida-pstlz     TO t_excel-pstlz,
          t_saida-stras     TO t_excel-stras,
          t_saida-ort02     TO t_excel-ort02,
          t_saida-kunnr2    TO t_excel-receb1,
*          t_saida-custs     TO t_excel-custs,
          t_saida-waerk     TO t_excel-waerk.
*Display field in Excel file
    t_excel-name2   =  t_saida-name2 .
    t_excel-rel     =  t_saida-rel   .
    t_excel-salgrp  =  t_saida-salgrp.
    t_excel-saltyp  =  t_saida-saltyp.

    CLEAR: out_zzrepcc, zzrepcc_filled, out_zzpaidd, zzpaidd_filled.
    LOOP AT t_vbap WHERE vbeln = t_saida-vbelv.
      IF t_saida-zzrepcc IS INITIAL.
        IF zzrepcc_filled IS INITIAL AND t_vbap-zzrepcc IS NOT INITIAL.
          out_zzrepcc = t_vbap-zzrepcc.
          zzrepcc_filled = 'X'.
        ENDIF.
      ELSE.
        IF zzrepcc_filled IS INITIAL.
          out_zzrepcc = t_saida-zzrepcc.
          zzrepcc_filled = 'X'.
        ENDIF.
      ENDIF.

      IF t_saida-zzpaidd IS INITIAL.
        IF zzpaidd_filled IS INITIAL AND t_vbap-zzpaidd IS NOT INITIAL.
          out_zzpaidd = t_vbap-zzpaidd.
          zzpaidd_filled = 'X'.
        ENDIF.
      ELSE.
        IF zzpaidd_filled IS INITIAL.
          out_zzpaidd = t_saida-zzpaidd.
          zzpaidd_filled = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

    t_excel-zzrepcc = out_zzrepcc.
    t_excel-zzpaidd = out_zzpaidd.
    CONCATENATE t_excel-zzpaidd+6(2) '/' t_excel-zzpaidd+4(2) '/'  t_excel-zzpaidd(4) INTO t_excel-zzpaidd.

    t_excel-zitemno = t_saida-posnr.                    "Item No.


    "   New
*     Moving values to new fields as well                                       "   New
    MOVE : t_saida-vkbur   TO t_excel-vkbur,                                  "   New
           t_saida-vkburt  TO t_excel-vkburt,                                 "   New
           t_saida-vkgrp   TO t_excel-vkgrp,                                  "   New
           t_saida-vkgrpt  TO t_excel-vkgrpt,                                 "   New
           t_saida-kunnr3  TO t_excel-kunnr,                                  "   New
           t_saida-agent   TO t_excel-name1,                                  "   New
           t_saida-mvgr3   TO t_excel-mvgr3,                                  "   New
           t_saida-bezei3  TO t_excel-mvgr3t,                                 "   New
           t_saida-klabc   TO t_excel-klabc1,                                 "   New
           t_saida-ddtext  TO t_excel-klabc1t,                                "   New
           t_saida-mschl   TO t_excel-mschl1,                                 "   New
           t_saida-text1   TO t_excel-mschl1t,                                "   New
           t_saida-lifsp   TO t_excel-lifsp,                                  "   New
           t_saida-faksp   TO t_excel-faksp,                                  "   New
           t_saida-freight_br TO t_excel-freight,                             "   New
           t_saida-pgrp       TO t_excel-pgrp,                                "   New
           t_saida-roteiro TO t_excel-troto.                                  "   New
    REPLACE ALL OCCURENCES OF '#' IN t_excel-troto WITH ` `.
    SPLIT t_saida-bezei  AT '-' INTO t_excel-mvgr4  t_excel-mvgr4t.           "   New
    t_excel-receb1 = t_saida-kunnr2.                                          "   New
    SELECT SINGLE name1 FROM kna1 INTO t_excel-receb1t                        "   New
                                                WHERE kunnr = t_saida-kunnr2. "   New
    IF sy-subrc <> 0.
      lv_t1 = lv_t2.
    ENDIF.
    READ TABLE t_vbpa WITH KEY vbeln = t_excel-ordem parvw = 'RG' BINARY SEARCH.     "   New
    IF sy-subrc = 0.                                                   "   New
      t_excel-kunnr4 = t_vbpa-kunnr.                                   "   New
      CLEAR wa_kna1.                                                   "   New
      READ TABLE itab_kna1 INTO wa_kna1 WITH KEY kunnr = t_vbpa-kunnr. "   New
      IF sy-subrc = 0 .                                                "   New
        t_excel-parvwt = wa_kna1-name1.                                "   New
        t_excel-kunnr4_ad = wa_kna1-stras.
      ENDIF.                                                           "   New
    ENDIF.                                                             "   New
    "   New
    IF  t_saida-v_so IS NOT INITIAL.
      t_excel-ordem = ''.
      CLEAR t_excel-zitemno.
    ENDIF.
    t_excel-zzcre_blk  = e_saida-zzcre_blk.
    CONCATENATE e_saida-zzdate_blk+6(2) '/'
                e_saida-zzdate_blk+4(2) '/'
                e_saida-zzdate_blk+0(4) INTO t_excel-zzdate_blk.

    APPEND t_excel.
    IF e_saida-auart = l_const23 OR e_saida-auart = l_const24
    OR e_saida-auart = lv_const30 OR e_saida-auart = lv_const31.
*--------------------------------------------------------------------*
      MOVE-CORRESPONDING  e_saida TO t_excel.
      MOVE-CORRESPONDING  t_saida TO t_excel.
      CLEAR lv_contract_line.
      CLEAR t_excel-ordem.
      CLEAR t_excel-usd_value.
*--------------------------------------------------------------------*
      MOVE: t_saida-werks      TO t_excel-centro,
            t_saida-matnr      TO t_excel-produto,
            t_saida-arktx      TO t_excel-descri,
            gv_quantity        TO t_excel-qprog,
            gv_quantity        TO t_excel-qpend,
            t_saida-kbetr      TO t_excel-vlruni,
            t_saida-taxa       TO t_excel-usd_rate.
      t_excel-real_value = t_excel-vlruni * gv_quantity.
      t_excel-usd_value  = t_excel-real_value / t_saida-taxa.
      CLEAR t_excel-qremet.

      READ TABLE t_vbpa WITH KEY vbeln = t_excel-contract_no parvw = 'RG' .     "   New
      IF sy-subrc = 0.                                                   "   New
        t_excel-kunnr4 = t_vbpa-kunnr.                                   "   New
        CLEAR wa_kna1.                                                   "   New
        READ TABLE itab_kna1 INTO wa_kna1 WITH KEY kunnr = t_vbpa-kunnr. "   New
        IF sy-subrc = 0 .                                                "   New
          t_excel-parvwt = wa_kna1-name1.                                "   New
          t_excel-kunnr4_ad = wa_kna1-stras.
        ENDIF.                                                           "   New
      ENDIF.                                                             "   New


      READ TABLE t_excel WITH KEY contract_no = t_excel-contract_no
                                  ordem       = space TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
* Flag is set to display only one line of contract
        lv_contract_line = 1.
      ENDIF.
* If Flag is set display line for contract
      IF lv_contract_line IS NOT INITIAL.
        APPEND t_excel.
      ENDIF.
      CLEAR t_excel.
    ENDIF.

  ENDIF.
ENDFORM.                     " excel
*&---------------------------------------------------------------------*
*&      Form  f_consiste_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_consiste_data.

  IF s_erdat IS INITIAL AND s_edatu IS INITIAL.
    MESSAGE e368(zxunity) WITH 'Data de criação ou date de divisão de'(037)
                            'divisão de remessa deve ser preenchida'(038).
  ENDIF.


  IF NOT s_erdat IS INITIAL AND NOT s_edatu IS INITIAL.
    MESSAGE e368(zxunity)
    WITH 'Somente a data de criação ou a data de divisão '(039)
         'deve ser preenchida'(040).
  ENDIF.




ENDFORM.                    " f_consiste_data
*&---------------------------------------------------------------------*
*&      Form  cabec_excel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cabec_excel.

  DELETE  t_excel WHERE version = 'Versão'.                                                        "CHG160438
  MOVE: 'Versão'(245)                TO t_excel-version,
        text-029                     TO t_excel-centro,
        text-t03                     TO t_excel-name2,
        'Data'(041)                  TO t_excel-data,
*        'Hora'(042)                  TO t_excel-hora,
        'Organização de Vendas'(154) TO t_excel-vkorg,
        'Contrato SAP'(098)          TO t_excel-contract_no,                                                 " Changed name
        'Tipo de Contrato'(097)      TO t_excel-contract_type,
        'Replacement Contract'(167)  TO t_excel-zzrepcc,
        'Pago data'(168)             TO t_excel-zzpaidd,
        'Contrato MOL'(150)          TO t_excel-bstkd,                                                       " Changed name
        'Ordem Vendas'(043)          TO t_excel-ordem,                                                       " Changed name
        'Status do Contrato'(100)    TO t_excel-cont_status,
        'Num Cliente'(044)           TO t_excel-numcli,
        'Nom Cliente'(045)           TO t_excel-nomcli,
        'Modalidade'(046)            TO t_excel-modali,     "
        'Gerente Nacional'(148)      TO t_excel-bzirk,
        'Nome Gerente Nacional'(250) TO t_excel-bzirk1,
*        'Filial'(047)                TO t_excel-filial,                                                     " Need to remove
        'Gerente'(222)               TO t_excel-vkbur,                                                       "   new
        'Nome gerente'(223)          TO t_excel-vkburt,                                                      "   new
*        'Supervisor'(048)            TO t_excel-supervisor,                                                 " Need to remove
        'Supervisor'(226)            TO t_excel-vkgrp,                                                       "   new
        'Nome supervisor'(224)       TO t_excel-vkgrpt,                                                      "   new
*        'Agente'(049)                TO t_excel-agente,                                                     " Need to remove
        'Agente'(227)                TO t_excel-kunnr,                                                       "   new
        'Nome agente'(225)           TO t_excel-name1,                                                       "   new
        'Data Vencimento'(050)       TO t_excel-dvenc,
        'Data Credito'(051)          TO t_excel-dcred,
        'Data inicial'(054)          TO t_excel-dini,
        'Data final'(055)            TO t_excel-dfim,
        'Data criação'(056)          TO t_excel-dcria,
        'Data entrega'(080)          TO t_excel-edatu,      "
        'Estado'(057)                TO t_excel-dest,
        'Cidade'(058)                TO t_excel-dest2,
        'Bairro'(209)                TO t_excel-ort02,
        'Produto'(059)               TO t_excel-produto,    "
        'Descrição produto'(060)     TO t_excel-descri,     "
        'Qtd Programada'(061)        TO t_excel-qprog,
        'Qtd remetida'(062)          TO t_excel-qremet,
        'Qtd Pendente'(063)          TO t_excel-qpend,
        'Vlr.Unitário'(064)          TO t_excel-vlruni,
         text-217                    TO t_excel-waerk,
        'Valor em Reais'(091)       TO t_excel-real_value,
        'Taxa do Dolar'(141)        TO t_excel-usd_rate,
        'Valor em Dolar'(105)       TO t_excel-usd_value,
        'Comissão'(074)              TO t_excel-zra0,
*        'Fixed USD Rate'(175)        TO t_excel-zexrate,
*        'Unit Value R$'(176)         TO t_excel-zvalorunit,
*        'Tipo de embalagem'(146)     TO t_excel-bag,                                                        " Need to remove
        'Tipo de embalagem'(228)     TO t_excel-mvgr3,                                                       "   new
        'Descrição Tipo de embalagem'(229) TO t_excel-mvgr3t,                                                "   new
*        'Cultura'(065)               TO t_excel-cult,                                                       " Need to remove
        'Cultura'(230)               TO t_excel-mvgr4,                                                       "   new
        'Descrição da cultura'(231)	 TO t_excel-mvgr4t,                                                      "   new
        'Bl Rem'(066)                TO t_excel-blrem,      "
        'Bl pgto'(067)               TO t_excel-blpgto,     "
        'Bl Cred'(068)               TO t_excel-blcred,     "
        'Bl Rem item'(232)           TO t_excel-lifsp,                                                       "   new
        'Bl Fat item'(233)           TO t_excel-faksp,                                                       "   new
        'Motivo de Recusa'(069)      TO t_excel-motrec,
        'Criado por'(070)            TO t_excel-ernam,
*        'Segmentação'(151)           TO t_excel-klabc,                                                      " Need to remove
        'Segmentação'(234)           TO t_excel-klabc1,                                                      "   new
        'Descrição Segmentação'(235) TO t_excel-klabc1t,                                                     "   new
        'Grupo de Clientes'(152)     TO t_excel-kdgrp,
        'Cond Pagto'(147)            TO t_excel-zterm,      "
*        'Tipo de Recurso'(149)       TO t_excel-mschl,                                                      " Need to remove
        'Tipo de Recurso'(236)       TO t_excel-mschl1,                                                      "   new
        'Descrição Tipo de Recurso'(237) TO t_excel-mschl1t,                                                 "   new
        'Agrupamento'(072)           TO t_excel-eikto,      "
        'Bloq Material'(073)         TO t_excel-mstav,      "
        'CNPJ'(201)                  TO t_excel-stcd1,
        'CPF'(202)                   TO t_excel-stcd2,
        'Inscrição Estadual'(203)    TO t_excel-stcd3,
        'Inscrição Munipal'(204)     TO t_excel-stcd4,
*        'Tax Jurisdiction code'(177) TO t_excel-ztaxzur,
        'Cód. Postal'(205)           TO t_excel-pstlz,
        'Endereço'(206)              TO t_excel-stras,
*        'Recebedor'(210)             TO t_excel-receb,                                                      " Need to remove
        'Recebedor'(238)             TO t_excel-receb1,                                                      "   new
        'Nome Recebedor'(239)        TO t_excel-receb1t,                                                     "   new
*        'Estr. Clientes'(211)        TO t_excel-custs,
        text-t01                     TO t_excel-salgrp,
        text-t02                     TO t_excel-saltyp,
        text-t04                     TO t_excel-rel,
        'Item Number'(178)           TO t_excel-zitemno,                                                     " Position Change
        'SAP Contract item'(247)     TO t_excel-zitemno1,                                                    "   New
        text-220                     TO t_excel-zzcre_blk,
        text-221                     TO t_excel-zzdate_blk,
*        'Customer PO Header'(173)    TO t_excel-zzcust_po,
*        'Customer PO Item'(174)      TO t_excel-zzcust_po_item,
*        text-073                     TO t_excel-delvblock,
        'Pagador'(240)               TO t_excel-kunnr4,                                                      "   new
        'Nome Pagador'(241)          TO t_excel-parvwt,                                                      "   new
        'Endereço Pagador'(249)      TO t_excel-kunnr4_ad,                                                   "   new
        'Frete Estatístico (ZFRT)'(242) TO t_excel-freight,                                                  "   new
        'Grupo embalagem'(243)       TO t_excel-pgrp,                                                        "   new
        'Texto Roteiro'(244)         TO t_excel-troto.                                                       "   new

  APPEND t_excel.
  CLEAR t_excel.
ENDFORM.                    " cabec_excel

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_RANGE
*&---------------------------------------------------------------------*
FORM f_monta_range.

  CLEAR r_condicao[].
* Monta Range com as condições de pagamento.
  r_condicao-sign   = 'I'.
  r_condicao-option = 'EQ'.


  MOVE 'ZD01' TO r_condicao-low.
  APPEND r_condicao.

  MOVE 'ZDOR' TO r_condicao-low.
  APPEND r_condicao.

  MOVE 'ZE01' TO r_condicao-low.
  APPEND r_condicao.

  MOVE 'ZO01' TO r_condicao-low.
  APPEND r_condicao.

  MOVE 'Y17' TO r_condicao-low.
  APPEND r_condicao.

  MOVE 'Y51' TO r_condicao-low.
  APPEND r_condicao.

  CLEAR  r_condicao.


  IF s_custs IS NOT INITIAL.
    CLEAR s_klabc[].
    s_klabc-sign    = 'I'.
    s_klabc-option  = 'EQ'.

    CLEAR s_kdgrp[].
    s_kdgrp-sign    = 'I'.
    s_kdgrp-option  = 'EQ'.

    LOOP AT itab_zvar INTO wa_zvar WHERE descr IN s_custs.
      APPEND wa_zvar TO itab_zvaru.
    ENDLOOP.

    CLEAR wa_zvar.

    itab_zvart = itab_zvaru.
    SORT itab_zvart BY var2.
    DELETE ADJACENT DUPLICATES FROM itab_zvart COMPARING var2.
    LOOP AT itab_zvart INTO wa_zvar.
      MOVE wa_zvar-var2 TO s_kdgrp-low.
      APPEND s_kdgrp.
    ENDLOOP.

    CLEAR wa_zvar.

    itab_zvart = itab_zvaru.
    SORT itab_zvart BY var3.
    DELETE ADJACENT DUPLICATES FROM itab_zvart COMPARING var3.
    LOOP AT itab_zvart INTO wa_zvar.
      MOVE wa_zvar-var3 TO s_klabc-low.
      APPEND s_klabc.
    ENDLOOP.
  ENDIF.

  CLEAR: itab_zvaru, itab_zvart, wa_zvar, s_klabc, s_kdgrp.
ENDFORM.                    " F_MONTA_RANGE
*
*&---------------------------------------------------------------------*
*&      Form  CHECK_DELIVERY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_delivery .

  MOVE t_saida-vbeln TO pvbeln.

  READ TABLE xvbak INTO lvbak WITH KEY vbeln = pvbeln.
  IF sy-subrc = 0.

    READ TABLE xvbap INTO lvbap WITH KEY vbeln = pvbeln.
    IF sy-subrc = 0.

      LOOP AT xvbap INTO lvbap.
        READ TABLE xvbak INTO lvbak WITH KEY vbeln = lvbap-vbeln.

        PERFORM read_vbup.
        PERFORM read_vbfa.
        PERFORM read_vbkd.
        PERFORM read_vbep.

        IF sy-subrc <> 0. CONTINUE. ENDIF.

        PERFORM check_deliveries.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  read_vbup
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_vbup.

  FREE xvbup[].
  LOOP AT xxvbup INTO lvbup WHERE vbeln  = lvbap-vbeln AND posnr  = lvbap-posnr.
    APPEND lvbup TO xvbup.
  ENDLOOP.



ENDFORM.                    " read_vbup
*&---------------------------------------------------------------------*
*&      Form  read_vbfa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_vbfa.

  FREE xvbfa[].

  LOOP AT xxvbfa INTO lvbfa WHERE vbeln  = lvbap-vbeln AND posnv  = lvbap-posnr AND vbtyp_n  = l_const10.
    APPEND lvbfa  TO xvbfa.
  ENDLOOP.

ENDFORM.                    " read_vbfa
*&---------------------------------------------------------------------*
*&      Form  read_vbkp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_vbkd .

  FREE xvbkd[].

  LOOP AT xxvbkd INTO llvbkd WHERE vbeln  = lvbap-vbeln AND posnr  = lvbap-posnr.
    lvbkd-vbeln = llvbkd-vbeln.
    lvbkd-posnr = llvbkd-posnr.
    lvbkd-inco1 = llvbkd-inco1.
    APPEND lvbkd  TO xvbkd.
  ENDLOOP.
ENDFORM.                    " read_vbkp
*&---------------------------------------------------------------------*
*&      Form  read_vbep
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_vbep.

  FREE xvbep[].

  LOOP AT xxvbep INTO lvbep WHERE vbeln  = lvbap-vbeln AND posnr  = lvbap-posnr AND  bmeng  > 0.
    APPEND lvbep  TO xvbep.
  ENDLOOP.

ENDFORM.                    " read_vbep

*&---------------------------------------------------------------------*
*&      Form  check_deliveries
*&---------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM check_deliveries.

  DATA: zvbap TYPE STANDARD TABLE OF vbapvb ,
        lzvbap TYPE vbapvb.
  lzvbap-mandt = lvbap-mandt.
  lzvbap-vbeln = lvbap-vbeln.
  lzvbap-posnr = lvbap-posnr.
  lzvbap-kwmeng = lvbap-kwmeng.
  lzvbap-kbmeng = lvbap-kbmeng.
  lzvbap-matnr = lvbap-matnr.
  lzvbap-arktx = lvbap-arktx.
  lzvbap-netwr = lvbap-netwr.
  APPEND lzvbap TO zvbap.
  CALL FUNCTION 'RV_SCHEDULE_CHECK_DELIVERIES'
    EXPORTING
      fbeleg                  = lvbap-vbeln
      fposnr                  = lvbap-posnr
    TABLES
      fvbfa                   = xvbfa
      fvbup                   = xvbup
      fxvbep                  = xvbep
      fvbap                   = zvbap
    EXCEPTIONS
      fehler_bei_lesen_fvbup  = 1
      fehler_bei_lesen_fxvbep = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  READ TABLE xvbkd INTO lvbkd WITH KEY vbeln = lvbap-vbeln
                                       posnr = lvbap-posnr.
  MOVE lvbkd-inco1 TO lvbep_out-inco1.
  MOVE lvbap-abgru   TO lvbep_out-abgru.
  MOVE lvbap-werks   TO lvbep_out-werks.
  MOVE lvbak-lifsk   TO lvbep_out-lifsk.
  MOVE lvbak-vkgrp   TO lvbep_out-vkgrp.
  MOVE lvbap-matkl   TO lvbep_out-matkl.
  MOVE lvbak-kunnr   TO lvbep_out-kunnr.

  LOOP AT xvbep INTO lvbep.
    MOVE-CORRESPONDING lvbep TO lvbep_out.
    APPEND lvbep_out TO vbep_out.
  ENDLOOP.
  CLEAR lzvbap.
  FREE : xvbfa[], xvbup[], xvbep[], zvbap[].

ENDFORM.                    " check_deliveries
*&---------------------------------------------------------------------*
*&      Form  BAL_QUANTITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bal_quantity .
  CLEAR v_name.
  CONCATENATE t_saida-vbelv t_saida-posnr INTO v_name.
  IF sy-langu = 'E'.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client          = sy-mandt
        id              = 'Z011'
        language        = 'E'
        name            = v_name
        object          = 'VBBP'
      TABLES
        lines           = text_bq
      EXCEPTIONS
        object          = 1
        id              = 2
        language        = 3
        name            = 4
        not_found       = 5
        reference_check = 6.

    READ TABLE text_bq INDEX 1.
    IF sy-subrc = 0.
      MOVE text_bq-tdline TO t_saida-tdtext.
    ELSE.
      MOVE '                    '(140) TO t_saida-tdtext.
    ENDIF.

  ELSEIF sy-langu = 'P' .
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id              = 'Z011'
        language        = 'P'
        name            = v_name
        object          = 'VBBP'
      TABLES
        lines           = text_bq
      EXCEPTIONS
        object          = 1
        id              = 2
        language        = 3
        name            = 4
        not_found       = 5
        reference_check = 6.


    READ TABLE text_bq INDEX 1.
    IF sy-subrc = 0.
      MOVE text_bq-tdline TO t_saida-tdtext.
    ELSE.
      MOVE '                    '(140) TO t_saida-tdtext.
    ENDIF.
  ENDIF.

ENDFORM.                    " BAL_QUANTITY
*&---------------------------------------------------------------------*
*&      Form  CHANGE_CONST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_const .

  CLEAR:  l_const1,l_const2,l_const3,l_const4,l_const5,
          l_const6,l_const7,l_const8,l_const9,l_const10,l_const11,l_const12,
          l_const13,l_const14,l_const15,
          l_const16,l_const17,l_const18,l_const19,l_const20,l_const21,l_const22, t_const,
          lv_const25,lv_const26,lv_const27, lv_const28,lv_const29.

  CALL FUNCTION 'ZUTI3001_READ_PROG_VALUES'
    EXPORTING
      i_program   = sy-repid
    TABLES
      t_ztut_valu = t_const.

  SORT t_const.
  READ TABLE t_const WITH KEY progr = sy-repid
                            posit = c_const1.
  IF sy-subrc = 0.
    l_const1 = t_const-value.
  ENDIF.
  CLEAR t_const.
  READ TABLE t_const WITH KEY progr = sy-repid
                             posit = c_const2.
  IF sy-subrc = 0.
    l_const2 = t_const-value.
  ENDIF.
  CLEAR t_const.
  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const3.
  IF sy-subrc = 0.
    l_const3 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const4.
  IF sy-subrc = 0.
    l_const4 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const5.
  IF sy-subrc = 0.
    l_const5 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                             posit = c_const6.
  IF sy-subrc = 0.
    l_const6 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                             posit = c_const49.
  IF sy-subrc = 0.
    l_const49 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                             posit = c_const7.
  IF sy-subrc = 0.
    l_const7 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const8.
  IF sy-subrc = 0.
    l_const8 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const9.
  IF sy-subrc = 0.
    l_const9 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const10.
  IF sy-subrc = 0.
    l_const10 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                             posit = c_const11.
  IF sy-subrc = 0.
    l_const11 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                               posit = c_const12.
  IF sy-subrc = 0.
    l_const12 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                               posit = c_const50.
  IF sy-subrc = 0.
    l_const50 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const13.
  IF sy-subrc = 0.
    l_const13 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const14.
  IF sy-subrc = 0.
    l_const14 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const15.
  IF sy-subrc = 0.
    l_const15 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                             posit = c_const16.
  IF sy-subrc = 0.
    l_const16 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                          posit = c_const17.
  IF sy-subrc = 0.
    l_const17 = t_const-value.
  ENDIF.
  CLEAR t_const.

  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const18.
  IF sy-subrc = 0.
    l_const18 = t_const-value.
  ENDIF.

  CLEAR t_const.
  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const19.
  IF sy-subrc = 0.
    l_const19 = t_const-value.
  ENDIF.

  CLEAR t_const.
  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const20.
  IF sy-subrc = 0.
    l_const20 = t_const-value.
  ENDIF.

  CLEAR t_const.
  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const21.
  IF sy-subrc = 0.
    l_const21 = t_const-value.
  ENDIF.

  CLEAR t_const.
  READ TABLE t_const WITH KEY progr = sy-repid
                           posit = c_const22.
  IF sy-subrc = 0.
    l_const22 = t_const-value.
  ENDIF.

  CLEAR: t_const, l_const23.
  READ TABLE t_const WITH KEY progr = sy-repid
                              posit = c_const23.
  IF sy-subrc = 0.
    l_const23 = t_const-value.
  ENDIF.

  CLEAR: t_const, l_const24.
  READ TABLE t_const WITH KEY progr = sy-repid
                              posit = c_const24.
  IF sy-subrc = 0.
    l_const24 = t_const-value.
  ENDIF.
*Read new contract types  and move to local variables
  CLEAR: t_const, lv_const25.
  READ TABLE t_const WITH KEY progr = sy-repid
                              posit = c_const25."ZUQB
  IF sy-subrc = 0.
    lv_const25 = t_const-value.
  ENDIF.
  CLEAR: t_const, lv_const26.
  READ TABLE t_const WITH KEY progr = sy-repid
                              posit = c_const26."ZUQN
  IF sy-subrc = 0.
    lv_const26 = t_const-value.
  ENDIF.
  CLEAR: t_const, lv_const27.
  READ TABLE t_const WITH KEY progr = sy-repid
                              posit = c_const27."ZUCA
  IF sy-subrc = 0.
    lv_const27 = t_const-value.
  ENDIF.
  CLEAR: t_const, lv_const28.
  READ TABLE t_const WITH KEY progr = sy-repid
                              posit = c_const28."ZUCB
  IF sy-subrc = 0.
    lv_const28 = t_const-value.
  ENDIF.
  CLEAR: t_const, lv_const29.
  READ TABLE t_const WITH KEY progr = sy-repid
                              posit = c_const29."ZEUB
  IF sy-subrc = 0.
    lv_const29 = t_const-value.
  ENDIF.
  CLEAR: t_const, lv_const30.
  READ TABLE t_const WITH KEY progr = sy-repid
                              posit = c_const30."ZUDB
  IF sy-subrc = 0.
    lv_const30 = t_const-value.
  ENDIF.
  CLEAR: t_const, lv_const31.
  READ TABLE t_const WITH KEY progr = sy-repid
                              posit = c_const31."ZUDN
  IF sy-subrc = 0.
    lv_const31 = t_const-value.
  ENDIF.
  CLEAR: itab_supply_const[].
* Read constant values defined in transaction ZUTI3001
  CALL FUNCTION 'ZUTI3001_READ_PROG_VALUES'
    EXPORTING
      i_program   = c_supply
    TABLES
      t_ztut_valu = itab_supply_const.
ENDFORM.                    " CHANGE_CONST
*&---------------------------------------------------------------------*
*&      FORM  validate_email_addr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_email_addr.

  DATA : lv_str1     TYPE string,
         lv_str2     TYPE string,
         lv_msg1(50) TYPE c,
         lv_msg2(50) TYPE c.
  IF p_email IS NOT INITIAL.
*check validity of the Email ID
    CLEAR: lv_str1, lv_str2.
    SPLIT p_email AT '@' INTO lv_str1 lv_str2.
*only company mail address allowed
    IF lv_str2 <> 'mosaicco.com'.
      SET CURSOR FIELD 'P_EMAIL'.
      MESSAGE e000(zcst_messid) WITH text-156.
    ENDIF.
*Email functionality is applicable only in background
*Hence, if report executed in foreground then display error message
    IF ( sy-batch = ' ' AND sy-ucomm = 'ONLI' ) OR
       ( sy-batch = ' ' AND sy-ucomm = 'PRIN' ).
      CLEAR: lv_msg1, lv_msg2.
      lv_msg1 = 'Funcionalidade de email disponivel apenas em bkgrd'(165).
      lv_msg2 = '(processos executados através de Job)'(166).
      SET CURSOR FIELD 'P_EMAIL'.
      MESSAGE e000(zcst_messid) WITH lv_msg1 lv_msg2.
    ENDIF.
  ENDIF.

ENDFORM.                    "validate_email_addr
*&---------------------------------------------------------------------*
*&      FORM  send_email
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_email.

*progress indicator for sending email
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 80
      text       = text-157.

  PERFORM format_attachment.

  TRY.
*create persistent send request
      v_send_request = cl_bcs=>create_persistent( ).

*create and set document with attachment
*create document object from internal table with text
      REFRESH itab_text.
      APPEND text-158             TO itab_text.
      APPEND '      '             TO itab_text.
      IF t_excel[] IS NOT INITIAL.
        APPEND text-159           TO itab_text.
      ELSEIF t_excel[] IS INITIAL.
        APPEND text-160           TO itab_text.
      ENDIF.
      APPEND text-161             TO itab_text.
      APPEND '      '             TO itab_text.
      APPEND text-162             TO itab_text.

      v_subject = text-163.

      v_document = cl_document_bcs=>create_document( i_type    = 'RAW'
                                                     i_text    = itab_text
                                                     i_subject = v_subject ).

*add excel as an attachment to document object
      v_document->add_attachment( i_attachment_type    = 'xls'
                                  i_attachment_subject = v_subject
                                  i_attachment_size    = v_size
                                  i_att_content_hex    = v_solix ).

*add document object to send request
      v_send_request->set_document( v_document ).

      TRANSLATE p_email TO LOWER CASE.
      v_recipient = cl_cam_address_bcs=>create_internet_address( p_email ).
      v_send_request->add_recipient( i_recipient = v_recipient ).

*set sender as a Dummy ID(user name = 'ZBATCHUSER')
      v_sender = cl_sapuser_bcs=>create( 'ZBATCHUSER' ).
      CALL METHOD v_send_request->set_sender
        EXPORTING
          i_sender = v_sender.

*send document
      v_send = v_send_request->send( i_with_error_screen = 'X' ).
      COMMIT WORK.
      IF v_send IS INITIAL.
        MESSAGE i500(sbcoms) WITH p_email.
      ENDIF.

*exception handling
    CATCH cx_bcs INTO v_bcs_exception.
      MESSAGE i865(so) WITH v_bcs_exception->error_type.
  ENDTRY.

ENDFORM.                    "send_email
*&---------------------------------------------------------------------*
*&      FORM  format_attachment
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM format_attachment.

* convert the text string into UTF-16LE binary data including
* byte-order-mark. Mircosoft Excel prefers these settings
  IF t_excel[] IS NOT INITIAL.
    CLEAR v_string.
    LOOP AT t_excel.
      CONCATENATE v_string
                  t_excel-version        c_tab
                  t_excel-centro         c_tab
                  t_excel-name2          c_tab
                  t_excel-data           c_tab
*                  t_excel-hora           c_tab
                  t_excel-vkorg          c_tab
                  t_excel-contract_no    c_tab
                  t_excel-contract_type  c_tab
                  t_excel-zzrepcc        c_tab
                  t_excel-zzpaidd        c_tab
                  t_excel-bstkd	         c_tab
                  t_excel-ordem          c_tab
                  t_excel-cont_status    c_tab
                  t_excel-numcli         c_tab
                  t_excel-nomcli         c_tab
                  t_excel-modali         c_tab
                  t_excel-bzirk          c_tab
                  t_excel-bzirk1         c_tab
*                  t_excel-filial         c_tab
                  t_excel-vkbur          c_tab              "
                  t_excel-vkburt         c_tab              "
*                  t_excel-supervisor     c_tab
                  t_excel-vkgrp          c_tab              "
                  t_excel-vkgrpt         c_tab              "
*                  t_excel-agente         c_tab
                  t_excel-kunnr          c_tab              "
                  t_excel-name1          c_tab              "
                  t_excel-dvenc          c_tab
                  t_excel-dcred          c_tab
                  t_excel-dini           c_tab
                  t_excel-dfim           c_tab
                  t_excel-dcria          c_tab
                  t_excel-edatu          c_tab
                  t_excel-dest           c_tab
                  t_excel-dest2          c_tab
                  t_excel-ort02          c_tab
                  t_excel-produto        c_tab
                  t_excel-descri         c_tab
                  t_excel-qprog          c_tab
                  t_excel-qremet         c_tab
                  t_excel-qpend          c_tab
                  t_excel-vlruni         c_tab
                  t_excel-waerk          c_tab
                  t_excel-real_value     c_tab
                  t_excel-usd_rate       c_tab
                  t_excel-usd_value      c_tab
                  t_excel-zra0           c_tab

                  t_excel-mvgr3          c_tab              "
                  t_excel-mvgr3t         c_tab              "

                  t_excel-mvgr4          c_tab              "
                  t_excel-mvgr4t         c_tab              "
                  t_excel-blrem          c_tab
                  t_excel-blpgto         c_tab
                  t_excel-blcred         c_tab
                  t_excel-lifsp          c_tab              "
                  t_excel-faksp          c_tab              "
                  t_excel-motrec         c_tab
                  t_excel-ernam          c_tab

                  t_excel-klabc1         c_tab              "
                  t_excel-klabc1t        c_tab              "
                  t_excel-kdgrp          c_tab
                  t_excel-zterm          c_tab
*                  t_excel-mschl          c_tab
                  t_excel-mschl1         c_tab              "
                  t_excel-mschl1t        c_tab              "
                  t_excel-eikto          c_tab
                  t_excel-mstav          c_tab
                  t_excel-stcd1          c_tab
                  t_excel-stcd2          c_tab
                  t_excel-stcd3          c_tab
                  t_excel-stcd4          c_tab
                  t_excel-pstlz          c_tab
                  t_excel-stras          c_tab
*                  t_excel-receb          c_tab
                  t_excel-receb1         c_tab              "
                  t_excel-receb1t        c_tab              "
                  t_excel-salgrp         c_tab
                  t_excel-saltyp         c_tab
                  t_excel-rel            c_tab
                  t_excel-zitemno        c_tab    " Position Change
                  t_excel-zitemno1       c_tab    " New
                  t_excel-zzcre_blk      c_tab
                  t_excel-zzdate_blk     c_tab

                  t_excel-kunnr4         c_tab              "
                  t_excel-parvwt         c_tab              "
                  t_excel-kunnr4_ad      c_tab              "
                  t_excel-freight        c_tab              "
                  t_excel-pgrp           c_tab              "
                  t_excel-troto          c_crlf             "
                  INTO v_string.
      CLEAR t_excel.
    ENDLOOP.

    TRY.
        cl_bcs_convert=>string_to_solix(
          EXPORTING
            iv_string   = v_string
            iv_codepage = '4103'
            iv_add_bom  = 'X'
          IMPORTING
            et_solix  = v_solix
            ev_size   = v_size ).
      CATCH cx_bcs.
        MESSAGE e445(so).
    ENDTRY.
  ENDIF.

ENDFORM.                    "format_attachment



*&---------------------------------------------------------------------*
*&      Form  fill_zvar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_zvar.
  SELECT DISTINCT var1 description var2 var3
    FROM zvar
    INTO TABLE itab_zvar
   WHERE var1 = c_palantir.

  SELECT DISTINCT description
    FROM zvar
    INTO TABLE itab_zvars
   WHERE var1 = c_palantir.
*--- Fetching data from ZVAR to get Reference Status
  SELECT var1
         description
         var2
         var3
    FROM zvar
    INTO TABLE itab_zvarf
    WHERE var1 = c_zsdr3002
      AND var2 = c_rfstk.
*---Fetch the Blocking Code for Dilivery and Billing

  SELECT var1
        description
        var2
        var3
        var4
   FROM zvar
   INTO TABLE itab_zvarb
   WHERE var1 = c_chg1
    AND var4 IN ('C', 'G').


  SELECT var1
        description
        var2
        var3
        var4
   FROM zvar
   INTO TABLE itab_zvarc
   WHERE var1 = c_chg1
    AND description = 'ELO_MVGR3'.




ENDFORM.                    "fill_zvar

*&---------------------------------------------------------------------*
*&      Form  check_customer_structure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_customer_structure.
  IF s_custs IS NOT INITIAL.
    CLEAR wa_dyfields-fieldvalue.
    wa_dyfields-fieldname = 'S_KLABC-LOW'.
    APPEND wa_dyfields TO itab_dyfields.

    wa_dyfields-fieldname = 'S_KLABC-HIGH'.
    APPEND wa_dyfields TO itab_dyfields.

    wa_dyfields-fieldname = 'S_KDGRP-LOW'.
    APPEND wa_dyfields TO itab_dyfields.

    wa_dyfields-fieldname = 'S_KDGRP-HIGH'.
    APPEND wa_dyfields TO itab_dyfields.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname     = sy-cprog
        dynumb     = sy-dynnr
      TABLES
        dynpfields = itab_dyfields.

    CLEAR s_klabc.
    CLEAR s_kdgrp.
    CLEAR s_klabc[].
    CLEAR s_kdgrp[].
  ENDIF.

  LOOP AT SCREEN.
    IF s_custs IS NOT INITIAL.
      IF screen-group1 = 'KLA'.
        screen-input = '0'.
      ENDIF.
    ELSE.
      IF screen-group1 = 'KLA'.
        screen-input = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  CLEAR itab_dyfields.

ENDFORM.                    "check_customer_structure
*&---------------------------------------------------------------------*
*&      Form  UPD_DELV_BLOCK
*&---------------------------------------------------------------------*
*--- Updating Delivery block into Excel sheet
*----------------------------------------------------------------------*
FORM upd_delv_block .
*--- Fetching Delivery Block Description
  IF NOT t_excel[] IS INITIAL.
    SELECT * FROM tvlst
             INTO TABLE itab_delvblk
             FOR ALL ENTRIES IN t_excel
             WHERE lifsp = t_excel-mstav
               AND spras = sy-langu.
  ENDIF.

*--------------------------------------------------------------------*
ENDFORM.                    " UPD_DELV_BLOCK
*&---------------------------------------------------------------------*
*&      Form  DATE_FORMAT
*&---------------------------------------------------------------------*
FORM date_format  USING    lv_input TYPE char16
                  CHANGING lv_output TYPE char9.
  IF lv_input+0(2) NE '00'.
    CASE lv_input+3(2).
      WHEN '01'. lv_output = 'JAN'.
      WHEN '02'. lv_output = 'FEB'.
      WHEN '03'. lv_output = 'MAR'.
      WHEN '04'. lv_output = 'APR'.
      WHEN '05'. lv_output = 'MAY'.
      WHEN '06'. lv_output = 'JUN'.
      WHEN '07'. lv_output = 'JUL'.
      WHEN '08'. lv_output = 'AUG'.
      WHEN '09'. lv_output = 'SEP'.
      WHEN '10'. lv_output = 'OCT'.
      WHEN '11'. lv_output = 'NOV'.
      WHEN '12'. lv_output = 'DEC'.
    ENDCASE.

    CONCATENATE lv_input+0(2) lv_output lv_input+8(2) INTO lv_output SEPARATED BY '-'.
  ENDIF.

ENDFORM.                    " DATE_FORMAT
*&---------------------------------------------------------------------*
*&      Form  F_AUTHROITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_authroity_check .

  TYPES : BEGIN OF ty_plant,
            werks             TYPE werks_d,                "Plant
          END OF ty_plant.

  DATA : itab_plant          TYPE TABLE OF ty_plant,
         wa_plant            TYPE ty_plant.

  LOOP AT itab_plant INTO wa_plant.
    PERFORM authority USING wa_plant-werks.
    CLEAR wa_plant.
  ENDLOOP.

ENDFORM.                    " F_AUTHROITY_CHECK
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_PLANT_WERKS  text
*----------------------------------------------------------------------*
FORM authority  USING    p_werks TYPE werks_d.

  CONSTANTS:
    c_auth_ob    TYPE char10   VALUE 'Z_SD_EEDC',
    c_werks_auth TYPE char5    VALUE 'WERKS',
    c_actvt      TYPE char5    VALUE 'ACTVT',
    c_16         TYPE char2    VALUE '16'.

*   Validation to check if the entered company code exists and
*   user have authorization for the entered company code
  AUTHORITY-CHECK OBJECT c_auth_ob
      ID c_actvt       FIELD c_16
      ID c_werks_auth  FIELD p_werks.
  IF sy-subrc <> 0.
    MESSAGE e000(zcst_messid) WITH text-251 p_werks.
  ENDIF.                                                                                           "CHG160438

ENDFORM.                    " AUTHORITY
*&---------------------------------------------------------------------*
*&      Form  F_GETCONTDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_getcontdata .                                                                               "CHG160438

  IF NOT t_vbak IS INITIAL.                                                                        "CHG160438
    SELECT * INTO TABLE t_vbap_c FROM vbap                                                         "CHG160438
    FOR ALL ENTRIES IN                                                                             "CHG160438
    t_vbak WHERE vbeln = t_vbak-vbeln .                                                            "CHG160438
    IF sy-subrc  = 0.                                                                              "CHG160438
      SELECT * INTO TABLE t_vbak_c FROM vbak                                                       "CHG160438
      FOR ALL ENTRIES IN                                                                           "CHG160438
      t_vbak WHERE vbeln = t_vbak-vbeln AND vbtyp = 'G'.                                           "CHG160438
      IF sy-subrc  = 0.                                                                            "CHG160438
      ENDIF.                                                                                       "CHG160438
    ENDIF.                                                                                         "CHG160438
  ELSE.                                                                                            "CHG160438
    SELECT * INTO TABLE t_vbap_c FROM vbap                                                         "CHG160438
    FOR ALL ENTRIES IN                                                                             "CHG160438
    t_vbap WHERE vbeln = t_vbap-vbeln                                                              "CHG160438
           AND   vbap~matnr  IN s_matnr                                                            "CHG160438
           AND vbap~matkl  IN s_matkl                                                              "CHG160438
           AND vbap~faksp  <> '98'                                                                 "CHG160438
           AND vbap~kwmeng IN s_kwmeng                                                             "CHG160438
           AND vbap~werks  IN s_werks                                                              "CHG160438
           AND vbap~abgru  IN s_abgru                                                              "CHG160438
           AND vbap~pstyv  NE l_const2                                                             "CHG160438
           AND vbap~mvgr3  IN s_mvgr3.                                                             "CHG160438

    IF sy-subrc  = 0.                                                                              "CHG160438
      SELECT * INTO TABLE t_vbak_c FROM vbak                                                       "CHG160438
      FOR ALL ENTRIES IN                                                                           "CHG160438
      t_vbap WHERE vbeln = t_vbap-vbeln AND vbtyp = 'G'.                                           "CHG160438
      IF sy-subrc  = 0.                                                                            "CHG160438
      ENDIF.                                                                                       "CHG160438
    ENDIF.                                                                                         "CHG160438
  ENDIF.                                                                                           "CHG160438
  IF NOT t_vbap_c[] IS INITIAL.                                                                    "CHG160438
      DELETE t_vbap_c WHERE vbeln+2(1) <> '4'.                                                     "CHG160438
      t_excel1[] = t_excel[] .                                                                     "CHG160438
      DELETE t_excel WHERE ordem IS INITIAL.                                                       "CHG160438
      SELECT vbeln kunnr parvw  INTO TABLE itab_vbpa1 FROM vbpa FOR ALL ENTRIES IN t_vbap_c        "CHG160438
      WHERE vbeln = t_vbap_c-vbeln .                                                               "CHG160438
      IF sy-subrc = 0.                                                                             "CHG160438
        SELECT kunnr name1 INTO TABLE  t_kna5                                                      "CHG160438
        FROM kna1 FOR ALL ENTRIES IN itab_vbpa1                                                    "CHG160438
        WHERE kunnr = itab_vbpa1-kunnr.                                                            "CHG160438
      ENDIF.                                                                                       "CHG160438

      LOOP AT  t_vbap_c.                                                                           "CHG160438
        CLEAR v_temp.                                                                              "CHG160438
        LOOP AT t_vbfa WHERE vbelv = t_vbap_c-vbeln AND posnv = t_vbap_c-posnr AND VBTYP_N = 'C'.  "CHG160438
          v_temp = t_vbfa-rfmng + v_temp.                                                          "CHG160438
        ENDLOOP.                                                                                   "CHG160438
        READ TABLE t_vbak_c WITH KEY vbeln = t_vbap_c-vbeln.                                       "CHG160438
        PERFORM sel_kbert.                                                                         "CHG160438
        CLEAR t_excel.                                                                             "CHG160438
        READ TABLE t_excel1 WITH KEY contract_no = t_vbap_c-vbeln.                                 "CHG160438
        IF sy-subrc = 0.                                                                           "CHG160438
          CLEAR itab_vbpa1.                                                                        "CHG160438
          READ TABLE itab_vbpa1 WITH KEY vbeln = t_vbap_c-vbeln PARVW = 'ZA'.                      "CHG160438
          IF sy-subrc = 0.                                                                         "CHG160438
            CLEAR t_kna5  .                                                                        "CHG160438
            READ TABLE t_kna5 WITH KEY kunnr = itab_vbpa1-kunnr.                                   "CHG160438
          ENDIF.                                                                                   "CHG160438
          t_excel1-kunnr = t_kna5-Kunnr.                                                           "CHG160438
          t_excel1-name1 = t_kna5-agent.                                                           "CHG160438
          t_excel1-qprog = t_vbap_c-zmeng - v_temp.                                                "CHG160438
          t_excel1-qremet = SPACE.                                                                 "CHG160438
          t_excel1-qpend = t_vbap_c-zmeng - v_temp.                                                "CHG160438
          t_excel1-ordem = SPACE.                                                                  "CHG160438
          t_excel1-centro = t_vbap_c-werks.                                                        "CHG160438
          t_excel1-zitemno1 = t_vbap_c-posnr.                                                      "CHG160438
          t_excel1-descri = t_vbap_c-arktx.                                                        "CHG160438
          t_excel1-produto = t_vbap_c-matnr.                                                       "CHG160438
          t_excel1-zitemno = SPACE.                                                                "CHG160438
          t_excel1-vlruni = t_saida-kbetr.                                                         "CHG160438
          t_excel1-real_value = t_excel1-vlruni * ( t_vbap_c-zmeng - v_temp ).                     "CHG160438
          CLEAR t_excel1-usd_value.                                                                "CHG160438
          IF t_excel1-usd_rate > 0.                                                                "CHG160438
              t_excel1-usd_value = t_excel1-real_value / t_excel1-usd_rate.                        "CHG160438
          ELSE.                                                                                    "CHG160438
              t_excel1-usd_value = t_excel1-real_value  .                                          "CHG160438
          ENDIF.                                                                                   "CHG160438
          lv_pac = t_excel1-usd_value.                                                             "CHG160438
          t_excel1-usd_value = lv_pac.                                                             "CHG160438
        ENDIF.                                                                                     "CHG160438
        IF t_excel1-qprog > 0.                                                                     "CHG160438
          APPEND t_excel1 TO t_excel.                                                              "CHG160438
        ENDIF.                                                                                     "CHG160438
      ENDLOOP.                                                                                     "CHG160438
    ENDIF.                                                                                         "CHG160438
ENDFORM.                    " F_GETCONTDATA                                                        "CHG160438
*&---------------------------------------------------------------------*
*&      Form  SEL_KBERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sel_kbert .                                                                                   "CHG160438
  SELECT SINGLE kbetr INTO t_saida-kbetr                                                           "CHG160438
                   FROM  konv                                                                      "CHG160438
                   WHERE knumv EQ t_vbak_c-knumv                                                   "CHG160438
                   AND   kposn EQ t_vbap_c-posnr                                                   "CHG160438
     AND   kschl EQ l_const3                                                                       "CHG160438
     AND   kbetr NE 0.                                                                             "CHG160438
  IF sy-subrc NE 0.                                                                                "CHG160438
    SELECT kbetr INTO t_saida-kbetr                                                                "CHG160438
                    FROM  konv UP TO 1 ROWS                                                        "CHG160438
                    WHERE knumv EQ t_vbak_c-knumv                                                  "CHG160438
                    AND   kposn EQ t_vbap_c-posnr                                                  "CHG160438
      AND   kschl EQ l_const4                                                                      "CHG160438
      AND   kbetr NE 0.                                                                            "CHG160438
    ENDSELECT.                                                                                     "CHG160438
  ENDIF.                                                                                           "CHG160438

ENDFORM.                    " SEL_KBERT                                                            "CHG160438
*&---------------------------------------------------------------------*
*&      Form  DAT_TIM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dat_tim .                                                                                     "CHG160842
  MOVE : sy-datum TO lv_date,                                                                      "CHG160842
         sy-uzeit TO lv_time1.                                                                     "CHG160842
  WRITE  sy-timlo TO lv_time.                                                                      "CHG160842
ENDFORM.                    " DAT_TIM
