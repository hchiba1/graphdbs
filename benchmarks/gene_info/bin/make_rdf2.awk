#!/usr/bin/awk -f
BEGIN {
    FS = "\t"
    print "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
    print "@prefix dct: <http://purl.org/dc/terms/> ."
    print "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> ."
    print "@prefix ncbigene: <http://identifiers.org/ncbigene/> ."
    print "@prefix taxid: <http://identifiers.org/taxonomy/> ."
    print "@prefix hgnc: <http://identifiers.org/hgnc/> ."
    print "@prefix mim: <http://identifiers.org/mim/> ."
    print "@prefix mirbase: <http://identifiers.org/mirbase/> ."
    print "@prefix ensembl: <http://identifiers.org/ensembl/> ."
    print "@prefix nuc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/> ."
    print "@prefix : <http://purl.org/net/orthordf/hOP/ontology#> ."
}

{
    if (NR == 1) {
        next # Skip header line
    }
    print ""
    print "ncbigene:" $2 " a nuc:Gene ;"
    print "    dct:identifier " $2 " ;"
    print "    rdfs:label \"" $3 "\" ;"
    if ($11 != "-") {
        print "    nuc:standard_name \"" $11 "\" ;"
    }
    if ($5 != "-") {
        synonym_str = format_str_array($5)
        print "    nuc:gene_synonym " synonym_str " ;"
    }
    print "    dct:description \"" $9 "\" ;"
    if ($14 != "-") {
        others_str = format_str_array($14)
        print "    dct:alternative " others_str " ;"
    }
    dblink_str = ""
    db_xref_str = ""
    if ($6 != "-") {
        split($6, dblinks, "|")
        for (i in dblinks) {
            if (dblinks[i] ~ /^MIM:[0-9]+$/) {
                if (dblink_str != "") {
                    dblink_str = dblink_str " ,\n        "
                }
                dblink_str = dblink_str "mim:" substr(dblinks[i], 5)
            } else if (dblinks[i] ~ /^HGNC:HGNC:[0-9]+$/) {
                if (dblink_str != "") {
                    dblink_str = dblink_str " ,\n        "
                }
                dblink_str = dblink_str "hgnc:" substr(dblinks[i], 11)
            } else if (dblinks[i] ~ /^Ensembl:ENSG[0-9]+$/) {
                if (dblink_str != "") {
                    dblink_str = dblink_str " ,\n        "
                }
                dblink_str = dblink_str "ensembl:" substr(dblinks[i], 9)
            } else if (dblinks[i] ~ /^miRBase:MI[0-9]+$/) {
                if (dblink_str != "") {
                    dblink_str = dblink_str " ,\n        "
                }
                dblink_str = dblink_str "mirbase:" substr(dblinks[i], 9)
            } else {
                if (db_xref_str != "") {
                    db_xref_str = db_xref_str " ,\n        "
                }
                db_xref_str = db_xref_str "\"" dblinks[i] "\""
            }
        }
        print "    nuc:dblink " dblink_str " ;"
    }
    print "    :typeOfGene \"" $10 "\" ;"
    if ($13 == "O") {
        print "    :nomenclatureStatus \"official\" ;"
    } else if ($13 == "I") {
        print "    :nomenclatureStatus \"interim\" ;"
    }
    if ($12 != "-") {
        print "    :fullName \"" $12 "\" ;"
    }
    if ($6 != "-") {
        if (db_xref_str != "") {
            print "    nuc:db_xref " db_xref_str " ;"
        }
    }
    if ($16 != "-") {
        feature_type_str = format_str_array($16)
        print "    :featureType " feature_type_str " ;"
    }
    print "    :taxid taxid:" $1 " ;"
    print "    nuc:chromosome \"" $7 "\" ;"
    print "    nuc:map \"" $8 "\" ;"
    if ($15 != "-") {
        date = format_date($15)
        print "    dct:modified \"" date "\"^^xsd:date ."
    }
}

function format_str_array(str) {
    split(str, arr, "|")
    str_arr = ""
    for (i in arr) {
        if (str_arr != "") {
            str_arr = str_arr " ,\n        "
        }
        str_arr = str_arr "\"" arr[i] "\""
    }
    return str_arr
}

function format_date(date) {
    if (date ~ /^([0-9]{4})([0-9]{2})([0-9]{2})$/) {
        return substr(date, 1, 4) "-" substr(date, 5, 2) "-" substr(date, 7, 2)
    }
}
