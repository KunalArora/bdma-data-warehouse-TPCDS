
BEGIN {
    flag = 0;
}
{
    if (flag > 0 && flag < 7 ) {
        flag++;
    }
    else if (flag == 7) {
        flag = 0;
    }
    else if ($0 ~ /create table.*_text/) {
        split($0, arr, " ");
        
        for ( i in arr ) {
            if (i == 2) {
                printf ("external ");
                printf (arr[i]);
                printf (" ");
            }
            else if (i == 3) {
                sub (/_text/, "", arr[i]);
                print arr[i];
            }
            else {
                printf (arr[i]);
                printf (" ");
            }
        }
    }
    else if ($0 ~ /.*_text;$/) {
        sub (/_text/, "", $0);
        match($0, / [A-Za-z0-9]*$/)
        line = substr($0, RSTART, RLENGTH);
        print line;
    }
    else if ($0 ~ /USING csv/) {
        flag = 1;
        print "ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'";
        getline options
        split (options, array, /DATA_DIR\}\//);
        location = array[2];
        match(location, /\.dat.*$/);
        location = substr(location, 1, RSTART-1);
        printf "LOCATION '${DATA_DIR}/"
        printf location
        print "';";
    }
    else {
        print $0;
    }

}